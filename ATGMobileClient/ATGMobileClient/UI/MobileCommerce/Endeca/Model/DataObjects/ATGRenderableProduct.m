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

#import "ATGRenderableProduct.h"
#import <ATGMobileClient/ATGRestManager.h>

@implementation ATGRenderableProduct
@synthesize title = _title, subTitle1 = _subTitle1, subTitle2 = _subTitle2, auxTitle = _auxTitle,
                    imageURL = _imageURL, shortDescription = _shortDescription;


- (NSString *)title {
  return [self valueForProperty:@"product.displayName"];
}

- (NSString *)subTitle1 {
  return [self valueForProperty:@"product.brand"];
}

- (NSString *)subTitle2 {
  return [self valueForProperty:@"product.briefDescription"];
}

- (NSString *)auxTitle {
  NSArray *activePrices = (NSArray *)[((EMRecord *)[self.records objectAtIndex:0]).attributes valueForKey:@"sku.activePrice"];
  if (activePrices.count == 1) {
    return [NSString stringWithFormat:@"$%.2f", [[activePrices objectAtIndex:0] floatValue]];
  }
  activePrices = [activePrices sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [[NSDecimalNumber numberWithFloat:[obj1 floatValue]] compare:[NSDecimalNumber numberWithFloat:[obj2 floatValue]]];
  }];
  return [NSString stringWithFormat:@"$%.2f - $%.2f", [[activePrices objectAtIndex:0] floatValue], [[activePrices lastObject] floatValue]];
}

- (NSString *)imageURL {
  return [ATGRestManager getAbsoluteImageString:[self valueForProperty:@"product.mediumImage.url"]];
}

- (NSString *)largeImageURL {
  return [ATGRestManager getAbsoluteImageString:[self valueForProperty:@"product.largeImage.url"]];
}

- (NSString *)shortDescription {
  return [self valueForProperty:@"product.description"];
}

- (NSString *)uniqueID {
  return [self valueForProperty:@"product.repositoryId"];
}

- (NSString *)valueForProperty:(NSString *)property {
  NSString *value = nil;
  
  value = (NSString *)[(NSArray *)[self.attributes valueForKey:property] objectAtIndex:0];
  if (!value || value.length < 1) {
    value = (NSString *)[(NSArray *)[((EMRecord *)[self.records objectAtIndex:0]).attributes valueForKey:property] objectAtIndex:0];
  }
  
  return value;
}

- (NSString *)accessibilityLabel {
  return [NSString stringWithFormat:@"%@ %@ %@", [self title], [self subTitle1], [self auxTitle]];
}

- (BOOL)isOnSale {
  CGFloat highestPrice = [self valueForProperty:@"product.highestListPrice"].floatValue;
  CGFloat lowestPrice = [self valueForProperty:@"product.lowestSalePrice"].floatValue;
  return highestPrice > lowestPrice;
}

@end
