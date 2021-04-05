using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Spark.MessengerModels
{
    public class ForgotDTO
    {
        public string Token { get; set; }
        public string Password { get; set; }
    }
    public class ResetDTO
    {
        public string Username { get; set; }
        public string OldPassword { get; set; }
        public string NewPassword { get; set; }
    }
}