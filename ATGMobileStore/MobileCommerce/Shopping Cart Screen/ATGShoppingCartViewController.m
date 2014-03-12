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

#import "ATGShoppingCartViewController.h"
#import "ATGCartTableViewCell.h"
#import "ATGExpandableTableView.h"
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGProduct.h>
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileClient/ATGProductPage.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import "ATGOrderTotalTableViewCell.h"
#import "ATGShippingAddressesViewController.h"
#import <ATGUIElements/ATGButton.h>
#import <ATGMobileClient/ATGGridCollectionView.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

// UI-related constants.
static const CGFloat ATGInsetBounds = 5;
static const CGFloat ATGDelimiterWidth = 20;
static const CGFloat ATGPoputInsetBounds = 12;
static const CGFloat ATGPopupElementHeight = 44;
static NSString *const ATGDefaultImageURL =
@"/crsdocroot/content/images/products/thumb/MissingProduct_thumb.jpg";
static NSString *const ATGCartToProductSegue = @"cartToProduct";
static NSString *const ATGSliderImageHeight = @"ATG_SLIDER_IMAGE_HEIGTH";

#pragma mark - ATGShoppingCartViewController Private Protocol
#pragma mark -

// Private protocol, defines some useful methods.
@interface ATGShoppingCartViewController () <ATGOrderTotalTableViewCellDelegate,
ATGProfileManagerDelegate, ATGAddressesViewControllerDelegate, ATGGridCollectionViewDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGOrder *order;
@property (nonatomic, readwrite, strong) ATGManagerRequest *request;
@property (nonatomic, readwrite, weak) UIView *featuredItemsView;
@property (nonatomic, readwrite, assign) CGFloat featuredItemsOffset;
@property (nonatomic, readwrite, assign, getter = isCartLoaded) BOOL cartLoaded;
@property (nonatomic, readwrite, weak) ATGGridCollectionView *featuredItemsGridView;

#pragma mark - Private Protocol Definition

// Creates a round-rect button with title and color specified. This method places
// the button created around part of space specified with frame parameter.
- (UIButton *)createButtonWithTitle:(NSString *)title
                       initialFrame:(CGRect)frame image:(UIImage *)image;
// The user just touched 'Share' button.
- (void)didTouchShareButton:(id)sender;
// The user just touched the 'Remove' button.
- (void)didTouchRemoveButton:(id)sender;
// The user just touched the 'Checkout' button.
- (void)didTouchCheckoutButton:(id)sender;
// Display addresses screen (start the checkout process).
- (void)presentAddressesScreenForAnonymous:(BOOL)userAnonymous;
// Display featured items.
- (void)setupFeaturedItemsView;
// Open main site
- (void)checkoutFromMainSite;

@end

#pragma mark - ATGShoppingCartViewController Implementation
#pragma mark -

@implementation ATGShoppingCartViewController

#pragma mark - Synthesized Properties

@synthesize order;
@synthesize request;
@synthesize featuredItemsView;
@synthesize featuredItemsOffset;
@synthesize cartLoaded;

#pragma mark - UIViewController+ATGToolbar Category Implementation

+ (UIImage *)toolbarIcon {
  return [UIImage imageNamed:@"icon-cart"];
}

+ (NSString *)toolbarAccessibilityLabel {
  return NSLocalizedStringWithDefaultValue
  (@"ATGViewController.ShoppingCartAccessibilityLabel",
   nil, [NSBundle mainBundle],
   @"Shopping Cart",
   @"Shopping cart toolbar button accessibility label");
}

#pragma mark - NSObject

- (void)dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (void)loadView {
  // Create an expandable view. This will allow to edit items purchased.
  UITableView *tableView = [[ATGExpandableTableView alloc] initWithFrame:CGRectZero
                                                                   style:UITableViewStyleGrouped];
  [self setView:tableView];
  [self setTableView:tableView];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  [self setCartLoaded:NO];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  [self setTitle:[[self class] toolbarAccessibilityLabel]];
}

