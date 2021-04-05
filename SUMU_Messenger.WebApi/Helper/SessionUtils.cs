using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Xml.Linq;
using static SUMU_Messenger.Models.Base;

namespace SUMU_Messenger.WebApi
{
    public static class SessionUtils
    {
        private static T ParseHeader<T>(this HttpContext httpContext, string key, T defaultValue)
        {
            try
            {
                var keyValue = (T)Convert.ChangeType(httpContext.Request.Headers[key], typeof(T));
                if (keyValue == null)
                    return defaultValue;

                return keyValue;
            }
            catch
            {
                return defaultValue;
            }
        }
        public static string UserAgentInfo(this System.Net.Http.HttpRequestMessage request)
        {
            var headerInfo = string.Format("{0}:{1}{2}", "UserAgent", request.Headers.UserAgent, Environment.NewLine);
            IEnumerable<string> values;
            if (request.Headers.TryGetValues("Origin", out values))
            {
                foreach (var value in values)
                    headerInfo = headerInfo + string.Format("{0}:{1}{2}", "Origin", value, Environment.NewLine);
            }
            return headerInfo;
        }
        public static SessionInfo GetSessionInfo(this HttpContext context)
        {
            var session =
             new SessionInfo
             {
                 DeviceSerial = context.ParseHeader<string>("dSerial", null),
                 PlaformId = context.ParseHeader<int>("platform", -1),
                 VersionId = context.ParseHeader<int>("appV", -1)
             };
            return session;
        }
    }
}