USE [SUMU_Messengerdb]
GO
/****** Object:  UserDefinedFunction [dbo].[CheckIfRegisteredByPreUserId]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[CheckIfRegisteredByPreUserId](@preUserId bigint)
returns bit
as
begin
if(exists (Select 1 from [PreUser] p inner join [Users] u on u.UserId=p.UserId where p.Id= @PreUserId ))
	return 1
return 0

end

GO
/****** Object:  UserDefinedFunction [dbo].[CONST_ActiveMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_ActiveMembershipStatus]()
returns int
as
begin
	return 2
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_CancelledMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_CancelledMembershipStatus]()
returns int
as
begin
	return 4
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_GetValueByKey]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_GetValueByKey](@key nvarchar(50))
returns nvarchar(255)
as
begin
	declare @value nvarchar(255)
	select @value = value from SystemSettings where [key]=@key
	return isnull(@value,'')
end



GO
/****** Object:  UserDefinedFunction [dbo].[CONST_GroupMembersMaxCount]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_GroupMembersMaxCount]()
returns int
as
begin
	return 255
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_LeftMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_LeftMembershipStatus]()
returns int
as
begin
	return 5
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_PendingMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_PendingMembershipStatus]()
returns int
as
begin
	return 1
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_RejectedMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_RejectedMembershipStatus]()
returns int
as
begin
	return 3
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_RemovedMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_RemovedMembershipStatus]()
returns int
as
begin
	return 6
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_SystemUserId]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[CONST_SystemUserId]()
returns nvarchar(128)
as
begin
return 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
end




GO
/****** Object:  UserDefinedFunction [dbo].[CONST_SystemUserInternalId]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[CONST_SystemUserInternalId]()
returns bigint
as
begin
	return 0
end




GO
/****** Object:  UserDefinedFunction [dbo].[GenerateMobileValidationCode]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[GenerateMobileValidationCode](@DigitsCount smallint)
returns nvarchar(10)
as
begin
return '000000'

DECLARE @Random INT;
DECLARE @Upper INT;
DECLARE @Lower INT

SET @Lower = power(10,@DigitsCount - 1)
SET @Upper = power(10,@DigitsCount) - 1
SELECT @Random = ROUND(((@Upper - @Lower -1) * (select GetRand from vwRand) + @Lower), 0)
return cast(@Random as nvarchar(10))

end





GO
/****** Object:  UserDefinedFunction [dbo].[GetFollowers]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetFollowers] (@userId bigint, @identityTypeId int=null)
returns @Followers table (Id nvarchar(128), userId Bigint)
as
begin
	insert into @Followers(Id,userId)
	Select distinct u.Id, c.UserId from userContacts c join users u 
	on u.userId=c.userId
	where c.ContactUserId=@UserId and c.contactUserId is not null and c.userId<>@userId 
	and (@identityTypeId is null or (@identityTypeId is not null and c.IdentityTypeId = @identityTypeId))
	return
end




GO
/****** Object:  UserDefinedFunction [dbo].[GetIdentityTypeIdByName]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetIdentityTypeIdByName](@typeName nvarchar(20))
returns int
as
begin
DECLARE @Id INT;
Select @id=id from [IdentityType] where Name= @TypeName
if(@@rowcount=0)
	Set @id=-1
return @Id
end




GO
/****** Object:  UserDefinedFunction [dbo].[GetMembers]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetMembers] (@groupId bigint)
returns @Members table (Id nvarchar(128), userId Bigint)
as
begin
	insert into @Members(Id,userId)
	Select u.id, u.userid from GroupMembers m join users u on u.userid=m.memberid 
	where groupid=@groupid and GroupMembershipStatusId=dbo.const_ActiveMembershipStatus()

	return
end




GO
/****** Object:  UserDefinedFunction [dbo].[GetPendingNotificationsCount]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetPendingNotificationsCount](@recipientId bigint)
returns int
as
begin
declare @count int
select @count=count(*) from dbo.NotificationRecipients R
join dbo.Notifications N on N.Id = R.NotificationId
join dbo.NotificationTypes T on T.NotificationTypeId = N.NotificationTypeId
where R.RecipientId=@recipientId 
and R.NotificationStatusId = 1 -- pending
and T.IsChat = 1
return isnull(@count,0)
end



GO
/****** Object:  UserDefinedFunction [dbo].[GetPreUserIdByUserId]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create function [dbo].[GetPreUserIdByUserId](@id nvarchar(128))
returns bigint
as
begin
DECLARE @PreUserId bigint;
Select @PreUserId=p.Id from [PreUser] p inner join [Users] u on u.UserId=p.UserId where u.Id= @id
if(@@rowcount=0)
	Set @PreUserId=-1
return @PreUserId
end

GO
/****** Object:  UserDefinedFunction [dbo].[GetSynchronizeStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE funCTION [dbo].[GetSynchronizeStatus] (@UserId bigint)
returns bit
as
begin
declare @InProcess bit
select @InProcess=InProcess from UserSynchronizeLog  WITH(NOLOCK)  where userid=@UserId
return @inProcess
end





GO
/****** Object:  UserDefinedFunction [dbo].[GetUserDisplayName]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetUserDisplayName](@id nvarchar(128))
returns nvarchar(50)
as
begin
	declare @name nvarchar(50)
	Select @name=[Name] From Users where id=@id
	return @name
end




GO
/****** Object:  UserDefinedFunction [dbo].[GetUserIdentities]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[GetUserIdentities](@userId bigint)
returns @result table (TypeId int, Value nvarchar(100))
as
begin
	insert into @result
	select identityTypeId, [Identity] from UserIdentities where userid=@userId
	return
end



GO
/****** Object:  UserDefinedFunction [dbo].[Group_GetDetailsByUser]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[Group_GetDetailsByUser](@userId bigint, @groupId nvarchar(128)=null)
returns @result table(
Id nvarchar(128), 
GroupId bigint,
[Subject] nvarchar(25),
IsAdmin bit,
CreatedAt datetimeoffset,
UpdatedAT datetimeoffset,
Pending bit,
CreatedBy_Id nvarchar(128),
CreatedBy_UserId bigint,
CreatedBy_Name nvarchar(50),
CreatedBy_Username nvarchar(20),
InvitedBy_Id nvarchar(128),
InvitedBy_UserId bigint,
InvitedBy_Name nvarchar(50),
InvitedBy_Username nvarchar(20))
as
begin
Set @groupId=isnull(@groupId,'')
insert into @result(id,groupId, [subject], IsAdmin,CreatedAt, UpdatedAt,Pending,
CreatedBy_Id,CreatedBy_UserId,CreatedBy_Name,CreatedBy_Username,
InvitedBy_Id,InvitedBy_UserId, InvitedBy_Name, InvitedBy_Username)
select G.Id,G.GroupId, G.[Subject], M.IsAdmin, G.CreatedAt, M.UpdatedAt, case when M.GroupMembershipStatusId = dbo.const_PendingMembershipStatus() then 1 else null end as Pending,
crU.Id, cru.UserId, crU.Name, crU.Username, 
invU.Id, invU.UserId, invU.Name, invU.Username
from Groups G join GroupMembers M on G.GroupId=M.GroupId
join Users invU on invU.UserId=M.InvitedBy
join Users crU on crU.UserId=G.CreatedBy
Where M.GroupMembershipStatusId in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus())
and M.MemberId=@userId
and (@groupId='' or (len(@groupId)>0 and G.Id=@groupId))
return
end




GO
/****** Object:  UserDefinedFunction [dbo].[Group_GetMembersByUser]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[Group_GetMembersByUser](@userId bigint, @groupId bigint)
returns @Members table (Id nvarchar(128),Name nvarchar(50), Username nvarchar(20), IsAdmin bit, Pending bit, identityTypeId int, identityValue nvarchar(100))
as
begin
	insert into @Members(Id, Name, Username, IsAdmin, Pending, identityTypeId, identityValue)
	Select u.id, u.Name, u.Username, IsAdmin,case when GroupMembershipStatusId = dbo.const_PendingMembershipStatus() then 1 else null end
	,ui.IdentityTypeId, ui.[Identity]
	from GroupMembers m join users u on u.userid=m.memberid
	join UserIdentities ui on ui.UserId = u.UserId
	where groupid=@groupid and 
	(
		(InvitedBy=@userId and GroupMembershipStatusId in (dbo.const_PendingMembershipStatus(),dbo.const_ActiveMembershipStatus()))
	or 
		(GroupMembershipStatusId = dbo.const_ActiveMembershipStatus())
	)
	and u.UserId <> @userId /*exclude request issuer, user membership info loaded on level group not group.members*/
	return
end



