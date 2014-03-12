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

#import "ATGPickerTableViewController.h"
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGRestManager.h>

static NSString *ATGSkuCell = @"ATGSkuCell";
static NSString *ATGColorSkuCell = @"ATGColorSkuCell";

#pragma mark - ATGPickerViewController private protocol declaration
#pragma mark -
@interface ATGPickerTableViewController ()

#pragma mark - Custom properties
@property (nonatomic, assign) NSInteger selectedIndex;
@end

#pragma mark - ATGSkuPickerViewController implementation
@implementation ATGPickerTableViewController

- (id) initWithType:(NSString *)pType dataArray:(NSArray *)pDataArray delegate:(id<ATGPickerDelegate>)pDelegate {
  NSBundle *bundle = [NSBundle atgResourceBundle];
  self = [super initWithNibName:@"ATGPickerTableViewController" bundle:bundle];
  if (self) {
    self.type = pType;
    self.selectedIndex = -1;
    self.dataArray = pDataArray;
    self.delegate = pDelegate;
  }
  return self;
}

// make sure selectedIndex is set if we're setting a selectedValue
- (void) setSelectedValue:(NSString *)pSelectedValue {
  _selectedValue = pSelectedValue;
  if (self.selectedIndex < 0) {
    self.selectedIndex = [self.dataArray indexOfObject:pSelectedValue];
  }
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.title = self.type;
}

- (void) viewDidUnload {
  [super viewDidUnload];
}

- (CGSize) contentSizeForViewInPopover {
  return CGSizeMake(self.view.bounds.size.width + 40, ([self.dataArray count]) * 44);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [self.dataArray count];
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSString *cellIdentifier = ATGSkuCell;

  if ([self.imageArray count] != 0) {
    cellIdentifier = ATGColorSkuCell;
  }

  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];
  NSBundle *bundle = [NSBundle atgResourceBundle];

  if (!cell) {
    if ([self.imageArray count] == 0) {
      [self.tableView registerNib:[UINib nibWithNibName:@"ATGSkuCell_iPad" bundle:bundle] forCellReuseIdentifier:ATGSkuCell];
      cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];
      cell.accessibilityHint = NSLocalizedStringWithDefaultValue(
        @"ATGSKUPicker.SkuAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to select sku", @"sku picker accessibility hint.");
    } else {
      [self.tableView registerNib:[UINib nibWithNibName:@"ATGColorSkuCell_iPad" bundle:bundle] forCellReuseIdentifier:ATGColorSkuCell];
      cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];
      cell.accessibilityHint = NSLocalizedStringWithDefaultValue(
        @"ATGSKUPicker.SkuAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to select sku", @"sku picker accessibility hint.");
    }
  }

  UILabel *label = (UILabel *)[cell viewWithTag:4];
  label.text = [self.dataArray objectAtIndex:pIndexPath.row];

  if ([self.imageArray count] != 0) {
    ATGImageView *image = (ATGImageView *)[cell viewWithTag:3];
    image.imageURL = [ATGRestManager getAbsoluteImageString:[self.imageArray objectAtIndex:pIndexPath.row]];
  }
  
  UIView *checkmark = [cell viewWithTag:5];
  if (self.selectedIndex == pIndexPath.row) {
    [checkmark setHidden:NO];
  } else {
    [checkmark setHidden:YES];
  }

  return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  for (UITableViewCell *visibleCell in [pTableView visibleCells]) {
    [[visibleCell viewWithTag:5] setHidden:YES];
  }
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
  UIImageView *checkMark = (UIImageView *)[cell viewWithTag:5];
  checkMark.hidden = YES;
  cell.accessibilityTraits = UIAccessibilityTraitNone;

  self.selectedIndex = pIndexPath.row;

  cell = [self.tableView cellForRowAtIndexPath:pIndexPath];
  checkMark = (UIImageView *)[cell viewWithTag:5];
  checkMark.hidden = NO;
  [self.delegate didSelectValue:[self.dataArray objectAtIndex:self.selectedIndex] forType:self.type];

  [self.tableView deselectRowAtIndexPath:pIndexPath animated:NO];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return YES;
}

@end