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

#import "ATGStoreTableController.h"
#import "ATGStoreMapViewController.h"
#import <ATGMobileClient/ATGStoreManager.h>
#import <ATGMobileClient/ATGStoreManagerRequest.h>

#pragma mark - ATGStoreTableController private interface declaration
#pragma mark -

@interface ATGStoreTableController ()

// This array will contain all store instances to be displayed by this controller.
@property (nonatomic, strong) NSArray *allStores;
@property (nonatomic, strong) ATGStoreManagerRequest *currentRequest;
@property (nonatomic, strong) ATGStore *selection;

@end

#pragma mark - ATGStoreTableController Implementation
#pragma mark -

@implementation ATGStoreTableController
#pragma mark - Synthesized properties
@synthesize allStores, currentRequest, selection;

#pragma mark - UIViewController+ATGToolbar Category Implementation

+ (UIImage *) toolbarIcon {
  return [UIImage imageNamed:@"icon-locator"];
}

+ (NSString *) toolbarAccessibilityLabel {
  return NSLocalizedStringWithDefaultValue(@"ATGViewController.StoreLocatorAccessibilityLabel",
                                           nil, [NSBundle mainBundle],
                                           @"Store Locator",
                                           @"Store locator toolbar button accessibility label");
}

#pragma mark - ATGTableViewController

- (void) reloadData {
  // Fill in the table.
  [self startActivityIndication:NO];
  self.currentRequest = [[ATGStoreManager storeManager] getStores:self];
}

#pragma mark - Instance Management

- (void) dealloc {
  [self.currentRequest setDelegate:nil];
  [self.currentRequest cancelRequest];
}

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  [self setTitle:[[self class] toolbarAccessibilityLabel]];

  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [self reloadData];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [self.currentRequest setDelegate:nil];
  [self.currentRequest cancelRequest];
  self.currentRequest = nil;
  [super viewWillDisappear:pAnimated];
}

#pragma mark - UIPopoverController

- (CGSize) contentSizeForViewInPopover {
  NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
  NSInteger tableHeight = (numberOfRows - 1) * ATGStoreCellDeselectedHeight + ATGStoreCellSelectedHeight;
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  return CGSizeMake(320,  cell.frame.origin.y * 2 + tableHeight);
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Display all stores inside of a single section.
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView
  numberOfRowsInSection:(NSInteger)pSection {
  return [self.allStores count];
}

- (UITableViewCell *) tableView:(UITableView *)pTableView
          cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Identifier to be used when dequeuing from tableView.
  // The same identifier is specified in the NIB file defining
  // StoreTableViewCell custom cell.
  NSString *identifier = @"ATGStoreTableViewCell";
  ATGStoreTableViewCell *cell = (ATGStoreTableViewCell *)
                                [pTableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell.delegate) {
    [cell setDelegate:self];
  }
  return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
 forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // We're about to display a cell to the user. Update cell's store.
  // This will enable the cell to display proper data.
  ATGStoreTableViewCell *cellToDisplay = (ATGStoreTableViewCell *)pCell;
  [cellToDisplay setStore:[self.allStores objectAtIndex:[pIndexPath row]]];
}

- (NSIndexPath *) tableView:(UITableView *)pTableView
   willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
  if (![cell isSelected]) {
    // The cell is not selected yet. Let the controller to select it.
    return pIndexPath;
  } else {
    // The cell is already selected. Deselect it and tell the controller to update
    // its height.
    [pTableView beginUpdates];
    [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
    NSString *announcement = NSLocalizedStringWithDefaultValue
                               (@"ATGStoreTableController.AccessibilityAnnouncementButtonsDisappeared", nil,
                               [NSBundle mainBundle], @"Action buttons disappeared.",
                               @"Accessibility announcement to be used when buttons disappeared.");
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement);
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    [pTableView endUpdates];
    // Do not allow row selection.
    return nil;
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  // User just selected one of the stores. Tell the tableView to update cells height.
  [pTableView beginUpdates];
  [pTableView endUpdates];
  NSString *announcement = NSLocalizedStringWithDefaultValue
                             (@"ATGStoreTableController.AccessibilityAnnouncementButtonsAppeared", nil,
                             [NSBundle mainBundle], @"Action buttons appeared.",
                             @"Accessibility announcement to be used when buttons appeared.");
  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement);
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (CGFloat)    tableView:(UITableView *)pTableView
 heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Cells have different heights based on their selection.
  if ([[pTableView indexPathForSelectedRow] isEqual:pIndexPath]) {
    return ATGStoreCellSelectedHeight;
  } else {
    return ATGStoreCellDeselectedHeight;
  }
}

#pragma mark - ATGStoreTableViewCellDelegate

- (void) didTouchMapButton:(ATGStoreTableViewCell *)pCell {
  self.selection = pCell.store;
  [self performSegueWithIdentifier:@"storesToStoresMap" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  ATGStoreMapViewController *controller = segue.destinationViewController;
  [controller setStore:self.selection];
}

- (void) didTouchCallButton:(ATGStoreTableViewCell *)cell {
  NSString *phoneNumber = [[cell store] phoneNumber];
  phoneNumber = [phoneNumber stringByDeletingCharactersInSet:
                 [NSCharacterSet characterSetWithCharactersInString:@"() "]];
  // Compose a tel: URL.
  NSURL *phoneUrl = [NSURL URLWithString:[NSString
                                          stringWithFormat:@"tel:%@", phoneNumber]];
  // Open the URL, this will ask the user if a call should be placed.
  if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
    [[UIApplication sharedApplication] openURL:phoneUrl];
  } else {
    // If the device cannot place a call, display the phone number instead
    [self alertWithTitleOrNil:cell.store.name
             withMessageOrNil:cell.store.phoneNumber];
  }
}

- (void) didTouchMailButton:(ATGStoreTableViewCell *)cell {
  NSString *email = [[cell store] email];
  NSString *subject = NSLocalizedStringWithDefaultValue
                        (@"ATGStoreTableController.ContactUsEmailSubject", nil, [NSBundle mainBundle],
                        @"Contact Us", @"Email subject for the ContactUs mail");
  // Always escape the subject, cause it will be used as part of URL.
  subject = [subject stringByAddingPercentEscapes];
  // Compose mailto: URL.
  NSString *mailString = [NSString stringWithFormat:@"mailto:%@?subject=%@",
                          email, subject];
  NSURL *mailUrl = [NSURL URLWithString:mailString];
  // And open the URL (this will open Mail application).
  [[UIApplication sharedApplication] openURL:mailUrl];
}

#pragma mark - ATGStoreManagerDelegate

- (void) didGetStores:(ATGStoreManagerRequest *)pSearchResults {
  [self stopActivityIndication];
  // We have the stores loaded. Save it to be used by tableview's datasource.
  self.allStores = [pSearchResults stores];
  // And tell the tableview to reload data.
  [[self tableView] reloadData];
}

- (void) didErrorGettingStores:(ATGStoreManagerRequest *)pRequest {
  DebugLog(@"didErrorGettingStores");
  [self stopActivityIndication];
  self.currentRequest = nil;
}

@end