GO
/****** Object:  UserDefinedFunction [dbo].[Group_GetSubject]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[Group_GetSubject](@id nvarchar(128))
returns nvarchar(25)
as
begin
	declare @subject nvarchar(25)
	Select @subject=[Subject] From Groups where id=@id
	return @subject
end




GO
/****** Object:  UserDefinedFunction [dbo].[Group_NotificationRemainigRecipientsCountByStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[Group_NotificationRemainigRecipientsCountByStatus](@id nvarchar(128), @statusId int,@userId bigint=-1)
returns int
as
begin
	declare @result int
	Select @result =count(*) from notificationRecipients where notificationId=@id and notificationStatusId<@statusId and (@userid=-1 or (@userid<>-1 and recipientid <>@userId))
	return isnull(@result,0)
end




GO
/****** Object:  UserDefinedFunction [dbo].[InternationalFormat]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[InternationalFormat] (@rawMobile nvarchar(50), @countryCode char(3))
returns nvarchar(50)
as
begin
	return @rawMobile;
end




GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE funCTION [dbo].[Split](@String nvarchar(max), @Delimiter char(1))     
returns @temptable TABLE (items nvarchar(max))     
as     
begin     
	declare @idx int     
	declare @slice nvarchar(max)     
    
	select @idx = 1     
		if len(@String)<1 or @String is null  return     
    
	while @idx!= 0     
	begin     
		set @idx = charindex(@Delimiter,@String)     
		if @idx!=0     
			set @slice = left(@String,@idx - 1)     
		else     
			set @slice = @String     

		if(len(@slice)>0)
			insert into @temptable(Items) values(@slice)     

		set @String = right(@String,len(@String) - @idx)     
		if len(@String) = 0 break     
	end 
return     
end



GO
/****** Object:  Table [dbo].[ApplicationVersions]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationVersions](
	[ApplicationVersionId] [int] NOT NULL,
	[DeviceTypeId] [int] NOT NULL,
	[VersionName] [nvarchar](10) NOT NULL,
	[ReleaseDate] [datetime] NOT NULL,
	[Active] [bit] NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.ApplicationVersions] PRIMARY KEY CLUSTERED 
(
	[ApplicationVersionId] ASC,
	[DeviceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Country]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country](
	[Id] [nchar](2) NOT NULL,
	[Code] [varchar](5) NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
	[BanSMSInvitation] [bit] NULL,
	[PhoneRegExp] [nvarchar](300) NULL,
 CONSTRAINT [PK_SUMU_Messenger.Country] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DeviceTypes]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeviceTypes](
	[DeviceTypeId] [int] NOT NULL,
	[Name] [nvarchar](25) NOT NULL,
	[PNSTypeId] [int] NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.DeviceTypes] PRIMARY KEY CLUSTERED 
(
	[DeviceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupIcons]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GroupIcons](
	[Id] [nvarchar](128) NOT NULL,
	[GroupId] [bigint] NOT NULL,
	[Data] [varbinary](max) NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GroupMembers]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupMembers](
	[GroupId] [bigint] NOT NULL,
	[MemberId] [bigint] NOT NULL,
	[IsAdmin] [bit] NOT NULL,
	[InvitedBy] [bigint] NOT NULL,
	[RemovedBy] [bigint] NULL,
	[GroupMembershipStatusId] [int] NULL,
	[Id] [nvarchar](max) NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupMembershipStatus](
	[GroupMembershipStatusId] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Id] [nvarchar](max) NULL DEFAULT (newid()),
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Groups]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Groups](
	[Id] [nvarchar](128) NOT NULL,
	[GroupId] [bigint] IDENTITY(1,1) NOT NULL,
	[Subject] [nvarchar](25) NOT NULL,
	[CreatedBy] [bigint] NOT NULL,
	[MembersCount] [int] NOT NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IdentityType]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdentityType](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](25) NOT NULL,
	[ImmediateVerification] [bit] NULL DEFAULT ((1)),
	[CodeLength] [int] NULL DEFAULT ((128)),
	[CodeValidForMinutes] [int] NULL DEFAULT ((60)),
 CONSTRAINT [PK_SUMU_Messenger.IdentityType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MediaChunksMapping]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MediaChunksMapping](
	[Id] [nvarchar](128) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[TotalChunks] [int] NOT NULL,
	[FileType] [int] NOT NULL,
	[DeviceFileName] [nvarchar](128) NULL,
	[LocalChunksNames] [nvarchar](max) NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[CompletedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_SUMU_Messenger.MediaChunksMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationRecipients]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationRecipients](
	[NotificationId] [nvarchar](128) NOT NULL,
	[RecipientId] [bigint] NOT NULL,
	[NotificationStatusId] [int] NULL,
	[DeliveredAt] [datetimeoffset](7) NULL,
	[ReadAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_SUMU_Messenger.NotificationRecipients] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC,
	[RecipientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[SenderId] [bigint] NOT NULL,
	[NotificationTypeId] [int] NOT NULL,
	[Message] [nvarchar](2048) NOT NULL,
	[ExpiresAt] [nvarchar](50) NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL,
	[SizeInBytes] [bigint] NULL,
	[Duration] [int] NULL,
	[LocalId] [nvarchar](max) NULL,
	[IsScrambled] [bit] NOT NULL DEFAULT ((0)),
	[GroupId] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationStatus](
	[NotificationStatusId] [int] NOT NULL,
	[Name] [nvarchar](15) NOT NULL,
	[EndStatus] [bit] NOT NULL,
	[Id] [nvarchar](max) NULL DEFAULT (newid()),
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationTracking]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationTracking](
	[NotificationId] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[DeliveredAt] [datetimeoffset](7) NULL,
	[ReadAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_SUMU_Messenger.NotificationTracking] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NotificationTypes]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationTypes](
	[NotificationTypeId] [int] NOT NULL,
	[Name] [nvarchar](25) NOT NULL,
	[PushPreview] [nvarchar](max) NULL,
	[IsChat] [bit] NOT NULL,
	[Id] [nvarchar](max) NULL DEFAULT (newid()),
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PNSTypes]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PNSTypes](
	[PNSTypeId] [int] NOT NULL,
	[Name] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.PNSTypes] PRIMARY KEY CLUSTERED 
(
	[PNSTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PreUser]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PreUser](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](20) NOT NULL,
	[CountryId] [nchar](2) NOT NULL,
	[Password] [varbinary](max) NOT NULL,
	[Salt] [varbinary](max) NOT NULL,
	[UserId] [bigint] NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
 CONSTRAINT [PK_dbo.PreUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PreUserIdentity]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PreUserIdentity](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[PreUserId] [bigint] NOT NULL,
	[Identity] [nvarchar](100) NOT NULL,
	[IdentityTypeId] [int] NOT NULL,
	[ValidationCode] [nvarchar](128) NOT NULL,
	[ExpiresAt] [datetime] NULL,
	[Validated] [bit] NULL DEFAULT ((0)),
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[TransactionType] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemSettings]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemSettings](
	[Key] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.SystemSettings] PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Template]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Template](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [nvarchar](50) NOT NULL,
	[Type] [int] NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.Template] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TracingLogs]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TracingLogs](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[UserId] [nvarchar](128) NULL,
	[Message] [nvarchar](max) NULL,
	[Category] [nvarchar](50) NULL,
	[Level] [nvarchar](50) NULL,
	[Request] [nvarchar](max) NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserAccesses]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserAccesses](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[UserId] [bigint] NOT NULL,
	[Username] [nvarchar](20) NOT NULL,
	[Password] [varbinary](max) NOT NULL,
	[Salt] [varbinary](max) NOT NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserAvailabilities]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAvailabilities](
	[UserId] [bigint] NOT NULL,
	[Online] [bit] NOT NULL,
	[LoggedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_SUMU_Messenger.UserAvailabilities] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserContactInfos]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserContactInfos](
	[Id] [nvarchar](128) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[LocalId] [bigint] NOT NULL,
	[Info] [nvarchar](255) NOT NULL,
	[Source] [nvarchar](50) NULL,
	[InfoTypeId] [int] NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserContacts](
	[Id] [nvarchar](128) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[LocalId] [bigint] NOT NULL,
	[IdentityTypeId] [int] NOT NULL,
	[Identity] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](50) NOT NULL,
	[OriginalIdentity] [nvarchar](100) NOT NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL,
	[ContactUserId] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserIdentities]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserIdentities](
	[UserId] [bigint] NOT NULL,
	[IdentityTypeId] [int] NOT NULL,
	[Identity] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SUMU_Messenger.UserIdentities] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[IdentityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserProfilePictures]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserProfilePictures](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[UserId] [bigint] NOT NULL,
	[Preview] [varbinary](max) NULL,
	[Data] [varbinary](max) NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserPublicKeys]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPublicKeys](
	[Id] [nvarchar](128) NOT NULL,
	[PublicKey] [nvarchar](max) NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NOT NULL,
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [nvarchar](128) NOT NULL DEFAULT (newid()),
	[UserId] [bigint] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[CountryId] [nchar](2) NOT NULL,
	[Version] [timestamp] NOT NULL,
	[CreatedAt] [datetimeoffset](7) NULL DEFAULT (sysutcdatetime()),
	[UpdatedAt] [datetimeoffset](7) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserSessions]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSessions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[PushToken] [nvarchar](1000) NULL,
	[OSVersion] [nvarchar](30) NULL,
	[DeviceModel] [nvarchar](50) NULL,
	[SessionDetails] [nvarchar](500) NULL,
	[LoggedAt] [datetimeoffset](7) NULL,
	[ApplicationVersionId] [int] NOT NULL,
	[DeviceTypeId] [int] NOT NULL,
	[DeviceSerial] [nvarchar](100) NULL,
	[RegistrationId] [nvarchar](max) NULL,
 CONSTRAINT [PK_SUMU_Messenger.UserSessions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserSynchronizeLog]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSynchronizeLog](
	[UserId] [bigint] NOT NULL,
	[InProcess] [bit] NULL DEFAULT ((0)),
	[Data] [nvarchar](max) NULL,
	[StartedAt] [datetimeoffset](7) NULL,
	[EndedAt] [datetimeoffset](7) NULL,
 CONSTRAINT [PK_SUMU_Messenger.UserSynchronizeLog] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwRand]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwRand]
AS
SELECT RAND() AS GetRand




GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AC', N'247', N'Ascension Island', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AD', N'376', N'Andorra', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AE', N'971', N'United Arab Emirates', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AF', N'93', N'Afghanistan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AG', N'1', N'Antigua and Barbuda', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AI', N'1', N'Anguilla', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AL', N'355', N'Albania', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AM', N'374', N'Armenia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AO', N'244', N'Angola', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AR', N'54', N'Argentina', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AS', N'1', N'American Samoa', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AT', N'43', N'Austria', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AU', N'61', N'Australia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AW', N'297', N'Aruba', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AX', N'358', N'Åland Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'AZ', N'994', N'Azerbaijan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BA', N'387', N'Bosnia and Herzegovina', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BB', N'1', N'Barbados', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BD', N'880', N'Bangladesh', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BE', N'32', N'Belgium', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BF', N'226', N'Burkina Faso', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BG', N'359', N'Bulgaria', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BH', N'973', N'Bahrain', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BI', N'257', N'Burundi', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BJ', N'229', N'Benin', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BL', N'590', N'Saint Barthélemy', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BM', N'1', N'Bermuda', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BN', N'673', N'Brunei', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BO', N'591', N'Bolivia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BQ', N'599', N'Caribbean Netherlands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BR', N'55', N'Brazil', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BS', N'1', N'Bahamas', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BT', N'975', N'Bhutan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BW', N'267', N'Botswana', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BY', N'375', N'Belarus', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'BZ', N'501', N'Belize', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CA', N'1', N'Canada', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CC', N'61', N'Cocos (Keeling) Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CD', N'243', N'Congo - Kinshasa', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CF', N'236', N'Central African Republic', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CG', N'242', N'Congo - Brazzaville', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CH', N'41', N'Switzerland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CI', N'225', N'Côte d’Ivoire', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CK', N'682', N'Cook Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CL', N'56', N'Chile', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CM', N'237', N'Cameroon', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CN', N'86', N'China', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CO', N'57', N'Colombia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CR', N'506', N'Costa Rica', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CU', N'53', N'Cuba', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CV', N'238', N'Cape Verde', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CW', N'599', N'Curaçao', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CX', N'61', N'Christmas Island', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CY', N'357', N'Cyprus', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'CZ', N'420', N'Czech Republic', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DE', N'49', N'Germany', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DJ', N'253', N'Djibouti', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DK', N'45', N'Denmark', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DM', N'1', N'Dominica', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DO', N'1', N'Dominican Republic', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'DZ', N'213', N'Algeria', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'EC', N'593', N'Ecuador', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'EE', N'372', N'Estonia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'EG', N'20', N'Egypt', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ER', N'291', N'Eritrea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ES', N'34', N'Spain', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ET', N'251', N'Ethiopia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FI', N'358', N'Finland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FJ', N'679', N'Fiji', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FK', N'500', N'Falkland Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FM', N'691', N'Micronesia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FO', N'298', N'Faroe Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'FR', N'33', N'France', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GA', N'241', N'Gabon', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GB', N'44', N'United Kingdom', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GD', N'1', N'Grenada', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GE', N'995', N'Georgia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GF', N'594', N'French Guiana', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GG', N'44', N'Guernsey', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GH', N'233', N'Ghana', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GI', N'350', N'Gibraltar', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GL', N'299', N'Greenland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GM', N'220', N'Gambia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GN', N'224', N'Guinea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GP', N'590', N'Guadeloupe', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GQ', N'240', N'Equatorial Guinea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GR', N'30', N'Greece', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GT', N'502', N'Guatemala', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GU', N'1', N'Guam', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GW', N'245', N'Guinea-Bissau', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'GY', N'592', N'Guyana', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'HK', N'852', N'Hong Kong SAR China', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'HN', N'504', N'Honduras', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'HR', N'385', N'Croatia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'HT', N'509', N'Haiti', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'HU', N'36', N'Hungary', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ID', N'62', N'Indonesia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IE', N'353', N'Ireland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IL', N'972', N'Israel', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IM', N'44', N'Isle of Man', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IN', N'91', N'India', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IO', N'246', N'British Indian Ocean Territory', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IQ', N'964', N'Iraq', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IR', N'98', N'Iran', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IS', N'354', N'Iceland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'IT', N'39', N'Italy', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'JE', N'44', N'Jersey', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'JM', N'1', N'Jamaica', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'JO', N'962', N'Jordan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'JP', N'81', N'Japan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KE', N'254', N'Kenya', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KG', N'996', N'Kyrgyzstan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KH', N'855', N'Cambodia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KI', N'686', N'Kiribati', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KM', N'269', N'Comoros', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KN', N'1', N'Saint Kitts and Nevis', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KP', N'850', N'North Korea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KR', N'82', N'South Korea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KW', N'965', N'Kuwait', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KY', N'1', N'Cayman Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'KZ', N'7', N'Kazakhstan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LA', N'856', N'Laos', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LB', N'961', N'Lebanon', 0, N'(?:3\d|7(?:[019]\d|6[013-9]|8[89]))\d{5}|(79[13]|81\d)\d{5}')
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LC', N'1', N'Saint Lucia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LI', N'423', N'Liechtenstein', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LK', N'94', N'Sri Lanka', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LR', N'231', N'Liberia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LS', N'266', N'Lesotho', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LT', N'370', N'Lithuania', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LU', N'352', N'Luxembourg', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LV', N'371', N'Latvia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'LY', N'218', N'Libya', 1, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MA', N'212', N'Morocco', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MC', N'377', N'Monaco', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MD', N'373', N'Moldova', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ME', N'382', N'Montenegro', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MF', N'590', N'Saint Martin', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MG', N'261', N'Madagascar', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MH', N'692', N'Marshall Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MK', N'389', N'Macedonia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ML', N'223', N'Mali', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MM', N'95', N'Myanmar (Burma)', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MN', N'976', N'Mongolia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MO', N'853', N'Macau SAR China', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MP', N'1', N'Northern Mariana Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MQ', N'596', N'Martinique', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MR', N'222', N'Mauritania', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MS', N'1', N'Montserrat', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MT', N'356', N'Malta', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MU', N'230', N'Mauritius', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MV', N'960', N'Maldives', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MW', N'265', N'Malawi', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MX', N'52', N'Mexico', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MY', N'60', N'Malaysia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'MZ', N'258', N'Mozambique', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NA', N'264', N'Namibia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NC', N'687', N'New Caledonia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NE', N'227', N'Niger', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NF', N'672', N'Norfolk Island', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NG', N'234', N'Nigeria', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NI', N'505', N'Nicaragua', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NL', N'31', N'Netherlands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NO', N'47', N'Norway', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NP', N'977', N'Nepal', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NR', N'674', N'Nauru', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NU', N'683', N'Niue', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'NZ', N'64', N'New Zealand', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'OM', N'968', N'Oman', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PA', N'507', N'Panama', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PE', N'51', N'Peru', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PF', N'689', N'French Polynesia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PG', N'675', N'Papua New Guinea', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PH', N'63', N'Philippines', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PK', N'92', N'Pakistan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PL', N'48', N'Poland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PM', N'508', N'Saint Pierre and Miquelon', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PR', N'1', N'Puerto Rico', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PS', N'970', N'Palestinian Territories', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PT', N'351', N'Portugal', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PW', N'680', N'Palau', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'PY', N'595', N'Paraguay', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'QA', N'974', N'Qatar', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'RE', N'262', N'Réunion', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'RO', N'40', N'Romania', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'RS', N'381', N'Serbia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'RU', N'7', N'Russia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'RW', N'250', N'Rwanda', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SA', N'966', N'Saudi Arabia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SB', N'677', N'Solomon Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SC', N'248', N'Seychelles', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SD', N'249', N'Sudan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SE', N'46', N'Sweden', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SG', N'65', N'Singapore', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SH', N'290', N'Saint Helena', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SI', N'386', N'Slovenia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SJ', N'47', N'Svalbard and Jan Mayen', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SK', N'421', N'Slovakia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SL', N'232', N'Sierra Leone', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SM', N'378', N'San Marino', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SN', N'221', N'Senegal', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SO', N'252', N'Somalia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SR', N'597', N'Suriname', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SS', N'211', N'South Sudan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ST', N'239', N'São Tomé and Príncipe', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SV', N'503', N'El Salvador', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SX', N'1', N'Sint Maarten', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SY', N'963', N'Syria', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'SZ', N'268', N'Swaziland', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TC', N'1', N'Turks and Caicos Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TD', N'235', N'Chad', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TG', N'228', N'Togo', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TH', N'66', N'Thailand', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TJ', N'992', N'Tajikistan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TK', N'690', N'Tokelau', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TL', N'670', N'Timor-Leste', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TM', N'993', N'Turkmenistan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TN', N'216', N'Tunisia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TO', N'676', N'Tonga', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TR', N'90', N'Turkey', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TT', N'1', N'Trinidad and Tobago', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TV', N'688', N'Tuvalu', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TW', N'886', N'Taiwan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'TZ', N'255', N'Tanzania', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'UA', N'380', N'Ukraine', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'UG', N'256', N'Uganda', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'US', N'1', N'United States', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'UY', N'598', N'Uruguay', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'UZ', N'998', N'Uzbekistan', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VA', N'379', N'Vatican City', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VC', N'1', N'St. Vincent & Grenadines', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VE', N'58', N'Venezuela', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VG', N'1', N'British Virgin Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VI', N'1', N'U.S. Virgin Islands', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VN', N'84', N'Vietnam', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'VU', N'678', N'Vanuatu', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'WF', N'681', N'Wallis and Futuna', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'WS', N'685', N'Samoa', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'YE', N'967', N'Yemen', 1, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'YT', N'262', N'Mayotte', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ZA', N'27', N'South Africa', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ZM', N'260', N'Zambia', 0, NULL)
GO
INSERT [dbo].[Country] ([Id], [Code], [Name], [BanSMSInvitation], [PhoneRegExp]) VALUES (N'ZW', N'263', N'Zimbabwe', 0, N'(?:3\d|7(?:[019]\d|6[013-9]|8[89]))\d{5}|(79[13]|81\d)\d{5}')
GO
INSERT [dbo].[DeviceTypes] ([DeviceTypeId], [Name], [PNSTypeId]) VALUES (0, N'unknown', 0)
GO
INSERT [dbo].[DeviceTypes] ([DeviceTypeId], [Name], [PNSTypeId]) VALUES (1, N'android', 1)
GO
INSERT [dbo].[DeviceTypes] ([DeviceTypeId], [Name], [PNSTypeId]) VALUES (2, N'iOS', 2)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (1, N'Pending', N'D22358B6-4746-4A81-9557-989970669CBD', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (2, N'Active', N'AFE10AD2-888D-4C29-81AC-52FB8AEDCA3E', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (3, N'Rejected', N'C7EA0CD5-3E99-419A-B51A-0BED124ECF2E', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (4, N'Cancelled', N'3C69A72C-71D4-45CC-B087-031CAC84A2C1', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (5, N'Left', N'ED697703-60A7-4B73-AF97-A360E88624DE', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId], [Name], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (6, N'Removed', N'027AFCEB-FC10-487F-B3EF-0BA5F82D40BA', CAST(N'2021-02-12T10:24:20.9917742+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[IdentityType] ([Id], [Name], [ImmediateVerification], [CodeLength], [CodeValidForMinutes]) VALUES (0, N'Username', 1, 0, 0)
GO
INSERT [dbo].[IdentityType] ([Id], [Name], [ImmediateVerification], [CodeLength], [CodeValidForMinutes]) VALUES (1, N'Mobile', 1, 6, 15)
GO
INSERT [dbo].[IdentityType] ([Id], [Name], [ImmediateVerification], [CodeLength], [CodeValidForMinutes]) VALUES (2, N'Email', 0, 128, 60)
GO
INSERT [dbo].[Notifications] ([Id], [SenderId], [NotificationTypeId], [Message], [ExpiresAt], [CreatedAt], [UpdatedAt], [Deleted], [SizeInBytes], [Duration], [LocalId], [IsScrambled], [GroupId]) VALUES (N'BE484587-EC43-4067-99C0-F0DD0BECB0CC', 1, 5, N'', NULL, CAST(N'2021-02-22T18:45:04.7359962+00:00' AS DateTimeOffset), CAST(N'2021-02-22T18:45:04.7670408+00:00' AS DateTimeOffset), 0, NULL, NULL, NULL, 0, NULL)
GO
INSERT [dbo].[Notifications] ([Id], [SenderId], [NotificationTypeId], [Message], [ExpiresAt], [CreatedAt], [UpdatedAt], [Deleted], [SizeInBytes], [Duration], [LocalId], [IsScrambled], [GroupId]) VALUES (N'21D736E5-C691-4C32-B639-AA7331FD8A4A', 2, 5, N'', NULL, CAST(N'2021-04-07T19:16:42.5966632+00:00' AS DateTimeOffset), CAST(N'2021-04-07T19:16:42.6010463+00:00' AS DateTimeOffset), 0, NULL, NULL, NULL, 0, NULL)
GO
INSERT [dbo].[Notifications] ([Id], [SenderId], [NotificationTypeId], [Message], [ExpiresAt], [CreatedAt], [UpdatedAt], [Deleted], [SizeInBytes], [Duration], [LocalId], [IsScrambled], [GroupId]) VALUES (N'EA31159F-CF75-4ED6-8235-8E2810ADE7A9', 10002, 5, N'', NULL, CAST(N'2021-04-08T14:30:41.8819889+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:30:41.8836249+00:00' AS DateTimeOffset), 0, NULL, NULL, NULL, 0, NULL)
GO
INSERT [dbo].[Notifications] ([Id], [SenderId], [NotificationTypeId], [Message], [ExpiresAt], [CreatedAt], [UpdatedAt], [Deleted], [SizeInBytes], [Duration], [LocalId], [IsScrambled], [GroupId]) VALUES (N'B9778A55-B02E-40A6-B908-BBD3EC55FCA0', 10003, 5, N'', NULL, CAST(N'2021-04-08T14:31:29.0550147+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:31:29.0591151+00:00' AS DateTimeOffset), 0, NULL, NULL, NULL, 0, NULL)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (1, N'Pending', 0, N'81172BAF-E2C8-46C9-9BB3-4B0B0EA4ED6C', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (2, N'Delivered', 0, N'20AF7136-9C4B-43AD-A7F1-1CBA15901F48', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (3, N'Recalled', 1, N'B2F12F52-BAA1-47A2-8B67-AA172852BC7F', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (4, N'Read', 1, N'ECD45AB6-AF3A-4B96-98C2-FF2E8AA4A1E2', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (5, N'Expired', 1, N'EDE61EE2-D66A-4768-AC01-EE355AC8D6D5', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (0, N'Scheduled', 0, N'73386E9B-D340-4714-B03B-086C02D09752', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationStatus] ([NotificationStatusId], [Name], [EndStatus], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (6, N'Sending', 0, N'DD84220E-5641-496F-AB67-6D17E6CA1429', CAST(N'2021-02-12T10:13:50.2511516+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (1, N'Text', N'', 1, N'6C687A43-7118-41FD-A108-34F3B22419AE', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (2, N'Photo', N'Photo', 1, N'5CF0E54C-7166-4BAD-B692-B1D5D102D388', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (3, N'Video', N'Video', 1, N'E4AFE0A7-BD9C-4EEB-A55C-E133B8E60CE2', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (4, N'Audio', N'Audio', 1, N'F6E37C8C-0763-4FEE-936E-EBC3D16654D9', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (5, N'Joined', N'', 0, N'DFEDF585-C062-4132-AAEE-08E958613F86', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (6, N'ProfilePicChanged', N'', 0, N'90F22F7C-2AF0-4E1B-906C-148A0C1F3AEC', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (7, N'Reset', N'', 0, N'3C54BC32-0A06-4E63-A8A3-F775FDB40C62', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (8, N'MessageDelivered', N'', 0, N'2DFC7845-3D89-451D-810B-AC8479CD8577', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (9, N'MessageRead', N'', 0, N'CFF7D434-38D7-4F76-99CD-77D04C04E42C', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (10, N'MessageRecalled', N'', 0, N'0786BC55-D11F-4603-A6A8-5ED7A51D4B0F', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (11, N'VoiceNote', N'Voice note', 1, N'34A21564-6AF2-4019-8CAE-DF9A3CBB59AA', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (12, N'Handshake', N'', 0, N'07E0F81B-D334-49B9-8CC0-A131B04A184B', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (13, N'PublicKeyChanged', N'', 0, N'4AABB393-6C49-44C2-8704-55983E128723', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (14, N'DisplayNameChanged', N'', 0, N'A73DAF2D-B531-4EC0-B35B-49FFF86D9CA7', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (15, N'GroupInvitation', N'Group invitation', 1, N'D731DA15-8714-4D7D-B93C-F12BCE6A2914', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (16, N'GroupSubjectChanged', N'', 0, N'67BBEB0C-2426-4CF8-9FDF-CFBDFE4A3B2E', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (17, N'GroupIconChanged', N'', 0, N'9AC129E5-0EE1-472F-92A9-777CC3F32DE6', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (18, N'GroupInvitationCancelled', N'', 0, N'FBE0940A-C374-477F-9257-4A6B35D670F7', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (19, N'GroupInvitationRejected', N'', 0, N'4BCFA5EB-7414-43B6-BF05-CC488CF97647', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (20, N'GroupMemberJoined', N'', 0, N'50A29E06-F521-4FEF-8AEF-52628CE87A48', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (21, N'GroupMemberLeft', N'', 0, N'09F9D196-B335-4784-B98D-5D381BD254F4', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (22, N'GroupMemberRemoved', N'', 0, N'25836813-84A9-4265-A245-1D0C6A8EC792', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (23, N'GroupMemberSetAsAdmin', N'', 0, N'2CE7DA6F-AF9D-4792-AE5D-9504CCD1C3CF', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (24, N'IdentityUpdated', N'', 0, N'D82D209F-EDF7-4769-8C08-FEB4F4DFD7CD', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[NotificationTypes] ([NotificationTypeId], [Name], [PushPreview], [IsChat], [Id], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (25, N'Left', N'', 0, N'ECD19565-7737-481A-93A7-7CFFCF688965', CAST(N'2021-02-12T10:11:56.4928066+00:00' AS DateTimeOffset), NULL, 0)
GO
INSERT [dbo].[PNSTypes] ([PNSTypeId], [Name]) VALUES (0, N'unknown')
GO
INSERT [dbo].[PNSTypes] ([PNSTypeId], [Name]) VALUES (1, N'gcm')
GO
INSERT [dbo].[PNSTypes] ([PNSTypeId], [Name]) VALUES (2, N'apns')
GO
INSERT [dbo].[PNSTypes] ([PNSTypeId], [Name]) VALUES (3, N'wns')
GO
INSERT [dbo].[PNSTypes] ([PNSTypeId], [Name]) VALUES (4, N'mpns')
GO
SET IDENTITY_INSERT [dbo].[PreUser] ON 

GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (1, N'saharmerheb', N'LB', 0x5448A45B5631608FA0C8C6CECC1F15BDD84153B4CF8D35CA8BA57FCFC134DAD1A1412BA1251C1CA9C8940CF3F51DC8CF68A023F46E795E9AEDF5B600058E0F37, 0x745F8B0CE8379C22006C51B19F16CCA0A9CB7704AE784704A152945ABF6A14A13DBAD4B0A9625670DA4BF8CE11CE940C818D1B34DBAE2DE6873ED4CDEAB59E78DB1A085EB28EB0BA44A449D00EF9FFF6C870D3ABD245FBA1E73320D3FDDCC4EAF9339DD01F25CE06E964E1E7BDF61B4A3938EEE92E624EE04B73C652EEFFF7FB28A8E3BA4D5D6CBCCDD95BC100B9ED51A943869362527A028774C0AC8996B05FFDB0A793E2A71AA5FEC821CC4CDDE8D937ED570A756E4B8AA8B16F90231CBE84BB80AAC921BB630B9D29B14840492949D342FE8B4103FB1918355F77034A29E914AE159FE5AFA45F34BE78771B65BF645F309BE5C42A0FEB55589655A43737A5, NULL, CAST(N'2021-02-19T19:51:56.3071112+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (2, N'saharmerheb', N'LB', 0xBB79F042572D233CF503B522FA60F5A3869E0A2DE3AFEB404B6ACF03AED3BC1215894895F77132A99B1111490CA55B43D9244AC362DA4511A7FB111BA57B38EC, 0x8098384433A0EF577F0051FAA8B742CEE9D3663E86D8DE19E2402D81736420A8946BCDCEE9BB1C70B6A57A10134C640CE8AF7A74C20197BFEA392548A6AD5CB9E7A330EC8059C3F88BB54D24F50D0A95D2C20C0226E9212F4954FCD483914BD62099C432C93CDECCA715CA27EBB5D5E94F105BDE916461FA42BA8C17B54982CEDA7E1B60E15A69CB0997816E1F4815957442F3D167BF45DCFCCB372AC8631289B8AA1A73040E6ECCAB5F0490F68A270B63147216EA9B68F9554AB559E88973FC2AF54CD84200BB5FC598B0D3A5A4A2331AA137D482720940D27DCE1446DB3B54EE2E690C5FD87ADA80708EFB29F9813627127295D61001906E6DB1C487E2A056, NULL, CAST(N'2021-02-19T19:53:50.7168658+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (3, N'saharmerheb', N'LB', 0xAF8585FD0D638AB74F53A4963ECF90E00942D8A6CE3081150DA72F38666B86BA615740BAFA43F5B65909209F7EEA267C61C7ADF4AB061CE18683334CF9DFB56F, 0x9DA9DAD308E7E1959702D564C84F3CBB4AE46A689061C2C6B2A51AE6F7CF3E08E124C7DAA716F99C3C320CB5C98A03BA2A29FE895420894B45D7DEF90F8F5686181780AA9DA6672447C6C47A8FF743FF8E84AF9CB282E85642F0AEDE60765924B0D10F1BC80579FA40A250DB850C7165C20A4A5B9A7E728FC832E89407D815D04E95B04B57687097D819EFEF9C1B43AB814C1290B2B5C2BDEDBBFE5FE2F716E48F50573FDFFBE83156A9E268FB7CB9AAC7497D6C180FE9AB99FE6482DD97AFB8CA315AFA583E7347AD3749DBEF416E9D77FE9495AE7E0E316A79420A0760EF4838F10FAAE458896F635858421972F8234594B9490A5078BB1CCAF32A925F6A5C, NULL, CAST(N'2021-02-19T19:57:27.0585689+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (4, N'saharmerheb', N'LB', 0x28805C864FF09C89EF17B4B501C0411F682E4A9AF7984D5581105F217C6686FA8C3FA7C50FF2ECF034A52D0C0F5B2A133F5307F5C4B01D5788BDE05B215ECE87, 0x708A705A9952835F8AFB927B11EC080FF08F54A7EE740C099153F7E720C776DD31C330CEE270F73A876485397F979ECC76E8D85AB848EBCB5721C79628F11970AF49D7A8DD15E755AFBDA32070E5642CAB9EED908947F30A2EAB04F1F8CDFED0CECE3FE2503DA29BC8402B545351F888F96182F6E112D0B7CB864DA1F3A21F461BC95F54876107DE2DF921FA7134D73321E1D7B59B27BFE20FC3EB9DE9608C364368CF86C711DD16907E749F3B19D6A679CDAEDABDEFF767838A0563046C0C52BC21FB44A03EF58CBEF0AE9A2B309C3283EDF399BFE0DA78FAFF567E801040FBED741268D768A4FC5A19CA7AF8880733127E3D59F02A87A4482DBA9C47DACD96, NULL, CAST(N'2021-02-19T19:59:01.9941554+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (5, N'saharmerheb', N'LB', 0x89C1525D2FB456189DBD56CFC56D7A04C7D9A461442B1855FCB34F1309DB93D626854CA89DD55BD292853AF89DF4ABBBA272B25807254C554BF3810BDB7BF53C, 0x300C640988E02C09F4FC2C3FB742F96E934199E88A00DEA46C39E26438EC3D0CE7B2083873BB10FF01965BCEEEADB478720279C430C4E35DD2E89436F187AC88EC3257659613E23CC609626A1D891CCA16399C217ADEF12E33AE49D7BB00F66BC525F711D6E0A7AC67CD7D3957F5C966ABF51279D37ECFF5E760A99CF670BF5743B9D38BAF741A28C03E985C406E618C3156FBDC5CBFD9013A9B4BAE7BB6C61D9DBE83C774BBD3483C88003AC01A77DF6CCA33D08B87115FC11294829CA6376D3DB219DB01C2A3C621B34D997F07147A67663CA538BA06CAF3F0E1CEAECD06F954A295F07BC8431FB51CA4AF33142A6F16C57DD3433140C69FE8C8FB3A5402C9, 1, CAST(N'2021-02-22T18:44:40.9776551+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (6, N'lamar', N'LB', 0x8AC2D563311D8C8996635A051F73B17EF1D98235D6E3687DB437FD40200E6A4C16DADFF4D27C0788D5E77545118180C29D824E9A088E34E894D20AE5AFA32610, 0x0BD8E118529DC469BF18E32017C7ED1180FDA5D571D76C234FC51722585EE6C98264CAE0CD6BB9BD2E58B0A367238FB76CCBC6B8D69E0F8FCF255F12EBB10885F8D28E36194F1872EBE4AD768E28BD6E6538B572F132EB0959052A809C924FA6507D1872A3900343773FA46686E2B506704CB54A64FC34A67F5FE4BC1F96E65911206133A35AA25E1ECB868B72CE78FD1B7B43AD4C607D4D08057AF7B32858F7F9B4F45E9ECEB7870B1DE7672981F8B090107FFADE1945EDE5EA89ABE8B40EE0BBE5A246CACA3736D1F76B131B23AD1BAE7B572DBEEAA2363A302A3ACE3712509AFC3C44AF880BCDC3D9BC29A5C1CB64011145D1AB2F419B254309FC70917948, NULL, CAST(N'2021-04-07T18:38:27.8795357+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (7, N'lamar', N'LB', 0x6C58A3C494015EE48A55C850DCC0DEF82D0B49AACD0CCDB603ACF940D44B36C8D351FF462E0221FCE18669666EC5E96A21CB3B20A6E6686EE7F2D6A002DC3840, 0xA33AB9D5769ED36A8064C154DB07899E0360C7D6D571C2F828EF5003FB1B99AC0519BCC9705456195161CE15E83E5B173C89DC47F954502947111343EDE6D1B5DF5B70678E94833155317026108DA985D8D877CF3B00FF1BC3482D9D73CF2364D4B977F54393E4E43A1B5F4B33B077C3F381A85276408C101ED5834EDCA03F5CDA6E0D68E44B3BC5438A67247DA179E0DE6938DE53949CCC5805C9A70611A19E2CAEB6CD1D8D9DEB70D3B73B1E70FA788FE429D07EA02BA7DEE2F5099C25D5F244F439A46932BFA894CCA1E7E8A7C66BA98BF2DDA5954B5185BB9A84B328F7BAA27879EB6C5F97D29433BC476416B344F505BF75F2B75ADB052506D0EC874F42, NULL, CAST(N'2021-04-07T18:46:14.8177142+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (8, N'lamar', N'LB', 0x3EABA320BE8FDF34F9B43D94E7404845EBE5C1854CE13177D656EAB221BFEDB32207729360F9080A83E18748C2E6724F832D3A8FA5D62751CF00EBF53061D9E7, 0xB6F2AB09D2778ACA747807642D13CB0C9DBFC5ABB2716F06FC90EBE0474263C4AF243996D077C46243FE51F6941AD1D848559493012BF97BBFA349D2A3A61BDC4D575DAC9134D43DEFD83B94632D4849AC47E97DD929FE78C8A000965544E206D5D55B36AE92BF1719E5181C64AA5ADC70816EBA81184A338EBBF79BB0DD0B11B43F229F8B013981AA23B149F3E683D61A49686BA6992CD21824E08662F678986B286816839B54115F47379CE0BEEF9807A6C915FE560B7A1092ED2C9C81969281F6F3AAC93696D274A8FB54928D6ACB41CCFBB22EDAE6B8C844967DFE8057007772594FA99D878A16E8CF8963E0AA44FA6F077F0F4F2C8816A39DABEBEC2DDE, 2, CAST(N'2021-04-07T19:14:45.1642306+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (10006, N'restapiuser', N'LB', 0xE2ABDFCFEDCF12F6E83309754BBE4135A4617AA9378E9016A058DE7C6B97AB1C273CA364CDA797B8D707F9EFF9F74E604A225D4006A69FA941BAE8177E4EAF95, 0xD719818776ED4CF3ED7F5732458A664F877AE685E78A0BF431A5DD6089941D70B9D0AADCF8C9A08D4F23746E59D5FF207A4C4741D317F389A82A40ADD181253888FEEB3177EA2B669EB213C325537FC1AE639BB5C5E194F6D15A4642E4CA89E7D94FA02B201CAC17CAEE36F11D586417C55D80E0CBCF0F0171AFB4957E8C1A253D2F3DC638C61EBA5D8ECFC593B30FE6DC8DEEFA5D0832DF9DC8C8DFEFA4C034125E92BE81274725AEBC672FB5F3590EAFF349823A5E130CE92A5BCA65DC4FC8AB6D2752D9E2D8172446CD85732EFAEBC7208D1978818A7A2C782947F6504EB8CF439CC5018C04AADA9B384A38579A719A4581F4D1B0AADBCA667CCDA2DA411F, 10002, CAST(N'2021-04-08T14:24:25.8929439+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (10007, N'restapiuser2', N'LB', 0x4F587ECD865BBF86E58C9EECF76DA0531AE69A7016A445938D92678E23534A7AB1F6B48F175261185CCE8F32C9A2554A5A882142C3167C1ECB71DD2A97664728, 0xDAACF7681C22F8904FE1FA8DD958E8027FB2FD66EA3BA4AB6947839A10105B3FAA7F8EE2C885930BB9F46B875184D43ADED85AEFEB1DA679A64BF66C9E05A17DE53949916DDEE504D77A0485A9FEE088234A83609AFAD173356499FE46BF20268893EC2B8D5731FDA0269854FF233357CE29464C5E5C3D7CAE85354B2CBABEBC54AA49654EB32C4B573806D0EF97CAD0D694F693E5ED77776BCC59AE9094DD13B37AB20F5E93D4108AC758875633966CAF69E64C317C842C0A6FF7741D4C00800EA6924FC5B92DC56480A5FC88BD94EC3D3ACE72FBE2FA4A2CE56443A257DE67AADCDA7B13FEA2BF532928B7490F28F0EB8CF432A9EBF5FD0A5F5E0F62090B0C, 10003, CAST(N'2021-04-08T14:31:03.5463892+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[PreUser] ([Id], [Username], [CountryId], [Password], [Salt], [UserId], [CreatedAt]) VALUES (10008, N'restapiuser3', N'LB', 0xF1F04D73A383CB0DEC3B05A9434A71E6D71B947CA228B262777A2EAE00451A7373606E33391871780EC1EBEF6C6524CB9987ABADC7814C4CAD63A1743FD4A2AE, 0x1C83D86AACA54B5469594B3E87118BF62485782EC3DFCB5A37B045DD3778A80B420713E7ACD77AF4FE6B9FB0D87022C7000BF4F5D04B0FDFD89635C2A959AF2ADF4C2DCF9F138174D55CA0477DE73033BA6DBB10629E55D5A17D9BAF96C7F8F0C5AE2352E745DDD05E2E5CC7E055E65A107335A4EADE511FCE2CAA5858F30FAAD304A31D3DA15343DB46042241D3618DF06065AD92F26308F3914E057F4062F521F19245A03D3F1CBB5A2B7C2386B86662121E0569BB675DF0EF2FEF57A4F74E7876A4EA54986898F48E3BD259354CB9A67CA8C77E87C3E42347A22FC5D4B02238F6CC9AB0AC78AB01A6E3B281F348E2E673778467A282982C2470080E7B7464, NULL, CAST(N'2021-04-08T14:37:35.9645893+00:00' AS DateTimeOffset))
GO
SET IDENTITY_INSERT [dbo].[PreUser] OFF
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'A8B40609-33C1-4A5E-9750-06EFA256CFD6', 4, N'96170511852', 1, N'000000', CAST(N'2021-02-19 20:14:02.130' AS DateTime), 0, CAST(N'2021-02-19T19:59:02.1302717+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'232AFF0C-7804-4A14-A1D5-ECA660EB4AD8', 5, N'96170511852', 1, N'000000', CAST(N'2021-02-22 18:59:41.600' AS DateTime), 1, CAST(N'2021-02-22T18:44:41.6005582+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'F1CC6315-30D0-4247-983C-1C116A072EAA', 8, N'96170117012', 1, N'129259', CAST(N'2021-04-07 19:29:45.167' AS DateTime), 1, CAST(N'2021-04-07T19:14:45.1692305+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'7F921512-A55A-4657-B8B2-5D6B05168BA9', 10006, N'96170117013', 1, N'462717', CAST(N'2021-04-08 14:39:25.907' AS DateTime), 1, CAST(N'2021-04-08T14:24:25.9070250+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'9A541D7B-FB3D-4BC7-87B8-4C6DE6D4198D', 10007, N'96170117014', 1, N'000000', CAST(N'2021-04-08 14:46:03.553' AS DateTime), 1, CAST(N'2021-04-08T14:31:03.5543947+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[PreUserIdentity] ([Id], [PreUserId], [Identity], [IdentityTypeId], [ValidationCode], [ExpiresAt], [Validated], [CreatedAt], [TransactionType]) VALUES (N'7FB310CE-A641-46BF-A42C-FAE2A875BD64', 10008, N'961701170145', 1, N'000000', CAST(N'2021-04-08 14:52:35.970' AS DateTime), 0, CAST(N'2021-04-08T14:37:35.9734263+00:00' AS DateTimeOffset), NULL)
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'5F8BFE69-AC3D-4BC8-ABC9-266B0585A1A3', N'', N'{"Username":"saharmerheb#","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170511852","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-02-19T19:47:09.1607873+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'80085BBE-B556-47E9-A7D5-083633FF135C', N'', N'Nullable object must have a value.', N'', N'error', N'/api/user', CAST(N'2021-02-19T19:51:57.3396697+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'DB539CE5-3300-4F0F-BEBE-D6ABAEA63066', N'', N'Nullable object must have a value.', N'', N'error', N'/api/user', CAST(N'2021-02-19T19:57:15.9694152+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'F25833F9-3EEC-48C9-8FB5-DA3A997BE0B2', N'', N'Cannot find either column "dbo" or the user-defined function or aggregate "dbo.CheckIfRegisteredByPreUserId", or the name is ambiguous.', N'', N'error', N'/api/user', CAST(N'2021-02-19T19:57:42.4907418+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'E799ED4F-8DC8-41F4-BFDF-8B2116990C4D', N'', N'4:{"Username":"saharmerheb","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170511852","Email":null}:[{"TypeId":1,"Identity":"96170511852","Token":"A8B40609-33C1-4A5E-9750-06EFA256CFD6","Validation":"000000","Immediate":true,"Template":""}]', N'', N'info', N'/api/user', CAST(N'2021-02-19T19:59:02.2973611+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'F29E70C6-9666-4B00-9847-5B8CD3A1D5F6', N'', N'{"Username":"saharmerheb$","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170511852","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-02-20T14:47:14.6342794+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'8090DE1D-E3D9-4D5F-9117-E7271BC47248', N'', N'{"Username":"saharmerheb$","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170511852","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-02-20T20:12:49.9379823+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'B5EFE6FB-B03E-44CC-B8E0-E670E2CB960B', N'A8B40609-33C1-4A5E-9750-06EFA256CFD6', N'CodeExpired', N'', N'error', N'/api/identity?token=A8B40609-33C1-4A5E-9750-06EFA256CFD6&code=000000', CAST(N'2021-02-22T18:44:17.1474777+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'64C29012-9672-4694-9E9C-C5DF83E5A000', N'', N'{"Username":"saharmerheb$","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170511852","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-02-22T18:44:31.2360976+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'E93345F2-00D8-4372-A6AA-FC82238BA4E0', N'232AFF0C-7804-4A14-A1D5-ECA660EB4AD8', N'CodeExpired', N'', N'error', N'/api/identity?token=232AFF0C-7804-4A14-A1D5-ECA660EB4AD8&code=000000', CAST(N'2021-02-23T14:54:56.4791824+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'FFF0F01B-652F-434D-843B-74CB5C11143B', N'232AFF0C-7804-4A14-A1D5-ECA660EB4AD8', N'CodeExpired', N'', N'error', N'/api/identity?token=232AFF0C-7804-4A14-A1D5-ECA660EB4AD8&code=000000', CAST(N'2021-02-23T14:56:07.5177464+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'5E54F034-60D5-4D06-A78D-DF4E9076E718', N'232AFF0C-7804-4A14-A1D5-ECA660EB4AD8', N'CodeExpired', N'', N'error', N'/api/identity?token=232AFF0C-7804-4A14-A1D5-ECA660EB4AD8&code=000000', CAST(N'2021-02-23T15:01:33.4046207+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'8259CC1E-EE7F-49F3-807A-D96FE5D864CF', N'232AFF0C-7804-4A14-A1D5-ECA660EB4AD8', N'CodeExpired', N'', N'error', N'/api/identity?token=232AFF0C-7804-4A14-A1D5-ECA660EB4AD8&code=000000', CAST(N'2021-02-23T15:05:09.1438958+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'557DC735-DC18-4D52-9552-86B1F1B459C3', N'', N'{"Username":"ah","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170117012","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-03-25T13:14:00.1116162+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'2172883E-3A79-4539-AE5B-87B6844571CD', N'', N'Cannot find either column "dbo" or the user-defined function or aggregate "dbo.GenerateMobileValidationCode", or the name is ambiguous.', N'', N'error', N'/api/user', CAST(N'2021-04-07T18:38:28.0319427+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'90B4EB4A-981C-4BBF-ACAD-3ADC8492FFBD', N'', N'Cannot find either column "dbo" or the user-defined function or aggregate "dbo.CheckIfRegisteredByPreUserId", or the name is ambiguous.', N'', N'error', N'/api/user', CAST(N'2021-04-07T18:46:14.8505262+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'6DD86B1A-0E72-403F-A9A5-28719AD0B6B4', N'F1CC6315-30D0-4247-983C-1C116A072EAA', N'', N'', N'info', N'/api/identity?token=F1CC6315-30D0-4247-983C-1C116A072EAA&code=000000', CAST(N'2021-04-07T19:15:08.6202682+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'12B8C4A0-8EBE-4ABE-95B9-E20CEC68FF31', N'F1CC6315-30D0-4247-983C-1C116A072EAA', N'CodeInvalid', N'', N'error', N'/api/identity?token=F1CC6315-30D0-4247-983C-1C116A072EAA&code=000000', CAST(N'2021-04-07T19:15:08.6705596+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'6FF1F7A1-0545-4F9E-BED6-AFE839CE4A2B', N'', N'{"Username":"ah","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170117012","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-03-25T14:51:04.5757808+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'80D4B3A2-18EA-490F-900C-CB2AA0DB2F1A', N'', N'{"Username":"ah","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170117012","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-04-06T07:43:23.7474015+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'5D37294F-9CCC-4C94-98B3-0BACD23C8634', N'F1CC6315-30D0-4247-983C-1C116A072EAA', N'', N'', N'info', N'/api/identity?token=F1CC6315-30D0-4247-983C-1C116A072EAA&code=129259', CAST(N'2021-04-07T19:16:42.5404972+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'FC6ED663-F533-4A37-8AA5-5D94AEA62E9C', N'', N'UsernameNotAvailable', N'', N'error', N'/api/user', CAST(N'2021-04-07T19:16:53.6853370+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'A82EEC6A-5CD1-4576-A5E3-606161FB2557', N'', N'Procedure or function ''GetUsers'' expects parameter ''@offset'', which was not supplied.', N'', N'error', N'/api/user', CAST(N'2021-04-08T13:52:58.9264297+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'4C789421-D3FB-4A88-902B-C500B080E940', N'', N'Procedure or function ''GetUsers'' expects parameter ''@offset'', which was not supplied.', N'', N'error', N'/api/user', CAST(N'2021-04-08T13:53:17.8017271+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'7556A422-32E8-4777-ADB2-277CAC989F4E', N'', N'UsernameNotAvailable', N'', N'error', N'/api/user', CAST(N'2021-04-08T14:19:13.6698133+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'403E7D58-DDDD-45D5-B1C9-59ED863E9473', N'7F921512-A55A-4657-B8B2-5D6B05168BA9', N'', N'', N'info', N'/api/identity?token=7F921512-A55A-4657-B8B2-5D6B05168BA9&code=462717', CAST(N'2021-04-08T14:30:41.8191371+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'36E3E603-8D73-4C6A-8F18-47CE97A097EB', N'9A541D7B-FB3D-4BC7-87B8-4C6DE6D4198D', N'', N'', N'info', N'/api/identity?token=9A541D7B-FB3D-4BC7-87B8-4C6DE6D4198D&code=000000', CAST(N'2021-04-08T14:31:28.9564343+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'03BAD5E6-5BCC-416B-86DA-E06FDF3C7817', N'', N'', N'', N'info', N'/api/country/mobile?id=LB&mobile=70117012', CAST(N'2021-04-08T14:56:02.7328683+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'55A81D12-798C-410E-BD99-53A2F0156DED', N'', N'', N'', N'info', N'/api/country/mobile?id=LB&mobile=701170123', CAST(N'2021-04-08T14:56:06.9791299+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'0837CA1C-5DD3-4CD7-B388-C63834D283D4', N'', N'', N'', N'info', N'/api/country/mobile?id=LB&mobile=70117012', CAST(N'2021-04-08T14:56:20.9502187+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'966ADF97-DEB3-4A3A-AE24-248D2EF961A3', N'', N'', N'', N'info', N'/api/country/mobile?id=LB&mobile=701170123', CAST(N'2021-04-08T14:56:27.0950534+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'58AF7D8F-2124-4CDB-8CF3-D492AF5A1E5D', N'', N'', N'', N'info', N'/api/country/mobile?id=LB&mobile=701170123', CAST(N'2021-04-08T14:57:15.0722702+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[TracingLogs] ([Id], [UserId], [Message], [Category], [Level], [Request], [CreatedAt]) VALUES (N'D31EFA2E-EDF6-4B94-A183-073E9C144520', N'', N'{"Username":"ah","Password":"P@ssw0rd","CountryId":"LB","Mobile":"96170117012","Email":null}:{"item.Username":{"Value":null,"Errors":[{"Exception":null,"ErrorMessage":"The field Username must match the regular expression ''^(?=.{3,15}$)([A-Za-z0-9][._]?)*$''."}]}}', N'', N'error', N'/api/user', CAST(N'2021-04-06T13:41:39.8950596+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[UserAccesses] ([Id], [UserId], [Username], [Password], [Salt], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'5D8108B2-EEC2-4759-999B-2790909535E8', 1, N'saharmerheb', 0x89C1525D2FB456189DBD56CFC56D7A04C7D9A461442B1855FCB34F1309DB93D626854CA89DD55BD292853AF89DF4ABBBA272B25807254C554BF3810BDB7BF53C, 0x300C640988E02C09F4FC2C3FB742F96E934199E88A00DEA46C39E26438EC3D0CE7B2083873BB10FF01965BCEEEADB478720279C430C4E35DD2E89436F187AC88EC3257659613E23CC609626A1D891CCA16399C217ADEF12E33AE49D7BB00F66BC525F711D6E0A7AC67CD7D3957F5C966ABF51279D37ECFF5E760A99CF670BF5743B9D38BAF741A28C03E985C406E618C3156FBDC5CBFD9013A9B4BAE7BB6C61D9DBE83C774BBD3483C88003AC01A77DF6CCA33D08B87115FC11294829CA6376D3DB219DB01C2A3C621B34D997F07147A67663CA538BA06CAF3F0E1CEAECD06F954A295F07BC8431FB51CA4AF33142A6F16C57DD3433140C69FE8C8FB3A5402C9, CAST(N'2021-02-22T18:45:03.8029902+00:00' AS DateTimeOffset), CAST(N'2021-02-22T18:45:03.8749517+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserAccesses] ([Id], [UserId], [Username], [Password], [Salt], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'605A3BBC-DA66-4A10-AD81-D7FDBEB1CB44', 2, N'lamar', 0x3EABA320BE8FDF34F9B43D94E7404845EBE5C1854CE13177D656EAB221BFEDB32207729360F9080A83E18748C2E6724F832D3A8FA5D62751CF00EBF53061D9E7, 0xB6F2AB09D2778ACA747807642D13CB0C9DBFC5ABB2716F06FC90EBE0474263C4AF243996D077C46243FE51F6941AD1D848559493012BF97BBFA349D2A3A61BDC4D575DAC9134D43DEFD83B94632D4849AC47E97DD929FE78C8A000965544E206D5D55B36AE92BF1719E5181C64AA5ADC70816EBA81184A338EBBF79BB0DD0B11B43F229F8B013981AA23B149F3E683D61A49686BA6992CD21824E08662F678986B286816839B54115F47379CE0BEEF9807A6C915FE560B7A1092ED2C9C81969281F6F3AAC93696D274A8FB54928D6ACB41CCFBB22EDAE6B8C844967DFE8057007772594FA99D878A16E8CF8963E0AA44FA6F077F0F4F2C8816A39DABEBEC2DDE, CAST(N'2021-04-07T19:16:42.5695401+00:00' AS DateTimeOffset), CAST(N'2021-04-07T19:16:42.5723246+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserAccesses] ([Id], [UserId], [Username], [Password], [Salt], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'A3600863-BD87-49E9-8FE3-AE3F557DEB72', 10002, N'restapiuser', 0xE2ABDFCFEDCF12F6E83309754BBE4135A4617AA9378E9016A058DE7C6B97AB1C273CA364CDA797B8D707F9EFF9F74E604A225D4006A69FA941BAE8177E4EAF95, 0xD719818776ED4CF3ED7F5732458A664F877AE685E78A0BF431A5DD6089941D70B9D0AADCF8C9A08D4F23746E59D5FF207A4C4741D317F389A82A40ADD181253888FEEB3177EA2B669EB213C325537FC1AE639BB5C5E194F6D15A4642E4CA89E7D94FA02B201CAC17CAEE36F11D586417C55D80E0CBCF0F0171AFB4957E8C1A253D2F3DC638C61EBA5D8ECFC593B30FE6DC8DEEFA5D0832DF9DC8C8DFEFA4C034125E92BE81274725AEBC672FB5F3590EAFF349823A5E130CE92A5BCA65DC4FC8AB6D2752D9E2D8172446CD85732EFAEBC7208D1978818A7A2C782947F6504EB8CF439CC5018C04AADA9B384A38579A719A4581F4D1B0AADBCA667CCDA2DA411F, CAST(N'2021-04-08T14:30:41.8636170+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:30:41.8674636+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserAccesses] ([Id], [UserId], [Username], [Password], [Salt], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'54BBD5E2-7C65-4BB5-A95B-C29FB462B4F9', 10003, N'restapiuser2', 0x4F587ECD865BBF86E58C9EECF76DA0531AE69A7016A445938D92678E23534A7AB1F6B48F175261185CCE8F32C9A2554A5A882142C3167C1ECB71DD2A97664728, 0xDAACF7681C22F8904FE1FA8DD958E8027FB2FD66EA3BA4AB6947839A10105B3FAA7F8EE2C885930BB9F46B875184D43ADED85AEFEB1DA679A64BF66C9E05A17DE53949916DDEE504D77A0485A9FEE088234A83609AFAD173356499FE46BF20268893EC2B8D5731FDA0269854FF233357CE29464C5E5C3D7CAE85354B2CBABEBC54AA49654EB32C4B573806D0EF97CAD0D694F693E5ED77776BCC59AE9094DD13B37AB20F5E93D4108AC758875633966CAF69E64C317C842C0A6FF7741D4C00800EA6924FC5B92DC56480A5FC88BD94EC3D3ACE72FBE2FA4A2CE56443A257DE67AADCDA7B13FEA2BF532928B7490F28F0EB8CF432A9EBF5FD0A5F5E0F62090B0C, CAST(N'2021-04-08T14:31:29.0264799+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:31:29.0295660+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserAvailabilities] ([UserId], [Online], [LoggedAt]) VALUES (1, 0, CAST(N'2021-02-22T18:45:03.9602124+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[UserAvailabilities] ([UserId], [Online], [LoggedAt]) VALUES (2, 0, CAST(N'2021-04-07T19:16:42.5779386+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[UserAvailabilities] ([UserId], [Online], [LoggedAt]) VALUES (10002, 0, CAST(N'2021-04-08T14:30:41.8711268+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[UserAvailabilities] ([UserId], [Online], [LoggedAt]) VALUES (10003, 0, CAST(N'2021-04-08T14:31:29.0348730+00:00' AS DateTimeOffset))
GO
INSERT [dbo].[UserIdentities] ([UserId], [IdentityTypeId], [Identity]) VALUES (1, 1, N'96170511852')
GO
INSERT [dbo].[UserIdentities] ([UserId], [IdentityTypeId], [Identity]) VALUES (2, 1, N'96170117012')
GO
INSERT [dbo].[UserIdentities] ([UserId], [IdentityTypeId], [Identity]) VALUES (10002, 1, N'96170117013')
GO
INSERT [dbo].[UserIdentities] ([UserId], [IdentityTypeId], [Identity]) VALUES (10003, 1, N'96170117014')
GO
INSERT [dbo].[UserProfilePictures] ([Id], [UserId], [Preview], [Data], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'5D8108B2-EEC2-4759-999B-2790909535E8', 1, NULL, NULL, CAST(N'2021-02-22T18:45:03.8910580+00:00' AS DateTimeOffset), CAST(N'2021-02-22T18:45:03.9532318+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserProfilePictures] ([Id], [UserId], [Preview], [Data], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'605A3BBC-DA66-4A10-AD81-D7FDBEB1CB44', 2, NULL, NULL, CAST(N'2021-04-07T19:16:42.5723246+00:00' AS DateTimeOffset), CAST(N'2021-04-07T19:16:42.5764161+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserProfilePictures] ([Id], [UserId], [Preview], [Data], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'A3600863-BD87-49E9-8FE3-AE3F557DEB72', 10002, NULL, NULL, CAST(N'2021-04-08T14:30:41.8674636+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:30:41.8711268+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[UserProfilePictures] ([Id], [UserId], [Preview], [Data], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'54BBD5E2-7C65-4BB5-A95B-C29FB462B4F9', 10003, NULL, NULL, CAST(N'2021-04-08T14:31:29.0305668+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:31:29.0348730+00:00' AS DateTimeOffset), 0)
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

GO
INSERT [dbo].[Users] ([Id], [UserId], [Username], [Name], [CountryId], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'5D8108B2-EEC2-4759-999B-2790909535E8', 1, N'saharmerheb', NULL, N'LB', CAST(N'2021-02-22T18:45:03.2857365+00:00' AS DateTimeOffset), CAST(N'2021-02-22T18:45:03.7638916+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[Users] ([Id], [UserId], [Username], [Name], [CountryId], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'605A3BBC-DA66-4A10-AD81-D7FDBEB1CB44', 2, N'lamar', NULL, N'LB', CAST(N'2021-04-07T19:16:42.5641594+00:00' AS DateTimeOffset), CAST(N'2021-04-07T19:16:42.5695401+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[Users] ([Id], [UserId], [Username], [Name], [CountryId], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'A3600863-BD87-49E9-8FE3-AE3F557DEB72', 10002, N'restapiuser', NULL, N'LB', CAST(N'2021-04-08T14:30:41.8556489+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:30:41.8621178+00:00' AS DateTimeOffset), 0)
GO
INSERT [dbo].[Users] ([Id], [UserId], [Username], [Name], [CountryId], [CreatedAt], [UpdatedAt], [Deleted]) VALUES (N'54BBD5E2-7C65-4BB5-A95B-C29FB462B4F9', 10003, N'restapiuser2', NULL, N'LB', CAST(N'2021-04-08T14:31:29.0210789+00:00' AS DateTimeOffset), CAST(N'2021-04-08T14:31:29.0264799+00:00' AS DateTimeOffset), 0)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
INSERT [dbo].[UserSynchronizeLog] ([UserId], [InProcess], [Data], [StartedAt], [EndedAt]) VALUES (1, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[UserSynchronizeLog] ([UserId], [InProcess], [Data], [StartedAt], [EndedAt]) VALUES (2, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[UserSynchronizeLog] ([UserId], [InProcess], [Data], [StartedAt], [EndedAt]) VALUES (10002, 0, NULL, NULL, NULL)
GO
INSERT [dbo].[UserSynchronizeLog] ([UserId], [InProcess], [Data], [StartedAt], [EndedAt]) VALUES (10003, 0, NULL, NULL, NULL)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.GroupIcons]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[GroupIcons] ADD  CONSTRAINT [PK_SUMU_Messenger.GroupIcons] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_SUMU_Messenger.GroupMembers]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[GroupMembers] ADD  CONSTRAINT [PK_SUMU_Messenger.GroupMembers] PRIMARY KEY NONCLUSTERED 
(
	[GroupId] ASC,
	[MemberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_SUMU_Messenger.GroupMembershipStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[GroupMembershipStatus] ADD  CONSTRAINT [PK_SUMU_Messenger.GroupMembershipStatus] PRIMARY KEY NONCLUSTERED 
(
	[GroupMembershipStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.Groups]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Groups] ADD  CONSTRAINT [PK_SUMU_Messenger.Groups] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Groups__149AF36B185BBCAD]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Groups] ADD UNIQUE NONCLUSTERED 
(
	[GroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.Notifications]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Notifications] ADD  CONSTRAINT [PK_SUMU_Messenger.Notifications] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_SUMU_Messenger.NotificationStatus]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[NotificationStatus] ADD  CONSTRAINT [PK_SUMU_Messenger.NotificationStatus] PRIMARY KEY NONCLUSTERED 
(
	[NotificationStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_SUMU_Messenger.NotificationTypes]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[NotificationTypes] ADD  CONSTRAINT [PK_SUMU_Messenger.NotificationTypes] PRIMARY KEY NONCLUSTERED 
(
	[NotificationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_dbo.PreUserIdentity]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[PreUserIdentity] ADD  CONSTRAINT [PK_dbo.PreUserIdentity] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ__PreUserI__4FE6746F830BDAA9]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[PreUserIdentity] ADD UNIQUE NONCLUSTERED 
(
	[PreUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Template__1D2A534CEB38EC6B]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Template] ADD UNIQUE NONCLUSTERED 
(
	[Subject] ASC,
	[Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.TracingLogs]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[TracingLogs] ADD  CONSTRAINT [PK_SUMU_Messenger.TracingLogs] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.UserAccesses]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[UserAccesses] ADD  CONSTRAINT [PK_SUMU_Messenger.UserAccesses] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.UserContactInfos]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[UserContactInfos] ADD  CONSTRAINT [PK_SUMU_Messenger.UserContactInfos] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.UserContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[UserContacts] ADD  CONSTRAINT [PK_SUMU_Messenger.UserContacts] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.UserProfilePictures]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[UserProfilePictures] ADD  CONSTRAINT [PK_SUMU_Messenger.UserProfilePictures] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.UserPublicKeys]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[UserPublicKeys] ADD  CONSTRAINT [PK_SUMU_Messenger.UserPublicKeys] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_SUMU_Messenger.Users]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [PK_SUMU_Messenger.Users] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ__Users__1788CC4D4F65336C]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Users__536C85E43F90ADF1]    Script Date: 4/8/2021 6:03:59 PM ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupIcons] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[GroupIcons] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[GroupMembers] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[GroupMembers] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Groups] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[Groups] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[MediaChunksMapping] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[MediaChunksMapping] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[UserContactInfos] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserContactInfos] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[UserContacts] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserContacts] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[UserPublicKeys] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[UserPublicKeys] ADD  DEFAULT (sysutcdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ApplicationVersions]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.ApplicationVersions_SUMU_Messenger.DeviceTypes_DeviceTypeId] FOREIGN KEY([DeviceTypeId])
REFERENCES [dbo].[DeviceTypes] ([DeviceTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ApplicationVersions] CHECK CONSTRAINT [FK_SUMU_Messenger.ApplicationVersions_SUMU_Messenger.DeviceTypes_DeviceTypeId]
GO
ALTER TABLE [dbo].[DeviceTypes]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.DeviceTypes_SUMU_Messenger.PNSTypes_PNSTypeId] FOREIGN KEY([PNSTypeId])
REFERENCES [dbo].[PNSTypes] ([PNSTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DeviceTypes] CHECK CONSTRAINT [FK_SUMU_Messenger.DeviceTypes_SUMU_Messenger.PNSTypes_PNSTypeId]
GO
ALTER TABLE [dbo].[GroupIcons]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupIcons_SUMU_Messenger.Groups_Id] FOREIGN KEY([Id])
REFERENCES [dbo].[Groups] ([Id])
GO
ALTER TABLE [dbo].[GroupIcons] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupIcons_SUMU_Messenger.Groups_Id]
GO
ALTER TABLE [dbo].[GroupMembers]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupMembers_InvitedBy_SUMU_Messenger.User_UserId] FOREIGN KEY([InvitedBy])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[GroupMembers] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupMembers_InvitedBy_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[GroupMembers]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupMembers_MemberId_SUMU_Messenger.User_UserId] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[GroupMembers] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupMembers_MemberId_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[GroupMembers]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupMembers_RemovedBy_SUMU_Messenger.User_UserId] FOREIGN KEY([RemovedBy])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[GroupMembers] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupMembers_RemovedBy_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[GroupMembers]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupMembers_SUMU_Messenger.Group_GroupId] FOREIGN KEY([GroupId])
REFERENCES [dbo].[Groups] ([GroupId])
GO
ALTER TABLE [dbo].[GroupMembers] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupMembers_SUMU_Messenger.Group_GroupId]
GO
ALTER TABLE [dbo].[GroupMembers]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.GroupMembers_SUMU_Messenger.GroupMembershipStatus_GroupMembershipStatusId] FOREIGN KEY([GroupMembershipStatusId])
REFERENCES [dbo].[GroupMembershipStatus] ([GroupMembershipStatusId])
GO
ALTER TABLE [dbo].[GroupMembers] CHECK CONSTRAINT [FK_SUMU_Messenger.GroupMembers_SUMU_Messenger.GroupMembershipStatus_GroupMembershipStatusId]
GO
ALTER TABLE [dbo].[Groups]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.Group_SUMU_Messenger.User_UserId] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[Groups] CHECK CONSTRAINT [FK_SUMU_Messenger.Group_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[NotificationRecipients]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.NotificationRecipient_NotificationId_SUMU_Messenger.Notification_Id] FOREIGN KEY([NotificationId])
REFERENCES [dbo].[Notifications] ([Id])
GO
ALTER TABLE [dbo].[NotificationRecipients] CHECK CONSTRAINT [FK_SUMU_Messenger.NotificationRecipient_NotificationId_SUMU_Messenger.Notification_Id]
GO
ALTER TABLE [dbo].[NotificationRecipients]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.NotificationRecipient_RecipientId_SUMU_Messenger.User_UserId] FOREIGN KEY([RecipientId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[NotificationRecipients] CHECK CONSTRAINT [FK_SUMU_Messenger.NotificationRecipient_RecipientId_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[NotificationRecipients]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.NotificationRecipients_SUMU_Messenger.NotificationStatus_NotificationStatusId] FOREIGN KEY([NotificationStatusId])
REFERENCES [dbo].[NotificationStatus] ([NotificationStatusId])
GO
ALTER TABLE [dbo].[NotificationRecipients] CHECK CONSTRAINT [FK_SUMU_Messenger.NotificationRecipients_SUMU_Messenger.NotificationStatus_NotificationStatusId]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.Notifications_SUMU_Messenger.Group_GroupId] FOREIGN KEY([GroupId])
REFERENCES [dbo].[Groups] ([GroupId])
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_SUMU_Messenger.Notifications_SUMU_Messenger.Group_GroupId]
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.Notifications_SUMU_Messenger.NotificationTypes_NotificationTypeId] FOREIGN KEY([NotificationTypeId])
REFERENCES [dbo].[NotificationTypes] ([NotificationTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_SUMU_Messenger.Notifications_SUMU_Messenger.NotificationTypes_NotificationTypeId]
GO
ALTER TABLE [dbo].[PreUser]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PreUser_dbo.Country_Id] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([Id])
GO
ALTER TABLE [dbo].[PreUser] CHECK CONSTRAINT [FK_dbo.PreUser_dbo.Country_Id]
GO
ALTER TABLE [dbo].[PreUser]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PreUser_dbo.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[PreUser] CHECK CONSTRAINT [FK_dbo.PreUser_dbo.User_UserId]
GO
ALTER TABLE [dbo].[PreUserIdentity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PreUserIdentity_dbo.IdentityType_Id] FOREIGN KEY([IdentityTypeId])
REFERENCES [dbo].[IdentityType] ([Id])
GO
ALTER TABLE [dbo].[PreUserIdentity] CHECK CONSTRAINT [FK_dbo.PreUserIdentity_dbo.IdentityType_Id]
GO
ALTER TABLE [dbo].[PreUserIdentity]  WITH CHECK ADD  CONSTRAINT [FK_dbo.PreUserIdentity_dbo.PreUser_Id] FOREIGN KEY([PreUserId])
REFERENCES [dbo].[PreUser] ([Id])
GO
ALTER TABLE [dbo].[PreUserIdentity] CHECK CONSTRAINT [FK_dbo.PreUserIdentity_dbo.PreUser_Id]
GO
ALTER TABLE [dbo].[Template]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.Template_SUMU_Messenger.IdentityType_Id] FOREIGN KEY([Type])
REFERENCES [dbo].[IdentityType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Template] CHECK CONSTRAINT [FK_SUMU_Messenger.Template_SUMU_Messenger.IdentityType_Id]
GO
ALTER TABLE [dbo].[UserAccesses]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserAccess_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserAccesses] CHECK CONSTRAINT [FK_SUMU_Messenger.UserAccess_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserAccesses]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserAccess_SUMU_Messenger.User_Username] FOREIGN KEY([Username])
REFERENCES [dbo].[Users] ([Username])
GO
ALTER TABLE [dbo].[UserAccesses] CHECK CONSTRAINT [FK_SUMU_Messenger.UserAccess_SUMU_Messenger.User_Username]
GO
ALTER TABLE [dbo].[UserAccesses]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserAccesses_SUMU_Messenger.Users_Id] FOREIGN KEY([Id])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserAccesses] CHECK CONSTRAINT [FK_SUMU_Messenger.UserAccesses_SUMU_Messenger.Users_Id]
GO
ALTER TABLE [dbo].[UserAvailabilities]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserAvailability_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserAvailabilities] CHECK CONSTRAINT [FK_SUMU_Messenger.UserAvailability_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserContactInfos]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserContactInfos_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserContactInfos] CHECK CONSTRAINT [FK_SUMU_Messenger.UserContactInfos_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserContacts]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserContact_ContactUserId_SUMU_Messenger.User_UserId] FOREIGN KEY([ContactUserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserContacts] CHECK CONSTRAINT [FK_SUMU_Messenger.UserContact_ContactUserId_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserContacts]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserContact_SUMU_Messenger.IdentityType_Id] FOREIGN KEY([IdentityTypeId])
REFERENCES [dbo].[IdentityType] ([Id])
GO
ALTER TABLE [dbo].[UserContacts] CHECK CONSTRAINT [FK_SUMU_Messenger.UserContact_SUMU_Messenger.IdentityType_Id]
GO
ALTER TABLE [dbo].[UserContacts]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserContact_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserContacts] CHECK CONSTRAINT [FK_SUMU_Messenger.UserContact_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserIdentities]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserIdentity_SUMU_Messenger.IdentityType_Id] FOREIGN KEY([IdentityTypeId])
REFERENCES [dbo].[IdentityType] ([Id])
GO
ALTER TABLE [dbo].[UserIdentities] CHECK CONSTRAINT [FK_SUMU_Messenger.UserIdentity_SUMU_Messenger.IdentityType_Id]
GO
ALTER TABLE [dbo].[UserIdentities]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserIdentity_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserIdentities] CHECK CONSTRAINT [FK_SUMU_Messenger.UserIdentity_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserProfilePictures]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserProfilePictures_SUMU_Messenger.Users_Id] FOREIGN KEY([Id])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserProfilePictures] CHECK CONSTRAINT [FK_SUMU_Messenger.UserProfilePictures_SUMU_Messenger.Users_Id]
GO
ALTER TABLE [dbo].[UserProfilePictures]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserProfilePictures_SUMU_Messenger.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserProfilePictures] CHECK CONSTRAINT [FK_SUMU_Messenger.UserProfilePictures_SUMU_Messenger.Users_UserId]
GO
ALTER TABLE [dbo].[UserPublicKeys]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserPublicKeys_SUMU_Messenger.Users_Id] FOREIGN KEY([Id])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserPublicKeys] CHECK CONSTRAINT [FK_SUMU_Messenger.UserPublicKeys_SUMU_Messenger.Users_Id]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.Users_SUMU_Messenger.Country_Id] FOREIGN KEY([CountryId])
REFERENCES [dbo].[Country] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_SUMU_Messenger.Users_SUMU_Messenger.Country_Id]
GO
ALTER TABLE [dbo].[UserSessions]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserSessions_SUMU_Messenger.ApplicationVersions_ApplicationVersionId_DeviceTypeId] FOREIGN KEY([ApplicationVersionId], [DeviceTypeId])
REFERENCES [dbo].[ApplicationVersions] ([ApplicationVersionId], [DeviceTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserSessions] CHECK CONSTRAINT [FK_SUMU_Messenger.UserSessions_SUMU_Messenger.ApplicationVersions_ApplicationVersionId_DeviceTypeId]
GO
ALTER TABLE [dbo].[UserSessions]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserSessions_SUMU_Messenger.User_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserSessions] CHECK CONSTRAINT [FK_SUMU_Messenger.UserSessions_SUMU_Messenger.User_UserId]
GO
ALTER TABLE [dbo].[UserSynchronizeLog]  WITH CHECK ADD  CONSTRAINT [FK_SUMU_Messenger.UserSynchronizeLog_SUMU_Messenger.Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([UserId])
GO
ALTER TABLE [dbo].[UserSynchronizeLog] CHECK CONSTRAINT [FK_SUMU_Messenger.UserSynchronizeLog_SUMU_Messenger.Users_UserId]
GO
/****** Object:  StoredProcedure [dbo].[AuthenticateByIdentity]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AuthenticateByIdentity] @Identity nvarchar(100), @error nvarchar(200) out 
as
begin
	declare @transactionType nvarchar(50)='ResetPassword'
	declare @template nvarchar(max)
	declare @userId bigint
	declare @identityTypeId int
	declare @Id nvarchar(128)
	declare @preUserId bigint
 	declare @ValidationCode nvarchar(10)
	declare @Token nvarchar(128)=NewId()
	declare @immediate bit = 1
	declare @name nvarchar(50)
	declare @username nvarchar(20)
	Select @identityTypeId = IdentityTypeId, @userId = UserId from [userIdentities] where [identity]=@Identity
	if(@@rowcount=0)
	begin
		Set @error = 'InvalidIdentity'
		Return
	end

	Select @Id = Id,@name=Name,@username=Username from [users] where userId=@userId
	Set @preUserId = dbo.GetPreUserIdByUserId(@Id)
	Set @ValidationCode = dbo.GenerateMobileValidationCode(6)
	
	insert into [preUserIdentity]([IdentityTypeId], [PreUserId], Id, [Identity], ValidationCode, ExpiresAt,TransactionType)
	values (@identityTypeId, @preUserId, @Token, @Identity, @ValidationCode, DATEADD(MINUTE,15,GETUTCDATE()),@transactionType)
	exec dbo.loadtemplate @identityTypeId, 'ForgotPassword', @template out, @Token, @ValidationCode, @Identity,@username,@name

	Select @identityTypeId as TypeId,@Identity as [Identity], @Token as Token, @ValidationCode as [Validation], @immediate as [Immediate], @template as Template

end



GO
/****** Object:  StoredProcedure [dbo].[CleanUpGroups]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[CleanUpGroups] @userId bigint
as
begin
	Delete from GroupMembers where MemberId=@userId
	declare @sysUserId bigint = [dbo].[CONST_SystemUserInternalId]()
	update GroupMembers set RemovedBy = @sysUserId where RemovedBy=@userId
	update GroupMembers set InvitedBy = @sysUserId where InvitedBy=@userId
	update Groups set CreatedBy = @sysUserId where CreatedBy=@userId	
end



GO
/****** Object:  StoredProcedure [dbo].[CleanUpNotifications]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[CleanUpNotifications]
as
begin
declare @delivered int=2
declare @recalled int=3
declare @read int=4

declare @toDelete table (id nvarchar(128), recipientId bigint, deliveredAt datetimeoffset, readAt datetimeoffset, ischat bit)
insert into @toDelete (id, recipientId, deliveredAt, readAt, ischat)
select n.id,r.RecipientId, r.DeliveredAt,r.ReadAt,ischat from notifications n join notificationrecipients r on r.notificationId=n.id join notificationTypes t on t.notificationTypeId=n.notificationTypeId
where 
(n.GroupId is null and (
(t.isChat = 1 and (r.notificationStatusId in (@recalled, @read) or (expiresAt is not null and dateadd(second, cast(expiresAt as int), n.createdat) < getutcdate())))
--(t.isChat = 1 and (r.notificationStatusId in (@recalled, @read)) )
or
(t.isChat = 0 and r.notificationStatusId in (@delivered, @read))
))
or
(n.GroupId is not null and (
(t.isChat = 1 and ((dbo.Group_NotificationRemainigRecipientsCountByStatus(n.id,@recalled,-1)=0 or (expiresAt is not null and dateadd(second, cast(expiresAt as int), n.createdat) < getutcdate()))))
or
(t.isChat = 0 and dbo.Group_NotificationRemainigRecipientsCountByStatus(n.id,@delivered,-1)=0)
))

insert into NotificationTracking(NotificationId, UserId, DeliveredAt, ReadAt)
select d.id, u.id, deliveredAt, readAt from @toDelete d join users u on u.UserId=d.recipientId where ischat=1

delete r from notificationRecipients r join @toDelete d on d.id=r.notificationId
delete n from notifications n join @toDelete d on d.id=n.id


insert into tracinglogs ([level],category,request)
select 'ScheduledJob','CleanUpNotifications',count(*) from @toDelete
end





GO
/****** Object:  StoredProcedure [dbo].[CleanUpUserContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[CleanUpUserContacts] @userId bigint, @DataType nvarchar(25)
as
begin
if( @datatype='Identity')
begin
	DELETE dbo.usercontacts
	FROM dbo.usercontacts
	LEFT OUTER JOIN (
		SELECT min(id) as RowId, LocalId, OriginalIdentity, IdentityTypeId
		FROM dbo.usercontacts where userid=@userid
		GROUP BY LocalId, OriginalIdentity, IdentityTypeId
	) as KeepRows ON
	dbo.usercontacts.id = KeepRows.RowId
	WHERE KeepRows.RowId IS NULL and userid=@userid
end
else if( @datatype='Info')
begin
	DELETE dbo.usercontactinfos
	FROM dbo.usercontactinfos
	LEFT OUTER JOIN (
		SELECT max(id) as RowId, LocalId, Info, InfoTypeId
		FROM dbo.usercontactinfos where userid=@userid
		GROUP BY LocalId, Info, InfoTypeId
	) as KeepRows ON
	dbo.usercontactinfos.id = KeepRows.RowId
	WHERE KeepRows.RowId IS NULL and userid=@userid
end
end





GO
/****** Object:  StoredProcedure [dbo].[ClearUserContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[ClearUserContacts] @userId bigint
as
begin

	DELETE usercontacts
	FROM usercontacts
	WHERE userid=@userid

	DELETE usercontactinfos
	FROM usercontactinfos
	WHERE userid=@userid
end




GO
/****** Object:  StoredProcedure [dbo].[ConfirmRead]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ConfirmRead] @userId bigint, @Id nvarchar(128), @markAllPrevious bit, 
@NotificationId nvarchar(128) out, @SenderId nvarchar(128) out
as begin
Set @NotificationId = ''
set @SenderId = ''
declare @CONST_PendingStatusId int = 1
declare @CONST_ReadStatusId int = 4
declare @CONST_MessageRead int= 9
declare @SenderInternalId bigint

declare @CONST_DeliveredStatusId int = 2
declare @issuedAt datetimeoffset

Begin Transaction
update r
set r.NotificationStatusId = @CONST_ReadStatusId,
@SenderInternalId = n.SenderId, @issuedAt =n.CreatedAt
from [NotificationRecipients] r join [Notifications] n
on n.id=r.NotificationId
where n.Id=@id and r.RecipientId=@userId
and r.NotificationStatusId != @CONST_ReadStatusId
if(@@ROWCOUNT=0)
begin
	commit
	return
end

if(@markAllPrevious=1)
begin
	update r
	set r.NotificationStatusId = @CONST_ReadStatusId
	from [NotificationRecipients] r join [Notifications] n
	on n.id=r.NotificationId
	where n.CreatedAt<@issuedAt and r.RecipientId=@userId and r.NotificationStatusId = @CONST_DeliveredStatusId
end

Set @NotificationId = newid()

insert into [Notifications](id,[SenderId], [NotificationTypeId],[Message],Deleted)
values (@NotificationId, @userId, @CONST_MessageRead,@Id, 0)
if(@@error<>0)
begin
	Rollback
	Set @NotificationId = ''
	set @SenderId = ''
	return
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
values (@NotificationId,@SenderInternalId, @CONST_PendingStatusId)
if(@@error<>0)
begin
	Rollback
	Set @NotificationId = ''
	set @SenderId = ''
	return
end
select @SenderId = id from users where UserId=@SenderInternalId

commit
end







GO
/****** Object:  StoredProcedure [dbo].[Deactivate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Deactivate] @user_Id nvarchar(128), @updateId nvarchar(128) out, @error nvarchar(500) out
as
begin
	declare @userId bigint
	Select @userId =userid from users where id=@user_Id
	declare @CONST_NotificationLeft int = 25
	Declare @Followers table (Id nvarchar(128), userId bigint)
	declare @resultingUpdates table (id nvarchar(128))
		
	insert into @Followers(Id, userId)
	Select Id, userId From [dbo].[GetFollowers](@userId, null)
	
	begin transaction
	Set @updateId = newid()
	insert into @resultingUpdates(id) values(@updateId)

	insert into Notifications(Id,SenderId, NotificationTypeId, [Message], Deleted)
	Values(@updateId, [dbo].[CONST_SystemUserInternalId](), @CONST_NotificationLeft, @user_Id, 0)
	if(@@Error<>0)
		return
	
	insert into NotificationRecipients(NotificationId, RecipientId, NotificationStatusId)
	Select @updateId, F.userId, 1 from @followers F
	if(@@Error<>0)
	Begin
		Rollback
		Return
	End
/*----------------------------------------------------------------Generate Group Related Updates--------------------------------------------------------------------------------------*/
	declare @action int
	declare @CONST_GroupMemberLeft int=21
	declare @CONST_GroupInvitationRejected int=19
	declare @group_id nvarchar(128)
	declare @leftGroupUpdateId nvarchar(128)
	declare @newAdminId nvarchar(128)
	declare @newAdminUpdateId nvarchar(128)
	declare @errorMessage nvarchar(max)
	declare @involvedGroups table (group_id nvarchar(128), membershipStatus int)
	insert into @involvedGroups(group_id, membershipStatus)
	select g.id, m.GroupMembershipStatusId from Groups G join GroupMembers M on G.GroupId=M.GroupId Where M.MemberId=@userId and M.GroupMembershipStatusId in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus())
	while((select count(*) from @involvedgroups)>0)
	begin
		set @leftGroupUpdateId = ''
		select top(1) @group_id=group_id, @action = case when membershipStatus = dbo.CONST_PendingMembershipStatus() then @CONST_GroupInvitationRejected else @CONST_GroupMemberLeft end from @involvedGroups

		exec [dbo].[System_Group_MemberAction] @user_Id, @group_id, @action out, @leftGroupUpdateId out, @newAdminId out, @newAdminUpdateId out, @errorMessage out
		if(@@Error<>0)
		Begin
			Rollback
			Return
		End
		if(len(isnull(@leftGroupUpdateId,''))>0) insert into @resultingUpdates(id) values(@leftGroupUpdateId)
		if(len(isnull(@newAdminUpdateId,''))>0) insert into @resultingUpdates(id) values(@newAdminUpdateId)

		delete from @involvedGroups where group_id=@group_id
	end
