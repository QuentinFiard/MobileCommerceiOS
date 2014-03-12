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

#import "ATGRootViewController_iPad.h"
#import "ATGShoppingCartViewController_iPad.h"
#import "ATGHomeViewController_iPad.h"
#import "ATGCompareViewController.h"
#import "ATGBarButtonItem.h"
#import "ATGOrderDetailsViewController_iPad.h"
#import "ATGShoppingCartViewController.h"
#import "ATGProfileViewController.h"
#import "ATGMoreViewController_iPad.h"
#import "ATGGiftListItemsViewController.h"
#import "ATGCommerceProductPageViewController.h"
#import "ATGSearchViewController_iPad.h"
#import "ATGBrowseResultsViewController.h"
#import <ATGMobileClient/ATGGiftList.h>
#import <ATGMobileClient/ATGBrowseViewController_iPad.h>
#import <ATGMobileClient/ATGBrowseViewController.h>
#import <ATGMobileClient/ATGConfigurationManager.h>
#import <ATGMobileClient/ATGSearchBox.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMNavigationAction.h>
#import <EMMobileClient/EMSearchBox.h>

@interface ATGRootViewController_iPad () <ATGSearchBoxDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate>

// stores the currently presented popover when pushing view controllers, so it can be restored
@property (nonatomic, strong) NSMutableArray *savedPopoverButtons;
@property (nonatomic, weak) ATGBarButtonItem *popoverButton;

@property (nonatomic, strong) ATGHomeViewController_iPad *homeController;
@property (nonatomic, strong) ATGSearchViewController_iPad *searchController;
@property (nonatomic, strong) ATGBaseBrowseResultsViewController *browseResultsController;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) UINavigationController *browseController;
@property (nonatomic, strong) ATGProductPageViewController *productPageController;
@property (nonatomic, strong) ATGSearchBox *searchBoxView;
@property (nonatomic, strong) UINavigationController *searchAutoSuggestions;
@property (nonatomic, strong) ATGBarButtonItem *navButtonSearch;
@property (nonatomic, strong) ATGBarButtonItem *navButtonBrowse;
@property (nonatomic, strong) ATGBarButtonItem *navButtonGiftlist;
@property (nonatomic, strong) ATGBarButtonItem *navButtonWishlist;
@property (nonatomic, strong) ATGBarButtonItem *navButtonCompare;
@property (nonatomic, strong) ATGBarButtonItem *navButtonCart;
@property (nonatomic, strong) ATGBarButtonItem *navButtonProfile;
@property (nonatomic, strong) ATGBarButtonItem *navButtonMore;

@property (nonatomic, strong)  ATGCommerceManagerRequest *updateItemsRequest;

// Callback method to be called when shopping cart is changed.
- (void) shoppingCartChangedNotification:(NSNotification *)notification;

@end

@implementation ATGRootViewController_iPad

static int* const kObserverContextSearchCompletion;

static NSString *const NavBarProfileImageName = @"icon-menu-account.png";
static NSString *const NavBarBrowseImageName = @"icon-menu-browse.png";
static NSString *const NavBarCartImageName = @"icon-menu-shoppingCart.png";
static NSString *const NavBarHomeImageName = @"icon-menu-home.png";
static NSString *const NavBarMoreImageName = @"icon-menu-more.png";

static NSString *const ATGStoryboardProfile = @"ProfileStoryboard_iPad";
static NSString *const ATGStoryboardCheckout = @"CheckoutStoryboard_iPad";
static NSString *const ATGStoryboardMore = @"MoreStoryboard_iPad";
static NSString *const ATGSceneIdOrders = @"ATGOrdersViewController";
static NSString *const ATGSceneIdOrderDetails = @"ATGOrderDetailsViewController";
static NSString *const ATGGiftListStoryboard = @"GiftListStoryboard_iPad";
static NSString *const ATGWishListControllerID = @"atgWishListItemsNavViewController";
static NSString *const ATGNavigationController = @"ATGNavigationController";

