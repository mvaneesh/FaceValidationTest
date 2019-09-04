#import "AMBNNetworkClient.h"
#import "AMBNServer.h"
#import "AMBNSerializedRequest.h"
#import <CommonCrypto/CommonCrypto.h>

#import "AMBNGlobal.h"

NSString *const AMBNCreateSessionEndpoint = @"sessions";
NSString *const AMBNSubmitBehaviouralEndpoint = @"behavioural";
NSString *const AMBNGetScoreEndpoint = @"score";
NSString *const AMBNFacialEnrollEndpoint = @"face/enroll";
NSString *const AMBNFacialEnrollWithoutSessionEndpoint = @"face/enroll/nosession";
NSString *const AMBNFacialAuthEndpoint = @"face/auth";
NSString *const AMBNFacialAuthWithoutSessionEndpoint = @"face/auth/nosession";
NSString *const AMBNFacialCompareEndpoint = @"face/compare";
NSString *const AMBNVoiceEnrollEndpoint = @"voice/enroll";
NSString *const AMBNVoiceEnrollWithoutSessionEndpoint = @"voice/enroll/nosession";
NSString *const AMBNVoiceAuthEndpoint = @"voice/auth";
NSString *const AMBNVoiceAuthWithoutSessionEndpoint = @"voice/auth/nosession";
NSString *const AMBNVoiceTokenEndpoint = @"voice/token";
NSString *const AMBNVoiceTokenWithoutSessionEndpoint = @"voice/token/nosession";
NSString *const AMBNFaceTokenEndpoint = @"face/token";
NSString *const AMBNFaceTokenWithoutSessionEndpoint = @"face/token/nosession";

@interface AMBNNetworkClient()
@property(nonatomic, strong) NSURL *baseURL;
@property(nonatomic, copy) NSString *apiKey;
@property(nonatomic, strong) NSData *secret;
@end

@implementation AMBNNetworkClient

- (instancetype)initWithApiKey:(NSString *)apiKey secret:(NSString *)secret {
    return [self initWithApiKey:apiKey secret:secret baseUrl:@"https://api.aimbrain.com:443/v1/"];
}

- (instancetype)initWithApiKey:(NSString *)apiKey secret:(NSString *)secret baseUrl:(NSString *)baseUrl {
    self = [super init];
    if (self) {
        self.apiKey = apiKey;
        self.secret = [secret dataUsingEncoding:NSUTF8StringEncoding];
        self.baseURL = [NSURL URLWithString:baseUrl];
    }
    return self;
}

-(void)sendRequest:(NSMutableURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:( void (^)(id _Nullable responseJSON, NSError * _Nullable connectionError)) completion {
    void (^requestCompletion)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        AMBN_LVERBOSE(@"RESPONSE_CODE: %@", @(httpResponse.statusCode));
        if ([httpResponse statusCode] != 200) {
            completion(nil, [self composeErrorResponse:httpResponse data:data]);
            return;
        }

        NSError *jsonParseError;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
        if (jsonParseError) {
            AMBN_LERR(@"JSON parser error: %@", jsonParseError.localizedDescription);
            completion(nil, [NSError errorWithDomain:AMBNServerErrorDomain code:AMBNServerWrongResponseFormatError userInfo:nil]);
            return;
        }
        
        AMBN_LVERBOSE(@"RESPONSE_BODY: %@", (NSDictionary *)jsonObject);
        if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
            AMBN_LVERBOSE(@"RESPONSE_HEADERS: %@", httpResponse.allHeaderFields);
        }

        completion(jsonObject, nil);
    };

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:requestCompletion];
}

- (NSMutableURLRequest *)createJSONPOSTWithData:(id)data endpoint: (NSString *) path {
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    AMBNSerializedRequest *serialized = [self serializeRequestData:data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:_apiKey forHTTPHeaderField:@"X-aimbrain-apikey"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *signatureData = [self calculateSignatureForHTTPMethod:request.HTTPMethod path:url.path httpBody:serialized.data key: self.secret];
    NSString *singature;
    if([signatureData respondsToSelector:@selector(base64Encoding)]){
        singature = [signatureData base64Encoding];
    } else {
        singature = [signatureData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    [request setValue:singature forHTTPHeaderField:@"X-aimbrain-signature"];
    request.HTTPBody = serialized.data;
    
    AMBN_LVERBOSE(@"URL_USED: %@", url.absoluteString);
    AMBN_LVERBOSE(@"REQUEST_BODY: %@", serialized.dataString);
    
    return request;
}

-(AMBNSerializedRequest *) serializeRequestData:(id)data {
    NSError *error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    if(error != nil) {
        AMBN_LERR(@"Serialized request error: %@", error.localizedDescription);
        return nil;
    }
    return [[AMBNSerializedRequest alloc] initWithData:jsonData];
}

- (BOOL)canSendRequests {
    return _baseURL && _apiKey && _secret;
}

- (NSError *)composeErrorResponse:(NSHTTPURLResponse *)response data:(NSData *)data {
    NSString *errorMessage;
    NSError *jsonParseError;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
    if (!jsonParseError) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDict = (NSDictionary *) jsonObject;
            errorMessage = jsonDict[@"error"];
            AMBN_LERR(@"%@", errorMessage);
        }
    }
    NSDictionary *userInfo;
    if (errorMessage) {
        userInfo = @{
                NSLocalizedDescriptionKey : errorMessage
        };
    }

    switch ([response statusCode]) {
        case 404:
            return [NSError errorWithDomain:AMBNServerErrorDomain code:AMBNServerHTTPNotFoundError userInfo:userInfo];
        case 401:
            return [NSError errorWithDomain:AMBNServerErrorDomain code:AMBNServerHTTPUnauthorizedError userInfo:userInfo];
        default:
            return [NSError errorWithDomain:AMBNServerErrorDomain code:AMBNServerHTTPUnknownError userInfo:userInfo];
    }
}

- (NSData *) calculateSignatureForHTTPMethod: (NSString *) httpMethod path: (NSString *) path httpBody: (NSData *) body key: (NSData *) key{
    NSData * newLineData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * methodData = [[httpMethod uppercaseString] dataUsingEncoding:NSUTF8StringEncoding];
    NSData * pathData = [[path lowercaseString] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *message = [NSMutableData dataWithData:methodData];
    [message appendData:newLineData];
    [message appendData:pathData];
    [message appendData:newLineData];
    [message appendData:body];
    NSMutableData * hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, key.bytes, key.length, message.bytes, message.length, hash.mutableBytes);
    return hash;
}

@end