- (void)viewDidUnload {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Deselect currently selected row first. This will cause an underlying
  // ATGExpandableTableView to recalculate cell height properly.
  [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow]
                                  animated:NO];
  [self loadOrder];
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
  [[self tableView] setScrollEnabled:YES];
  [super viewWillDisappear:pAnimated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  // Display all items in a single section + one section with 'Checkout' button.
  return [[[self order] commerceItems] count] > 0 ? 2 : ([self order] ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // Number of items purchased + one extra row with order details.
    return [[[self order] commerceItems] count] + 1 + [self errorNumberOfRowsInSection:pSection];
  } else if (pSection == 1) {
    return 1;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)pTableView
         cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 0 &&
      [pIndexPath row] != [self tableView:pTableView
                    numberOfRowsInSection:[pIndexPath section]] - 1 -
      [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    // It's an item details cell. Standard way of allocating a row.
    ATGCartTableViewCell *cell = [[ATGCartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                             reuseIdentifier:nil];
    // Receive messages from it.
    [cell setDelegate:self];
    return cell;
  } else if ([pIndexPath section] == 0) {
    // Last row in the first section is an Order Total.
    // Load Order Total cell from a NIB file.
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ATGOrderTotalTableViewCell"
                                                     owner:nil options:nil];
    for (id object in objects) {
      if ([object isKindOfClass:[ATGOrderTotalTableViewCell class]]) {
        ATGOrderTotalTableViewCell *cell = object;
        // Receive messages from it.
        [cell setDelegate:self];
        [cell setCouponEditable:YES];
        return cell;
      }
    }
  } else if ([pIndexPath section] == 1) {
    ATGButtonTableViewCell *cell = [[ATGButtonTableViewCell alloc] init];
    NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController.CheckoutButtonTitle", nil, [NSBundle mainBundle],
     @"Checkout", @"Title to be used by the checkout button.");
    [[cell button] setTitle:title forState:UIControlStateNormal];
    NSString *hint = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController.CheckoutButtonAccessoryHint", nil,
     [NSBundle mainBundle], @"Starts checkout process.",
     @"Accessibility hint to be used by the checkout button.");
    [[cell button] setAccessibilityHint:hint];
    NSString *label = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController.CheckoutButtonAccessoryButton", nil,
     [NSBundle mainBundle], @"Checkout",
     @"Accessibility label to be used by the checkout button.");
    [[cell button] setAccessibilityLabel:label];
    [[cell button] addTarget:self action:@selector(didTouchCheckoutButton:)
            forControlEvents:UIControlEventTouchUpInside];
    return cell;
  }
  // No other cells allowed.
  return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] < [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    return;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 0 &&
      [pIndexPath row] != [self tableView:pTableView
                    numberOfRowsInSection:[pIndexPath section]] - 1 -
      [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    // We're going to demonstrate an item cell. Update cell properties.
    ATGCartTableViewCell *cell = (ATGCartTableViewCell *)pCell;
    ATGCommerceItem *item = [[[self order] commerceItems] objectAtIndex:[pIndexPath row]];
    [cell setOldPrice:[item listPrice]];
    [cell setPriceBeans:[item unitPrices]];
    if ((id)item.thumbnailImage != [NSNull null] && item.thumbnailImage.length) {
      [cell setImageURL:[item thumbnailImage]];
    } else {
      [cell setImageURL:ATGDefaultImageURL];
    }
    [cell setCurrencyCode:self.order.priceInfo.currencyCode];
    [cell setSkuId:[[item sku] repositoryId]];
    [cell setIsNavigable:[item isNavigableProduct]];
    NSMutableArray *skuProperties = [[NSMutableArray alloc] initWithCapacity:3];
    if ([[item sku] color]) {
      [skuProperties addObject:[[item sku] color]];
    }
    if ([[item sku] size]) {
      [skuProperties addObject:[[item sku] size]];
    }
    if ([[item sku] woodFinish]) {
      [skuProperties addObject:[[item sku] woodFinish]];
    }
    [cell setSKUProperties:skuProperties];
    [cell setProductName:[[item sku] displayName]];
    [cell setItemId:[item commerceItemId]];
    [cell setProductId:[item prodId]];
  } else if ([pIndexPath section] == 0) {
    // Last row in the first section is an order total. Update its properties.
    ATGOrderTotalTableViewCell *cell = (ATGOrderTotalTableViewCell *)pCell;
    [cell setItemsTotal:self.order.priceInfo.rawSubtotal];
    [cell setDiscountTotal:self.order.priceInfo.discountAmount];
    [cell setStoreCreditsTotal:self.order.storeCreditsAvailable ? self.order.storeCreditsAvailable : self.order.storeCreditsAppliedTotal];
    [cell setShippingTotal:self.order.priceInfo.shipping];
    [cell setTaxTotal:self.order.priceInfo.tax];
    [cell setOrderTotal:self.order.priceInfo.total];
    [cell setOrderEmpty:[[[self order] commerceItems] count] == 0];
    [cell setCurrencyCode:self.order.priceInfo.currencyCode];
    [cell setDiscounts:[[self order] appliedPromotions]];
    [cell setCouponCode:[[self order] couponCode]];
    // Mark the cell as dirty to actually display all the properties.
    [cell setNeedsLayout];
  }
}

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 0 &&
      [pIndexPath row] == [self tableView:pTableView
                    numberOfRowsInSection:[pIndexPath section]] - 1 -
      [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    // It's an order total cell. It can calculate its height.
    return [[[self order] commerceItems] count] ? 126 : [pTableView rowHeight];
  }
  ATGCommerceItem *item = [[[self order] commerceItems] objectAtIndex:[pIndexPath row]];
  return 30 * [[item unitPrices] count] + 2 * 7;
}

