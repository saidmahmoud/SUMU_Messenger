using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using SUMU_Messenger.DataAccess;
using SUMU_Messenger.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Web;

namespace SUMU_Messenger.WebApi
{
    public class ChatHub : Hub
    {
        public void Broadcast(string message)
        {
            Clients.All.Broadcast(message);
        }

        SessionInfo _SessionInfo = HttpContext.Current.GetSessionInfo();
        private readonly UserDTO _User = (HttpContext.Current.User as ClaimsPrincipal).ResolveIdentity();

        public readonly static ConnectionMapping<string> _connections = new ConnectionMapping<string>();
        public override Task OnConnected()
        {
            Models.User user;
            if (AuthorizedUser(out user, Context.ConnectionId))
            {
                _connections.Add(user.Id, user.ConnectionInfo);
                DataClassesManager.InsertLog(string.Empty, "SignalR", "OnConnected", Context.ConnectionId, user.Id);
            }
            return base.OnConnected();
        }
        public static void Remove(string id)
        {
            _connections.Remove(id);
            DataClassesManager.InsertLog(string.Empty, "SignalR", "#OnDisconnected", "", id);
        }
        public override Task OnDisconnected(bool stopCalled)
        {
            if (!stopCalled)
            {
                var id = _connections.GetUserIdByConnectionId(Context.ConnectionId);
                _connections.Remove(id);
                DataClassesManager.InsertLog(string.Empty, "SignalR", "OnDisconnected", Context.ConnectionId, id);
            }
            else
            {
                Models.User user;
                if (AuthorizedUser(out user))
                {
                    _connections.Remove(user.Id);
                    DataClassesManager.InsertLog(string.Empty, "SignalR", "OnDisconnected", Context.ConnectionId, string.Format("{0}-{1}", user.UserId, user.Username));
                }
            }
            return base.OnDisconnected(stopCalled);
        }
        public override Task OnReconnected()
        {
            Models.User user;
            if (AuthorizedUser(out user, Context.ConnectionId))
            {
                _connections.Add(user.Id, user.ConnectionInfo);
                DataClassesManager.InsertLog(string.Empty, "SignalR", "OnReconnected", Context.ConnectionId, user.Id);
            }

            return base.OnReconnected();
        }

