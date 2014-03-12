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

#import "ATGGenericProductDetails.h"

#pragma mark - ATGGenericProductDetailsPriceRange Private Protocol Definition
#pragma mark -

@interface ATGGenericProductDetailsPriceRange ()

// We're going to set some properties, so redefine them to be readwrite.
@property (nonatomic, readwrite, strong) NSNumber *lowestPrice;
@property (nonatomic, readwrite, strong) NSNumber *highestPrice;

@end

#pragma mark - ATGGenericProductDetailsPrice Private Protocol Definition
#pragma mark -

@interface ATGGenericProductDetailsPrice ()

// We're going to set some properties, so redefine them to be readwrite.
@property (nonatomic, readwrite, strong) NSString *currencyCode;
@property (nonatomic, readwrite, strong) NSNumber *listPrice;
@property (nonatomic, readwrite, strong) NSNumber *salePrice;
@property (nonatomic, readwrite, strong) ATGGenericProductDetailsPriceRange *range;

@end

#pragma mark - ATGGenericProductDetails Private Protocol Definition
#pragma mark -

@interface ATGGenericProductDetails ()

// We're going to set some properties, so redefine them to be readwrite.
@property (nonatomic, readwrite, strong) NSString *productID;
@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSString *imageURL;
@property (nonatomic, readwrite, strong) ATGGenericProductDetailsPrice *price;

@end

#pragma mark - ATGGenericProductDetailsPriceRange Implementation
#pragma mark -

@implementation ATGGenericProductDetailsPriceRange

#pragma mark - Synthesized Properties

@synthesize lowestPrice;
@synthesize highestPrice;

#pragma mark - Initialization Methods

- (id) initWithLowestPrice:(NSNumber *)pLowest highestPrice:(NSNumber *)pHighest {
  self = [super init];
  if (self) {
    [self setLowestPrice:pLowest];
    [self setHighestPrice:pHighest];
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"(%@ - %@)", [self lowestPrice], [self highestPrice]];
}

@end

#pragma mark - ATGGenericProductDetailsPrice Implementation
#pragma mark -

@implementation ATGGenericProductDetailsPrice

#pragma mark - Synthesized Properties

@synthesize currencyCode;
@synthesize listPrice;
@synthesize salePrice;
@synthesize range;

#pragma mark - Initialization Methods

- (id) initWithCurrencyCode:(NSString *)pCode listPrice:(NSNumber *)pListPrice salePrice:(NSNumber *)pSalePrice {
  self = [super init];
  if (self) {
    [self setCurrencyCode:pCode];
    [self setListPrice:pListPrice];
    [self setSalePrice:pSalePrice];
  }
  return self;
}

- (id) initWithCurrencyCode:(NSString *)pCode priceRange:(ATGGenericProductDetailsPriceRange *)pRange {
  self = [super init];
  if (self) {
    [self setCurrencyCode:pCode];
    [self setRange:pRange];
  }
  return self;
}

- (NSString *) description {
  if ([self range]) {
    return [NSString stringWithFormat:@"{currency: %@, price: %@}", [self currencyCode], [self range]];
  } else {
    return [NSString stringWithFormat:@"{currency: %@, price: {%@, %@}}",
            [self currencyCode], [self salePrice], [self listPrice]];
  }
}

@end

#pragma mark - ATGGenericProductDetails Implementation
#pragma mark -

@implementation ATGGenericProductDetails

#pragma mark - Synthesized Properties

@synthesize productID;
@synthesize name;
@synthesize imageURL;
@synthesize price;

#pragma mark - Initialization Methods

- (id) initWithProductID:(NSString *)pProductID name:(NSString *)pName image:(NSString *)pImageURL
                   price:(ATGGenericProductDetailsPrice *)pPrice {
  self = [super init];
  if (self) {
    [self setProductID:pProductID];
    [self setName:pName];
    [self setImageURL:pImageURL];
    [self setPrice:pPrice];
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"{ID: %@, name: %@, image: %@, price: %@}",
          [self productID], [self name], [self imageURL], [self price]];
}

@end