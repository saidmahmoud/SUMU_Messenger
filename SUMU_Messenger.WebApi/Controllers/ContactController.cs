using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace SUMU_Messenger.WebApi.Controllers
{
    public class ContactController : ApiController
    {
        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();
        UserDTO _User = (HttpContext.Current.User as ClaimsPrincipal).ResolveIdentity();
        [Authorize]
        public async Task<IHttpActionResult> PostIdentity([FromBody] string contacts)
        {

            DataClassesManager.ControllerLog("info", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}#{1}:{2}", "", _User.Username, string.IsNullOrEmpty(contacts) ? "NULL" : (contacts.Length > 20 ? contacts.Substring(0, 20) + "..." : contacts)));

            DateTimeOffset? ack; string countryCode;

            DataClassesManager.GetUserSyncInfo(_User.UserId.Value, out countryCode, out ack);
            string error = string.Empty;
            var script = Helper.SynchronizeUtils.GenerateSynchronizeIdentityTSQL(_User.UserId.Value, countryCode, contacts, out error);

            if (!string.IsNullOrEmpty(error))
            {
                DataClassesManager.ControllerLog("error", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}#{1}:{2}", "", _User.Username, error));
                return BadRequest(error);
            }

            DataClassesManager.ExecuteSynchronizeScript(_User.UserId.Value, script, "Identity", ack, out error);
            if (string.IsNullOrEmpty(error))
                DataClassesManager.ControllerLog("info", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}#{1}:{2}:{3}", "", _User.Username, ack, "Done"));
            else
                DataClassesManager.ControllerLog("error", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}#{1}:{2}", "", _User.Username, error));


            DataClassesManager.ControllerLog("info", _User.Id, this.Request.RequestUri.PathAndQuery, string.Format("{0}#{1}:{2}", "", _User.Username, ack));
            return Ok(new { ack = ack });
        }

        [Authorize]
        public async Task<IHttpActionResult> GetFavorites(DateTimeOffset? ack = null)
        {
            var inProcess = false;

            List<UserDTO> favorites = DataClassesManager.GetFavorites(_User.UserId.Value, ref ack, out inProcess);
            return Ok(new { ack = ack, inProcess = inProcess, favorite = favorites });

        }
    }
}