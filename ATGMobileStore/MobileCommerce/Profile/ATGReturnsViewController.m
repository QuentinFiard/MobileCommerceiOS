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

#import "ATGReturnsViewController.h"
#import <ATGMobileClient/ATGReturnManager.h>
#import <ATGMobileClient/ATGReturnManagerRequest.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import "ATGReturnsTableViewCell.h"
#import "ATGReturnDetailsViewController.h"

static const NSInteger ATGTableCellHeightEmpty = 64;

@interface ATGReturnsViewController ()

#pragma mark - Custom Properties

@property (nonatomic, strong) NSArray *returns;
@property (nonatomic, strong) ATGReturnManagerRequest *request;
@property (nonatomic, readwrite, strong) UITableViewCell *emptyListCell;
@end

@implementation ATGReturnsViewController

@synthesize emptyListCell;

#pragma mark - UIViewController

- (void)loadView {
  [super loadView];
  self.title  = NSLocalizedStringWithDefaultValue(@"ATGReturnsViewController.Title", nil, [NSBundle mainBundle], @"My Returns", @"Title of Returns History view controller");
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.request = [[ATGReturnManager instance] getReturnHistoryWithStartIndex:@0 count:@25 success:^(ATGReturnManagerRequest *request, NSArray *results) {
    self.returns = results;

    if (self.returns.count == 0)
      [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self.tableView reloadData];
    
    if ([UIDevice isPad]) {
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    }
  } failure:^(ATGReturnManagerRequest *request, NSError *error) {
  
  }];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = ATGTableCellHeightEmpty;
  NSUInteger count = self.returns.count;
  if (count > 0)
    height = count * self.tableView.rowHeight + 20;

  return CGSizeMake(ATGPhoneScreenWidth, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.returns.count > 0)
    return self.returns.count;

  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.returns.count > 0) {
    ATGReturnsTableViewCell *cell = (ATGReturnsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ATGReturnCell"];
    [cell setObject:[self.returns objectAtIndex:indexPath.row]];
    return cell;
  }

  self.emptyListCell = [tableView dequeueReusableCellWithIdentifier:@"ATGEmptyReturnCell"];
  self.emptyListCell.backgroundColor = [UIColor tableCellBackgroundColor];
  UILabel *label = [self.emptyListCell.contentView.subviews objectAtIndex:0];
  label.text = NSLocalizedStringWithDefaultValue
    (@"ATGReturnsViewController.NoReturns", nil, [NSBundle mainBundle], @"You have no returns",
    @"Message rendered for returns view, when user have no returns");
  [label applyStyleWithName:@"smallProductTitleLabel"];
  return self.emptyListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]];
  ATGReturnDetailsViewController *returnDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ATGReturnDetailsViewController"];
  returnDetailsViewController.returnId = ((ATGReturnRequest *)[self.returns objectAtIndex:indexPath.row]).requestId;
  [self.navigationController pushViewController:returnDetailsViewController animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.returns.count > 0) {
    return tableView.rowHeight;
  }

  return ATGTableCellHeightEmpty;
}

@end
