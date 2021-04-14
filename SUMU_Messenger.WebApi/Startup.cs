using Microsoft.AspNet.SignalR;
using Microsoft.Owin;
using Microsoft.Owin.Security.OAuth;
using Owin;
using SUMU_Messenger.WebApi.Helper;
using System;
using System.Threading.Tasks;

[assembly: OwinStartup(typeof(SUMU_Messenger.WebApi.Startup))]

namespace SUMU_Messenger.WebApi
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureOAuth(app);
            //app.MapSignalR();
            var hubConfig = new HubConfiguration();
            hubConfig.EnableDetailedErrors = true;
            GlobalHost.Configuration.ConnectionTimeout = TimeSpan.FromSeconds(60);
            GlobalHost.Configuration.DisconnectTimeout = TimeSpan.FromSeconds(180);
            GlobalHost.Configuration.KeepAlive = TimeSpan.FromSeconds(60);
            GlobalHost.HubPipeline.AddModule(new ErrorHandlingPipelineModule());
            GlobalHost.TraceManager.Switch.Level = System.Diagnostics.SourceLevels.All;
            app.MapSignalR(hubConfig);
        }
        public void ConfigureOAuth(IAppBuilder app)
        {
            OAuthAuthorizationServerOptions OAuthServerOptions = new OAuthAuthorizationServerOptions()
            {
                AllowInsecureHttp = true,
                TokenEndpointPath = new PathString("/token"),
                AccessTokenExpireTimeSpan = TimeSpan.FromSeconds(TokenExpiry_Seconds),
                Provider = new AuthorizationProvider()
            };

            // Token Generation
            app.UseOAuthAuthorizationServer(OAuthServerOptions);
            app.UseOAuthBearerAuthentication(new OAuthBearerAuthenticationOptions());

        }

        private static int tokenExpiry_Seconds;
        private static int TokenExpiry_Seconds
        {
            get
            {

                if (tokenExpiry_Seconds == 0)
                {
                    if (!int.TryParse(System.Configuration.ConfigurationManager.AppSettings["TokenExpiry_Seconds"], out tokenExpiry_Seconds))
                        tokenExpiry_Seconds = 86400;
                }
                return tokenExpiry_Seconds;
            }

        }
    }
}


