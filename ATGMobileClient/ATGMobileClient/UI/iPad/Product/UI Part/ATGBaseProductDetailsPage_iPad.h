/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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

#import <ATGMobileClient/ATGProduct.h>
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileClient/ATGCommerceManager.h>
#import <ATGMobileClient/ATGPopoverPicker.h>
#import <ATGMobileClient/ATGSkuPickersView.h>
#import <ATGUIElements/ATGButton.h>
#import "ATGProductPageViewController.h"

@class ATGCommerceItem;

/*!
   @class
   @abstract ATGRenderableProduct details controller. Displays all information about product.
 */

@class ATGImageView, ATGSkuPickersView, UIActivityIndicatorView;

@interface ATGBaseProductDetailsPage_iPad : UIViewController <ATGProductManagerDelegate, ATGCommerceManagerDelegate, ATGSkuPickerDelegate, ATGPickerDelegate>

/*!
   @method initWithProduct:presenter:
   @abstract This method instantiate class with product object.
   @param product ATGRenderableProduct object.
   @param presenter Object that will present that page.
   @return New instance of product page.
 */
- (id) initWithProduct:(ATGProduct *)product presenter:(ATGProductPageViewController *)presenter;
- (id) initWithProduct:(ATGProduct *)pProduct commerceItem:(ATGCommerceItem *)pCommerceItem presenter:(ATGProductPageViewController *)pPresenter;

- (ATGProductManager*) productManager;
- (ATGCommerceManager*) commerceManager;

#pragma mark - Properties

@property (nonatomic, strong) ATGProduct *product;
@property (nonatomic, strong) ATGSku *sku;
@property (nonatomic, strong) ATGCommerceItem *commerceItem;
@property (nonatomic, strong) ATGProductInventory *inventory;
@property (nonatomic, copy) NSString *quantity;
// fulfillment options
@property (nonatomic, strong) NSString *shippingGroupId;
@property (nonatomic, strong) NSString *locationId;

@property (nonatomic, strong) ATGProductManagerRequest *productRequest;

@property (nonatomic, readwrite, strong) UIPopoverController *popover;

@property (strong, nonatomic) ATGSkuPickersView *skuPickers;

@property (nonatomic, strong) ATGCommerceManagerRequest *commerceRequest;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, weak) ATGProductPageViewController *presenter;

/*!
 By default, if this page is displaying an ATGCommerceItem it is assumed that that item is in the Shopping Cart.  This property
 allows that assumption to be switched if, for example, the ATGCommerceItem is not in the cart, and is instead from an old order.
 */
@property (assign) BOOL assumeCommerceItemsAreInCart;

#pragma mark - IB Outlets
@property (weak, nonatomic) IBOutlet UIButton *compareButton;
@property (weak, nonatomic) IBOutlet UIButton *giftListButton;
@property (weak, nonatomic) IBOutlet UIButton *wishListButton;
@property (weak, nonatomic) IBOutlet UILabel *wishListLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftListLabel;
@property (weak, nonatomic) IBOutlet UILabel *compareLabel;

@property (weak, nonatomic) IBOutlet ATGImageView *productImage;

@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

// inventory status
@property (weak, nonatomic) IBOutlet UILabel *productStatus;

// add to cart/update item/email me/preorder button
@property (weak, nonatomic) IBOutlet ATGButton *actionButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet ATGPopoverPicker *quantityPicker;
@property (weak, nonatomic) IBOutlet UIView *actionsPane;

#pragma mark - IB Actions
- (IBAction) didPressAddToCompareButton:(id)sender;
- (IBAction)didTouchAddToWishListButton:(UIButton *)sender;
- (IBAction)didTouchAddToGiftListButton:(UIButton *)sender;

- (void) loadInventoryStatus;
- (void)  reloadStatus;
- (void)  layoutControls;
- (void)  hideBlockView;
- (void) updatePriceLabel;
@end