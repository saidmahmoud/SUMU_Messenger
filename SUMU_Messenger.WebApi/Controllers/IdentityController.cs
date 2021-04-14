using Newtonsoft.Json;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using static SUMU_Messenger.Models.Base;

namespace SUMU_Messenger.WebApi.Controllers
{
    public class IdentityController : ApiController
    {
        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();
        [AllowAnonymous]
        [HttpGet]
        public async Task<IHttpActionResult> CheckAvailability(int type, string value)
        {
            value = value.ToLower();
            bool available = DataClassesManager.CheckIdentityAvailability(type, value);

            DataClassesManager.ControllerLog("info", value, this.Request.RequestUri.PathAndQuery, string.Format("{0}:{1}:available={2}", type, value, available));

            return Ok(new { Available = available });
        }
        [AllowAnonymous]
        [HttpGet]
        public async Task<IHttpActionResult> Validate(string token, string code)
        {
            DataClassesManager.ControllerLog("info", token, this.Request.RequestUri.PathAndQuery,string.Empty);
            var error = string.Empty;
            long? userId;
            string user_Id;
            var content = string.Empty;
            var updates = DataClassesManager.Validate(token, code, out userId, out user_Id, out content, out error);

            if (!string.IsNullOrEmpty(error))
            {
                DataClassesManager.ControllerLog("error", token, this.Request.RequestUri.PathAndQuery,error);
                return BadRequest(error);
            }

            //Broadcast user joining
            //foreach (var update in updates)
            //{
            //    if (update.Recipients != null && update.Recipients.Count > 0)
            //        Task.Factory.StartNew(() => ChatUtils.BroadcastUpdate((ChatUtils.NotificationTypeEnum)update.TypeId, update.Id, user_Id, update.Recipients.Select(x => x.Id).ToList(), ""));
            //}

            return Ok();
        }


    }
}
