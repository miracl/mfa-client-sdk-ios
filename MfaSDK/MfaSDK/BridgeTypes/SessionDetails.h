#import <Foundation/Foundation.h>

@interface SessionDetails : NSObject
@property (nonatomic, retain) NSString * prerollId;
@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) NSString * appIconUrl;
@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * customerName;
@property (nonatomic, retain) NSString * customerIconUrl;
@property (nonatomic)         BOOL       registerOnly;
@property (nonatomic, retain) NSString * clientId;
@property (nonatomic, retain) NSURL *redirectURI;

- (id) initWith:(NSString * ) prerollId
        appName:(NSString *) appName
     appIconUrl:(NSString *) appIconUrl
     customerId:(NSString *) customerId
   customerName:(NSString *) customerName
customerIconUrl:(NSString *) customerIconUrl
   registerOnly:(BOOL)registerOnly
       clientId:(NSString *) clientId
    redirectURI:(NSURL *)redirectURI;

@end
