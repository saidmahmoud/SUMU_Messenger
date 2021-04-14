using Newtonsoft.Json;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace SUMU_Messenger.WebApi.Controllers
{
    public class NotificationController : ApiController
    {
        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();
        UserDTO _User = (HttpContext.Current.User as ClaimsPrincipal).ResolveIdentity();

        [Authorize]
        [HttpGet]
        [Route("api/notification")]
        public async Task<IHttpActionResult> Get()
        {
            var deviceSerial = _SessionInfo.DeviceSerial;
            if (string.IsNullOrEmpty(deviceSerial))
            {
                DataClassesManager.ControllerLog("error", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}:{1}", _User.Username, "SerialHeaderRequired"));
                return BadRequest("SerialHeaderRequired");
            }
            //var activeSession = context.UserSession.Where(x => x.UserId == user.UserId).OrderByDescending(x => x.LoggedAt).Take(1).SingleOrDefault();
            //if (activeSession.DeviceSerial != deviceSerial)
            //{
            //    var ac = activeSession.DeviceSerial;
            //    DataClassesManager.ControllerLog("error", id, this.Request.RequestUri.PathAndQuery, string.Format("{0}:{1}-current:{2}-active:{3}", user.Username, "Conflict", activeSession.DeviceSerial, deviceSerial));
            //    return Conflict();
            //}
            var errorMessage = "";
            var result = DataClassesManager.GetPendingChat(_User.UserId.Value, out errorMessage);
            if (!string.IsNullOrEmpty(errorMessage))
            {
                DataClassesManager.ControllerLog("error", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}:{1}", _User.Username, errorMessage));
                return BadRequest(errorMessage);
            }
            var chatGroupedBySender = result.GroupBy(x => new { x.Group, x.Sender }, x => new { Id = x.Id, Type = x.Type, Content = x.Content, IssuedAt = x.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT), ExpiresAt = x.ExpiresAt, SizeInBytes = x.SizeInBytes, Duration = x.Duration, IsScrambled = x.IsScrambled })
                .Select(grp => new {
                    sender = grp.Key.Sender,
                    group = grp.Key.Group,
                    chat = grp.ToList().OrderBy(x => x.IssuedAt)
                }).ToList();

            DataClassesManager.ControllerLog("info", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}:count={1}", _User.Username, result.Count));

            return Ok(chatGroupedBySender);
        }


    }
}
