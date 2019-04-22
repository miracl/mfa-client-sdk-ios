#import "Expiration.h"

@implementation Expiration

-(id) initWith:(int) nowTime expireTime:(int) expTime {
    self = [super init];
    if (self) {
        _expireTimeSeconds = expTime;
        _nowTimeSeconds = nowTime;
    }
    return self;
}

@end
