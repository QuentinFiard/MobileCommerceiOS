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

#import "ATGBaseProductDetailsPage_iPad.h"
#import "ATGSkuInventory.h"
#import <ATGUIElements/ATGImageView.h>
#import "ATGEmailMeViewController_iPad.h"
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGGiftListManagerRequest.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGMobileClient/ATGContactInfo.h>
#import "ATGCommerceItem.h"
#import "ATGPickerTableViewController.h"

static NSString *const ATGSelectGiftListConrollerID = @"atgSelectGiftListRootNavigationController";

#pragma mark - ATGProductPageInnerView_iPad Definition
#pragma mark -

@interface ATGProductPageInnerView_iPad : UIView

#pragma mark - Custom Properties

@property (nonatomic, readwrite, weak) ATGBaseProductDetailsPage_iPad *parentController;

@end

@interface ATGBaseProductDetailsPage_iPad ()
{
  BOOL fullSizePhoto;
  
  ATGSkuInventoryLevel mLevel;
}
@end

#pragma mark - ATGProductDetailsPage_iPad implementation
#pragma mark -
@implementation ATGBaseProductDetailsPage_iPad
#pragma mark - Synthesized Properties
@synthesize compareButton;
@synthesize activityIndicator, productTitle, productStatus, actionButton, wishListButton, giftListButton;
@synthesize productImage, productDescription, presenter;
@synthesize productRequest, product, currencyFormatter, sku, inventory, quantity, commerceRequest, commerceItem;

#pragma mark - Custom getters/setters

- (void)setPopover:(UIPopoverController *)popover {
  if(_popover) {
    [_popover dismissPopoverAnimated:YES];
  }
  _popover = popover;
}

#pragma mark - Public interface

- (id) initWithProduct:(ATGProduct *)pProduct presenter:(ATGProductPageViewController *)pPresenter {
  return [self initWithProduct:pProduct commerceItem:nil presenter:pPresenter];
}

- (id) initWithProduct:(ATGProduct *)pProduct commerceItem:(ATGCommerceItem *)pCommerceItem presenter:(ATGProductPageViewController *)pPresenter {
  NSBundle *bundle = [NSBundle atgResourceBundle];

  //Load certain view layout regarding to device orientation
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if ( UIInterfaceOrientationIsLandscape(orientation) ) {
    self = [super initWithNibName:@"ATGProductDetailsPage_iPad" bundle:bundle];
  } else {
    self = [super initWithNibName:@"ATGProductDetailsPage_iPad_Portrait" bundle:bundle];
  }
  if (self) {
    self.product = pProduct;
    if (pCommerceItem) {
      self.commerceItem = pCommerceItem;
      self.quantity = [NSString stringWithFormat:@"%@", pCommerceItem.qty];
      self.shippingGroupId = pCommerceItem.shippingGroup.shippingAddress.nickname;
      self.locationId = pCommerceItem.shippingGroup.locationId;
      self.assumeCommerceItemsAreInCart = YES;

      // if commerceitemsku was just a regular sku we wouldn't have to do this
      for (ATGSku *childSku in self.product.childSKUs) {
        if ([childSku.repositoryId isEqualToString:self.commerceItem.sku.repositoryId]) {
          self.sku = childSku;
          break;
        }
      }
    } else {
      self.quantity = @"1";
    }
    self.presenter = pPresenter;

    self.currencyFormatter = [[NSNumberFormatter alloc] init];
    [self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [self.currencyFormatter setCurrencyCode:self.product.currencyCode];
    if ([self.product.currencyCode isEqualToString:@"USD"]) {
      [self.currencyFormatter setCurrencyDecimalSeparator:@"."];
    } else if ([self.product.currencyCode isEqualToString:@"EUR"]) {
      [self.currencyFormatter setCurrencyDecimalSeparator:@","];
    }

    if (self.productRequest == nil) {
      //loading inventory level for product
      self.productRequest = [[self productManager] getProductInventoryLevel:self.product.repositoryId delegate:self];
    }
  }
  return self;
}

#pragma mark - manager retrieval methods

- (ATGProductManager*) productManager {
  return [ATGProductManager productManager];
}

- (ATGCommerceManager*) commerceManager {
  return [ATGCommerceManager commerceManager];
}

- (void)viewWillAppear:(BOOL)animated {
  [self loadProductInfo];

  [self updatePriceLabel];

  // setup/layout sku pickers, quantity picker, 'add to cart'/'view cart' button
  [self layoutControls];

  [self applyButtonAccessibility];

  [self reloadStatus];

  [(ATGProductPageInnerView_iPad *)[self view] setParentController:self];
}

- (void) loadProductInfo {
  if (self.product.longDescription != nil) {
    self.productDescription.text = self.product.longDescription;
  } else {
    self.productDescription.text = self.product.productDescription;
  }

  self.productTitle.text = self.product.displayName;
  
  if (self.product.largeImageUrl) {
    self.productImage.imageURL = [ATGRestManager getAbsoluteImageString:self.product.largeImageUrl];
  }
  
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProductImage:)];
  //recognizer.numberOfTapsRequired = 2;
  [self.productImage addGestureRecognizer:recognizer];

  NSString *label = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Label.ProductImage",
  nil, [NSBundle mainBundle], @"ATGRenderableProduct",
  @"Accessibility label to be used by the small product image on the ATGRenderableProduct Details Page");
  self.productImage.accessibilityLabel = label;
}