static NSString *const ATGHomePageController = @"ATGHomeViewController";
static NSString *const ATGCompareController = @"ATGCompareController";

static NSString *const ATGGiftListItemsNavViewControllerId = @"atgGiftListItemsNavViewController";
static NSString *const ATGOtherUserGiftListItemsNavViewControllerId = @"atgOtherUserGiftListItemsNavViewController";


// singleton
static ATGRootViewController_iPad *rootViewController;

+ (ATGRootViewController_iPad *) rootViewController {
  if (!rootViewController) {
    NSAssert(NO, @"If not using storyboard, you must initialize rootViewController");
  }
  return rootViewController;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [self.browseResultsController.collectionView.collectionViewLayout invalidateLayout];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    // singleton var
    rootViewController = self;
    self.savedPopoverButtons = [NSMutableArray new];
  }
  return self;
}

- (void)setPopover:(UIPopoverController *)pPopover {
  if (self.popover) {
    [self.popover dismissPopoverAnimated:YES];
  }
  _popover = pPopover;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [rootViewController loadNavigationBar];

  self.homeController = [self.storyboard instantiateViewControllerWithIdentifier:ATGHomePageController];
  [rootViewController pushViewController:self.homeController];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(shoppingCartChangedNotification:)
                                               name:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                                             object:nil];
}

- (void)pushViewController:(UIViewController *)pViewController {
  if (self.popover) {
    [self.savedPopoverButtons addObject:self.popoverButton];
    self.popover = nil;
  } else {
    [self.savedPopoverButtons addObject:[NSNull null]];
  }
  [self addChildViewController:pViewController];

  CGRect viewFrame = self.view.bounds;

  // account for the origin y changing in ios 6 vs 7.  Take into account 42 pts for header
  // and 20 pts for status bar by increasing y by 62
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && [pViewController isKindOfClass:[ATGCommerceProductPageViewController class]]) {
    viewFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 62,
                           self.view.bounds.size.width, self.view.bounds.size.height);
  }
  pViewController.view.frame = viewFrame;
  [self.view addSubview:pViewController.view];
  [pViewController didMoveToParentViewController:self];
}

- (void)popViewController {
  if (self.childViewControllers.count == 0) {
    return;
  }
  UIViewController *vc = [self.childViewControllers lastObject];
  [vc willMoveToParentViewController:nil];
  [vc.view removeFromSuperview];
  [vc removeFromParentViewController];

  id barButton = [self.savedPopoverButtons lastObject];
  if (barButton != [NSNull null]) {
    [self displayPopoverFromBarButton:(ATGBarButtonItem *)barButton];
  }
  [self.savedPopoverButtons removeLastObject];
}

- (void) switchToViewController: (UIViewController*) pViewController {
  if (self.childViewControllers.count == 0) {
    [self pushViewController:pViewController];
    return;
  }
  while (self.childViewControllers.count > 1) {
    if ([self.childViewControllers lastObject] == pViewController) {
      return;
    }
    [self popViewController];
  }
  UIViewController *currentVC = [self.childViewControllers objectAtIndex:0];
  if (currentVC == pViewController) {
    return;
  }
  [currentVC willMoveToParentViewController:nil];
  [self addChildViewController:pViewController];
  pViewController.view.frame = self.view.bounds;

  [self transitionFromViewController:currentVC toViewController:pViewController
                            duration: 0.25 options:UIViewAnimationOptionTransitionCrossDissolve
                          animations:^{}
                          completion:^(BOOL finished) {
                            [currentVC removeFromParentViewController];
                            [pViewController didMoveToParentViewController:self];
                          }];
}

- (void) updateCartItemsCount {
  [self.updateItemsRequest setDelegate:nil];
  [self.updateItemsRequest cancelRequest];
  self.updateItemsRequest = [[ATGCommerceManager commerceManager] getCartItemCount:self];
}

