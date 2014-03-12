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

#import "ATGOrderReviewViewController.h"
#import "ATGOrdersViewController.h"
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import "ATGCheckoutShippingMethodViewController.h"
#import <ATGUIElements/ATGTextField.h>
#import <ATGMobileClient/ATGOrder.h>
#import "ATGOrderPlacedViewController.h"
#import "ATGMoreDetailsController.h"
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import "ATGCheckoutCreditCardsController.h"
#import "ATGOrderPlacedViewController_iPad.h"
#import "ATGOrderTotalTableViewCell.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>

#pragma mark - ATGContactInfo+ATGAddressDetails Definition
#pragma mark -

@interface ATGContactInfo (ATGAddressDetails)

- (NSString *)contact;
- (NSString *)address;

@end

#pragma mark - ATGCreditCard+ATGCardDetails Definition
#pragma mark -

@interface ATGCreditCard (ATGCardDetails)

- (NSString *)details;

@end

#pragma mark - ATGOrderReviewViewController Private Protocol
#pragma mark -

@interface ATGOrderReviewViewController () <ATGProfileManagerDelegate, UITextFieldDelegate,
    ATGAddressesViewControllerDelegate, ATGCommerceManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGOrder *order;
@property (nonatomic, readwrite, strong) UITableViewCell *creditCardCell;
@property (nonatomic, readwrite, strong) UITableViewCell *addressCell;
@property (nonatomic, readwrite, strong) UITextField *emailText;
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *orderID;
@property (nonatomic, readwrite, assign, getter = isUserAnonymous) BOOL userAnonymous;
@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *request;

#pragma mark - Private Protocol Definition

- (void)didTouchPlaceOrderButton:(id)sender;
- (void)handleSecurityStatus:(NSNumber *)pSecurityStatus;

@end

#pragma mark - ATGOrderReviewViewController Implementation
#pragma mark -

@implementation ATGOrderReviewViewController

#pragma mark - Synthesized Properties

@synthesize order;
@synthesize creditCardCell;
@synthesize addressCell;
@synthesize emailText;
@synthesize priceFormatter;
@synthesize email;
@synthesize orderID;
@synthesize userAnonymous;
@synthesize request;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
  [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
  [[self priceFormatter] setLocale:[NSLocale currentLocale]];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGOrderReviewViewController.ScreenTitle", nil, [NSBundle mainBundle],
       @"Order Review", @"Screen title to be used.");
  [self setTitle:title];
}