- (void) applyButtonAccessibility {
  NSString *label = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Label.GiftListButton",
  nil, [NSBundle mainBundle], @"Gift list",
  @"Accessibility label to be used by the Gift List button on the ATGRenderableProduct Details Page");
  [[self giftListButton] setAccessibilityLabel:label];
  NSString *hint = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Hint.GiftListButton",
  nil, [NSBundle mainBundle], @"Double tap to add current product to your gift list.",
  @"Accessibility hint to be used by the Gift List button on the ATGRenderableProduct Details Page");
  [[self giftListButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Label.WishListButton",
  nil, [NSBundle mainBundle], @"Wish list",
  @"Accessibility label to be used by the Wish List button on the ATGRenderableProduct Details Page");
  [[self wishListButton] setAccessibilityLabel:label];
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Hint.WishListButton",
  nil, [NSBundle mainBundle], @"Double tap to add current product to your wish list.",
  @"Accessibility hint to be used by the Wish List button on the ATGRenderableProduct Details Page");
  [[self wishListButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Label.CompareButton",
  nil, [NSBundle mainBundle], @"Compare",
  @"Accessibility label to be used by the Compare button on the ATGRenderableProduct Details Page");
  [[self compareButton] setAccessibilityLabel:label];
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Hint.CompareButton",
  nil, [NSBundle mainBundle], @"Double tap to add current product to your comparisons list.",
  @"Accessibility hint to be used by the Compare button on the ATGRenderableProduct Details Page");
  [[self compareButton] setAccessibilityHint:hint];
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGProductPage_iPad.Accessibility.Hint.ProductImage",
  nil, [NSBundle mainBundle], @"Triple tap to display full-size product image.",
  @"Accessibility hint to be used by small product image on the ATGRenderableProduct Details Page");
  [[self productImage] setAccessibilityHint:hint];

  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)pToInterfaceOrientation duration:(NSTimeInterval)duration {
  //on device rotation reload interface layout and update it.
  [self hideBlockView];
  if ( UIInterfaceOrientationIsPortrait(pToInterfaceOrientation) ) {
    [[NSBundle atgResourceBundle] loadNibNamed:@"ATGProductDetailsPage_iPad_Portrait" owner:self options:nil];
  } else if ( UIInterfaceOrientationIsLandscape(pToInterfaceOrientation) ) {
    [[NSBundle atgResourceBundle] loadNibNamed:@"ATGProductDetailsPage_iPad" owner:self options:nil];
  }
}

