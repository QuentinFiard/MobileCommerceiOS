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

#import "ATGOrder.h"
#import "ATGCommerceItem.h"
#import "ATGReturnRequest.h"
#import "ATGShippingGroup.h"
#import "ATGPricingAdjustment.h"

@implementation ATGGiftMessage

@synthesize from;
@synthesize to;
@synthesize text;

@end

@implementation ATGOrder

@synthesize
commerceItems = _commerceItems,
orderId = _orderId,
orderDescription = _orderDescription,
totalItems = _totalItems,
submittedDate = _submittedDate,
lastModifiedTime = _lastModifiedTime,
state = _state,
status = _status,
numberFormatter = _numberFormatter,
shippingMethod = _shippingMethod,
creditCard = _creditCard,
shippingAddress = _shippingAddress,
appliedPromotions = _appliedPromotions,
index = _index,
containsGiftWrap = _containsGiftWrap,
shippingGroupCount = _shippingGroupCount,
totalCommerceItemCount = _totalCommerceItemCount,
couponCode = _couponCode,
email = _email,
securityStatus = _securityStatus,
giftMessage,
relationships;

static NSString *const ATG_PAYMENT_GROUP_CREDIT_CARD_CLASS = @"atg.commerce.order.CreditCard";

- (id) initWithIndex:(int)pIndex {
  self = [super init];
  if (self) {
    _index = pIndex;
  }

  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Order: \r storeCreditsAppliedTotal:  %@\r storeCreditsAvailable: %@\r" \
          "priceInfo: %@\r commerceItems: %@\r orderId: %@\r orderDescription: %@\r totalItem: %@\r submittedDate: %@\r" \
          "lastModifiedTime: %@ status: %@\r shippingMethod: %@\r creditCard: %@\r shippingAddress: %@\r" \
          "appliedPromotions: %@\r containsGiftWrap: %d\r shippingGroupCount: %@\r totalCommerceItemCount: %@\r, giftMessage: %@",
          _storeCreditsAppliedTotal, _storeCreditsAvailable, _priceInfo, _commerceItems, _orderId, _orderDescription, _totalItems, _submittedDate,
          _lastModifiedTime, _status, _shippingMethod, _creditCard, _shippingAddress, _appliedPromotions, _containsGiftWrap,
          _shippingGroupCount, _totalCommerceItemCount, [self giftMessage]];
}

