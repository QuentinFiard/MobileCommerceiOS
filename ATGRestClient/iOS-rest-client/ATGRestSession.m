/*<ORACLECOPYRIGHT>
 * Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates. 
 * Other names may be trademarks of their respective owners.
 * UNIX is a registered trademark of The Open Group.
 *
 * This software and related documentation are provided under a license agreement 
 * containing restrictions on use and disclosure and are protected by intellectual property laws. 
 * Except as expressly permitted in your license agreement or allowed by law, you may not use, copy, 
 * reproduce, translate, broadcast, modify, license, transmit, distribute, exhibit, perform, publish, 
 * or display any part, in any form, or by any means. Reverse engineering, disassembly, 
 * or decompilation of this software, unless required by law for interoperability, is prohibited.
 *
 * The information contained herein is subject to change without notice and is not warranted to be error-free. 
 * If you find any errors, please report them to us in writing.
 *
 * U.S. GOVERNMENT RIGHTS Programs, software, databases, and related documentation and technical data delivered to U.S. 
 * Government customers are "commercial computer software" or "commercial technical data" pursuant to the applicable 
 * Federal Acquisition Regulation and agency-specific supplemental regulations. 
 * As such, the use, duplication, disclosure, modification, and adaptation shall be subject to the restrictions and 
 * license terms set forth in the applicable Government contract, and, to the extent applicable by the terms of the 
 * Government contract, the additional rights set forth in FAR 52.227-19, Commercial Computer Software License 
 * (December 2007). Oracle America, Inc., 500 Oracle Parkway, Redwood City, CA 94065.
 *
 * This software or hardware is developed for general use in a variety of information management applications. 
 * It is not developed or intended for use in any inherently dangerous applications, including applications that 
 * may create a risk of personal injury. If you use this software or hardware in dangerous applications, 
 * then you shall be responsible to take all appropriate fail-safe, backup, redundancy, 
 * and other measures to ensure its safe use. Oracle Corporation and its affiliates disclaim any liability for any 
 * damages caused by use of this software or hardware in dangerous applications.
 *
 * This software or hardware and documentation may provide access to or information on content, 
 * products, and services from third parties. Oracle Corporation and its affiliates are not responsible for and 
 * expressly disclaim all warranties of any kind with respect to third-party content, products, and services. 
 * Oracle Corporation and its affiliates will not be responsible for any loss, costs, 
 * or damages incurred due to your access to or use of third-party content, products, or services.
 </ORACLECOPYRIGHT>*/

#import "AFNetworking.h"
#import "ATGDefaultRestRequestFactory.h"
#import "ATGSessionConfirmationNumberRequestFactory.h"
#import "ATGRestHTTPOperation.h"
#import "ATGProfileServicesLoginHandler.h"

@interface ATGRestSession ()
@property (strong, nonatomic) id <ATGRestRequestFactory>httpClient;
@property (strong, nonatomic) ATGDefaultRestRequestFactory *reachabilityClient;
- (id) initWithHost:(NSString *)pHost port:(NSInteger) pPort username:(NSString *) pUsername password:(NSString *)pPassword;
- (NSString *)getComponentURL:(NSString *)pComponentPath,...NS_REQUIRES_NIL_TERMINATION;
- (NSString *)getServiceURL:(NSString *)pComponentPath arguments:(NSArray *) pArguments;
- (NSString *)getActorURL:(NSString *)pComponentPath arguments:(NSArray *) pArguments;
- (id <ATGRestRequestFactory>)getFactoryForRequest:(id <ATGRestRequestFactory>)pRequestFactory;
- (NSError *)wrapError:(NSError *)pError;
-(id)checkForError:(id<ATGRestOperation>) pOperation response:(id)pResponseObject;
-(id)checkForFormHandlerExceptions:(id <ATGRestOperation>)pOperation response:(id)pResponseObject;
- (NSMutableDictionary *) addRequestOptions:(ATGRestRequestOptions)pRequestOptions toDictionary:(NSMutableDictionary *)pDictionary;
-(NSMutableURLRequest *)createRequestWithFactory:(id<ATGRestRequestFactory>)pFactory method:(ATGHTTPMethod)pMethod path:(NSString *)pPath parameters:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions;
-(NSString *)postBodyAsString:(NSURLRequest*)pRequest;
@end

