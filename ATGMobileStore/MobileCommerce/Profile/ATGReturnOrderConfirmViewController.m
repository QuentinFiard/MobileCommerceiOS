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

#import "ATGReturnOrderConfirmViewController.h"
#import <ATGMobileClient/ATGReturnManager.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGReturnShippingGroup.h>
#import <ATGMobileClient/ATGReturnItem.h>
#import <ATGMobileClient/ATGOrder.h>
#import "ATGReturnsActionCell.h"
#import "ATGAddressTableViewCell.h"
#import "ATGOrderItemTableViewCell.h"
#import "ATGReturnSummaryTableViewCell.h"
#import "ATGOrderSummaryTableViewCell.h"
#import "ATGReturnSuccessViewController.h"

@interface ATGReturnOrderConfirmViewController () <UIAlertViewDelegate>
@property (nonatomic, readwrite, strong) ATGReturnRequest *returnRequest;
@end

@implementation ATGReturnOrderConfirmViewController

- (void)viewWillAppear:(BOOL)animated {
  //Explicitly NOT call load order
  
  // set the screen's title
  [self setViewTitle];
  
  // add a modify return button
  UIBarButtonItem* modifyButton = [[UIBarButtonItem alloc] init];
  modifyButton.title = NSLocalizedStringWithDefaultValue
    (@"ATGReturnOrderConfirmViewController.ModifyButtonLabel", nil, [NSBundle mainBundle],
     @"Modify", @"Title to be used on the modify return order button.");
  [[self navigationItem] setLeftBarButtonItem:modifyButton];
  [modifyButton setTarget:self];
  [modifyButton setAction:@selector(modifyReturn:)];
  
  // add a cancel button
  UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] init];
  cancelButton.title = NSLocalizedStringWithDefaultValue
    (@"ATGReturnOrderConfirmViewController.CancelButtonLabel", nil, [NSBundle mainBundle],
     @"Cancel", @"Title to be used on the cancel return order button.");
  [[self navigationItem] setRightBarButtonItem:cancelButton];
  [cancelButton setTarget:self];
  [cancelButton setAction:@selector(cancelReturn:)];
}

- (void) setViewTitle {
  NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGReturnOrderConfirmViewController.ScreenTitleFormat", nil, [NSBundle mainBundle],
     @"Return Confirmation", @"Title format to be used on the screen.");
  [self setTitle:[NSString stringWithFormat:title]];
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return self.returnRequest.shippingGroupList.count + 3; //One per shipping group, 1 for the place button, 1 for the  return summary cell, 1 for the order summary cell
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section >= self.returnRequest.shippingGroupList.count) { // 1 row for place, 1 row for summaries
    return 1;
  }
  ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:section];
  return shippingGroup.itemList.count + 1; //+1 here for the address row
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.section == self.returnRequest.shippingGroupList.count ? YES : NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == self.returnRequest.shippingGroupList.count) { //Place Order Row
    return 44.0;
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 1) { //Summary Row
    return [ATGReturnSummaryTableViewCell heightForReturnSummaryWithReturnRequest:self.returnRequest];
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 2) { //Summary Row
    return [ATGOrderSummaryTableViewCell heightForOrder:self.order];
  }
  if (indexPath.row == 0) {
    return 120.0; //Address Cell
  }
  return 130.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == self.returnRequest.shippingGroupList.count) {
    ATGReturnsActionCell *cell = (ATGReturnsActionCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnsActionCell"];
    [cell setObject:@"Place Return"];
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
    static NSString *CellIdentifier = @"OrderReturnSummaryCell";
    ATGOrderSummaryTableViewCell *cell = (ATGOrderSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
      cell = [[ATGOrderSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setObject:self.order];
    return cell;
  }
  if (indexPath.row == 0) {
    ATGAddressTableViewCell *cell = (ATGAddressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section];
    [cell setObject: shippingGroup];
    return cell;
  } else {
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section];
    ATGReturnItem *returnItem = [shippingGroup.itemList objectAtIndex:indexPath.row - 1]; // -1 for address cell
    ATGOrderItemTableViewCell *cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderItemReturnConfirmCell"];
    [cell setObject:returnItem];
    return cell;
  }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == self.returnRequest.shippingGroupList.count) {
    [[ATGReturnManager instance] confirmReturnWithSuccess:^(ATGReturnManagerRequest *request, NSString *returnRequestId) {
      UIStoryboard *storyB = [UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]];
      ATGReturnSuccessViewController *viewController = [storyB instantiateViewControllerWithIdentifier:@"ATGReturnSuccessController"];
      self.returnRequest.requestId = returnRequestId;
      viewController.returnRequst = self.returnRequest;
      [self.navigationController pushViewController:viewController animated:YES];
    } failure:^(ATGReturnManagerRequest *request, NSError *error) {

    }];
  }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 [self.navigationController popToRootViewControllerAnimated:YES];
}

- (CGSize)contentSizeForViewInPopover {
  if (!self.returnRequest) {
    return CGSizeMake(320, 200);
  }
  return self.tableView.contentSize;
}

- (IBAction)modifyReturn:(id)sender {
  [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)cancelReturn:(id)sender {
  NSUInteger viewControllerIndex = self.navigationController.viewControllers.count - 1;
  // The order details view is two views before the current one
  [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:viewControllerIndex - 2] animated:YES];
}

@end
