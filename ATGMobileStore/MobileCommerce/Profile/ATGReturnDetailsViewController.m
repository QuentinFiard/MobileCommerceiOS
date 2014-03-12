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

#import "ATGReturnDetailsViewController.h"
#import <ATGMobileClient/ATGReturnManager.h>
#import <ATGMobileClient/ATGReturnManagerRequest.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGReturnShippingGroup.h>
#import <ATGMobileClient/ATGReturnItem.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGProductPage.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>

#import "ATGReturnPlacedCell.h"
#import "ATGOrderItemTableViewCell.h"
#import "ATGAddressTableViewCell.h"
#import "ATGReturnSummaryTableViewCell.h"
#import "ATGOrderSummaryTableViewCell.h"

@interface ATGReturnDetailsViewController () <ATGProfileManagerDelegate>
@property (nonatomic, strong) ATGReturnManagerRequest *returnManagerRequest;
@property (nonatomic, strong) ATGReturnRequest *returnRequest;
@property (nonatomic, strong) ATGOrder *order;
@end

@implementation ATGReturnDetailsViewController


- (void)didGetOrderDetails:(ATGProfileManagerRequest *)pRequestResults {
  [self orderDidLoad:[pRequestResults requestResults]];
  [self.tableView reloadData];
  if (IS_IPAD) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (void)orderDidLoad:(ATGOrder *)pOrder {
  [self setOrder:pOrder];
  [[self tableView] reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.returnRequest.shippingGroupList.count + 3; //One for each shipping group, one for the return placed cell, one for the return summary cell, and one for the order summary cell
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (section == 0 || section == self.returnRequest.shippingGroupList.count + 1 || section == self.returnRequest.shippingGroupList.count + 2 ? 1 : ((ATGReturnShippingGroup *)[self.returnRequest.shippingGroupList objectAtIndex:section - 1]).itemList.count + 1); //Add one to the shippingGroupList count for the address
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    ATGReturnPlacedCell *cell = (ATGReturnPlacedCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnPlacedCell"];
    [cell setObject:self.returnRequest];
    return cell;
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 1) {
    static NSString *CellIdentifier = @"ReturnSummaryCell";
    ATGReturnSummaryTableViewCell *cell = (ATGReturnSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
      cell = [[ATGReturnSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setObject:self.returnRequest];
    return cell;
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 2) {
    static NSString *CellIdentifier = @"OrderSummaryCell";
    ATGOrderSummaryTableViewCell *cell = (ATGOrderSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
      cell = [[ATGOrderSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setObject:self.order];
    return cell;
  }
  if (indexPath.row == 0) {
    ATGAddressTableViewCell *cell = (ATGAddressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
    [cell setObject:[self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1]];
    return cell;
  } else {
    ATGOrderItemTableViewCell *cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnItemCell"];
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1];
    ATGReturnItem *item = [shippingGroup.itemList objectAtIndex:indexPath.row - 1];
    [cell setObject:item];
    return cell;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 80.0;
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 1) {
    return [ATGReturnSummaryTableViewCell heightForReturnSummaryWithReturnRequest:self.returnRequest];
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 2) {
    return [ATGOrderSummaryTableViewCell heightForOrder:self.order];
  } else {
    if (indexPath.row == 0) {
      return 120.0;
    } else {
      return 140.0;
    }
  }
}


#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section <= self.returnRequest.shippingGroupList.count && indexPath.section != 0 && indexPath.row != 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1];
  ATGReturnItem *returnItem = [shippingGroup.itemList objectAtIndex:indexPath.row - 1];
  ATGCommerceItem *commerceItem = returnItem.commerceItem;
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

- (void)setReturnId:(NSString *)returnId {
  _returnId = returnId;
  self.title = NSLocalizedStringWithDefaultValue(@"ATGReturnDetailsViewController.Title", nil, [NSBundle mainBundle], @"Return:", @"Return view controller title");
  self.title = [self.title stringByAppendingFormat:@" [%@]", returnId];
  
  self.returnManagerRequest = [[ATGReturnManager instance] getDetailsForReturnId:self.returnId success:^(ATGReturnManagerRequest *request, ATGReturnRequest *result){
    self.returnRequest = result;
    [[ATGExternalProfileManager profileManager] getOrderDetails:self.returnRequest.orderId
                                                       delegate:self];
    [self.tableView reloadData];
  } failure:^(ATGReturnManagerRequest *request, NSError *error) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
  }];
}

@end
