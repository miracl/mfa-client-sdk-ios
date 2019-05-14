#import <Foundation/Foundation.h>

@interface BridgeSignature : NSObject

-(id) initWith: (NSData *) strHash
        mpinId: (NSString *) strMpinId
          strU: (NSData *) strU
          strV: (NSData *) strV
  strPublicKey: (NSData *) strPublicKey
          dtas: (NSString *) strDtas;

@property (nonatomic) NSData    *strHash;
@property (nonatomic) NSString  *strMpinId;
@property (nonatomic) NSData    *strU;
@property (nonatomic) NSData    *strV;
@property (nonatomic) NSData    *strPublicKey;
@property (nonatomic) NSString  *strDtas;

@end