- (void)viewDidUnload {
  [self setCreditCardCell:nil];
  [self setAddressCell:nil];
  [self setEmailText:nil];
  [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  
  //drop checkout navigation stack to cc
  NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
  if (![[vcs objectAtIndex:[vcs count] - 2] isKindOfClass:[ATGOrdersViewController class]]) {
    NSInteger creditCardsIndex =
        [vcs indexOfObjectPassingTest:^BOOL(id pObject, NSUInteger pIndex, BOOL *pStop) {
          if ([pObject isKindOfClass:[ATGCheckoutCreditCardsController class]]) {
            *pStop = YES;
            return YES;
          }
          return NO;
        }];
    if (creditCardsIndex != NSNotFound) {
      while (![[vcs lastObject] isKindOfClass:[ATGCheckoutCreditCardsController class]]) {
        [vcs removeLastObject];
      }
      [vcs addObject:self];
      [self.navigationController setViewControllers:vcs animated:NO];
    }
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:ATGSegueIdOrderReviewToShippingAddresses]) {
    ATGAddressesViewController *controller = pSegue.destinationViewController;
    controller.delegate = self;
    controller.showsSelection = YES;
  } else if ([pSegue.identifier isEqualToString:ATGSegueIdOrderReviewToShippingMethods]) {
    ATGCheckoutShippingMethodViewController *controller = pSegue.destinationViewController;
    controller.editMethod = YES;
  } else if ([pSegue.identifier isEqualToString:ATGSegueIdOrderReviewToOrderPlaced]) {
    if ([self isPad]) {
      ATGOrderPlacedViewController *controller = pSegue.destinationViewController;
      controller.email = [self email];
      controller.userAnonymous = [self isUserAnonymous];
      controller.orderID = [self orderID];
    } else {
      ATGOrderPlacedViewController_iPad *destination = [pSegue destinationViewController];
      [destination setEmail:[self email]];
      [destination setUserAnonymous:[self isUserAnonymous]];
      [destination setOrderID:[self orderID]];
    }
  } else {
    [super prepareForSegue:pSegue sender:pSender];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  // Four sections with order details, one extra section for anonymous users
  // (contains order confirmation email address) and one section for
  // 'Place Order' button.
  return [self order] ? 4 + ([self isUserAnonymous] ? 1 : 0) + 1 : 0;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // It's an order details section, re-use shopping cart's cells.
    return [super tableView:pTableView numberOfRowsInSection:pSection];
  } else {
    // All other sections contain only one cell.
    return 1 + [self errorNumberOfRowsInSection:pSection];
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView
         cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    // It's an order details section, re-use shopping cart's cells.
    UITableViewCell *cell = [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
    if ([cell isKindOfClass:[ATGOrderTotalTableViewCell class]]) {
      if ([[self order] couponCode] == nil) {
        [(ATGOrderTotalTableViewCell *)cell setCouponHidden:NO];
        [(ATGOrderTotalTableViewCell *) cell setCouponEditable:YES];
      } else {
        [(ATGOrderTotalTableViewCell *)cell setCouponEditable:NO];
      }
    }
    return cell;
  }
  UITableViewCell *errorCell = [self tableView:pTableView
                    errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath section] == 1) {
    // Payment details.
    return [self creditCardCell];
  } else if ([pIndexPath section] == 2) {
    // Shipping address details.
    [[self addressCell] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[self addressCell] setAccessibilityTraits:UIAccessibilityTraitButton];
    [[self addressCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
       (@"ATGOrderReviewViewController.ShippingAddressAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to change shipping address", @"Accessebility hint for change shipping address button.")];
    return [self addressCell];
  } else if ([pIndexPath section] == 3) {
    // Shipping method.
    UITableViewCell *cell =
      [[ATGCheckoutShippingMethodTableViewCell alloc]
         initWithStyle:UITableViewCellStyleDefault
       reuseIdentifier:nil currencyCode:self.order.priceInfo.currencyCode];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setBackgroundColor:[UIColor tableCellBackgroundColor]];
    [cell setAccessibilityTraits:UIAccessibilityTraitButton];
    [cell setAccessibilityHint:NSLocalizedStringWithDefaultValue
       (@"ATGOrderReviewViewController.ShippingMethodAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to change shipping method", @"Accessebility hint for change shipping method button.")];
    return cell;
  } else if ([pIndexPath section] == 4 && [self isUserAnonymous]) {
    // Order confirmation email cell.
    UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    CGRect inputFrame = [[cell contentView] bounds];
    inputFrame.origin.x = 10;
    inputFrame.size.width -= 20;
    UITextField *emailInput = [[UITextField alloc] initWithFrame:inputFrame];
    [emailInput setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleBottomMargin];
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
    [self setEmailText:emailInput];

    ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:nil];
    [[self emailText] setInputAccessoryView:toolbar];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    [cell setBackgroundColor:[UIColor tableCellBackgroundColor]];
    return cell;
  } else {
    // Place button.
    ATGButtonTableViewCell *cell = [[ATGButtonTableViewCell alloc] init];
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGOrderReviewViewController.PlaceButtonTitle", nil, [NSBundle mainBundle],
         @"Place My Order", @"Title to be displayed on the Place button.");
    [[cell button] setTitle: title forState:UIControlStateNormal];
    [[cell button] addTarget:self action:@selector(didTouchPlaceOrderButton:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Get the size of the space needed to display the text  
    CGSize size = [title sizeWithFont: [[[cell button] titleLabel] font]];
    
    // Get the old frame, which is positioned correctly, and make a new frame from it, updating it with 
    // the size of the text.
    CGRect oldFrame = [cell button].frame;
    [[cell button] setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y,
                                       size.width + 12, oldFrame.size.height)];

    return cell;
  }
}

