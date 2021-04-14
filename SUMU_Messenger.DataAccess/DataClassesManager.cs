
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using static SUMU_Messenger.Models.Base;

namespace SUMU_Messenger.DataAccess
{
    public class DataClassesManager
    {
        private static System.Data.SqlClient.SqlConnection _ConnectionString = null;
        private static System.Data.SqlClient.SqlConnection ConnectionString
        {
            get
            {
                _ConnectionString = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.AppSettings["ConnectionString"]);
                return _ConnectionString;
            }
        }

        public static string GetRegExpByCountry(string id)
        {
            var regExp = string.Empty;
            using (var dc = new DataClassesDataContext(ConnectionString))
            {
                regExp = (from x in dc.Countries
                          where x.Id == id
                          select x.PhoneRegExp).SingleOrDefault();
                return regExp;
            }
        }
        public static bool CheckIdentityAvailability(int type, string value)
        {
            var available = false;
            using (var dc = new DataClassesDataContext(ConnectionString))
            {
                switch (type)
                {
                    case (int)IdentityEnum.Username:
                        available = dc.Users.Where(x => x.Username == value).SingleOrDefault() == null;
                        break;
                    case (int)IdentityEnum.Mobile:
                    case (int)IdentityEnum.Email:
                        available = (dc.UserIdentities.Where(x => x.Identity == value).SingleOrDefault() == null);
                        break;
                    default:
                        available = false;
                        break;
                }
                return available;
            }

        }
        public static List<IdentityValidation> Register(string username, byte[] password, byte[] salt, string countryId, XElement identitiesXml, out long? preUserId, out string errorMessage)
        {
            errorMessage = string.Empty;
            var redirect = string.Empty;

            preUserId = 0;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    var result = (from x in dc.DoRegistration(username, password, salt, countryId, identitiesXml, ref preUserId, ref errorMessage, ref redirect)
                                  select new IdentityValidation { TypeId = x.TypeId.Value, Identity = x.Identity, Token = x.Token, Validation = x.Validation, Immediate = x.Immediate.Value, Template = x.Template }).ToList();

                    return result;
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
            }
            return null;
        }
        public static List<GenericNotificationFeedback> Validate(string token, string code, out long? userId, out string user_id, out string redirect, out string errorMessage)
        {
            errorMessage = string.Empty;
            redirect = string.Empty;
            userId = 0;
            user_id = string.Empty;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    return (from x in dc.DoValidation(token, code, ref userId, ref user_id, ref errorMessage, ref redirect)
                            select new GenericNotificationFeedback
                            {
                                Id = x.Id,
                                TypeId = x.TypeId,
                                //Recipients = string.IsNullOrEmpty(x.Recipients) ? null : (from y in x.Recipients.Split(',').ToList() select new RecipientDTO { Id = y }).ToList()
                            }).ToList();
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return null;
            }
        }
        public static List<IdentityValidation> ValidationRequest(long refId, ICollection<IdentityDTO> identities, out string errorMessage /*, out ErrorManager.Error Error*/)
        {
            var result = new List<IdentityValidation>();
            errorMessage = string.Empty;
            var redirect = string.Empty;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {

                    foreach (var identity in identities)
                    {
                        var r = (from x in dc.DoValidationRequest(identity.TypeId, refId, identity.Value.ToLower(), ref errorMessage, ref redirect)
                                 select new IdentityValidation { TypeId = x.TypeId.Value, Identity = x.Identity, Token = x.Token, Validation = x.Validation, Immediate = x.Immediate.Value, Template = x.Template }).SingleOrDefault();

                        if (!string.IsNullOrEmpty(errorMessage))
                        {
                            return null;
                        }
                        result.Add(r);
                    }

                    return result;

                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
            }
            return null;
        }
        public static void preAuthorizationTokenGeneration(string username, out string id, out long? internalId, out byte[] password, out byte[] salt)
        {
            id = string.Empty;
            internalId = -1;
            System.Data.Linq.Binary _password = null;
            System.Data.Linq.Binary _salt = null;
            password = new byte[] { };
            salt = new byte[] { };
            //if(username=="saharmerheb")
            //{
            //    password = new byte[64] { 137, 193, 82, 93, 47, 180, 86, 24, 157, 189, 86, 207, 197, 109, 122, 4, 199, 217, 164, 97, 68, 43, 24, 85, 252, 179, 79, 19, 9, 219, 147, 214, 38, 133, 76, 168, 157, 213, 91, 210, 146, 133, 58, 248, 157, 244, 171, 187, 162, 114, 178, 88, 7, 37, 76, 85, 75, 243, 129, 11, 219, 123, 245, 60 };
            //    salt = new byte[256] { 48, 12, 100, 9, 136, 224, 44, 9, 244, 252, 44, 63, 183, 66, 249, 110, 147, 65, 153, 232, 138, 0, 222, 164, 108, 57, 226, 100, 56, 236, 61, 12, 231, 178, 8, 56, 115, 187, 16, 255, 1, 150, 91, 206, 238, 173, 180, 120, 114, 2, 121, 196, 48, 196, 227, 93, 210, 232, 148, 54, 241, 135, 172, 136, 236, 50, 87, 101, 150, 19, 226, 60, 198, 9, 98, 106, 29, 137, 28, 202, 22, 57, 156, 33, 122, 222, 241, 46, 51, 174, 73, 215, 187, 0, 246, 107, 197, 37, 247, 17, 214, 224, 167, 172, 103, 205, 125, 57, 87, 245, 201, 102, 171, 245, 18, 121, 211, 126, 207, 245, 231, 96, 169, 156, 246, 112, 191, 87, 67, 185, 211, 139, 175, 116, 26, 40, 192, 62, 152, 92, 64, 110, 97, 140, 49, 86, 251, 220, 92, 191, 217, 1, 58, 155, 75, 174, 123, 182, 198, 29, 157, 190, 131, 199, 116, 187, 211, 72, 60, 136, 0, 58, 192, 26, 119, 223, 108, 202, 51, 208, 139, 135, 17, 95, 193, 18, 148, 130, 156, 166, 55, 109, 61, 178, 25, 219, 1, 194, 163, 198, 33, 179, 77, 153, 127, 7, 20, 122, 103, 102, 60, 165, 56, 186, 6, 202, 243, 240, 225, 206, 174, 205, 6, 249, 84, 162, 149, 240, 123, 200, 67, 31, 181, 28, 164, 175, 51, 20, 42, 111, 22, 197, 125, 211, 67, 49, 64, 198, 159, 232, 200, 251, 58, 84, 2, 201 };
            //    id = "5D8108B2-EEC2-4759-999B-2790909535E8";
            //    internalId = 1;
            //    return;
            //}
            using (var dc = new DataClassesDataContext(ConnectionString))
            {
                dc.preAuthorizationTokenGeneration(username, ref id, ref internalId, ref _password, ref _salt);
                password = _password.ToArray();
                salt = _salt.ToArray();
            }

        }
        public static void SaveNotification(long senderId, string recipientPublicId, ref long? recipientInternalId, string localMessageId, int messageTypeId, string message, string expiresAt, long? fileSizeInBytes, int? duration, bool isScrambled, int delay, out bool? alreadyReceived, out string messageId, out DateTimeOffset? issuedAt, out bool? senderHasPendingNotifications)
        {
            alreadyReceived = false; messageId = string.Empty; issuedAt = DateTimeOffset.MinValue; senderHasPendingNotifications = false;
            try
            {
                long? _recipientInternalId = recipientInternalId;
                bool? _alreadyReceived = alreadyReceived;
                string _messageId = messageId;
                DateTimeOffset? _issuedAt = issuedAt;
                bool? _senderHasPendingNotifications = senderHasPendingNotifications;

                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    dc.SaveNotification(senderId, recipientPublicId, ref _recipientInternalId, localMessageId, messageTypeId, message, expiresAt, fileSizeInBytes, duration, isScrambled, delay, ref _alreadyReceived, ref _messageId, ref _issuedAt, ref _senderHasPendingNotifications);
                }

                recipientInternalId = _recipientInternalId;
                alreadyReceived = _alreadyReceived;
                messageId = _messageId;
                issuedAt = _issuedAt;
                senderHasPendingNotifications = _senderHasPendingNotifications;
            }
            catch (Exception ex)
            {
                issuedAt = DateTimeOffset.MinValue;
            }
        }
        public static List<NotificationDTO> GetPendingChat(long userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    return (from x in dc.GetPendingChat(userId)
                            select new NotificationDTO { Id = x.Id, Content = x.Content, Duration = x.Duration, ExpiresAt = x.ExpiresAt, Group = x.Group, IsScrambled = x.IsScrambled, IssuedAt = x.IssuedAt, Sender = x.Sender, SizeInBytes = x.SizeInBytes, Type = x.Type }
                            ).ToList();
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
            }
            return null;
        }
        public static List<Update> NotificationDelivered(long userId, string notificationId)
        {
            var updates = new List<Update>();
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    updates = (from x in dc.NotificationDelivered(userId, notificationId)
                                select new Update { Recipient_Id = x.User_Id, RecipientId = x.UserId.Value, Id = x.UpdateId, Content = x.Content }).ToList();
                }

            }
            catch (Exception ex)
            {
                return null;
            }
            return updates;
        }
        public static Update NotificationRead(long userId, string notificationId, bool markAllPrevious)
        {
            var update = new Update { };
            try
            {

                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    update = (from x in dc.NotificationRead(userId, notificationId, markAllPrevious)
                                select new Update { Recipient_Id = x.User_Id, RecipientId = x.UserId, Id = x.UpdateId, Content = x.Content }).SingleOrDefault();
                }

            }
            catch (Exception ex)
            {
            }
            return update;
        }
        public static List<Update> NotificationRecalled(long userId, string ids)
        {
            var updates = new List<Update>();
            try
            {

                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    var _notificationId = string.Empty;
                    updates = (from x in dc.NotificationRecalled(userId, ids)
                                select new Update { Recipient_Id = x.User_Id, RecipientId = x.UserId, Id = x.UpdateId, Content = ids }).ToList();
                }
            }
            catch (Exception ex)
            {
                return null;
            }
            return updates;
        }
        public static UserDTO GetUser(string id, out string error)
        {
            error = string.Empty;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    var data = (from x in dc.GetUserById(id)
                                group x by new { x.Id, x.Name, x.Username, x.CreatedAt, x.CountryId } into y
                                select new UserDTO
                                {
                                    Id = y.Key.Id,
                                    CountryId = y.Key.CountryId,
                                    Username = y.Key.Username,
                                    Name = y.Key.Name,
                                    RegisteredAt = y.Key.CreatedAt,
                                    Identity = (from z in y
                                                select new IdentityDTO
                                                {
                                                    TypeId = z.IdentityTypeId,
                                                    Value = z.Identity
                                                }).ToList()
                                }
                                ).SingleOrDefault();
                    return data;
                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
                return new UserDTO { };
            }
        }
        public static List<UserDTO> GetUsers(string userId, int offset, int limit, out string error)
        {
            error = string.Empty;
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    var data = (from x in dc.GetUsers(offset, limit)
                                group x by new { x.Id, x.Name, x.Username, x.CreatedAt, x.CountryId } into y
                                select new UserDTO
                                {
                                    Id = y.Key.Id,
                                    CountryId = y.Key.CountryId,
                                    Username = y.Key.Username,
                                    Name = y.Key.Name,
                                    RegisteredAt = y.Key.CreatedAt,
                                    Identity = (from z in y
                                                select new IdentityDTO
                                                {
                                                    TypeId = z.IdentityTypeId,
                                                    Value = z.Identity
                                                }).ToList()
                                }
                                ).ToList();
                    return data;
                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
                return new List<UserDTO> { };
            }
        }
        public static void ControllerLog(string level, string userId, string request, string message, string category = "")
        {
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    dc.InsertLog(userId, message, category, level, request);
                }
            }
            catch (Exception ex)
            {

            }
        }
        public static void InsertLog(string message, string category, string level, string request, string userId = "")
        {
            try
            {
                using (var dc = new DataClassesDataContext(ConnectionString))
                {
                    dc.InsertLog(userId, message, category, level, request);
                }
            }
            catch (Exception ex)
            {

            }
        }
    }
}