        public void Typing(string senderId, string recipientId, bool typing)
        {
            var connectionId = _connections.GetConnectionId(recipientId);

            if (!string.IsNullOrEmpty(connectionId))
                Clients.Client(connectionId).TypingReceived(senderId, typing);
        }
        public string SendMessage(string localMessageId, string recipientId, int messageTypeId, string message, bool isScrambled)
        {
            return SendMessage(recipientId, localMessageId, messageTypeId, message, null, isScrambled);
        }
        public string SendTemporaryMessage(string localMessageId, string recipientId, int messageTypeId, string message, string expiresAt, bool isScrambled)
        {
            return SendMessage(recipientId, localMessageId, messageTypeId, message, expiresAt, isScrambled);
        }
        private string SendMessage(string recipientId, string localMessageId, int messageTypeId, string message, string expiresAt, bool isScrambled)
        {
            Models.User sender;

            var messageId = string.Empty;
            var issuedAt = string.Empty;
            var reInitSessionRequired = false;

            if (AuthorizedUser(out sender))
            {
                //if (!ChatHelper.FormatMessage(messageTypeId, ref message))
                //    return string.Empty;

                var recipientConnection = _connections.GetConnection(recipientId);

                long recipientInternalId = recipientConnection.PushMode ? -1 : recipientConnection.UserId;

                var feedback = ChatUtils.SP_SaveNotification(sender.UserId, recipientId, ref recipientInternalId, localMessageId, messageTypeId, message, isScrambled, expiresAt);
                DataClassesManager.InsertLog(string.Format("From {0}:{1}", sender.Username, message), "ChatHub", "SendMessage", string.Format("{0}-{1}", recipientConnection.PushMode, recipientConnection.ConnectionId), recipientId);
                messageId = feedback.Id;
                issuedAt = feedback.FormattedIssuedAt;
                reInitSessionRequired = feedback.ReInitSessionRequired;
                if (string.IsNullOrEmpty(messageId))
                    return string.Empty;

                if (feedback.AlreadyReceived)
                    goto AlreadyReceived;

                if (!recipientConnection.PushMode)
                {
                    if (!string.IsNullOrEmpty(expiresAt))//.HasValue
                        Clients.Client(recipientConnection.ConnectionId).TemporaryMessageReceived(messageTypeId, messageId, message, sender.Id, expiresAt, isScrambled, issuedAt);
                    else
                        Clients.Client(recipientConnection.ConnectionId).MessageReceived(messageTypeId, messageId, message, sender.Id, isScrambled, issuedAt);
                }
                else
                {
                    bool requirePush; string pushPreview;
                    //requirePush = Settings.PushNotificationTypes.TryGetValue(messageTypeId, out pushPreview);
                    //if (string.IsNullOrEmpty(pushPreview))
                    //    pushPreview = message;
                    //Task.Factory.StartNew(() => {
                    //    PushManager.Send(pushPreview, recipientInternalId, recipientId, sender.Name, sender.Id);
                    //});
                }
            AlreadyReceived:
                if (messageId == "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
                {
                    Clients.Client(sender.ConnectionInfo.ConnectionId).RemoveContact(Guid.NewGuid().ToString(), recipientId);
                    messageId = Guid.NewGuid().ToString();
                }
                var callBack = string.Empty;
                callBack = string.Format("{0}#{1}#{2}#{3}", localMessageId, messageId, issuedAt, reInitSessionRequired.ToString());
                return callBack;
            }
            throw new HubException("Reconnect required");
        }
        public void ConfirmDelivery(IList<string> receivedIds)
        {
            Models.User user;
            if (AuthorizedUser(out user))
            {
                DataClassesManager.InsertLog(string.Join(",", receivedIds), "SignalR", "ConfirmDelivery", Context.ConnectionId, string.Format("{0}-{1}", user.UserId, user.Username));

                var updates = DataClassesManager.NotificationDelivered(user.UserId, string.Join(",", receivedIds));
                foreach (var update in updates)
                {
                    var recipientConnectionId = _connections.GetConnectionId(update.Recipient_Id);
                    if (!string.IsNullOrEmpty(recipientConnectionId))
                        Clients.Client(recipientConnectionId).MyMessageDelivered(update.Id, update.Content);
                }
            }
        }
        public void ConfirmRead(string notificationId, bool applyOnPreviouslyReceived)
        {
            Models.User user;
            if (AuthorizedUser(out user))
            {
                DataClassesManager.InsertLog(string.Format("{0}-{1}", notificationId, applyOnPreviouslyReceived.ToString()), "SignalR", "ConfirmRead", Context.ConnectionId, string.Format("{0}-{1}", user.UserId, user.Username));

                string recipientId = string.Empty;
                var update = DataClassesManager.NotificationRead(user.UserId, notificationId, applyOnPreviouslyReceived);
                if (update != null)
                {
                    var recipientConnectionId = _connections.GetConnectionId(update.Recipient_Id);
                    if (!string.IsNullOrEmpty(recipientConnectionId))
                        Clients.Client(recipientConnectionId).MyMessageRead(update.Id, update.Content, applyOnPreviouslyReceived);
                }
            }
        }
        public void RecallNotification(IList<string> recalledIds)
        {
            Models.User user;
            if (AuthorizedUser(out user))
            {
                string _recalledIds = string.Join(",", recalledIds);
                var updates = DataClassesManager.NotificationRecalled(user.UserId, _recalledIds);
                foreach (var update in updates)
                {
                    var recipientConnectionId = _connections.GetConnectionId(update.Recipient_Id);
                    if (!string.IsNullOrEmpty(recipientConnectionId))
                        Clients.Client(recipientConnectionId).MessageRecalled(update.Id, update.Content);
                }
            }
        }
        private bool AuthorizedUser(out Models.User user, string connectionId = "")
        {
            user = null;

            if (_User.Id != null)
            {
                if (string.IsNullOrEmpty(connectionId))
                {
                    var conInfo = _connections.GetConnection(_User.Id);
                    if (conInfo.PushMode)
                        return false;
                    else
                    {
                        user = new Models.User { Id = _User.Id, Name = conInfo.Name, UserId = conInfo.UserId, ConnectionInfo = conInfo };
                        return true;
                    }
                }
                else
                {
                    user = new Models.User {
                        Id = _User.Id,
                        Username = _User.Username,
                        UserId = _User.UserId.Value,
                        ConnectionInfo = new ConnectionInfo
                        {
                            ConnectionId = connectionId,
                            UserId = _User.UserId.Value,
                            PushMode = false,
                            PlaformId = _SessionInfo.PlaformId,
                            VersionId = _SessionInfo.VersionId
                        }
                    };
                    return true;
                }
            }
            return false;
        }
    }