- (void) shoppingCartChangedNotification:(NSNotification *)pNotification {
  // Get numer of cart items and put it onto proper toolbar button.
  NSInteger count = [(NSNumber *)[[pNotification userInfo]
                                  objectForKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY] integerValue];
  
  if (count > 0)
    self.navButtonCart.badgeValue = count;
  else
    self.navButtonCart.badgeValue = 0;
}

#pragma mark - Navigation Bar

// add buttons (and search box) to the navigation bar
- (void) loadNavigationBar {
  CGFloat height = self.navigationController.navigationBar.frame.size.height;
  
  // left: home, browse, and search box
  ATGBarButtonItem *home = [ATGBarButtonItem barButtonItemFromImageNamed:NavBarHomeImageName
                                                      accessibilityLabel:[ATGHomeViewController toolbarAccessibilityLabel]
                                                                  height:height
                                                                  target:self
                                                                selector:@selector(displayHomepage)
                                                                 divider:YES];
  
  self.navButtonBrowse = [ATGBarButtonItem barButtonItemFromImageNamed:NavBarBrowseImageName
                                                    accessibilityLabel:[ATGBrowseViewController toolbarAccessibilityLabel]
                                                                height:height
                                                                target:self
                                                              selector:@selector(displayBrowse)
                                                               divider:YES];

  EMSearchBox *searchBox = [[EMSearchBox alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"SearchBox", @"@type", @"Search Box", @"name", [NSNumber numberWithInt:3], @"minAutoSuggestInputLength", nil]];
  searchBox.baseAction = [EMAction actionWithContentPath:@"browse" siteRootPath:@"" state:[NSString stringWithFormat:@"?%@=", @"Ntt"]];
  self.searchBoxView = [[ATGSearchBox alloc] initWithFrame:CGRectMake(0, 0, 180, 31) searchBox:searchBox];
  self.searchBoxView.delegate = self;
  self.navButtonSearch = [[ATGBarButtonItem alloc] initWithCustomView:self.searchBoxView];

  NSArray *leftBarButtonItems = @[home, self.navButtonBrowse, self.navButtonSearch];
  [self.navigationItem setLeftBarButtonItems:leftBarButtonItems];

  // right side: giftlist, wishlist, compare, cart, profile, more
  self.navButtonGiftlist = [ATGBarButtonItem barButtonItemWithTitle:NSLocalizedStringWithDefaultValue(@"ATGRootViewController_iPad.NavigationBar.GiftListBarButton.Title", nil, [NSBundle mainBundle], @"Gift List", @"String which is rendered AS the button for the gift list, there is no icon")
                                                             height:height
                                                              target:self
                                                           selector:@selector(displayGiftlist)
                                                            divider:YES];
  
  self.navButtonWishlist = [ATGBarButtonItem barButtonItemWithTitle:NSLocalizedStringWithDefaultValue(@"ATGRootViewController_iPad.NavigationBar.WishListBarButton.Title", nil, [NSBundle mainBundle], @"Wish List", @"String which is rendered AS the button for the wish list, there is no icon")
                                                             height:height
                                                             target:self
                                                           selector:@selector(displayWishlist)
                                                            divider:YES];
  
  self.navButtonCompare = [ATGBarButtonItem barButtonItemWithTitle:NSLocalizedStringWithDefaultValue(@"ATGRootViewController_iPad.NavigationBar.CompareBarButton.Title", nil, [NSBundle mainBundle], @"Compare", @"String which is rendered AS the button for product compare, there is no icon")
                                                            height:height
                                                            target:self
                                                          selector:@selector(displayCompare)
                                                            divider:YES];
  
  self.navButtonCart = [ATGBarButtonItem barButtonItemFromImageNamed:NavBarCartImageName
                                                  accessibilityLabel:[ATGShoppingCartViewController toolbarAccessibilityLabel]
                                                              height:height
                                                              target:self
                                                            selector:@selector(displayCart)
                                                              divider:YES];
  
  self.navButtonProfile = [ATGBarButtonItem barButtonItemFromImageNamed:NavBarProfileImageName
                                                     accessibilityLabel:[ATGProfileViewController toolbarAccessibilityLabel]
                                                                 height:height
                                                                 target:self
                                                               selector:@selector(displayProfile)
                                                                divider:YES];
  
  self.navButtonMore = [ATGBarButtonItem barButtonItemFromImageNamed:NavBarMoreImageName
                                                  accessibilityLabel:[ATGMoreViewController_iPad toolbarAccessibilityLabel]
                                                              height:height
                                                              target:self
                                                            selector:@selector(displayMore)
                                                             divider:NO];
  
  NSArray *rightBarButtonItems = @[self.navButtonMore, self.navButtonProfile, self.navButtonCart, self.navButtonCompare, self.navButtonWishlist, self.navButtonGiftlist];
  [self.navigationItem setRightBarButtonItems:rightBarButtonItems];

  [self setupPopovers];
}

