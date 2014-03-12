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

#import "ATGCommerceItem.h"
#import "ATGPricingAdjustment.h"

@implementation ATGCommerceItem

@synthesize commerceItemId = _commerceItemId,
prodId = _prodId,
isNavigableProduct = _isNavigableProduct,
appliedPromotions = _appliedPromotions,
thumbnailImage = _thumbnailImage,
qty = _qty,
salePrice = _salePrice,
listPrice = _listPrice,
price = _price,
onSale = _onSale,
sku = _sku,
unitPrices = _unitPrices,
isGiftWrap,
siteId;

- (NSString *) description {
  return [NSString stringWithFormat                                                                                                                                           :@"Commerce Item: \r commerceItemId: %@\r prodId: %@\r isNavigableProduct: %c\r appliedPromotions: %@\r" \
          "thumbnailImage: %@\r quantity: %@\r salePrice: %@\r listPrice: %@\r price: %@\ronSale: %d\r sku: %@\r isWrap: %@",
          _commerceItemId, _prodId, _isNavigableProduct, _appliedPromotions, _thumbnailImage, _qty, _salePrice, _listPrice, _price, _onSale, _sku, [self isGiftWrap] ? @"true":@"false"];
}

- (BOOL) isEqual:(id)pObject {
  // Objects of other classes cannot be compared with ATGCommerceItem
  // and therefore they are not equal to it.
  if (![pObject isKindOfClass:[ATGCommerceItem class]]) {
    return NO;
  }
  // There is a number of properties to be compared. Just compare them
  // one by one and then return the result, if everything is OK.
  ATGCommerceItem *other = (ATGCommerceItem *)pObject;
  if (![[self commerceItemId] isEqualToString:[other commerceItemId]]) {
    return NO;
  } else if (![[self prodId] isEqualToString:[other prodId]]) {
    return NO;
  } else if (![[[self sku] repositoryId] isEqualToString:[[other sku] repositoryId]]) {
    return NO;
  } else if (![[self appliedPromotions] isEqual:[other appliedPromotions]]) {
    return NO;
  } else if (![[self qty] isEqualToNumber:[other qty]]) {
    return NO;
  } else if (![[self unitPrices] isEqual:[other unitPrices]]) {
    return NO;
  } else {
    return YES;
  }
}

- (NSString *)parseId:(NSString *)pRawId {
  [self setCommerceItemId:pRawId];
  return nil;
}

- (NSNumber *)parseQuantity:(NSNumber *)pRawQuantity {
  [self setQty:pRawQuantity];
  return nil;
}

- (id)parseAuxiliaryData:(NSDictionary *)pRawData {
  [self applyPropertiesFromDictionary:pRawData];
  return nil;
}

- (NSString *)parseProductId:(NSString *)pRawId {
  [self setProdId:pRawId];
  return nil;
}

- (id)parseProductRef:(NSDictionary *)pRawData {
  NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:pRawData];
  // Do not override commerce item ID with product ID.
  [data removeObjectForKey:@"id"];
  [self applyPropertiesFromDictionary:data];
  return nil;
}

- (NSString *)parseThumbnailImageUrl:(NSString *)pRawURL {
  [self setThumbnailImage:pRawURL];
  return nil;
}

- (ATGCommerceItemSku *)parseCatalogRef:(NSDictionary *)pRawSKU {
  [self setSku:(ATGCommerceItemSku *)[ATGCommerceItemSku objectFromDictionary:pRawSKU]];
  return nil;
}

- (id)parsePriceInfo:(NSDictionary *)pRawPriceInfo {
  [self applyPropertiesFromDictionary:pRawPriceInfo];
  return nil;
}

- (NSDecimalNumber *)parseAmount:(NSNumber *)pRawAmount {
  NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithDecimal:[pRawAmount decimalValue]];
  [self setPrice:price];
  return nil;
}

- (NSArray *)parseAdjustments:(NSArray *)pRawAdjustments {
  [self setAppliedPromotions:[ATGPricingAdjustment objectsFromArray:pRawAdjustments]];

  // store the total value of all adjustments
  self.adjustmentTotal = [NSDecimalNumber zero];
  for (ATGPricingAdjustment *adjustment in self.appliedPromotions) {
    double total = self.adjustmentTotal.doubleValue + adjustment.totalAdjustment.doubleValue;
    self.adjustmentTotal = [[NSDecimalNumber alloc] initWithDouble:total];
  }
  return nil;
}

- (NSArray *)parseCurrentPriceDetailsSorted:(NSArray *)pRawPriceDetails {
  NSMutableArray *unitPrices = [[NSMutableArray alloc] initWithCapacity:[pRawPriceDetails count]];
  for (NSDictionary *priceBean in pRawPriceDetails) {
    NSNumber *quantity = [priceBean objectForKey:@"quantity"];
    NSNumber *rawPrice = [priceBean objectForKey:@"detailedUnitPrice"];
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithDecimal:[rawPrice decimalValue]];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[priceBean objectForKey:@"amount"] decimalValue]];
    NSDictionary *translatedBean = [NSDictionary dictionaryWithObjectsAndKeys:quantity, @"quantity",
                                                                              price, @"unitPrice",
                                                                              amount, @"amount", nil];
    [unitPrices addObject:translatedBean];
  }
  [self setUnitPrices:unitPrices];
  return nil;
}

- (NSString *)parseReturnable:(NSObject *)pReturnable {
  if ([pReturnable isKindOfClass:[NSDictionary class]]) {
    NSDictionary *returnableDict = (NSDictionary *)pReturnable;
    self.returnableDescription = [returnableDict objectForKey:@"returnableDescription"];
    return [returnableDict objectForKey:@"returnable"];
  }
  return (NSString *)pReturnable;

}

- (NSDecimalNumber *)totalPrice {
  if (!_totalPrice) {
    _totalPrice = [NSDecimalNumber zero];
    for (NSDictionary *unitPrice in self.unitPrices) {
      _totalPrice = [_totalPrice decimalNumberByAdding:(NSDecimalNumber *)[unitPrice valueForKey:@"amount"]];
    }
  }
  return _totalPrice;
}

- (int)totalQuantity {
  if (!_totalQuantity) {
    for (NSDictionary *unitPrice in self.unitPrices) {
      _totalQuantity += [[unitPrice valueForKey:@"quantity"] intValue];
    }
  }
  return _totalQuantity;
}

@end