- (NSIndexPath *)tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 0 &&
      [pIndexPath row] != [self tableView:pTableView
                    numberOfRowsInSection:[pIndexPath section]] - 1 -
      [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    return pIndexPath;
  }
  // don't allow anything other than a commerce item to be selected
  return nil;
}

#pragma mark - ATGCartTableViewCellDelegate

- (void)cartTableViewCell:(ATGCartTableViewCell *)pCell didTouchShareButton:(UIButton *)pButton {
  // The user touched the 'Share' button on some item cell. Display an extended
  // Share menu. This menu should be displayed on the blocked screen.
  ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
  // Calculate button position as if it is located on the current view.
  CGRect buttonFrame = [[self view] convertRect:[pButton frame]
                                       fromView:[pCell contentView]];
  NSString *shareCaption = NSLocalizedStringWithDefaultValue
  (@"ATGShoppingCartViewController.ShareButtonTitle", nil, [NSBundle mainBundle],
   @"Email a Friend", @"Title to be displayed on the Share button.");
  // Create the extended menu. By now it contains only one button.
  UIButton *button = [self createButtonWithTitle:shareCaption
                                    initialFrame:buttonFrame
                                           image:[[pButton imageView] image]];
  // What should we do when the user selects something from the menu?
  [button addTarget:self action:@selector(didTouchShareButton:)
   forControlEvents:UIControlEventTouchUpInside];
  // And display everything.
  [[self tableView] setScrollEnabled:NO];
  [blocker showBlockView:button withFrame:[[self view] bounds]
             actionBlock:^{
               [blocker dismissBlockView];
               [[self tableView] setScrollEnabled:YES];
             }
                 forView:[self view]];
}

