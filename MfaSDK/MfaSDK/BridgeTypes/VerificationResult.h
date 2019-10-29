

#import <Foundation/Foundation.h>

@interface VerificationResult : NSObject

@property (nonatomic, strong) NSString *activationToken;
@property (nonatomic, strong) NSString *accessCode;

-(instancetype) initWithActivationToken:(NSString *)activationToken
                          andAccessCode:(NSString *)accessCode;

@end
