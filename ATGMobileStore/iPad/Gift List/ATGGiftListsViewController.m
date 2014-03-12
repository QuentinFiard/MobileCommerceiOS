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

#import "ATGGiftListsViewController.h"
#import "ATGGiftListCreateViewController.h"
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGGiftListManagerRequest.h>

@class ATGManagerRequest;

static NSString *const ATGEventType = @"ATGGiftListCell";
static NSString *const ATGSegueEditGiftList = @"ATGListToEdit";
static NSString *const ATGSegueCreateGiftList = @"atgUserGiftListsToCreateGiftList";

#pragma mark - ATGGiftListsViewController private interface declaration
#pragma mark -
@interface ATGGiftListsViewController () <ATGGiftListManagerDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, strong) IBOutlet UILabel *noGiftListsLabel;

#pragma mark - Custom properties
@property (nonatomic, strong) NSArray *idList;
@property (nonatomic, strong) NSString *listToEdit;
@property (nonatomic, strong) NSDictionary *giftLists;
@property (nonatomic, strong) ATGManagerRequest *request;

#pragma mark - UI Event Handlers

- (void)didTouchAddGiftListBarButtonItem:(UIBarButtonItem *)sender;

@end

#pragma mark - ATGGiftListsViewController implementation
#pragma mark -
@implementation ATGGiftListsViewController

#pragma mark - Lifecycle
- (void) viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue(@"ATGGiftListsViewController.Title",
                                                      nil, [NSBundle mainBundle], @"Gift Lists",
                                                      @"Title to be displayed at the top of the screen which display list of users gift lists.");
  [self setTitle:title];
  
  [[self tableView] setBackgroundView:[self noGiftListsLabel]];
  [[self noGiftListsLabel] setHidden:YES];
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListsViewController.NoGiftListsSubTitle",
       nil, [NSBundle mainBundle], @"You have not created gift lists yet.",
       @"Message to be displayed to user, if no gift lists created yet.");
  [[self noGiftListsLabel] setText:title];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self navigationController] setToolbarHidden:YES animated:NO];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGGiftListManager instance] getUserGiftListsForDelegate:self]];
}

- (void) viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (CGSize) contentSizeForViewInPopover {
  NSInteger rowsNumber = [[self tableView] numberOfRowsInSection:0];
  return CGSizeMake(320, (rowsNumber == 0 ? 2 : rowsNumber) * [[self tableView] rowHeight]);
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueEditGiftList isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGGiftListCreateViewController *editController = [pSegue destinationViewController];
    [editController setListId:[self listToEdit]];
  }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)pSection {
  return [self.giftLists count];
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:ATGEventType forIndexPath:pIndexPath];
  cell.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGGiftListsViewController.GiftListCell.Accessibility.Hint", nil, [NSBundle mainBundle], @"gift list, double tap to select", @"Hint to accompany the reading of the cell text, which is the gift list name");
  return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSString *key = [self.idList objectAtIndex:pIndexPath.row];
  pCell.textLabel.text = [self.giftLists objectForKey:key];
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([[self delegate] respondsToSelector:@selector(viewController:didSelectGiftList:)] &&
      ![[self delegate] viewController:self
                     didSelectGiftList:[[self idList] objectAtIndex:[pIndexPath row]]]) {
    // Delegate has taken care of the gift list selected. Nothing to do here.
  } else {
    [self setListToEdit:[self.idList objectAtIndex:pIndexPath.row]];
    [self performSegueWithIdentifier:ATGSegueEditGiftList sender:self];
  }
}

#pragma mark - GiftListManager delegate

- (void) giftListManagerDidGetUserLists:(NSDictionary *)pGiftLists {
  [self stopActivityIndication];
  if ([[self delegate] respondsToSelector:@selector(viewController:shouldDisplayGiftList:)]) {
    NSMutableDictionary *allowedGiftLists = [[NSMutableDictionary alloc] init];
    for (NSString *listID in pGiftLists) {
      if ([[self delegate] viewController:self shouldDisplayGiftList:listID]) {
        [allowedGiftLists setObject:[pGiftLists objectForKey:listID] forKey:listID];
      }
    }
    pGiftLists = allowedGiftLists;
  }
  self.giftLists = pGiftLists;
  self.idList = [self.giftLists allKeys];
  [self.tableView reloadData];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  
  if ([[self giftLists] count] == 0 &&
      [[self delegate] respondsToSelector:@selector(viewControllerShouldDisplayNewGiftListButton:)] &&
      [[self delegate] viewControllerShouldDisplayNewGiftListButton:self]) {
    UIBarButtonItem *addGiftListItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(didTouchAddGiftListBarButtonItem:)];
    [[self navigationItem] setRightBarButtonItem:addGiftListItem animated:YES];
  }
  [[self noGiftListsLabel] setHidden:[[self giftLists] count] > 0];
  [[self tableView] setSeparatorStyle:[[self giftLists] count] == 0 ?
      UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLineEtched];
}

- (void) giftListManagerDidFailWithError:(NSError *)pError {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

#pragma mark - UI Event Handlers

- (void)didTouchAddGiftListBarButtonItem:(UIBarButtonItem *)pSender {
  [self performSegueWithIdentifier:ATGSegueCreateGiftList sender:self];
}

@end