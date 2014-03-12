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

#import <ATGMobileClient/ATGTableViewController.h>
#import "ATGGiftListItemsViewController.h"
#import <ATGMobileClient/ATGGridCollectionView.h>
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGGiftItem.h>
#import "ATGGiftListItemCollectionViewCell.h"
#import <ATGUIElements/ATGProgressHUD.h>
#import <ATGMobileClient/ATGProductManager.h>
#import "ATGGiftListCreateViewController.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import "ATGGiftListsViewController.h"
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import "ATGRootViewController_iPad.h"

static NSString *const ATGGiftListInfoControllerID = @"ATGGiftListInfoViewController";
static CGFloat const ATGGiftListInfoScreenWidth = 440;
static NSString *const ATGEditGiftListControllerID = @"ATGGiftListCreateViewController";
static NSString *const ATGSelectGiftListConrollerID = @"atgSelectGiftListRootNavigationController";

#pragma mark - ATGGiftListInfoViewController Declaration
#pragma mark -

@interface ATGGiftListInfoViewController : ATGTableViewController

@property (nonatomic, readwrite, strong) ATGGiftList *giftList;

@end

#pragma mark - ATGGiftListItemsViewController Private Protocol Definition
#pragma mark -

@interface ATGGiftListItemsViewController () <ATGGiftListManagerDelegate, ATGGridCollectionViewDelegate,
    ATGGiftListItemCollectionViewCellDelegate, ATGProductManagerDelegate,
    ATGGiftListCreateViewControllerDelegate, ATGGiftListsViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *userNameItem;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *giftListNameItem;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *giftListNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *giftListInfoItem;
@property (nonatomic, readwrite, weak) IBOutlet ATGGridCollectionView *gridView;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *editGiftListItem;
@property (nonatomic, readwrite, strong) IBOutlet UIBarButtonItem *editGiftItemsItem;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *removeGiftItemsItem;
@property (nonatomic, readwrite, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *noProductsTitleLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *noProductsSubtitleLabel;

@property (nonatomic, readwrite, strong) UIPopoverController *popover;
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, readwrite, weak) ATGProgressHUD *hudView;
@property (nonatomic, readwrite, weak) ATGGiftListItemCollectionViewCell *activeCell;
@property (nonatomic, readwrite, assign) BOOL shouldUpdateCurrentGiftList;
@property (nonatomic, readwrite, weak) UIBarButtonItem *doneEditingGiftItemsItem;
@property (nonatomic, readwrite, strong) UIActionSheet *actionSheet;

- (IBAction)didTouchEditGiftListItem:(UIBarButtonItem *)sender;
- (IBAction)didTouchEditGiftItemsItem:(UIBarButtonItem *)sender;
- (IBAction)didTouchRemoveGiftItemsItem:(UIBarButtonItem *)sender;

- (void)handleInfoItem:(UIBarButtonItem *)item;
- (void)didTouchDoneEditingItem:(UIBarButtonItem *)sender;

@end

#pragma mark - ATGGiftListItemsViewController Implementation
#pragma mark -

