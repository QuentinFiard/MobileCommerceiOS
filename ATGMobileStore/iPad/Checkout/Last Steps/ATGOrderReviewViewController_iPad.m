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

#import "ATGOrderReviewViewController_iPad.h"
#import "ATGCheckoutCreditCardsController.h"
#import "ATGCheckoutShippingMethodViewController.h"
#import "ATGMoreDetailsController.h"
#import "ATGOrderPlacedViewController.h"
#import "ATGOrderSubtotalsTableViewCell.h"
#import <ATGMobileClient/ATGCreditCardTableViewCell.h>
#import "ATGOrderReviewAddressTableViewCell.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGRestManager.h>

#pragma mark - ATGOrderReviewViewController_iPad Private Protocol Definition
#pragma mark -

@interface ATGOrderReviewViewController_iPad () <ATGCommerceManagerDelegate>

#pragma mark - Custom Properties
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) NSArray *orderItems;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) BOOL userAnonymous;

#pragma mark - Private Protocol

- (void) viewOrderOnMainSite:(id)sender;
- (void) handleSecurityStatus:(NSNumber *)pSecurityStatus;

@end

#pragma mark - ATGOrderReviewViewController_iPad Implementation
#pragma mark -

@implementation ATGOrderReviewViewController_iPad

@synthesize orderItems, priceFormatter, orderId, email, userAnonymous, emailField;

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  // Superclass declares an Edit button to be displayed at the right side. Remove it.
  [[self navigationItem] setRightBarButtonItem:nil];
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGOrderReviewViewController.PlaceButtonTitle", nil, [NSBundle mainBundle],
                      @"Place My Order", @"Title to be displayed on the Place button.");
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(didTouchPlaceOrderButton:)];
  button.width = ATGPhoneScreenWidth;
  self.toolbarItems = [NSArray arrayWithObject:button];
  [self.navigationController setToolbarHidden:NO animated:YES];
  title = NSLocalizedStringWithDefaultValue
            (@"ATGOrderReviewViewController.ScreenTitle",
            nil, [NSBundle mainBundle], @"Order Review",
            @"Screen title to be used.");
  [self setTitle:title];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [self.navigationController setToolbarHidden:NO animated:YES];
  //  [self setTitle:[NSString stringWithFormat:title, [self orderID]]];
}

- (void) viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  //drop navigation stack to cc
  NSArray *controllers = [[self navigationController] viewControllers];
  // First, try to find 'Cards List' screen in the stack.
  NSUInteger splitIndex =
    [controllers indexOfObjectPassingTest: ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
       if ([pObject isKindOfClass:[ATGCheckoutCreditCardsController class]]) {
         *pStop = YES;
         return YES;
       }
       return NO;
     }
    ];
  if (splitIndex == NSNotFound) {
    // Nothing found? then this screen has been removed due to empty user card list.
    // Search for the 'New Card' screen instead.
    splitIndex =
      [controllers indexOfObjectPassingTest: ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
         if ([pObject isKindOfClass:[ATGCheckoutCreditCardCreateController class]]) {
           *pStop = YES;
           return YES;
         }
         return NO;
       }
      ];
  }
  if (splitIndex != NSNotFound) {
    // Save all controllers displayed before card-related screens (and first card screen).
    controllers = [controllers subarrayWithRange:NSMakeRange (0, splitIndex + 1)];
    // Don't forget to add current screen at the top of the stack.
    controllers = [controllers arrayByAddingObject:self];
    [[self navigationController] setViewControllers:controllers];
  }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ATGSegueIdOrderReviewToShippingAddresses]) {
    ATGAddressesViewController *controller = segue.destinationViewController;
    controller.delegate = self;
    controller.showsSelection = YES;
  } else if ([segue.identifier isEqualToString:ATGSegueIdOrderReviewToShippingMethods]) {
    ATGCheckoutShippingMethodViewController *controller = segue.destinationViewController;
    controller.editMethod = YES;
  } else if ([segue.identifier isEqualToString:ATGSegueIdOrderReviewToMoreDetails]) {
    ATGMoreDetailsController *controller = segue.destinationViewController;
    controller.request = [[ATGStoreManager storeManager] getPrivacyPolicy:controller];
  } else if ([segue.identifier isEqualToString:ATGSegueIdOrderReviewToOrderPlaced]) {
    ATGOrderPlacedViewController *controller = segue.destinationViewController;
    controller.email = self.email;
    controller.userAnonymous = self.userAnonymous;
    controller.orderID = self.orderId;
  } else {
    [super prepareForSegue:segue sender:sender];
  }
}

