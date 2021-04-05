using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public class RegistrationDTO
    {
        [Required, RegularExpression("^(?=.{3,15}$)([A-Za-z0-9][._]?)*$")]
        public string Username { get; set; }

        [Required, RegularExpression("^(?=.{7,20}$).*$")]
        public string Password { get; set; }

        [Required]
        public string CountryId { get; set; }

        [RegularExpression("^[1-9][0-9]*$")]
        public string Mobile { get; set; }

        public string Email { get; set; }
    }
}