#pragma mark - Actions implementation
- (IBAction) didPressAddToCompareButton:(id)pSender {
  self.productRequest = [[self productManager] addProductToComparisons:self.product.repositoryId siteID:self.product.siteId delegate:self];
}

- (IBAction)didTouchAddToWishListButton:(UIButton *)pSender {
  [[self popover] dismissPopoverAnimated:YES];
  if (self.sku && self.quantity) {
    [[ATGGiftListManager instance] addProductToWishList:self.product.repositoryId
                                                    sku:self.sku.repositoryId
                                               quantity:self.quantity
                                               delegate:self];
  } else {
    NSString *message = NSLocalizedStringWithDefaultValue
        (@"ATGProductPage_iPad.ErrorMessage.WishListNoSkuSelected",
    nil, [NSBundle mainBundle], @"Select SKU to be added to your wish list, please.",
    @"Error message to be displayed if trying to add product to wish list with no SKU selected.");
    [self alertWithTitleOrNil:nil withMessageOrNil:message];
  }
}

- (IBAction)didTouchAddToGiftListButton:(UIButton *)pSender {
  // Let subclasses decide how to proceed
}

- (void) hideBlockView {
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
}

- (void) didTapProductImage:(UITapGestureRecognizer *)pSender;
{
  if (pSender.state == UIGestureRecognizerStateEnded) {
    if ([self.presenter respondsToSelector:@selector(presentFullImage)]) {
      [self.presenter performSelector:@selector(presentFullImage)];
    }
  }
}

#pragma mark - ATGSkuPickerDelegate
- (void) didSelectSku:(ATGSku *)pSKU {
  self.sku = pSKU;
  [self reloadStatus];
}

#pragma mark - ATGPopoverPickerDelegate
- (void) didSelectValue:(NSString *) pString forType:(NSString *) pType {
  if ([pType isEqualToString:@"quantity"]) {
    self.quantity = pString;
    // if the item is in the cart, we need to update it after changing quantity
    if (self.commerceItem) {
      [self loadActionButtonState];
    }
  }
}

#pragma mark - Private methods

- (void)reloadStatus {
  if (self.sku) {
    [self loadInventoryStatus];
    [self updatePriceLabel];
  }
  [self loadActionButtonState];
}



- (void) loadInventoryStatus {
  if (self.sku && self.inventory) {
    ATGSkuInventory *level = [self.inventory.skuInventory objectForKey:self.sku.repositoryId];
    mLevel = level.availability;
    switch (level.availability) {
      case ATGSkuInventoryLevelBackorderable:
        self.productStatus.text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Backordered", nil, [NSBundle mainBundle], @"Backordered", @"Backordered status of product");
        break;
      case ATGSkuInventoryLevelPreorderable:
        self.productStatus.text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.AvailableSoon", nil, [NSBundle mainBundle], @"Available Soon", @"ATGRenderableProduct will be available soon");
        break;
      case ATGSkuInventoryLevelUnavailable:
        self.productStatus.text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Unavailable", nil, [NSBundle mainBundle], @"Out of Stock", @"ATGRenderableProduct is out of stock");
        break;
      case ATGSkuInventoryLevelAvailable:
        self.productStatus.text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Available", nil, [NSBundle mainBundle], @"In Stock", @"Status text on product page when product available in stock");
      default:
        break;
    }
    self.productStatus.hidden = NO;
  } else {
    self.productStatus.hidden = YES;
  }
}

#pragma mark - Action button states

