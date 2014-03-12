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

#import "ATGShippingAddressesViewController.h"
#import <ATGMobileClient/ATGTableViewController.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGAddressesViewController.h>
#import <ATGMobileClient/ATGCommerceManagerDelegate.h>
#import <ATGMobileClient/ATGOrder.h>

@class ATGOrder;
@class ATGManagerRequest;

/*!
   @class ATGShoppingCartViewController_iPad
   @abstract This class manages the Shopping Cart screen.
   @discussion You may subclass ATGShoppingCartViewController_iPad to display other similar screens.
 */
@interface ATGShoppingCartViewController_iPad : ATGTableViewController <ATGProfileManagerDelegate, ATGAddressesViewControllerDelegate, ATGCommerceManagerDelegate, UITextFieldDelegate>

/*!
   @property order
   @abstract Reference to currently displayed order (or shopping cart).
 */
@property (nonatomic, readwrite, strong) ATGOrder *order;

// Currently running REST request.
@property (nonatomic, readwrite, strong) ATGManagerRequest *currentRequest;
// Price formatter configured with current order currency.
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
// Just simple formatter to convert number to string
@property (nonatomic, strong) NSNumberFormatter *formatter;

/*!
   @method loadOrder
   @abstract Override this method to use your custom code which will load an order.
 */
- (void) loadOrder;
/*!
   @method orderDidLoad:
   @abstract Override this method to initialize controller's inner properties.
   @discussion If you override this method, make sure to call super-implementation at some point
   to allow your superclass to initialize its inner contents. Moreover do not update UI within this method,
   as your class could also be extended, and it's a tricky task to undo your UI changes.
   @param order Order loaded.
 */
- (void) orderDidLoad:(ATGOrder *)order;
/*!
   @method shouldEditCellForRowAtIndexPath:
   @abstract Override this method to define, whether your controller supports swipe-to-edit gestures or not.
   @discussion Default value is YES.
   @param indexPath Index path of the cell to be edited.
   @return YES if swipe-to-edit gestures are supported, NO otherwise.
 */
- (BOOL) shouldEditCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/*!
   @category ATGOrder (ATGShoppingCart)
   @abstract Additional methods used by the Shopping Cart screen.
 */
@interface ATGOrder (ATGShoppingCart)

/*!
   @method acceptableCommerceItems
   @abstract Calculates order's commerce items which can be displayed by the Shopping Cart screen.
   @return Array of commerce items supported by Shopping Cart screen.
 */
- (NSArray *) acceptableCommerceItems NS_RETURNS_NOT_RETAINED;

@end