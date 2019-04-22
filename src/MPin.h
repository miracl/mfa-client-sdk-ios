#import <Foundation/Foundation.h>
#import "IUser.h"
#import "MpinStatus.h"
#import "OTP.h"

@interface MPin : NSObject

+ (void) initSDK;
+ (void) initSDKWithHeaders:(NSDictionary *)dictHeaders;
+ (void) Destroy;
+ (void) AddCustomHeaders:(NSDictionary *)dictHeaders;
+ (void) ClearCustomHeaders;

+ (void) AddTrustedDomain:(NSString *) domain;
+ (void) ClearTrustedDomains;

+ (MpinStatus*) TestBackend:(const NSString*)url;
+ (MpinStatus*) SetBackend:(const NSString*)url;

+ (id<IUser>) MakeNewUser:(const NSString*)identity;
+ (id<IUser>) MakeNewUser:(const NSString*)identity
              deviceName:(const NSString*)devName;
+ (Boolean) IsUserExisting:(NSString *) identity;
+ (void) DeleteUser:(const id<IUser>)user;
+ (void) ClearUsers;

+ (Boolean) Logout:(const id<IUser>)user;
+ (Boolean) CanLogout:(const id<IUser>)user;

+ (id<IUser>) getIUserById:(NSString *) userId;
+ (NSString *) GetClientParam:(const NSString *) key;


+ (MpinStatus*) StartRegistration:(const id<IUser>)user;
+ (MpinStatus*) StartRegistration:(const id<IUser>)user userData:(NSString *) userData;
+ (MpinStatus*) StartRegistration:(const id<IUser>)user activateCode:(NSString *) activateCode;
+ (MpinStatus*) StartRegistration:(const id<IUser>)user activateCode:(NSString *) activateCode userData:(NSString *) userData;
+ (MpinStatus*) FinishRegistration:(const id<IUser>)user pin:(NSString *) pin;

+ (MpinStatus*) RestartRegistration:(const id<IUser>)user;
+ (MpinStatus*) RestartRegistration:(const id<IUser>)user userData:(NSString *) userData;

+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user;
+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user  pushNotificationIdentifier:(NSString *) pushNotificationIdentifier;

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user;
+ (MpinStatus*) CheckAccessNumber:(NSString *)an;
+ (MpinStatus*) FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin;
+ (MpinStatus*) FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin authResultData:(NSString **)authResultData;
+ (MpinStatus*) FinishAuthenticationOTP:(id<IUser>)user pin:(NSString *) pin otp:(OTP**)otp;
+ (MpinStatus*) FinishAuthenticationAN:(id<IUser>)user pin:(NSString *) pin accessNumber:(NSString *)an;

+ (NSMutableArray*) listUsers;
+ (NSMutableArray*) listUsers:( NSString *) backendURL;
+ (NSMutableArray*) listBackends;

@end
