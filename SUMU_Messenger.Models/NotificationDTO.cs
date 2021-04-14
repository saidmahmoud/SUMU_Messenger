using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class NotificationDTO
    {
        public string Id { get; set; }
        public int Type { get; set; }
        public string Content { get; set; }
        public long? SizeInBytes { get; set; }
        public string ExpiresAt { get; set; }
        public DateTimeOffset IssuedAt { get; set; }
        [Required]
        public string LocalId { get; set; }
        public int? Duration { get; set; }
        public bool IsScrambled { get; set; }
        public string Sender { get; set; }
        public string Group { get; set; }
    }

}