@implementation ATGRestSession

#pragma mark -
#pragma mark Private Methods

@synthesize httpClient = _httpClient, reachabilityClient = _reachabilityClient, loginHandler = _loginHandler;

-(id <ATGRestRequestFactory>)httpClient{
  if (!_httpClient) {
    ATGDefaultRestRequestFactory *client = [ATGDefaultRestRequestFactory factoryWithStringEncoding:self.characterEncoding];
    _httpClient = client;
  }
  return _httpClient;
}

-(ATGDefaultRestRequestFactory *)reachabilityClient{
#ifdef _SYSTEMCONFIGURATION_H
  if(!_reachabilityClient){
    _reachabilityClient = [[ATGDefaultRestRequestFactory alloc] initWithStringEncoding:ATG_DEFAULT_STRING_ENCODING withBaseURL:[self hostURLWithOptions:ATGRestRequestOptionNone]];
    _reachabilityClient.trackReachability = YES;
    [_reachabilityClient startMonitoringNetworkReachability];
  }
#endif
  return _reachabilityClient;
}

- (id) initWithHost:(NSString *)pHost port:(NSInteger) pPort username:(NSString *)pUsername password:(NSString *)pPassword{
  if ((self = [super init])) {
    self.host = pHost;
    self.port = pPort;
    self.username = pUsername;
    self.password = pPassword;
    self.restContextRoot = @"rest";
    self.useHttps = ATG_USE_HTTPS;
    self.characterEncoding = ATG_DEFAULT_STRING_ENCODING;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if(infoDictionary != nil){
      NSString *encoding = [infoDictionary objectForKey:ATG_DEFAULT_STRING_ENCODING_KEY];
      if(encoding != nil){
        NSStringEncoding encodingString = [ATGRestConstants getEncodingFromString:encoding];
        self.characterEncoding = encodingString;
      }
      NSNumber *useHttpsPlist = [infoDictionary objectForKey:ATG_USE_HTTPS_KEY];
      if(useHttpsPlist != nil){
        self.useHttps = [useHttpsPlist boolValue];
      } 
    }
    //Call reachability to start listenting
    [self reachabilityClient];
  }
  return self;
}

- (NSString *)getComponentURL:(NSString *)pComponentPath,...{
  NSMutableArray *components = [NSMutableArray arrayWithObjects:[self restContextRoot],ATG_REST_BEAN, nil];
  va_list args;
  va_start(args, pComponentPath);
  for (NSString *arg = pComponentPath; arg != nil; arg = va_arg(args, NSString*))
  {
    [components addObject:arg];
  }
  va_end(args);
  NSString *url = [NSString pathWithComponents:components];
  return url;
}

- (NSString *)getServiceURL:(NSString *)pComponentPath arguments:(NSArray *) pArguments{
  NSMutableArray *components = [NSMutableArray arrayWithObjects:[self restContextRoot],ATG_REST_SERVICE,pComponentPath,nil];
  [components addObjectsFromArray:pArguments];
  NSString *url = [NSString pathWithComponents:components];
  return url;                   
}

- (NSString *)getActorURL:(NSString *)pComponentPath arguments:(NSArray *) pArguments{
  NSMutableArray *components = [NSMutableArray arrayWithObjects:[self restContextRoot],ATG_REST_MODELACTOR,pComponentPath,nil];
  [components addObjectsFromArray:pArguments];
  NSString *url = [NSString pathWithComponents:components];
  return url;                   
}

-(id)checkForError:(id<ATGRestOperation>) pOperation response:(id)pResponseObject{
  id formExceptions = [self checkForFormHandlerExceptions:pOperation response:pResponseObject];
  if (formExceptions) {
    return [self wrapFormHandlerExceptions:formExceptions];
  }
  return nil;
}

-(NSArray *)checkForFormHandlerExceptions:(id <ATGRestOperation>)pOperation response:(id)pResponseObject {
  id exceptions = [pResponseObject objectForKey:ATG_REST_FORM_EXCEPTIONS];
  if (exceptions) {
    return exceptions;
  }
  return nil;  
}

- (id <ATGRestRequestFactory>)getFactoryForRequest:(id <ATGRestRequestFactory>)pRequestFactory{
  id <ATGRestRequestFactory>factory = pRequestFactory;
  if (factory == nil) {
    factory = self.requestFactory;
  }
  return factory;
}

