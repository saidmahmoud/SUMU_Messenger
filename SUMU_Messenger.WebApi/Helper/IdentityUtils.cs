using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Xml.Linq;
using static SUMU_Messenger.Models.Base;

namespace SUMU_Messenger.WebApi
{
    public class IdentityUtils
    {
        internal static XElement GetIdentitiesXML(string mobile, string email)
        {
            var identities = new List<IdentityDTO>();
            if (!string.IsNullOrEmpty(mobile)) identities.Add(new IdentityDTO { TypeId = (int)Base.IdentityEnum.Mobile, Value = mobile });
            if (!string.IsNullOrEmpty(email)) identities.Add(new IdentityDTO { TypeId = (int)Base.IdentityEnum.Email, Value = email.ToLower() });
            if (identities.Count == 0)
                return null;
            return new XElement("Identities", identities.Select(i => new XElement("Identity", new XElement[] { new XElement("TypeId", i.TypeId), new XElement("Value", i.Value) })));

        }
        internal static bool ExactMatch(string input, string match)
        {
            if (input.StartsWith("0"))
                input = input.Substring(1, input.Length - 1);
            var result = Regex.Match(input, string.Format(@"^{0}$", match));
            return result.Success && result.Value == input;
        }
        internal static Task ValidateIdentity(IdentityValidation validation, string transactionType = "Validation")
        {
            switch (validation.TypeId)
            {
                case (int)IdentityEnum.Mobile:
                    return SendSMS(validation.Identity, validation.Template, validation.Token);
                case (int)IdentityEnum.Email:
                    return SendEmail(validation.Identity, transactionType, validation.Template);

                default:
                    break;
            }
            return null;
        }

        private static Task SendEmail(string identity, string transactionType, string template)
        {
            throw new NotImplementedException();
        }

        private static Task SendSMS(string identity, string template, string token)
        {
            return Task.Factory.StartNew(() =>
            {
                if (template.Contains("000000"))
                    return;
            });
            throw new NotImplementedException();
        }
    }
}