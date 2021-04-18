using Microsoft.AspNet.SignalR;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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
        internal static void Notify( UserDTO sender, List<RecipientDTO> recipients, NotificationDTO notification)
        {
            Parallel.ForEach(recipients, recipient => Notify(sender, recipient, notification));
        }
        internal static void Notify(UserDTO sender, RecipientDTO recipient, NotificationDTO notification, bool requirePush=true, string pushPreview="")
        {
            var hubContext = GlobalHost.ConnectionManager.GetHubContext<ChatHub>();
            var userConnection = ChatHub._connections.GetConnection(recipient.Id);
            if (!userConnection.PushMode)
            {
                switch (notification.Type)
                {
                    case (int)NotificationTypeEnum.Photo:
                    case (int)NotificationTypeEnum.Audio:
                    case (int)NotificationTypeEnum.Video:
                    case (int)NotificationTypeEnum.VoiceNote:
                        if (!string.IsNullOrEmpty(notification.Group))
                        {
                            hubContext.Clients.Client(userConnection.ConnectionId).GroupMediaReceived(notification.Group, notification.Type, notification.Id, notification.Content, sender.Id, notification.SizeInBytes, notification.Duration, notification.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT), notification.IsScrambled, notification.ExpiresAt);
                        }
                        else 
                        {
                            if (!string.IsNullOrEmpty(notification.ExpiresAt))
                                hubContext.Clients.Client(userConnection.ConnectionId).TemporaryMediaReceived(notification.Type, notification.Id, notification.Content, sender.Id, notification.SizeInBytes, notification.ExpiresAt, notification.Duration, notification.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT), notification.IsScrambled);
                            else
                                hubContext.Clients.Client(userConnection.ConnectionId).MediaReceived(notification.Type, notification.Id, notification.Content, sender.Id, notification.SizeInBytes, notification.Duration, notification.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT), notification.IsScrambled);
                        }

                        break;

                    default:
                        if (!string.IsNullOrEmpty(notification.Group))
                        {
                            hubContext.Clients.Client(userConnection.ConnectionId).GroupMessageReceived(notification.Group, notification.Type, notification.Id, notification.Content, sender.Id, notification.ExpiresAt, notification.IsScrambled, notification.IssuedAt);
                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(notification.ExpiresAt))
                                hubContext.Clients.Client(userConnection.ConnectionId).TemporaryMessageReceived(notification.Type, notification.Id, notification.Content, sender.Id, notification.ExpiresAt, notification.IsScrambled, notification.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT));
                            else
                                hubContext.Clients.Client(userConnection.ConnectionId).MessageReceived(notification.Type, notification.Id, notification.Content, sender.Id, notification.IsScrambled, notification.IssuedAt.ToString(ChatUtils.DATE_TIME_FORMAT));

                        }
                        break;
                }
            }
            else
            {
                if (requirePush)
                    Task.Factory.StartNew(() => PushManager.Send(pushPreview, recipient.UserId, recipient.Id, sender.Name, sender.Id, notification.Group));
            }
        }

    }
}