using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class UserDTO
    {
        public string Id { get; set; }
        public string Username { get; set; }
        public string Name { get; set; }
        public string CountryId { get; set; }        
        public ICollection<IdentityDTO> Identity { get; set; }
        public DateTimeOffset? RegisteredAt {get; set;}

    }
}