/*----------------------------------------------------------------Generate Group Related Updates--------------------------------------------------------------------------------------*/

	exec [dbo].[System_CancelQueuedInvitationByMotivationUser] @userId
	if(@@ERROR<>0)
	begin
		rollback
		return
	end
	exec [dbo].DeleteUser @userId
	if(@@ERROR<>0)
	begin
		--update notificationrecipients set notificationstatusid=3 where NotificationId=@updateId
		update notificationrecipients set notificationstatusid=3 where NotificationId in (select id from @resultingUpdates)
		rollback
		return
	end

	commit
	Select Id from @Followers
end



GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DeleteUser] @userId bigint
as
begin
	begin transaction
	declare @id nvarchar(128)
	select @id = id from dbo.users where userid=@userid
	delete from dbo.usersynchronizelog where userid=@userid
	if(@@error<>0)
	begin
		return
	end
	delete from dbo.NotificationRecipients where recipientid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.NotificationRecipients where notificationid in (select id from  dbo.Notifications where senderid=@userid)
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.Notifications where senderid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserAccesses where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserAvailabilities where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserContactInfos where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserContacts where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	update dbo.UserContacts set ContactUserId=null where ContactUserId=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.PreUserIdentity where PreUserId=(select id from dbo.PreUser where userid=@userid)
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.PreUser where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserIdentities where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserProfilePictures where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.UserSessions where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	exec dbo.CleanUpGroups @userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.userpublickeys where id=@id
	if(@@error<>0)
	begin
		rollback 
		return
	end
	delete from dbo.Users where userid=@userid
	if(@@error<>0)
	begin
		rollback 
		return
	end
	commit
