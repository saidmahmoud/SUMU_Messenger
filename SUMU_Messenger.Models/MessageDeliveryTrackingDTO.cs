using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Spark.MessengerModels
{
    public class MessageDeliveryTrackingDTO
    {
        public string Id { get; set; }
        public DateTimeOffset DeliveredAt { get; set; }
        public DateTimeOffset? ReadAt { get; set; }
    }
}