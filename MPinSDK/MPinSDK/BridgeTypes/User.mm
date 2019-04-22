#import "User.h"

NSString *const VERIFICATION_TYPE_EMAIL = @"em";
NSString *const VERIFICATION_TYPE_CUSTOM = @"pv";
NSString *const VERIFICATION_TYPE_REG_CODE = @"rc";
NSString *const VERIFICATION_TYPE_DVS_REG_TOKEN = @"dvs";

@interface User() {
    UserPtr userPtr;
}

@end

@implementation User

- (id) initWith:(UserPtr) usrPtr {
    self = [super init];
    if (self) {
        userPtr = usrPtr;
    }
    return self;
}

-(NSString *) getIdentity {
    return [NSString stringWithUTF8String:userPtr->GetId().c_str()];
}

-(UserState) getState {
    return (UserState)userPtr->GetState();
}

-(UserPtr) getUserPtr {
    return userPtr;
}

- (NSString*) getBackend {
    return [NSString stringWithUTF8String:userPtr->GetBackend().c_str()];
}

- (NSString*) getCustomerId {
    return [NSString stringWithUTF8String:userPtr->GetCustomerId().c_str()];
}

- (NSString*) getAppId {
    return [NSString stringWithUTF8String:userPtr->GetAppId().c_str()];
}

- (NSString*) getMPinId  {
    return [NSString stringWithUTF8String:userPtr->GetMPinId().c_str()];
}

- (Expiration*) getRegistrationExpiration {
    return [[Expiration alloc] initWith:userPtr->GetRegistrationExpiration().nowTimeSeconds expireTime:userPtr->GetRegistrationExpiration().expireTimeSeconds];
}

- ( int ) getPINLength {
    return userPtr->GetPinLength();
}

- (bool) canSign  {
    return userPtr->CanSign();
}

- (NSString*) getVerificationType {
   return [NSString stringWithUTF8String:userPtr->GetVerificationType().c_str()];
}


@end
