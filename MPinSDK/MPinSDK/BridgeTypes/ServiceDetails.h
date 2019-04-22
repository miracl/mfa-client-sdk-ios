#import <Foundation/Foundation.h>

@interface ServiceDetails : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * backendUrl;
@property (nonatomic, strong) NSString * logoUrl;
- (id) initWith:(NSString * ) name backendUrl:(NSString *) backendUrl logoUrl:(NSString *) logoUrl;
@end
