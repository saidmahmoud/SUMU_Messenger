using Microsoft.Owin.Security.OAuth;
using Newtonsoft.Json;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;

namespace SUMU_Messenger.WebApi.Helper
{
    public class AuthorizationProvider : OAuthAuthorizationServerProvider
    {
        public override async Task ValidateClientAuthentication(OAuthValidateClientAuthenticationContext context)
        {
            context.Validated();
        }

        public override async Task GrantResourceOwnerCredentials(OAuthGrantResourceOwnerCredentialsContext context)
        {
            string id;
            long? userId;
            var error = string.Empty;
            context.OwinContext.Response.Headers.Add("Access-Control-Allow-Origin", new[] { "*" });  //tells browsers whether to expose the response to frontend JavaScript code
            var username = context.UserName;
            //EnforceEncodingInteroperability(ref username);

            //byte[]  userPassword = Convert.FromBase64String(context.Password);
            using (AuthorizationRepository _repo = new AuthorizationRepository())
            {
                var userAuthInfo = _repo.ValidateSession(username);
                id = userAuthInfo.Id;
                userId = userAuthInfo.UserId;
                if (userId < 0)
                {
                    error = "Invalid username";
                    goto ErrorHandling;
                }

                var incoming = AuthorizationUtils.Hash(context.Password, userAuthInfo.Salt);
                if (!(AuthorizationUtils.SlowEquals(incoming, userAuthInfo.Password)))
                {
                    error = "Invalid username and or password";
                    goto ErrorHandling;
                }
            }

            var identity = new ClaimsIdentity(context.Options.AuthenticationType);
            identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, string.Format("{0}:{1}", id, username)));
            identity.AddClaim(new Claim(ClaimTypes.Role, "user"));

            context.Validated(identity);
            LogManager.WriteLog(string.Format("{0}/{1}", username, context.Password), JsonConvert.SerializeObject(context.OwinContext.Request.Headers.Values), null, null, "OK", string.Format("{0}:{1}", id, context.UserName)).Forget();
            return;

        ErrorHandling:
            context.SetError("invalid_grant", error);
            LogManager.WriteLog(string.Format("{0}/{1}", username, context.Password), JsonConvert.SerializeObject(context.OwinContext.Request.Headers.Values), null, null, "BadRequest", error).Forget();
            return;
        }


    }
}