- (NSString *)tableView:(UITableView *)pTableView titleForHeaderInSection:(NSInteger)pSection {
  switch (pSection) {
    case 0:
      return nil;
    case 1:
      return NSLocalizedStringWithDefaultValue
               (@"ATGOrderReviewViewController.PayWithSectionTitle",
                nil, [NSBundle mainBundle], @"Pay With",
                @"Title to be displayed on the 'pay with' section.");
    case 2:
      return NSLocalizedStringWithDefaultValue
               (@"ATGOrderReviewViewController.ShipToSectionTitle",
                nil, [NSBundle mainBundle], @"Ship To",
                @"Title to be displayed on the 'ship to' section.");
    case 3:
      return NSLocalizedStringWithDefaultValue
               (@"ATGOrderReviewViewController.ShippingMethodSectionTitle",
                nil, [NSBundle mainBundle], @"Shipping Method",
                @"Title to be displayed on the 'shipping method' section.");
    case 4:
      return [self isUserAnonymous] ? NSLocalizedStringWithDefaultValue
               (@"ATGOrderReviewViewController.EmailConfirmationSectionTitle",
                nil, [NSBundle mainBundle], @"Email Confirmation?",
                @"Title to be displayed on the 'email confirmation' section.") : nil;
    default:
      return nil;
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  } else if ([pIndexPath section] == 3) {
    [(ATGCheckoutShippingMethodTableViewCell *) pCell setShippingMethod:[[self order] shippingMethod]];
    [(ATGCheckoutShippingMethodTableViewCell *) pCell setPrice:self.order.priceInfo.shipping];
  } else if ([pIndexPath section] == 4) {
    [self emailText].text = [self email];
  }
}

- (NSIndexPath *)tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0 || [pIndexPath section] > 3) {
    // It's either order details section or email/button section.
    // Do not allow the user to select cells from it to prevent cells from expanding
    // or highlighting contents.
    return nil;
  }
  return pIndexPath;
}

- (UIView *)tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)pSection {
  NSString *title = [self tableView:pTableView titleForHeaderInSection:pSection];
  if (title) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label applyStyleWithName:@"headerLabel"];
    [label setText:title];
    [label setBackgroundColor:[[self tableView] backgroundColor]];
    return label;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)pTableView heightForHeaderInSection:(NSInteger)pSection {
  if ([self tableView:pTableView titleForHeaderInSection:pSection]) {
    return 33;
  } else {
    return 0;
  }
}

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
  }
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  if ([pIndexPath section] == 1 && [self creditCardCell]) {
    if ([[[[self creditCardCell] detailTextLabel] text] length] > 0) {
      CGRect textFrame = [[[self creditCardCell] textLabel] frame];
      CGRect detailFrame = [[[self creditCardCell] detailTextLabel] frame];
      return detailFrame.origin.y - textFrame.origin.y + detailFrame.size.height + 20;
    } else {
      CGRect textFrame = [[[self creditCardCell] textLabel] frame];
      return textFrame.size.height + 20;
    }
  } else if ([pIndexPath section] == 2 && [self addressCell]) {
    CGRect textFrame = [[[self addressCell] textLabel] frame];
    CGRect detailFrame = [[[self addressCell] detailTextLabel] frame];
    return detailFrame.origin.y - textFrame.origin.y + detailFrame.size.height + 20;
  }
  return [pTableView rowHeight];
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  switch ([pIndexPath section]) {
    case 1:
      if (![[self navigationController]
            popToViewControllerWithClass:[ATGCheckoutCreditCardsController class] animated:YES]) {
        [[self navigationController]
            popToViewControllerWithClass:[ATGCheckoutCreditCardCreateController class] animated:YES];
      }
      break;
    case 2:
      if (![[self navigationController]
            popToViewControllerWithClass:[ATGShippingAddressesViewController class] animated:YES]) {
        [[self navigationController]
            popToViewControllerWithClass:[ATGShippingAddressEditController class] animated:YES];
      }
      break;
    case 3:
      [[self navigationController]
          popToViewControllerWithClass:[ATGCheckoutShippingMethodViewController class] animated:YES];
      break;
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [pTextField resignFirstResponder];
  [self didTouchPlaceOrderButton:nil];
  return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)pTextField {
  if (pTextField == [self emailText]) {
    [self setEmail:[self emailText].text];
  }
}

#pragma mark - ATGShoppingCartViewController

