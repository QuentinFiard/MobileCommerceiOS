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

#import "ATGExpandableTableViewCell.h"
#import "ATGCartTableViewCellDelegate.h"

/*!
   @class ATGCartTableViewCell
   @abstract This class represents a single item in a user's shopping cart.
   @discussion Use instances of ATGCartTableViewCell to fill UITableView with
   contents of the user's shopping cart.

   ATGCartTableViewCell is an ATGExpandableTableViewCell, that is it's height may be
   changed when the cell is selected.

   ATGCartTableViewCell also changes its appearance when selected. It displays
   additional buttons to enable the user edit current item, remove it from cart
   or share it with friends. Each time the user touches an action button on the cell,
   ATGCartTableViewCell notifies its delegate about this event. The delegate
   must adopt the ATGCartTableViewCellDelegate protocol.
 */
@interface ATGCartTableViewCell : UITableViewCell <ATGExpandableTableViewCell>

/*!
   @property itemId
   @abstract ID of commerce item represented by this row.
 */
@property (nonatomic, readwrite, copy) NSString *itemId;

/*!
   @property productName
   @abstract Name of displayed product.
 */
@property (nonatomic, readwrite, copy) NSString *productName;
/*!
   @property oldPrice
   @abstract Price of the displayed product without discounts applied.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *oldPrice;
/*!
   @property productId
   @abstract ID of product represented by the row.
 */
@property (nonatomic, readwrite, copy) NSString *productId;
/*!
   @property skuId
   @abstract ID of SKU represented by the row.
 */
@property (nonatomic, readwrite, copy) NSString *skuId;
/*!
   @property SKUProperties
   @abstract SKU property values to be displayed.
 */
@property (nonatomic, readwrite, copy) NSArray *SKUProperties;
/*!
   @property imageURL
   @abstract URL of product image to be displayed.
 */
@property (nonatomic, readwrite, copy) NSString *imageURL;
/*!
   @property currencyCode
   @abstract Currency code to be used when calculating price and quantity strings.
   @discussion This currency will be used when determining currency and
   number format to be used when displaying prices or quantities.
 */
@property (nonatomic, readwrite, copy) NSString *currencyCode;
/*!
   @property quantity
   @abstract Quantity of product added to shopping cart.
 */
@property (nonatomic, readonly, assign) NSUInteger quantity;
/*!
   @property priceBeans
   @abstract Price beans to be used.
 */
@property (nonatomic, readwrite, copy) NSArray *priceBeans;

@property (nonatomic, readwrite) BOOL isNavigable;

/*!
   @property delegate
   @abstracgt Cell's delegate to be used.
   @discussion This delegate will be notified about all events generated by the cell.
 */
@property (nonatomic, readwrite, weak) id <ATGCartTableViewCellDelegate> delegate;

@end