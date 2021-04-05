using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Spark.MessengerModels
{
    public class NewGroupDTO
    {
        [Required, MinLength(1,ErrorMessage="Empty subjects are not allowed"), MaxLength(25,ErrorMessage="Subject length exceeded 25 characters")]
        public string Subject { get; set; }
        [EnsureRangeElementsAttribute(1, 254, ErrorMessage = "Members count should be between one and 254")]
        public List<NewGroupMemberDTO> Members { get; set; }
    }
    public class NewGroupMemberDTO
    {
        public Guid Id { get; set; }
    }
    public class EditGroupDTO
    {
        [Required, MinLength(1, ErrorMessage = "Empty subjects are not allowed"), MaxLength(25, ErrorMessage = "Subject length exceeded 25 characters")]
        public string Subject { get; set; }
    }
    public class GroupDTO
    {
        public string Id { get; set; }
        public string Subject { get; set; }
        public UserDTO CreatedBy { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public MembershipDTO Membership { get; set; }
        public List<MemberDTO> Members { get; set; }
    }
    public class MembershipDTO
    {
        public bool IsAdmin { get; set; }
        public bool? Pending { get; set; }
        public UserDTO InvitedBy { get; set; }
        public DateTimeOffset? InvitedAt { get; set; }
        public DateTimeOffset? JoinedAt { get; set; }

    }
    public class MemberDTO
    {
        public UserDTO ContactInfo { get; set; }
        public MembershipDTO Membership { get; set; }
    }
}