end





GO
/****** Object:  StoredProcedure [dbo].[Diagnostic_User]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[Diagnostic_User] @userid bigint=null, @username nvarchar(50)=null
as
begin
if(@userid is null)
	Select @userid=userid from users where username=@username
select * from users u join useridentities on u.userid=useridentities.userid where u.userid=@userid
select top(1) * from usersessions where userid=@userid order by loggedat desc
exec dbo.getpendingchat @userid
end




GO
/****** Object:  StoredProcedure [dbo].[DoCreateAccount]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DoCreateAccount] 
@Username nvarchar(20), @Password varbinary(max), @PasswordSalt varbinary(max),
@CountryId nvarchar(2), @IdentityTypeId int, @identity nvarchar(100), @userid bigint out,
@Error nvarchar(255) out, @redirect nvarchar(100) out
As
Begin
declare @erronousIdentityType int = -1
/*second round check, other users might used the username before the validation process is completed*/
if(exists (select 1 from [users] where username=@username))
	Set @erronousIdentityType = 0
else if(exists (select 1 from [UserIdentities] where [identity]=@identity))
	Set @erronousIdentityType = @IdentityTypeId

if(@erronousIdentityType <> -1)
begin
	exec [dbo].[IdentityErrorHandling] 'NotAvailable', @erronousIdentityType, @error out, @redirect out
	return
