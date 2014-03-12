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

#import "ATGGiftListSearchViewController.h"
#import "ATGGiftListSearchResultViewController.h"
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGGiftListManagerRequest.h>

@class ATGManagerRequest;

static NSString *const ATGSegueSearch = @"ATGGiftSearchSegue";

#pragma mark - ATGGiftListSearchViewController private interface declaration
#pragma mark -
@interface ATGGiftListSearchViewController () <ATGGiftListManagerDelegate>
#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;

#pragma mark - Custom properties
@property (nonatomic, strong) ATGManagerRequest *request;
@property (nonatomic, strong) NSArray *searchResults;

#pragma mark - Private methods
- (void) didSelectStartSearch;
@end

#pragma mark - ATGGiftListSearchViewController implementation
#pragma mark -
@implementation ATGGiftListSearchViewController

#pragma mark - Lifecycle
- (void) viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchViewController.Title",
                                                      nil, [NSBundle mainBundle], @"Find a Gift List",
                                                      @"Title to be displayed at the top of the screen which allow user to find gift list.");
  [self setTitle:title];

  title = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchViewController.Search",
                                            nil, [NSBundle mainBundle], @"Search",
                                            @"Title for button that will perform search.");

  UIBarButtonItem *confirmSearch = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(didSelectStartSearch)];
  confirmSearch.width = 320;
  self.toolbarItems = [NSArray arrayWithObject:confirmSearch];

  [[self firstNameInput] setLeftView:[self firstNameLabel]];
  self.firstNameInput.accessibilityLabel = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchViewController.FirstName.Input.Accessibility.Label", nil, [NSBundle mainBundle], @"First Name Input field, enter name you would like to search for", @"Explanation of fields use for entering the first name to search for");
  [[self firstNameInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self lastNameInput] setLeftView:[self lastNameLabel]];
  self.lastNameInput.accessibilityLabel = NSLocalizedStringWithDefaultValue(@"ATGGiftListSearchViewController.LastName.Input.Accessibility.Label", nil, [NSBundle mainBundle], @"Last Name Input field, enter last name you would like to search for", @"Explanation of fields use for entering the last name to search for");
  [[self lastNameInput] setLeftViewMode:UITextFieldViewModeAlways];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (CGSize) contentSizeForViewInPopover {
  return CGSizeMake(320, self.tableView.rowHeight *[self.tableView numberOfRowsInSection:0]);
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueSearch isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGGiftListSearchResultViewController *searchController = [pSegue destinationViewController];
    [searchController setSearchResult:[NSMutableArray arrayWithArray:[self searchResults]]];
  }
}

#pragma mark - Private methods
- (void) didSelectStartSearch {
  [self startActivityIndication:YES];
  [self setRequest:[[ATGGiftListManager instance] findGiftListsByFirstName:[self.firstNameInput text] lastName:[self.lastNameInput text] delegate:self]];
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return 2 + [self errorNumberOfRowsInSection:pSection];
  ;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  } else {
    return [pTableView rowHeight];
  }
}

- (void)  tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
  forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  pIndexPath = [self shiftIndexPath:pIndexPath];
}

#pragma mark - ATGGiftListManager delegate
- (void) giftListManagerDidFindGiftLists:(NSArray *)pGiftLists {
  [self stopActivityIndication];
  self.searchResults = pGiftLists;
  [self performSegueWithIdentifier:ATGSegueSearch sender:nil];
}

- (void) giftListManagerDidFailWithError:(NSError *)pError {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:pError inSection:0];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

@end