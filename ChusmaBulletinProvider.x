#import "ChusmaBulletinProvider.h"
#import <BulletinBoard/BBDataProviderIdentity.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBSectionIcon.h>
#import <BulletinBoard/BBSectionIconVariant.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBServer.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconModel.h>
#import <SpringBoard/SBIcon.h>

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBIconModel ()
-(id)expectedIconForDisplayIdentifier:(id)arg1;
@end

@interface SBIcon ()
-(id)generateIconImageWithInfo:(struct SBIconImageInfo)arg1;
@end

static NSString *kChusmaSectionIdentifier = @"com.itaysoft.chusma.app";
static NSString *kFindMyiPhoneBundle = @"com.apple.findmy";

@implementation ChusmaBulletinProvider
+ (instancetype)sharedInstance {
	static ChusmaBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		BBDataProviderIdentity *identity = [BBDataProviderIdentity identityForDataProvider:self];

		identity.sectionIdentifier = kChusmaSectionIdentifier;
		identity.sectionDisplayName = @"Chusma";
		identity.sortKey = @"date";
		identity.defaultSectionInfo = [self sectionInfo];
		identity.defaultSectionInfo.pushSettings = BBSectionInfoPushSettingsAlerts | BBSectionInfoPushSettingsSounds;

		self.identity = identity;
	}

	return self;
}

- (void)showBulletin:(BOOL)isFriend {
	NSString *application = isFriend ? @"Find My Friends" : @"Find My iPhone";
	NSString *message = [NSString stringWithFormat:@"Someone is tracking your device through %@", application];
	NSString *bulletinID = [NSString stringWithFormat:@"com.itaysoft.chusma-%@", [[NSUUID UUID] UUIDString]];

	BBBulletinRequest *bulletin = [BBBulletinRequest new];
    bulletin.title = @"Chusma";
    bulletin.sectionID = kChusmaSectionIdentifier;
    bulletin.message = message;
	bulletin.clearable = YES;
	bulletin.date = [NSDate date];
    bulletin.lastInterruptDate = [NSDate date];
	bulletin.bulletinID = [NSUUID UUID].UUIDString;
	bulletin.recordID = bulletinID;
    bulletin.publisherBulletinID = bulletinID;
	bulletin.defaultAction = [%c(BBAction) actionWithLaunchURL:[NSURL URLWithString:@"prefs:root=Chusma"] callblock:nil];
    //bulletin.icon = [self sectionIcon];

	BBDataProviderAddBulletin(self, bulletin);
}

#pragma mark - BBDataProvider

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

- (NSArray *)bulletinsFilteredBy:(NSUInteger)by count:(NSUInteger)count lastCleared:(id)cleared {
	return nil;
}

- (NSString *)sectionDisplayName {
	return @"Chusma";
}

- (BBSectionInfo *)sectionInfo {
	id sectionInfo = [%c(BBSectionInfo) defaultSectionInfoForType:0];
	[sectionInfo setNotificationCenterLimit:10];
	[sectionInfo setSectionID:kChusmaSectionIdentifier];
    [sectionInfo setAllowsNotifications:YES];
    [sectionInfo setShowsInNotificationCenter:YES];
    [sectionInfo setShowsInLockScreen:YES];
    [sectionInfo setAlertType:1];
    [sectionInfo setPushSettings:BBSectionInfoPushSettingsAlerts | BBSectionInfoPushSettingsSounds];
    [sectionInfo setEnabled:YES];
    [sectionInfo setIcon:[self sectionIcon]];
	return sectionInfo;
}

- (BBSectionIcon *) sectionIcon {
    SBIconController *iconController = [%c(SBIconController) sharedInstance];
	SBIcon *icon = [iconController.model expectedIconForDisplayIdentifier:kFindMyiPhoneBundle];
	
	struct SBIconImageInfo iconInfo;
    iconInfo.size = CGSizeMake(128, 128);
    iconInfo.scale = 2.0;
    iconInfo.continuousCornerRadius = 0;

	UIImage *image = [icon generateIconImageWithInfo:iconInfo];
	BBSectionIcon *sectionIcon = [[BBSectionIcon alloc] init];
	[sectionIcon addVariant:[BBSectionIconVariant variantWithFormat:0 imageData:UIImagePNGRepresentation(image)]];

    return sectionIcon;
}

@end