#pragma mark - ATGSearchBoxDelegate

// Show cancel button, modify nav bar etc.
- (void)searchBoxWillBeginEditing:(ATGSearchBox *)pSearchBox withCancelButton:(UIButton *)pCancelButton typeaheadTable:(UITableView *)pTypeaheadTable {
  pCancelButton.frame = self.view.bounds;
  [self.view addSubview:pCancelButton];

  pTypeaheadTable.frame = CGRectMake(0, 0, 350, self.view.bounds.size.height);

  UIViewController *typeaheadVC = [[UIViewController alloc] init];
  [typeaheadVC.view addSubview:pTypeaheadTable];

  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:typeaheadVC];
  navController.view.backgroundColor = [UIColor clearColor];
  navController.view.frame = typeaheadVC.view.frame;
  [navController setNavigationBarHidden:YES];
  self.searchAutoSuggestions = navController;
  // we'll present the popover when there's actually auto-complete suggestions in the table view
  [pTypeaheadTable addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:kObserverContextSearchCompletion];
  [pTypeaheadTable addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:kObserverContextSearchCompletion];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (context == kObserverContextSearchCompletion) {
    UITableView *searchCompletions = (UITableView *)object;
    if (searchCompletions.contentSize.height == 0 || searchCompletions.hidden) {
      // dismiss popover by setting it to nil
      self.navButtonSearch.popover = nil;
    } else if (self.searchAutoSuggestions && searchCompletions.contentSize.height > 0 && !self.navButtonSearch.popover) {
      self.navButtonSearch.popover = [[UIPopoverController alloc] initWithContentViewController:self.searchAutoSuggestions];
      [self.navButtonSearch.popover setPopoverContentSize:searchCompletions.contentSize animated:YES];
      [self displayPopoverFromBarButton:self.navButtonSearch];
    } else {
      [self.navButtonSearch.popover setPopoverContentSize:searchCompletions.contentSize animated:YES];
    }
  }
  else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

//Hide cancel button, modify nav bar etc.
- (void)searchBoxDidEndEditing:(ATGSearchBox *)pSearchBox withCancelButton:(UIButton *)pCancelButton typeaheadTable:(UITableView *)pTypeaheadTable {
  [pTypeaheadTable removeFromSuperview];
  self.navButtonSearch.popover = nil;
  [pCancelButton removeFromSuperview];
  self.searchAutoSuggestions = nil;
}

//Submit this if you want
- (void)searchBox:(ATGSearchBox *)pSearchBox didConstructSearchAction:(EMAction *)pSearchAction {
  [self displaySearchAction:pSearchAction];
}

- (void)displaySearchAction:(EMAction *)pSearchAction {
  // update the search box text if user clicked on an auto-complete suggestion
  if ([pSearchAction isKindOfClass:[EMNavigationAction class]] && ((EMNavigationAction *)pSearchAction).label) {
    [self.searchBoxView setSearchTerm:((EMNavigationAction *)pSearchAction).label];
  }
  
  self.searchController = [[ATGSearchViewController_iPad alloc] init];
  [self.searchController loadPageForAction:pSearchAction];

  [self switchToViewController:self.searchController];
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
  if (popoverController == self.navButtonSearch.popover) {
    [self.searchBoxView dismiss];
  } else {
    self.popover = nil;
  }
  return NO;
}

