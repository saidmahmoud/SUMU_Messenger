using SUMU_Messenger.DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace SUMU_Messenger.WebApi
{
    public static class LogManager
    {
        public static void Forget(this Task task)
        {
            //surpress warning for un awaited calls
            //used mainly for SaveLog calls
        }
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static void SaveLog(string level, string userId, string request, string message, string category = "", string header = "")
        {
            StringBuilder builder = new StringBuilder();
            builder.AppendLine("");
            builder.AppendLine(string.Format("[Category:]", category));
            builder.AppendLine(string.Format("[UserId:]", userId));
            builder.AppendLine(header.Replace("\r\n", ""));
            builder.AppendLine(request);
            builder.AppendLine(message);
            builder.AppendLine(new string('-', 200));

            if (level == "error")
            {
                log.Error(builder.ToString());
                DataClassesManager.ControllerLog(level, userId, request, message, category);
            }
            else
                log.Info(builder.ToString());
        }

        public static async Task WriteLog(string level, string userId, string request, string message, string category = "", string header = "")
        {
            await Task.Factory.StartNew(
                () =>
                SaveLog(level, userId, request, message, category, header)
                );
        }
    }
}