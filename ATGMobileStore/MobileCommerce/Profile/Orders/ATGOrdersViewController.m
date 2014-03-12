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

#import "ATGOrdersViewController.h"
#import "ATGOrdersTableViewCell.h"
#import "ATGOrderDetailsViewController.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

// How many orders should we load per request?
static const NSInteger ATGLoadOrdersPerRequest = 10;
static const NSInteger ATGTableCellHeightEmpty = 64;
static NSString *const ATGCellIdentifierEmptyCell = @"ATGOrdersTableEmptyCell";
static NSString *const ATGCellIdentifierOrderCell = @"ATGOrdersTableViewCell";

#pragma mark - ATGOrdersViewController Private Protocol
#pragma mark -

@interface ATGOrdersViewController () <ATGProfileManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) UITableViewCell *emptyListCell;
@property (nonatomic, readwrite, strong) NSMutableArray *orders;
@property (nonatomic, readwrite, assign) BOOL hasMoreOrders;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSDictionary *orderStatuses;
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *activityIndicator;

#pragma mark - Private Protocol Definition

- (void) loadNextOrders;

@end

#pragma mark - ATGOrdersViewController Implementation
#pragma mark -

@implementation ATGOrdersViewController

@synthesize emptyListCell;
@synthesize orders;
@synthesize hasMoreOrders;
@synthesize request;
@synthesize orderStatuses;
@synthesize activityIndicator;

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setOrders:[[NSMutableArray alloc] init]];
  [self setHasMoreOrders:YES];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGOrdersViewController.Title", nil, [NSBundle mainBundle], @"My Orders",
       @"Screen title to be displayed on the 'My Orders' screen.");
  [self setTitle:title];

  NSString *placed = NSLocalizedStringWithDefaultValue
      (@"ATGOrdersViewController.OrderStatusPlaced", nil, [NSBundle mainBundle],
       @"Order Placed", @"Order status description.");
  NSString *processing = NSLocalizedStringWithDefaultValue
      (@"ATGOrdersViewController.OrderStatusProcessing", nil, [NSBundle mainBundle],
       @"Order Processing", @"Order status description.");
  NSString *shipped = NSLocalizedStringWithDefaultValue
      (@"ATGOrdersViewController.OrderStatusShipped", nil, [NSBundle mainBundle],
       @"Order Shipped", @"Order status description.");
  NSString *cancelled = NSLocalizedStringWithDefaultValue
      (@"ATGOrdersViewController.OrderStatusCancelled", nil, [NSBundle mainBundle],
       @"Order Cancelled", @"Order status description.");
  [self setOrderStatuses:[[NSDictionary alloc] initWithObjectsAndKeys:placed, @"SUBMITTED",
                    processing, @"PROCESSING", processing, @"SAP_ACKNOWLEDGED",
                    processing, @"PENDING_FULFILLMENT", shipped, @"NO_PENDING_ACTION",
                    cancelled, @"PENDING_REMOVE", cancelled, @"REMOVED", nil]];

  UIActivityIndicatorView *spinner =
      [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [spinner setHidesWhenStopped:YES];
  CGRect bounds = [[self view] bounds];
  CGPoint center = CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) );
  [spinner setCenter:center];
  [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleTopMargin |
                               UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleBottomMargin];
  [[self tableView] setBackgroundView:spinner];
  [self setActivityIndicator:spinner];

  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
}

