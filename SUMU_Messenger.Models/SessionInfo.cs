using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SUMU_Messenger.Models
{
    public struct AuthSessionInfo
    {
        public string Id { get; set; }
        public long UserId { get; set; }
        public byte[] Password { get; set; }
        public byte[] Salt { get; set; }
    }
    public struct SessionInfo
    {
        public int PlaformId { get; set; }
        public int VersionId { get; set; }
        public string DeviceSerial { get; set; }
        public string Details { get; set; }
    }
    public struct ConnectionInfo
    {
        public bool PushMode { get; set; }
        public string ConnectionId { get; set; }
        public int PlaformId { get; set; }
        public int VersionId { get; set; }
        public long UserId { get; set; }
        public string Name { get; set; }

    }
}