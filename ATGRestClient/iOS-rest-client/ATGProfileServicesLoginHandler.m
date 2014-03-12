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

#import "ATGProfileServicesLoginHandler.h"

NSString *const ATG_PROFILE_SERVICES_COMPONENT_PATH = @"/atg/userprofiling/ProfileServices";

NSString *const ATG_PROFILE_SERVICES_LOGIN_METHOD = @"loginUser";

NSString *const ATG_PROFILE_SERVICES_LOGOUT_METHOD = @"logoutUser";

@implementation ATGProfileServicesLoginHandler

@synthesize restSession = _restSession;

-(id) initWithRestSession:(ATGRestSession*)pRestSession{
  self = [super init];
  if (self) {
    self.restSession = pRestSession;
  }
  return self;
}

-(id<ATGRestOperation>)login:(NSString *)pUsername 
                    password:(NSString*)pPassword 
                     factory:(id <ATGRestRequestFactory>)pRequestFactory
                     options:(ATGRestRequestOptions) pOptions
                     success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess 
                     failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure{
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  // CRS stores login usernames as lower case
  [params setObject:[pUsername lowercaseString] forKey:@"arg1"];
  [params setObject:pPassword forKey:@"arg2"];
  
  return [self.restSession executeMethod:ATG_PROFILE_SERVICES_LOGIN_METHOD 
                               component:ATG_PROFILE_SERVICES_COMPONENT_PATH
                               arguments:nil parameters:params 
                          requestFactory:pRequestFactory
                                 options:pOptions  
                                 success:^( id <ATGRestOperation>pOperation , id pResponseObject ){
                                     self.restSession.userId = pResponseObject;
                                     if (![self.restSession.userId isNotBlank]){
                                       self.restSession.userId = nil; 
                                       NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringWithDefaultValue(@"mobile.login.failure", nil, [NSBundle mainBundle], @"Login Failure", @"Login Failutre"),NSLocalizedDescriptionKey, nil];
                                       NSError *error = [NSError errorWithDomain:ATGRestClientException code:403 userInfo:userInfo];
                                       pFailure(pOperation,*&error,nil);
                                     }else {
                                      pSuccess(pOperation, self.restSession.userId); 
                                     }
                                 } 
                                 failure:^( id <ATGRestOperation>pOperation , NSError *pError ){                                                                              
                                   pFailure(pOperation,pError,nil);
                                 }];
}

-(id<ATGRestOperation>)logout:(id <ATGRestRequestFactory>)pRequestFactory
                      options:(ATGRestRequestOptions) pOptions
                      success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess 
                      failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure{
  if (![self.restSession.userId isNotBlank]) {
    DebugLog(@"This session is not logged in and cannot be logged out");
  }
  
  return [self.restSession executeMethod:ATG_PROFILE_SERVICES_LOGOUT_METHOD
                               component:ATG_PROFILE_SERVICES_COMPONENT_PATH
                               arguments:nil
                              parameters:nil
                          requestFactory:pRequestFactory
                                 options:pOptions
                                 success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
                                   self.restSession.userId = nil;
                                   [self.restSession resetSessionConfirmationNumber];
                                   pSuccess(pOperation, pResponseObject);
                                 } failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
                                   NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringWithDefaultValue(@"mobile.logout.failure", nil, [NSBundle mainBundle], @"Logout Failure", @"Logout Failutre"),NSLocalizedDescriptionKey,pError,ATGRestClientExceptionErrorKey, nil];
                                   NSError *error = [NSError errorWithDomain:ATGRestClientException code:403 userInfo:userInfo];
                                   pFailure(pOperation,*&error,nil);
                                 }];
}

@end
