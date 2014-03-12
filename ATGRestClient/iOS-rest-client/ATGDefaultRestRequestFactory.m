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



#import "ATGDefaultRestRequestFactory.h"
#import "ATGRestJSONOperation.h"
#import "ATGRestHTTPOperation.h"
#import "AFJSONUtilities.h"

@interface AFHTTPClient (Reachability)
- (void)startMonitoringNetworkReachability;
@end

@implementation ATGDefaultRestRequestFactory

@synthesize trackReachability = _trackReachability;

+ (ATGDefaultRestRequestFactory *)factoryWithStringEncoding:(NSStringEncoding)pStringEncoding{
  return [[self alloc] initWithStringEncoding:pStringEncoding];
}

- (id)initWithStringEncoding:(NSStringEncoding)pStringEncoding withBaseURL:(NSURL *)pURL {
  self = [super initWithBaseURL:pURL];
  if(self){
    self.parameterEncoding = AFJSONParameterEncoding;
    self.stringEncoding = pStringEncoding;
  }
  return self;
}

-(id)init{
  return [self initWithStringEncoding:ATG_DEFAULT_STRING_ENCODING];
}

- (id)initWithStringEncoding:(NSStringEncoding)pStringEncoding{
  return [self initWithStringEncoding:pStringEncoding withBaseURL:nil];
}

- (void)startMonitoringNetworkReachability {
#ifdef _SYSTEMCONFIGURATION_H
  if(self.trackReachability && [[self.baseURL host] UTF8String]){
    [super startMonitoringNetworkReachability];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
  }
#endif
}
- (void)networkStatusChanged:(NSNotification *)pStatus{
  [[NSNotificationCenter defaultCenter] postNotificationName:ATGNetworkingReachabilityDidChangeNotification object:[pStatus object]];
}
- (NSMutableURLRequest *)requestWithHTTPMethod:(ATGHTTPMethod)pMethod path:(NSURL *)pPath parameters:(NSDictionary *)pParameters options:(ATGRestRequestOptions) pOptions{
  NSMutableURLRequest *request = [self requestWithMethod:[ATGRestConstants getHTTPMethodString:pMethod] path:[pPath absoluteString] parameters:pParameters];
  return request;
}
- (NSDictionary *)modifyParams:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions{
  return pParameters;
}

-(NSURL *)modifyRequestURL:(NSURL *)pURL options:(ATGRestRequestOptions) pOptions{
  return pURL;
}

- (id <ATGRestOperation>)JSONRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure{  
  
    ATGRestJSONOperation *operation = [[ATGRestJSONOperation alloc] initWithRequest:pRequest];
    operation.successBlock =  pSuccess;
    operation.failureBlock =  pFailure;  
    [operation setCompletionBlockWithSuccess:pSuccess failure:pFailure];
    
    return operation;  
}

- (id <ATGRestOperation>)HTTPRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure{
  ATGRestHTTPOperation *operation = [[ATGRestHTTPOperation alloc] initWithRequest:pRequest];
  
  [operation setCompletionBlockWithSuccess:pSuccess failure:pFailure];
  
  return operation;
}

- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)operation withOptions:(ATGRestRequestOptions)options {
  [self enqueueRestOperation:operation];
}

- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)operation{
  [self enqueueHTTPRequestOperation:(ATGRestJSONOperation *)operation];
}
- (void) setUserAgentString:(NSString *)pUserAgent{
  [self setDefaultHeader:@"User-Agent" value:pUserAgent];
}

- (void)setValue:(id)pValue forKey:(NSString *)pKey onRequest:(NSMutableURLRequest*)pRequest{
  NSError *error = nil;
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:pRequest.HTTPBody
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
  [dictionary setValue:pValue forKey:pKey];
  pRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:dictionary
                                                      options:kNilOptions
                                                        error:&error];
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
