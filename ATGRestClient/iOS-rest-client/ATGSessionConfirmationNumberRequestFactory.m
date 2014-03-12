/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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

#import "ATGSessionConfirmationNumberRequestFactory.h"
#include <libkern/OSAtomic.h>

NSString *const ATG_SESSION_CONFIRMATION_PATH=@"/atg/rest/SessionConfirmation";
NSString *const ATG_SESSION_CONFIRMATION_PROP_NAME=@"sessionConfirmationNumber";

const int SCN_REQUESTED = 1;
const int SCN_NOT_REQUESTED = 0;

@interface ATGSessionConfirmationNumberRequestFactory ()
  @property (strong,nonatomic) NSMutableArray *deferredRestOperations;
@end

@implementation ATGSessionConfirmationNumberRequestFactory

+ (ATGSessionConfirmationNumberRequestFactory *) factoryWithStringEncoding:(NSStringEncoding)pStringEncoding restSession:(ATGRestSession *) pRestSession {
  return [[ATGSessionConfirmationNumberRequestFactory alloc] initWithStringEncoding:pStringEncoding restSession:pRestSession];
}

- (id) initWithStringEncoding:(NSStringEncoding)pStringEncoding restSession:(ATGRestSession *) pRestSession {
  self = [super initWithStringEncoding:pStringEncoding];
  if (!self) {
    return nil;
  }
  self.restSession = pRestSession;

  return self;
}

- (NSDictionary *)modifyParams:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions {
  if (!(pOptions & ATGRestRequestOptionRequireSessionConfirmation)) {
    return pParameters;
  }

  if (self.restSession->requestedSessionConfirmation == SCN_NOT_REQUESTED) {
    [self getSessionConfirmation];
  } else if ([self.restSession.sessionConfirmationNumber isNotBlank]) {
    NSMutableDictionary *params = [[super modifyParams:pParameters options:pOptions] mutableCopy];
    [params setObject:[self.restSession sessionConfirmationNumber] forKey:ATG_DYN_SESS_CONF];
    return params;
  }
  return pParameters;
}
- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)pOperation withOptions:(ATGRestRequestOptions)pOptions {

  if (pOptions & ATGRestRequestOptionRequireSessionConfirmation && ![self.restSession.sessionConfirmationNumber isNotBlank]) {
    if (self.deferredRestOperations == nil) {
      self.deferredRestOperations = [NSMutableArray new];
    }
    [self.deferredRestOperations addObject:pOperation];

    if (self.restSession->requestedSessionConfirmation == SCN_NOT_REQUESTED) {
      [self getSessionConfirmation];
    }
  } else {
    [super enqueueRestOperation:pOperation];
  }
}

- (id <ATGRestOperation>) getSessionConfirmation {
  // only make the request if it hasn't already been made
  if (!OSAtomicCompareAndSwapIntBarrier(SCN_NOT_REQUESTED, SCN_REQUESTED, &self.restSession->requestedSessionConfirmation)) {
    return nil;
  }
  return [self.restSession getPropertyValue:ATG_SESSION_CONFIRMATION_PROP_NAME component:ATG_SESSION_CONFIRMATION_PATH parameters:nil requestFactory:self options:ATGRestRequestOptionNone success:^(id <ATGRestOperation>operation, id responseObject) {
    self.restSession.sessionConfirmationNumber = [responseObject stringValue];

    NSArray *lDeferredRestOperations = self.deferredRestOperations;
    self.deferredRestOperations = nil;

    for (NSObject<ATGRestOperation> *restOperation in lDeferredRestOperations) {
      NSMutableURLRequest *requestCopy = [restOperation.request mutableCopy];

      [self setValue:self.restSession.sessionConfirmationNumber forKey:ATG_DYN_SESS_CONF onRequest:requestCopy];

      id <ATGRestOperation> operation = [self JSONRequestOperationWithRequest:requestCopy success:restOperation.successBlock failure:restOperation.failureBlock];
      [super enqueueRestOperation:operation];
    }

  } failure:^(id<ATGRestOperation> operation, NSError *error) {
    if (self.deferredRestOperations) {
      NSArray *lDeferredRestOperations = self.deferredRestOperations;
      self.deferredRestOperations = nil;
      // execute failure blocks of deferred operations since they depend on the SCN
      for (NSObject<ATGRestOperation> *restOperation in lDeferredRestOperations) {
        // send nil instead of the operation to prevent re-requesting SCN, which would cause a loop
        restOperation.failureBlock(nil, error);
      }
    }
    self.restSession->requestedSessionConfirmation = SCN_NOT_REQUESTED;
  }];
}

@end