- (void)cartTableViewCell:(ATGCartTableViewCell *)pCell
     didTouchRemoveButton:(UIButton *)pButton {
  // Display an extended 'Remove' menu.
  ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
  // Calculate button position as if it is located on the current view.
  CGRect buttonFrame = [[self view] convertRect:[pButton bounds] fromView:pButton];
  NSString *removeCaption = NSLocalizedStringWithDefaultValue
  (@"ATGShoppingCartViewController.RemoveButtonTitle", nil, [NSBundle mainBundle],
   @"Remove", @"Title to be displayed on the Remove button.");
  // Create the menu, it contains only one button.
  UIButton *button = [self createButtonWithTitle:removeCaption
                                    initialFrame:buttonFrame
                                           image:[[pButton imageView] image]];
  [button addTarget:self action:@selector(didTouchRemoveButton:)
   forControlEvents:UIControlEventTouchUpInside];
  // Display menu to user.
  [[self tableView] setScrollEnabled:NO];
  [blocker showBlockView:button withFrame:[[self view] bounds]
             actionBlock:^{
               [blocker dismissBlockView];
               [[self tableView] setScrollEnabled:YES];
             }
                 forView:[self view]];
}

- (void)cartTableViewCell:(ATGCartTableViewCell *)pCell didTouchEditSkuButton:(UIButton *)pButton {
  // Actually edit the SKU.
  [self performSegueWithIdentifier:ATGCartToProductSegue sender:pCell];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ATGCartToProductSegue]) {
    ATGProductPage *controller = segue.destinationViewController;
    if ([sender isMemberOfClass:[ATGBaseProduct class]]) {
      ATGBaseProduct *item = sender;
      controller.productId = item.repositoryId;
      controller.productTitle = item.displayName;
      controller.itemImageUrl = item.thumbnailImageUrl;
    } else {
      ATGCartTableViewCell *selection = sender;
      controller.productId = selection.productId;
      controller.productTitle = selection.productName;
      controller.skuId = selection.skuId;
      controller.productQuantity = [NSString stringWithFormat:@"%d", selection.quantity];
      controller.commerceItemId = selection.itemId;
      controller.itemImageUrl = selection.imageURL;
      controller.updateCard = YES;
    }
  } else if ([segue.identifier isEqualToString:ATGSegueIdCartToShippingAddresses]) {
    ATGShippingAddressesViewController *controller = segue.destinationViewController;
    controller.delegate = self;
    controller.showsSelection = YES;
  }
}

#pragma mark - ATGOrderTotalTableViewCellDelegate

- (void)claimCouponWithCode:(NSString *)pCouponCode {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  
  [self startActivityIndication:YES];
  BOOL renderCart = [self isMemberOfClass:[ATGShoppingCartViewController class]];
  [self setRequest:[[ATGCommerceManager commerceManager] claimCouponWithCode:pCouponCode
                                                       andRenderShoppingCart:renderCart
                                                                    delegate:self]];
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didGetShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self orderDidLoad:[pRequest requestResults]];
  [self setCartLoaded:YES];
}

