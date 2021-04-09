﻿using Newtonsoft.Json;
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

namespace SUMU_Messenger.WebApi.Controllers
{
    public class IdentityController : ApiController
    {
        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();
        //UserDTO _User = (HttpContext.Current.User as ClaimsPrincipal).ResolveIdentity();

        [AllowAnonymous]
        [HttpGet]
        public async Task<IHttpActionResult> ValidateIdentity(string token, string code)
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
