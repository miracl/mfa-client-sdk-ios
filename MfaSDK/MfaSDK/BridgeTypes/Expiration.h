#import <Foundation/Foundation.h>

@interface Expiration : NSObject
@property ( nonatomic, readonly ) int expireTimeSeconds;
@property ( nonatomic, readonly ) int nowTimeSeconds;

-(id) initWith:(int) nowTime expireTime:(int) expTime;

@end
