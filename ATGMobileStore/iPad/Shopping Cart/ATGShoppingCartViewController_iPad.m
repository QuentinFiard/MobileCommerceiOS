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


#import "ATGShoppingCartViewController_iPad.h"
#import "ATGShoppingCartItemCell.h"
#import "ATGPromotionsTableViewCell.h"
#import "ATGEditedOrderItemTableViewCell.h"
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGPricingAdjustment.h>
#import "ATGRootViewController_iPad.h"
#import "ATGGiftListsViewController.h"

static CGFloat const ATGScreenWidth = 380;
static NSString *const ATGCellIdentifierEditedItemCell = @"ATGEditedItemCell";
static NSString *const ATGCellIdentifierItemCell = @"ATGOrderItemCell";
static NSString *const ATGCellIdentifierPromotionsCell = @"ATGOrderPromotionsCell";
static NSString *const ATGCellIdentifierEmptyCartCell = @"ATGEmptyCartCell";

#pragma mark - ATGShoppingCartViewController_iPad Private Protocol
#pragma mark -

@interface ATGShoppingCartViewController_iPad () <ATGEditedOrderItemTableViewCellDelegate,
    ATGProductManagerDelegate, ATGGiftListManagerDelegate, ATGGiftListsViewControllerDelegate>

#pragma mark - IB Outlets

// Label for the applied store credit.
@property (nonatomic, readwrite, weak) IBOutlet UILabel *storeCreditLabel;
// Label for the order subtotal.
@property (nonatomic, readwrite, weak) IBOutlet UILabel *subtotalLabel;
// Continue button.
@property (nonatomic, weak) IBOutlet UIButton *continueButton;

#pragma mark - Custom Properties

// Spinner displayed while there is no shopping cart loaded.
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *spinner;
// List of commerce items to be displayed.
@property (nonatomic, readwrite, strong) NSArray *commerceItems;
// Set of commerce item indexes which are currently in edit mode.
@property (nonatomic, readwrite, strong) NSMutableSet *indexesForEditingRows;
// Reference to a cell with promotions.
@property (nonatomic, readwrite, weak) ATGPromotionsTableViewCell *promotionCell;
// Reference to a cell which requested to add an item to comparisons/gift/wish list.
@property (nonatomic, readwrite, weak) ATGEditedOrderItemTableViewCell *activeCell;
// need to keep a reference to which commerce item we want added to a giftlist after one is selected by the user
@property (nonatomic, strong) NSString *commerceItemIdToAddToGiftlist;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, assign) BOOL addingToWishlist;

#pragma mark - UI Event Handlers
// This method is called when the user taps cell in shopping cart.
- (void) didSelectCellToPresentPDP:(ATGShoppingCartItemCell *)pCell;
// This method is called when the user makes a swipe-to-edit gesture.
- (void) handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer;
// This method is called when the user taps Done button.
- (void) didTouchDoneButton:(UIBarButtonItem *)sender;
// This method is called when the user taps Edit button.
- (void) didTouchEditButton:(UIBarButtonItem *)sender;
// This method is called when the user taps Checkout button.
- (void) didTouchCheckoutButton:(UIBarButtonItem *)sender;
// This method is called when the user taps 'Continue Shopping' button.
- (void) didTouchContinueButton:(UIBarButtonItem *)sender;

#pragma mark - Private Protocol Declaration

// This method updates currently displayed item cells, removing or adding new cells if needed.
- (void) updateCommerceItemsCellsWithItems:(NSArray *)commerceItems;
// This method updates the applied store credit.
- (void) updateStoreCredit:(NSObject *)pOrder;
// This method updates the order subtotal value.
- (void) updateOrderSubotal:(NSNumber *)pSubtotal;
// This method retrieves promotions from the order specified.
// It also separates promotions by type, if the promotion has come from a coupon, then it would be stored
// into |couponPromotions| output array, otherwise it would be stored into |promotions| output array.
- (void) getCouponPromotions:(__autoreleasing NSArray **)couponPromotions
 simplePromotions           :(__autoreleasing NSArray **)promotions
         forOrder                   :(ATGOrder *)order;

@end

#pragma mark - ATGShoppingCartViewController_iPad Implementation
#pragma mark -

@implementation ATGShoppingCartViewController_iPad

#pragma mark - Synthesized Properties

