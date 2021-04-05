using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using SUMU_Messenger.Models;
namespace SUMU_Messenger.DataAccess
{
    public class Helper
    {
        public static XElement GetIdentitiesXML(string mobile, string email)
        {
            var identities = new List<IdentityDTO>();
            if (!string.IsNullOrEmpty(mobile))
                identities.Add(new IdentityDTO { TypeId = (int)Base.IdentityEnum.Mobile, Value = mobile });
            if (!string.IsNullOrEmpty(email))
                identities.Add(new IdentityDTO { TypeId = (int)Base.IdentityEnum.Email, Value = email.ToLower() });
            if (identities.Count == 0)
                return null;
            return new XElement("Identities", identities.Select(i => new XElement("Identity", new XElement[] { new XElement("TypeId", i.TypeId), new XElement("Value", i.Value) })));
        }
    }
}
