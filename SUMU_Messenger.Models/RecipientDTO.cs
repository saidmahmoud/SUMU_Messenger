using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class RecipientDTO
    {
        public string Id { get; set; }
        public long UserId { get; set; }
        public bool? IsGroup { get; set; }
    }
}