- (void)loadOrder {
  [self startActivityIndication:YES];
  [self setRequest:[[ATGCommerceManager commerceManager] getOrderSummaryForConfirmation:self]];
}

- (void) orderDidLoad:(ATGOrder *)pOrder {
  // Drop all errors previously set.
  [self setErrors:nil inSection:0];
  [self setErrors:nil inSection:2];

  [self.priceFormatter setCurrencyCode:pOrder.priceInfo.currencyCode];

  ATGCreditCard *creditCard = [pOrder creditCard];

  [self setCreditCardCell:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                 reuseIdentifier:nil]];
  [[[self creditCardCell] textLabel] applyStyleWithName:@"formTitleLabel"];
  [[[self creditCardCell] detailTextLabel] applyStyleWithName:@"formFieldLabel"];
  if ([pOrder.priceInfo.total compare:pOrder.storeCreditsAppliedTotal] == NSOrderedDescending) {
    [[[self creditCardCell] detailTextLabel] setNumberOfLines:0];
    [[[self creditCardCell] textLabel] setText:[creditCard details]];
    [[[self creditCardCell] detailTextLabel] setText:
     [NSString stringWithFormat:@"%@\n%@",
      [[creditCard billingAddress] contact], [[creditCard billingAddress] address]]];
    [[self creditCardCell] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[self creditCardCell] setAccessibilityTraits:UIAccessibilityTraitButton];
    [[self creditCardCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
        (@"ATGOrderReviewViewController.PaymentMethodAccessibilityHint", nil, [NSBundle mainBundle],
         @"Double tap to change credit card", @"Accessebility hint for change credit card button.")];
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGOrderReviewViewController.StoreCreditsTitle",
         nil, [NSBundle mainBundle], @"Payed with store credits",
         @"Title to be displayed instead of credit card details if the whole order was payed "
         @"with store credits.");
    [[[self creditCardCell] textLabel] setText:title];
    [[self creditCardCell] setAccessoryType:UITableViewCellAccessoryNone];
    [[self creditCardCell] setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
  [[self creditCardCell] layoutIfNeeded];
  [[self creditCardCell] setBackgroundColor:[UIColor tableCellBackgroundColor]];

  [self setAddressCell:[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:nil]];
  [[[self addressCell] textLabel] applyStyleWithName:@"formTitleLabel"];
  [[[self addressCell] detailTextLabel] applyStyleWithName:@"formFieldLabel"];
  [[[self addressCell] detailTextLabel] setNumberOfLines:0];
  [[[self addressCell] textLabel] setText:[[pOrder shippingAddress] contact]];
  [[[self addressCell] detailTextLabel] setText:[[pOrder shippingAddress] address]];
  [[self addressCell] layoutIfNeeded];
  [[self addressCell] setBackgroundColor:[UIColor tableCellBackgroundColor]];

  [super orderDidLoad:pOrder];
  [self setOrder:pOrder];

  [self handleSecurityStatus:[pOrder securityStatus]];
}

- (void) reloadData {
  //noop, overridden
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didGetOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self orderDidLoad:[pRequest requestResults]];
}

- (void)didErrorGettingOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self setRequest:nil];
}

- (void)didCommitOrder:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self setOrderID:[pRequest requestResults]];
  [self performSegueWithIdentifier:ATGSegueIdOrderReviewToOrderPlaced sender:self];
}

- (void)didErrorCommittingOrder:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];

  ATGButtonTableViewCell *cell;
  if ([self isUserAnonymous]) {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                              inSection:5]];
  } else {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                              inSection:4]];
  }
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGOrderReviewViewController.PlaceButtonTitle", nil, [NSBundle mainBundle],
       @"Place My Order", @"Title to be displayed on the Place button.");
  [[cell button] setTitle:title forState:UIControlStateNormal];
  [[cell button] setEnabled:YES];
}

