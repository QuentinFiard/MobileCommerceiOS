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

#import "ATGReturnManager.h"
#import "ATGRestManager.h"
#import "ATGReturnRequest.h"
#import "ATGReturnManagerRequest.h"
#import "ATGReturnShippingGroup.h"
#import "ATGReturnItem.h"

static NSString *const ATG_ACTOR_PATH_RETURNS = @"/atg/commerce/custsvc/returns/ReturnsActor";
static NSString *const ATG_ACTOR_CHAIN_RETURNS_LIST = @"/returnsHistory";
static NSString *const ATG_ACTOR_CHAIN_RETURN_DETAILS = @"/details";
static NSString *const ATG_ACTOR_CHAIN_RETURN_REASONS = @"/returnReasons";
static NSString *const ATG_ACTOR_CHAIN_START_RETURN_ITEMS = @"/createReturnAndSelectItems";
static NSString *const ATG_ACTOR_CHAIN_CONFIRM_RETURN = @"/confirmReturn";

static ATGReturnManager *managerInstance;

@interface ATGReturnManager ()

@end

@implementation ATGReturnManager

+ (ATGReturnManager *)instance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    managerInstance = [[ATGReturnManager alloc] init];
  }
  );
  return managerInstance;
}

- (ATGRestSession *)restSession {
  return [[ATGRestManager restManager] restSession];
}

- (ATGReturnManagerRequest *)getReturnHistoryWithStartIndex:(NSNumber *)pStartIndex count:(NSNumber *)pCount
                                                    success:(void ( ^ ) (ATGReturnManagerRequest *request, NSArray *results))pSuccess
                                                    failure:(void ( ^ ) (ATGReturnManagerRequest *request, NSError *error))pFailure {
  ATGReturnManagerRequest *request = [[ATGReturnManagerRequest alloc] init];

  id<ATGRestOperation> operation = [[self restSession] executePostRequestForActorPath:[ATG_ACTOR_PATH_RETURNS stringByAppendingString:ATG_ACTOR_CHAIN_RETURNS_LIST]
                                                                           parameters:@{@"numReturns":[pCount stringValue]} requestFactory:nil options:ATGRestRequestOptionNone
                                                    success:^(id <ATGRestOperation> pOperation, id pResponseObject) {
                                                      NSArray *result = [ATGReturnRequest objectsFromArray:[pResponseObject objectForKey:@"result"]];
                                                      pSuccess(request, result);
                                                    }
                                                    failure:^(id <ATGRestOperation> pOperation, NSError *pError) {
                                                      pFailure(request, pError);
                                                    }];
  request.operation = operation;
  return request;

}

- (ATGReturnManagerRequest *)getDetailsForReturnId:(NSString *)pReturnId
                                           success:(void ( ^ ) (ATGReturnManagerRequest *request, ATGReturnRequest *result))pSuccess
                                           failure:(void ( ^ ) (ATGReturnManagerRequest *request, NSError *error))pFailure {
  ATGReturnManagerRequest *request = [[ATGReturnManagerRequest alloc] init];

  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pReturnId, @"returnRequestId", nil];

  id<ATGRestOperation> operation = [[self restSession] executePostRequestForActorPath:[ATG_ACTOR_PATH_RETURNS stringByAppendingString:ATG_ACTOR_CHAIN_RETURN_DETAILS]
                                                                           parameters:params requestFactory:nil options:ATGRestRequestOptionNone
                                                                              success:^(id <ATGRestOperation> pOperation, id pResponseObject) {
                                                                                ATGReturnRequest *result = (ATGReturnRequest *)[ATGReturnRequest objectFromDictionary:[pResponseObject objectForKey:@"result"]];
                                                                                pSuccess(request, result);
                                                                              }
                                                                              failure:^(id <ATGRestOperation> pOperation, NSError *pError) {
                                                                                pFailure(request, pError);
                                                                              }];
  request.operation = operation;
  return request;

}