end

Begin Transaction
Declare @Id nvarchar(128) = newid()

insert into [Users](id,username, CountryId, Deleted)
values (@Id, @Username, @CountryId,0)
if(@@error<>0)
begin	
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [Users]'
	return
end
Set @UserId = SCOPE_IDENTITY()
insert into [UserIdentities](userid,[identitytypeid], [identity])
values (@UserId, @IdentityTypeId, @identity)
if(@@error<>0)
begin
	Rollback
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [UserIdentities]'
	return
end

insert into [UserAccesses](id,userid,username, [password], Salt,Deleted)
values (@id, @UserId, @username, @Password, @PasswordSalt,0)
if(@@error<>0)
begin
	Rollback
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [UserAccesses]'
	return
end
insert into [UserProfilePictures](id,userid,Deleted)
values (@id, @UserID,0)
if(@@error<>0)
begin
	Rollback
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [UserProfilePictures]'
	return
end
insert into [UserSynchronizeLog]([UserId])
values (@UserID)
if(@@error<>0)
begin
	Rollback
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [UserSynchronizeLog]'
	return
end
insert into [UserAvailabilities](userid,[Online],LoggedAt)
values (@UserId,0,sysutcdatetime())
if(@@error<>0)
begin
	Rollback
	Set @Error = 'System error, [DoCreateAccount]#INSERT INTO [UserAvailabilities]'
	return
end
Commit


End








GO
/****** Object:  StoredProcedure [dbo].[DoRegistration]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DoRegistration] 
@Username nvarchar(20), @Password varbinary(max), @PasswordSalt varbinary(max),
@CountryId nvarchar(2), @identitiesXML xml, @preUserId bigint out,
@Error nvarchar(255) out, @redirect nvarchar(100) out
As
Begin
--declare @transactionType nvarchar(50)='Validation'
--declare @bit as bit=0 ; declare @type as int
--Select @type as TypeId, '' as [Identity],  '' as Token,'' as  [Validation], @bit as [Immediate] 

Declare @IdentityValidation table(TypeId int, [Identity] nvarchar(100), Token nvarchar(128), [Validation] nvarchar(1024), [Immediate] bit, Template nvarchar(max))

/*checks to be performed primarly on client side*/
if(exists (select 1 from [UserAccesses] where username=@username)) 
begin
	exec [dbo].[IdentityErrorHandling] 'NotAvailable', 0, @error out, @redirect out
	goto theEnd
end



Begin Transaction

insert into [preUser](username, [password], Salt, countryId)
values (@username, @Password, @PasswordSalt, @countryId)
if(@@error<>0)
begin
	Set @Error = 'SystemError, DoRegistration#INSERT INTO preUser'
	goto theEnd
end

Set @preUserId = SCOPE_IDENTITY();

Declare @IdentityTypeId int
Declare @Identity nvarchar(100)
Declare @identitiesT table (typeId int, Value nvarchar(100))
insert into @identitiesT
select feed.x.value('TypeId[1]','int') as TypeId, 
	   feed.x.value('Value[1]','NVARCHAR(100)') as Value
from @identitiesXML.nodes('//Identities//Identity') feed(x)

while(select count(*) from @identitiesT)>0
begin
	select top(1) @IdentityTypeId = typeId, @Identity=Value from @identitiesT
	Insert into @IdentityValidation
	Exec [dbo].[DoValidationRequest] @IdentityTypeId, @preUserId, @Identity, @error out, @redirect out
	if(@error<>'')
	begin
		rollback
		goto theEnd
	end
	--if(@IdentityTypeId=2)
	--begin
	--	Select @redirect = Content from template where [Subject]=@transactionType
	--	Set @redirect = REPLACE(@redirect,'#Root#',dbo.CONST_GetValueByKey('Root'))
	--end
	delete from @identitiesT where typeid=@IdentityTypeId
end

Commit
theEnd:
Select TypeId, [Identity],  Token,  [Validation],  [Immediate], Template from @IdentityValidation
End



GO
/****** Object:  StoredProcedure [dbo].[DoValidation]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[DoValidation]
@Token nvarchar(128), @Code nvarchar(128), @userId bigint out, @user_id nvarchar(128) out,  @error nvarchar(255) out, @redirect nvarchar(max) out
as begin
declare @identityTypeId int
declare @identity nvarchar(100)
declare @actualCode nvarchar(128)
declare @preUserId bigint
declare @ExpiresAt datetimeoffset(7)
declare @CONST_Joined int = 5
declare @update nvarchar(1)
declare @updateId nvarchar(128)
declare @ContactJoinedUpdateRecipients table(Id nvarchar(128))
declare @notifications table(Id nvarchar(128), TypeId int, Recipients nvarchar(max))

Select @identityTypeId = identityTypeId, @actualCode = ValidationCode, @ExpiresAt = ExpiresAt from preUserIdentity Where id=@Token 
if(@@ROWCOUNT=0)
	set @error = 'TokenInvalid'
else if(@ExpiresAt < GETUTCDATE())
	set @error = 'CodeExpired'
else if(@actualCode <> @code)
	set @error = 'CodeInvalid'
else
	set @error =''

if(@error <> '')
begin
	exec [dbo].[IdentityErrorHandling] @error, @identityTypeId, @error out, @redirect out
	return
end
declare @TransactionType nvarchar(50)
update preUserIdentity set @identity=[identity], @preUserId = PreUserId, Validated=1, @TransactionType=TransactionType Where id=@Token 

Declare @Username nvarchar(20), @Password varbinary(max), @Salt varbinary(max), @CountryId nchar(2)
select @Username=Username, @Password=[Password], @Salt=Salt, @CountryId = CountryId, @userid = userid from preuser where Id=@preUserId
if(@userid is not null)
begin
	declare @oldIdentity nvarchar(100)
	Select @oldIdentity = [identity] from UserIdentities where userid=@userid and identityTypeId= @identitytypeid
	if(@@ROWCOUNT = 0)
	begin
		insert into UserIdentities(userId, identityTypeId,[identity]) values(@userid, @identityTypeId, @identity)
		update usercontacts set ContactUserId=@userid,updatedat=CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) where [identity]=@identity
	end
	else
	begin
		if(@TransactionType = 'ResetPassword')
		begin
			Select @redirect = Content from template where [Subject]=@TransactionType
			Set @redirect = REPLACE(@redirect,'#Username#',@username)
			Set @redirect = REPLACE(@redirect,'#Token#',@token)
			Set @redirect = REPLACE(@redirect,'#ResourceRoot#',dbo.CONST_GetValueByKey('ResourceRoot'))
			Set @redirect = REPLACE(@redirect,'#Website#',dbo.CONST_GetValueByKey('Website'))
			return 
		end
		else
		begin
		
			begin transaction
			Set @update = cast(@identityTypeId as nvarchar(1))
			declare @CONST_IdentityChanged int = 24
			declare @identityChangedUpdateRecipients table(Id nvarchar(128))

			insert into @identityChangedUpdateRecipients(Id)
			exec [dbo].[GenerateUpdate] '', @userId, @CONST_IdentityChanged, @update, @updateId out
			if(@@ERROR<>0)
			begin
				commit
				return
			end
			Insert into @notifications(Id, TypeId, Recipients)
			values (@updateId, @CONST_IdentityChanged, STUFF((Select N',' + cast([id] as nvarchar(128)) from @identityChangedUpdateRecipients for xml path(N'')),1,1,N''))
		
			update UserIdentities set  [identity]=@identity where  userid=@userid and identityTypeId= @identitytypeid and [identity]=@oldIdentity
			if(@@ERROR<>0)
			begin
				update notificationrecipients set notificationstatusid=3 where NotificationId=@updateId
				rollback
				return
			end
			commit
		end
	end
	goto GENERATE_JOIN_NOTIFICATION;
end
else
begin
	if(@identityTypeId=2)
	begin
		Select @redirect = Content from template where [Subject]='EmailValidation-Success'
		Set @redirect = REPLACE(@redirect,'#ResourceRoot#',dbo.CONST_GetValueByKey('ResourceRoot'))
		Set @redirect = REPLACE(@redirect,'#Website#',dbo.CONST_GetValueByKey('Website'))
		print @redirect
	end
end
declare @ignore nvarchar(255)
exec [dbo].[DoCreateAccount]  @Username, @Password, @Salt, @CountryId,@identityTypeId, @identity, @userid out, @error out, @ignore out
if(@error='')
begin
	update preuser set userid=@userid where id=@preUserId
	update usercontacts set ContactUserId=@userid, updatedat=CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) where [identity]=@identity
end
else
begin
	set @redirect = ''
end

GENERATE_JOIN_NOTIFICATION:
insert into @ContactJoinedUpdateRecipients(Id)
exec [dbo].[GenerateUpdate] '', @userId, @CONST_Joined, @update, @updateId out
if(@@ERROR<>0)
begin
	return
end
--exec [dbo].System_CancelQueuedInvitationByRecipient @identitytypeid, @identity

Insert into @notifications(Id, TypeId, Recipients)
values (@updateId, @CONST_Joined, STUFF((Select N',' + cast([id] as nvarchar(128)) from @ContactJoinedUpdateRecipients for xml path(N'')),1,1,N''))
Select @user_id=id from users where UserId=@userId
Select * From @notifications

end



GO
/****** Object:  StoredProcedure [dbo].[DoValidationRequest]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[DoValidationRequest]@IdentityType int, @preUserId bigint, @Identity nvarchar(100), @error nvarchar(255) out, @redirect nvarchar(100) out
as begin


declare @explicitCodeLength int =6
declare @transactionType nvarchar(50)='Validation'
Declare @immediate bit
Declare @ValidForMinutes int
Declare @ValidationCode nvarchar(128)
declare @Token nvarchar(128), @Validation nvarchar(1024)
Declare @template nvarchar(max)

if(exists (select 1 from [userIdentities] where [identity]=@Identity) )
begin
	exec [dbo].[IdentityErrorHandling] 'NotAvailable', @IdentityType, @error out, @redirect out
	return
end
select @immediate = immediateVerification, @ValidForMinutes = CodeValidForMinutes, @ValidationCode = case when CodeLength=128 then convert(nvarchar(128), NewID()) else dbo.[GenerateMobileValidationCode](CodeLength) end  
from [IdentityType] where id=@IdentityType

Set @Token = NEWID()
if([dbo].[CheckIfRegisteredByPreUserId](@preUserId) = 1)
begin
	set @transactionType = @transactionType + '-Explicit'
	set @ValidationCode = dbo.[GenerateMobileValidationCode](@explicitCodeLength)
	set @immediate = 1
end
insert into [preUserIdentity]([IdentityTypeId], [PreUserId], Id, [Identity], ValidationCode, ExpiresAt)
values (@IdentityType, @preUserId, @Token, @Identity, @ValidationCode, DATEADD(MINUTE,@ValidForMinutes,GETUTCDATE()))

Set @Validation = @ValidationCode
exec dbo.loadtemplate @IdentityType, @transactionType, @template out, @Token, @ValidationCode, @Identity,'',''
Select @IdentityType as TypeId,@Identity as [Identity], @Token as Token, @Validation as [Validation], @immediate as [Immediate], @template as [Template]

end


GO
/****** Object:  StoredProcedure [dbo].[ForgotPassword]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ForgotPassword]
@Token nvarchar(128), @Password varbinary(max), @Salt varbinary(max), @redirect nvarchar(max) out, @error nvarchar(255) out
as begin

declare @userid bigint
declare @preUserId bigint

select @preUserId = PreUserId from preUserIdentity Where id=@Token and Validated=1
if(@@ROWCOUNT=0)
begin
	set @error = 'TokenInvalid'
	return
end

Select @userid = userid from preUser where Id=@preuserid

Update UserAccesses Set [Password]=@Password, Salt=@Salt  where userId=@userId
Select @redirect = Content from template where [Subject]='ResetPassword-Success'
Set @redirect = REPLACE(@redirect,'#ResourceRoot#',dbo.CONST_GetValueByKey('ResourceRoot'))
Set @redirect = REPLACE(@redirect,'#Website#',dbo.CONST_GetValueByKey('Website'))
end



GO
/****** Object:  StoredProcedure [dbo].[GenerateUpdate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GenerateUpdate] @Id nvarchar(128), @userId bigint=0, @updateTypeId int, @update nvarchar(1024), @updateId nvarchar(128) out
as
begin
	declare @CONST_Joined int = 5
	declare @CONST_IdentityChanged int = 24
	Declare @Followers table (Id nvarchar(128), userId bigint)

	if(@userId=0)
		Select @UserId = UserId from Users where Id=@Id
	
	declare @identityTypeId int
	if(@updateTypeId in (@CONST_Joined,@CONST_IdentityChanged))
	begin
		if(len(isnull(@update,''))>0)
			Set @identityTypeId = cast(@update as int)
		Set @update = ''
	end

	insert into @Followers(Id, userId)
	Select Id, userId From [dbo].[GetFollowers](@userId, @identityTypeId)
	
	begin transaction
	Set @updateId = newid()
	insert into Notifications(Id,SenderId, NotificationTypeId, [Message], Deleted)
	Values(@updateId, @userId, @updateTypeId, @update, 0)

	print @updateId
	insert into NotificationRecipients(NotificationId, RecipientId, NotificationStatusId)
	Select @updateId, F.userId, 1 from @followers F
	if(@@Error<>0)
	Begin
		Rollback
		Return
	End
	commit
	Select Id from @Followers
end






GO
/****** Object:  StoredProcedure [dbo].[GenericNotification]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GenericNotification] @delay int, @SenderId bigint, 
@recipient_users nvarchar(max), @recipient_groups nvarchar(max),
@LocalMessageId nvarchar(100), @NotificationTypeId int, @NotificationContent nvarchar(2048), @ExpiresAt nvarchar(50), @FileSizeInBytes bigint, @Duration int, @IsScrambled bit,
@IssuedAt datetimeoffset out, @AlreadyReceived bit out, @SenderHasPendingNotifications bit out
as begin
Set @IsScrambled = isnull(@IsScrambled,0)
declare @CONST_PendingStatusId int = 1
declare @CONST_DelayedStatusId int = 0
declare @StartingStatusId int = case when @delay=0 then @CONST_PendingStatusId else @CONST_DelayedStatusId end

declare @Groups table (group_id nvarchar(128), groupId bigint)
declare @Recipients table ([User_Id] nvarchar(128), UserId bigint)
declare @Notifications table (Id nvarchar(128), Group_Id nvarchar(128), GroupSubject nvarchar(25), Recipients nvarchar(max))
declare @NotificationId nvarchar(128)

Set @SenderHasPendingNotifications = case when exists (Select 1 from [NotificationRecipients] R join [Notifications] N on R.NotificationId=N.Id
Where R.RecipientId=@SenderId And R.NotificationStatusId = @CONST_PendingStatusId And N.CreatedAt < DATEADD(SECOND,2,SYSDATETIMEOFFSET()))  
then 1 else 0 end

SELECT top(1) @AlreadyReceived = 1, @NotificationId=[Id],@issuedAt=CreatedAt
FROM [Notifications] Where [LocalId] = @LocalMessageId and [SenderId] = @SenderId
if(@@ROWCOUNT>0)
begin
	insert into @Notifications(id) values	(@NotificationId)
	goto theEnd	
end

insert into @Recipients([User_Id], userId)
select items,userid from dbo.Split( @recipient_users,',') data join [users] u on u.id=data.items where u.userId<>@SenderId
if(@@RowCount>0)
begin
	insert into @groups (group_id, groupId) values (null,-1)
end

insert into @Groups(group_id, groupId)
select distinct data.items,groupid from dbo.Split(@recipient_Groups, ',') data join [groups] g on g.id=data.items

declare @groupId bigint
declare @group_Id nvarchar(128)

declare @members table ([user_id] nvarchar(128), userId bigint)
set @IssuedAt = DATEADD(second,@delay,sysutcdatetime())

Begin Transaction
while(select count(*) from @groups)>0
begin

	Select top(1) @groupId=groupId, @group_id=group_id from @Groups
	if(@groupId = -1)
		insert into @members([user_id], userId) select [User_Id], UserId from @Recipients
	else
		insert into @members([user_id], userId) select [Id] , UserId from [dbo].[GetMembers] (@groupId)
	
	delete from @members where UserId=@SenderId
	if((select count(*) from @members)=0)
		goto NEXT_GROUP

	Set @AlreadyReceived = 0
	Set @NotificationId = newid()
	
	insert into [Notifications](id,[GroupId],[SenderId], [LocalId],[NotificationTypeId],[Message],[ExpiresAt],[SizeInBytes],[Duration],[IsScrambled], Deleted,/* [Delay],*/ createdat)
	values (@NotificationId,case when @groupId=-1 then null else @groupId end, @SenderId, @LocalMessageId,@NotificationTypeId,@NotificationContent,@ExpiresAt,@FileSizeInBytes,@Duration,@IsScrambled, 0,/*@Delay,*/@IssuedAt)
	if(@@error<>0)
	begin
		Rollback
		return
	end

	insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
	select @NotificationId, userId, @StartingStatusId from @Members
	if(@@error<>0)
	begin
		Rollback
		return
	end

	insert into @Notifications(Id)
	values(@NotificationId)
	if(@delay=0 )
	begin
		update n 
		set Group_Id=g.id,  GroupSubject=g.[subject], recipients=STUFF((Select N',' + cast([user_id] as nvarchar(128))+':'+ cast([userid] as nvarchar(25)) from @members for xml path(N'')),1,1,N'') 
		from @Notifications n left outer join groups g on g.GroupId=@groupid and n.Id=@NotificationId
	end

	NEXT_GROUP:
	delete from @Groups where groupId=@groupid
	delete from @members