#pragma mark - Public protocol implementation

- (void) displayHomepage {
  self.popover = nil;
  if (self.childViewControllers.count > 0 && [self.childViewControllers lastObject] == self.homeController) {
    // home page is already current view, so just reload
    [self reloadHomepage];
  } else {
    [self switchToViewController:self.homeController];
  }
}

- (void) reloadHomepage {
  [self.homeController viewWillAppear:YES];
}

- (void) reloadBrowse {
  self.browseController = nil;
}

- (void) displayDetailsForProductId:(NSString *)pProductId inList:(NSArray *)pList {
  self.productPageController = [[ATGCommerceProductPageViewController alloc] initWithProductId:pProductId productList:pList];
  [self pushViewController:self.productPageController];
}

- (void) displayDetailsForProductId:(NSString *)pProductId withProductStack:(id<ATGProductDetailsStackDataSource>)pStack {
  self.productPageController = [[ATGCommerceProductPageViewController alloc] initWithProductId:pProductId dataSource:pStack];
  [self pushViewController:self.productPageController];
}

- (void) displayDetailsForProduct:(id<RenderableProduct>)pProduct inList:(NSArray *)pList {
  [self displayDetailsForProductId:pProduct.uniqueID inList:pList];
}

- (void) displayDetailsForCommerceItem:(ATGCommerceItem *)pCommerceItem {
  [self displayDetailsForCommerceItem:pCommerceItem fromOrderHistory:NO];
}

- (void) displayDetailsForCommerceItem:(ATGCommerceItem *)pCommerceItem fromOrderHistory:(BOOL)pFromOrderHistory {
  self.productPageController = [[ATGCommerceProductPageViewController alloc] initWithCommerceItem:pCommerceItem commerceItemList:@[pCommerceItem]];
  self.productPageController.launchedFromOrderHistory = pFromOrderHistory;
  [self pushViewController:self.productPageController];
}

#pragma mark - Navigation button actions

- (void) displayBrowse {
  if (!self.browseController) {
    ATGBrowseViewController_iPad *browse = [[ATGBrowseViewController_iPad alloc] initWithAction:[[ATGConfigurationManager sharedManager] rootAction]];
    browse.reloadContentPath = @"$.contents.SecondaryContent";
    self.browseController = [[UINavigationController alloc] initWithRootViewController:browse];
    self.browseResultsController = [[ATGBrowseResultsViewController alloc] init];
    browse.rootViewController = self.browseResultsController;
    
    self.searchController = [[ATGSearchViewController_iPad alloc] init];
    [self.searchController loadPageForAction:[[ATGConfigurationManager sharedManager] rootAction]];

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.viewControllers = @[self.browseController, self.browseResultsController];
    self.splitViewController.delegate = self;
    [self switchToViewController:self.splitViewController];
  }  else {
    [self.browseResultsController.collectionView.collectionViewLayout invalidateLayout];
    if ([self.childViewControllers objectAtIndex:0] == self.splitViewController) {
      [self switchToViewController:self.browseResultsController];
    } else {
      self.splitViewController.viewControllers = @[self.browseController, self.browseResultsController];
      self.splitViewController.view.frame = self.view.bounds; // in case orientation changed while not being displayed
      [self switchToViewController:self.splitViewController];
    }
  }

  // if iOS 7, shift frame down 64 pts so that the header does not overlap the content
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    CGRect shiftedFrame = self.splitViewController.view.frame;
    shiftedFrame.origin.y = 64;
    self.splitViewController.view.frame = shiftedFrame;
  }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
  return NO;
}

- (void) displayWishlist {
  [self displayPopoverFromBarButton:self.navButtonWishlist];
}

- (void) displayGiftlist {
  [self displayPopoverFromBarButton:self.navButtonGiftlist];
}