@synthesize order;
@synthesize currentRequest;
@synthesize priceFormatter;
@synthesize spinner;
@synthesize commerceItems;
@synthesize storeCreditLabel;
@synthesize subtotalLabel;
@synthesize indexesForEditingRows;
@synthesize promotionCell;
@synthesize continueButton;
@synthesize formatter;
@synthesize activeCell;

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGShoppingCartViewController_iPad.ScreenTitle",
                      nil, [NSBundle mainBundle], @"Shopping Cart",
                      @"Title to be displayed on the top of the shopping cart screen on iPad.");
  [self setTitle:title];

  // Do not display subtotal and store credit labels until the shopping cart is loaded.
  [[self subtotalLabel] setHidden:YES];
  [[self storeCreditLabel] setHidden:YES];

  // Add a gesture recognizer to handle swipe-to-edit user gestures.
  UISwipeGestureRecognizer *recognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
  [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
  [[self tableView] addGestureRecognizer:recognizer];

  UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [indicator setHidesWhenStopped:YES];
  CGRect bounds = [[self view] bounds];
  CGPoint center = CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) );
  [indicator setCenter:center];
  [indicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin |
   UIViewAutoresizingFlexibleRightMargin |
   UIViewAutoresizingFlexibleBottomMargin |
   UIViewAutoresizingFlexibleLeftMargin];
  [[self tableView] setBackgroundView:indicator];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  [self setSpinner:indicator];

  self.formatter = [[NSNumberFormatter alloc] init];

  [self.continueButton applyStyleWithName:@"blueButton_iPad"];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }

}
- (void) changeButtonToContinue {
  self.continueButton.hidden = NO;
  [self.continueButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
  [self.continueButton addTarget:self action:@selector(didTouchContinueButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.continueButton setTitle:NSLocalizedStringWithDefaultValue
            (@"ATGShoppingCartViewController_iPad.ContinueButtonTitle", nil, [NSBundle mainBundle], @"Continue Shopping",
  @"Title to be displayed on the 'Continue Shopping' button on empty shopping cart screen.") forState:UIControlStateNormal];
}

- (void) changeButtonToCheckout {
  self.continueButton.hidden = NO;
  [self.continueButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
  [self.continueButton addTarget:self action:@selector(didTouchCheckoutButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.continueButton setTitle:NSLocalizedStringWithDefaultValue
            (@"ATGShoppingCartViewController_iPad.CheckoutButtonTitle", nil, [NSBundle mainBundle], @"Checkout",
  @"Title to be displayed on the checkout button at the very bottom of the shopping cart screen.") forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // load the cart every time the cart is displayed
  [self loadOrder];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
  [[self currentRequest] setDelegate:nil];
  [[self currentRequest] cancelRequest];
  [super viewWillDisappear:pAnimated];
}

- (CGSize) contentSizeForViewInPopover {
  CGFloat height = 0;
  for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:0]; row++) {
    height += [self          tableView:[self tableView]
               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  }
  height += [[self tableView] sectionHeaderHeight];
  height += [[self tableView] sectionFooterHeight];
  height += [[[self tableView] tableFooterView] bounds].size.height;
  return CGSizeMake(ATGScreenWidth, height);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ATGSegueIdCartToShippingAddresses]) {
    ATGShippingAddressesViewController *controller = segue.destinationViewController;
    controller.delegate = self;
    controller.showsSelection = YES;
  }
}

- (void) viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Do not display table contents, if no shopping cart is loaded.
  return [self order] ? 1 : 0;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  NSUInteger count = [self.commerceItems count];
  if (count > 0) {
    return count + 1 + [self errorNumberOfRowsInSection:pSection]; // One additional row: promotions.
  } else {
    return 1;
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  
  NSUInteger count = [self.commerceItems count];

  if (count == 0) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierEmptyCartCell];
    UILabel *label = [cell.contentView.subviews objectAtIndex:0];
    label.text = NSLocalizedStringWithDefaultValue(@"ATGShoppingCartViewController_iPad.EmptyCart", nil, [NSBundle mainBundle], @"You have no items in your shopping cart", @"Message rendered for shopping cart containing no items");
    return cell;
  }

  if ([pIndexPath row] < count) {
    // Is current row in Edit mode?
    if ([[self indexesForEditingRows] containsObject:[NSNumber numberWithInteger:[pIndexPath row]]]) {
      // True, load a separate cell instance for this row.
      ATGEditedOrderItemTableViewCell *cell =
        [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierEditedItemCell];
      [cell setItem:[[self commerceItems] objectAtIndex:[pIndexPath row]]];
      [cell setCurrencyCode:self.order.priceInfo.currencyCode];
      // Reset row's UI to its default state (i.e. hide confirmation button).
      [cell setShowsConfirmButton:NO];
      [cell setDelegate:self];
      cell.accessibilityTraits = UIAccessibilityTraitStaticText | UIAccessibilityTraitButton;
      return cell;
    } else {
      // Current row is not in Edit mode, just display regular commerce item cell.
      ATGShoppingCartItemCell *cell =
        [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierItemCell];
      [cell setItem:[[self commerceItems] objectAtIndex:[pIndexPath row]]];
      [cell setCurrencyCode:self.order.priceInfo.currencyCode];
      cell.accessibilityTraits = UIAccessibilityTraitStaticText | UIAccessibilityTraitButton;
      return cell;
    }
  } else {
    ATGPromotionsTableViewCell *cell = nil;
    // Promotions cell size depends on current screen width and inner cell content height.
    // That's why we'll have to recalculate cell's height once more after it's displayed on the screen.
    // In order to make this happen, we'll have to save a reference to the Promotions cell and reuse
    // the existing cell instance. Otherwise the cell would calculate incorrect height.
    // We're going to trigger table update with empty |beginUpdates|+|endUpdates| statement
    // after the table contents are loaded. This would be done within methods which receive
    // new order instance from commerce manager.
    if ([self promotionCell]) {
      cell = [self promotionCell];
    } else {
      cell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierPromotionsCell];
      [self setPromotionCell:cell];
    }
    NSArray *promotions = nil;
    NSArray *couponPromotions = nil;
    [self getCouponPromotions:&couponPromotions simplePromotions:&promotions forOrder:[self order]];
    [cell setOtherPromotions:promotions];
    [cell setCouponPromotions:couponPromotions];
    [cell setCouponCode:[[self order] couponCode]];
    return cell;
  } 
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  // Screen inner cells know their optimal heights.
  UITableViewCell *cell = [self tableView:pTableView cellForRowAtIndexPath:pIndexPath];
  return [cell sizeThatFits:[[self tableView] bounds].size].height;
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  // Check, if there is an input field within the cell and activate it (if any).
  for (UIView *subview in[[[pTableView cellForRowAtIndexPath:pIndexPath] contentView] subviews]) {
    if ([subview canBecomeFirstResponder]) {
      [subview becomeFirstResponder];
    }
  }
  if ([[pTableView cellForRowAtIndexPath:pIndexPath] isKindOfClass:[ATGShoppingCartItemCell class]]) {
    [self didSelectCellToPresentPDP:(ATGShoppingCartItemCell *)[pTableView cellForRowAtIndexPath:pIndexPath]];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)pTextField {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  // An only input field on the screen is a promo code input. So, just ask commerce manager to claim a coupon.
  [pTextField resignFirstResponder];
  [[self currentRequest] setDelegate:nil];
  [[self currentRequest] cancelRequest];
  [self setPromotionCell:nil];
  [self startActivityIndication:YES];
  BOOL renderCart = [self isMemberOfClass:[ATGShoppingCartViewController_iPad class]];
  [self setCurrentRequest:[[ATGCommerceManager commerceManager] claimCouponWithCode:[pTextField text]
                                                              andRenderShoppingCart:renderCart
                                                                           delegate:self]];
  return YES;
}