@implementation ATGGiftListItemsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [[self gridView] setGridViewDelegate:self];
  UIActivityIndicatorView *spinner =
      [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [self setSpinner:spinner];
  [[self gridView] setBackgroundView:spinner];
  
  NSString *infoButtonTitle = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.InfoButtonTitle",
       nil, [NSBundle mainBundle], @"Info",
       @"Title to be displayed on the Info button of the Gift List - Items screen.");
  [[self giftListInfoItem] setTitle:infoButtonTitle];
  [[self giftListInfoItem] setTarget:self];
  [[self giftListInfoItem] setAction:@selector(handleInfoItem:)];
  
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Title.EditGiftList",
       nil, [NSBundle mainBundle], @"Edit Details",
       @"Title to be displayed on the 'Edit Gift List' button of the gift list items toolbar.");
  NSString *hint = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Accessibility.Hint.EditGiftList",
       nil, [NSBundle mainBundle], @"Double tap to edit current gift list details.",
       @"Accessibility hint to be used by the 'Edit Gift List' button of the gift list items toolbar.");
  [[self editGiftListItem] setTitle:title];
  [[self editGiftListItem] setAccessibilityHint:hint];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Title.EditGiftItems",
       nil, [NSBundle mainBundle], @"Edit Items",
       @"Title to be displayed on the 'Edit Gift List Items' button of the gift list items toolbar.");
  hint = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Accessibility.Hint.EditGiftItems",
       nil, [NSBundle mainBundle], @"Double tap to edit all gift items.",
       @"Accessibility hint to be used by the 'Edit Gift Items' button of the gift list items toolbar.");
  [[self editGiftItemsItem] setTitle:title];
  [[self editGiftItemsItem] setAccessibilityHint:hint];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Title.RemoveItems",
       nil, [NSBundle mainBundle], @"Remove All Items",
       @"Title to be displayed on the 'Remove All Items' button of the gift list items toolbar.");
  hint = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Accessibility.Hint.RemoveItems",
       nil, [NSBundle mainBundle], @"Double tap to remove all gift items.",
       @"Accessibility hint to be used by the 'Remove Items' button of the gift list items toolbar.");
  [[self removeGiftItemsItem] setTitle:title];
  [[self removeGiftItemsItem] setAccessibilityHint:hint];
  hint = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Accessibility.Hint.GiftListInfo",
       nil, [NSBundle mainBundle], @"Double tap to inspect gift list info.",
       @"Accessibility hint to be used by the 'Gift List Info' button of the gift list items toolbar.");
  [[self giftListInfoItem] setAccessibilityHint:hint];
  
  title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Title.NoProductsAdded",
       nil, [NSBundle mainBundle], @"You have not added any products to the list.",
       @"Title to be displayed on the Gift List Items screen if no items added to list.");
  [[self noProductsTitleLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.Subtitle.NoProductsAdded",
       nil, [NSBundle mainBundle], @"You may add items to list from any product page.",
       @"Description to be displayed on the Gift List Items screen if no items added to list.");
  [[self noProductsSubtitleLabel] setText:title];
  
  [[self editGiftItemsItem] setEnabled:NO];
  [[self removeGiftItemsItem] setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  NSString *userName = [NSString stringWithFormat:@"%@ %@:",
                        [[self giftList] firstName], [[self giftList] lastName]];
  [[self userNameItem] setTitle:userName];
  [[self giftListNameLabel] setText:[[self giftList] name]];
  CGSize size = [[self giftListNameLabel] sizeThatFits:[[self giftListNameLabel] bounds].size];
  [[self giftListNameItem] setWidth:size.width];
  [super viewWillAppear:pAnimated];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [super viewWillDisappear:pAnimated];
  
  // Replace the done button with edit button if the user was in edit mode before exiting
  NSMutableArray *items = [[[self toolbar] items] mutableCopy];
  NSUInteger index = [items indexOfObject:[self doneEditingGiftItemsItem]];
  if (index != NSNotFound) {
    [items replaceObjectAtIndex:index withObject:[self editGiftItemsItem]];
    [[self toolbar] setItems:items animated:YES];
  }
  
  [[self popover] dismissPopoverAnimated:pAnimated];
}

- (void)viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  [[self spinner] startAnimating];
  if ([self giftList]) {
    [[ATGGiftListManager instance] getGiftListItems:[[self giftList] giftlistId] delegate:self];
  }
}

#pragma mark - ATGGiftListManagerDelegate

