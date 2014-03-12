//
//  EMAssemblerConnection.m
//  iOS-rest-client
//
//  Created by Randall Burkes on 7/20/12.
//  Copyright (c) 2012 Endeca. All rights reserved.
//

#import "EMAssemblerConnection.h"
#import "EMAssemblerRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "EMAssemblerConnectionURLBuilder.h"

@interface EMParsedActionString : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSDictionary *parameters;

- (id)initWithPath:(NSString *)pPath parameters:(NSDictionary *)pParamDict;
+ (EMParsedActionString *)createParsedActionString:(NSString *)pActionString;

@end

@implementation EMParsedActionString
@synthesize path = _path, parameters = _parameters;

- (id)initWithPath:(NSString *)pPath parameters:(NSDictionary *)pParamDict {
    self = [super init];
    
    if (self) {
        self.path = pPath;
        self.parameters = pParamDict;
    }
    return self;
}

+ (EMParsedActionString *)createParsedActionString:(NSString *)pActionString {
    
    NSString *path = @"";
    NSDictionary *paramDict = [NSDictionary dictionary];
    
    if ([pActionString rangeOfString:@"?"].length > 0) {
        NSArray *splitActionString = [pActionString componentsSeparatedByString:@"?"];
        if (splitActionString.count > 2) {
            [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidActionPath", nil, [NSBundle mainBundle], @"Invalid Action Path: Action path shouldn't have multiple '?'", @"Invalid Action Path: Action path shouldn't have multiple '?'") userInfo:nil] raise];
        } else {
            //If the string has a ? and is split it will always have two parts. ?foo returns ['', 'foo']
            path = [splitActionString objectAtIndex:0];
            paramDict = [EMParsedActionString dictionaryFromParameterArray:[[splitActionString objectAtIndex:1] componentsSeparatedByString:@"&"]];
        }
    } else {
        path = pActionString;
    }
    
    return [[EMParsedActionString alloc] initWithPath:path parameters:paramDict];
}

+ (NSDictionary *)dictionaryFromParameterArray:(NSArray *)pParameterAray {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *par in pParameterAray) {
        if ([par rangeOfString:@"="].length > 0) {
            NSArray *arr = [par componentsSeparatedByString:@"="];
            [dict setValue:[[arr objectAtIndex:1] stringByReplacingOccurrencesOfString:@"+" withString:@" "] forKey:[arr objectAtIndex:0]];
        }
    }
    return dict;
}

@end


@interface EMAssemblerConnection () 

- (id)initWithHost:(NSString *)pHost 
              port:(NSInteger)pPort 
       contextPath:(NSString *)pContextPath 
    responseFormat:(EMAssemblerResponseFormat)pResponseFormat 
          useHttps:(BOOL)pUseHttps
        urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder;

- (NSString *)constructRelativePathWithContentPath:(NSString *)pContentPath siteRootPath:(NSString *)pSiteRootPath actionPath:(NSString *)pActionPath;
- (NSString *)formatTypeToString:(EMAssemblerResponseFormat)pFormat;
- (void) setUserAgentString:(NSString *)pUserAgent;
@end

@implementation EMAssemblerConnection
@synthesize host=_host,port=_port,contextPath=_contextPath,responseFormat=_responseFormat,urlBuilder = _urlBuilder;

- (id)initWithHost:(NSString *)pHost 
              port:(NSInteger)pPort 
       contextPath:(NSString *)pContextPath 
    responseFormat:(EMAssemblerResponseFormat)pResponseFormat
        urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder{
  return [self initWithHost:pHost port:pPort contextPath:pContextPath responseFormat:pResponseFormat useHttps:NO urlBuilder:pURLBuilder];
}

+ (EMAssemblerConnection *)connectionWithHost:(NSString *)pHost 
                                         port:(NSInteger)pPort 
                                  contextPath:(NSString *)pContextPath 
                               responseFormat:(EMAssemblerResponseFormat)pResponseFormat
                                   urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder{
  return [[EMAssemblerConnection alloc] initWithHost:pHost port:pPort contextPath:pContextPath responseFormat:pResponseFormat urlBuilder:pURLBuilder];
}

- (id)initWithSecureHost:(NSString *)pHost 
                    port:(NSInteger)pPort 
             contextPath:(NSString *)pContextPath 
          responseFormat:(EMAssemblerResponseFormat)pResponseFormat
              urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder{
  return [self initWithHost:pHost port:pPort contextPath:pContextPath responseFormat:pResponseFormat useHttps:YES urlBuilder:pURLBuilder];
}