#pragma mark - ATGCommerceManagerDelegate

- (void) didErrorGettingShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  [[self spinner] stopAnimating];
}

- (void) didGetShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  [[self spinner] stopAnimating];
  // Call orderDidLoad, this will fill in controller's inner state with proper values.
  ATGOrder *cart = pRequest.requestResults;
  [self orderDidLoad:cart];

  if ([cart.commerceItems count] > 0) {
    // Now we may display the order's subtotal and the applied store credit labels.
    [[self subtotalLabel] setHidden:NO];
    [self updateOrderSubotal:self.order.priceInfo.total];
    [[self storeCreditLabel] setHidden:NO];
    [self updateStoreCredit:[self order]];
    
    // |Edit| button at the right-top corner of the screen.
    UIBarButtonItem *editBarItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                    target:self
                                                    action:@selector(didTouchEditButton:)];
    [[self navigationItem] setRightBarButtonItem:editBarItem animated:YES];

    [self changeButtonToCheckout];
  } else {
    [self changeButtonToContinue];
  }

  [self.tableView reloadData];

  // Don't forget to resize the popover, shopping cart contents may be really long.
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didErrorRemovingItemFromCart:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

- (void) didRemoveItemFromCart:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];

  // And merge new cart contents with existing content.
  NSArray *newCommerceItems = [(ATGOrder *)[pRequest requestResults] acceptableCommerceItems];
  [[self tableView] beginUpdates];
  [self updateCommerceItemsCellsWithItems:newCommerceItems];
  // Update |Promotions| cell only if needed.
  NSArray *oldPromotions = nil, *newPromotions = nil, *oldCouponPromotions = nil, *newCouponPromotions = nil;
  [self getCouponPromotions:&oldCouponPromotions
           simplePromotions:&oldPromotions
                   forOrder:[self order]];
  [self getCouponPromotions:&newCouponPromotions
           simplePromotions:&newPromotions
                   forOrder:[pRequest requestResults]];
  if (![oldCouponPromotions isEqualToArray:newCouponPromotions] ||
      ![oldPromotions isEqualToArray:newPromotions]) {
    [[self tableView] reloadRowsAtIndexPaths:[NSArray
                                              arrayWithObject:[NSIndexPath
                                                               indexPathForRow:[[self commerceItems] count]
                                                                     inSection:0]]
                            withRowAnimation:UITableViewRowAnimationRight];
  }

  // Update inner state with new order contents.
  [self setCommerceItems:newCommerceItems];
  [self setOrder:[pRequest requestResults]];
  [[self tableView] endUpdates];

  // Additional update to recalculate |Promotions| cell height.
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];

  //reload data, then we will have updated cell with message about empty cart.
  if ([newCommerceItems count] == 0) {
    [self updateCart];
    [[self tableView] reloadData];
  }

  // The order subtotal and the store credit should be updated.
  [self updateOrderSubotal:self.order.priceInfo.total];
  [self updateStoreCredit:[self order]];
  
  // And don't forget to resize the popover.
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didErrorClaimingCoupon:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didClaimCoupon:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];

  // Applied coupon can change item's price or add/remove new items to cart.
  // So we need to merge new order items.
  NSArray *newCommerceItems = [(ATGOrder *)[pRequest requestResults] acceptableCommerceItems];
  [[self tableView] beginUpdates];
  [self updateCommerceItemsCellsWithItems:newCommerceItems];
  // Coupon always changes promotions applied, so reload |Promotions| cell.
  [[self tableView] reloadRowsAtIndexPaths:[NSArray
                                            arrayWithObject:[NSIndexPath
                                                             indexPathForRow:[[self commerceItems] count]
                                                                   inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
  // Update controller's inner state.
  [self setOrder:[pRequest requestResults]];
  [self setCommerceItems:newCommerceItems];
  [[self tableView] endUpdates];
  // And recalculate cells height.
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];

  // Update the order's subtotal and the applied store credit amounts
  [self updateOrderSubotal:self.order.priceInfo.total];
  [self updateStoreCredit:[self order]];

  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

#pragma mark - ATGProductManagerDelegate

- (void) didAddProductToComparisons:(ATGProductManagerRequest *)pRequest {
  [self stopActivityIndication];
  [[self activeCell] setShowsConfirmButton:NO];
  DebugLog(@"item added to compare list");
}

- (void) didErrorAddingProductToComparisons:(ATGProductManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

#pragma mark - ATGEditedOrderItemTableViewCellDelegate

- (void) itemCellRequestedMoveToWishlist:(ATGEditedOrderItemTableViewCell *)pCell {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  [self.currentRequest cancelRequest];
  [self startActivityIndication:YES];
  ATGCommerceItem *item = [pCell item];
  self.addingToWishlist = YES;
  self.currentRequest = [[ATGGiftListManager instance] moveToWishlistFromCartCommerceItemWithId:item.commerceItemId quantity:@"1" delegate:self];
  [self setActiveCell:pCell];
}
- (void) giftListManagerDidMoveItemToWishList {
   self.addingToWishlist = NO;
  [self stopActivityIndication];
  [self didTouchDoneButton:nil];
  [self loadOrder];
  [[self activeCell] setShowsConfirmButton:NO];
  
  [self updateCart];
}
- (void) itemCellRequestedMoveToGiftlist:(ATGEditedOrderItemTableViewCell *)pCell {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  [self.currentRequest cancelRequest];
  [self startActivityIndication:YES];
  ATGCommerceItem *item = [pCell item];
  self.commerceItemIdToAddToGiftlist = item.commerceItemId;

  UIStoryboard *giftListStoryboard =
          [UIStoryboard storyboardWithName:@"GiftListStoryboard_iPad" bundle:nil];
  ATGResizingNavigationController *contents =
          [giftListStoryboard instantiateViewControllerWithIdentifier:@"atgSelectGiftListRootNavigationController"];
  self.popover = [[UIPopoverController alloc] initWithContentViewController:contents];
  [contents setPopoverController:self.popover];
  ATGGiftListsViewController *listController = (ATGGiftListsViewController *)[contents topViewController];
  [listController setDelegate:self];
  [self.popover presentPopoverFromRect:pCell.bounds
                                  inView:self.view
                permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                animated:YES];

  [self setActiveCell:pCell];
}

- (BOOL)viewController:(ATGGiftListsViewController *)controller didSelectGiftList:(NSString *)giftListID {
  [self.popover dismissPopoverAnimated:YES];
  self.currentRequest = [[ATGGiftListManager instance] moveToGiftlistFromCartCommerceItemWithId:self.commerceItemIdToAddToGiftlist giftlistId:giftListID quantity:@"1" delegate:self];
  return NO;
}

- (void) giftListManagerDidMoveItemToGiftList {
  [self stopActivityIndication];
  [self didTouchDoneButton:nil];
  [self loadOrder];
  [[self activeCell] setShowsConfirmButton:NO];
  
  [self updateCart];
}

- (void)giftListManagerDidFailWithError:(NSError *)error {
  [self stopActivityIndication];
  [[self activeCell] setShowsConfirmButton:NO];
}

- (void) itemCellRequestedCompare:(ATGEditedOrderItemTableViewCell *)pCell {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  [self.currentRequest cancelRequest];
  [self startActivityIndication:YES];
  ATGCommerceItem *item = [pCell item];
  self.currentRequest = [[ATGProductManager productManager] addProductToComparisons:[item prodId] siteID:[item siteId] delegate:self];
  [self setActiveCell:pCell];
}

- (void) itemCellRequestedRemove:(ATGEditedOrderItemTableViewCell *)pCell {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  ATGCommerceItem *item = [pCell item];
  [self startActivityIndication:YES];
  [self setCurrentRequest:[[ATGCommerceManager commerceManager] removeItemFromCart:[item commerceItemId]
                                                                          delegate:self]];
}

#pragma mark - ATGShoppingCartViewController_iPad Public Protocol Implementation

- (void) loadOrder {
  [[self currentRequest] setDelegate:nil];
  [[self currentRequest] cancelRequest];
  [self setCurrentRequest:[[ATGCommerceManager commerceManager] getShoppingCart:self]];
}

- (void) orderDidLoad:(ATGOrder *)pOrder {
  [self setOrder:pOrder];

  [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
  [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
  [[self priceFormatter] setLocale:[NSLocale currentLocale]];
  [[self priceFormatter] setCurrencyCode:self.order.priceInfo.currencyCode];

  [self setCommerceItems:[pOrder acceptableCommerceItems]];
  [self setIndexesForEditingRows:[[NSMutableSet alloc] init]];
}

- (BOOL) shouldEditCellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Shopping cart screen supports swipe-to-edit gestures.
  return YES;
}

#pragma mark - ATGShoppingCartViewController_iPad Private Protocol Implementation

- (void) didSelectCellToPresentPDP:(ATGShoppingCartItemCell *)pCell {
  ATGCommerceItem *item = [pCell item];
  if ([item isNavigableProduct]) {
    [[ATGRootViewController_iPad rootViewController] displayDetailsForCommerceItem:item];
  }
}

- (void) handleSwipeGesture:(UISwipeGestureRecognizer *)pRecognizer {
  // First, find active cell by gesture start point.
  NSIndexPath *indexPath =
    [[self tableView] indexPathForRowAtPoint:[pRecognizer locationInView:[self tableView]]];
  if (indexPath == nil) {
    // Out of cells swipe, do nothing.
    return;
  }
  indexPath = [self shiftIndexPath:indexPath];
  // Proceed with swipe-to-edit?
  if (![self shouldEditCellForRowAtIndexPath:indexPath]) {
    return;
  }
  // Only commerce item cells are editable, so check index path for validity.
  // Do not re-edit rows which are in Edit mode already.
  if ([indexPath row] < [[self commerceItems] count] &&
      ![[self indexesForEditingRows] containsObject:[NSNumber numberWithInteger:[indexPath row]]]) {
    [[self indexesForEditingRows] addObject:[NSNumber numberWithInteger:[indexPath row]]];
    [[self tableView] reloadRowsAtIndexPaths:@[[self convertIndexPath:indexPath]]
                            withRowAnimation:UITableViewRowAnimationLeft];
    // We're entering an Edit mode, so replace |Edit| button with |Done|.
    UIBarButtonItem *doneBarItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                    target:self
                                                    action:@selector(didTouchDoneButton:)];
    [[self navigationItem] setRightBarButtonItem:doneBarItem animated:YES];
    // Cells in Edit mode may have different height, so update popover.
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
  [self tableView:[self tableView] setErrors:nil inSection:0];
}

- (void) didTouchDoneButton:(UIBarButtonItem *)pSender {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  NSMutableArray *indexPathesForReload = [[NSMutableArray alloc] init];
  for (NSNumber *index in [self indexesForEditingRows]) {
    [indexPathesForReload addObject:[self convertIndexPath:[NSIndexPath indexPathForRow:[index integerValue]
                                                                              inSection:0]]];
  }
  // Clear indexes for editing rows and reload all commerce item cells,
  // this will change their state to default.
  [self setIndexesForEditingRows:[[NSMutableSet alloc] init]];
  [[self tableView] reloadRowsAtIndexPaths:indexPathesForReload
                          withRowAnimation:UITableViewRowAnimationFade];
  // Now we've left the Edit mode, so replace |Done| button with |Edit|.
  UIBarButtonItem *editBarItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                  target:self
                                                  action:@selector(didTouchEditButton:)];
  [[self navigationItem] setRightBarButtonItem:editBarItem animated:YES];

  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didTouchEditButton:(UIBarButtonItem *)pSender {
  [self tableView:[self tableView] setErrors:nil inSection:0];
  UIBarButtonItem *doneBarItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(didTouchDoneButton:)];
  [[self navigationItem] setRightBarButtonItem:doneBarItem animated:YES];

  NSMutableArray *indexPathesForReload = [[NSMutableArray alloc] init];
  [self setIndexesForEditingRows:[[NSMutableSet alloc] init]];
  for (NSInteger row = 0; row < [[self commerceItems] count]; row++) {
    [[self indexesForEditingRows] addObject:[NSNumber numberWithInteger:row]];
    [indexPathesForReload addObject:[self convertIndexPath:[NSIndexPath indexPathForRow:row inSection:0]]];
  }
  [[self tableView] reloadRowsAtIndexPaths:indexPathesForReload
                          withRowAnimation:UITableViewRowAnimationLeft];

  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didTouchCheckoutButton:(UIBarButtonItem *)pSender {
  [self startActivityIndication:YES];
  self.currentRequest = [[ATGExternalProfileManager profileManager] getSecurityStatus:self];
}

- (void) didTouchContinueButton:(UIBarButtonItem *)sender {
  UIPopoverController * popover =
      [(ATGResizingNavigationController *)[self navigationController] popoverController];
  id<UIPopoverControllerDelegate> delegate = [popover delegate];
  [popover dismissPopoverAnimated:YES];
  if ([delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
    [delegate popoverControllerDidDismissPopover:popover];
  }
}

- (void) updateCommerceItemsCellsWithItems:(NSArray *)pCommerceItems {
  NSArray *oldCommerceItems = [self commerceItems];
  UITableView *tableView = [self tableView];

  // First, find cells which are to be removed.
  for (NSInteger row = 0; row < [oldCommerceItems count]; row++) {
    ATGCommerceItem *oldItem = [oldCommerceItems objectAtIndex:row];
    // Is there a commerce item represented by an existing cell?
    if ([pCommerceItems indexOfObjectPassingTest: ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
           ATGCommerceItem *item = (ATGCommerceItem *)pObject;
           if ([[item commerceItemId] isEqualToString:[oldItem commerceItemId]]) {
             *pStop = YES;
             return YES;
           }
           return NO;
         }
        ] == NSNotFound) {
      // No, then just remove the cell from table view.
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row
                                                                                    inSection:0]]
                       withRowAnimation:UITableViewRowAnimationLeft];
      // We should also update indexesForEditedRows property to hold actual data.
      NSMutableSet *newIndexes = [[NSMutableSet alloc] init];
      [[self indexesForEditingRows] enumerateObjectsUsingBlock: ^(id pObject, BOOL * pStop) {
         NSNumber *index = (NSNumber *)pObject;
         if ([index integerValue] < row) {
           // Edited row is located before the row to be removed: no updates needed, just copy the index.
           [newIndexes addObject:index];
         } else if ([index integerValue] > row) {
           // Edited row is located after the row to be removed: shift edited row by 1 to correspond to its new
           // TableView position.
           [newIndexes addObject:[NSNumber numberWithInteger:[index integerValue] - 1]];
         }
         // Edited row is a row to be removed, just do not copy it to the new edited indices.
       }
      ];
      [self setIndexesForEditingRows:newIndexes];
    }
  }
  // Next, find cells which are to be added or updated.
  // All new items should be added at the very end of the list, as server-side adds them to the end.
  NSInteger topRow = [oldCommerceItems count];
  for (NSInteger index = 0; index < [pCommerceItems count]; index++) {
    ATGCommerceItem *newItem = [pCommerceItems objectAtIndex:index];
    // Is there a cell representing the commerce item?
    NSInteger oldItemRow =
      [oldCommerceItems indexOfObjectPassingTest: ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
         ATGCommerceItem *item = (ATGCommerceItem *)pObject;
         if ([[item commerceItemId] isEqualToString:[newItem commerceItemId]]) {
           *pStop = YES;
           return YES;
         }
         return NO;
       }
      ];
    if (oldItemRow == NSNotFound) {
      // No such cell, then we'll have to insert a new one.
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:topRow++
                                                                                    inSection:0]]
                       withRowAnimation:UITableViewRowAnimationRight];
    } else {
      // There is a cell representing the item.
      ATGCommerceItem *oldItem = [oldCommerceItems objectAtIndex:oldItemRow];
      // Is item changed?
      if (![oldItem isEqual:newItem]) {
        // Yes, then update it.
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:oldItemRow
                                                                                      inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
      }
    }
  }
  
  if ([[self indexesForEditingRows] count] == 0) {
    [self didTouchDoneButton:nil];
  }
}

