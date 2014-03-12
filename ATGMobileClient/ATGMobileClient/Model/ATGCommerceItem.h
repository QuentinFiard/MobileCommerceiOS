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

/*!

   @header
   @abstract The base class for Commerce Items

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Model/ATGCommerceItem.h#1 $$Change: 848678 $

 */

#import "ATGCommerceItemSku.h"
#import "ATGHardgoodShippingGroup.h"

/*!
   @class
   @abstract The CommerceItem object of which @link ATGOrder @/link contains a collection.
 */
@interface ATGCommerceItem : ATGRestEntity

/*!
   @property
   @abstract the ID of this commerce item
 */
@property (nonatomic, copy) NSString *commerceItemId;

/*!
   @property
   @abstract the product ID
 */
@property (nonatomic, copy) NSString *prodId;

/*!
 @property
 @abstract the shipping group this commerce item belongs to
 */
@property (nonatomic, weak) ATGHardgoodShippingGroup *shippingGroup;

/*!
   @property
   @abstract is this a navigable product?
   @discussion non-navigable items (like gift with purchase, gift wrap) should not be selectable in the cart
 */
@property (nonatomic, assign) BOOL isNavigableProduct;

/*!
   @property
   @abstract NSArray of promotions applied to this item
 */
@property (nonatomic, copy) NSArray *appliedPromotions;

/*!
   @property
   @abstract NSArray of unit prices
   @discussion unit prices are the price for a group of items. e.g. a buy 2 get one free promotion
   would result in a unit with 1 item for free and the other unit with 2 items at the regular price
 */
@property (nonatomic, readwrite, copy) NSArray *unitPrices;

/*!
   @property
   @abstract NSString path to image
 */
@property (nonatomic, copy) NSString *thumbnailImage;

/*!
   @property
   @abstract quantity of the item
 */
@property (nonatomic, strong) NSNumber *qty;

/*!
   @property
   @abstract sales price
 */
@property (nonatomic, strong) NSDecimalNumber *salePrice;

/*!
   @property
   @abstract list price
 */
@property (nonatomic, strong) NSDecimalNumber *listPrice;

/*!
   @property
   @abstract the actual price
   @discussion "price" here is the price on the commerce item which takes
   into account the quantity of the item, the sale price and
   any promotions that have been applied
 */
@property (nonatomic, strong) NSDecimalNumber *price;

/*!
 @property
 @abstract the total value of all adjustments
 @discussion this is the amount the price is adjusted by
 */
@property (nonatomic, strong) NSDecimalNumber *adjustmentTotal;

/*!
 @property
 @abstract the total price calculated from price details
 @discussion A commerce item retrieved through a shipping group relationship needs to have its price 
             calculated by iterating through its price details
 */
@property (nonatomic, strong) NSDecimalNumber *totalPrice;

/*!
 @property
 @abstract the total quantity calculated from price details
 */
@property (nonatomic) int totalQuantity;

/*!
   @property
   @abstract if the item is on sale
 */
@property (nonatomic, assign) BOOL onSale;

/*!
   @property
   @abstract if the item is discounted
 */
@property (nonatomic, assign) BOOL discounted;

/*!
   @property isGiftWrap
   @abstract Defines whether curren commerce item is a gift wrap or not.
 */
@property (nonatomic, readwrite, getter = isGiftWrap) BOOL isGiftWrap;

/*!
   @property
   @abstract the SKU item
 */
@property (nonatomic, strong) ATGCommerceItemSku *sku;
/*!
 @property siteId
 @abstract Commerce item's origin site ID.
 */
@property (nonatomic, copy, readwrite) NSString *siteId;
/*!
 @property siteName
 @abstract Commerce item's origin site name.
 */
@property (nonatomic, copy, readwrite) NSString *siteName;

/*!
 @property isReturnable
 @abstract is this commerce item eligible for return?
 */
@property (nonatomic) BOOL returnable;

/*!
 @property returnableDescription
 @abstract description eligibility for return
 */
@property (nonatomic, strong) NSString *returnableDescription;

@end