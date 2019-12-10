#import <Foundation/Foundation.h>
#import "IUser.h"
#import "MpinStatus.h"
#import "OTP.h"
#import "SessionDetails.h"
#import "ServiceDetails.h"
#import "BridgeSignature.h"
#import "MultiFactor.h"
#import "RegCode.h"
#import "VerificationResult.h"

@interface MPinMFA : NSObject

+ (MpinStatus *) initSDK;
+ (MpinStatus *) initSDKWithHeaders:(NSDictionary *)dictHeaders;
+ (void) Destroy;
+ (void) AddCustomHeaders:(NSDictionary *)dictHeaders;
+ (void) ClearCustomHeaders;

+ (void) AddTrustedDomain:(NSString *) domain;
+ (void) ClearTrustedDomains;

+ (MpinStatus*) TestBackend:(const NSString*)url;
+ (MpinStatus*) SetBackend:(const NSString*)url;

+ (id<IUser>) MakeNewUser:(const NSString*)identity;
+ (id<IUser>) MakeNewUser:(const NSString*)identity deviceName:(const NSString*)devName;
+ (Boolean) IsUserExisting:(NSString *) identity customerId:(NSString *) customerId appId:(NSString *) appId;
+ (void) DeleteUser:(const id<IUser>)user;
+ (bool) isRegistrationTokenSet:(const id<IUser>)user;

+ (void) ClearUsers;

+ (Boolean) Logout:(const id<IUser>)user;
+ (Boolean) CanLogout:(const id<IUser>)user;

+ (id<IUser>) getIUserById:(NSString *) userId;
+ (NSString *) GetClientParam:(const NSString *) key;

+ (MpinStatus*) GetServiceDetails:(NSString *) url
                   serviceDetails:(ServiceDetails **)sd;
+ (void) SetClientId:(NSString *) clientId;
+ (SessionDetails*) GetSessionDetails:(NSString *) accessCode;
+ (MpinStatus*) AbortSession:(NSString *) accessCode;

+ (MpinStatus*) GetAccessCode:(NSString *) authzUrl accessCode:(NSString **)ac;

+ (MpinStatus*) RestartRegistration:(const id<IUser>)user;
+ (MpinStatus*) SetRegistrationToken:(const id<IUser>)user
                               token:(NSString *) token;

+ (MpinStatus*) StartRegistration:(const id<IUser>)user
                       accessCode:(NSString *) accessCode
                              pmi:(NSString *) pmi;

+ (MpinStatus*) StartRegistration:(const id<IUser>)user
                       accessCode:(NSString *) accessCode
                          regCode:(NSString *) regCode
                              pmi:(NSString *) pmi;

+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user;
+ (MpinStatus*) FinishRegistration:(const id<IUser>)user
                              pin0:(NSString *) pin0
                              pin1:(NSString *) pin1;

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user
                         accessCode:(NSString *) accessCode;

+ (MpinStatus*) FinishAuthentication:(id<IUser>)user
                                pin0:(NSString *) pin0
                                pin1:(NSString *) pin1
                          accessCode:(NSString *)ac;

+ (MpinStatus*) FinishAuthentication:(const id<IUser>)user
                                 pin:(NSString *) pin
                                pin1:(NSString *) pin1
                          accessCode:(NSString *)ac
                           authzCode:(NSString **)authzCode;



+ (MpinStatus*) StartAuthenticationRegCode:(const id<IUser>)user;

+ (MpinStatus*) FinishAuthenticationRegCode:(const id<IUser>)user
                                        pin:(NSString *) pin0
                                       pin1:(NSString *) pin1
                                    regCode:(RegCode **)regCode;

+ (MpinStatus*) StartRegistrationDVS:(const id<IUser>) user
                                pin0:(NSString *) pin0
                                pin1:(NSString *) pin1;

+ (MpinStatus*) FinishRegistrationDVS:(const id<IUser>)user
                               pinDVS:(NSString *) pinDVS
                                  nfc:(NSString *) nfc;

+ (NSData*) HashDocument:(NSString *) strDoc;
+ (BOOL) VerifyDocument:(NSString *) strDoc
                   hash:(NSData *)hash;

+ (MpinStatus*) Sign:(id<IUser>)user
        documentHash:(NSData *)hash
                pin0:(NSString *) pin0
                pin1:(NSString *) pin1
           epochTime:(double) epochTime
              result:(BridgeSignature **)result;

+ (MpinStatus*) StartAuthenticationOTP:(const id<IUser>)user;
+ (MpinStatus*) FinishAuthenticationOTP:(const id<IUser>)user
                                    pin:(NSString *)pin
                                    otp:(OTP**)otp;
+ (NSMutableArray*) listUsers;

+(MpinStatus *) StartVerification:(const id<IUser>)user
                         clientId:(NSString *)clientId
                       accessCode:(NSString *)accessCode;

+(MpinStatus *) FinishVerification:(const id<IUser>)user
                  verificationCode:(NSString *)code
                verificationResult:(VerificationResult **)verificationResult;
@end
