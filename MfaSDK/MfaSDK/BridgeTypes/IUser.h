#import <Foundation/Foundation.h>
#import "Expiration.h"

typedef NS_ENUM(NSInteger, UserState) {
    INVALID = 0,
    STARTED_VERIFICATION,
    STARTED_REGISTRATION,
    ACTIVATED,
    REGISTERED,
    BLOCKED
};

@protocol IUser <NSObject>

- (NSString*) getIdentity;
- (UserState) getState;
- (NSString*) getBackend;
- (NSString*) getCustomerId;
- (NSString*) getAppId;
- (NSString*) getMPinId;
- (Expiration*) getRegistrationExpiration;
- ( int ) getPinLength;
- (BOOL) canSign;
- (NSString*) getVerificationType;

@end