- (CGSize) contentSizeForViewInPopover {
  CGFloat width = ATGPhoneScreenWidth;
  CGFloat height = ATGPopoverMinHeight;
  if (![self order]) {
    return CGSizeMake(width, ATGPhoneScreenHeight);
  }
  for (NSInteger section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; section++) {
    height += [[self tableView] sectionHeaderHeight] + [[self tableView] sectionFooterHeight];
    for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:section]; row++) {
      height += [self          tableView:[self tableView]
                 heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    }
  }
  return CGSizeMake(width, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Do not display 'Email Confirmation' and 'Place Order' cells. Order details only.
  NSInteger numberOfSection = [self order] ? 3 : 0;
  if ([self order] && self.userAnonymous) {
    numberOfSection++;
  }
  return numberOfSection;
}

- (NSString *) tableView:(UITableView *)pTableView titleForHeaderInSection:(NSInteger)pSection {
  switch (pSection) {
  case 0:
    return NSLocalizedStringWithDefaultValue
             (@"ATGOrderDetailsViewController.iPad.ItemsSectionTitle",
             nil, [NSBundle mainBundle], @"Items, Extras, Totals",
             @"Title of the table view section with order items, promotions and totals on the screen "
             @"with submitted order details.");
    break;

  case 1:
    return NSLocalizedStringWithDefaultValue
             (@"ATGOrderDetailsViewController.iPad.ShippingSectionTitle",
             nil, [NSBundle mainBundle], @"Ship to",
             @"Title of the table view section with shipping information on the screen "
             @"with submitted order details.");
    break;

  case 2:
    return NSLocalizedStringWithDefaultValue
             (@"ATGOrderDetailsViewController.iPad.BillingSectionTitle",
             nil, [NSBundle mainBundle], @"Payment",
             @"Title of the table view section with billing information on the screen "
             @"with submitted order details.");
    break;

  case 3:
    return NSLocalizedStringWithDefaultValue
             (@"ATGOrderReviewViewController.EmailConfirmationSectionTitle",
             nil, [NSBundle mainBundle], @"Email Confirmation?",
             @"Title to be displayed on the 'email confirmation' section.");

  default:
    return nil;
  }
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  switch (pSection) {
  case 0:
    return [[self orderItems] count] + 3 + [self errorNumberOfRowsInSection:pSection]; //4
    break;

  case 1:
    return 2;
    break;

  case 2:
    if ([self.order.storeCreditsAppliedTotal compare:[NSDecimalNumber zero]] == NSOrderedDescending
            && self.order.creditCard) {
      // There are store credits applied, so both credits and card were used.
      return 2;
    }
    return 1;
    break;
  case 3:
    return 1;
    break;

  default:
    return 0;
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
    
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 0 &&
      [pIndexPath row] == [[self orderItems] count] + 1) {
    ATGOrderSubtotalsTableViewCell *cell =
      [pTableView dequeueReusableCellWithIdentifier:@"ATGOrderSubtotalsCell"];
    [cell setSubtotal:self.order.priceInfo.rawSubtotal];
    [cell setShipping:self.order.priceInfo.shipping];
    [cell setDiscounts:self.order.priceInfo.discountAmount];
    [cell setTax:self.order.priceInfo.tax];
    [cell setCurrencyCode:self.order.priceInfo.currencyCode];
    return cell;
  } else if ([pIndexPath section] == 0 &&
             [pIndexPath row] == [[self orderItems] count] + 2) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGOrderTotalCell"];
    NSString *caption = NSLocalizedStringWithDefaultValue
                          (@"ATGOrderDetailsViewController.OrderTotalCaption",
                          nil, [NSBundle mainBundle], @"Order Total",
                          @"Caption to be displayed next to order total value on the order details screen.");
    [[cell textLabel] setText:caption];
    [[cell detailTextLabel] setText:[[self priceFormatter] stringFromNumber:self.order.priceInfo.total]];
    return cell;
  } else if ([pIndexPath section] == 1 && [pIndexPath row] == 0) {
    ATGOrderReviewAddressTableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
    [cell setAddress:[[self order] shippingAddress]];
    cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
    return cell;
  } else if ([pIndexPath section] == 1 && [pIndexPath row] == 1) {
    ATGShippingMethodTableViewCell *cell =
      [pTableView dequeueReusableCellWithIdentifier:@"ATGShippingMethodCell"];
    [cell setShippingMethod:[[self order] shippingMethod]];
    cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
    return cell;
  } else if ([pIndexPath section] == 2) {
    if ([pIndexPath row] == 0 &&
        self.order.creditCard) {
      ATGCreditCardTableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGBillingCell"];
      [cell setCreditCard:[[self order] creditCard]];
      cell.cardAmountLabel.text = [self.priceFormatter stringFromNumber:self.order.creditCard.amount];
      cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
      return cell;
    } else if (self.order.storeCreditsAppliedTotal && self.order.storeCreditsAppliedTotal != [NSDecimalNumber zero]) {
      UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGBillingCreditsCell"];
      NSString *caption = NSLocalizedStringWithDefaultValue
          (@"ATGOrderReviewViewController_iPad.StoreCreditsCaption",
           nil, [NSBundle mainBundle], @"Store Credits",
           @"Title to be displayed to user inside a cell with store credits applied to order.");
      [[cell textLabel] setText:caption];
      [[cell detailTextLabel] setText:[self.priceFormatter stringFromNumber:self.order.storeCreditsAppliedTotal]];
      return cell;
    }
  } else if ([pIndexPath section] == 3 && self.userAnonymous) {
    // Order confirmation email cell.
    UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    CGRect inputFrame = [[cell contentView] bounds];
    inputFrame.origin.x = 10;
    inputFrame.size.width -= 20;
    UITextField *emailInput = [[UITextField alloc] initWithFrame:inputFrame];
    [emailInput setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [[cell contentView] addSubview:emailInput];
    NSString *placeholder = NSLocalizedStringWithDefaultValue
        (@"ATGOrderReviewViewController.EmailInputPlaceholder", nil, [NSBundle mainBundle],
         @"Email Address (optional)", @"Placeholder to be displayed on the email input.");
    [emailInput setPlaceholder:placeholder];
    [emailInput applyStyle:ATGTextFieldFormText];
    [emailInput setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [emailInput setDelegate:self];
    [emailInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [emailInput setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [emailInput setReturnKeyType:UIReturnKeyGo];
    [emailInput setKeyboardType:UIKeyboardTypeEmailAddress];
    self.emailField = emailInput;
    [emailInput setText:[self email]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    [cell setBackgroundColor:[UIColor tableCellBackgroundColor]];
    return cell;
  } 
  pIndexPath = [self convertIndexPath:pIndexPath];
  return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForHeaderInSection:(NSInteger)pSection {
  return [pTableView sectionHeaderHeight];
}

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  // Do not pass shifted index path into tableView:cellForRowAtIndexPath: or
  // tableView:heighForRowAtIndexPath: methods. These methods are written
  // to handle error-related cells by their own.
  NSIndexPath *shiftedPath = [self shiftIndexPath:pIndexPath];
  if ([shiftedPath section] == 0 && [shiftedPath row] == [[self orderItems] count] + 1) {
    ATGOrderSubtotalsTableViewCell *cell = (ATGOrderSubtotalsTableViewCell *)[self        tableView:pTableView
                                                                              cellForRowAtIndexPath:pIndexPath];
    return [cell bounds].size.height;
  } else if ([shiftedPath section] == 0) {
    return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
  } else if ([shiftedPath section] == 1 && [shiftedPath row] == 0) {
    ATGOrderReviewAddressTableViewCell *cell = (ATGOrderReviewAddressTableViewCell *)[self        tableView:pTableView
                                                                cellForRowAtIndexPath:pIndexPath];
    return [cell sizeThatFits:[[self tableView] bounds].size].height;
  } else if ([shiftedPath section] == 2) {
    UITableViewCell *cell = [self tableView:pTableView cellForRowAtIndexPath:pIndexPath];
    if ([cell isKindOfClass:[ATGCreditCardTableViewCell class]]) {
      return [cell sizeThatFits:[[self tableView] bounds].size].height;
    }
  }
  return [[self tableView] rowHeight];
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  switch (pIndexPath.section) {
  case 1:
    if (pIndexPath.row == 0) {
      if (![[self navigationController]
            popToViewControllerWithClass:[ATGShippingAddressesViewController class] animated:YES]) {
        [[self navigationController] popToViewControllerWithClass:[ATGShippingAddressEditController class]
                                                         animated:YES];
      }
    } else {
      [[self navigationController]
          popToViewControllerWithClass:[ATGCheckoutShippingMethodViewController class] animated:YES];
    }
    break;

  case 2:
      if ([pIndexPath row] == 0 && self.order.creditCard) {
        if (![[self navigationController]
              popToViewControllerWithClass:[ATGCheckoutCreditCardsController class] animated:YES]) {
          [[self navigationController]
           popToViewControllerWithClass:[ATGCheckoutCreditCardCreateController class] animated:YES];
        }
      }
    break;
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  if (pTextField == [self emailField]) {
    [pTextField resignFirstResponder];
    [self didTouchPlaceOrderButton:nil];
    return YES;
  } else {
    return [super textFieldShouldReturn:pTextField];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)pTextField {
  if (pTextField == [self emailField]) {
    [self setEmail:[pTextField text]];
  }
}

#pragma mark - ATGCommerceManagerDelegate

- (void) didGetOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self orderDidLoad:[pRequest requestResults]];
  // If no order is set, then orderDidLoad: method did not set it; this means that order is incorrect.
  // So no UI updates should be made.
  if ([self order]) {
    [[self tableView] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
                    withRowAnimation:UITableViewRowAnimationFade];
    [self handleSecurityStatus:[[self order] securityStatus]];
    if (IS_IPAD) {
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    }
  }
}

- (void) didErrorGettingOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

- (void) didCommitOrder:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  self.orderId = [pRequest requestResults];
  [self performSegueWithIdentifier:ATGSegueIdOrderReviewToOrderPlaced sender:self];
}

- (void) didErrorCommittingOrder:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
}

- (void) didClaimCoupon:(ATGCommerceManagerRequest *)pRequest {
  // Save shipping/billing info, as it's not returned from server when claiming a coupon.
  // We'll place these values back on order after the order is set on the controller.
  // Coupon can't change shipping address or credit card, so it's a legal operation.
  ATGContactInfo *shippingAddress = [[self order] shippingAddress];
  ATGCreditCard *creditCard = [[self order] creditCard];
  NSString *shippingMethod = [[self order] shippingMethod];
  [self setOrder:[pRequest requestResults]];
  [[self tableView] beginUpdates];
  [[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]
                  withRowAnimation:UITableViewRowAnimationFade];
  [[self tableView] endUpdates];
  // Allow superclass to update order items and promotions cell.
  [super didClaimCoupon:pRequest];
  // Super-implementation updates controller's order property, so we're ready to restore shipping/billing info.
  [[self order] setShippingAddress:shippingAddress];
  [[self order] setShippingMethod:shippingMethod];
  [[self order] setCreditCard:creditCard];
  // And now we have to update order subtotals and order total cells.
  [[self tableView] beginUpdates];
  NSInteger numberOfRows = [[self tableView] numberOfRowsInSection:0];
  // Order subtotals and order total are the last two cells in this section.
  [[self tableView] reloadRowsAtIndexPaths:[NSArray
                                            arrayWithObjects:[NSIndexPath indexPathForRow:numberOfRows - 2
                                                                                inSection:0],
                                            [NSIndexPath indexPathForRow:numberOfRows - 1
                                                               inSection:0], nil]
                          withRowAnimation:UITableViewRowAnimationRight];
  // Reload billing/shipping sections to display pre-saved shipping/billing info.
  [[self tableView] reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]
                  withRowAnimation:UITableViewRowAnimationNone];
  [[self tableView] endUpdates];
}

#pragma mark - ATGShoppingCartViewController_iPad

- (void) loadOrder {
  // This screen takes an order from profile manager, not commerce.
  [self.currentRequest setDelegate:nil];
  [self.currentRequest cancelRequest];
  [self startActivityIndication:YES];
  self.currentRequest = [[ATGCommerceManager commerceManager] getOrderSummaryForConfirmation:self];
}

- (void) orderDidLoad:(ATGOrder *)pOrder {
  if ([[pOrder shippingGroupCount] integerValue] > 1) {
    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGOrderReviewViewController.iPad.BadOrderMessage",
                        nil, [NSBundle mainBundle], @"Orders that shipped to multiple addresses can only be viewed from the main site.",
                        @"Error message to be displayed to user when trying to inspect an order "
                        @"shipped to multiple addresses.");
    NSString *action = NSLocalizedStringWithDefaultValue
                         (@"ATGOrderDetailsViewController.ViewOrderOnMainSiteTitle",
                         nil, [NSBundle mainBundle], @"View Order on the main site",
                         @"Button title.");
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel applyStyleWithName:@"formTitleLabel"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor textHighlightedColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setText:title];
    CGSize maxSize = [[self view] bounds].size;
    maxSize.width -= 4 * 12;
    CGSize titleSize = [title sizeWithFont:[titleLabel font] constrainedToSize:maxSize
                             lineBreakMode:[titleLabel lineBreakMode]];
    [titleLabel setFrame:CGRectMake(12, 12, maxSize.width, titleSize.height)];
    UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [viewButton addTarget:self action:@selector(viewOrderOnMainSite:)
         forControlEvents:UIControlEventTouchUpInside];
    [viewButton setBackgroundColor:[UIColor buttonLightBackgroundColor]];
    [[viewButton titleLabel] applyStyleWithName:@"formTitleLabel"];
    [viewButton setTitleColor:[UIColor textColor] forState:UIControlStateNormal];
    [viewButton setTitle:action forState:UIControlStateNormal];
    UIImage *disclosureImage = [UIImage imageNamed:@"icon-arrowLEFT"];
    [viewButton setImage:disclosureImage forState:UIControlStateNormal];
    [[viewButton imageView] setTransform:CGAffineTransformMakeRotation(M_PI)];
    [viewButton setFrame:CGRectMake(0, 12 + titleSize.height + 12,
                                    maxSize.width + 2 * 12, 44)];
    [[viewButton layer] setBorderColor:[[UIColor borderDarkColor] CGColor]];
    [[viewButton layer] setBorderWidth:1];
    [viewButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [viewButton setImageEdgeInsets:UIEdgeInsetsMake(0, maxSize.width, 0, 0)];
    [viewButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    UIView *container =
      [[UIView alloc] initWithFrame:CGRectMake(12, 12, maxSize.width + 2 * 12,
                                               12 + titleSize.height + 12 + 44)];
    [container setBackgroundColor:[UIColor messageBackgroundColor]];
    [[container layer] setBorderColor:[[UIColor borderDarkColor] CGColor]];
    [[container layer] setBorderWidth:1];
    [[container layer] setCornerRadius:8];
    [container setClipsToBounds:YES];
    [container addSubview:titleLabel];
    [container addSubview:viewButton];
    [[ATGActionBlocker sharedModalBlocker] showBlockView:container
                                               withFrame:[[self view] bounds]
                                             actionBlock: ^{
       [[self navigationController] popViewControllerAnimated:YES];
     }
                                                 forView:[self view]];
  } else {
    [super orderDidLoad:pOrder];
    [self setOrder:pOrder];
    [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
    [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self priceFormatter] setLocale:[NSLocale currentLocale]];
    [[self priceFormatter] setCurrencyCode:self.order.priceInfo.currencyCode];
    [self setOrderItems:[[self order] acceptableCommerceItems]];
  }
}

- (BOOL) shouldEditCellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Order Details screen doesn't support Swipe-to-Edit gesture.
  return NO;
}

