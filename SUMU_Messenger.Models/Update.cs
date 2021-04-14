using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class Update
    {
        public string Id{ get; set; }
        public string Content { get; set; }
        public string Recipient_Id { get; set; }
        public long RecipientId { get; set; }
    }
}