+ (EMAssemblerConnection *)connectionWithSecureHost:(NSString *)pHost 
                                               port:(NSInteger)pPort 
                                        contextPath:(NSString *)pContextPath 
                                     responseFormat:(EMAssemblerResponseFormat)pResponseFormat
                                         urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder{
  return [[EMAssemblerConnection alloc] initWithSecureHost:pHost port:pPort contextPath:pContextPath responseFormat:pResponseFormat urlBuilder:pURLBuilder];
}

//baseURL must end with a '/'
- (id)initWithHost:(NSString *)pHost 
              port:(NSInteger)pPort 
       contextPath:(NSString *)pContextPath 
    responseFormat:(EMAssemblerResponseFormat)pResponseFormat 
          useHttps:(BOOL)pUseHttps
        urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder {
   
  NSString *protocol = @"http://";
    
  if (pUseHttps) {
    protocol = @"https://";
  }
    
  NSString *baseURL = [pURLBuilder constructBaseURLWithProtocol:protocol host:pHost port:pPort contextPath:[self prependString:pContextPath withPrefix:@"/"] formatString:[self prependString:[self formatTypeToString:pResponseFormat] withPrefix:@"/"]];
    
  self = [super initWithBaseURL:[NSURL URLWithString:baseURL]];
  if (self) {
    self.host = pHost; 
    self.port = pPort;
    self.contextPath = pContextPath;
    self.responseFormat = pResponseFormat;
    self.urlBuilder = pURLBuilder;
        
    if (pResponseFormat == EMAssemblerResponseFormatJSON || pResponseFormat == EMAssemblerResponseFormatXML) {
      [self setDefaultHeader:@"Accept" value:[NSString stringWithFormat:@"application/%@", [self formatTypeToString:pResponseFormat]]];
    }
    NSString *userAgentString = [ATGRestConstants getUserAgent];
    if ([userAgentString isNotBlank]) {
      [self setUserAgentString:userAgentString];
    }
    
    [super registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [super registerHTTPOperationClass:[AFXMLRequestOperation class]];
  }
  return self;
}

- (void)fetchContent:(NSString *)pContentPath 
     forSiteRootPath:(NSString *)pSiteRootPath
        actionString:(NSString *)pActionString
             success:(void (^)(EMAssemblerRequestOperation *operation, id responseObject))success 
             failure:(void (^)(EMAssemblerRequestOperation *operation, NSError *error))failure {
    
  NSString *actions = [self.urlBuilder modifyParameters:pActionString forConnection:self];
  EMParsedActionString *actionString = [EMParsedActionString createParsedActionString:actions];
    
  NSString *path = [self.urlBuilder constructRelativePathWithContentPath:pContentPath siteRootPath:pSiteRootPath actionPath:actionString.path];
    
  [super getPath:path parameters:actionString.parameters 
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success 
         failure:(void (^)(AFHTTPRequestOperation *operation, id responseObject))failure];
}

#pragma mark -
#pragma mark Internal

- (NSString *)constructRelativePathWithContentPath:(NSString *)pContentPath siteRootPath:(NSString *)pSiteRootPath actionPath:(NSString *)pActionPath {
  NSString *path = [NSString stringWithFormat:@"%@%@%@", (pSiteRootPath ? pSiteRootPath : @""), [self prependString:pContentPath withPrefix:@"/"], [self prependString:pActionPath withPrefix:@"/"]];
  return [self removePrecedingSlash:path];
}

- (NSString *)prependString:(NSString *)pString withPrefix:(NSString *)pPrefix {
  if (pString && pString.length > 0 && [pString rangeOfString:pPrefix].location != 0) {
    return [NSString stringWithFormat:@"%@%@", pPrefix, pString];
  }
  return (pString ? pString : @"");
}

- (NSString *)removePrecedingSlash:(NSString *)pString {    
  if ([pString rangeOfString:@"/"].location == 0) {
    pString = [pString substringFromIndex:1];
  }
  return pString;
}

- (NSString *)formatTypeToString:(EMAssemblerResponseFormat)pFormat {
  switch (pFormat) {
    case EMAssemblerResponseFormatXML:
      return @"xml";
    case EMAssemblerResponseFormatJSON:
      return @"json";
    default:
      break;
  }
  return @"";
}

- (void) setUserAgentString:(NSString *)pUserAgent{
  [self setDefaultHeader:@"User-Agent" value:pUserAgent];
}

@end