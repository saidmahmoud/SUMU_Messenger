using Microsoft.AspNet.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.WebApi
{
    public class ChatHub : Hub
    {
        public void Broadcast(string message)
        {
            Clients.All.Broadcast(message);
        }

    }
}