end

commit
theEnd:
Select * from @Notifications
end




GO
/****** Object:  StoredProcedure [dbo].[GetPendingChat]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetPendingChat](@userId bigint)
as
begin
select g.Id as [Group], u.Id as Sender, n.Id, n.NotificationTypeId as [Type], 
case when n.[Message]='' then null else n.[Message] end as Content,case when n.SizeInBytes =0 then null else n.SizeInBytes end as SizeInBytes, n.CreatedAt as IssuedAt,
n.ExpiresAt, 
case when n.Duration =0 then null else n.Duration end as Duration,
n.IsScrambled
from dbo.NotificationRecipients r
join dbo.Notifications n on n.id=r.NotificationId
join dbo.users u on n.SenderId=u.UserId
left join dbo.groups g on n.GroupId=g.groupId
where r.NotificationStatusId = 1 --pending
and r.RecipientId=@userId
end




GO
/****** Object:  StoredProcedure [dbo].[GetPendingIdentity]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[GetPendingIdentity] (@Id nvarchar(128), @userId bigint=0, @VerifiedIentityTypeId int, @typeId int out, @value nvarchar(100) out)
as
begin
if(@userId=0)
	select @userID=userId from dbo.users where id=@id

select top(1) @typeId=[identityTypeId],@value=[identity] from
dbo.preuseridentity pending join dbo.preuser preuser on  pending.preUserId = preuser.id
where pending.identityTypeId<>@VerifiedIentityTypeId and preuser.userId=@userId
order by preuser.createdat desc
if(@@ROWCOUNT=0)
	set @typeId = -1
end




GO
/****** Object:  StoredProcedure [dbo].[GetPreSynchronizeInfo]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetPreSynchronizeInfo] @userId bigint, @startingDate datetimeoffset out
as
begin

select @startingDate=max(updatedat) from dbo.usercontacts where userid=@userid
if(@@rowcount=0 or @startingDate is null)
	set @startingDate = sysutcdatetime()

end



GO
/****** Object:  StoredProcedure [dbo].[GetUserById]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetUserById] @Id nvarchar(100)
as
begin
	select Id, Name, Username, CountryId, u.CreatedAt, IdentityTypeId,[Identity]
	from Users u join UserIdentities i on i.UserId=u.UserId 
	where u.Id=@Id
end

GO
/****** Object:  StoredProcedure [dbo].[GetUsers]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetUsers] @offset int =0, @limit int=10
as
begin
	select Id, Name, Username, CountryId, u.CreatedAt, IdentityTypeId,[Identity]
	from Users u join UserIdentities i on i.UserId=u.UserId 
	order by i.UserId
	offset @offset rows 
	fetch next @limit rows only
end

GO
/****** Object:  StoredProcedure [dbo].[Group_AddMembers]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Group_AddMembers] @user_Id nvarchar(128), @group_id nvarchar(128), @invitees nvarchar(max), @updateId nvarchar(128) out, @update nvarchar(100) out, @errorMessage nvarchar(max) out
as begin
	declare @CONST_NewGroupInvitationType int=15
	declare @isAdmin bit
	declare @userIsAdmin bit
	declare @userId bigint
	declare @groupId bigint	
	declare @newMembersCount int
	declare @currentMembersCount int	
	declare @CONST_pendingMembershipStatus int = dbo.CONST_PendingMembershipStatus()
	declare @invitations table (member_id nvarchar(128), memberId bigint, currentMembershipStatus int)
	declare @members table (id nvarchar(128), userId bigint)

	set @isAdmin = 0
	set @errorMessage = ''

	select @groupId = groupId, @currentMembersCount=membersCount, @update=[subject] from groups where id=@group_Id
	select @userId = userId, @userIsAdmin=isAdmin from users u join GroupMembers m on u.UserId=m.MemberId where u.Id=@user_Id and m.GroupId=@groupId and GroupMembershipStatusId =dbo.CONST_ActiveMembershipStatus()
	if(@userIsAdmin is null or @userIsAdmin = 0)
	begin
		set @errorMessage = 'UserIsNotAdmin'
		return
	end

	insert into @invitations(member_id, memberId)
	select distinct id, UserId from dbo.split(@invitees, ',') as invitees join dbo.users u on u.id=invitees.items

	delete from @invitations where member_id=@user_Id

	Select @newMembersCount = count(*) from @invitations
	if(@newMembersCount = 0)
	begin
		Set @errorMessage='AtLeastOneMember'
		goto theEnd
	end
	if(@currentMembersCount + @newMembersCount > dbo.CONST_GroupMembersMaxCount())
	begin
		Set @errorMessage='MembersLimitExceeded'
		goto theEnd
	end

	update invitees set currentMembershipStatus=GroupMembershipStatusId 
	from @invitations as invitees join groupmembers on invitees.memberId=groupMembers.MemberId
	and GroupId=@groupId	
	
	if((select count(*) from @invitations where currentMembershipStatus in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus()))>0)
	begin
		select @errorMessage = COALESCE(@errorMessage + ',', '') + cast(memberId as nvarchar(20)) from @invitations where currentMembershipStatus in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus())
		set @errorMessage = 'Conflict:' + @errorMessage
		goto theEnd
	end

	begin transaction
	update M Set GroupMembershipStatusId=@CONST_pendingMembershipStatus,
	invitedBy = @userId, isAdmin=@isAdmin, removedBy = null 
	From groupMembers M join @invitations reInvited on M.memberId=reInvited.memberId and M.GroupId=@groupId 
	where reInvited.currentMembershipStatus is not null
	if(@@error<>0)
	begin
		raiserror('Error on reinvite',16,34)
		goto TheEnd
	end
			
	insert into groupMembers(groupId, memberId, invitedBy, isAdmin, GroupMembershipStatusId, deleted)
	select @groupId, invitees.memberId, @userId, @isAdmin, @CONST_pendingMembershipStatus, 0
	from @invitations invitees where invitees.currentMembershipStatus is null
	if(@@error<>0)
	begin
		raiserror('error on add new invitations',16,34)
		rollback
		goto theEnd
	end
	UPDATE [Groups] SET [MembersCount] = (select count(*) from GroupMembers where groupid=@groupId and GroupMembershipStatusId in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus())) where GroupId=@groupId
	if(@@error<>0)
	begin
		raiserror('error on recalculate members count',16,34)
		rollback
		goto theEnd
	end
	set @invitees =''
	select @invitees = COALESCE(@invitees + ',', '') + cast(memberId as nvarchar(20)) from @invitations 
	print @invitees
	insert into @members(id, userId)
	exec [dbo].[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId,@CONST_NewGroupInvitationType, @update, @updateId out, @invitees
	commit
	
	theEnd:
	select id, userId from @members
end



GO
/****** Object:  StoredProcedure [dbo].[Group_AdminMembershipAction]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Group_AdminMembershipAction](@user_Id nvarchar(128), @group_id nvarchar(128), @action int, @member_id nvarchar(128), @updateId nvarchar(128) out, @errorMessage nvarchar(max) out)
as begin
	declare @CONST_GroupInvitationCancelled int=18
	declare @CONST_GroupMemberRemoved int=22
	declare @CONST_GroupMemberSetAsAdmin int=23

	declare @userId bigint
	declare @memberId bigint
	declare @groupId bigint
	declare @userIsAdmin bit
	declare @usersToInform table (Id nvarchar(128), userId bigint)
	
	set @errorMessage =''
	Select @memberId=userid from users where id=@member_Id
	Select @groupId=groupId from groups where id=@group_id
	select @userId = userId, @userIsAdmin=isAdmin from users u join GroupMembers m on u.UserId=m.MemberId where u.Id=@user_Id and m.GroupId=@groupId

	if(@userIsAdmin is null or @userIsAdmin=0)
		begin
		set @errorMessage = 'UserIsNotAdmin'
		goto theEnd		
	end
	if(@action = @CONST_GroupMemberRemoved)
	begin
		begin transaction
		insert into @usersToInform(id, userId)
		exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @member_id, @updateId out
		if(@@error=0)
		begin
			update GroupMembers set GroupMembershipStatusId=dbo.CONST_RemovedMembershipStatus(), RemovedBy=@userId
			where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
			if(@@ROWCOUNT=0)
			begin
				rollback
				set @errorMessage = 'Inconsistent data'
				goto theEnd	
			end				
		end
		commit
	end
	else if(@action = @CONST_GroupInvitationCancelled)
	begin
		update GroupMembers set GroupMembershipStatusId=dbo.CONST_CancelledMembershipStatus()	
		where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus() and InvitedBy=@userId
		if(@@ROWCOUNT=1)
		begin
			insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, '', @updateId out , @memberId 
		end
		else
		begin
			set @errorMessage = 'Action Denied:UserIsNotInvitationIssuer or InvitationIsNoLongerPending'
			goto theEnd	
		end
	end if(@action = @CONST_GroupMemberSetAsAdmin)
	begin
		update GroupMembers set IsAdmin=1	
		where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() 
		if(@@ROWCOUNT=1)
		begin
			insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @member_id, @updateId out, @memberId 
		end
		else
		begin
			set @errorMessage = 'Inconsistent data'
			goto theEnd	
		end
	end
	theend:
	select * from @usersToInform
end




GO
/****** Object:  StoredProcedure [dbo].[Group_Create]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Group_Create](@user_Id nvarchar(128), @Subject nvarchar(25), @group_id nvarchar(128) out, @groupId bigint out, @createdAt datetimeoffset out, @error nvarchar(25) out)
as
begin
	declare @CONST_ActiveMembershipStatus int = dbo.CONST_ActiveMembershipStatus()
	declare @userId bigint
	declare @isAdmin bit = 1
	begin transaction
	Set @group_id = newid()
	Select @userId=userid from users where id=@user_Id
	
	insert into Groups(id,CreatedBy,[Subject], MembersCount,CreatedAt, Deleted)
	values (@group_id, @userId, @Subject, 1,CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()), 0)
	if(@@error<>0)
	begin	
		set @error = 'System error, [Group_Create]#INSERT INTO [Groups]'
		return
	end
	
	Select @groupId =groupId, @createdAt=createdAt from groups where id=@group_id
	
	insert into groupMembers(groupId, memberId, invitedBy, isAdmin, GroupMembershipStatusId, deleted)
	select @groupId, @userId, @userId, @isAdmin, @CONST_ActiveMembershipStatus, 0
	if(@@error<>0)
	begin	
		set @error = 'System error, [Group_Create]#INSERT INTO [groupMembers]'
		rollback
		return
	end
	commit
end




GO
/****** Object:  StoredProcedure [dbo].[Group_CreateROLLBACK]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Group_CreateROLLBACK](@groupId bigint)
as
begin
	delete from GroupIcons where GroupId=@groupId
	delete from GroupMembers where GroupId=@groupId
	delete from Groups where GroupId=@groupId
end




GO
/****** Object:  StoredProcedure [dbo].[Group_GenerateUpdate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Group_GenerateUpdate] @user_Id nvarchar(128), @userId bigint=0,@group_id nvarchar(128),@groupId bigint=0, @updateTypeId int, @update nvarchar(2048), @updateId nvarchar(128) out, @specificMembers nvarchar(max)=null,@muteOutput bit=0
as begin
	declare @CONST_PendingStatusId int = 1
	declare @CONST_GroupInvitationCancelled int=18
	declare @CONST_GroupInvitationRejected int=19
	declare @CONST_GroupMemberJoined int=20
	declare @CONST_GroupMemberLeft int=21
	declare @CONST_GroupMemberSetAsAdmin int=23

	Declare @Members table (Id nvarchar(128), userId bigint)
	if(@userId=0)	
		Select @userId = userId from users where Id=@user_Id
	if(@groupid=0)
		Select @groupId = groupId from groups where Id=@group_id

	if(@specificMembers is not null and len(@specificMembers)>0)
	begin
		insert into @Members(Id, userId)
		Select u.Id,u.UserId From [dbo].split(@specificMembers,',') custom join users u on u.userId =custom.items where items<>@userId
	end
	else
	begin
		if(@updateTypeId = @CONST_GroupInvitationCancelled)
		begin
			insert into @Members(Id, userId)
			Select u.id, u.userid from GroupMembers m join users u on u.userid=m.memberid 
			where groupid=@groupid and GroupMembershipStatusId=dbo.const_PendingMembershipStatus()
		end
		else
		begin
			insert into @Members(Id, userId)
			Select Id,userId From [dbo].[GetMembers](@groupId) where userId<>@userId
		end
	end
	if((select count(*) from @Members)=0)
		return
	if(@updateTypeId in (@CONST_GroupMemberLeft, @CONST_GroupMemberSetAsAdmin, @CONST_GroupInvitationCancelled, @CONST_GroupInvitationRejected))
	begin
		set @userId = [dbo].[CONST_SystemUserInternalId]()
	end
	begin transaction
	Set @updateId = newid()
	insert into Notifications(Id, SenderId, [GroupId], NotificationTypeId, [Message], Deleted)
	Values(@updateId, @userId, @groupId, @updateTypeId, @update,0)

	insert into NotificationRecipients(NotificationId, RecipientId, NotificationStatusId)
	Select @updateId, M.userId, @CONST_PendingStatusId from @Members M
	if(@@Error<>0)
	Begin
		Rollback
		Return
	End
	commit

	if(@muteOutput=1)
		return
	Select * from @Members
end




GO
/****** Object:  StoredProcedure [dbo].[Group_MemberAction]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Group_MemberAction](@user_Id nvarchar(128), @group_id nvarchar(128), @action int out, 
@updateId nvarchar(128) out, 
@newAdminId nvarchar(128) out, @newAdminUpdateId nvarchar(128) out, @errorMessage nvarchar(max) out)
as begin
	set @newAdminId = ''
	set @newAdminUpdateId = ''
	declare @CONST_GroupInvitationCancelled int=18
	declare @CONST_GroupInvitationRejected int=19
	declare @CONST_GroupMemberJoined int=20
	declare @CONST_GroupMemberLeft int=21
	declare @CONST_GroupMemberSetAsAdmin int=23

	declare @userId bigint
	declare @groupId bigint
	declare @usersToInform table (Id nvarchar(128), userId bigint)
	Select @userId=userid from users where id=@user_Id
	Select @groupId=groupId from groups where id=@group_id

	if(@action = @CONST_GroupMemberJoined)
	begin
		update GroupMembers set GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
		where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus()
		if(@@ROWCOUNT=1)
		begin
			insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId,@action, '', @updateId out
		end
		else
		begin
			--Set @errorMessage ='Action Denied:InvitationIsNoLongerPending'
			goto theEnd
		end
	end
	else if(@action = @CONST_GroupMemberLeft)
	begin
		declare @isAdmin bit
		Select @isAdmin = isAdmin from GroupMembers where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
		if(@@ROWCOUNT=1)
		begin
			begin transaction
			if(@isAdmin = 1)
			begin
				if((select count(*) from GroupMembers where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and MemberId<>@userId)=0)
				begin
					Set @action = @CONST_GroupInvitationCancelled
				end
				else
				begin
					if((select count(*) from GroupMembers where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and MemberId<>@userId and IsAdmin = 1)=0)
					begin
						Select top (1) @newAdminId=u.id from GroupMembers m join users u on u.userid=m.memberid where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and memberid<> @userid order by m.UpdatedAt asc
						--insert into @usersToInform
						exec [dbo].[system_Group_AdminMembershipAction] @user_Id, @group_id, @CONST_GroupMemberSetAsAdmin, @newAdminId, @newAdminUpdateId  out, @errorMessage out					
						if(@@ERROR<>0)
						begin
							Rollback
							Set @errorMessage = 'ErrorOccuredOnSetNewAdmin:' + @newAdminId + ' in group:' + @group_id
							return
						end
					end
				end			
			end
			update GroupMembers set GroupMembershipStatusId=dbo.CONST_LeftMembershipStatus(), @isAdmin = isAdmin
			where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
			if(@@ERROR<>0)
			begin
				Rollback
				Set @errorMessage = 'ErrorOccuredOnMemberLeft'
				return
			end
			delete from @usersToInform
			insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @user_Id, @updateId out
			if(@@ERROR<>0)
			begin
				Rollback
				Set @errorMessage = 'ErrorOccuredOnGroup_GenerateUpdate:' + cast(@action as nvarchar(10))
				return
			end
			commit
		end
	end
	else if(@action = @CONST_GroupInvitationRejected)
	begin
		declare @invitedBy bigint
		update GroupMembers set @invitedBy=invitedBy, GroupMembershipStatusId=dbo.CONST_RejectedMembershipStatus()	
		where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus()
		if(@@ROWCOUNT=1)
		begin
			insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @user_Id, @updateId out, @invitedBy 
		end
		else
		begin
			--Set @errorMessage ='Action Denied:InvitationIsNoLongerPending'
			goto theEnd
		end
	end
	theEnd:
	select * from @usersToInform
end





GO
/****** Object:  StoredProcedure [dbo].[Group_SaveNotification]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Group_SaveNotification] @SenderId bigint, @group_Id nvarchar(128),@LocalMessageId nvarchar(100), @NotificationTypeId int, @NotificationContent nvarchar(2048), @ExpiresAt nvarchar(50), @FileSizeInBytes bigint, @Duration int, @IsScrambled bit, @delay int, @AlreadyReceived bit out, @NotificationId nvarchar(128) out, @IssuedAt datetimeoffset out, @SenderHasPendingNotifications bit out
as begin
declare @CONST_PendingStatusId int = 1
declare @CONST_DelayedStatusId int = 0
declare @StartingStatusId int = case when @delay=0 then @CONST_PendingStatusId else @CONST_DelayedStatusId end

Set @SenderHasPendingNotifications = case when exists (Select 1 from [NotificationRecipients] R join [Notifications] N on R.NotificationId=N.Id
Where R.RecipientId=@SenderId And R.NotificationStatusId = @CONST_PendingStatusId And N.CreatedAt < DATEADD(SECOND,2,SYSDATETIMEOFFSET()))  
then 1 else 0 end


SELECT @AlreadyReceived = 1, @NotificationId=[Id], @IssuedAt = [CreatedAt] 
FROM [Notifications] Where [LocalId] = @LocalMessageId and [SenderId] = @SenderId
if(@@ROWCOUNT>0)
	return
	
declare @groupId bigint
declare @Members table (Id nvarchar(128), userId bigint)

Select @groupId = groupId from groups where Id=@group_id

Set @AlreadyReceived = 0
Set @NotificationId = newid()
set @IssuedAt = DATEADD(second,@delay,sysutcdatetime())

insert into @Members(Id, userId)
Select Id,userId From [dbo].[GetMembers](@groupId) where userId<>@SenderId
if(@@ROWCOUNT=0)
	return


Begin Transaction
insert into [Notifications](id,[GroupId],[SenderId], [LocalId],[NotificationTypeId],[Message],[ExpiresAt],[SizeInBytes],[Duration],[IsScrambled], Deleted)
values (@NotificationId,@groupId, @SenderId, @LocalMessageId,@NotificationTypeId,@NotificationContent,@ExpiresAt,@FileSizeInBytes,@Duration,@IsScrambled, 0)
if(@@error<>0)
begin
	Set @NotificationId = ''
	return
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
select @NotificationId, userId, @StartingStatusId from @Members
if(@@error<>0)
begin
	Rollback
	Set @NotificationId = ''
	return
end
--Select @IssuedAt = [CreatedAt] from [Notifications] where id=@NotificationId
commit
Select * from @Members
end




GO
/****** Object:  StoredProcedure [dbo].[Group_UpdateIcon]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Group_UpdateIcon]@user_Id nvarchar(128), @group_id nvarchar(128), @icon varbinary(max), @updateId nvarchar(128) out, @errorMessage nvarchar(max) out
as begin
	declare @CONST_GroupIconChangedType int = 17
	--declare @userIsAdmin bit
	declare @userId bigint
	declare @groupId bigint	
	Declare @Members table (Id nvarchar(128), userId bigint)

	set @errorMessage = ''

	select @groupId = groupId from groups where id=@group_Id
	select @userId = userId/*, @userIsAdmin=isAdmin*/ from users u join GroupMembers m on u.UserId=m.MemberId where u.Id=@user_Id and m.GroupId=@groupId
	--if(@userIsAdmin is null or @userIsAdmin=0)
	if(@@rowcount=0)
		begin
		set @errorMessage = 'UserIsNotAdmin'  --user is not member
		goto theEnd		
	end

	update GroupIcons set Data=@icon where Id=@group_id
	
	insert into @members(id, userId)
	exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId,@Const_GroupIconChangedType, '', @updateId out

	theEnd:
	Select * from @members