#pragma mark - Private Protocol Implementation

- (void) viewOrderOnMainSite:(id)pSender {
  NSString *url = [[[[ATGRestManager restManager] restSession] hostURLWithOptions:ATGRestRequestOptionNone] absoluteString];
  url = [url stringByAppendingString:ATGUrlLogin];
  NSString *finalUrl = [ATGUrlOrderDetail stringByAppendingString:self.order.orderId];
  url = [url stringByAppendingString:[finalUrl stringByAddingPercentEscapes]];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - ATGAddressViewControllerDelegate

- (void) navigateOnSelection {
  [self.navigationController popViewControllerAnimated:YES];
  [self loadOrder];
}

#pragma mark - Private Protocol Implementation

- (void) didTouchPlaceOrderButton:(id)pSender {
  self.email = self.userAnonymous ? [[self.emailField text] copy] : [[self.order email] copy];
  [self.currentRequest cancelRequest];
  [self startActivityIndication:YES];
  self.currentRequest = [[ATGCommerceManager commerceManager] commitOrder:self.email delegate:self];
  ATGButtonTableViewCell *cell;
  if (self.userAnonymous) {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
  } else {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
  }
  [[cell button] setTitle:NSLocalizedStringWithDefaultValue
      (@"ATGOrderReviewViewController.SubmittingTitleButton", nil, [NSBundle mainBundle], @"Submitting...",
       @"Title to be displayed on the button during submitting order.") forState:UIControlStateNormal];
  [[cell button] setEnabled:NO];
}

- (void) handleSecurityStatus:(NSNumber *)pSecurityStatus {
  if (pSecurityStatus) {
    // make sure it's not nil
    BOOL oldUserAnonymous = self.userAnonymous;
    if ([pSecurityStatus compare:[NSNumber numberWithInteger:0]] == NSOrderedSame) {
      self.userAnonymous = YES;
    } else {
      self.userAnonymous = NO;
    }
    if (self.userAnonymous && !oldUserAnonymous) {
      [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:3]
                      withRowAnimation:UITableViewRowAnimationRight];
    } else if (oldUserAnonymous && !self.userAnonymous) {
      [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:3]
                      withRowAnimation:UITableViewRowAnimationRight];
    }
  }
}

@end
