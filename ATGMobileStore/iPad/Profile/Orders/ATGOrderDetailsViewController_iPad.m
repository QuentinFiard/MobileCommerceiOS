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

#import "ATGOrderDetailsViewController_iPad.h"
#import "ATGOrderSubtotalsTableViewCell.h"
#import "ATGShippingMethodTableViewCell.h"
#import <ATGMobileClient/ATGCreditCardTableViewCell.h>
#import "ATGAddressTableViewCell.h"
#import "ATGOrderItemTableViewCell.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGRootViewController_iPad.h"

#pragma mark - ATGOrderDetailsViewController_iPad Private Protocol Definition
#pragma mark -

@interface ATGOrderDetailsViewController_iPad () <ATGProfileManagerDelegate>

#pragma mark - IB Outlets

// This label is not a part of view hierarchy by default, so make this property strong.
@property (nonatomic, readwrite, strong) IBOutlet UILabel *wrongOrderLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *currentRequest;
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) NSArray *orderItems;

#pragma mark - Private Protocol

- (void) viewOrderOnMainSite:(id)sender;

@end

#pragma mark - ATGOrderDetailsViewController_iPad Implementation
#pragma mark -

@implementation ATGOrderDetailsViewController_iPad

#pragma mark - Synthesized Properties

@synthesize orderID;
@synthesize orderItems;
@synthesize currentRequest;
@synthesize priceFormatter;
@synthesize wrongOrderLabel;

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  // Superclass declares an Edit button to be displayed at the right side. Remove it.
  [[self navigationItem] setRightBarButtonItem:nil];
  
  NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGOrderDetailsViewController.iPad.BadOrderMessage",
     nil, [NSBundle mainBundle], @"Orders that shipped to multiple addresses can only be viewed from the main site",
     @"Error message to be displayed to user when trying to inspect an order "
     @"shipped to multiple addresses.");
  [[self wrongOrderLabel] setText:title];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGOrderDetailsViewController.ScreenTitleFormat", nil, [NSBundle mainBundle],
                      @"Order: %@", @"Title format to be used on the screen.");
  [self setTitle:[NSString stringWithFormat:title, [self orderID]]];
  [[self navigationController] setToolbarHidden:YES];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  UIBarButtonItem *item = [[self toolbarItems] lastObject];
  [item setWidth:[[self view] bounds].size.width];
}

- (CGSize) contentSizeForViewInPopover {
  CGFloat width = ATGPhoneScreenWidth;
  CGFloat height = 10;
  if (![self order]) {
    return CGSizeMake(width, ATGPopoverMinHeight);
  }
  for (NSInteger section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; section++) {
    height += [[self tableView] sectionHeaderHeight] + [[self tableView] sectionFooterHeight];
    for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:section]; row++) {
      height += [self          tableView:[self tableView]
                 heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    }
  }
  return CGSizeMake(width, MAX(ATGPopoverMinHeight, height));
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Do not display 'Email Confirmation' and 'Place Order' cells. Order details only.
  return [self order] ? 3 : 0;
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

  default:
    return nil;
  }
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  switch (pSection) {
  case 0:
    return [[self orderItems] count] + 3;
    break;

  case 1:
    return 2;
    break;

  case 2:
    return 1;
    break;

  default:
    return 0;
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
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
    ATGAddressTableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
    [cell setObject:[self.order.shippingGroups objectAtIndex:0]];
    //[cell setAddress:[[self order] shippingAddress]];
    return cell;
  } else if ([pIndexPath section] == 1 && [pIndexPath row] == 1) {
    ATGShippingMethodTableViewCell *cell =
      [pTableView dequeueReusableCellWithIdentifier:@"ATGShippingMethodCell"];
    [cell setShippingMethod:[[self order] shippingMethod]];
    return cell;
  } else if ([pIndexPath section] == 2 && [[self order] creditCard]) {
    ATGCreditCardTableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGBillingCell"];
    [cell setCreditCard:[[self order] creditCard]];
    return cell;
  } else if ([pIndexPath section] == 2) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGBillingCreditsCell"];
    NSString *caption = NSLocalizedStringWithDefaultValue
                          (@"ATGOrderDetailsViewController.PaidWithStoreCreditsCaption",
                           nil, [NSBundle mainBundle], @"Paid with store credits",
                          @"Message to be displayed to user instead of credit card info if order paid with store credits.");
    [[cell textLabel] setText:caption];
    return cell;
  } else {
    return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForHeaderInSection:(NSInteger)pSection {
  return [pTableView sectionHeaderHeight];
}

- (CGFloat)tableView:(UITableView *)pTableView heightForFooterInSection:(NSInteger)pSection {
  return [pTableView sectionFooterHeight];
}

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0 && [pIndexPath row] == [[self orderItems] count] + 2) {
    ATGOrderSubtotalsTableViewCell *cell = (ATGOrderSubtotalsTableViewCell *)[self        tableView:pTableView
                                                                              cellForRowAtIndexPath:pIndexPath];
    return [cell bounds].size.height;
  } else if ([pIndexPath section] == 0) {
    return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
  } else if ([pIndexPath section] == 1 && [pIndexPath row] == 0) {
    ATGAddressTableViewCell *cell = (ATGAddressTableViewCell *)[self        tableView:pTableView
                                                                cellForRowAtIndexPath:pIndexPath];
    return [cell sizeThatFits:[[self tableView] bounds].size].height;
  } else if ([pIndexPath section] == 2 && [[self order] creditCard]) {
    ATGCreditCardTableViewCell *cell = (ATGCreditCardTableViewCell *)[self        tableView:pTableView
                                                                      cellForRowAtIndexPath:pIndexPath];
    return [cell sizeThatFits:[[self tableView] bounds].size].height;
  }
  return [[self tableView] rowHeight];
}