End




GO
/****** Object:  StoredProcedure [dbo].[Group_UpdateSubject]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Group_UpdateSubject]@user_Id nvarchar(128), @group_id nvarchar(128), @newSubject nvarchar(25),  @updateId nvarchar(128) out, @errorMessage nvarchar(max) out
as begin
	declare @CONST_GroupSubjectChangedType int=16
	--declare @userIsAdmin bit
	declare @userId bigint
	declare @groupId bigint	
	declare @currentSubject nvarchar(25)
	Declare @Members table (Id nvarchar(128), userId bigint)

	set @errorMessage = ''

	select @groupId = groupId, @currentSubject=[Subject] from groups where id=@group_Id
	select @userId = userId/*, @userIsAdmin=isAdmin*/ from users u join GroupMembers m on u.UserId=m.MemberId where u.Id=@user_Id and m.GroupId=@groupId
	--if(@userIsAdmin is null or @userIsAdmin=0)
	if(@@rowcount=0)
		begin
		set @errorMessage = 'UserIsNotAdmin' --user is not member
		goto theEnd		
	end
	if(@currentSubject = @newSubject)
		goto theEnd

	update groups set Subject=@newSubject where GroupId=@groupId
	
	insert into @members(id, userId)
	exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId,@CONST_GroupSubjectChangedType, @newSubject, @updateId out

	theEnd:
	Select * from @members
End




GO
/****** Object:  StoredProcedure [dbo].[IdentityErrorHandling]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[IdentityErrorHandling] @Category nvarchar(50), @identityTypeId int, @ErrorMessage nvarchar(255) out, @Redirect nvarchar(100) out
as
begin
declare @spaceForReadibility varchar(1) =''
declare @identityTypeName nvarchar(20) 
select @identityTypeName = name from [dbo].[IdentityType] where id =@identityTypeId

if(@Category in ('NotAvailable','Required'))
begin
	set @errorMessage = @identityTypeName + @spaceForReadibility + @Category
	set @redirect = '~Registration\' + @identityTypeName
end
else if (@category = 'CodeExpired')
begin
	set @errorMessage = 'Code' + @spaceForReadibility + 'Expired'
	set @redirect = '~Registration\' + @identityTypeName
end
else if (@Category = 'CodeInvalid')
begin
	set @errormessage = 'Code' + @spaceForReadibility + 'Invalid'
	set @redirect = ''
end
else
begin
	set @errormessage = @Category + @identityTypeName
	set @redirect = ''
end
end




GO
/****** Object:  StoredProcedure [dbo].[InsertLog]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[InsertLog] @userId nvarchar(128), @message nvarchar(max), @category nvarchar(50), @level nvarchar(50), @request nvarchar(max)
as
begin
	insert into [TracingLogs](UserId, [Message], Category, [Level], Request)
	values (@userId, @message, @category, @level, @request)
end




GO
/****** Object:  StoredProcedure [dbo].[LoadFileChunksReference]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[LoadFileChunksReference] @userId bigint, @deviceFileName nvarchar(50), @LocalChunksNames nvarchar(max) out
as
begin
	update [dbo].[MediaChunksMapping]
	set @LocalChunksNames = LocalChunksNames, [CompletedAt] = sysutcdatetime()
	where userId=@userId and deviceFileName=@deviceFileName
	if(@@rowcount=0)
		insert into [dbo].[MediaChunksMapping] (userId,deviceFileName,[CompletedAt],totalchunks,filetype)
		select @userId, @deviceFileName,sysutcdatetime(),-1,-1
end





GO
/****** Object:  StoredProcedure [dbo].[LoadInviationTemplate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[LoadInviationTemplate](@userId bigint, @languageId int)
as
begin
declare @SMSInvitationTemplate  nvarchar(160)='Enjoy secured conversations, control sensitive messages life time, share secrets with third party apps and many more with Twicie
dbo.azurewebsites.net/dl/'
declare @IsUnicode bit=0
	select 1 as TypeId, '' as Title,@SMSInvitationTemplate  as Content, @IsUnicode as IsUnicode, ',' as RecipientsSeperator
end		







GO
/****** Object:  StoredProcedure [dbo].[LoadTemplate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[LoadTemplate](@IdentityType int, @transactionType nvarchar(50), @template nvarchar(max) out, @token nvarchar(128), @code nvarchar(128), @identity nvarchar(100), @username nvarchar(20), @name nvarchar(50))
as
begin
	Select @template=content from template where subject=@transactionType and type=@IdentityType
	Set @template = replace(@template, '#Root#', dbo.CONST_GetValueByKey('Root'))
	Set @template = replace(@template, '#Website#', dbo.CONST_GetValueByKey('Website'))
	Set @template = replace(@template, '#AppName#', dbo.CONST_GetValueByKey('AppName'))
	
	Set @template = replace(@template, '#Token#', isnull(@Token,''))
	Set @template = replace(@template, '#Code#', isnull(@Code,''))	
	Set @template = replace(@template, '#Identity#', isnull(@Identity,''))	
	Set @template = replace(@template, '#Username#', isnull(@Username,''))
	Set @template = replace(@template, '#Name#', isnull(@Name,''))
	Set @template = isnull(@template,'')
end



GO
/****** Object:  StoredProcedure [dbo].[ManageInviteeList]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ManageInviteeList](@userId bigint, @all bit, @invitees nvarchar(max), @smsReferenceId [nvarchar](128) out, @emailReferenceId [nvarchar](128) out)
as
begin
	declare @emailEnabled bit = 0
	declare @notSynched nvarchar(max)
	Declare @inviteesList table (value nvarchar(255), found bit, notRegistered bit, typeId int)
	if(@all = 1)
	begin
		insert into @inviteesList (value, typeId, notRegistered)
		Select c.[identity], c.IdentityTypeId, 1 from userContacts c where c.userid=@userId and c.ContactUserId is null
	end
	else if(@invitees is not null and @invitees !='')
	begin

		declare @countryCode char(3)
		select @countryCode=Code from users u join Country c on c.Id=u.CountryId where u.UserId=@userId

		insert into @inviteesList (value,found,notRegistered)
		Select items,0,0 from dbo.Split(@invitees,',')

		update inviteesList set 
		found = case when c.Id is not null then 1 else 0 end,
		notRegistered= case when c.ContactUserId is null then 1 else 0 end,
		typeId = c.IdentityTypeId,
		value = case when c.[Identity] is null then inviteesList.value else c.[identity] end
		from @inviteesList inviteesList left join userContacts c on inviteesList.value = c.[originalIdentity] and c.userid=@userId

		Select @notSynched = COALESCE(@notSynched + ',', '') + [value] FROM @inviteesList where found=0 group by [value]
		delete from @inviteesList where found=0

		/*************TO DO IN CASE HANDLING NON SYNCHED CONTACTS IS SUPPORTED*******************/
		--write InternationalFormat function
		--update inviteesList set typeId = 1, value = [dbo].[InternationalFormat](Value, @countryCode) from @inviteesList inviteesList where found=0 and value not like '%@%'
		--update inviteesList set typeId = 2 from @inviteesList inviteesList where typeId is null
	end
	else
	begin
		Raiserror('Invitee list is empty',13,34)
		Return
	end

	declare @inviteesConcatenated nvarchar(max)
	Select @inviteesConcatenated = COALESCE(@inviteesConcatenated + ',', '') + [value] FROM @inviteesList where typeId=1 group by [value]

	if(len(isnull(@inviteesConcatenated,'')))>0
	begin
		Set @smsReferenceId = newid()		
		insert into [invitation](Id, InvitorId, [Bulk], [IdentityTypeId],[Invitee], notSynched)
		values (@smsReferenceId, @userid, @all, 1, @inviteesConcatenated + ',' , @notSynched)
	end
	if(@emailEnabled=1)
	begin
		set @inviteesConcatenated=''
		Select @inviteesConcatenated = COALESCE(@inviteesConcatenated + ',', '') + [value] FROM @inviteesList where typeId=2 group by [value]
		if(len(isnull(@inviteesConcatenated,'')))>0
		begin
			Set @emailReferenceId = newid()	
			insert into [invitation](Id, InvitorId, [Bulk], [IdentityTypeId],[Invitee], notSynched)
			values (@emailReferenceId, @userid, @all, 2, @inviteesConcatenated + ',' , @notSynched)
		end
	end

	----Simulation--
	--delete from @inviteesList
	--insert into @inviteesList(typeId,value,notRegistered)
	--select IdentityTypeId , [identity],1 from UserIdentities where userid=@userId and IdentityTypeId=1 -- mobile
	----Simulation--
	select distinct -1 as TypeId, '' as [Identity] --from @inviteesList where (typeId=1 or (@emailEnabled =1 and typeId =2))and notRegistered=1
	
end				



GO
/****** Object:  StoredProcedure [dbo].[NotificationDelivered]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[NotificationDelivered]
@userId bigint,@notifications nvarchar(max)
as
begin
	declare @CONST_Delivered int = 2
	declare @CONST_Read int = 4
	declare @CONST_MessageDeliveredNotificationEnumId int = 8

	declare @Data table(id nvarchar(128), SenderId bigint, GroupId bigint, remaining int, isChat bit )
	declare @updates table( UserId bigint,[User_Id] nvarchar(128),Content nvarchar(max), UpdateId nvarchar(128))

	insert into @Data(Id, SenderId, GroupId, isChat)
	Select N.Id, N.SenderId, N.GroupId,IsChat  From [dbo].split(@notifications,',') ids
	join Notifications N on N.Id = ids.items 
	join NotificationRecipients R on R.NotificationId = N.Id 
	join NotificationTypes t on t.NotificationTypeId = N.NotificationTypeId 
	where R.RecipientId=@userId and R.NotificationStatusId not in (@CONST_Delivered,@CONST_Read)
	if(@@ROWCOUNT=0)
		return
	
	update R set R.NotificationStatusId=@CONST_Delivered, R.deliveredAt = getutcdate()
	from NotificationRecipients R join @Data delivered on delivered.id=R.NotificationId
	where R.RecipientId=@userId

	delete d from @Data d where isChat=0
	delete d from @Data d where dbo.Group_NotificationRemainigRecipientsCountByStatus(d.id, @CONST_MessageDeliveredNotificationEnumId,@userId)>0	--TO DO: Do not delete in case at least one recipient didnt receive it yet

	insert into @updates(UserId,[User_Id], Content)
	select delivered.SenderId, U.Id, STUFF((SELECT ',' + [Id] FROM @data WHERE (SenderId = delivered.SenderId) FOR XML PATH ('')),1,1,'') AS groupedBySender
	from @Data delivered 
	join users U on u.UserId = delivered.SenderId
	group by delivered.SenderId, U.Id

	declare @updateId nvarchar(128)
	declare @update nvarchar(max)
	declare @recipientId bigint
	while((select count(*) from @updates where updateid is null)>0)
	begin
		select top(1) @recipientId=UserId, @update=Content from @updates where updateid is null

		Set @updateId = newid()
		insert into Notifications(Id,SenderId, NotificationTypeId, [Message], Deleted) Values(@updateId, @userId, @CONST_MessageDeliveredNotificationEnumId, @update, 0)
		insert into NotificationRecipients(NotificationId, RecipientId, NotificationStatusId) Values(@updateId,@recipientId, 1)

		update @updates set UpdateId=@updateId where UserId=@recipientId
	end
	select * from @updates
end






GO
/****** Object:  StoredProcedure [dbo].[NotificationRead]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[NotificationRead] @userId bigint, @Id nvarchar(128), @markAllPrevious bit 
as begin
declare @SenderId bigint
declare @UpdateId nvarchar(128)= ''
declare @Content nvarchar(max)= ''

declare @CONST_PendingStatusId int = 1
declare @CONST_ReadStatusId int = 4
declare @CONST_MessageRead int= 9 

declare @CONST_DeliveredStatusId int = 2
declare @issuedAt datetimeoffset
declare @date datetimeoffset = getutcdate()
declare @GroupId bigint
declare @Remaining int
Begin Transaction

update r
set r.NotificationStatusId = @CONST_ReadStatusId,
@SenderId = n.SenderId, @issuedAt =n.CreatedAt,
@GroupId=groupid, @remaining=case when groupid is null then 0 else dbo.Group_NotificationRemainigRecipientsCountByStatus(n.Id, @CONST_ReadStatusId,@userId) end,
r.readAt=@date, r.deliveredat=case when r.deliveredAt is null then @date else r.deliveredAt end
from [NotificationRecipients] r join [Notifications] n
on n.id=r.NotificationId
where n.Id=@id and r.RecipientId=@userId
and r.NotificationStatusId != @CONST_ReadStatusId
if(@@ROWCOUNT=0)
begin
	goto theend
end

if(@Remaining = 0)
	Set @Content = @id

if(@markAllPrevious=1)
begin
	declare @data table (id nvarchar(128), readat datetimeoffset)

	update r
	set r.NotificationStatusId = @CONST_ReadStatusId,
	r.ReadAt = @date
	output inserted.NotificationId, inserted.ReadAt into @data
	from [NotificationRecipients] r join [Notifications] n
	on n.id = r.NotificationId
	where n.CreatedAt < @issuedAt and r.RecipientId = @userId and r.NotificationStatusId = @CONST_DeliveredStatusId
	and ( (@GroupId is null and groupid is null) or (@groupid is not null and groupid is not null and groupid=@GroupId))
	if(@@rowcount>0)
	begin
		if(@Content = '')
		begin
			select top(1) @Content = Id from  @data 
			where dbo.Group_NotificationRemainigRecipientsCountByStatus(Id, @CONST_ReadStatusId,@userId)=0
			order by readAt desc
		end
	end
end
if(@Content = '')
begin
	goto theend
end

Set @UpdateId = newid()

insert into [Notifications](id,[SenderId], [NotificationTypeId],[Message],Deleted)
values (@UpdateId, @userId, @CONST_MessageRead,@Content, 0)
if(@@error<>0)
begin
	Rollback
	Set @UpdateId = ''
	return
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
values (@UpdateId,@SenderId, @CONST_PendingStatusId)
if(@@error<>0)
begin
	Rollback
	Set @UpdateId = ''
	return
end

select u.UserId, u.id as [User_Id], @UpdateId as UpdateId, @Content as Content from users u where UserId=@SenderId
theend:
commit
end




GO
/****** Object:  StoredProcedure [dbo].[NotificationRecalled]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[NotificationRecalled] @userId bigint, @Ids nvarchar(max)
as begin
declare  @UpdateId nvarchar(128) =''

declare @recalledIds table(Id nvarchar(128))
insert into @recalledIds
select * from dbo.split(@Ids, ',')

declare @CONST_PendingStatusId int = 1
declare @CONST_RecallStatusId int = 3
declare @CONST_MessageRecalled int= 10
declare @updateRecipients table(UserId bigint)


--select distinct (r.recipientid) from [NotificationRecipients] r join  @recalledIds Ids on Ids.Id=r.notificationId
--if(@@ROWCOUNT!=1)
--begin
--	insert into TracingLogs(Level, Category, Request,UserId)
--	select 'Error','Recall',@Ids,@userId
--	return
--end
Begin Transaction

update r
set r.NotificationStatusId = @CONST_RecallStatusId/*,
@RecipientInternalId = r.recipientid*/
output inserted.recipientid into @updateRecipients
from [NotificationRecipients] r join @recalledIds Ids on Ids.Id=r.NotificationId join notifications n on n.id=ids.Id
where n.SenderId=@userId
and r.NotificationStatusId != @CONST_RecallStatusId
if(@@ROWCOUNT=0)
begin
	goto theend
end

Set @UpdateId = newid()

insert into [Notifications](id,[SenderId], [NotificationTypeId],[Message],Deleted)
values (@UpdateId, @userId, @CONST_MessageRecalled,@Ids, 0)
if(@@error<>0)
begin
	Rollback
	Set @UpdateId = ''
	--set @RecipientId = ''
	return
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
--values (@UpdateId,@RecipientInternalId, @CONST_PendingStatusId)
select distinct @UpdateId,r.userid, @CONST_PendingStatusId from @updateRecipients r
if(@@error<>0)
begin
	Rollback
	Set @UpdateId = ''
	--set @RecipientId = ''
	return
end
--select @RecipientId = id from users where UserId=@RecipientInternalId
select u.UserId ,u.id as [User_Id], @UpdateId as UpdateId from users u join @updateRecipients r on r.userid=u.userid
theend:
commit
end