- (void) setActionButtonEmailMe {
  [self.actionButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.actionButton setTitle:NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.EmailMe", nil, [NSBundle mainBundle], @"Email Me", @"Email Me Button Title") forState:UIControlStateNormal];
  [self.actionButton setAccessibilityHint:NSLocalizedStringWithDefaultValue
   (@"ATGProductPage_iPad.Accessibility.Hint.EmailMeButton",
  nil, [NSBundle mainBundle], @"Double tap to register for email notification.",
  @"Accessibility hint to be used by the Email Me button on the ATGRenderableProduct Details Page")];
  [self.actionButton addTarget:self action:@selector(didPressEmailMeButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void) setActionButtonAddToCart {
  [self.actionButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.actionButton setTitle:NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.addBtnTitle", nil, [NSBundle mainBundle], @"Add to Cart", @"Add to Cart Button Title") forState:UIControlStateNormal];
  [self.actionButton setAccessibilityHint:NSLocalizedStringWithDefaultValue
   (@"ATGProductPage_iPad.Accessibility.Hint.AddToCartButton",
  nil, [NSBundle mainBundle], @"Double tap to add selected product to your shopping cart.",
  @"Accessibility hint to be used by the AddToCart button on the ATGRenderableProduct Details Page")];
  [self.actionButton addTarget:self action:@selector(didPressAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) setActionButtonUpdateItem {
  [self.actionButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.actionButton setTitle:NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.UpdateCartBtn", nil, [NSBundle mainBundle], @"Update Cart", @"Update Cart Button Title") forState:UIControlStateNormal];
  [self.actionButton setAccessibilityHint:NSLocalizedStringWithDefaultValue
   (@"ATGProductPage_iPad.Accessibility.Hint.UpdateCartButton",
  nil, [NSBundle mainBundle], @"Double tap to update your shopping cart.",
  @"Accessibility hint to be used by the Update Cart button on the ATGRenderableProduct Details Page")];
  [self.actionButton addTarget:self action:@selector(didPressUpdateItemButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void) setActionButtonPreorder {
  [self.actionButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.actionButton setTitle:NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Preorder", nil, [NSBundle mainBundle], @"Preorder", @"Preorder Button Title") forState:UIControlStateNormal];
  [self.actionButton setAccessibilityHint:NSLocalizedStringWithDefaultValue
   (@"ATGProductPage_iPad.Accessibility.Hint.PreorderButton",
  nil, [NSBundle mainBundle], @"Double tap to pre-order selected product.",
  @"Accessibility hint to be used by the Preorder button on the ATGRenderableProduct Details Page")];
  [self.actionButton addTarget:self action:@selector(didPressAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) loadActionButtonState {
  if (mLevel == ATGSkuInventoryLevelUnavailable) {
    [self setActionButtonEmailMe];
  } else if (self.commerceItem && self.assumeCommerceItemsAreInCart) {
    // a different SKU was selected, need to update the cart with the new SKU
    [self setActionButtonUpdateItem];
  } else {
    // the item is not in our cart
    if (self.inventory == nil || mLevel == ATGSkuInventoryLevelBackorderable || mLevel == ATGSkuInventoryLevelAvailable) {
      [self setActionButtonAddToCart];
    } else if (mLevel == ATGSkuInventoryLevelPreorderable) {
      [self setActionButtonPreorder];
    }
  }

  self.actionButton.enabled = self.sku ? YES : NO;

  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

#pragma mark - Action button actions
- (void) didPressAddToCartButton:(id)pSender  {
  NSString *btnTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.AddingCartBtn", nil, [NSBundle mainBundle], @"Adding...", @"Adding Cart Button Title");
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
  [self.actionButton setTitle:btnTitle forState:UIControlStateNormal];
  [self.actionButton setEnabled:NO];
  [self.activityIndicator startAnimating];

  [self.commerceRequest cancelRequest];
  self.commerceRequest = [[self commerceManager] addItemToShoppingCartWithSkuId:self.sku.repositoryId productId:self.product.repositoryId quantity:self.quantity shippingGroupId:self.shippingGroupId locationId:self.locationId delegate:self];
}

- (void) didPressUpdateItemButton {
  [self.activityIndicator startAnimating];
  [self.actionButton setEnabled:NO];
  [self.commerceRequest cancelRequest];
  self.commerceRequest = [[self commerceManager] changeSkuOfOldCommerceId:self.commerceItem.commerceItemId
                                                                          withProductId:[self.product repositoryId]
                                                                                toSkuId:self.sku.repositoryId
                                                                           withQuantity:self.quantity
                                                                       shippingGroupId:self.shippingGroupId
                                                                             locationId:self.locationId
                                                                               delegate:self];
}

- (void) didPressEmailMeButton {
  ATGEmailMeViewController_iPad *emailMe =
    [[UIStoryboard storyboardWithName:@"MobileCommerce_iPad" bundle:nil]
      instantiateViewControllerWithIdentifier:@"ATGEmailMeViewController"];
  [emailMe setProductID:self.product.repositoryId];
  [emailMe setSkuID:self.sku.repositoryId];
  UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:emailMe]];
  [emailMe setPopover:popover];
  [popover presentPopoverFromRect:[self.view convertRect:self.actionButton.bounds
                                                fromView:self.actionButton]
                           inView:self.view
         permittedArrowDirections:UIPopoverArrowDirectionAny
                         animated:YES];
  [self setPopover:popover];
}

#pragma mark - Price label

- (void) updatePriceLabel {
  self.priceLabel.adjustsFontSizeToFitWidth = YES;
  UIFont *currentPriceFont = [UIFont fontWithName:@"Helvetica-Bold" size:28];
  UIColor *color = [UIColor colorWithRed:.223 green:.333 blue:.529 alpha:1];
  NSDictionary *wasPriceAttr = @{ NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle) };
  NSDictionary *currentPriceAttr = @{ NSFontAttributeName: currentPriceFont, NSForegroundColorAttributeName:color};
  NSAttributedString *wasPriceRangeIndicator = [[NSAttributedString alloc] initWithString:@" - " attributes:wasPriceAttr];
  NSAttributedString *currentPriceRangeIndicator = [[NSAttributedString alloc] initWithString:@" - " attributes:currentPriceAttr];

  NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];

  if (self.sku) {
    // we have selected a sku, so we don't have any price ranges
    if (self.sku.salePrice && [self.sku.listPrice compare:self.sku.salePrice] != NSOrderedSame) {
      // 'was price' exists
      self.priceLabel.numberOfLines = 2;
      NSMutableAttributedString *wasPrice = [[NSMutableAttributedString alloc] initWithString:[[self.currencyFormatter stringFromNumber:self.sku.listPrice] stringByAppendingString:@"\n"] attributes:wasPriceAttr];
      NSAttributedString *currentPrice = [[NSAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.sku.salePrice]  attributes:currentPriceAttr];

      [wasPrice appendAttributedString:currentPrice];
      self.priceLabel.attributedText = wasPrice;
    } else {
      // single price
      self.priceLabel.numberOfLines = 1;
      NSAttributedString *currentPrice = [[NSAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.sku.listPrice] attributes:currentPriceAttr];
      self.priceLabel.attributedText = currentPrice;
    }
  } else {
    NSMutableAttributedString *price = [NSMutableAttributedString new];
    // check if the list prices are different from the sale prices
    if ([self.product.lowestListPrice compare:self.product.lowestSalePrice] != NSOrderedSame || [self.product.highestListPrice compare:self.product.highestSalePrice] != NSOrderedSame) {
      // product is on sale -- display 'was price'
      self.priceLabel.numberOfLines = 2;
      NSAttributedString *wasPrice = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.product.lowestListPrice] attributes:wasPriceAttr];
      [price appendAttributedString:wasPrice];

      if ([self.product.lowestListPrice compare:self.product.highestListPrice] != NSOrderedSame) {
        // 'was price' is a range
        NSAttributedString *wasPrice2 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.product.highestListPrice] attributes:wasPriceAttr];
        [price appendAttributedString:wasPriceRangeIndicator];
        [price appendAttributedString:wasPrice2];
      }
      [price appendAttributedString:newLine];
    }

    // check if there is a single price for a product, or a range of prices
    if ([self.product.lowestSalePrice compare:self.product.highestSalePrice] != NSOrderedSame) {
      // price range
      NSAttributedString *price1 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.product.lowestSalePrice] attributes:currentPriceAttr];
      [price appendAttributedString:price1];
      [price appendAttributedString:currentPriceRangeIndicator];
    }
    if (self.product.highestSalePrice) {
      NSAttributedString *price2 = [[NSMutableAttributedString alloc] initWithString:[self.currencyFormatter stringFromNumber:self.product.highestSalePrice] attributes:currentPriceAttr];
      [price appendAttributedString:price2];
    }
    self.priceLabel.attributedText = price;
  }
}

#pragma mark - Layout views

- (void) moveView:(UIView *)pView2 after:(UIView *)pView1 padding:(int)pPadding {
  CGRect frame = pView2.frame;
  frame.origin.y = pView1.frame.origin.y + pView1.frame.size.height + pPadding;
  pView2.frame = frame;
}

- (void) layoutControls {
  // initialize the sku pickers. it'll set its height based on the number of pickers needed.
  CGRect skuPickersFrame = CGRectMake(self.actionsPane.bounds.origin.x + 22, self.productStatus.frame.origin.y + self.productStatus.frame.size.height, 238, 0);

  self.skuPickers = [[ATGSkuPickersView alloc] initWithFrame:skuPickersFrame product:self.product sku:self.sku delegate:self];
  [self.actionsPane addSubview:self.skuPickers];

  // setup the quantity picker and move it after the sku pickers if there are any
  NSArray *quantityArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
  ATGPickerTableViewController *pickerTableView = [[ATGPickerTableViewController alloc] initWithType:@"quantity" dataArray:quantityArray delegate:self.quantityPicker];
  [self.quantityPicker setupWithPickerViewController:pickerTableView type:@"quantity" singleValue:nil delegate:self];
  [self.quantityPicker didSelectValue:self.quantity forType:@"quantity"];

  if (self.skuPickers.frame.size.height > 0) {
    [self moveView:self.quantityPicker after:self.skuPickers padding:7];
  }
    
  // setup the 'add to cart'/'view cart' button
  [self moveView:self.actionButton after:self.quantityPicker padding:20];
  [self.actionButton applyStyleWithName:@"blueButton_iPad"];
}

#pragma mark - Product manager delegate

- (void) didGetInventoryLevel:(ATGProductManagerRequest *)pRequest {
  self.inventory = pRequest.productInventory;

  [self reloadStatus];
  DebugLog(@"Got inventory level");
}

- (void) didErrorGettingInventoryLevel:(ATGProductManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
}

- (void) didAddProductToComparisons:(ATGProductManagerRequest *)pRequest {
  //apply animation to notify user about adding product to compare list
  [UIView beginAnimations:@"AddToCompare" context:nil];
  [UIView setAnimationDuration:0.5];
  self.compareButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
  self.compareButton.transform = CGAffineTransformIdentity;
  [UIView commitAnimations];
}

- (void) didErrorAddingProductToComparisons:(ATGProductManagerRequest *)request {
  [self alertWithTitleOrNil:nil withMessageOrNil:[request.error localizedDescription]];
}

#pragma mark - Commerce manager delegates

- (void) didAddItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  DebugLog(@"Item added to cart");
  [self loadActionButtonState];
  [self.actionButton setEnabled:YES];
  [self.activityIndicator stopAnimating];
}

- (void) didErrorAddingItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  [self setActionButtonAddToCart];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
  [self.actionButton setEnabled:YES];
  [self.activityIndicator stopAnimating];
}

- (void) didChangeSku:(ATGCommerceManagerRequest *)pRequest {
  [self.presenter didPressCloseButton];
}

#pragma mark - ATGEmailMeDelegate

- (void) didErrorRegisteringBackInStockNotification:(NSError *)pError {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

@end

#pragma mark -
#pragma mark -

@implementation ATGProductPageInnerView_iPad

#pragma mark - Synthesized Properties

@synthesize parentController;

@end
