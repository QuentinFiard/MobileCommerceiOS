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
 * </ORACLECOPYRIGHT>*/

#import "ATGGiftListStartViewController.h"
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGGiftListManagerRequest.h>

static NSString *const ATGListSegue = @"ATGStartToList";
static NSString *const ATGCreateSegue = @"ATGStartToCreate";
static NSString *const ATGGiftMenuCell = @"ATGGiftMenuCell";
static NSString *const ATGFindSegue = @"ATGStartToFind";

#pragma mark - ATGGiftListViewController private protocol declaration
#pragma mark -
@interface ATGGiftListStartViewController () <ATGGiftListManagerDelegate>

#pragma mark - Custom properties
@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) ATGManagerRequest *request;
@property (nonatomic, strong) NSDictionary *giftLists;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

#pragma mark - ATGGiftListViewController implementation
#pragma mark -
@implementation ATGGiftListStartViewController

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];
  [self setNumberFormatter:[[NSNumberFormatter alloc] init]];
  [[self numberFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - Lifecycle
- (void) viewDidLoad {
  [super viewDidLoad];
  self.badge = [[UILabel alloc] initWithFrame:CGRectZero];
  self.badge.textColor = [UIColor whiteColor];
  [self.badge setBackgroundColor:[UIColor dirtyBlueColor]];
  self.badge.font = [UIFont boldSystemFontOfSize:15];
  self.badge.textAlignment = NSTextAlignmentCenter;
  self.badge.clipsToBounds = YES;
  self.badge.layer.cornerRadius = 10;
  self.badge.text = @"0";
  self.badge.frame = CGRectMake(254, 12, 35, 20);
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self navigationController] setToolbarHidden:YES animated:NO];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGGiftListManager instance] getUserGiftListsForDelegate:self]];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverController

- (CGSize) contentSizeForViewInPopover {
  NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
  NSInteger tableHeight = numberOfRows * self.tableView.rowHeight;
  return CGSizeMake(320,  tableHeight);
}

#pragma mark - UITableViewController

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([self.giftLists count] == 0) {
    return 2;
  }
  return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATGGiftMenuCell forIndexPath:indexPath];

  return cell;
}

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  switch (pIndexPath.row) {
  case 0:
    pCell.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListController.FindListLabel", nil,
                                                             [NSBundle mainBundle], @"Find a Gift List",
                                                             @"Label text for 'find list' cell on gift list start screen");
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  pCell.textLabel.text;
    break;

  case 1:
    pCell.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListController.CreatedListLabel", nil,
                                                             [NSBundle mainBundle], @"Create a Gift List",
                                                             @"Label text for 'create list' cell on gift list start screen");
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  pCell.textLabel.text;
    break;

  case 2:
    [pCell.contentView addSubview:self.badge];
    pCell.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListController.EditListLabel", nil,
                                                             [NSBundle mainBundle], @"Edit a Gift List",
                                                             @"Label text for 'edit list' cell on gift list start screen");
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  [NSString stringWithFormat:@"%@, %@", pCell.textLabel.text, self.badge.text];
    break;
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (pIndexPath.row == 1) {
    [self performSegueWithIdentifier:ATGCreateSegue sender:nil];
  } else if (pIndexPath.row == 2) {
    [self performSegueWithIdentifier:ATGListSegue sender:nil];
  } else {
    [self performSegueWithIdentifier:ATGFindSegue sender:nil];
  }
}

#pragma mark - GiftListManager delegate

- (void) giftListManagerDidGetUserLists:(NSDictionary *)pGiftLists {
  [self stopActivityIndication];
  self.giftLists = pGiftLists;
  [self.badge setText:[NSString stringWithFormat:@"%i", [self.giftLists count]]];
  [self.tableView reloadData];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) giftListManagerDidFailWithError:(NSError *)pError {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

@end