
# iOS Mobile SDK for MIRACL MFA Platform 

## Building the MFA Mobile SDK for iOS

### Prerequisites

1. Download and install Xcode 10.0 or higher

### Building the MFA Mobile SDK

1. Navigate to `<mfa-client-sdk-ios>/MfaSDK`
2. Execute `pod install`
3. Open the `MfaSDK.xcworkspace`
4. Select `MfaSdk` build scheme from the top bar where the build schemes are listed
5. Select *Product->Build* from the Xcode menu.

There is also another build target named `MfaSdkAggregate`. It will build a version of the SDK which contains all architectures. This target is meant to be built only when a cocoapods release of the SDK is made. To build a release version of the SDK follow these steps:

1. Navigate to `<mfa-client-sdk-ios>/MfaSDK`
2. Execute `pod install`
3. Open the `MfaSDK.xcworkspace`
4. Select `MfaSdkAggregate` build scheme from the top bar where the build schemes are listed
5. Select *Product->Build* from the Xcode menu.

The generated `.framework` file can be found by navigating within the `Project Navigator in Xcode` to `MfaSDK->Products->Right click on MfaSdk.framework->Show in finder`. In the `Finder` window you will find the `MfaSdk.framework` in the `Prod-universal` folder.

For further details, see [MIRACL MFA Mobile SDK for iOS Documentation](https://devdocs.trust.miracl.cloud/mobile-sdk-instructions/)

## iOS SDK API for MIRACL MFA (`MPinMFA`)

This flavor of the SDK should be used to build apps that authenticate users against the [_MIRACL MFA Platform_](https://trust.miracl.cloud).
The `MPinMFA` object needs to be initialized first.
Most of the methods return a `MpinStatus` object as status `OK` means it passed successfully.

Many methods expect the provided `user` object to be in a certain state, and if it is not, the method will return status `FLOW_ERROR`

##### `(MpinStatus *) initSDK;`
This method constructs/initializes the SDK object.

##### `(MpinStatus *) initSDKWithHeaders: (NSDictionary*) dictHeaders;`
This method constructs/initializes the SDK object.
The `dictHeaders` parameter allows the caller to pass additional dictionary of custom headers, which will be added to any HTTP request that the SDK executes.

**Note that after this initialization the SDK will not be ready for usage until `SetBackend` is called with a valid _Server URL_.**

##### `(void) AddCustomHeaders: (NSDictionary*) dictHeaders;`
This method allows the SDK user to set a map of custom headers, which will be added to any HTTP request that the SDK executes.
The `dictHeaders` parameter is a dictionary of header names mapped to their respective value.
Subsequent calls of this method will add headers on top of the already added ones.

##### `(void) ClearCustomHeaders;`
This method will clear all the currently set custom headers.

##### `(void) AddTrustedDomain: (NSString *) domain;`
For better security, the SDK user might want to limit the SDK to make outgoing requests only to URLs that belong to one or more trusted domains.
This method can be used to add such trusted domains, one by one.
When trusted domains are added, the SDK will verify that any outgoing request is done over the `https` protocol and the host belongs to one of the trusted domains.
If for some reason a request is about to be done to a non-trusted domain, the SDK will return Status `UNTRUSTED_DOMAIN_ERROR`.

##### `(void) ClearTrustedDomains;`
This method will clear all the currently set trusted domains.

##### `(void) SetClientId: (NSString*) clientId;`
This method will set a specific _Client/Customer ID_ which the SDK should use when sending requests to the backend.
The MIRACL MFA Platform generates _Client IDs_ (sometimes also referred as _Customer IDs_) for the platform customers.
The customers can see those IDs through the _Platform Portal_.
When customers use the SDK to build their own applications to authenticate users using the Platform, the _Client ID_ has to be provided using this method. 

##### `(MpinStatus*) TestBackend: (const NSString*) url;`
This method will test whether `url` is a valid back-end URL by trying to retrieve Client Settings from it.
If the back-end URL is a valid one, the method will return status `OK`.

##### `(MpinStatus*) SetBackend: (const NSString*) url;`
This method will change the currently configured back-end in the SDK.
`url` is the new back-end URL that should be used.
If successful, the method will return status `OK`.

##### `(id<IUser>) MakeNewUser: (const NSString*) identity;`
##### `(id<IUser>) MakeNewUser: (const NSString*) identity deviceName: (const NSString*) devName;`
This method creates a new user object. The user object represents an end-user of the Miracl authentication.
The user has its own unique identity, which is passed as the `identity` parameter to this method.
Additionally, an optional `deviceName` might be specified. The _Device Name_ is passed to the RPA, which might store it and use it later to determine which _M-Pin ID_ is associated with this device.
The returned value is a newly created user instance. The User class itself looks like this:
```objective-c
typedef NS_ENUM(NSInteger, UserState)
{
    INVALID = 0,
    STARTED_REGISTRATION,
    ACTIVATED,
    REGISTERED,
    BLOCKED
};

@protocol IUser <NSObject>

- (NSString*) getIdentity;
- (UserState) getState;
- (NSString*) getBackend;
- (NSString*) getCustomerId;
- (NSString*) getAppId;
- (NSString*) getMPinId;
- (Expiration*) getRegistrationExpiration;
- (int) getPinLength;
- (BOOL) canSign;

@end
```

The newly created user is in the `INVALID` user state.

##### `(Boolean) IsUserExisting: (NSString*) identity customerId: (NSString*) customerId appId: (NSString*) appId;`
This method will return `TRUE` if there is a user with the given properties.
If no such user is found, the method will return `FALSE`.

In the MIRACL MFA Platform end-users are registered for a given Customer.
Therefore, same identity might be registered for two different customers, and two different User objects will be present for the two different customers, but with the same `identity`.
When checking whether the user exists, one should specify also the `customerId`.
The `appId` parameter is for future use and should be passed as an empty string.

##### `(id<IUser>) getIUserById:(NSString *) userId;`
This method returns an IUser object for the provided unique identity name string if any. If nil or an empty string is passed as a parameter, nil will be returned.

##### `(void) DeleteUser: (const id<IUser>) user;`
This method deletes a user from the users list that the SDK maintains.
All the user data including its _M-Pin ID_, its state and _M-Pin Token_ will be deleted.
A new user with the same identity can be created later with the `MakeNewUser` method.

##### `(NSMutableArray*) listUsers;`
This method populates the provided list with all the users that are associated with the currently set backend.
Different users might be in different states, reflecting their registration status.
The method will return status `OK` on success and `FLOW_ERROR` if no backend is set through the `Init()` or `SetBackend()` methods.

##### `(MpinStatus*) GetServiceDetails: (NSString*) url serviceDetails: (ServiceDetails**) sd;`
After scanning a QR Code from the platform login page, the app should extract the URL from it and call this method to retrieve the _Service Details_.
The service details include the _backend URL_ which needs to be set back to the SDK in order connect it to the platform.
This method could be called even before the SDK has been initialized, or alternatively the SDK could be initialized without setting a backend, and `SetBackend` could be used after the backend URL has been retrieved through this method.
The returned `ServiceDetails` look as follows:
```objective-c
@interface ServiceDetails : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* backendUrl;
@property (nonatomic, strong) NSString* logoUrl;

@end
```
* `name` is the service readable name
* `backendUrl` is the URL of the service backend. This URL has to be set either via the SDK `initSDK` method or using  `SetBackend`
* `logoUrl` is the URL of the service logo. The logo is a UI element that could be used by the app.

##### `(SessionDetails*) GetSessionDetails: (NSString*) accessCode;`
This method could be optionally used to retrieve details regarding a browser session when the SDK is used to authenticate users to an online service, such as the _MIRACL MFA Platform_.
In this case an `accessCode` is transferred to the mobile device out-of-band e.g. via scanning a graphical code.
The code is then provided to this method to get the session details.
This method will also notify the backend that the `accessCode` was retrieved from the browser session.
The returned `SessionDetails` look as follows:
```objective-c
@interface SessionDetails : NSObject

@property (nonatomic, retain) NSString* prerollId;
@property (nonatomic, retain) NSString* appName;
@property (nonatomic, retain) NSString* appIconUrl;
@property (nonatomic, retain) NSString* customerId;
@property (nonatomic, retain) NSString* customerName;
@property (nonatomic, retain) NSString* customerIconUrl;

@end
}
```
During the online browser session an optional user identity might be provided meaning that this is the user that wants to register/authenticate to the online service.
* The `prerollId` will carry that user ID, or it will be empty if no such ID was provided.
* `appName` is the name of the web application to which the service will authenticate the user.
* `appIconUrl` is the URL from which the icon for web application could be downloaded.
* `customerId` is the ID of the Customer (the one whom the application belongs to) for the current session.
* `customerName` is the name of the Customer (the one whom the application belongs to) for the current session.
* `customerIconUrl` is the Customer icon URL for the  for the current session. Note that this URL might not be set.

##### `(MpinStatus*) AbortSession: (NSString*) accessCode;`
This method should be used to inform the Platform that the current authentication/registration session has been aborted.
A session starts with obtaining the _Access Code_, usually after scanning and decoding a graphical image, such as QR Code.
Then the mobile client might retrieve the session details using `GetSessionDetails`, after which it can either start registering a new end-user or start authentication.
This process might be interrupted by either the end-user disagreeing on the consent page, or by just hitting a Back button on the device, or by even closing the app.
For all those cases, it is recommended to use `AbortSession` to inform the Platform.

##### `(MpinStatus*) GetAccessCode: (NSString*) authzUrl accessCode: (NSString**) accessCode;`
This method should be used when the mobile app needs to login an end-user into the app itself.
In this case there's no browser session involved and the Access Code cannot be obtained by scanning an image from the browser.
Instead, the mobile app should initially get from its backend an _Authorization URL_. This URL could be formed at the app backend using one of the _MFA Platform SDK_ flavors.
When the mobile app has the Authorization URL, it can pass it to this method as `authzUrl`, and get back an `accessCode` that can be further used to register or authenticate end-users.
Note that the Authorization URL contains a parameter that identifies the app.
This parameter is validated by the Platform and it should correspond to the Customer ID, set via `SetClientId`.

##### `+(MpinStatus *) StartVerification:(const id<IUser>)user clientId:(NSString *)clientId redirectURI:(NSURL *)redirectURI accessCode:(NSString *)accessCode;`
This method initializes the default user identity verification process. A verification means confirming that user identity is owned by the user itself.
The default user identity verification in the _MIRACL MFA Platform_ sends an email message that contains confirmation URL. When clicked it opens the authentication application (Universal link entitlement must be obtained from Apple) and `FinishVerification` should be called to finalize the verification. Note that the identity is created on the device where the email URL is opened.

The SDK sends the necessary requests to the back-end service.
The State of the User instance will change to `STARTED_VERIFICATION`.
The status will indicate whether the operation is successful or not.

##### `+(MpinStatus *) FinishVerification:(const id<IUser>)user verificationCode:(NSString *)code verificationResult:(VerificationResult **)verificationResult;`
This method is used to finalize the process of the default user identity verification.
The `verificationCode` has to be obtained from the verification URL received in the confirmation email as a query parameter.

The `VerificationResult` class returned as a reference variable has the following form:

```
@property (nonatomic, strong) NSString *activationToken;
@property (nonatomic, strong) NSString *accessCode;
```

The `accessCode` is a session identifier which you could control the session with by `AbortSession`, `GetSessionDetails`. 
The `activationToken` is a code which indicates that the user identity is already verified and is used to start the identity registration.


##### `(MpinStatus*) StartRegistration: (const id<IUser>) user accessCode: (NSString*) accessCode pmi: (NSString*) pmi;`
##### `(MpinStatus*) StartRegistration: (const id<IUser>) user accessCode: (NSString*) accessCode regCode: (NSString*) regCode pmi: (NSString*) pmi;`
This method initializes the registration for a User that has already been verified.
The SDK starts the Setup flow, sending the necessary requests to the back-end service.
The State of the User instance will change to `STARTED_REGISTRATION`.
The status will indicate whether the operation was successful or not.
During this call, an _M-Pin ID_ for the end-user will be issued by the Platform and stored within the user object.

The `accessCode` should be obtained from a browser session, and session details are retrieved before starting the registration.
This way the mobile app can show to the end-user the respective details for the customer, which the identity is going to be associated to.

The `regCode` is a code which value indicates that the user identity is already verified. It could be obtained as `activationToken` value of `VerificationResult` object from a successfull call to `FinishVerification` method using the default identity verification or using a bootstrap code. 

##### `(MpinStatus*) RestartRegistration: (const id<IUser>) user;`
This method re-initializes the registration process for a user, where registration has already started.
The difference between this method and `StartRegistration` is that it will not generate a new _M-Pin ID_, but will use the one that was already generated.
Besides that, the methods follow the same procedures, such as getting the RPA to re-start the user identity verification procedure of sending a verification email to the user.

##### `(MpinStatus*) ConfirmRegistration: (const id<IUser>) user;`
This method allows the application to check whether the user identity verification process has been finalized or not.
The provided `user` object is expected to be either in the `STARTED_REGISTRATION` state or in the `ACTIVATED` state.
The latter is possible if the RPA activated the user immediately with the call to `StartRegistration` and no verification process was started.
During the call to `ConfirmRegistration` the SDK will make an attempt to retrieve _Client Key_ for the user.
This attempt will succeed if the user has already been verified/activated but will fail otherwise.
The method will return status `OK` if the Client Key has been successfully retrieved and `IDENTITY_NOT_VERIFIED` if the identity has not been verified yet.
If the method has succeeded, the application is expected to get the desired PIN/secret from the end-user and then call `FinishRegistration`, and provide the PIN.

##### `(MpinStatus*) FinishRegistration: (const id<IUser>) user pin0: (NSString*) pin0 pin1: (NSString*) pin1;`
This method finalizes the user registration process.
It extracts the _M-Pin Token_ from the _Client Key_ for the provided `pin` (secret), and then stores the token in the secure storage.
On successful completion, the user state will be set to `REGISTERED` and the method will return status `OK`.
Additional authentication factor can be passed as `pin1`. If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) StartAuthentication: (const id<IUser>) user accessCode: (NSString*) accessCode;`
This method starts the authentication process for a given `user`.
It attempts to retrieve the _Time Permits_ for the user, and if successful, will return Status `OK`.
If they cannot be retrieved, the method will return Status `REVOKED`.
If this method is successfully completed, the app should read the PIN/secret from the end-user and call one of the `FinishAuthentication` variants to authenticate the user.

The `accessCode` is retrieved out-of-band from a browser session when the user has to be authenticated to an online service, such as the _MIRACL MFA Platform_.
The SDK will notify the platform that authentication associated with the given `accessCode` has started for the provided user. 

##### `(MpinStatus*) StartAuthenticationOTP: (const id<IUser>) user;`
This method will start the authentication for OTP generation.
It resembles the `StartAuthentication` method, but the difference is that in this case no `accessCode` is required.
OTP generation is not tied to a specific Customer Application session.

##### `(MpinStatus*) StartAuthenticationRegCode: (const id<IUser>) user;`
This method will start the authentication for _Registration Code_ generation.
It resembles the `StartAuthentication` method, but the difference is that in this case no `accessCode` is required.
Registration Code generation is not tied to a specific Customer Application session.

##### `(MpinStatus*) FinishAuthentication: (id<IUser>) user pin0: (NSString*) pin0 pin1: (NSString*) pin1 accessCode: (NSString*) accessCode;`
This method authenticates the end-user for logging into a Web App in a browser session.
The `user` to be authenticated is passed as a parameter, along with his/her secret (`pin0`).
The `accessCode` associates the authentication with the browser session from which it was obtained.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

The returned status might be:
* `OK` - Successful authentication.
* `INCORRECT_PIN` - The authentication failed because of incorrect PIN/secret.
After the 3rd unsuccessful authentication attempt, the method will still return `INCORRECT_PIN` but the User State will be set to `BLOCKED`.

##### `(MpinStatus*) FinishAuthentication: (const id<IUser>) user pin: (NSString*) pin pin1: (NSString*) pin1 accessCode: (NSString*) accessCode authzCode: (NSString**) authzCode;`
This method authenticates an end-user in a way that allows the mobile app to log the user into the app itself after verifying the authentication against its own backend. 
When using this flow, the mobile app would first retrieve the `accessCode` using the `GetAccessCode` method,
and when authentication the user it will receive an _Authorization Code_, `authzCode`.
Using this Authorization Code, the mobile app can make a request to its own backend, so the backend can validate it using one of the _MFA Platform SDK_ flavors,
and create a session token.
This token could be used further as an authentication element in the communication between the app and its backend.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) FinishAuthenticationOTP: (const id<IUser>) user pin: (NSString*) pin otp: (OTP**) otp;`
This method performs end-user authentication for OTP generation.
The authentication process is similar to `FinishAuthentication`, but as a result the MFA Platform issues an OTP instead of logging the user into an application.
The returned status is analogical to the `FinishAuthentication` method, but in addition to that, an `OTP` object is returned.
The `OTP` class looks like this:
```objective-c
@interface OTP : NSObject

@property (nonatomic, retain, readonly) MpinStatus* status;
@property (nonatomic, retain, readonly) NSString* otp;
@property (atomic, readonly) long expireTime;
@property (atomic, readonly) int ttlSeconds;
@property (atomic, readonly) long nowTime;

@end
```
* The `otp` string is the issued OTP.
* The `expireTime` is the MIRACL MFA system time when the OTP will expire.
* The `ttlSeconds` is the expiration period in seconds.
* The `nowTime` is the current MIRACL MFA system time.
* `status` is the status of the OTP generation. The status will be `OK` if the OTP was successfully generated, or `FLOW_ERROR` if not.

##### `(MpinStatus*) FinishAuthenticationRegCode: (const id<IUser>) user pin: (NSString*) pin0 pin1: (NSString*) pin1 regCode: (RegCode**) regCode;`
This method performs end-user authentication for _Registration Code_ generation.
The authentication process is similar to `FinishAuthentication`, but as a result the MFA Platform issues a Registration Code instead of logging the user into an application.
The returned status is analogical to the `FinishAuthentication` method, but in addition to that, an `RegCode` object is returned.
The `RegCode` class is basically identical to the `OTP` class, and looks like this:
```objective-c
@interface RegCode : NSObject

@property (nonatomic, retain, readonly) MpinStatus* status;
@property (nonatomic, retain , readonly) NSString* otp;
@property (atomic, readonly) long expireTime;
@property (atomic, readonly) int ttlSeconds;
@property (atomic, readonly) long nowTime;

@end
```
* The `otp` string is the issued Registration Code, which is a one-time code in its nature.
* The `expireTime` is the MIRACL MFA system time when the code will expire.
* The `ttlSeconds` is the expiration period in seconds.
* The `nowTime` is the current MIRACL MFA system time.
* `status` is the status of the Registration Code generation. The status will be `OK` if the Registration Code was successfully generated, or `FLOW_ERROR` if not.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) StartRegistrationDVS: (const id<IUser>) user pin0:(NSString *) pin0 pin1:(NSString *) pin1;`
This method starts the user registration for the _DVS (Designated Verifier Signature)_ functionality.

The DVS functionality allows a customer application to verify signatures of documents/transactions, signed by the end-user.

It is a separate process than the registration for authentication, while a user should be authenticated in order to register for DVS.
This separate process allows users to register for DVS only if they want/need to, and also to select a different PIN/secret for signing documents.

The expected `pin0` is the first authentication factor.
An additional authentication factor can be passed as `pin1`. If not needed, `pin1` should be `nil`.

##### `(MpinStatus*) FinishRegistrationDVS: (const id<IUser>) user pinDVS: (NSString*) pinDVS nfc: (NSString*) nfc;`
This method finalizes the user registration process for the DVS functionality.
Before calling it the application has to get from the end-user the authentication factors that need to be specified while signing (like PIN and possibly others).

The method allows passing additional authentication factor to the SDK, as `nfc`.
If not needed, `nfc` should be `nil`.

##### `(BOOL) VerifyDocument: (NSString*) strDoc hash: (NSData*) hash;`
This method relates to the _DVS (Designated Verifier Signature)_ functionality of the MFA Platform.

It verifies that the `hash` value is correct for the given `strDoc`.
The method returns `TRUE` or `FALSE` respectively, if the hash is correct or not.

The DVS functionality allows a customer application to verify signatures of documents/transactions, signed by the end-user.
The document (`strDoc`) is any free form text that needs to be signed.
Typically, the customer application will generate a `hash` value for the document that needs to be signed, and will send it to the mobile client app.
The client app can then verify the correctness of the hash value using this method.

##### `(MpinStatus*) Sign: (id<IUser>) user documentHash: (NSData*) documentHash pin0: (NSString*) pin0 pin1: (NSString*) pin1 epochTime: (double) epochTime result: (BridgeSignature**) result;`
This method relates to the _DVS (Designated Verifier Signature)_ functionality of the MFA Platform.

It signs a given `documentHash` for the provided `user`.
The `user` should have the ability to sign documents, i.e. it has to have possession of a signing client key and a public/private key-pair.
Those are issued for the user during registration, but users that have registered prior to the DVS feature availability, might lack those keys.
To check whether a user has signing capability, use the `IUser`'s method `canSign`.
The end-user's authentication factor/s should be provided as well, since signing a document (its hash, in fact) is very similar to authenticating.

The method allows passing additional authentication factor to the SDK, as `pin1`.
If not needed, `pin1` should be `nil`.

`epochTime` is the time, in Epoch format, for the document/transaction signature.
Both the `documentHash` and the `epochTime` should be generated and provided by the customer application back-end.

The generated signature is returned in the `result` parameter.
The `BridgeSignature` class has the following form:
```objective-c
@interface BridgeSignature : NSObject

@property (nonatomic) NSData* strHash;
@property (nonatomic) NSData* strMpinId;
@property (nonatomic) NSData* strU;
@property (nonatomic) NSData* strV;
@property (nonatomic) NSData* strPublicKey;

@end
```
* `strHash` is the document hash. It should be identical to the provided `documentHash`.
* `strMpinId` is the end-user's _M-Pin ID_.
* `strU` and `strV` are the actual values that represent the signature.
* `strPublicKey` is the _Public Key_ associated with the end-user.
All of those parameters should be sent to the customer application back-end, so it can verify the signature.

The returned `MpinStatus` could be one of:
* `OK` - document hash was successfully signed.
* `INCORRECT_PIN` - The method failed due to incorrect authentication factor/s. If this status is returned, the `user` State might be changed to `BLOCKED` in case several consecutive unsuccessful attempts were performed.
* `FLOW_ERROR` - The provided `user` doesn't have the ability to sign documents.
* `CRYPTO_ERROR` - an error has occurred at the crypto layer of the SDK. Call the status's `errorMessage` property for more info.
