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

#import <ATGUIElements/ATGPrefixLabel.h>
#import <ATGUIElements/ATGValidatableInput.h>

/*!
   @protocol ATGOrderTotalTableViewCellDelegate
   @abstract Adopt this protocol, if you want to receive messages from 'Order Total' cell.
 */
@protocol ATGOrderTotalTableViewCellDelegate

/*!
   @method claimCouponWithCode:
   @abstract Tels to claim a coupon with code specified.
   @param couponCode Coupon to be claimed.
 */
- (void)claimCouponWithCode:(NSString *)couponCode;

@end

#pragma mark - ATGOrderTotalTableViewCell Interface
#pragma mark -

/*!
   @class ATGOrderTotalTableViewCell
   @abstract Special kind of cell. Displays order total.
 */
@interface ATGOrderTotalTableViewCell : UITableViewCell

/*!
   @property itemsTotal
   @abstract Items subtotal amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *itemsTotal;
/*!
   @property discountTotal
   @abstract Discount subtotal amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *discountTotal;
/*!
   @property storeCreditsTotal
   @abstract Store credits amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *storeCreditsTotal;
/*!
   @property shippingTotal
   @abstract Shipping costs amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *shippingTotal;
/*!
   @property taxTotal
   @abstract Taxes amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *taxTotal;
/*!
   @property orderTotal
   @abstract Order grand total amount.
 */
@property (nonatomic, readwrite, strong) NSDecimalNumber *orderTotal;
/*!
   @property currencyCode
   @abstract Currency code to be used when displaying prices.
 */
@property (nonatomic, readwrite, copy) NSString *currencyCode;
/*!
   @property orderEmpty
   @abstract Set to YES, if order is empty. This will cause to hide all order details.
 */
@property (nonatomic, readwrite, assign, getter = isOrderEmpty) BOOL orderEmpty;
/*!
   @property discounts
   @abstract List of discount names to be displayed to user.
 */
@property (nonatomic, readwrite, copy) NSArray *discounts;
/*!
   @property delegate
   @abstract Delegate to be notified about UI events.
 */
@property (nonatomic, readwrite, weak) id <ATGOrderTotalTableViewCellDelegate> delegate;
/*!
   @property couponError
   @abstract Coupon-related error.
 */
@property (nonatomic, readwrite, copy) NSString *couponError;
/*!
   @property couponHidden
   @abstract Set to YES, if coupon code input field should be hidden.
 */
@property (nonatomic, readwrite, assign, getter = isCouponHidden) BOOL couponHidden;
/*!
 @property couponEditable
 @abstract Set to YES, if coupon code input field should be editable.
 */
@property (nonatomic, readwrite, assign, getter = isCouponEditable) BOOL couponEditable;
/*!
   @property couponCode
   @abstract Coupon code currently applied to the shopping cart.
 */
@property (nonatomic, readwrite, copy) NSString *couponCode;

@end