- (void)tableView:(UITableView *)pTableView
  willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  if ([self tableView:pTableView willSelectRowAtIndexPath:pIndexPath]) {
    [pCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
  } else {
    [pCell setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
}

- (NSIndexPath *)tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0 && [pIndexPath row] < [[self orderItems] count]) {
    ATGCommerceItem *item = [[self orderItems] objectAtIndex:[pIndexPath row]];
    if ([item isNavigableProduct]) {
      return pIndexPath;
    }
  }
  return nil;
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  ATGCommerceItem *item = [[self orderItems] objectAtIndex:[pIndexPath row]];
  NSArray *items = [[self order] acceptableCommerceItems];
  items = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id pEvaluatedObject,
                                                                                   NSDictionary *pBindings) {
    return [(ATGCommerceItem *) pEvaluatedObject isNavigableProduct];
  }]];
  [[ATGRootViewController_iPad rootViewController] displayDetailsForCommerceItem:item];
}

#pragma mark - ATGProfileManagerDelegate

- (void) didGetOrderDetails:(ATGProfileManagerRequest *)pRequestResults {
  [self orderDidLoad:[pRequestResults requestResults]];
  // If no order set, then orderDidLoad: method did not set it; this means that order is incorrect.
  // So no UI updates should be made.
  if ([self order]) {
    //[[self tableView] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
    //                withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    if (IS_IPAD) {
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    }
  } else {
    [[self wrongOrderLabel] setFrame:[[self tableView] bounds]];
    [[self wrongOrderLabel] setHidden:NO];
    [[self tableView] setBackgroundView:[self wrongOrderLabel]];
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGOrderDetailsViewController.ViewOrderOnMainSiteTitle",
         nil, [NSBundle mainBundle], @"View Order on the main site",
         @"Button title.");
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(viewOrderOnMainSite:)];
    [[self navigationController] setToolbarHidden:NO animated:YES];
    [self setToolbarItems:[NSArray arrayWithObject:item] animated:YES];
  }
}

- (void) didErrorGettingOrderDetails:(ATGProfileManagerRequest *)pRequestResults {
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequestResults error] localizedDescription]];
}

#pragma mark - ATGShoppingCartViewController_iPad

- (void) loadOrder {
  // This screen takes an order from profile manager, not commerce.
  [[self currentRequest] setDelegate:nil];
  [[self currentRequest] cancelRequest];
  [self setCurrentRequest:[[ATGExternalProfileManager profileManager] getOrderDetails:[self orderID]
                                                                     delegate:self]];
}

- (void) orderDidLoad:(ATGOrder *)pOrder {
  if ([[pOrder shippingGroupCount] integerValue] < 2) {
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
  NSString *finalUrl = [ATGUrlOrderDetail stringByAppendingString:[self orderID]];
  url = [url stringByAppendingString:[finalUrl stringByAddingPercentEscapes]];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end