- (void) updateOrderSubotal:(NSNumber *)pSubtotal {
  // Just animate a transition from one price to another.
  [UIView transitionWithView:[self subtotalLabel]
                    duration:.3
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations: ^{
     NSString *subtotalFormat = NSLocalizedStringWithDefaultValue
                                (@"ATGShoppingCartViewController_iPad.SubtotalLabelFormat",
                                 nil, [NSBundle mainBundle], @"Subtotal: %@",
                                 @"String format to be used when constructing an order subtotal label."
                                 @"This label is displayed at the very bottom of the shopping cart screen."
                                 @"Its parameter is an order subtotal value.");
     [[self subtotalLabel] setText:[NSString stringWithFormat:subtotalFormat,
                                    [[self priceFormatter] stringFromNumber:pSubtotal]]];
   }
                  completion: ^(BOOL finished) {
     // Nothing to do.
   }
  ];
}

- (void) updateStoreCredit:(NSObject *)order {
  NSString *storeCreditFormat = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController_iPad.StoreCreditLabel", nil, [NSBundle mainBundle],
     @"Store Credit: -%@",
     @"The formatted store credit label."
     @"The parameter represents the applied store credit amount.");
  
  // Calculate the applied store credit amount.
  NSDecimalNumber *orderTotal = self.order.priceInfo.total;
  NSDecimalNumber *availableStoreCredit = self.order.storeCreditsAvailable ? self.order.storeCreditsAvailable : [NSDecimalNumber zero];
  NSDecimalNumber *appliedStoreCredit;
  if ([orderTotal compare:availableStoreCredit] == NSOrderedAscending)
    appliedStoreCredit = [orderTotal copy];
  else
    appliedStoreCredit = [availableStoreCredit copy];
  
  if ([appliedStoreCredit compare:[NSDecimalNumber zero]] == NSOrderedSame) {
    [[self storeCreditLabel] setHidden:YES];
  } else {
    [[self storeCreditLabel] setText:[NSString stringWithFormat:storeCreditFormat,
                                [[self priceFormatter] stringFromNumber:appliedStoreCredit]]];
  }
}

