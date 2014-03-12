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

#import "ATGWishListItemsViewController.h"
#import <ATGMobileClient/ATGGiftListManager.h>
#import <ATGMobileClient/ATGGridCollectionView.h>
#import "ATGGiftListCreateViewController.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGUIElements/ATGProgressHUD.h>
#import <ATGMobileClient/ATGGiftItem.h>

static NSString *const ATGCreateGiftListControllerID = @"ATGGiftListCreateViewController";
static NSString *const ATGSegueWishListToGiftListItems = @"atgWishListItemsToGiftListItems";

@interface ATGGiftListItemsViewController () <ATGGiftListManagerDelegate>

@end

#pragma mark - ATGWishListItemsViewController Private Protocol Definition
#pragma mark -

@interface ATGWishListItemsViewController () <ATGGiftListManagerDelegate,
    ATGGiftListCreateViewControllerDelegate>

@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *titleItem;
@property (nonatomic, readwrite, weak) IBOutlet ATGGridCollectionView *gridView;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *convertWishListItem;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *noProductsTitleLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *noProductsSubtitleLabel;
@property (nonatomic, readwrite, strong) IBOutlet UIBarButtonItem *editGiftItemsItem;
@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *removeGiftItemsItem;

@property (nonatomic, readwrite, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, readwrite, strong) UIPopoverController *popover;
@property (nonatomic, readwrite, weak) ATGProgressHUD *hudView;

- (IBAction)didTouchConvertToGiftListItem:(UIBarButtonItem *)sender;

@end

#pragma mark - ATGWishListItemsViewController Implementation
#pragma mark -

@implementation ATGWishListItemsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGWishListItemsViewController.Subtitle",
       nil, [NSBundle mainBundle], @"My Wish List",
       @"Screen subtitle to be displayed on the toolbar of the Wish List screen.");
  [[self titleItem] setTitle:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGWishListItemsViewController.Title.ConvertWishList",
       nil, [NSBundle mainBundle], @"Convert to Gift List",
       @"Title to be used by the 'Convert Wish List' button of the wish list items toolbar.");
  [[self convertWishListItem] setTitle:title];
}

- (void)viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  [[ATGGiftListManager instance] getWishListItemsForDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueWishListToGiftListItems isEqualToString:[pSegue identifier]]) {
    ATGGiftListItemsViewController *giftItemsController = [pSegue destinationViewController];
    [giftItemsController setGiftList:[self giftList]];
  }
}

- (CGSize) contentSizeForViewInPopover {
  return [UIScreen mainScreen].bounds.size;
}

#pragma mark - ATGGiftListManagerDelegate

- (void)giftListManagerDidFailWithError:(NSError *)pError {
  [[self spinner] stopAnimating];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

- (void)giftListManagerDidGetWishListItems:(NSArray *)pItems {
  [[self spinner] stopAnimating];
  [[self gridView] setObjectsToDisplay:pItems];
  [[self noProductsTitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self noProductsSubtitleLabel] setHidden:[[[self gridView] objectsToDisplay] count] > 0];
  [[self editGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self removeGiftItemsItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
  [[self convertWishListItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
}

- (void)giftListManagerDidConvertWishListToGiftList:(ATGGiftList *)pGiftList {
  [[self popover] dismissPopoverAnimated:YES];
  [self setGiftList:pGiftList];
  [self performSegueWithIdentifier:ATGSegueWishListToGiftListItems sender:self];
}

- (void)giftListManagerDidRemoveItemFromGiftList:(ATGGiftList *)pGiftList {
  [super giftListManagerDidRemoveItemFromGiftList:pGiftList];
  [[self convertWishListItem] setEnabled:[[[self gridView] objectsToDisplay] count] > 0];
}

- (void)giftListManagerDidRemoveAllItemsFromGiftList:(ATGGiftList *)pGiftList {
  [super giftListManagerDidRemoveAllItemsFromGiftList:pGiftList];
  [[self convertWishListItem] setEnabled:NO];
}

#pragma mark - ATGGiftListCreateViewControllerDelegate

- (BOOL)viewController:(ATGGiftListCreateViewController *)pController
    shouldCreateGiftListWithName:(NSString *)pName
    type:(NSString *)pType
    addressId:(NSString *)pAddressId
    date:(NSDate *)pDate
    publish:(BOOL)pPublish
    description:(NSString *)pDescription
    instructions:(NSString *)pInstructions {
  [[ATGGiftListManager instance] convertWishListToGiftListWithName:pName
                                                              type:pType
                                                         addressId:pAddressId
                                                              date:pDate
                                                           publish:pPublish
                                                       description:pDescription
                                                      instructions:pInstructions
                                                          delegate:self];
  return NO;
}

#pragma mark - Public Protocol Implementation

- (void)removeAllGiftItems {
  [self setHudView:[ATGProgressHUD showHUDAddedTo:[self view] animated:YES]];
  ATGGiftItem *item = (ATGGiftItem *)[[[self gridView] objectsToDisplay] objectAtIndex:0];
  [[ATGGiftListManager instance] removeAllItemsFromGiftList:[item giftList] delegate:self];
}

#pragma mark - Private Protocol Implementation

- (IBAction)didTouchConvertToGiftListItem:(UIBarButtonItem *)pSender {
  if ([[self popover] isPopoverVisible]) {
    return;
  }
  ATGGiftListCreateViewController *contents =
      [[self storyboard] instantiateViewControllerWithIdentifier:ATGCreateGiftListControllerID];
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

@end
