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

#import "ATGRelatedOrdersViewController.h"
#import "ATGOrderDetailsViewController.h"
#import "ATGReturnDetailsViewController.h"

@interface ATGRelatedOrdersViewController ()
@property (nonatomic, strong) NSArray *returns;
@property (nonatomic, strong) NSArray *exchanges;
@property (nonatomic, strong) NSArray *parents;
@property (nonatomic, assign) NSInteger returnsIndex;
@property (nonatomic, assign) NSInteger exchangesIndex;
@property (nonatomic, assign) NSInteger parentsIndex;
@end

@implementation ATGRelatedOrdersViewController

- (id)initWithReturns:(NSArray *)pReturns exchanges:(NSArray *)pExchanges parents:(NSArray *)pParents {
  self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
      self.returns = pReturns;
      self.exchanges = pExchanges;
      self.parents = pParents;
      self.returnsIndex = -1;
      self.parentsIndex = -1;
      self.exchangesIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  self.title = NSLocalizedStringWithDefaultValue(@"ATGRelatedOrdersViewController.Title", nil, [NSBundle mainBundle], @"Related Orders", @"Controller title for related orders");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSInteger sections = 0;
  if (self.returns.count > 0) {
    self.returnsIndex = sections;
    sections++;
  }
  if (self.exchanges.count > 0) {
    self.exchangesIndex = sections;
    sections++;
  }
  if (self.parents.count > 0) {
    self.parentsIndex = sections;
    sections++;
  }
  return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self sectionDataSourceForIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  
  NSArray *sectionDataSource = [self sectionDataSourceForIndex:indexPath.section];
  NSString *orderId = (NSString *)[sectionDataSource objectAtIndex:indexPath.row];
  cell.textLabel.text = orderId;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *sectionDataSource = [self sectionDataSourceForIndex:indexPath.section];
  NSString *orderId = (NSString *)[sectionDataSource objectAtIndex:indexPath.row];
  
  if (indexPath.section == self.returnsIndex) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]];
    ATGReturnDetailsViewController *returnDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ATGReturnDetailsViewController"];
    returnDetailsViewController.returnId = orderId;
    [self.navigationController pushViewController:returnDetailsViewController animated:YES];
  } else {
    ATGOrderDetailsViewController *controller = [[UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ATGOrderDetailsViewController"];
    controller.orderID = orderId;
    [self.navigationController pushViewController:controller animated:YES];
  }
  
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == self.returnsIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGRelatedOrdersViewController.ReturnsHeader", nil, [NSBundle mainBundle], @"Related Returns", @"Section header for related returns");
  } else if (section == self.exchangesIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGRelatedOrdersViewController.ExchangesHeader", nil, [NSBundle mainBundle], @"Related Exchanges", @"Section header for related exchanges");
  } else if (section == self.parentsIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGRelatedOrdersViewController.ParentOrderHeader", nil, [NSBundle mainBundle], @"Parent Order", @"Section header for related parent order");
  } else {
    return nil;
  }
}

- (NSArray *)sectionDataSourceForIndex:(NSInteger)section {
  if (self.returnsIndex == section) {
    return self.returns;
  } else if (self.exchangesIndex == section) {
    return self.exchanges;
  } else if (self.parentsIndex == section) {
    return self.parents;
  } else  {
    return nil;
  }
}

@end