- (void)viewDidUnload {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  if ([[self orders] count] == 0) {
    [self loadNextOrders];
  }
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = ATGTableCellHeightEmpty;
  NSUInteger count = [[self orders] count];
  if (count > 0) {
    height = count * [[self tableView] rowHeight] + 20;
  }

  return CGSizeMake(ATGPhoneScreenWidth, height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSender isKindOfClass:[ATGOrdersTableViewCell class]]) {
    ATGOrderDetailsViewController *controller =
      (ATGOrderDetailsViewController *)[pSegue destinationViewController];
    NSString *orderId = [(ATGOrdersTableViewCell *)pSender orderId];
    [controller setOrderID:orderId];
  } else {
    ATGOrderDetailsViewController *controller = pSegue.destinationViewController;
    controller.orderID = pSender;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if ([[self orders] count] > 0) {
    return [[self orders] count];
  }

  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSUInteger count = [[self orders] count];
  if (count == 0) {
    self.emptyListCell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierEmptyCell];
    self.emptyListCell.backgroundColor = [UIColor tableCellBackgroundColor];
    UILabel *label = [self.emptyListCell.contentView.subviews objectAtIndex:0];
    label.text = NSLocalizedStringWithDefaultValue
        (@"ATGOrdersViewController.NoOrders", nil, [NSBundle mainBundle], @"You have no orders",
         @"Message rendered for orders view, when user have no orders");
    [label applyStyleWithName:@"smallProductTitleLabel"];
    self.emptyListCell.hidden = YES;
    return self.emptyListCell;
  }

  // We're using dynamic prototypes here, so deque method will never return nil.
  return [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierOrderCell];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  NSUInteger count = [[self orders] count];
  if (count > 0) {
    // Update the cell to be displayed with all proper order property values.
    ATGOrder *order = [[self orders] objectAtIndex:[pIndexPath row]];
    ATGOrdersTableViewCell *cell = (ATGOrdersTableViewCell *)pCell;
    [cell setObject:order];
    cell.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGOrdersViewController.OrderCell.Accessibility.Hint", nil, [NSBundle mainBundle], @"Order details", @"Hint for clicking on the order cells");
    [cell setNeedsLayout];
    if ([self hasMoreOrders] && [[self orders] count] - [pIndexPath row] < ATGLoadOrdersPerRequest / 2) {
      // We're close enough to the end of the list, and there are orders to be loaded.
      // Load them now.
      [self loadNextOrders];
    }
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger count = [[self orders] count];
  if (count > 0) {
    return tableView.rowHeight;
  }

  return ATGTableCellHeightEmpty;
}

#pragma mark - ATGProfileManagerDelegate

- (void)didGetOrdersStartingAt:(ATGProfileManagerRequest *)pRequestResults {
  [[self activityIndicator] stopAnimating];
  // Here are newly loaded orders.
  NSMutableArray *newOrders = [NSMutableArray arrayWithArray:(NSArray *)[pRequestResults requestResults]];

  //we can retrieve NULL object in result array. We want to delete them before processing to updating table view.
  [newOrders removeObjectIdenticalTo:[NSNull null]];

  if ([newOrders count] > 0) {
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    // Insert new orders with a single animation.
    [[self tableView] beginUpdates];
    // Construct array with index pathes for new cells.
    // These cells will be added at the end of the existing array.
    NSMutableArray *newCellIndices = [[NSMutableArray alloc] init];
    for (NSInteger i = [[self orders] count]; i < [[self orders] count] + [newOrders count]; i++) {
      [newCellIndices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    // Update inner container, this will be used by the table view datasource.

    //If orders array is empty, than we have one cell with message about empty list - remove it
    if ([[self orders] count] == 0) {
      [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                                           inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }

    [[self orders] addObjectsFromArray:newOrders];
    [[self tableView] insertRowsAtIndexPaths:newCellIndices
                            withRowAnimation:UITableViewRowAnimationRight];
    [[self tableView] endUpdates];
  }
  if ([newOrders count] == 0) {
    [self.emptyListCell setHidden:NO];
  }
  if ([newOrders count] < ATGLoadOrdersPerRequest) {
    [self setHasMoreOrders:NO];
  }
  [self setRequest:nil];
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (void) didErrorGettingOrdersStartingAt:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

#pragma mark - Private Protocol Implementation

- (void)loadNextOrders {
  if ([self request] && ![[self request] done]) {
    // There is a request in progress.
    // Do not make new requests while this one is not finished.
    return;
  }
  if ([[self orders] count] == 0) {
    [[self activityIndicator] startAnimating];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  }
  NSNumber *startWith = [NSNumber numberWithInteger:[[self orders] count] + 1];
  NSNumber *howMany = [NSNumber numberWithInteger:ATGLoadOrdersPerRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] getOrdersStartingAt:startWith
                                                                 andReturn:howMany
                                                                  delegate:self]];
}

@end