- (void)giftListManagerDidFailWithError:(NSError *)pError {
  [[self spinner] stopAnimating];
  [[self hudView] hide:YES];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

- (void)giftListManagerDidGetGiftItems:(NSArray *)pItems forGiftList:(NSString *)pGiftListID {
  [[self spinner] stopAnimating];
  [[self gridView] setObjectsToDisplay:pItems];
  [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
}

- (void)giftListManagerDidAddGiftItemToCart:(ATGGiftItem *)pGiftItem {
  [[self hudView] hide:YES];
  [[self gridView] dechooseItemAtIndexPath:[[self gridView] indexPathForCell:[self activeCell]]
                                  animated:YES];
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
}

- (void)giftListManagerDidCopyItemToWishList {
  [[self hudView] hide:YES];
  if ([self shouldUpdateCurrentGiftList]) {
    [[self gridView] removeObjectToDisplay:[[self activeCell] objectToDisplay]];
    [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
    [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
    [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
    [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
    if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
      [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
    }
  }
}

- (void)giftListManagerDidRemoveItemFromGiftList:(ATGGiftList *)pGiftList {
  [[self hudView] hide:YES];
  [[self gridView] removeObjectToDisplay:[[self activeCell] objectToDisplay]];
  [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
}

- (void)giftListManagerDidRemoveAllItemsFromGiftList:(ATGGiftList *)pGiftList {
  [[self hudView] hide:YES];
  [[self gridView] setObjectsToDisplay:[[pGiftList items] array]];
  [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)giftListManagerDidCopyItemToGiftList:(NSString *)pGiftListID {
  [[self hudView] hide:YES];
  if ([self.activeCell.reuseIdentifier isEqualToString:@"ATGStrangerGiftListItemCollectionViewCell"]) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
    return;
  }
  [[self gridView] removeObjectToDisplay:[[self activeCell] objectToDisplay]];
  [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
}

#pragma mark - ATGGridCollectionViewDelegate

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView
           willDisplayCell:(ATGGridCollectionViewCell *)pCell {
  [(ATGGiftListItemCollectionViewCell *)pCell setDelegate:self];
}

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didSelectObject:(id)pObject {
  [[ATGRootViewController_iPad rootViewController] displayDetailsForProductId:((ATGGiftItem *)pObject).productId inList:@[pObject]];
}

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didDechooseObject:(id)pObject {
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
}

#pragma mark - ATGProductManagerDelegate

- (void)didAddProductToComparisons:(ATGProductManagerRequest *)pRequest {
  [[self hudView] hide:YES];
  [[self gridView] dechooseItemAtIndexPath:[[self gridView] indexPathForCell:[self activeCell]]
                                  animated:YES];
  if ([[[self gridView] indexPathsForChosenItems] count] == 0) {
    [self didTouchDoneEditingItem:[self doneEditingGiftItemsItem]];
  }
}

- (void)didErrorAddingProductToComparisons:(ATGProductManagerRequest *)pRequest {
  [[self hudView] hide:YES];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

#pragma mark - ATGGiftListsViewControllerDelegate

- (BOOL)viewController:(ATGGiftListsViewController *)pController didSelectGiftList:(NSString *)pGiftListID {
  [[self popover] dismissPopoverAnimated:YES];
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGGiftListManager instance] copyGiftItem:[[self activeCell] objectToDisplay]
                                   toGiftList:pGiftListID
                                    andRemove:![[self activeCell].reuseIdentifier isEqualToString:@"ATGStrangerGiftListItemCollectionViewCell"]
                                     delegate:self];
  return NO;
}

- (BOOL)viewController:(ATGGiftListsViewController *)pController
 shouldDisplayGiftList:(NSString *)pGiftListID {
  return ![[[self giftList] giftlistId] isEqualToString:pGiftListID];
}

#pragma mark - ATGGiftListItemCollectionViewCellDelegate

- (void)removeGiftItem:(ATGGiftItem *)pGiftItem forCell:(ATGGiftListItemCollectionViewCell *)pCell {
  [self setActiveCell:pCell];
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGGiftListManager instance] removeGiftItem:pGiftItem delegate:self];
}

- (void)moveGiftItemToGiftList:(ATGGiftItem *)pGiftItem forCell:(ATGGiftListItemCollectionViewCell *)pCell {
  [self setActiveCell:pCell];
  ATGResizingNavigationController *contents =
  [[self storyboard] instantiateViewControllerWithIdentifier:ATGSelectGiftListConrollerID];
  [self setPopover:[[UIPopoverController alloc] initWithContentViewController:contents]];
  [contents setPopoverController:[self popover]];
  ATGGiftListsViewController *listController = (ATGGiftListsViewController *)[contents topViewController];
  [listController setDelegate:self];
  [[self popover] presentPopoverFromRect:[pCell bounds]
                                  inView:pCell
                permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                animated:YES];
}

- (void)moveGiftItemToWishList:(ATGGiftItem *)pGiftItem forCell:(ATGGiftListItemCollectionViewCell *)pCell {
  [self setActiveCell:pCell];
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGGiftListManager instance] copyGiftItemToWishList:pGiftItem
                                              andRemove:[self shouldUpdateCurrentGiftList]
                                               delegate:self];
}

- (void)compareGiftItem:(ATGGiftItem *)pGiftItem forCell:(ATGGiftListItemCollectionViewCell *)pCell {
  [self setActiveCell:pCell];
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGProductManager productManager] addProductToComparisons:[pGiftItem productId]
                                                       siteID:[pGiftItem siteId]
                                                     delegate:self];
}

- (void)addGiftItemToCart:(ATGGiftItem *)pGiftItem forCell:(ATGGiftListItemCollectionViewCell *)pCell {
  [self setActiveCell:pCell];
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGGiftListManager instance] addGiftItemToCart:pGiftItem delegate:self];
}

