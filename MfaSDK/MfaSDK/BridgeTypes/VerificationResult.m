#import "VerificationResult.h"

@implementation VerificationResult

-(instancetype) initWithActivationToken:(NSString *)activationToken
                             accessCode:(NSString *)accessCode
                             expireTime:(NSNumber *)expireTime
{
    self = [super init];
    if(self){
        self.activationToken = activationToken;
        self.accessCode = accessCode;
        self.expireTime = expireTime;
    }
    return self;
}

@end

