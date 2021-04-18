using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.WebApi.Helper
{
    public static class Extension
    {
        internal static string Formatted(this string ErrorMessage, string redirect = "")
        {
            return JsonConvert.SerializeObject(new { Message = ErrorMessage, Redirect = redirect });
        }
        private static string GetNumbers(this string input)
        {
            return new string(input.Where(c => char.IsDigit(c)).Select(x => char.GetNumericValue(x).ToString()[0]).ToArray());
        }
        internal static string InternationalFormat(this string rawMobile, string countryCode)
        {
            rawMobile = rawMobile.Replace("( 0", "(").Replace("(0", "(");
            bool isInternational = rawMobile.StartsWith("+") || rawMobile.StartsWith("00");
            var cleanMobile = rawMobile.GetNumbers();
            if (isInternational)
            {
                if (cleanMobile.StartsWith("00"))
                    cleanMobile = cleanMobile.Remove(0, 2);
            }
            else
            {
                if (cleanMobile.StartsWith("0"))
                    cleanMobile = cleanMobile.Remove(0, 1);

                cleanMobile = string.Format("{0}{1}", countryCode, cleanMobile);
            }
            return cleanMobile;
        }
        internal static string SQLize(this string value, int maxLength = -1)
        {
            value = value.Replace("'", "''");
            if (maxLength > 0 && value.Length > maxLength)
                value = value.Substring(0, maxLength);
            return "N'" + value + "'";
        }
    }
}