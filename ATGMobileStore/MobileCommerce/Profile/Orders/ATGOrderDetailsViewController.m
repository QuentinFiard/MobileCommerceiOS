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

#import "ATGOrderDetailsViewController.h"
#import <ATGMobileClient/ATGProductPage.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import "ATGOrderPlacedCell.h"
#import "ATGAddressTableViewCell.h"
#import "ATGOrderItemTableViewCell.h"
#import "ATGOrderSummaryTableViewCell.h"
#import "ATGReturnsActionCell.h"
#import "ATGRelatedOrdersViewController.h"
#import "ATGReturnOrderViewController.h"

static NSString *const ATGOrderDetailsToProductSegue = @"orderDetailsToProduct";

#define ATGOrderDetailsTableViewSectionOrderPlaced 0
#define ATGOrderDetailsTableViewSectionOrderSummary [self.order.shippingGroupCount integerValue] + 1

typedef enum  {
  ATGOrderDetailsTableViewRowShippingMethod = 0,
  ATGOrderDetailsTableViewRowProduct
} ATGOrderDetailsTableViewRow;

#pragma mark - ATGOrderDetailsViewController Private Protocol
#pragma mark -

@interface ATGOrderDetailsViewController () <ATGProfileManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGOrder *order;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
// Implemented by superclass.
@property (nonatomic, readwrite, strong) UITableViewCell *creditCardCell;

#pragma mark - ATGOrderDetailsViewController Implementation
#pragma mark -

@end
@implementation ATGOrderDetailsViewController

@synthesize orderID;
@synthesize order;
@synthesize request;

#pragma mark - UIViewController

- (void)loadView {
  [super loadView];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [self setViewTitle];
  [self loadOrder];
}

- (void) setViewTitle {
  NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGOrderDetailsViewController.ScreenTitleFormat", nil, [NSBundle mainBundle],
     @"Order: %@", @"Title format to be used on the screen.");
  [self setTitle:[NSString stringWithFormat:title, [self orderID]]];

}