- (void) displayGiftlistControllerForGiftList:(ATGGiftList *)pGiftList allowsEditing:(BOOL)editable {
  NSString *controllerIdentifier = ATGOtherUserGiftListItemsNavViewControllerId;
  if (editable) {
    controllerIdentifier = ATGGiftListItemsNavViewControllerId;
  }
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGGiftListStoryboard bundle:nil];
  ATGResizingNavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
  ATGGiftListItemsViewController *itemsController = [controller.viewControllers objectAtIndex:0];
  itemsController.giftList = pGiftList;
  self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  [self.popover presentPopoverFromBarButtonItem:self.navButtonGiftlist permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) displayCompare {
  [self displayPopoverFromBarButton:self.navButtonCompare];
}

- (void) displayProfile {
  
  if (self.navButtonProfile.popover && self.navButtonProfile.popover == self.popover) {
    self.navButtonProfile.popover = nil;
    self.popover = nil;
    return;
  }
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
  ATGResizingNavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:ATGNavigationController];
  self.navButtonProfile.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  controller.popoverController = self.navButtonProfile.popover;
  
  [self displayPopoverFromBarButton:self.navButtonProfile];
}

- (void) displayProfileOrders {
  [self displayProfile];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
  UIViewController *orders = [storyboard instantiateViewControllerWithIdentifier:ATGSceneIdOrders];
  [((UINavigationController *)self.popover.contentViewController) pushViewController:orders animated:YES];
}

- (void) displayDetailsForOrderId:(NSString *)pOrderId {
  [self displayProfileOrders];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
  ATGOrderDetailsViewController_iPad *orderDetails = [storyboard instantiateViewControllerWithIdentifier:ATGSceneIdOrderDetails];
  orderDetails.orderID = pOrderId;
  [((UINavigationController *)self.popover.contentViewController) pushViewController:orderDetails animated:YES];
}

- (void) displayMore {
  if (!self.navButtonMore.popover) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardMore bundle:[NSBundle mainBundle]];
    ATGResizingNavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:ATGNavigationController];
    self.navButtonMore.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    controller.popoverController = self.navButtonMore.popover;
  }
  [self displayPopoverFromBarButton:self.navButtonMore];
}

- (void) displayCart {
  
  if (self.navButtonCart.popover && self.navButtonCart.popover == self.popover) {
    self.navButtonCart.popover = nil;
    self.popover = nil;
    return;
  }
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardCheckout bundle:nil];
  ATGResizingNavigationController *controller = [storyboard instantiateInitialViewController];
  self.navButtonCart.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  controller.popoverController = self.navButtonCart.popover;
  
  [self displayPopoverFromBarButton:self.navButtonCart];
}

- (void) displayPopoverFromBarButton:(ATGBarButtonItem *)pButton {
  if (self.popover == pButton.popover) {
    // we're already showing our popover, dismiss it
    self.popover = nil;
    return;
  }
  [self.view endEditing:YES];
  self.popoverButton = pButton;
  self.popover = pButton.popover;
  self.popover.delegate = self;
  [self.popover presentPopoverFromBarButtonItem:pButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) setupPopovers {
  // giftlist
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGGiftListStoryboard bundle:nil];
  ATGResizingNavigationController *controller = [storyboard instantiateInitialViewController];
  self.navButtonGiftlist.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  controller.popoverController = self.navButtonGiftlist.popover;

  // wishlist
  storyboard = [UIStoryboard storyboardWithName:ATGGiftListStoryboard bundle:nil];
  controller = [storyboard instantiateViewControllerWithIdentifier:ATGWishListControllerID];
  self.navButtonWishlist.popover = [[UIPopoverController  alloc] initWithContentViewController:controller];
  controller.popoverController = self.navButtonWishlist.popover;

  // compare
  controller = [self.storyboard instantiateViewControllerWithIdentifier:ATGCompareController];
  self.navButtonCompare.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  controller.popoverController = self.navButtonCompare.popover;
}

@end
