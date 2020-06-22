#import <BulletinBoard/BBDataProvider.h>

@class BBSectionInfo;

@interface ChusmaBulletinProvider : BBDataProvider <BBDataProvider>
+ (instancetype)sharedInstance;
- (void)showBulletin:(BOOL)isFriend;
- (BBSectionInfo *)sectionInfo;
@end