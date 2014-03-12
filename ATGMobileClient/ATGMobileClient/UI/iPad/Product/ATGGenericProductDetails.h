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
   @class ATGGenericProductDetailsPriceRange
   @abstract Represents a range price value.
   @discussion Instances of this class are part of the
   @link //apple_ref/occ/cl/ATGGenericProductDetailsPrice @/link instance.
 */
@interface ATGGenericProductDetailsPriceRange : NSObject

/*!
   @method initWithLowestPrice:highestPrice:
   @abstract Initializes price range object with its values.
   @param lowest Lowest price of the range.
   @param highest Highest price of the range.
   @return Fully configured instance.
 */
- (id) initWithLowestPrice:(NSNumber *)lowest highestPrice:(NSNumber *)highest;

/*!
   @property lowestPrice
   @abstract Lowest price of the range.
 */
@property (nonatomic, readonly, strong) NSNumber *lowestPrice;
/*!
   @property highestPrice
   @abstract Highest price of the range.
 */
@property (nonatomic, readonly, strong) NSNumber *highestPrice;

@end

/*!
   @class ATGGenericProductDetailsPrice
   @abstract Represents a price value of the product.
   @discussion Instances of this class contain full information about product price.
 */
@interface ATGGenericProductDetailsPrice : NSObject

/*!
   @method initWithCurrencyCode:listPrice:salePrice:
   @abstract Initializes simple representation of the price.
   @param code Currency code to be used when displaying the price to user.
   @param listPrice List price of the product.
   @param salePrice Sale price of the product.
   @return Fully configured price object.
 */
- (id) initWithCurrencyCode:(NSString *)code listPrice:(NSNumber *)listPrice
 salePrice                 :(NSNumber *)salePrice;
/*!
   @method initWithCurrencyCode:priceRange:
   @abstract Initializes range representation of the price.
   @param code Currency code to be used when displaying the price to user.
   @param range Range of prices for the product.
   @return Fully configured price object.
 */
- (id) initWithCurrencyCode:(NSString *)code
 priceRange                :(ATGGenericProductDetailsPriceRange *)range;

/*!
   @property currencyCode
   @abstract Use this code when formatting output to user.
 */
@property (nonatomic, readonly, strong) NSString *currencyCode;
/*!
   @property listPrice
   @abstract List price of the product. <code>nil</code> if product has a price range.
 */
@property (nonatomic, readonly, strong) NSNumber *listPrice;
/*!
   @property salePrice
   @abstract Sale price of the product. <code>nil</code> if product has a price range.
 */
@property (nonatomic, readonly, strong) NSNumber *salePrice;
/*!
   @property range
   @abstract Price range of the product.
 */
@property (nonatomic, readonly, strong) ATGGenericProductDetailsPriceRange *range;

@end

/*!
   @class ATGGenericProductDetails
   @abstract Generic details of the product to be used by PDP.
 */
@interface ATGGenericProductDetails : NSObject

/*!
   @method initWithProductID:name:image:price:
   @abstract Initializes the product details object with all related data.
   @param productID ID of the product.
   @param name ATGRenderableProduct display name.
   @param imageURL ATGRenderableProduct's thumbnail image URL.
   @param price ATGRenderableProduct's price.
   @return Fully configured product details object.
 */
- (id) initWithProductID:(NSString *)productID name:(NSString *)name
 image                  :(NSString *)imageURL price:(ATGGenericProductDetailsPrice *)price;

/*!
   @property productID
   @abstract ID of the product.
 */
@property (nonatomic, readonly, strong) NSString *productID;
/*!
   @property name
   @abstract ATGRenderableProduct display name.
 */
@property (nonatomic, readonly, strong) NSString *name;
/*!
   @property imageURL
   @abstract ATGRenderableProduct thumbnail image URL.
 */
@property (nonatomic, readonly, strong) NSString *imageURL;
/*!
   @property price
   @abstract ATGRenderableProduct price (either range or list price).
 */
@property (nonatomic, readonly, strong) ATGGenericProductDetailsPrice *price;

@end