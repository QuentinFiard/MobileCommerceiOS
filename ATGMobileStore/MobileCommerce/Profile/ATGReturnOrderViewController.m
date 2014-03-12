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

#import "ATGReturnOrderViewController.h"
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGReturnManagerRequest.h>
#import <ATGMobileClient/ATGReturnManager.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGReturnShippingGroup.h>
#import <ATGMobileClient/ATGReturnItem.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import "ATGAddressTableViewCell.h"
#import "ATGOrderItemTableViewCell.h"
#import "ATGReturnsConfigurationTableViewCell.h"
#import "ATGReturnsActionCell.h"
#import "ATGReturnOrderConfirmViewController.h"

@interface ATGReturnOrderViewController ()
@property (nonatomic, readwrite, strong) ATGReturnRequest *returnRequest;
@property (nonatomic, readwrite, strong) ATGReturnManagerRequest *request;
@property (nonatomic, strong) ATGOrder *order;
@end

@implementation ATGReturnOrderViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // add a cancel button
  UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] init];
  cancelButton.title = NSLocalizedStringWithDefaultValue
    (@"ATGReturnOrderViewController.CancelButtonLabel", nil, [NSBundle mainBundle],
     @"Cancel", @"Title to be used on the cancel button.");
  [[self navigationItem] setRightBarButtonItem:cancelButton];
  [cancelButton setTarget:self];
  [cancelButton setAction:@selector(cancelReturn:)];
  
  // hide the back button
  self.navigationItem.hidesBackButton = TRUE;
  
  [[ATGReturnManager instance] getReturnReasonsWithSuccess:^(ATGReturnManagerRequest *request, NSArray *results) {
    [self.tableView reloadData];
  }failure:^(ATGReturnManagerRequest *request, NSError *error) {
    
  }];
}

- (void) setViewTitle {
  NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGReturnOrderViewController.ScreenTitleFormat", nil, [NSBundle mainBundle],
     @"Return Details", @"Title format to be used on the screen.");
  [self setTitle:[NSString stringWithFormat:title]];
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return self.returnRequest.shippingGroupList.count + 2; //One per shipping group, 1 for the Universal config, 1 for the continue button
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0 || section == self.returnRequest.shippingGroupList.count + 1) {
    return 1;
  }
  ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:section - 1];
  return shippingGroup.itemList.count + 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {

  return indexPath.section == self.returnRequest.shippingGroupList.count + 1 && [self shouldAllowReturn];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return ([self.returnRequest.universalReturn boolValue] ? 98 : 54);
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 1) {
    return  ([self shouldAllowReturn] ? 44.0 : 75.0);
  }
  if (indexPath.row == 0) {
    return 120.0;
  }
  
  ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1];
  ATGReturnItem *returnItem = [shippingGroup.itemList objectAtIndex:indexPath.row - 1];
  
  return (!returnItem.commerceItem.returnable ? 190.0 : 240.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    ATGReturnsConfigurationTableViewCell *cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnAllTableViewCell"];

    // if iOS 7, remove extra spacing between end of table header and beginning of first table cell (36 pts)
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
      for (UIView * subview in [cell.contentView subviews]){
        if ([subview isKindOfClass:[UITableView class]]){
          UITableView *returnAllTableView = subview;
          // remove extra padding in between header and first cell of table view
          returnAllTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
        }
      }
    }
    [cell setObject:self.returnRequest];
    return cell;
  } else if (indexPath.section == self.returnRequest.shippingGroupList.count + 1) {
    ATGReturnsActionCell *cell = (ATGReturnsActionCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnsActionCell"];
    [cell setObject:NSLocalizedStringWithDefaultValue(@"ATGReturnOrderViewController.Continue", nil, [NSBundle mainBundle], @"Continue", @"Title to be used on the Continue button to continue with return")];
    [cell prepareForReuse];
    
    if (![self shouldAllowReturn]) {
      [cell setErrorText:NSLocalizedStringWithDefaultValue(@"ATGReturnOrderViewController.Error", nil, [NSBundle mainBundle], @"At least one item must be configured with a return quantity and reason to continue", @"Reason for why the continue button is disabled")];
    }
    return cell;
  }
  if (indexPath.row == 0) {
    ATGAddressTableViewCell *cell = (ATGAddressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGShippingAddressCell"];
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1];
    [cell setObject: shippingGroup];
    return cell;
  } else {
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:indexPath.section - 1];
    ATGReturnItem *returnItem = [shippingGroup.itemList objectAtIndex:indexPath.row - 1];
    ATGOrderItemTableViewCell *cell;
    if (!returnItem.commerceItem.returnable) {
      cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderItemNonReturnableCell"]; 
    } else if (![self.returnRequest.universalReturn boolValue]) {
      cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderItemReturnConfigureCell"]; 
    } else {
      cell = (ATGOrderItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGOrderItemReturnConfigureImmutableCell"];
      returnItem.returnReasonDescription = self.returnRequest.universalReturnReason;
      returnItem.quantityToReturn = returnItem.commerceItem.qty;
    }
    [cell setObject:returnItem];
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  [[ATGReturnManager instance] startReturnWithRequest:self.returnRequest
                               success:^(ATGReturnManagerRequest *request, ATGReturnRequest *pReturnRequest) {
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]];
     ATGReturnOrderConfirmViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ATGReturnOrderConfirmViewController"];
     controller.returnRequest = pReturnRequest;
     controller.order = self.order;
     [self.navigationController pushViewController:controller animated:YES];
                             } failure:^(ATGReturnManagerRequest *request, NSError *error) {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                               [alertView show];

  }];
}

- (void)orderDidLoad:(ATGOrder *)pOrder {
  self.order = pOrder;
  if (!self.returnRequest) {
    self.returnRequest = [ATGReturnRequest returnRequestWithOrder:pOrder];
  }
  [[self tableView] reloadData];
}

- (BOOL)shouldAllowReturn {
  BOOL shouldAllowReturn = YES;
  BOOL aReturnableItem = NO;
  
  if (self.returnRequest.universalReturn && self.returnRequest.universalReturnReason) {
    return YES;
  }
  
  for (int i = 0; i < self.returnRequest.shippingGroupList.count && shouldAllowReturn; i++) {
    ATGReturnShippingGroup *shippingGroup = [self.returnRequest.shippingGroupList objectAtIndex:i];
    for (ATGReturnItem *retItem in shippingGroup.itemList) {
      if (([retItem.quantityToReturn integerValue] > 0 && retItem.returnReasonDescription.length < 1) || (retItem.returnReasonDescription.length > 0 && [retItem.quantityToReturn integerValue] < 1)) {
        shouldAllowReturn = NO;
      } else {
        if (retItem.returnReasonDescription.length > 0 && [retItem.quantityToReturn integerValue] > 0)
          aReturnableItem = YES;
      }
    }
  }
  return shouldAllowReturn && aReturnableItem;
}

- (IBAction)cancelReturn:(id)sender {
  [[self navigationController] popViewControllerAnimated:YES];
}

@end
