using SUMU_Messenger.DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.WebApi
{
    public class ChatUtils
    {
        public const string DATE_TIME_FORMAT = "yyyy-MM-ddTHH:mm:ss.fffZ";
        internal enum NotificationTypeEnum
        {
            Text = 1, Photo = 2, Video = 3, Audio = 4, Joined = 5, ProfilePicChanged = 6, Reset = 7, MessageDelivered = 8, MessageRead = 9, MessageRecalled = 10, VoiceNote = 11, Handshake = 12, PublicKeyChanged = 13, DisplayNameChanged = 14,
            GroupInvitation = 15, GroupSubjectChanged = 16, GroupIconChanged = 17, GroupInvitationCancelled = 18, GroupInvitationRejected = 19, GroupMemberJoined = 20, GroupMemberLeft = 21, GroupMemberRemoved = 22, GroupMemberSetAsAdmin = 23, IdentityChanged = 24, Left = 25,
        };
        internal struct MessageServerFeedback
        {
            public bool AlreadyReceived { get; set; }
            public string Id { get; set; }
            public DateTimeOffset IssuedAt { get; set; }
            public string FormattedIssuedAt { get; set; }
            public bool ReInitSessionRequired { get; set; }
        }
        internal static MessageServerFeedback SP_SaveNotification(long senderId, string recipientPublicId, ref long recipientInternalId, string localMessageId, int messageTypeId, string message, bool isScrambled, string expiresAt, int delay = 0, long? fileSizeInBytes = 0, int? duration = 0)
        {
            bool? alreadyReceived; string messageId; DateTimeOffset? issuedAt; bool? senderHasPendingNotifications; long? _recipientInternalId = recipientInternalId;
            DataClassesManager.SaveNotification(senderId, recipientPublicId, ref _recipientInternalId, localMessageId, messageTypeId, message, expiresAt, fileSizeInBytes, duration, isScrambled, delay, out alreadyReceived, out messageId, out issuedAt, out senderHasPendingNotifications);
            recipientInternalId = _recipientInternalId.Value;
            return new MessageServerFeedback { AlreadyReceived = alreadyReceived.Value, Id = messageId, IssuedAt = issuedAt.Value, FormattedIssuedAt = issuedAt.Value.ToString(DATE_TIME_FORMAT), ReInitSessionRequired = senderHasPendingNotifications.Value };
        }
    }
}