- (void)didRemoveItemFromCart:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSIndexPath *selectedIndex = [[self tableView] indexPathForSelectedRow];
  NSIndexPath *orderTotalPath =
  [NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0] - 1
                     inSection:0];
  
  // This method is called in response to 'Remove Item' request.
  // With an item explicitly asked to be removed, some items may also disappear.
  // This may happen if some GiftWithPurchase item was added to shopping cart earlier.
  // When GWP conditions are not met anymore, extra items will be removed along with
  // explicitly removed items.
  // So we have to determine all rows to be removed.
  ATGOrder *newOrder = (ATGOrder *)[pRequest requestResults];
  // Save indices to be removed into this array.
  NSMutableArray *indiciesToRemove = [[NSMutableArray alloc] init];
  for (ATGCommerceItem *item in[[self order] commerceItems]) {
    // Search for an item within the new order. Two items are considered equal,
    // if they have equal IDs.
    if ([[newOrder commerceItems]
         indexOfObjectPassingTest:^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
           if ([[item commerceItemId]
                isEqualToString:[(ATGCommerceItem *) pObject commerceItemId]]) {
             // Do not iterate more if we've found the item already.
             *pStop = YES;
             return YES;
           }
           return NO;
         }] == NSNotFound) {
           // No item found in the new order. Current item should be removed then.
           [indiciesToRemove addObject:[NSIndexPath indexPathForRow:[[[self order] commerceItems]
                                                                     indexOfObject:item]
                                                          inSection:0]];
         }
  }
  NSInteger topRow = [[[self order] commerceItems] count];
  NSMutableArray *indicesToAdd = [[NSMutableArray alloc] init];
  for (ATGCommerceItem *newItem in [newOrder commerceItems]) {
    if ([[[self order] commerceItems]
         indexOfObjectPassingTest:^BOOL(id pObject, NSUInteger pIndex, BOOL *pStop) {
           if ([[newItem commerceItemId] isEqualToString:[(ATGCommerceItem *)pObject commerceItemId]]) {
             *pStop = YES;
             return YES;
           }
           return NO;
         }] == NSNotFound) {
           [indicesToAdd addObject:[NSIndexPath indexPathForRow:topRow++ inSection:0]];
         }
  }
  
  [self setOrder:newOrder];
  
  [[self tableView] deselectRowAtIndexPath:selectedIndex animated:NO];
  
  [[self tableView] beginUpdates];
  [[self tableView] deleteRowsAtIndexPaths:indiciesToRemove
                          withRowAnimation:UITableViewRowAnimationRight];
  [[self tableView] insertRowsAtIndexPaths:indicesToAdd
                          withRowAnimation:UITableViewRowAnimationRight];
  [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:orderTotalPath]
                          withRowAnimation:UITableViewRowAnimationRight];
  if ([[[self order] commerceItems] count] == 0) {
    // New order is empty, do not display 'Checkout' button anymore.
    [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:1]
                    withRowAnimation:UITableViewRowAnimationRight];
  }
  [[self tableView] endUpdates];
  
  
  [[self tableView] setScrollEnabled:YES];
  
  if ([[[self order] commerceItems] count] == 0) {
    [self setupFeaturedItemsView];
  }
}

- (void)didErrorRemovingItemFromCart:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow]
                                  animated:NO];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
}

- (void)didClaimCoupon:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  
  NSString *email = [[[self order] email] copy];
  [self setOrder:[pRequest requestResults]];
  [[self order] setEmail:email];
  [self.tableView reloadData];
}

- (void) didErrorClaimingCoupon:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSString *errorMessage = NSLocalizedStringWithDefaultValue
  (@"ATGShoppingCartViewController.ErrorClaimingCoupon", nil,
   [NSBundle mainBundle], @"Invalid",
   @"Alert message for error claiming coupon");
  ATGOrderTotalTableViewCell *totalCell =
  (ATGOrderTotalTableViewCell *)[[self tableView]
                                 cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:[[self tableView]
                                                               numberOfRowsInSection:0] - 1
                                                    inSection:0]];
  [totalCell setCouponError:errorMessage];
  [totalCell setNeedsLayout];
}

- (void)didGetCartFeaturedItems:(ATGCommerceManagerRequest *)pRequest {
  [[self featuredItemsGridView] setObjectsToDisplay:[pRequest requestResults]];
}

#pragma mark - ATGViewController

- (void)reloadData {
  [self loadOrder];
}

#pragma mark - Public Protocol Implementation

- (void)loadOrder {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  
  [self startActivityIndication:cartLoaded];
  [self setRequest:[[ATGCommerceManager commerceManager] getShoppingCart:self]];
}