- (NSError *)wrapFormHandlerExceptions:(NSArray *)pFormHandlerExceptions { 
  __block NSString *errorMessage;
  __block NSMutableArray *errors = [NSMutableArray new];
  
  [pFormHandlerExceptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if ([obj respondsToSelector:@selector(valueForKey:)] && [obj isKindOfClass:[NSDictionary class]]) {
      NSString *localizedMessage = [obj valueForKey:@"localizedMessage"];
      errorMessage = [NSString stringWithFormat:@"%@\n%@", errorMessage ? errorMessage : @"", localizedMessage];
      [errors addObject:localizedMessage];
    }
  }];
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, [NSArray arrayWithArray:errors], ATG_FORM_EXCEPTION_KEY, nil];
  return [NSError errorWithDomain:ATGRestClientException code:6 userInfo:userInfo];
}

- (NSError *)wrapError:(NSError *)pError{
  NSError *wrappedError = [NSError errorWithDomain:ATGRestClientException code:pError.code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:pError,ATGRestClientExceptionErrorKey,pError.localizedDescription,NSLocalizedDescriptionKey, nil]];
   return wrappedError;
}

- (NSMutableDictionary *) addRequestOptions:(ATGRestRequestOptions)pRquestOptions toDictionary:(NSMutableDictionary *)pDictionary{  
  NSMutableDictionary *params = pDictionary;
  if(!params){
    params =[NSMutableDictionary dictionary];
  }
  if(pRquestOptions & ATGRestRequestOptionReturnFormProperties){  
    [params setObject:[NSNumber numberWithBool:YES] forKey:ATG_REST_FORM_HANDLER_PROPERTIES];
  }
  if(pRquestOptions & ATGRestRequestOptionReturnFormExceptions){
    [params setObject:[NSNumber numberWithBool:YES] forKey:ATG_REST_FORM_HANDLER_EXCEPTIONS];
  }
  return params;
}

-(NSMutableURLRequest *)createRequestWithFactory:(id<ATGRestRequestFactory>)pFactory method:(ATGHTTPMethod)pMethod path:(NSString *)pPath parameters:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions{
  NSDictionary *modifiedParams = [pFactory modifyParams:pParameters options:pOptions];
  NSURL *url = [pFactory modifyRequestURL:[NSURL URLWithString:pPath relativeToURL:[self hostURLWithOptions:pOptions]] options:pOptions];
  
  NSMutableURLRequest *request = [pFactory requestWithHTTPMethod:pMethod path:url parameters:modifiedParams options:pOptions];
  return request;
}

-(NSString *)postBodyAsString:(NSURLRequest*)pRequest{
  NSData *data = pRequest.HTTPBody;
  return [[NSString alloc] initWithData:data encoding:self.characterEncoding];
}

#pragma mark -
#pragma mark Public Methods

@synthesize host=_host,port=_port,username=_username,password=_password,restContextRoot=_restContextRoot,useHttps=_useHttps,userId=_userId,sessionConfirmationNumber=_sessionConfirmationNumber,characterEncoding=_characterEncoding,requestFactory=_requestFactory;

+ (ATGRestSession *) newSessionForHost:(NSString *)pHost port:(NSInteger) pPort username:(NSString *) pUsername password:(NSString *)pPassword{
  ATGRestSession *session = [[ATGRestSession alloc] initWithHost:pHost port:pPort username:pUsername password:pPassword];
  return session;
}

-(id <ATGRestRequestFactory>)requestFactory{
  if(_requestFactory == nil){
    self.requestFactory = [ATGSessionConfirmationNumberRequestFactory factoryWithStringEncoding:self.characterEncoding restSession:self];
  }
  return _requestFactory;
}

//must clear out reachability when host, port, or https changes.
-(void)setHost:(NSString *)host{
  if(host !=_host){
    _host = host;
    _reachabilityClient = nil;
    [self reachabilityClient];
  }
}
-(void)setPort:(NSInteger)port{
  if (port != _port) {
    _port = port;
    _reachabilityClient = nil;
    [self reachabilityClient];
  }
}
-(void)setUseHttps:(BOOL)useHttps{
  if (_useHttps != useHttps) {
    _useHttps = useHttps;
    _reachabilityClient = nil;
    [self reachabilityClient];
  }
}

