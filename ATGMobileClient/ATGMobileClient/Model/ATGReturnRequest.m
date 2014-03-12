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

#import "ATGReturnRequest.h"
#import "ATGReturnShippingGroup.h"
#import "ATGHardgoodShippingGroup.h"
#import "ATGReturnItem.h"
#import "ATGCommerceItem.h"
#import "ATGOrder.h"

@implementation ATGReturnRequest

- (NSArray *)parseShippingGroupList:(NSArray *)pShippingGroups {
  return [ATGReturnShippingGroup objectsFromArray:pShippingGroups];
}

- (NSArray *)parseReturnItemList:(NSArray *)pReturnItemList {
  return [ATGReturnItem objectsFromArray:pReturnItemList];
}

// fill in the ATGReturnShippingGroup.itemList with ATGReturnItems from returnItems
- (NSArray *)shippingGroupList {
  if (!self.shippingGroupListWithReturnItems) {
    NSMutableArray *sgList = [NSMutableArray arrayWithArray:_shippingGroupList];
    NSMutableArray *emptyShippingGroupsToBeRemovedPostEnumeration = [NSMutableArray arrayWithCapacity:0];
    for (ATGReturnShippingGroup *returnShippingGroup in sgList) {
      NSMutableArray *returnItemList = [NSMutableArray new];
      for (NSDictionary *itemList in returnShippingGroup.itemList) {
        if (![itemList isKindOfClass:[NSDictionary class]])  {
          // list already contains ATGReturnItems, skip this stuff
          self.shippingGroupListWithReturnItems = _shippingGroupList;
          return self.shippingGroupListWithReturnItems;
        }
        NSString *cId = [itemList objectForKey:@"commerceItemId"];
        for (ATGReturnItem *returnItem in self.returnItemList) {
          if ([returnItem.commerceItem.commerceItemId isEqualToString:cId] && [returnItem.shippingGroupId isEqualToString:returnShippingGroup.shippingGroupId]) {
            [returnItemList addObject:returnItem];
            break;
          }
        }
      }
      returnShippingGroup.itemList = returnItemList;
      if (returnItemList.count < 1)
        [emptyShippingGroupsToBeRemovedPostEnumeration addObject:returnShippingGroup];
    }
    [sgList removeObjectsInArray:emptyShippingGroupsToBeRemovedPostEnumeration];
    self.shippingGroupListWithReturnItems = [NSArray arrayWithArray:sgList];
  }
  
  return self.shippingGroupListWithReturnItems;
}

- (void)setPromotionDisplayNameValueAdjustments:(NSDictionary *)promotionDisplayNameValueAdjustments {
  NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
  [promotionDisplayNameValueAdjustments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (key && obj && key != [NSNull null] && obj != [NSNull null]) {
      [mutableDictionary setValue:obj forKey:key];
    }
  }];
  _promotionDisplayNameValueAdjustments = [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

- (ATGOrderPriceInfo *)parseOrderPriceInfo:(NSDictionary *)pPriceInfo {
  return (ATGOrderPriceInfo *)[ATGOrderPriceInfo objectFromDictionary:pPriceInfo];
}

+ (ATGReturnRequest *)returnRequestWithOrder:(ATGOrder *)pOrder {
  ATGReturnRequest *returnRequest = [[ATGReturnRequest alloc] init];
  returnRequest.orderId = pOrder.orderId;
  returnRequest.thumbnailImageUrl = pOrder.thumbnailImageUrl;
  returnRequest.universalReturn = @0;
  NSMutableArray *shippingGroupList = [NSMutableArray arrayWithCapacity:0];
  for (ATGHardgoodShippingGroup *group in pOrder.shippingGroups) {
    ATGReturnShippingGroup *shippingGroup = [[ATGReturnShippingGroup alloc] init];
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    for (ATGCommerceItem *it in group.commerceItems) {
      ATGReturnItem *item = [[ATGReturnItem alloc] init];
      item.commerceItem = it;
      [itemList addObject:item];
    }
    shippingGroup.itemList = [NSArray arrayWithArray:itemList];
    [NSArray arrayWithArray:group.commerceItems];
    shippingGroup.shippingMethod = group.shippingMethod;
    shippingGroup.shippingAddress = [group.shippingAddress copy];
    [shippingGroupList addObject:shippingGroup];
  }
  returnRequest.shippingGroupList = [NSArray arrayWithArray:shippingGroupList];
  return returnRequest;
}
@end