- (void) getCouponPromotions:(__autoreleasing NSArray **)pCouponPromotions
            simplePromotions:(__autoreleasing NSArray **)pPromotions
                    forOrder:(ATGOrder *)pOrder {
  // Resulting output arrays.
  NSMutableArray *couponPromotions = [[NSMutableArray alloc] init];
  NSMutableArray *promotions = [[NSMutableArray alloc] init];
  // Declare a block which processes a dictionary with promotion data and adds the promotion name
  // to the proper resulting collection.
  void ( ^processPromotionData)(ATGPricingAdjustment *) = ^(ATGPricingAdjustment * pPromotion) {
    // Is there a coupon code specified?
    if ([pPromotion fromCoupon] &&
        [promotions indexOfObject:pPromotion] == NSNotFound) {
      // Yes, it's a coupon-specific promotion.
      [promotions addObject:pPromotion];
    } else if ([couponPromotions indexOfObject:pPromotion] == NSNotFound) {
      // No, it's a generic promotion.
      [couponPromotions addObject:pPromotion];
    }
  };
  // Collect promotions from commerce items.
  for (ATGCommerceItem *commerceItem in[pOrder commerceItems]) {
    for (ATGPricingAdjustment *promotion in[commerceItem appliedPromotions]) {
      processPromotionData (promotion);
    }
  }
  // And get promotions from order itself.
  for (ATGPricingAdjustment *promotion in[pOrder appliedPromotions]) {
    processPromotionData (promotion);
  }
  *pCouponPromotions = [couponPromotions copy];
  *pPromotions = [promotions copy];
}