-(NSURL *)hostURLWithOptions:(ATGRestRequestOptions)pOptions{
  NSMutableString *hostString = [NSMutableString string];
  if (self.useHttps || (pOptions & ATGRestRequestOptionUseHTTPS)) {
    [hostString appendFormat:@"https://%@",self.host];
    if (self.port != 443) {
      [hostString appendFormat:@":%d",self.port];
    }
  }
  else {
    [hostString appendFormat:@"http://%@",self.host];
    if (self.port != 80) {
      [hostString appendFormat:@":%d",self.port];
    }
  }
  return [NSURL URLWithString:hostString];;
}

-(id<ATGRestLoginHandler>)loginHandler{
  if(_loginHandler == nil){
    _loginHandler = [[ATGProfileServicesLoginHandler alloc] initWithRestSession:self];
  }

  return _loginHandler;
}

-(id<ATGRestOperation>) login:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure{
  return [self.loginHandler login:self.username password:self.password factory:pRequestFactory options:pOptions success:pSuccess failure:pFailure];
}

-(id<ATGRestOperation>) logout:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure{
  return [self.loginHandler logout:pRequestFactory options:pOptions success:pSuccess failure:pFailure];
}

- (id <ATGRestOperation>) executeMethod:(NSString *)pMethodName component:(NSString *) pComponentPath arguments:(NSArray *)pArguments parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure{
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pMethodName isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidMethodName", nil, [NSBundle mainBundle], @"Method name parameter cannot be empty", @"Method name parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:pParameters];
  
  for(int i = 1; pArguments != nil && i <= [pArguments count]; i++){      
    id arg = [pArguments objectAtIndex:i-1];
    NSString *argKey = [NSString stringWithFormat:@"%@%d",ATG_REST_ARG,i];
    DebugLog(@"Adding arg #%d, value of %@",i,arg);
    [params setObject:arg forKey:argKey];
  }
  
  NSString *encodedPath = [self getComponentURL:pComponentPath,pMethodName,nil];
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodPost path:encodedPath parameters:params options:pOptions];
  
  id<ATGRestOperation> operation = [factory JSONRequestOperationWithRequest:request 
    success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
      DebugLog(@"Method executed at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
      id responseError = [self checkForError:pOperation response:pResponseObject];
      if(responseError){
        DebugLog(@"Method executed at URL %@ failed in success block!", pOperation.request.URL);
        pFailure(pOperation,responseError);
      }
      else{
        DebugLog(@"Method executed at URL %@ succeeded!", pOperation.request.URL);
        pSuccess(pOperation, [pResponseObject objectForKey:ATG_REST_RESPONSE]);
      }
    } 
    failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
      DebugLog(@"Failure executing method at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
      pFailure(pOperation,[self wrapError:pError]);
    }];
  DebugLog(@"Executing Method %@ on %@ to URL %@ with post body: %@",pMethodName,pComponentPath,request.URL,[self postBodyAsString:request]);
  [factory enqueueRestOperation:operation];
  return operation;
}

