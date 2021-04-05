using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace Spark.MessengerModels
{
    public class NotificationTransactionDTO
    {
        public NotificationDTO Notification { get; set; }
        [EnsureRangeElementsAttribute(1, 255, ErrorMessage = "Recipients count should be between one and 255")]
        public List<RecipientDTO> Recipients { get; set; }
        public int? Mode{ get; set; }
    }
}