#pragma mark - ATGGiftListCreateViewControllerDelegate

- (void)viewController:(ATGGiftListCreateViewController *)pController
     didUpdateGiftList:(ATGGiftList *)pGiftList {
  [self setGiftList:pGiftList];
  [[self popover] dismissPopoverAnimated:YES];
}

- (BOOL)viewControllerShouldDisplayViewItemsButton:(ATGGiftListCreateViewController *)pController {
  return NO;
}

#pragma mark - UIActionSheetDeletate

- (void)actionSheet:(UIActionSheet *)pActionSheet didDismissWithButtonIndex:(NSInteger)pButtonIndex {
  [self setActionSheet:nil];
  if (pButtonIndex >= 0) {
    // If button index is set, then the user has touched action button.
    // On this screen, action sheet always has only one button.
    [self removeAllGiftItems];
  }
}

#pragma mark - Public Protocol Implementation

- (void)removeAllGiftItems {
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  [[ATGGiftListManager instance] removeAllItemsFromGiftList:[self giftList] delegate:self];
}

#pragma mark - Private Protocol Implementation

- (IBAction)didTouchEditGiftListItem:(UIBarButtonItem *)pSender {
  if ([[self popover] isPopoverVisible]) {
    [self.popover dismissPopoverAnimated:YES];
    return;
  }
  ATGGiftListCreateViewController *contents =
      [[self storyboard] instantiateViewControllerWithIdentifier:ATGEditGiftListControllerID];
  [contents setListId:[[self giftList] giftlistId]];
  [contents setDelegate:self];
  ATGResizingNavigationController *navigationController =
      [[ATGResizingNavigationController alloc] initWithRootViewController:contents];
  UIPopoverController *popover =
      [[UIPopoverController alloc] initWithContentViewController:navigationController];
  [navigationController setPopoverController:popover];
  [popover presentPopoverFromBarButtonItem:pSender
                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                  animated:YES];
  [self setPopover:popover];
}

- (IBAction)didTouchEditGiftItemsItem:(UIBarButtonItem *)pSender {
  for (NSInteger item = 0; item < [[self gridView] numberOfItemsInSection:0]; item++) {
    [[self gridView] chooseItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] animated:YES];
  }
  NSMutableArray *items = [[[self toolbar] items] mutableCopy];
  NSInteger index = [items indexOfObject:[self editGiftItemsItem]];
  if (index != NSNotFound) {
    UIBarButtonItem *doneItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(didTouchDoneEditingItem:)];
    NSString *hint = NSLocalizedStringWithDefaultValue
        (@"ATGGiftListItemsViewController.Accessibility.Hint.EditItemsDone",
         nil, [NSBundle mainBundle], @"Double tap to quit editing gift items.",
         @"Accessibility hint to be used by the 'Done Editing' button of the gift items toolbar.");
    [doneItem setAccessibilityHint:hint];
    [items replaceObjectAtIndex:index withObject:doneItem];
    [[self toolbar] setItems:items animated:YES];
    [self setDoneEditingGiftItemsItem:doneItem];
  }
  id arg = ([self.gridView indexPathsForChosenItems].count > 0 ? [[self.gridView indexPathsForChosenItems] objectAtIndex:0] : nil);
  if (arg) {
    ATGGiftListItemCollectionViewCell *cell = (ATGGiftListItemCollectionViewCell *)[self.gridView cellForItemAtIndexPath:(NSIndexPath *)arg];
    arg = cell.deleteButton;
  }
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, arg);
}