- (ATGReturnManagerRequest *)getReturnReasonsWithSuccess:(void ( ^ ) (ATGReturnManagerRequest *request, NSArray *result))pSuccess
                                                 failure:(void ( ^ ) (ATGReturnManagerRequest *request, NSError *error))pFailure {
  ATGReturnManagerRequest *request = [[ATGReturnManagerRequest alloc] init];

  id<ATGRestOperation> operation = [[self restSession] executePostRequestForActorPath:[ATG_ACTOR_PATH_RETURNS stringByAppendingString:ATG_ACTOR_CHAIN_RETURN_REASONS]
                                                                           parameters:nil requestFactory:nil options:ATGRestRequestOptionNone
                                                                              success:^(id <ATGRestOperation> pOperation, id pResponseObject) {
                                                                                self.returnReasons = [pResponseObject objectForKey:@"reasons"];
                                                                                pSuccess(request, [pResponseObject objectForKey:@"reasons"]);
                                                                              }
                                                                              failure:^(id <ATGRestOperation> pOperation, NSError *pError) {
                                                                                pFailure(request, pError);
                                                                              }];
  request.operation = operation;
  return request;
}

- (ATGReturnManagerRequest *)startReturnWithRequest:(ATGReturnRequest *)pReturnRequest
                                 success:(void ( ^ ) (ATGReturnManagerRequest *request, ATGReturnRequest *pReturnRequest))pSuccess
                                 failure:(void ( ^ ) (ATGReturnManagerRequest *request, NSError *error))pFailure {
  ATGReturnManagerRequest *request = [[ATGReturnManagerRequest alloc] init];
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:pReturnRequest.orderId, @"returnOrderId", nil];

  for (int i = 0; i < pReturnRequest.shippingGroupList.count; i++) {
    ATGReturnShippingGroup *rsg = (ATGReturnShippingGroup *)[pReturnRequest.shippingGroupList objectAtIndex:i];
    for (int j = 0; j < rsg.itemList.count; j++) {
      ATGReturnItem *ri = (ATGReturnItem *) [rsg.itemList objectAtIndex:j];
      int quantityToReturn = [ri.quantityToReturn intValue];
      if (quantityToReturn > 0) {
        [params setObject:ri.quantityToReturn forKey:[NSString stringWithFormat:@"returnRequest.shippingGroupList[%i].itemList[%i].quantityToReturn", i, j]];
        [params setObject:[[self.returnReasons allKeysForObject:ri.returnReasonDescription] objectAtIndex:0] forKey:[NSString stringWithFormat:@"returnRequest.shippingGroupList[%i].itemList[%i].returnReason", i, j]];
      }
    }
  }

  id<ATGRestOperation> operation = [[self restSession] executePostRequestForActorPath:[ATG_ACTOR_PATH_RETURNS stringByAppendingString:ATG_ACTOR_CHAIN_START_RETURN_ITEMS]
                                                                           parameters:params requestFactory:nil options:ATGRestRequestOptionNone
                                                                              success:^(id <ATGRestOperation> pOperation, id pResponseObject) {
                                                                                ATGReturnRequest *returnRequest = (ATGReturnRequest *)[ATGReturnRequest objectFromDictionary:[pResponseObject objectForKey:@"result"]];
                                                                                pSuccess(request, returnRequest);
                                                                              }
                                                                              failure:^(id <ATGRestOperation> pOperation, NSError *pError) {
                                                                                pFailure(request, pError);
                                                                              }];
  request.operation = operation;
  return request;
}

- (ATGReturnManagerRequest *)confirmReturnWithSuccess:(void ( ^ ) (ATGReturnManagerRequest *request, NSString *pReturnRequestId))pSuccess
                                              failure:(void ( ^ ) (ATGReturnManagerRequest *request, NSError *error))pFailure {


  ATGReturnManagerRequest *request = [[ATGReturnManagerRequest alloc] init];
  id<ATGRestOperation> operation = [[self restSession] executePostRequestForActorPath:[ATG_ACTOR_PATH_RETURNS stringByAppendingString:ATG_ACTOR_CHAIN_CONFIRM_RETURN]
                                                                           parameters:nil requestFactory:nil options:ATGRestRequestOptionNone
                                                                              success:^(id <ATGRestOperation> pOperation, id pResponseObject) {
                                                                                NSString *returnRequestId = [pResponseObject objectForKey:@"returnRequestId"];
                                                                                pSuccess(request, returnRequestId);
                                                                              }
                                                                              failure:^(id <ATGRestOperation> pOperation, NSError *pError) {
                                                                                pFailure(request, pError);
                                                                              }];
  request.operation = operation;
  return request;
}

@end