- (void)orderDidLoad:(ATGOrder *)pOrder {
  [self setOrder:pOrder];
  [[self tableView] reloadData];
  
  if ([[[self order] commerceItems] count] == 0) {
    [self setupFeaturedItemsView];
  } else {
    [[self featuredItemsView] removeFromSuperview];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)pScrollView {
  CGPoint offset = [pScrollView contentOffset];
  CGRect frame = [[self featuredItemsView] frame];
  frame.origin.y = [self featuredItemsOffset] + offset.y;
  [[self featuredItemsView] setFrame:frame];
}

#pragma mark - Private Protocol Implementation

- (UIButton *)createButtonWithTitle:(NSString *)pTitle
                       initialFrame:(CGRect)pFrame image:(UIImage *)pImage {
  // Create a button. Use initial frame as starting position of the button.
  UIButton *button = [[ATGButton alloc] initWithFrame:pFrame];
  [button applyStyleWithName:@"cartButton"];
  [button setTitle:pTitle forState:UIControlStateNormal];
  // Calculate a caption size.
  // We will adjust button size to have enough space to contain it.
  CGSize titleSize = [[[button titleLabel] text] sizeWithFont:[[button titleLabel] font]];
  // Escribe the button around the frame specified.
  pFrame.size.height += 2 * ATGInsetBounds;
  pFrame.origin.y -= ATGInsetBounds;
  // Make enough space to hold the caption.
  pFrame.origin.x -= ATGDelimiterWidth + titleSize.width + [button titleEdgeInsets].left;
  pFrame.size.width +=
  ATGDelimiterWidth + titleSize.width + [button titleEdgeInsets].left + ATGInsetBounds;
  // The button is displayed inside the UITableView, so its actual 'y' origin may change
  // when user scrolls the table.
  pFrame.origin.y -= [[self tableView] contentOffset].y;
  [button setFrame:pFrame];
  // Inner button image should be displayed on the very same frame specified with
  // the pFrame parameter. This will make an illusion of displaying the same button
  // represented on the item cell.
  CGRect innerFrame = CGRectMake(ATGInsetBounds + titleSize.width + ATGDelimiterWidth,
                                 ATGInsetBounds,
                                 pFrame.size.width - ATGInsetBounds * 2 - ATGDelimiterWidth - titleSize.width,
                                 pFrame.size.height - 2 * ATGInsetBounds);
  // Inner button image as it is.
  UIImageView *view = [[UIImageView alloc] initWithFrame:innerFrame];
  [view setImage:pImage];
  [button addSubview:view];
  return button;
}

- (void)didTouchRemoveButton:(id)pSender {
  NSIndexPath *selectedIndex = [[self tableView] indexPathForSelectedRow];
  ATGCartTableViewCell *selectedCell =
  (ATGCartTableViewCell *)[[self tableView] cellForRowAtIndexPath:selectedIndex];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGCommerceManager commerceManager] removeItemFromCart:[selectedCell itemId]
                                                                   delegate:self]];
}

- (void)didTouchShareButton:(id)pSender {
  NSIndexPath *selectedIndex = [[self tableView] indexPathForSelectedRow];
  ATGCartTableViewCell *selectedCell =
  (ATGCartTableViewCell *)[[self tableView] cellForRowAtIndexPath:selectedIndex];
  NSString *subjectFormat = NSLocalizedStringWithDefaultValue
  (@"ATGShoppingCartViewController.ShareEmailSubjectFormat",
   nil, [NSBundle mainBundle], @"Check out the '%@'!",
   @"Subject format to be used when composing an 'Email a Friend' message.");
  NSString *subject = [NSString stringWithFormat:subjectFormat,
                       [selectedCell productName]];
  subject = [subject stringByAddingPercentEscapes];
  NSString *emailUrl = [NSString stringWithFormat:@"mailto:?subject=%@", subject];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailUrl]];
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
}

