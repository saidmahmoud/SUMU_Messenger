using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static SUMU_Messenger.Models.Base;

namespace SUMU_Messenger.WebApi.Helper
{
    public class SynchronizeUtils
    {
        private const int SOURCE_MAX_LENGTH = 50;
        private const int SQL_INST_LIMIT = 1000;
        internal const char DEVICE_CONTACTS_FIELD_SEPERATOR = (char)30;
        internal const char DEVICE_CONTACTS_RECORD_SEPERATOR = (char)31;

        private const int IDENTITY_MAX_LENGTH = 100;
        private const string IDENTITY_CONTACTS_TABLE = "UserContacts";
        private const string IDENTITY_DEVICE_CONTACTS_COL = "localId, identityTypeId, originalIdentity, source";
        private const string IDENTITY_REMAINING_CONTACTS_COL = "userId, deleted, [identity]";
        private static string IdentityInsertInstructionHeader = string.Format("insert into {0}.{1}({2}, {3}) values ", "dbo", IDENTITY_CONTACTS_TABLE, IDENTITY_DEVICE_CONTACTS_COL, IDENTITY_REMAINING_CONTACTS_COL);

        private const int INFO_MAX_LENGTH = 255;
        private const string INFO_CONTACTS_TABLE = "UserContactInfos";
        private const string INFO_DEVICE_CONTACTS_COL = "localId, infoTypeId, info, source";
        private const string INFO_REMAINING_CONTACTS_COL = "userId";
        private static string InfoInsertInstructionHeader = string.Format("insert into {0}.{1}({2}, {3}) values ", "dbo", INFO_CONTACTS_TABLE, INFO_DEVICE_CONTACTS_COL, INFO_REMAINING_CONTACTS_COL);

        private static string IdentityRemoveInstructionHeader = string.Format("delete from {0}.{1} where userId=#userId# And (", "dbo", IDENTITY_CONTACTS_TABLE);

        internal static string GenerateSynchronizeIdentityTSQL(long userId, string countryCode, string rawData, out string error)
        {
            error = string.Empty;
            var builder = new System.Text.StringBuilder();
            try
            {
                var data = rawData.Split(new char[] { DEVICE_CONTACTS_RECORD_SEPERATOR }, StringSplitOptions.RemoveEmptyEntries);

                builder.Append(IdentityInsertInstructionHeader);
                var records = 0;
                foreach (var c in data)
                {
                    var elements = c.Split(DEVICE_CONTACTS_FIELD_SEPERATOR);
                    var value = elements[2];
                    if (string.IsNullOrWhiteSpace(value))
                        continue;
                    var type = int.Parse(elements[1]);
                    switch (type)
                    {
                        case (int)IdentityEnum.Mobile:
                            value = value.InternationalFormat(countryCode);
                            break;
                        case (int)IdentityEnum.Email:
                            break;
                        default:
                            throw new Exception("InvalidIdentityType");
                    }
                    builder.Append(string.Format("({0},{1},{2},{3},{4},{5},{6})",
                        elements[0],
                        type,
                        elements[2].SQLize(IDENTITY_MAX_LENGTH),
                        elements[3].SQLize(SOURCE_MAX_LENGTH),
                        userId,
                        0,
                        value.SQLize(IDENTITY_MAX_LENGTH)
                        ));

                    if (++records == SQL_INST_LIMIT)
                    {
                        builder.Append(";" + Environment.NewLine);
                        builder.Append(IdentityInsertInstructionHeader);
                        records = 0;
                    }
                    else
                        builder.Append(",");
                }
                if (records == 0)
                    builder.Remove(builder.Length - IdentityInsertInstructionHeader.Length, IdentityInsertInstructionHeader.Length);
                else if (records < SQL_INST_LIMIT)
                    builder.Remove(builder.Length - 1, 1);
            }
            catch (Exception ex)
            {
                error = "InvalidFormat";
                builder.Clear();
            }
            return builder.ToString();
        }
        internal static string GenerateSynchronizeInfoTSQL(long userId, string rawData, out string error)
        {
            error = string.Empty;
            var builder = new System.Text.StringBuilder();
            try
            {
                var data = rawData.Split(new char[] { DEVICE_CONTACTS_RECORD_SEPERATOR }, StringSplitOptions.RemoveEmptyEntries);

                builder.Append(InfoInsertInstructionHeader);
                var records = 0;
                foreach (var c in data)
                {
                    var elements = c.Split(DEVICE_CONTACTS_FIELD_SEPERATOR);
                    var value = elements[2];
                    if (string.IsNullOrWhiteSpace(value))
                        continue;

                    builder.Append(string.Format("({0},{1},{2},{3},{4})",
                        elements[0],
                        elements[1],
                        elements[2].SQLize(INFO_MAX_LENGTH),
                        elements[3].SQLize(SOURCE_MAX_LENGTH),
                        userId
                        ));

                    if (++records == SQL_INST_LIMIT)
                    {
                        builder.Append(";" + Environment.NewLine);
                        builder.Append(InfoInsertInstructionHeader);
                        records = 0;
                    }
                    else
                        builder.Append(",");
                }
                if (records == 0)
                    builder.Remove(builder.Length - InfoInsertInstructionHeader.Length, InfoInsertInstructionHeader.Length);
                else if (records < SQL_INST_LIMIT)
                    builder.Remove(builder.Length - 1, 1);
            }
            catch (Exception ex)
            {
                error = "InvalidFormat";
                builder.Clear();
            }
            return builder.ToString();
        }
        internal static string GenerateDeleteIdentityTSQL(long userId, string rawData, out string error)
        {
            error = string.Empty;
            var builder = new System.Text.StringBuilder();
            try
            {
                var data = rawData.Split(new char[] { DEVICE_CONTACTS_RECORD_SEPERATOR }, StringSplitOptions.RemoveEmptyEntries);

                builder.Append(IdentityRemoveInstructionHeader.Replace("#userId#", userId.ToString()));
                foreach (var c in data)
                {
                    var elements = c.Split(DEVICE_CONTACTS_FIELD_SEPERATOR);

                    builder.Append(string.Format(" (localId={0} and identityTypeId={1} and originalIdentity={2}) or",
                        elements[0],
                        elements[1],
                        elements[2].SQLize(IDENTITY_MAX_LENGTH)));

                }
                builder.Remove(builder.Length - 2, 2);
                builder.Append(")");
            }
            catch (Exception ex)
            {
                error = "InvalidFormat";
                builder.Clear();
            }
            return builder.ToString();
        }

    }
}