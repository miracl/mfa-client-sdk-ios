#import <Foundation/Foundation.h>
#import "IUser.h"
#import <MpinCoreLib/mpin_sdk_base.h>

typedef MPinSDKBase::UserPtr UserPtr;

@interface User : NSObject <IUser>

@property (nonatomic, strong) NSString * identity;
@property (nonatomic,readwrite) UserState userState;

-(id) initWith:(UserPtr)usrPtr;
-(UserPtr) getUserPtr;
@end
