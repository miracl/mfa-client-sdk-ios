#import "MPinMFA.h"
#import <MpinCoreLib/mfa_sdk.h>
#import "Context.h"
#import <vector>
#import "User.h"

static MfaSDK mpin;
static BOOL isInitialized = false;

static NSLock * lock = [[NSLock alloc] init];

typedef MfaSDK::UserPtr         UserPtr;
typedef MfaSDK::Status          Status;
typedef sdk_non_tee::Context    Context;
typedef MfaSDK::Signature       Signature;

@implementation MPinMFA

+ (MpinStatus *) initSDK {
    if (isInitialized){
        return nil;
    }
    [lock lock];
    Status s = mpin.Init(StringMap(), sdk_non_tee::Context::Instance());
    isInitialized = true;
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus *) initSDKWithHeaders:(NSDictionary *)dictHeaders{
    if (isInitialized){
        return nil;
    }
    [lock lock];
    Status s = mpin.Init(StringMap(), sdk_non_tee::Context::Instance());
    isInitialized = true;
    [lock unlock];
    [MPinMFA AddCustomHeaders:dictHeaders];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (void) Destroy {
    [lock lock];
    mpin.Destroy();
    isInitialized = false;
    [lock unlock];
}

+ (void) ClearUsers {
    [lock lock];
    mpin.ClearUsers();
    [lock unlock];
}

+ (void) AddCustomHeaders:(NSDictionary *)dictHeaders {
    if(dictHeaders == nil) return;
    StringMap sm_CustomHeaders;
    for( id headerName in dictHeaders)
    {
        sm_CustomHeaders.Put( [headerName UTF8String], [dictHeaders[headerName] UTF8String] );
    }
    [lock lock];
    mpin.AddCustomHeaders(sm_CustomHeaders);
    [lock unlock];
}

+ (void) ClearCustomHeaders {
    [lock lock];
    mpin.ClearCustomHeaders();
    [lock unlock];
}

+ (void) AddTrustedDomain:(NSString *) domain {
    [lock lock];
    mpin.AddTrustedDomain( (domain == nil)?(""):([domain UTF8String]));
    [lock unlock];
}

+ (void) ClearTrustedDomains {
    [lock lock];
    mpin.ClearTrustedDomains();
    [lock unlock];
}

+ (MpinStatus*) TestBackend:(const NSString * ) url {
    [lock lock];
    Status s = mpin.TestBackend((url == nil)?(""):([url UTF8String]));
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) SetBackend:(const NSString * ) url {
    [lock lock];
    Status s = mpin.SetBackend((url == nil)?(""):([url UTF8String]));
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (Boolean) Logout:(const id<IUser>) user {
    [lock lock];
    Boolean b = mpin.Logout([((User *) user) getUserPtr]);
    [lock unlock];
    return b;
}

+ (Boolean) CanLogout:(const id<IUser>) user {
    [lock lock];
    Boolean b = mpin.CanLogout([((User *) user) getUserPtr]);
    [lock unlock];
    return b;
}

+ (NSString*) GetClientParam:(const NSString *) key {
    [lock lock];
    String value = mpin.GetClientParam([key UTF8String]);
    [lock unlock];
    return [NSString stringWithUTF8String:value.c_str()];
}

+ (id<IUser>) MakeNewUser:(const NSString *) identity {
    [lock lock];
    UserPtr userPtr = mpin.MakeNewUser([identity UTF8String]);
    [lock unlock];
    return [[User alloc] initWith:userPtr];
}

+ (id<IUser>) MakeNewUser: (const NSString *) identity deviceName:(const NSString *) devName {
    [lock lock];
    UserPtr userPtr = mpin.MakeNewUser([identity UTF8String], [devName UTF8String]);
    [lock unlock];
    return [[User alloc] initWith:userPtr];
}

+ (void) DeleteUser:(const id<IUser>) user {
    [lock lock];
    mpin.DeleteUser([((User *) user) getUserPtr]);
    [lock unlock];
}

+ (bool) isRegistrationTokenSet:(const id<IUser>)user
{
    return mpin.IsRegistrationTokenSet([((User *) user) getUserPtr]);
}

+ (id<IUser>) getIUserById:(NSString *) userId {
    if( userId == nil ) return nil;
    if ([@"" isEqualToString:userId]) return nil;
    
    NSArray * users = [MPinMFA listUsers];
    
    for (User * user in users)
        if ( [userId isEqualToString:[user getIdentity]] )
            return user;
    
    return nil;
}

+ (Boolean) IsUserExisting:(NSString *) identity customerId:(NSString *) customerId appId:(NSString *) appId {
    [lock lock];
    Boolean b = mpin.IsUserExisting([identity UTF8String], [customerId UTF8String], [appId UTF8String]);
    [lock unlock];
    return b;
}

+ (void) SetClientId:(NSString *) clientId {
    [lock lock];
    mpin.SetCID([clientId UTF8String]);
    [lock unlock];
}

+ (MpinStatus*) GetServiceDetails:(NSString *) url serviceDetails:(ServiceDetails **)sd {
    MfaSDK::ServiceDetails c_sd;
    [lock lock];
    Status s = mpin.GetServiceDetails([url UTF8String], c_sd);
    [lock unlock];
    *sd = [[ServiceDetails alloc] initWith:[NSString stringWithUTF8String:c_sd.name.c_str()]
                                backendUrl:[NSString stringWithUTF8String:c_sd.backendUrl.c_str()]
                                   logoUrl:[NSString stringWithUTF8String:c_sd.logoUrl.c_str()]];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (SessionDetails*) GetSessionDetails:(NSString *) accessCode {
    [lock lock];
    MfaSDK::SessionDetails sd;
    Status s = mpin.GetSessionDetails([accessCode UTF8String] , sd);
    [lock unlock];
    
    if (s.GetStatusCode() != Status::Code::OK)
        return nil;
    
    NSURL *redirectURI = [NSURL URLWithString: [NSString stringWithUTF8String:sd.redirectURI.c_str()]];
    
    return  [[SessionDetails alloc] initWith:[NSString stringWithUTF8String:sd.prerollId.c_str()]
                                     appName:[NSString stringWithUTF8String:sd.appName.c_str()]
                                  appIconUrl:[NSString stringWithUTF8String:sd.appIconUrl.c_str()]
                                  customerId:[NSString stringWithUTF8String:sd.customerId.c_str()]
                                customerName:[NSString stringWithUTF8String:sd.customerName.c_str()]
                             customerIconUrl:[NSString stringWithUTF8String:sd.customerIconUrl.c_str()]
                                registerOnly:sd.registerOnly
                                    clientId:[NSString stringWithUTF8String:sd.clientId.c_str()]
                                 redirectURI:redirectURI];
}

+ (MpinStatus*) AbortSession:(NSString *) accessCode {
    [lock lock];
    Status s = mpin.AbortSession( [accessCode UTF8String] );
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) GetAccessCode:(NSString *) authzUrl accessCode:(NSString **)ac {
    MfaSDK::String c_ac;
    [lock lock];
    Status s = mpin.GetAccessCode([authzUrl UTF8String], c_ac);
    [lock unlock];
    *ac = [NSString stringWithUTF8String:c_ac.c_str()];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+(MpinStatus *) StartVerification:(const id<IUser>)user clientId:(NSString *)clientId accessCode:(NSString *)accessCode
{
    [lock lock];
    Status s = mpin.StartVerification([(User *)user getUserPtr],
                                      [clientId UTF8String],
                                      [accessCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode()
                           errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+(MpinStatus *) FinishVerification:(const id<IUser>)user verificationCode:(NSString *)code verificationResult:(VerificationResult **)verificationResult
{
    [lock lock];
    
    MfaSDK::VerificationResult coreVerificationResult;
    Status s = mpin.FinishVerification([(User *)user getUserPtr], [code UTF8String], coreVerificationResult);

    *verificationResult = [[VerificationResult alloc] initWithActivationToken:[NSString stringWithUTF8String:coreVerificationResult.activationToken.c_str()]
                                                                   accessCode:[NSString stringWithUTF8String:coreVerificationResult.accessId.c_str()]
                                                                   expireTime:[NSNumber numberWithLong:coreVerificationResult.expireTime]];
    
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode()
                           errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartRegistration:(const id<IUser>)user accessCode:(NSString *) accessCode pmi:(NSString *) pmi {
    [lock lock];
    Status s = mpin.StartRegistration([((User *) user) getUserPtr], [accessCode UTF8String], [pmi UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) SetRegistrationToken:(const id<IUser>)user token:(NSString *) token
{
    [lock lock];
    Status s = mpin.SetRegistrationToken([((User *) user) getUserPtr], [token UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) RestartRegistration:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.RestartRegistration([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) ConfirmRegistration:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.ConfirmRegistration([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}


+ (MpinStatus*) FinishRegistration:(const id<IUser>)user pin0:(NSString *) pin0 pin1:(NSString *) pin1 {
    [lock lock];
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishRegistration([((User *) user) getUserPtr], c_multiFactor);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartAuthentication:(const id<IUser>)user accessCode:(NSString *) accessCode {
    [lock lock];
    Status s = mpin.StartAuthentication([((User *) user) getUserPtr], [accessCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus *) FinishAuthentication:(id<IUser>) user pin0:(NSString *) pin0  pin1:(NSString *) pin1  accessCode:(NSString *) ac {
    [lock lock];
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], c_multiFactor, [ac UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*)FinishAuthentication:(const id<IUser>)user pin:(NSString *) pin0 pin1:(NSString *) pin1 accessCode:(NSString *)ac authzCode:(NSString **)authzCode {
    MfaSDK::String c_authzCode;
    [lock lock];
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthentication([((User *) user) getUserPtr], c_multiFactor, [ac UTF8String] , c_authzCode);
    [lock unlock];
    *authzCode = [NSString stringWithUTF8String:c_authzCode.c_str()];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (NSMutableArray*) listUsers {
    NSMutableArray * users = [NSMutableArray array];
    std::vector<UserPtr> vUsers;
    mpin.ListUsers(vUsers);
    for (int i = 0; i<vUsers.size(); i++) {
        [users addObject:[[User alloc] initWith:vUsers[i]]];
    }
    return users;
}

+ (NSData*) HashDocument:(NSString *) strDoc
{
    String cStrHash = mpin.HashDocument([strDoc UTF8String]);
    
    return [[NSData alloc] initWithBytes:cStrHash.data() length:cStrHash.length()];
}

+ ( BOOL ) VerifyDocument:(NSString *) strDoc hash:(NSData *) hash
{
    // The result of HashDocument is not hex encoded so we need to hex decode the hash before comparing them
    NSString *hashStr = [[NSString alloc] initWithData:hash encoding:NSUTF8StringEncoding];
    String hexDecoded = util::HexDecode([hashStr UTF8String]);
    hash = [[NSData alloc] initWithBytes:hexDecoded.data() length:hexDecoded.length()];
    
    NSData *data = [MPinMFA HashDocument:strDoc];
    
    return [hash isEqualToData:data];
}

+ (MpinStatus*) Sign:(id<IUser>)user
        documentHash:(NSData *)hash
                pin0:(NSString *) pin0
                pin1:(NSString *) pin1
           epochTime:(double) epochTime
              result:(BridgeSignature **)result
{
    
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    MfaSDK::Signature   signResult;
    
    String cStrHash ( ((char  * )[hash bytes]), hash.length );
    
    Status status = mpin.Sign([((User *) user) getUserPtr], cStrHash, c_multiFactor, epochTime, signResult);
    
    *result = [[BridgeSignature alloc] initWith:[NSData dataWithBytes: signResult.hash.data() length:signResult.hash.length()]
                                         mpinId:[NSString stringWithUTF8String:signResult.mpinId.c_str()]
                                           strU:[NSData dataWithBytes: signResult.u.data() length:signResult.u.length()]
                                           strV:[NSData dataWithBytes: signResult.v.data() length:signResult.v.length()]
                                   strPublicKey:[NSData dataWithBytes: signResult.publicKey.data() length:signResult.publicKey.length()]
                                           dtas:[NSString stringWithUTF8String:signResult.dtas.c_str()]
               ];

    return [[MpinStatus alloc] initWith:(MPinStatus)status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:status.GetErrorMessage().c_str()]];
}

#pragma mark - DVS Second PIN -

+ (MpinStatus*) StartRegistrationDVS:(const id<IUser>)user
                                pin0:(NSString *) pin0
                                pin1:(NSString *) pin1
{
    [lock lock];
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.StartRegistrationDVS([((User *) user) getUserPtr], c_multiFactor);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) FinishRegistrationDVS:(const id<IUser>)user
                               pinDVS:(NSString *) pinDVS
                                  nfc:(NSString *) nfc
{
    
    [lock lock];
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pinDVS UTF8String]);
    if ( nfc != nil )
    {
        c_multiFactor.push_back([nfc UTF8String]);
    }
    Status s = mpin.FinishRegistrationDVS([((User *) user) getUserPtr], c_multiFactor);
    [lock unlock];
    
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];

}

+ (MpinStatus*) StartAuthenticationOTP:(const id<IUser>)user {
    [lock lock];
    Status s = mpin.StartAuthenticationOTP([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) FinishAuthenticationOTP:(const id<IUser>)user pin:(NSString *) pin otp:(OTP**)otp {
    MfaSDK::OTP c_otp;
    [lock lock];
    Status s = mpin.FinishAuthenticationOTP([((User *) user) getUserPtr], [pin UTF8String], c_otp);
    [lock unlock];
    *otp = [[OTP alloc] initWith:[[MpinStatus alloc] initWith:(MPinStatus)c_otp.status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:c_otp.status.GetErrorMessage().c_str()]]
                             otp:[NSString stringWithUTF8String:c_otp.otp.c_str()]
                      expireTime:c_otp.expireTime
                      ttlSeconds:c_otp.ttlSeconds
                         nowTime:c_otp.nowTime];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

#pragma mark - RegCode -

+ (MpinStatus*) StartRegistration:(const id<IUser>)user accessCode:(NSString *) accessCode regCode:(NSString *) regCode pmi:(NSString *) pmi{
    [lock lock];
    Status s = mpin.StartRegistration([((User *) user) getUserPtr], [accessCode UTF8String], [pmi UTF8String], [regCode UTF8String]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*) StartAuthenticationRegCode:(const id<IUser>)user{
    [lock lock];
    Status s = mpin.StartAuthenticationRegCode([((User *) user) getUserPtr]);
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

+ (MpinStatus*)FinishAuthenticationRegCode:(const id<IUser>)user pin:(NSString *) pin0 pin1:(NSString *) pin1 regCode:(RegCode **)regCode{
    [lock lock];
    MfaSDK::RegCode     c_regCode = MfaSDK::RegCode();
    MfaSDK::MultiFactor c_multiFactor = MfaSDK::MultiFactor([pin0 UTF8String]);
    if ( pin1 != nil )
    {
        c_multiFactor.push_back([pin1 UTF8String]);
    }
    Status s = mpin.FinishAuthenticationRegCode([((User *) user) getUserPtr], c_multiFactor, c_regCode);
    *regCode = [[RegCode alloc] initWith:[[MpinStatus alloc] initWith:(MPinStatus)c_regCode.status.GetStatusCode() errorMessage:[NSString stringWithUTF8String:c_regCode.status.GetErrorMessage().c_str()]]
                                        otp:[NSString stringWithUTF8String:c_regCode.otp.c_str()]
                                 expireTime:c_regCode.expireTime
                                 ttlSeconds:c_regCode.ttlSeconds
                                    nowTime:c_regCode.nowTime];
    [lock unlock];
    return [[MpinStatus alloc] initWith:(MPinStatus)s.GetStatusCode() errorMessage:[NSString stringWithUTF8String:s.GetErrorMessage().c_str()]];
}

@end