- (NSNumberFormatter *) numberFormatter {
  if (_numberFormatter == nil) {
    return _numberFormatter;
  }

  _numberFormatter = [[NSNumberFormatter alloc] init];
  [_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [_numberFormatter setCurrencyCode:self.priceInfo.currencyCode];
  [_numberFormatter setLocale:[NSLocale currentLocale]];

  return _numberFormatter;
}

- (NSString *)parseId:(NSString *)pOrderId {
  [self setOrderId:pOrderId];
  return nil;
}

- (NSArray *)parseShippingGroups:(NSArray *)pShippingGroups {
  NSMutableArray *shippingGroups = [NSMutableArray arrayWithArray:[ATGHardgoodShippingGroup objectsFromArray:pShippingGroups]];
  // remove shipping groups containing no commerce items
  for (int i = 0; i < shippingGroups.count; i++) {
    ATGHardgoodShippingGroup *hgsg = (ATGHardgoodShippingGroup *)[shippingGroups objectAtIndex:i];
    if (hgsg.commerceItems == nil || hgsg.commerceItems.count == 0) {
      [shippingGroups removeObjectAtIndex:i];
      i--;
    }
  }
  return shippingGroups;
}

- (ATGOrderPriceInfo *)parsePriceInfo:(NSDictionary *)pRawPriceInfo {
  return (ATGOrderPriceInfo *)[ATGOrderPriceInfo objectFromDictionary:pRawPriceInfo];
}

- (NSArray *)parseAdjustments:(NSArray *)pRawAdjustments {
  [self setAppliedPromotions:[ATGPricingAdjustment objectsFromArray:pRawAdjustments]];
  return nil;
}

- (NSArray *) parseCommerceItems:(NSArray *)pItems {
  return [ATGCommerceItem objectsFromArray:pItems];
}

- (ATGContactInfo *) parseShippingAddress:(NSDictionary *)pAddress {
  return (ATGContactInfo *)[ATGContactInfo objectFromDictionary:pAddress];
}

- (ATGCreditCard *) parseCreditCard:(NSDictionary *)pCard {
  return (ATGCreditCard *)[ATGCreditCard objectFromDictionary:pCard];
}

- (void)setFirstName:(NSString *)firstName {
  if (!_shippingAddress) {
    _shippingAddress = [[ATGContactInfo alloc] init];
  }
  _shippingAddress.firstName = firstName;
}

- (void)setLastName:(NSString *)lastName {
  if (!_shippingAddress) {
    _shippingAddress = [[ATGContactInfo alloc] init];
  }
  _shippingAddress.lastName = lastName;
}

- (NSDate *) parseSubmittedDate:(id)pDate {
  return [self parseDate:pDate];
}

- (NSDate *) parseLastModifiedTime:(id) pTime {
  return [self parseDate:pTime];
}

- (NSDate *) parseDate:(id)pDate {
  if (pDate != [NSNull null]) {
    if ([pDate isKindOfClass:[NSDictionary class]] && [(NSDictionary *)pDate valueForKey:@"time"]) {
      NSTimeInterval epochTime = [[pDate objectForKey:@"time"] longLongValue] / 1000;
      return [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    } else {
      NSTimeInterval epochTime = [pDate doubleValue];
      if (epochTime > 1000000000000) {
        // the time from the server is in milliseconds, so divide by 1000 to get it in seconds.
        epochTime = epochTime / 1000;
      }
      return [NSDate dateWithTimeIntervalSince1970: epochTime];
    }
  }
  return nil;
}

- (ATGGiftMessage *) parseGiftMessage:(id)pGiftMessage {
  if (pGiftMessage != [NSNull null]) {
    return (ATGGiftMessage *)[ATGGiftMessage objectFromDictionary:pGiftMessage];
  }
  return nil;
}

- (NSArray *)parsePaymentGroupRelationships:(NSArray *)pPaymentGroupRelationships {
  for (NSDictionary *paymentGroupRel in pPaymentGroupRelationships) {
    NSNumber *amt = [paymentGroupRel objectForKey:@"amount"];
    if ([amt boolValue]) { // ignore payment groups with amount == 0
      NSString *paymentGroupClass = [paymentGroupRel objectForKey:@"paymentGroupClass"];
      if ([paymentGroupClass isEqualToString:ATG_PAYMENT_GROUP_CREDIT_CARD_CLASS]) {
        NSDictionary *paymentGroup = [paymentGroupRel objectForKey:@"paymentGroup"];
        self.creditCard = (ATGCreditCard *)[ATGCreditCard objectFromDictionary:paymentGroup];
      }
    }
  }
  return pPaymentGroupRelationships;
}

- (NSArray *)parseReturnRequests:(NSArray *)pReturnRequests {
  return [ATGReturnRequest objectsFromArray:pReturnRequests];
}

- (NSArray *)parseRelationships:(NSArray *)pRelationships {

  // if there are no commerce items, this method can't do anything, so return straightaway
  if (!self.commerceItems)
    return pRelationships;

  for (NSDictionary *relationship in pRelationships) {
    NSString *commerceItemId = [relationship objectForKey:@"commerceItemId"];
    NSString *shippingGroupId = [relationship objectForKey:@"shippingGroupId"];

    for (id<ATGShippingGroup> group in self.shippingGroups) {
      // determine whether or not this shipping group is the one referenced by this relationship
      if ([group isKindOfClass:[ATGHardgoodShippingGroup class]] && [((ATGHardgoodShippingGroup *) group).repositoryId isEqualToString:shippingGroupId]) {
        ATGHardgoodShippingGroup *hardgoodGroup = (ATGHardgoodShippingGroup*) group;

        NSMutableArray *commerceItems = [[NSMutableArray alloc] init];

        // get the commerce item that is referenced by this relationship
        for (ATGCommerceItem *commerceItem in self.commerceItems) {
          if ([commerceItem.commerceItemId isEqualToString:commerceItemId]) {
            [commerceItems addObject:commerceItem];
            break;
          }
        }
        
        // if there already are some commerce items, add them here.
        if (hardgoodGroup.commerceItems) {
          [commerceItems addObjectsFromArray:hardgoodGroup.commerceItems];
        }
        hardgoodGroup.commerceItems = commerceItems;

        // if we get here, the shipping group and commerce item have been matched, so loop no further.
        break;
      }
    }
  }
  return pRelationships;
}

#pragma mark - Custom Property Getters

- (NSArray *)commerceItems {
  if (_commerceItems) {
    return _commerceItems;
  }
  if (self.shippingGroups.count > 0) {
    NSMutableArray *commerceItems = [[NSMutableArray alloc] init];
    for (ATGHardgoodShippingGroup *hgsg in self.shippingGroups) {
      [commerceItems addObjectsFromArray:hgsg.commerceItems];
    }
    return commerceItems;
  }
  return nil;
}

- (NSString *)shippingMethod {
  if (!_shippingMethod && self.shippingGroups.count > 0) {
    _shippingMethod = ((ATGHardgoodShippingGroup *)[self.shippingGroups objectAtIndex:0]).shippingMethod;
  }
  return _shippingMethod;
}

- (ATGContactInfo *)shippingAddress {
  if (!_shippingAddress && self.shippingGroups.count > 0) {
    _shippingAddress = ((ATGHardgoodShippingGroup *)[self.shippingGroups objectAtIndex:0]).shippingAddress;
  }
  return _shippingAddress;
}

- (NSNumber *)totalCommerceItemCount {
  return _totalCommerceItemCount ? _totalCommerceItemCount : _totalItems;
}

@end
