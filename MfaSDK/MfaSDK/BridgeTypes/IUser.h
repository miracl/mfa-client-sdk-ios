#import <Foundation/Foundation.h>
#import "Expiration.h"

typedef NS_ENUM(NSInteger, UserState) {
    INVALID = 0,
    STARTED_REGISTRATION,
    ACTIVATED,
    REGISTERED,
    BLOCKED
};

FOUNDATION_EXPORT NSString *const VERIFICATION_TYPE_EMAIL;
FOUNDATION_EXPORT NSString *const VERIFICATION_TYPE_CUSTOM;
FOUNDATION_EXPORT NSString *const VERIFICATION_TYPE_REG_CODE;
FOUNDATION_EXPORT NSString *const VERIFICATION_TYPE_DVS_REG_TOKEN;

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