- (CGSize)contentSizeForViewInPopover {
  if (!self.order) {
    return CGSizeMake(320, 200);
  }
  return self.tableView.contentSize;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return [self.order.shippingGroupCount integerValue] + 2; //Order placed Cell, with button to start return, one section per shipping group, and 1 summary section.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == ATGOrderDetailsTableViewSectionOrderPlaced) {
    return (self.order.returnable  || self.order.returnRequests.count > 0  || self.order.parentOrderId ? 2 : 1);
  } else if (section ==ATGOrderDetailsTableViewSectionOrderSummary) {
    return 1;
  } else {
    ATGHardgoodShippingGroup *shippingGroup = [self.order.shippingGroups objectAtIndex:section - 1];
    return shippingGroup.commerceItems.count + 1; //Add 1 for the Shipping address row.
  }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ATGOrderDetailsTableViewSectionOrderPlaced) {
    return indexPath.row > 0;
  } else if (indexPath.section == ATGOrderDetailsTableViewSectionOrderSummary) {
    return NO;
  } else {
    if (indexPath.row > ATGOrderDetailsTableViewRowShippingMethod) {
      ATGHardgoodShippingGroup *shippingGroup = [self.order.shippingGroups objectAtIndex:indexPath.section - 1];
      ATGCommerceItem *commerceItem = [shippingGroup.commerceItems objectAtIndex:indexPath.row - 1];
      return commerceItem.isNavigableProduct;
    }
    return NO;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ATGOrderDetailsTableViewSectionOrderPlaced) {
    if (indexPath.row > 0) {
      return 44.0;
    }
    return 100.0;
  } else if (indexPath.section == ATGOrderDetailsTableViewSectionOrderSummary) {
    return [ATGOrderSummaryTableViewCell heightForOrder:self.order];
  } else {
    if (indexPath.row == ATGOrderDetailsTableViewRowShippingMethod) {
      return 121.0;
    } else {
      return 125.0;
    }
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ATGOrderDetailsTableViewSectionOrderPlaced) {
    //Order Placed Section
    if (indexPath.row > 0) {
      ATGReturnsActionCell *cell = (ATGReturnsActionCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnsActionCell"];
      if (self.order.returnable)
        [cell setObject:NSLocalizedStringWithDefaultValue(@"ATGOrderDetailsViewController.StartReturn.Title", nil, [NSBundle mainBundle], @"Start Return", @"Text for cell which is clicked to start a return")]; //Todo: this should either be start return, or see related
      else
        [cell setObject:NSLocalizedStringWithDefaultValue(@"ATGOrderDetailsViewController.RelatedOrders.Title", nil, [NSBundle mainBundle], @"Related Orders", @"Text for cell which is clicked to view related orders")];
      return cell;
    }
    ATGOrderPlacedCell *cell = (ATGOrderPlacedCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderPlacedCell"];
    [cell setObject:self.order];
    return cell;
  } else if (indexPath.section == ATGOrderDetailsTableViewSectionOrderSummary) {
    ATGOrderSummaryTableViewCell *cell = (ATGOrderSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SummaryCell"];
    if (!cell) {
      cell = [[ATGOrderSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SummaryCell"];
    }
    [cell setObject:self.order];
    return cell;
  } else {
    if (indexPath.row == ATGOrderDetailsTableViewRowShippingMethod) {
      ATGAddressTableViewCell *cell = (ATGAddressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
      ATGHardgoodShippingGroup *shippingGroup = [self.order.shippingGroups objectAtIndex:indexPath.section - 1];
      [cell setObject: shippingGroup];
      return cell;
    } else {
      ATGOrderItemTableViewCell *cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderItemCell"];
      ATGHardgoodShippingGroup *shippingGroup = [self.order.shippingGroups objectAtIndex:indexPath.section - 1];
      ATGCommerceItem *commerceItem = [shippingGroup.commerceItems objectAtIndex:indexPath.row - 1];
      [cell setObject:commerceItem];
      return cell;
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == ATGOrderDetailsTableViewSectionOrderPlaced) {
    if (self.order.returnable) {
      ATGReturnOrderViewController *controller = [[UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ATGReturnOrderViewController"];
      controller.order = self.order;
      controller.orderID = self.orderID;
      [self.navigationController pushViewController:controller animated:YES];
    } else {
      NSMutableArray *exchages = [NSMutableArray arrayWithCapacity:0], *returns = [NSMutableArray arrayWithCapacity:0];
      for (ATGReturnRequest *returnRequest in self.order.returnRequests) {
        if (returnRequest.requestId) {
          [returns addObject:returnRequest.requestId];
        }
        if (returnRequest.replacementOrderId) {
          [exchages addObject:returnRequest.replacementOrderId];
        }
      }      
      ATGRelatedOrdersViewController *controller = [[ATGRelatedOrdersViewController alloc] initWithReturns:[NSArray arrayWithArray:returns] exchanges:[NSArray arrayWithArray:exchages] parents:(self.order.parentOrderId ? [NSArray arrayWithObject:self.order.parentOrderId] : nil)];
      [self.navigationController pushViewController:controller animated:YES];
    }
  } else {
    ATGHardgoodShippingGroup *shippingGroup = [self.order.shippingGroups objectAtIndex:indexPath.section - 1];
    ATGCommerceItem *commerceItem = [shippingGroup.commerceItems objectAtIndex:indexPath.row - 1];
    if (!commerceItem.isNavigableProduct) {
      return;
    }
    if (IS_IPAD) {
      [[ATGRootViewController_iPad rootViewController] displayDetailsForCommerceItem:commerceItem fromOrderHistory:YES];
    } else {
      UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MobileCommerce_iPhone" bundle:[NSBundle mainBundle]];
      ATGProductPage *productPage = [storyBoard instantiateViewControllerWithIdentifier:@"ATGProductPage"];
      productPage.productId = commerceItem.prodId;
      productPage.productTitle = commerceItem.sku.displayName;
      [self.navigationController pushViewController:productPage animated:YES];
    }
  }
}

#pragma mark - UITableViewDelegate


#pragma mark - ATGProfileManagerDelegate

- (void)didGetOrderDetails:(ATGProfileManagerRequest *)pRequestResults {
  //[self stopActivityIndication];
  [self orderDidLoad:[pRequestResults requestResults]];
  [self.tableView reloadData];
  if (IS_IPAD) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (void)didErrorGettingOrderDetails:(ATGProfileManagerRequest *)pRequestResults {
  //[self stopActivityIndication];
  [self setRequest:nil];
}

#pragma mark - ATGShoppingCartViewController

- (void)loadOrder {
  // This screen takes an order from profile manager, not commerce.
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  //[self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getOrderDetails:[self orderID]
                                                              delegate:self]];
}

- (void)orderDidLoad:(ATGOrder *)pOrder {
  [self setOrder:pOrder];
  [[self tableView] reloadData];
}

@end