    public class ErrorHandlingPipelineModule : HubPipelineModule
    {
        public ErrorHandlingPipelineModule()
        {
        }
        protected override bool OnBeforeIncoming(IHubIncomingInvokerContext context)
        {
            //DataClassesManager.InsertLog("=> Invoking " + context.MethodDescriptor.Name + " on hub " + context.MethodDescriptor.Hub.Name, "SignalR", "OnBeforeIncoming", "");
            return base.OnBeforeIncoming(context);
        }
        protected override bool OnBeforeOutgoing(IHubOutgoingInvokerContext context)
        {
            string userId = context.Invocation.Args[0].ToString();
            //DataClassesManager.InsertLog("<= Invoking " + context.Invocation.Method + " on client hub " + context.Invocation.Hub, "SignalR", "OnBeforeOutgoing", "", userId);
            return base.OnBeforeOutgoing(context);
        }
        protected override void OnIncomingError(ExceptionContext exceptionContext, IHubIncomingInvokerContext invokerContext)
        {
            var connectionId = invokerContext.Hub.Context.ConnectionId;
            DataClassesManager.InsertLog("=> Exception " + exceptionContext.Error.Message, "SignalR", "OnIncomingError", connectionId);
            if (exceptionContext.Error.InnerException != null)
            {
                DataClassesManager.InsertLog("=> Inner Exception " + exceptionContext.Error.InnerException.Message, "SignalR", "OnIncomingError", connectionId);
            }
            base.OnIncomingError(exceptionContext, invokerContext);

        }
    }
    public class ConnectionMapping<T>
    {

        private readonly Dictionary<T, ConnectionInfo> _connections =
            new Dictionary<T, ConnectionInfo>();

        public int Count
        {
            get
            {
                return _connections.Count;
            }
        }

        public void Add(T key, ConnectionInfo connectionInfo)
        {
            lock (_connections)
            {
                var currentConnection = GetConnectionId(key);

                if (string.IsNullOrEmpty(currentConnection))
                    _connections.Add(key, connectionInfo);
                else
                    if (currentConnection != connectionInfo.ConnectionId)
                {
                    _connections[key] = connectionInfo;
                }
            }
        }
        public string GetUserIdByConnectionId(string connectionId)
        {
            var key = (from x in _connections where x.Value.ConnectionId == connectionId select x.Key).SingleOrDefault();
            return key.ToString();
        }

        public string GetConnectionId(T key)
        {
            ConnectionInfo connectionInfo;
            if (_connections.TryGetValue(key, out connectionInfo))
            {
                return connectionInfo.ConnectionId;
            }

            return string.Empty;
        }
        public ConnectionInfo GetConnection(T key)
        {
            ConnectionInfo connectionInfo;
            if (_connections.TryGetValue(key, out connectionInfo))
            {
                return connectionInfo;
            }
            return new ConnectionInfo { PushMode = true };
        }
        public void Remove(T key)
        {
            lock (_connections)
            {
                ConnectionInfo connectionInfo;
                if (!_connections.TryGetValue(key, out connectionInfo))
                {
                    return;
                }
                _connections.Remove(key);
            }
        }
    }
}