- (void) updateCart {
  //Additional call to remove remove index here was causing a crash.
  //Not sure what motivated the call to remove index here (it was calling for self.commerceItems.count + 1 to be removed.
  //I am pretty sure the updateCommerceItemsCellsWithItems: method is handling the removal sufficiently.
  
  // Do not display subtotal and store credit labels.
  [[self subtotalLabel] setHidden:YES];
  [[self storeCreditLabel] setHidden:YES];
  
  // If there are no commerce items, Checkout button should not be displayed.
  [self changeButtonToContinue];
  // Edit/Done buttons should not be displayed too.
  [[self navigationItem] setRightBarButtonItems:nil animated:YES];
}

#pragma mark - ATGProfileManagerDelegate

- (void) didGetSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  if ([(NSNumber *)[pRequestResults requestResults]
       compare:[NSNumber numberWithInteger:3]] == NSOrderedDescending) {
    // The user is explicitly logged in. Display addresses to begin checkout.
    [self performSegueWithIdentifier:ATGSegueIdCartToShippingAddresses sender:self];
  } else {
    // The user is not logged in yet.
    [self presentLoginViewControllerAnimated:YES allowSkipLogin:YES];
  }
}

- (void) didErrorGettingSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

#pragma mark - ATGLoginViewControllerDelegate

- (void) didLogin {
  [super didLogin];
  if (self.addingToWishlist) {
    [self itemCellRequestedMoveToWishlist:self.activeCell];
  } else {
    [self performSegueWithIdentifier:ATGSegueIdCartToShippingAddresses sender:self];
  }
}

- (void) didSkipLogin {
  [super didSkipLogin];
  [self performSegueWithIdentifier:ATGSegueIdCartToShippingAddresses sender:self];
}

@end

#pragma mark - ATGOrder (ATGShoppingCart) Category Implementation
#pragma mark -

@implementation ATGOrder (ATGShoppingCart)

- (NSArray *) acceptableCommerceItems {
  // Shopping cart screen can handle with non-gift-wrap items only.
  NSPredicate *predicate = [NSPredicate
                            predicateWithBlock: ^BOOL (id pEvaluatedObject, NSDictionary * pBindings) {
                              return ![(ATGCommerceItem *) pEvaluatedObject isGiftWrap];
                            }
                           ];
  return [[self commerceItems] filteredArrayUsingPredicate:predicate];
}

@end