- (id <ATGRestOperation>) getComponent:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(NSObject <ATGRestRequestFactory> *)pRequestFactory options:(ATGRestRequestOptions)pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }  
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];
  
  NSString *encodedPath = [self getComponentURL:pComponentPath,nil];
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodGet path:encodedPath parameters:pParameters options:pOptions];
  
  id <ATGRestOperation>operation = [factory JSONRequestOperationWithRequest:(NSURLRequest *)request 
    success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
      DebugLog(@"Component accessed at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
      id responseError = [self checkForError:pOperation response:pResponseObject];
      if(responseError){
        DebugLog(@"Component accessed at URL %@ failed in success block!",pOperation.request.URL);
        pFailure(pOperation,responseError);
      }
      else{
        DebugLog(@"Component accessed at URL %@ succeeded!",pOperation.request.URL);
        pSuccess(pOperation, pResponseObject);
      }
    } 
    failure:^( id <ATGRestOperation>pOperation , NSError *pError ){  
      DebugLog(@"Failure accessing component at URL %@, Status: %d, Response: %@, Error: %@",pOperation.request.URL,pOperation.response.statusCode,pOperation.responseString, pError);
      pFailure(pOperation,[self wrapError:pError]);
    }];
  DebugLog(@"Retrieving component %@ at URL %@",pComponentPath,request.URL);
  [factory enqueueRestOperation:operation];
  return operation;
}
- (id <ATGRestOperation>) getComponentAsPost:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(NSObject <ATGRestRequestFactory> *)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }  
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];  

  NSString *encodedPath = [self getComponentURL:pComponentPath,nil];
  
  NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:pParameters];
  [paramDict setObject:[NSNumber numberWithBool:true] forKey:ATG_REST_VIEW];
  
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodPost path:encodedPath parameters:paramDict options:pOptions];
  
  id <ATGRestOperation>operation = [factory JSONRequestOperationWithRequest:(NSURLRequest *)request 
     success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
       DebugLog(@"Data posted to component at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
       id responseError = [self checkForError:pOperation response:pResponseObject];
       if(responseError){
         DebugLog(@"Post to component at URL %@ failed in success block!",pOperation.request.URL);
         pFailure(pOperation,responseError);
       }
       else{
         DebugLog(@"Post to component at URL %@ succeeded!",pOperation.request.URL);
         pSuccess(pOperation, pResponseObject);
       }
     }                                            
     failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
       DebugLog(@"Failure posting to component at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
       pFailure(pOperation,[self wrapError:pError]);
     }];
  DebugLog(@"Posting to component %@ at URL %@ with post body: %@",pComponentPath,request.URL,[self postBodyAsString:request]);
  [factory enqueueRestOperation:operation];
  return operation;
}

- (id <ATGRestOperation>) executeGetRequestForActorPath:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(NSObject <ATGRestRequestFactory> *)pRequestFactory options:(ATGRestRequestOptions)pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }  
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];
  
  NSString *encodedPath = [self getActorURL:pComponentPath arguments:nil];
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodGet path:encodedPath parameters:pParameters options:pOptions];
  
  id <ATGRestOperation>operation = [factory JSONRequestOperationWithRequest:(NSURLRequest *)request 
                                                                    success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
                                                                      DebugLog(@"Component accessed at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
                                                                      id responseError = [self checkForError:pOperation response:pResponseObject];
                                                                      if(responseError){
                                                                        DebugLog(@"Component accessed at URL %@ failed in success block!",pOperation.request.URL);
                                                                        pFailure(pOperation,responseError);
                                                                      }
                                                                      else{
                                                                        DebugLog(@"Component accessed at URL %@ succeeded!",pOperation.request.URL);
                                                                        pSuccess(pOperation, pResponseObject);
                                                                      }
                                                                    } 
                                                                    failure:^( id <ATGRestOperation>pOperation , NSError *pError ){  
                                                                      DebugLog(@"Failure accessing component at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
                                                                      pFailure(pOperation,[self wrapError:pError]);
                                                                    }];
  DebugLog(@"Retrieving component %@ at URL %@",pComponentPath,request.URL);
  [factory enqueueRestOperation:operation];
  return operation;
}

- (id <ATGRestOperation>) executePostRequestForActorPath:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(NSObject <ATGRestRequestFactory> *)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }  
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];  
  
  NSString *encodedPath = [self getActorURL:pComponentPath arguments:nil];
  
  NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithDictionary:pParameters];
  
  pOptions = pOptions | ATGRestRequestOptionRequireSessionConfirmation;
  
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodPost path:encodedPath parameters:paramDict options:pOptions];
  
  id <ATGRestOperation>operation = [factory JSONRequestOperationWithRequest:(NSURLRequest *)request
                                                                    success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
                                                                      DebugLog(@"Data posted to component at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
                                                                      id responseError = [self checkForError:pOperation response:pResponseObject];
                                                                      if(responseError){
                                                                        DebugLog(@"Post to component at URL %@ failed in success block!",pOperation.request.URL);
                                                                        pFailure(pOperation,responseError);
                                                                      }
                                                                      else{
                                                                        DebugLog(@"Post to component at URL %@ succeeded!",pOperation.request.URL);
                                                                        pSuccess(pOperation, pResponseObject);
                                                                      }
                                                                    } failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
                                                                      DebugLog(@"Failure POSTing to URL %@, Response: %@", pOperation.request.URL, pOperation.responseString);
                                                                      //if error status 409, request session confirmation
                                                                      if (pOperation.response.statusCode == 409) {
                                                                        DebugLog(@"Failure caused by invalid session confirmation number by request to URL %@.",pOperation.request.URL);
                                                                        self.sessionConfirmationNumber = nil;
                                                                        requestedSessionConfirmation = SCN_NOT_REQUESTED;
                                                                        [factory enqueueRestOperation:pOperation withOptions:pOptions];
                                                                      }
                                                                      else{
                                                                        pFailure(pOperation,[self wrapError:pError]);
                                                                      }
                                                                    }];
 
  DebugLog(@"POSTing to URL %@ with POST body: %@", request.URL, [self postBodyAsString:request]);
  [factory enqueueRestOperation:operation withOptions:pOptions];

  return operation;
}


