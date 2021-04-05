using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SUMU_Messenger.Models
{
    class InternalModels
    { }
    public struct IdentityValidation
    {
        public int TypeId { get; set; }
        public string Identity { get; set; }
        public string Token { get; set; }
        public string Validation { get; set; }
        public bool Immediate { get; set; }
        public string Template { get; set; }

    }
    public struct GenericNotificationFeedback
    {
        public string Id { get; set; }
        //public GroupDTO Group { get; set; }
        //public List<RecipientDTO> Recipients { get; set; }
        public int? TypeId { get; set; }
    }
    public class User
    {
        public string Id { get; set; }
        public string Username { get; set; }
        public string Name { get; set; }
        public string CountryId { get; set; }
        public ICollection<IdentityDTO> Identity { get; set; }
        public DateTimeOffset? RegisteredAt { get; set; }
        public long UserId { get; set; }
        public ConnectionInfo ConnectionInfo { get; set; }
    }
}
