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

#import "ATGGiftListSearchResultViewController.h"
#import "ATGGiftSearchResultCell.h"
#import "ATGGiftSearchResultHeaderCell.h"
#import "ATGGiftListItemsViewController.h"
#import "ATGRootViewController_iPad.h"

static NSString *const ATGSearchResultCell = @"ATGGiftSearchResultCell";
static NSString *const ATGSearchResultHeader = @"ATGGiftSearchResultHeader";
static NSString *const ATGSegueListItems = @"ATGDisplayListItems";
static NSString *const ATGEmptyResult = @"ATGEmptyResult";

#pragma mark - ATGGiftListSearchResultViewController private interface declaration
#pragma mark -
@interface ATGGiftListSearchResultViewController ()

#pragma mark - Custom properties
@property (nonatomic, weak) UIButton *selectedOption;
@property (nonatomic) ATGSearchResultCellViewType selectedType;
@property (nonatomic, strong) ATGGiftList *selectedGiftList;

#pragma mark - UI Actions
- (IBAction) didSelectSortList:(id)sender;

@end

#pragma mark - ATGGiftListSearchResultViewController implementation
#pragma mark -
@implementation ATGGiftListSearchResultViewController

#pragma mark - Lifecycle

- (void) viewDidLoad {
  [super viewDidLoad];
  NSString *title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.Title",
                                                      nil, [NSBundle mainBundle], @"Gift List Search Results",
                                                      @"Title to be displayed at the top of the screen which display search result for gift lists.");
  [self setTitle:title];
}

- (void)viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (CGSize) contentSizeForViewInPopover {
  NSInteger count = [self.tableView numberOfRowsInSection:0];
  if ([self.searchResult count] == 0) return CGSizeMake(740, 45);
  return CGSizeMake(740, (count - 1) * 45 + 35);
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueListItems isEqualToString:[pSegue identifier]]) {
    ATGGiftListItemsViewController *itemsController = [pSegue destinationViewController];
    [itemsController setGiftList:[self selectedGiftList]];
  }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)pSection {
  return [self.searchResult count] + 1;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *cell;
  if (pIndexPath.row == 0) {
    if ([self.searchResult count] == 0) {
      cell = [pTableView dequeueReusableCellWithIdentifier:ATGEmptyResult];
    } else {
      cell = [pTableView dequeueReusableCellWithIdentifier:ATGSearchResultHeader];
    }
  } else {
    cell = [pTableView dequeueReusableCellWithIdentifier:ATGSearchResultCell];
    [(ATGGiftSearchResultCell *) cell setGiftList:[self.searchResult objectAtIndex:pIndexPath.row - 1]];
  }

  return cell;
}

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ((pIndexPath.row == 0)&&([self.searchResult count] != 0)) return 35;
  return 45;
}

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (pIndexPath.row == 0) {
    if ([self.searchResult count] != 0) {
    ATGGiftSearchResultHeaderCell *cell = (ATGGiftSearchResultHeaderCell *)pCell;
    NSString *title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.NameTitle",
                                                        nil, [NSBundle mainBundle], @"Name",
                                                        @"Button title for name colon on gift search result view.");
    [cell.nameButton setTitle:title forState:UIControlStateNormal];
    title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.EventNameTitle",
                                              nil, [NSBundle mainBundle], @"Event: Name",
                                              @"Button title for event name colon on gift search result view.");
    [cell.eventNameButton setTitle:title forState:UIControlStateNormal];
    title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.EventTypeTitle",
                                              nil, [NSBundle mainBundle], @"Event: Type",
                                              @"Button title for event type colon on gift search result view.");
    [cell.eventTypeButton setTitle:title forState:UIControlStateNormal];
    title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.EventDateTitle",
                                              nil, [NSBundle mainBundle], @"Event: Date",
                                              @"Button title for event date colon on gift search result view.");
    [cell.eventDateButton setTitle:title forState:UIControlStateNormal];
    } else {
      UILabel *label = (UILabel*)[pCell viewWithTag:2];
      label.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchResultViewController.EmptyResult",
                                                     nil, [NSBundle mainBundle], @"No results found",
                                                     @"Message that will be displayed when search result was empty.");
    }
  }
  if (pIndexPath.row > 0) {
    ATGGiftSearchResultCell *cell = (ATGGiftSearchResultCell *)pCell;
    [cell setSelectedView:self.selectedType];
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [self.tableView deselectRowAtIndexPath:pIndexPath animated:NO];
  if (pIndexPath.row > 0) {
    ATGGiftList *giftList = [self.searchResult objectAtIndex:pIndexPath.row - 1];
    [self setSelectedGiftList:giftList];
    [[ATGRootViewController_iPad rootViewController] displayGiftlistControllerForGiftList:giftList allowsEditing:NO];
  }
}

#pragma mark - Private methods
- (IBAction) didSelectSortList:(id)pSender {
  [self.selectedOption setSelected:NO];
  self.selectedOption = pSender;
  [pSender setSelected:YES];
  ATGGiftSearchResultHeaderCell *cell = (ATGGiftSearchResultHeaderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  if (pSender == cell.nameButton) {
    self.selectedType = ATGNameView;
    [self.searchResult sortUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
       NSString *str1 = [(ATGGiftList *) obj1 firstName];
       NSString *str2 = [(ATGGiftList *) obj2 firstName];
       return [str1 compare:str2];
     }
    ];
  } else if (pSender == cell.eventNameButton) {
    self.selectedType = ATGEventNameView;
    [self.searchResult sortUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
       NSString *str1 = [(ATGGiftList *) obj1 name];
       NSString *str2 = [(ATGGiftList *) obj2 name];
       return [str1 compare:str2];
     }
    ];
  } else if (pSender == cell.eventTypeButton) {
    self.selectedType = ATGEventTypeView;
    [self.searchResult sortUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
       NSString *str1 = [(ATGGiftList *) obj1 type];
       NSString *str2 = [(ATGGiftList *) obj2 type];
       return [str1 compare:str2];
     }
    ];
  } else {
    self.selectedType = ATGEventDateView;
    [self.searchResult sortUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
       NSDate *str1 = [(ATGGiftList *) obj1 date];
       NSDate *str2 = [(ATGGiftList *) obj2 date];
       return [str1 compare:str2];
     }
    ];
  }
  [self.tableView reloadData];
}
@end