using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Spark.MessengerModels
{
    public class Invitation
    {
        public string RefId { get; set; }
        public int TypeId { get; set; } //IdentityEnum { Username = 0, Mobile = 1, Email = 2, };
        public string Title { get; set; }
        public string Content { get; set; }
        public bool IsUnicode { get; set; }
        public string  RecipientsSeperator { get; set; }
    }

}