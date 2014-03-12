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



#import "ATGParentFirstRestRequestFactory.h"

@implementation ATGParentFirstRestRequestFactory

@synthesize parentFactory = _parentFactory;

- (id)initWithStringEncoding:(NSStringEncoding)pStringEncoding parent:(id<ATGRestRequestFactory>)pParentFactory{
  self = [super initWithStringEncoding:pStringEncoding];
  if(self){
    self.parentFactory = pParentFactory;
    self.stringEncoding = pStringEncoding;
  }
  return self;
}

- (NSMutableURLRequest *)requestWithHTTPMethod:(ATGHTTPMethod)pMethod path:(NSURL *)pPath parameters:(NSDictionary *)pParameters options:(ATGRestRequestOptions) pOptions{
  if(self.parentFactory){
    return [self.parentFactory requestWithHTTPMethod:pMethod path:pPath parameters:pParameters options:pOptions];
  }
  else {
    return [super requestWithHTTPMethod:pMethod path:pPath parameters:pParameters options:pOptions];
  }
}
-(NSURL *)modifyRequestURL:(NSURL *)pURL options:(ATGRestRequestOptions) pOptions{
  
  NSURL *url = pURL;
  if(self.parentFactory){
    url = [self.parentFactory modifyRequestURL:url options:pOptions];
  }
  else {
    url = [super modifyRequestURL:url options:pOptions];
  }   
  return url;  
}

- (NSDictionary *)modifyParams:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions{
  if (self.parentFactory) {
    return [self.parentFactory modifyParams:pParameters options:pOptions];
  }
  else{
    return [super modifyParams:pParameters options:pOptions];
  }
}

- (id <ATGRestOperation>)JSONRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure{
  if (self.parentFactory) {
    return [self.parentFactory JSONRequestOperationWithRequest:pRequest success:pSuccess failure:pFailure];
  }
  else {
    return [super JSONRequestOperationWithRequest:pRequest success:pSuccess failure:pFailure];
  }
}

- (id <ATGRestOperation>)HTTPRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure{
  if(self.parentFactory){
    return [self.parentFactory HTTPRequestOperationWithRequest:pRequest success:pSuccess failure:pFailure];
  }
  else{
    return [super HTTPRequestOperationWithRequest:pRequest success:pSuccess failure:pFailure];
  }
}

- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)pOperation withOptions:(ATGRestRequestOptions)pOptions {
  if(self.parentFactory){
    [self.parentFactory enqueueRestOperation:pOperation withOptions:pOptions];
  }
  else{
    [super enqueueRestOperation:pOperation withOptions:pOptions];
  }
}

- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)pOperation{
  if(self.parentFactory){
    [self.parentFactory enqueueRestOperation:pOperation];
  }
  else{
    [super enqueueRestOperation:pOperation];
  }
}

- (void) setUserAgentString:(NSString *)pUserAgent{
  if (self.parentFactory) {
    [self.parentFactory setUserAgentString:pUserAgent];
  }
  else {
    [super setUserAgentString:pUserAgent];
  }
}

-(void)setStringEncoding:(NSStringEncoding)pStringEncoding{
  if(self.parentFactory){
    [self.parentFactory setStringEncoding:pStringEncoding];
  }
  else {
    [super setStringEncoding:pStringEncoding];
  }
}
-(NSStringEncoding)stringEncoding{
  if(self.parentFactory){
    return [self.parentFactory stringEncoding];
  }
  else {
    return [super stringEncoding];
  }
}

@end