- (void)didTouchCheckoutButton:(id)pSender {
  [self becomeFirstResponder]; //force resign any other active responder, such as coupon text field.
  if ([[self order] containsGiftWrap]) {
    NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController.BadOrderMessageTitle", nil, [NSBundle mainBundle],
     @"Shipping to multiple addresses and gift wrap options can only be processed "
     @"from the main site.",
     @"Error message to be displayed for orders with gift options/multiple shipping groups.");
    NSString *action = NSLocalizedStringWithDefaultValue
    (@"ATGShoppingCartViewController.ViewOrderOnMainSiteTitle", nil, [NSBundle mainBundle],
     @"Checkout from the main site", @"Button title.");
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel applyStyleWithName:@"formTitleLabel"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor textHighlightedColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setText:title];
    CGSize maxSize = [[self view] bounds].size;
    maxSize.width -= 4 * ATGPoputInsetBounds;
    CGSize titleSize = [title sizeWithFont:[titleLabel font] constrainedToSize:maxSize
                             lineBreakMode:[titleLabel lineBreakMode]];
    [titleLabel setFrame:CGRectMake(ATGPoputInsetBounds, ATGPoputInsetBounds,
                                    maxSize.width, titleSize.height)];
    UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [viewButton addTarget:self action:@selector(checkoutFromMainSite)
         forControlEvents:UIControlEventTouchUpInside];
    [viewButton setBackgroundColor:[UIColor buttonLightBackgroundColor]];
    [[viewButton titleLabel] applyStyleWithName:@"formTitleLabel"];
    [viewButton setTitleColor:[UIColor textColor] forState:UIControlStateNormal];
    [viewButton setTitle:action forState:UIControlStateNormal];
    UIImage *disclosureImage = [UIImage imageNamed:@"icon-arrowLEFT"];
    [viewButton setImage:disclosureImage forState:UIControlStateNormal];
    [[viewButton imageView] setTransform:CGAffineTransformMakeRotation(M_PI)];
    [viewButton setFrame:CGRectMake(0, ATGPoputInsetBounds + titleSize.height + ATGPoputInsetBounds,
                                    maxSize.width + 2 * ATGPoputInsetBounds, ATGPopupElementHeight)];
    [[viewButton layer] setBorderColor:[[UIColor borderDarkColor] CGColor]];
    [[viewButton layer] setBorderWidth:1];
    [viewButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [viewButton setImageEdgeInsets:UIEdgeInsetsMake(0, maxSize.width, 0, 0)];
    [viewButton setTitleEdgeInsets:UIEdgeInsetsMake(0, ATGPoputInsetBounds, 0, 0)];
    UIView *container =
    [[UIView alloc] initWithFrame:CGRectMake(ATGPoputInsetBounds, ATGPoputInsetBounds,
                                             maxSize.width + 2 * ATGPoputInsetBounds,
                                             2 * ATGPoputInsetBounds + titleSize.height +
                                             ATGPopupElementHeight)];
    [container setBackgroundColor:[UIColor messageBackgroundColor]];
    [[container layer] setBorderColor:[[UIColor borderDarkColor] CGColor]];
    [[container layer] setBorderWidth:1];
    [[container layer] setCornerRadius:8];
    [container setClipsToBounds:YES];
    [container addSubview:titleLabel];
    [container addSubview:viewButton];
    [[ATGActionBlocker sharedModalBlocker] showBlockView:container
                                               withFrame:[[self view] bounds]
                                             actionBlock:^{
                                               [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
                                             }
                                                 forView:[self view]];
    return;
  }
  
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getSecurityStatus:self]];
}

- (void)presentAddressesScreenForAnonymous:(BOOL)pUserAnonymous {
  [self performSegueWithIdentifier:ATGSegueIdCartToShippingAddresses sender:self];
}

