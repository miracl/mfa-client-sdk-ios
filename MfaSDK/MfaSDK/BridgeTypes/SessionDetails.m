#import "SessionDetails.h"

@implementation SessionDetails

- (id) initWith:(NSString * ) prerollId
        appName:(NSString *) appName
     appIconUrl:(NSString *) appIconUrl
     customerId:(NSString *) customerId
   customerName:(NSString *) customerName
customerIconUrl:(NSString *) customerIconUrl
   registerOnly:(BOOL)registerOnly
       clientId:(NSString *) clientId
    redirectURI:(NSURL *)redirectURI
{

    self = [super init];
    if (self) {
        self.prerollId = prerollId;
        self.appName = appName;
        self.appIconUrl = appIconUrl;
        self.customerId = customerId;
        self.customerName = customerName;
        self.customerIconUrl = customerIconUrl;
        self.registerOnly = registerOnly;
        self.clientId = clientId;
        self.redirectURI = redirectURI;
    }
    return self;
}

@end
