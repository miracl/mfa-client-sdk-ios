

#import <Foundation/Foundation.h>

@interface VerificationResult : NSObject

@property (nonatomic, strong) NSString *activationToken;
@property (nonatomic, strong) NSString *accessCode;
@property (nonatomic, strong) NSNumber *expireTime;

-(instancetype) initWithActivationToken:(NSString *)activationToken
                             accessCode:(NSString *)accessCode
                             expireTime:(NSNumber *)expireTime;

@end