GO
/****** Object:  StoredProcedure [dbo].[PostSynchronizeContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[PostSynchronizeContacts] @userId bigint, @dataType nvarchar(25), @synchStartedAt datetimeoffset
as
begin
	Exec [dbo].[CleanUpUserContacts] @userId, @dataType

	if(@dataType = 'Identity')
	Begin
		insert into logs(category, userId,[log]) values (@dataType,@userid,@synchStartedAt)
		update uc
		set uc.contactUserId=ui.userId, updatedAt = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME())
		from dbo.userIdentities ui 
		join dbo.userContacts uc on ui.[identity]=uc.[identity]
		where uc.userid=@userId and CreatedAt>dateadd(second,-1,@synchStartedAt)
	End
end




GO
/****** Object:  StoredProcedure [dbo].[preAuthorizationTokenGeneration]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[preAuthorizationTokenGeneration](@Username nvarchar(20), @Id nvarchar(128) out, @UserId bigint out, @Password varbinary(max) out, @Salt varbinary(max) out)
AS
BEGIN
	Select @Id=Id, @UserId=UserId, @Password=[Password], @Salt=[Salt]
	From UserAccesses Where Username = @Username
End


GO
/****** Object:  StoredProcedure [dbo].[Recall]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[Recall] @userId bigint, @Ids nvarchar(max), @NotificationId nvarchar(128) out, @RecipientId nvarchar(128) out
as begin

set @NotificationId = ''
set @RecipientId = ''

declare @recalledIds table(Id nvarchar(128))
insert into @recalledIds
select * from dbo.split(@Ids, ',')

declare @CONST_PendingStatusId int = 1
declare @CONST_RecallStatusId int = 3
declare @CONST_MessageRecalled int= 10
declare @RecipientInternalId bigint
select distinct (r.recipientid) from [NotificationRecipients] r join  @recalledIds Ids on Ids.Id=r.notificationId
if(@@ROWCOUNT!=1)
begin
	insert into TracingLogs(Level, Category, Request,UserId)
	select 'Error','Recall',@Ids,@userId
	return
end
Begin Transaction
update r
set r.NotificationStatusId = @CONST_RecallStatusId,
@RecipientInternalId = r.recipientid
from [NotificationRecipients] r join @recalledIds Ids on Ids.Id=r.NotificationId join notifications n on n.id=ids.Id
where n.SenderId=@userId
and r.NotificationStatusId != @CONST_RecallStatusId
if(@@ROWCOUNT=0)
	return

Set @NotificationId = newid()

insert into [Notifications](id,[SenderId], [NotificationTypeId],[Message],Deleted)
values (@NotificationId, @userId, @CONST_MessageRecalled,@Ids, 0)
if(@@error<>0)
begin
	Rollback
	Set @NotificationId = ''
	set @RecipientId = ''
	return
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
values (@NotificationId,@RecipientInternalId, @CONST_PendingStatusId)
if(@@error<>0)
begin
	Rollback
	Set @NotificationId = ''
	set @RecipientId = ''
	return
end
select @RecipientId = id from users where UserId=@RecipientInternalId

commit
end





GO
/****** Object:  StoredProcedure [dbo].[Report_Error]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Report_Error] @category nvarchar(50)=null, @like nvarchar(50)=null,@count int=50
as begin
select top(@count)* from tracingLogs
where level='Error' 
and (isnull(@category,'')='' or category =@category)
--and (isnull(@like,'')='' or [message] like '%'+ @like+'%')
and createdat>'2016-08-23 20:01:21.6565421 +00:00'
order by createdAt desc
end




GO
/****** Object:  StoredProcedure [dbo].[SaveFileChunksReference]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[SaveFileChunksReference] @userId bigint, @deviceFileName nvarchar(50), @fileType int, @totalChunks int, @LocalChunksNames nvarchar(max)
as
begin
	update [dbo].[MediaChunksMapping]
	set LocalChunksNames = LocalChunksNames + ',' + @LocalChunksNames, UpdatedAt = sysutcdatetime()
	where userId=@userId and deviceFileName=@deviceFileName
	if(@@ROWCOUNT=0)
	begin
		insert into [dbo].[MediaChunksMapping](userId, deviceFileName, fileType, totalChunks, LocalChunksNames)
		values (@userId, @deviceFileName, @fileType, @totalChunks, @LocalChunksNames)
	end
end




GO
/****** Object:  StoredProcedure [dbo].[SaveInvitationFeedback]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SaveInvitationFeedback] (@invitationId nvarchar(128), @feedback nvarchar(max))
as
begin
	update [Invitation] set [status]=2, GatewayFeedback=@feedback, FeedbackAt=sysutcdatetime() where id = @invitationId
end



GO
/****** Object:  StoredProcedure [dbo].[SaveNotification]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SaveNotification]
@SenderId bigint, @recipientPublicId nvarchar(128), @RecipientInternalId bigint out, @LocalMessageId nvarchar(100), @NotificationTypeId int, @NotificationContent nvarchar(2048), @ExpiresAt nvarchar(50), @FileSizeInBytes bigint, @Duration int, @IsScrambled
 bit, @delay int, 
 @AlreadyReceived bit out, @NotificationId nvarchar(128) out, @IssuedAt datetimeoffset out, @SenderHasPendingNotifications bit out
as begin
declare @l_SenderId bigint, @l_recipientPublicId nvarchar(128), @l_RecipientInternalId bigint, @l_LocalMessageId nvarchar(100), @l_NotificationTypeId int, @l_NotificationContent nvarchar(2048), @l_ExpiresAt nvarchar(50), @l_FileSizeInBytes bigint, @l_Duration int, @l_IsScrambled bit, @l_delay int, @l_AlreadyReceived bit, @l_NotificationId nvarchar(128), @l_IssuedAt datetimeoffset, @l_SenderHasPendingNotifications bit

select @l_SenderId =@senderid,
@l_recipientPublicId =@recipientPublicId, 
@l_RecipientInternalId =@RecipientInternalId,
@l_LocalMessageId=@LocalMessageId,
@l_NotificationTypeId =@NotificationTypeId,
@l_NotificationContent =@NotificationContent,
@l_ExpiresAt =@ExpiresAt,
@l_FileSizeInBytes =@FileSizeInBytes,
@l_Duration =@Duration,
@l_IsScrambled =@IsScrambled,
@l_delay =@delay,
@l_AlreadyReceived  =@AlreadyReceived,
@l_NotificationId  =@NotificationId,
@l_IssuedAt =@IssuedAt,
@l_SenderHasPendingNotifications =@SenderHasPendingNotifications

declare @CONST_PendingStatusId int = 1
declare @CONST_DelayedStatusId int = 0
declare @l_StartingStatusId int = case when @l_delay=0 then @CONST_PendingStatusId else @CONST_DelayedStatusId end

Set @l_SenderHasPendingNotifications = case when exists (Select 1 from [NotificationRecipients] R join [Notifications] N on R.NotificationId=N.Id
Where R.RecipientId=@l_SenderId And R.NotificationStatusId = @CONST_PendingStatusId And N.CreatedAt < DATEADD(SECOND,2,SYSDATETIMEOFFSET()))  
then 1 else 0 end


SELECT @l_AlreadyReceived = 1, @l_NotificationId=[Id], @l_IssuedAt = [CreatedAt] 
FROM [Notifications] Where [LocalId] = @l_LocalMessageId and [SenderId] = @l_SenderId
if(@@ROWCOUNT>0)
begin
	goto TheEnd
end
set @l_IssuedAt = DATEADD(second,@l_delay,sysutcdatetime())


Set @l_AlreadyReceived = 0
Set @l_NotificationId = newid()
if(@l_RecipientInternalId=-1)
begin
	Select @l_RecipientInternalId = userid from users where id=@l_recipientPublicId
	if(@@ROWCOUNT=0)
	begin
		SELECT @l_AlreadyReceived = 1, @l_NotificationId='AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA', @l_IssuedAt = GETUTCDATE()
		goto theEnd 
	end
end
Begin Transaction
insert into [Notifications](id,[SenderId], [LocalId],[NotificationTypeId],[Message],[ExpiresAt],[SizeInBytes],[Duration],[IsScrambled], Deleted)
values (@l_NotificationId, @l_SenderId, @l_LocalMessageId,@l_NotificationTypeId,@l_NotificationContent,@l_ExpiresAt,@l_FileSizeInBytes,@l_Duration,@l_IsScrambled, 0)
if(@@error<>0)
begin
	Set @l_NotificationId = ''
	goto TheEnd
end

insert into [NotificationRecipients](NotificationId,RecipientId,NotificationStatusId)
values (@l_NotificationId, @l_RecipientInternalId, @l_StartingStatusId)
if(@@error<>0)
begin
	Rollback
	Set @l_NotificationId = ''
	goto TheEnd
end

--Select @IssuedAt = [CreatedAt] from [Notifications] where id=@NotificationId
commit

TheEnd:
select @RecipientInternalId=@l_RecipientInternalId,@AlreadyReceived=@l_AlreadyReceived, @NotificationId=@l_NotificationId, @IssuedAt =@l_IssuedAt, @SenderHasPendingNotifications=@l_SenderHasPendingNotifications
end




GO
/****** Object:  StoredProcedure [dbo].[ScheduledNotification_Activate]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[ScheduledNotification_Activate] @Id nvarchar(128), 
@SenderId bigint out, @Sender_Id nvarchar(128) out, @senderName nvarchar(25) out, @group_id nvarchar(128) out, 
@LocalMessageId nvarchar(100) out, @NotificationTypeId int out, @NotificationContent nvarchar(2048) out, @ExpiresAt nvarchar(50) out, @FileSizeInBytes bigint out, @Duration int out, @IsScrambled bit out, @issuedAt datetimeoffset out
as
begin
declare @CONST_PendingStatusId int = 1
declare @CONST_DelayedStatusId int = 0
declare @groupId bigint

declare @recipients table (userId bigint)
update r
set r.NotificationStatusId=@CONST_PendingStatusId
output inserted.recipientid into @recipients
from notificationRecipients r
where notificationid=@Id and NotificationStatusId=@CONST_DelayedStatusId

select @groupId=groupid, @SenderId=[SenderId], @LocalMessageId=[LocalId],@NotificationTypeId=[NotificationTypeId],@NotificationContent=[Message],@ExpiresAt=[ExpiresAt],@FileSizeInBytes=[SizeInBytes],@Duration=[Duration],@IsScrambled=[IsScrambled] /*@Delay=[delay],*/,@IssuedAt=createdat
from notifications where id=@id

select @sender_id=id, @senderName=name from users u where u.userid=@senderId
if(@groupId is not null)
begin
	declare @groupSubject nvarchar(25)
	select @group_id=id, @groupSubject=[subject] from groups g where g.groupId=@groupId
	Set @senderName= @senderName + '@'+ @groupSubject
end
select Id as Id, u.UserId from users u join @recipients r on r.userid=u.userId
end




GO
/****** Object:  StoredProcedure [dbo].[ScheduledNotification_Cancel]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[ScheduledNotification_Cancel](@userId bigint, @id nvarchar(128), @errorMessage nvarchar(max) out)
as
begin
Set @errorMessage=''
declare @CONST_RecalledStatusId int = 3
declare @CONST_DelayedStatusId int = 0

declare @SenderId bigint
Select @SenderId=senderid from notifications where id=@id
if(@SenderId<>@userId)
begin
	Set @errorMessage='Unauthorized'
	return
end	
update r
set r.NotificationStatusId=@CONST_RecalledStatusId
from notificationRecipients r
where notificationid=@Id and NotificationStatusId=@CONST_DelayedStatusId
if(@@ROWCOUNT=0)
begin
	Set @errorMessage='ActionDenied:Schedule has been activated already'
	return
end
end




GO
/****** Object:  StoredProcedure [dbo].[SynchronizeContacts]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SynchronizeContacts] @userId bigint, @dataType nvarchar(25), @script nvarchar(max), @synchStartedAt datetimeoffset
as
begin
	begin transaction
	update UserSynchronizeLog set InProcess=1, StartedAt=getUTCDATE() where userid=@userId and @dataType='Identity'
	exec(@Script)
	if(@@ERROR<>0)
	begin
		--rollback
		update UserSynchronizeLog set InProcess=0, EndedAt=getUTCDATE() where userid=@userId and @dataType='Identity'
		return
	end
	if(@datatype in ('Identity','Info'))
		exec [dbo].[PostSynchronizeContacts] @userId, @dataType, @synchStartedAt

	update UserSynchronizeLog set InProcess=0, EndedAt=getUTCDATE() where userid=@userId and @dataType='Identity'
	commit
end




GO
/****** Object:  StoredProcedure [dbo].[System_Group_AdminMembershipAction]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[System_Group_AdminMembershipAction](@user_Id nvarchar(128), @group_id nvarchar(128), @action int, @member_id nvarchar(128), @updateId nvarchar(128) out, @errorMessage nvarchar(max) out)
as begin
	declare @muteOutput bit = 1
	declare @CONST_GroupInvitationCancelled int=18
	declare @CONST_GroupMemberRemoved int=22
	declare @CONST_GroupMemberSetAsAdmin int=23

	declare @userId bigint
	declare @memberId bigint
	declare @groupId bigint
	declare @userIsAdmin bit
	--declare @usersToInform table (Id nvarchar(128), userId bigint)
	
	set @errorMessage =''
	Select @memberId=userid from users where id=@member_Id
	Select @groupId=groupId from groups where id=@group_id
	select @userId = userId, @userIsAdmin=isAdmin from users u join GroupMembers m on u.UserId=m.MemberId where u.Id=@user_Id and m.GroupId=@groupId

	if(@userIsAdmin is null or @userIsAdmin=0)
		begin
		set @errorMessage = 'UserIsNotAdmin'
		goto theEnd		
	end
	if(@action = @CONST_GroupMemberRemoved)
	begin
		begin transaction
		--insert into @usersToInform(id, userId)
		exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @member_id, @updateId out, null, @muteOutput
		if(@@error=0)
		begin
			update GroupMembers set GroupMembershipStatusId=dbo.CONST_RemovedMembershipStatus(), RemovedBy=@userId
			where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
			if(@@ROWCOUNT=0)
			begin
				rollback
				set @errorMessage = 'Inconsistent data'
				goto theEnd	
			end				
		end
		commit
	end
	else if(@action = @CONST_GroupInvitationCancelled)
	begin
		update GroupMembers set GroupMembershipStatusId=dbo.CONST_CancelledMembershipStatus()	
		where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus() and InvitedBy=@userId
		if(@@ROWCOUNT=1)
		begin
			--insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, '', @updateId out , @memberId , @muteOutput
		end
		else
		begin
			set @errorMessage = 'Action Denied:UserIsNotInvitationIssuer or InvitationIsNoLongerPending'
			goto theEnd	
		end
	end if(@action = @CONST_GroupMemberSetAsAdmin)
	begin
		update GroupMembers set IsAdmin=1	
		where groupId=@groupId and MemberId=@memberId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() 
		if(@@ROWCOUNT=1)
		begin
			--insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @member_id, @updateId out, @memberId , @muteOutput
		end
		else
		begin
			set @errorMessage = 'Inconsistent data'
			goto theEnd	
		end
	end
	theend:
	--select * from @usersToInform
end



GO
/****** Object:  StoredProcedure [dbo].[System_Group_MemberAction]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[System_Group_MemberAction](@user_Id nvarchar(128), @group_id nvarchar(128), @action int out, 
@updateId nvarchar(128) out, @newAdminId nvarchar(128) out, @newAdminUpdateId nvarchar(128) out, @errorMessage nvarchar(max) out)
as begin
	declare @muteOutput bit = 1
	set @newAdminId = ''
	set @newAdminUpdateId = ''
	declare @CONST_GroupInvitationCancelled int=18
	declare @CONST_GroupInvitationRejected int=19
	declare @CONST_GroupMemberJoined int=20
	declare @CONST_GroupMemberLeft int=21
	declare @CONST_GroupMemberSetAsAdmin int=23

	declare @userId bigint
	declare @groupId bigint
	--declare @usersToInform table (Id nvarchar(128), userId bigint)
	Select @userId=userid from users where id=@user_Id
	Select @groupId=groupId from groups where id=@group_id

	if(@action = @CONST_GroupMemberJoined)
	begin
		update GroupMembers set GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
		where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus()
		if(@@ROWCOUNT=1)
		begin
			--insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId,@action, '', @updateId out, null, @muteOutput
		end
		else
		begin
			Set @errorMessage ='Action Denied:InvitationIsNoLongerPending'
			goto theEnd
		end
	end
	else if(@action = @CONST_GroupMemberLeft)
	begin
		declare @isAdmin bit
		Select @isAdmin = isAdmin from GroupMembers where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()

		if(@@ROWCOUNT=1)
		begin
			begin transaction
			if(@isAdmin = 1)
			begin
				if((select count(*) from GroupMembers where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and MemberId<>@userId)=0)
				begin
					Set @action = @CONST_GroupInvitationCancelled
				end
				else
				begin
					if((select count(*) from GroupMembers where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and MemberId<>@userId and IsAdmin = 1)=0)
					begin

						Select top (1) @newAdminId=u.id from GroupMembers m join users u on u.userid=m.memberid 
						where GroupId=@groupId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus() and m.memberid<>@userId order by m.UpdatedAt asc

						exec [dbo].[System_Group_AdminMembershipAction] @user_Id, @group_id, @CONST_GroupMemberSetAsAdmin, @newAdminId, @newAdminUpdateId  out, @errorMessage out					
						if(@@ERROR<>0)
						begin
							Rollback
							Set @errorMessage = 'ErrorOccuredOnSetNewAdmin:' + @newAdminId + ' in group:' + @group_id
							print @errorMessage
							return
						end
					end
				end			
			end
			update GroupMembers set GroupMembershipStatusId=dbo.CONST_LeftMembershipStatus(), @isAdmin = isAdmin
			where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_ActiveMembershipStatus()
			if(@@ERROR<>0)
			begin
				Rollback
				Set @errorMessage = 'ErrorOccuredOnMemberLeft'
				return
			end
			--delete from @usersToInform
			--insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @user_Id, @updateId out, null, @muteOutput
			if(@@ERROR<>0)
			begin
				Rollback
				Set @errorMessage = 'ErrorOccuredOnGroup_GenerateUpdate:' + cast(@action as nvarchar(10))
				return
			end
			commit
		end
	end
	else if(@action = @CONST_GroupInvitationRejected)
	begin
		declare @invitedBy bigint
		update GroupMembers set @invitedBy=invitedBy, GroupMembershipStatusId=dbo.CONST_RejectedMembershipStatus()	
		where groupId=@groupId and MemberId=@userId and GroupMembershipStatusId=dbo.CONST_PendingMembershipStatus()
		if(@@ROWCOUNT=1)
		begin
			--insert into @usersToInform(id, userId)
			exec dbo.[Group_GenerateUpdate] @user_Id, @userId, @group_id, @groupId, @action, @user_Id, @updateId out, @invitedBy , @muteOutput
		end
		else
		begin
			Set @errorMessage ='Action Denied:InvitationIsNoLongerPending'
			goto theEnd
		end
	end
	theEnd:
	--select * from @usersToInform
end




GO
/****** Object:  StoredProcedure [dbo].[System_LoadSchedules]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[System_LoadSchedules]
as
begin
declare @CONST_DelayedStatusId int = 0
declare @now datetimeoffset
set @now=SYSUTCDATETIME() 
select distinct Id, createdAt as ScheduledFor from [dbo].notifications n 
join [dbo].NotificationRecipients r on r.NotificationId=n.Id
--where CreatedAt > @now-- and DATEADD(hour,24,@now)
where CreatedAt > @now and createdAT< DATEADD(millisecond,2147483647,@now)
and r.NotificationStatusId=@CONST_DelayedStatusId
end


GO
/****** Object:  StoredProcedure [dbo].[TrackMessageDelivery]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[TrackMessageDelivery](@id nvarchar(128))
as
begin
	declare @result table ( UserId nvarchar(128), DeliveredAt datetimeoffset, ReadAt datetimeoffset)
	insert into @result
	select UserId, DeliveredAt, ReadAt from NotificationTracking where NotificationId=@id
	if(@@ROWCOUNT=0)
	begin
		insert into @result
		select u.id as UserId, DeliveredAt, ReadAt from NotificationRecipients r join users u on u.UserId=r.RecipientId 
		where NotificationId=@id and DeliveredAt is not null 
	end
	Select * from @result
end




GO
/****** Object:  Trigger [dbo].[TR_dbo_GroupIcons_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_GroupIcons_InsertUpdateDelete] ON [dbo].[GroupIcons] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[GroupIcons] SET [dbo].[GroupIcons].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[GroupIcons].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_GroupMembers_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_GroupMembers_InsertUpdateDelete] ON [dbo].[GroupMembers] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[GroupMembers] SET [dbo].[GroupMembers].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[GroupMembers].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_GroupMembers_Update]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[TR_dbo_GroupMembers_Update] 
ON [dbo].[GroupMembers] 
AFTER UPDATE
AS
BEGIN

declare @groupId bigint
select  @groupId=groupId from INSERTED

UPDATE [Groups] 
SET [MembersCount] = (select count(*) from GroupMembers where groupid=@groupId and GroupMembershipStatusId in (dbo.CONST_PendingMembershipStatus(),dbo.CONST_ActiveMembershipStatus()))
where GroupId=@groupId

END



GO
/****** Object:  Trigger [dbo].[TR_dbo_GroupMembershipStatus_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_GroupMembershipStatus_InsertUpdateDelete] ON [dbo].[GroupMembershipStatus] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[GroupMembershipStatus] SET [dbo].[GroupMembershipStatus].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[GroupMembershipStatus].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_Groups_Insert]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_Groups_Insert] ON [dbo].[Groups]
AFTER INSERT
AS
BEGIN 
	insert into [GroupIcons](id,GroupId,Deleted)
	select id, groupId,0 from inserted 
END



GO
/****** Object:  Trigger [dbo].[TR_dbo_Groups_UpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_Groups_UpdateDelete] ON [dbo].[Groups]
AFTER UPDATE, DELETE
AS
BEGIN
	UPDATE [dbo].[Groups] SET [dbo].[Groups].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME())
	FROM INSERTED WHERE inserted.[Id] = [dbo].[Groups].[Id]
END




GO
/****** Object:  Trigger [dbo].[TR_dbo_Notifications_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_Notifications_InsertUpdateDelete] ON [dbo].[Notifications] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[Notifications] SET [dbo].[Notifications].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[Notifications].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_NotificationStatus_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_NotificationStatus_InsertUpdateDelete] ON [dbo].[NotificationStatus] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[NotificationStatus] SET [dbo].[NotificationStatus].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[NotificationStatus].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_NotificationTypes_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_NotificationTypes_InsertUpdateDelete] ON [dbo].[NotificationTypes] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[NotificationTypes] SET [dbo].[NotificationTypes].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[NotificationTypes].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_UserAccesses_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_UserAccesses_InsertUpdateDelete] ON [dbo].[UserAccesses] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[UserAccesses] SET [dbo].[UserAccesses].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[UserAccesses].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_UserContacts_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_UserContacts_InsertUpdateDelete] ON [dbo].[UserContacts] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[UserContacts] SET [dbo].[UserContacts].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[UserContacts].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_UserIdentities_Update]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_UserIdentities_Update] 
ON [dbo].[UserIdentities] 
AFTER UPDATE
AS
BEGIN

declare @oldIdentity nvarchar(100)
declare @NewContactId bigint
declare @NewIdentity nvarchar(100)

select  @oldIdentity=[IDENTITY] from deleted
select  @NewContactId=UserId, @NewIdentity=[IDENTITY] from INSERTED 
update usercontacts set ContactUserId=null, updatedat=CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) where [identity]=@oldIdentity
update usercontacts set ContactUserId=@NewContactId, updatedat=CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) where [identity]=@NewIdentity

END



GO
/****** Object:  Trigger [dbo].[TR_dbo_UserProfilePictures_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_UserProfilePictures_InsertUpdateDelete] ON [dbo].[UserProfilePictures] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[UserProfilePictures] SET [dbo].[UserProfilePictures].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[UserProfilePictures].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_UserPublicKeys_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_UserPublicKeys_InsertUpdateDelete] ON [dbo].[UserPublicKeys] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[UserPublicKeys] SET [dbo].[UserPublicKeys].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[UserPublicKeys].[Id] END



GO
/****** Object:  Trigger [dbo].[TR_dbo_Users_InsertUpdateDelete]    Script Date: 4/8/2021 6:03:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TR_dbo_Users_InsertUpdateDelete] ON [dbo].[Users] AFTER INSERT, UPDATE, DELETE AS BEGIN UPDATE [dbo].[Users] SET [dbo].[Users].[UpdatedAt] = CONVERT(DATETIMEOFFSET, SYSUTCDATETIME()) FROM INSERTED WHERE inserted.[Id] = [dbo].[Users].[Id] END



GO
