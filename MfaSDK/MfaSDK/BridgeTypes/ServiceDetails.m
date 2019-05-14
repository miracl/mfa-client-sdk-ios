#import "ServiceDetails.h"

@implementation ServiceDetails
- (id) initWith:(NSString * ) name backendUrl:(NSString *) backendUrl logoUrl:(NSString *) logoUrl {
    self = [super init];
    if (self) {
        self.name = name;
        self.backendUrl = backendUrl;
        self.logoUrl = logoUrl;
    }
    return self;
}
@end
