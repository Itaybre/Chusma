#include <dlfcn.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import <BulletinBoard/BBDataProviderManager.h>
#import "substrate.h"
#import "ChusmaBulletinProvider.h"

static NSString *ChusmaServerName = @"com.itaysoft.chusma";
static BOOL chusmaEnabled = YES;
static NSString *lastCommandId = @"";
static NSDate *lastAlert = [[NSDate alloc] initWithTimeIntervalSince1970:0];

#pragma mark - FindMyiPhone

%group findmydeviced

%hook FMDCommandHandlerLocate

- (void)_sendCurrentLocation:(id)location isFinished:(BOOL)finished forCmd:(NSDictionary *)command withReason:(long long)reason andAccuracyChange:(double)accuracy {
	HBLogDebug(@"Chusma - Sending location %@ reason %llu", location, reason);

	NSString *commandId = [command objectForKey:@"id"];
	if(![commandId isEqualToString:lastCommandId] && [lastAlert timeIntervalSinceNow] < -60) {
		lastCommandId = commandId;
		lastAlert = [NSDate date];

		CPDistributedMessagingCenter *center = [%c(CPDistributedMessagingCenter) centerNamed:ChusmaServerName];
    	rocketbootstrap_distributedmessagingcenter_apply(center);
		[center sendMessageName:@"showNotification" userInfo:@{
			@"isFriends": @(0)
		}];
	}

	%orig;
}

%end

%end

#pragma mark - FindMyFriends

@interface FMRequest: NSObject
-(NSDictionary *)requestBody;
@end

@interface FMRequestAckLocate: FMRequest
@end

@interface FMRequestCurrentLocation: FMRequest
@end

%group fmflocatord

%hook FindBaseServiceProvider

-(void)sendCurrentLocation:(id)location isFinished:(BOOL)finished forCmd:(NSDictionary *)command withReason:(long long)reason andAccuracyChange:(double)accuracy {
	HBLogDebug(@"Chusma - Sending location %@  %@ reason %llu", location, command, reason);

	NSString *commandId = [command objectForKey:@"id"];
	if(![commandId isEqualToString:lastCommandId] && [lastAlert timeIntervalSinceNow] < -60) {
		lastCommandId = commandId;
		lastAlert = [NSDate date];

		CPDistributedMessagingCenter *center = [%c(CPDistributedMessagingCenter) centerNamed:ChusmaServerName];
    	rocketbootstrap_distributedmessagingcenter_apply(center);
		[center sendMessageName:@"showNotification" userInfo:@{
			@"isFriends": @(1)
		}];
	}
	
	%orig;
}

%end

%end

#pragma mark - SpringBoard

%group SpringBoard

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1  {
    CPDistributedMessagingCenter *center = [%c(CPDistributedMessagingCenter) centerNamed:ChusmaServerName];
    rocketbootstrap_distributedmessagingcenter_apply(center);
	[center runServerOnCurrentThread];
    [center registerForMessageName:@"showNotification" target:self selector:@selector(_chusma_showNotification:userInfo:)];
	HBLogDebug(@"Chusma - Server Started");

	%orig;
}

%new
- (void) _chusma_showNotification:(NSString *)name userInfo:(NSDictionary *)userInfo {
	if(chusmaEnabled) {
		[[ChusmaBulletinProvider sharedInstance] showBulletin:[userInfo[@"isFriends"] boolValue]];
	}
}
%end

static BOOL inserted = NO;

%hook BBServer

-(void)dpManager:(BBDataProviderManager *)arg1 addDataProvider:(BBDataProvider *)arg2 withSectionInfo:(BBSectionInfo *)arg3 {
	%orig;
	if(!inserted) {
		inserted = YES;
		%orig(arg1,[ChusmaBulletinProvider sharedInstance],[[ChusmaBulletinProvider sharedInstance] defaultSectionInfo]);
	}
}

%end

%end

#pragma mark - Constructor

NSString * getProcessName()
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	return [args[0] lastPathComponent];
}

static void loadChusmaSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:@"com.itaysoft.chusma"];
	chusmaEnabled = [tweakSettings objectForKey:@"enabled"] ? [[tweakSettings objectForKey:@"enabled"] boolValue] : YES;
}

%ctor {
	NSString *processName = getProcessName();
	HBLogDebug(@"Chusma - Hooked %@", processName);
	if([processName isEqualToString:@"findmydeviced"]) {
		%init(findmydeviced);
	} else if([processName isEqualToString:@"fmflocatord"]) {
		%init(fmflocatord);
	} else {
		%init(SpringBoard);
		loadChusmaSettings(nil,nil,nil,nil,nil);
    	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    NULL,
                                    loadChusmaSettings, 
                                    CFSTR("com.itaysoft.chusma/ReloadPrefs"), 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);
	}
	%init;
}