- (void)checkoutFromMainSite {
  NSURL *url = [[[ATGRestManager restManager] restSession] hostURLWithOptions:ATGRestRequestOptionNone];
  
  NSString *successUrl = @"/cart/cart.jsp";
  NSString *urlStr = [@"/crs/myaccount/login.jsp?enableFullSite=true&loginSuccessURL="
                      stringByAppendingString:[successUrl stringByAddingPercentEscapes]];
  NSURL *finalurl = [NSURL URLWithString:urlStr relativeToURL:url];
  [[UIApplication sharedApplication] openURL:finalurl];
}

- (void)setupFeaturedItemsView {
  CGRect frame = [[self view] bounds];
  frame.origin.y =
  frame.size.height - [[[[NSBundle mainBundle] infoDictionary]
                        objectForKey:ATGSliderImageHeight] floatValue];
  frame.size.height = [[[[NSBundle mainBundle] infoDictionary]
                        objectForKey:ATGSliderImageHeight] floatValue];
  ATGGridCollectionView *carousel =
  [[ATGGridCollectionView alloc] initWithFrame:frame cellsNibName:@"ATGSimpleProductItem"];
  [carousel setGridViewDelegate:self];
  [carousel setAllowsChoosing:NO];
  [carousel setScrollDirection:UICollectionViewScrollDirectionHorizontal];
  [carousel setBackgroundColor:[[self tableView] backgroundColor]];
  UIImage *delimiterImage = [UIImage imageNamed:@"description-divider"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:delimiterImage];
  [imageView setTransform:CGAffineTransformMakeRotation(M_PI)];
  frame.size.height = [delimiterImage size].height;
  frame.origin.y -= frame.size.height;
  [imageView setFrame:frame];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
  NSString *title = NSLocalizedStringWithDefaultValue
  (@"ATGShoppingCartViewController.FeaturedItemsTitle", nil, [NSBundle mainBundle],
   @"Featured Items", @"Featured items title.");
  [titleLabel setText:title];
  [titleLabel applyStyleWithName:@"headerLabel"];
  [titleLabel setTextAlignment:NSTextAlignmentLeft];
  [titleLabel setBackgroundColor:[[self tableView] backgroundColor]];
  CGSize size = [title sizeWithFont:[titleLabel font]];
  frame.origin.y -= size.height;
  frame.size.height = size.height;
  frame.origin.x = 12;
  [titleLabel setFrame:frame];
  UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
  frame.origin.x = 0;
  frame.size.height = [[self view] bounds].size.height - frame.origin.y;
  [container setFrame:frame];
  [container addSubview:titleLabel];
  [container addSubview:imageView];
  [container addSubview:carousel];
  [[self featuredItemsView] removeFromSuperview];
  [self setFeaturedItemsView:container];
  [[self view] addSubview:container];
  for (UIView *view in[container subviews]) {
    [view setFrame:[container convertRect:[view frame] fromView:[self view]]];
  }
  [self setFeaturedItemsOffset:frame.origin.y];
  [self setFeaturedItemsGridView:carousel];
  [self setRequest:[[ATGCommerceManager commerceManager] getCartFeaturedItems:self]];
}

#pragma mark - ATGGridCollectionViewDelegate

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didSelectObject:(id)pObject {
  [self performSegueWithIdentifier:ATGCartToProductSegue sender:pObject];
}

#pragma mark - ATGLoginViewControllerDelegate

- (void)didLogin {
  [super didLogin];
  [self presentAddressesScreenForAnonymous:NO];
}

- (void)didSkipLogin {
  [super didSkipLogin];
  [self presentAddressesScreenForAnonymous:YES];
}

#pragma mark - ATGLoginDelegate

- (void)didGetSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  if ([(NSNumber *)[pRequestResults requestResults]
       compare:[NSNumber numberWithInteger:3]] == NSOrderedDescending) {
    // The user is explicitly logged in. Display addresses to begin checkout.
    [self presentAddressesScreenForAnonymous:NO];
  } else {
    // The user is not logged in yet.
    [self presentLoginViewControllerAnimated:YES allowSkipLogin:YES];
  }
}

- (void)didErrorGettingSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

@end