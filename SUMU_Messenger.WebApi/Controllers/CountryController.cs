using Newtonsoft.Json;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace SUMU_Messenger.WebApi.Controllers
{
    public class CountryController : ApiController
    {
        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();

        [AllowAnonymous]
        [HttpGet]
        [Route("api/country/mobile")]
        public async Task<IHttpActionResult> ValidateMobile(string id, string mobile)
        {
            DataClassesManager.ControllerLog("info", "", this.Request.RequestUri.PathAndQuery,string.Empty);
            var error = string.Empty;

            var regExp = DataClassesManager.GetRegExpByCountry(id);
            var result = IdentityUtils.ExactMatch(mobile, regExp);
            if(result)
                return Ok();
            return BadRequest();
        }


    }
}