- (id <ATGRestOperation>) getPropertyValue:(NSString *)pPropertyName component:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pPropertyName isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidPropertyParam", nil, [NSBundle mainBundle], @"Property parameter cannot be empty", @"Property parameter cannot be empty") userInfo:nil] raise];
  }  
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  } 
  
  NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:pComponentPath,pPropertyName, nil]];
  
  return [self getComponent:path parameters:pParameters requestFactory:pRequestFactory options:pOptions success:^(id<ATGRestOperation> operation, id responseObject) {
    id propertyValue = [responseObject objectForKey:pPropertyName];
    pSuccess(operation,propertyValue);
  } failure:^(id<ATGRestOperation> operation, NSError *error) {
    pFailure(operation,error);
  }];
}

- (id <ATGRestOperation>) executeFormHandler:(NSString *)pMethodName component:(NSString *) pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error , NSArray *pFormExceptions ))pFailure{
  
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pMethodName isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidMethodName", nil, [NSBundle mainBundle], @"Method name parameter cannot be empty", @"Method name parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  
  id <ATGRestRequestFactory>factory = [self getFactoryForRequest:pRequestFactory];  
  
  NSString *componentPath = [self getComponentURL:pComponentPath,pMethodName,nil];  
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:pParameters];
  params = [self addRequestOptions:pOptions toDictionary:params];

  if(self.characterEncoding){
    [params setObject:[ATGRestConstants getStringFromEncoding:self.characterEncoding] forKey:ATG_CHARSET];
  }
  
  pOptions = pOptions | ATGRestRequestOptionRequireSessionConfirmation;
  
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodPost path:componentPath parameters:params options:pOptions];
  
  id <ATGRestOperation>operation = [factory JSONRequestOperationWithRequest:(NSURLRequest *)request 
      success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
        DebugLog(@"FormHandler executed at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
        id responseError = [self checkForError:pOperation response:pResponseObject];
        NSArray *formExceptions = [self checkForFormHandlerExceptions:pOperation response:pResponseObject];
        if(responseError || formExceptions){
          DebugLog(@"Form exceptions returned from execution at URL %@",pOperation.request.URL);
          pFailure(pOperation,responseError,formExceptions);
        }
        else{
          DebugLog(@"FormHandler execution succeeded at URL %@",pOperation.request.URL);
          id properties = [pResponseObject objectForKey:ATG_REST_FORM_COMPONENT];
          pSuccess(pOperation, properties);
        }
      }                                            
      failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
        DebugLog(@"Failure executing FormHandler at URL %@, Response: %@",pOperation.request.URL,pOperation.responseString);
        //if error status 409, request session confirmation
        if (pOperation.response.statusCode == 409) {
          DebugLog(@"Failure caused by invalid session confirmation number by request to URL %@.",pOperation.request.URL);
          self.sessionConfirmationNumber = nil;
          self->requestedSessionConfirmation = SCN_NOT_REQUESTED;
          [factory enqueueRestOperation:pOperation withOptions:pOptions];
        }
        else{
          pFailure(pOperation,[self wrapError:pError],nil);
        }
      }];
  
  DebugLog(@"Executing method %@ on FormHandler %@ to URL %@ with post body: %@",pMethodName,pComponentPath,request.URL,[self postBodyAsString:request]);
  [factory enqueueRestOperation:operation withOptions:pOptions];

  return operation;
}

