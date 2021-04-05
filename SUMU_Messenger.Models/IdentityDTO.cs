using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class IdentityDTO
    {
        public long LocalId { get; set; }
        public int TypeId { get; set; }
        public string Value { get; set; }
        public string Token { get; set; }
        public bool Pending { get; set; }
    }

}