- (IBAction)didTouchRemoveGiftItemsItem:(UIBarButtonItem *)pSender {
  if ([[self actionSheet] isVisible]) {
    // Do not display new action sheet, if there is another action onscreen.
    return;
  }
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGGiftListItemsViewController.RemoveAllItems.Title",
       nil, [NSBundle mainBundle], @"Are you sure you want to remove all the items in this list?",
       @"Title to be used when displaying confirmation sheet for the 'remove all items' action.");
  NSString *buttonCaption = NSLocalizedStringWithDefaultValue
    (@"ATGGiftListItemsViewController.RemoveAllItems.ButtonTitle",
     nil, [NSBundle mainBundle], @"Delete all items",
     @"Button caption actually removing all items from the gift list.");
  UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:title
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:buttonCaption
                                             otherButtonTitles:nil];
  [action setActionSheetStyle:UIActionSheetStyleDefault];
  [action showFromBarButtonItem:pSender animated:YES];
  [self setActionSheet:action];
}

- (void)didTouchDoneEditingItem:(UIBarButtonItem *)pSender {
  for (NSInteger item = 0; item < [[self gridView] numberOfItemsInSection:0]; item++) {
    [[self gridView] dechooseItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] animated:YES];
  }
  NSMutableArray *items = [[[self toolbar] items] mutableCopy];
  NSInteger index = [items indexOfObject:pSender];
  if (index != NSNotFound) {
    [items replaceObjectAtIndex:index withObject:[self editGiftItemsItem]];
    [[self toolbar] setItems:items animated:YES];
  }
}

- (void)handleInfoItem:(UIBarButtonItem *)pItem {
  if ([[self popover] isPopoverVisible]) {
    [self.popover dismissPopoverAnimated:YES];
    return;
  }
  ATGGiftListInfoViewController *contents =
      [[self storyboard] instantiateViewControllerWithIdentifier:ATGGiftListInfoControllerID];
  [contents setGiftList:[self giftList]];
  UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:contents];
  [popover presentPopoverFromBarButtonItem:pItem
                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                  animated:YES];
  [self setPopover:popover];
}

- (CGSize)contentSizeForViewInPopover {
  return self.view.bounds.size;
}


@end

#pragma mark - ATGGiftListInfoViewController Implementation
#pragma mark -

@implementation ATGGiftListInfoViewController

#pragma mark - UIViewController

- (CGSize)contentSizeForViewInPopover {
  return CGSizeMake(ATGGiftListInfoScreenWidth,
                    [[self tableView] rowHeight] * [[self tableView] numberOfRowsInSection:0]);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView
  willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  switch ([pIndexPath row]) {
    case 0: {
      [[pCell detailTextLabel] setText:[[self giftList] giftListDescription]];
      NSString *title = NSLocalizedStringWithDefaultValue
          (@"ATGGiftListInfoViewController.DescriptionCellTitle",
           nil, [NSBundle mainBundle], @"Description",
           @"Title to be displayed on the description cell of the gift list info popover.");
      [[pCell textLabel] setText:title];
      break;
    }
    default: {
      [[pCell detailTextLabel] setText:[[self giftList] instructions]];
      NSString *title = NSLocalizedStringWithDefaultValue
          (@"ATGGiftListInfoViewController.InstructionsCellTitle",
           nil, [NSBundle mainBundle], @"Instructions",
           @"Title to be displayed on the instructions cell of the gift list info popover.");
      [[pCell textLabel] setText:title];
      break;
    }
  }
}

@end