- (void)didClaimCoupon:(ATGCommerceManagerRequest *)pRequest {
  // We will need this order instance later.
  ATGOrder *currentOrder = [self order];
  // Allow superclass to reload order total cell. This will also change the mOrder variable.
  [super didClaimCoupon:pRequest];
  // Restore the previous order, this is essential as the order returned from
  // 'claimCoupon' doesn't contain shipping/billing addresses and shipping method.
  [self setOrder:currentOrder];
  ATGOrder *newOrder = (ATGOrder *)[pRequest requestResults];
  // We've applied promotion, this means that prices may have changed.
  self.order.priceInfo = newOrder.priceInfo;

  [[self order] setCouponCode:[newOrder couponCode]];
  self.order.storeCreditsAppliedTotal = newOrder.storeCreditsAppliedTotal;
  
  [[self tableView] reloadData];
}

- (void)didErrorClaimingCoupon:(ATGCommerceManagerRequest *)pRequest {
  [super didErrorClaimingCoupon:pRequest];
}

#pragma mark - ATGAddressViewControllerDelegate

- (void)navigateOnSelection {
  [self.navigationController popViewControllerAnimated:YES];
  [self loadOrder];
}

#pragma mark - ATGLoginViewControllerDelegate

- (void) didLogin {
  [self loadOrder];
  [self dismissLoginViewControllerAnimated:YES];
}

#pragma mark - Private Protocol Implementation

- (void)didTouchPlaceOrderButton:(id)pSender {
  [self.emailText resignFirstResponder];
  if (![self isUserAnonymous]) {
    [self setEmail:[[[self order] email] copy]];
  }
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGCommerceManager commerceManager] commitOrder:[self email]
                                                            delegate:self]];
  ATGButtonTableViewCell *cell;
  if ([self isUserAnonymous]) {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                              inSection:5]];
  } else {
    cell = (ATGButtonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                              inSection:4]];
  }
  [[cell button] setTitle:NSLocalizedStringWithDefaultValue
      (@"ATGOrderReviewViewController.SubmittingTitleButton", nil, [NSBundle mainBundle], @"Submitting...",
       @"Title to be displayed on the button during submitting order.")
                 forState:UIControlStateNormal];
  [[cell button] setEnabled:NO];
}

- (void)handleSecurityStatus:(NSNumber *)pSecurityStatus {
  if (pSecurityStatus) {
    // make sure it's not nil
    BOOL oldUserAnonymous = [self isUserAnonymous];
    if ([pSecurityStatus compare:[NSNumber numberWithInteger:0]] == NSOrderedSame) {
      [self setUserAnonymous:YES];
    } else {
      [self setUserAnonymous:NO];
    }
    if ([self isUserAnonymous] && !oldUserAnonymous) {
      [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:4]
                      withRowAnimation:UITableViewRowAnimationRight];
    } else if (oldUserAnonymous && ![self isUserAnonymous]) {
      [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:4]
                      withRowAnimation:UITableViewRowAnimationRight];
    }
  }
}

@end

#pragma mark - ATGContactInfo Additions Implementation
#pragma mark -

@implementation ATGContactInfo (Address)

- (NSString *)contact {
  return [NSString stringWithFormat:@"%@ %@", [self firstName], [self lastName]];
}

- (NSString *)address {
  // Use the US postal address format. This will produce two lines of address.
  NSMutableString *result =
    [self address1] ? [NSMutableString stringWithString:[self address1]] : nil;
  if ([[self address2] length]) {
    // address2 may be not set, add it to result only if present.
    [result appendFormat:@" %@", [self address2]];
  }
  [result appendFormat:@", %@,", [self city]];
  if ([[self state] length]) {
    // state may be not set, add it to result only if present.
    [result appendFormat:@" %@,", [self state]];
  }
  [result appendFormat:@" %@ %@", [self postalCode], [self country]];
  return result;
}

@end

#pragma mark - ATGCreditCard Additions Implementation
#pragma mark -

@implementation ATGCreditCard (Details)

- (NSString *)details {
  NSString *detailsFormat = NSLocalizedStringWithDefaultValue
      (@"ATGOrderReviewViewController.CreditCardDetailsFormat", nil, [NSBundle mainBundle],
       @"%@ ...%@ Exp.%@/%@",
       @"Credit card details format to be used. The first token is the nickname of the card.\
       The second token is the last 4 digits of the card. \
       The third token is the Expiration Month and the the fourth token is the Expiration Year.");
  return [NSString stringWithFormat:detailsFormat, [self creditCardTypeDisplayName],
          [self maskedCreditCardNumber], [self expirationMonth], [self expirationYear]];
}

@end