#include "IBCRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>

@implementation IBCRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

+ (NSString *)hb_shareText {
	return @"Get a notified when someone is tracking you with using Chusma. Created by @itaybre";
}

+ (NSURL *)hb_shareURL {
	return nil;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed:29.f/ 255.f green:111.f / 255.f blue:242.f / 255.f alpha:1];
		self.hb_appearanceSettings = appearanceSettings;
	}

	return self;
}

@end
