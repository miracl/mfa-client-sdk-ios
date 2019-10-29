#import "VerificationResult.h"

@implementation VerificationResult

-(instancetype) initWithActivationToken:(NSString *)activationToken
                          andAccessCode:(NSString *)accessCode
{
    self = [super init];
    if(self){
        self.activationToken = activationToken;
        self.accessCode = accessCode;
    }
    return self;
}

@end