- (id <ATGRestOperation>) executeServiceRequestForComponent:(NSString *)pComponentPath withArguments:(NSArray *)pArguments requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory> factory = [self getFactoryForRequest:pRequestFactory];
  NSString *path = [self getServiceURL:pComponentPath arguments:pArguments];
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodGet path:path parameters:nil options:pOptions];
  
  id <ATGRestOperation> operation = [factory JSONRequestOperationWithRequest:request 
   success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
     DebugLog(@"Service request requested to URL %@, Response: %@",request.URL,pOperation.responseString);
     id responseError = [self checkForError:pOperation response:pResponseObject];
     if(responseError){
       DebugLog(@"Service request to URL %@ failed in success block!",request.URL);
       pFailure(pOperation,responseError);
     }
     else{
       DebugLog(@"Service request to URL %@ succeeded!",request.URL);
       pSuccess(pOperation, pResponseObject);
     }
   }  
   failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
     DebugLog(@"Service request failed to URL %@, Response: %@",request.URL,pOperation.responseString);
     pFailure(pOperation,[self wrapError:pError]);
   }];
  DebugLog(@"Requesting service request for component %@",pComponentPath);
  [factory enqueueRestOperation:operation];
  return operation;
}
- (id <ATGRestOperation>) executeServiceRequestPostForComponent:(NSString *)pComponentPath withArguments:(NSArray *)pArguments parameters:(NSDictionary *) pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation>operation , id responseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation>operation , NSError *error ))pFailure{
  if (![pComponentPath isNotBlank]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.InvalidComponetPath", nil, [NSBundle mainBundle], @"Component path parameter cannot be empty", @"Component path parameter cannot be empty") userInfo:nil] raise];
  }
  if (![pComponentPath hasPrefix:@"/"]) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedStringWithDefaultValue(@"RestSession.ComponentPathMustBeginWithSlash", nil, [NSBundle mainBundle], @"Component path must begin with a '/' character", @"Component path must begin with a '/' character") userInfo:nil] raise];
  }
  
  id <ATGRestRequestFactory> factory = [self getFactoryForRequest:pRequestFactory];
  NSString *path = [self getServiceURL:pComponentPath arguments:pArguments];
  NSMutableURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodPost path:path parameters:pParameters options:pOptions];
  
  //Posting to a service required url-encoded post body
  NSDictionary *modifiedParams = [factory modifyParams:pParameters options:pOptions];
  if (modifiedParams) {  
    NSString *charset =  [ATGRestConstants getStringFromEncoding:factory.stringEncoding];
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[AFQueryStringFromParametersWithEncoding(modifiedParams, factory.stringEncoding) dataUsingEncoding:factory.stringEncoding]];
  }
  
  id <ATGRestOperation> operation = [factory JSONRequestOperationWithRequest:request 
   success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
     DebugLog(@"Service request posted to URL %@, Response: %@",request.URL,pOperation.responseString);
     id responseError = [self checkForError:pOperation response:pResponseObject];
     if(responseError){
       DebugLog(@"Service request posted to URL %@ failed in success block!",request.URL);
       pFailure(pOperation,responseError);
     }
     else{
       DebugLog(@"Service request posted to URL %@ succeeded!",request.URL);
       pSuccess(pOperation, pResponseObject);
     }
   }  
   failure:^( id <ATGRestOperation>pOperation , NSError *pError ){
     DebugLog(@"Service post request failed to URL %@, Response: %@",request.URL,pOperation.responseString);
     pFailure(pOperation,[self wrapError:pError]);
   }];
  
  DebugLog(@"Requesting service request for component %@ with post body: %@",pComponentPath,[self postBodyAsString:request]);
  [factory enqueueRestOperation:operation];
  return operation;
}

- (id <ATGRestOperation>) executeGetRequestToAbsoluteURL:(NSURL *)pURL requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure{
  
  id <ATGRestRequestFactory> factory = [self getFactoryForRequest:pRequestFactory];
  
  NSURLRequest *request = [self createRequestWithFactory:factory method:ATGHTTPMethodGet path:[pURL absoluteString] parameters:nil options:pOptions];
  
  ATGRestHTTPOperation *operation = [factory HTTPRequestOperationWithRequest:request success:pSuccess failure:pFailure];
  [factory enqueueRestOperation:operation];  
    
  return operation;
}

-(void) resetSessionConfirmationNumber {
  self.sessionConfirmationNumber = nil;
  self->requestedSessionConfirmation = SCN_NOT_REQUESTED;
}

@end
