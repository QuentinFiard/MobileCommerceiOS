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

#import "ATGIpadViewController.h"
#import "ATGProfileViewController.h"
#import "ATGResizingNavigationController.h"
#import "ATGHomeViewController_iPad.h"
#import "ATGShoppingCartViewController_iPad.h"
#import "ATGAccountViewController.h"
#import "ATGOrderDetailsViewController_iPad.h"

static NSString *const ATGStoryboardProfile = @"ProfileStoryboard_iPad";
static NSString *const ATGSceneIdOrders = @"ATGOrdersViewController";
static NSString *const ATGSceneIdOrderDetails = @"ATGOrderDetailsViewController_iPad";

#define ATGHomePageController @"ATGHomeViewController"
#define ATGCompareController @"ATGCompareController"

NSString *const ATG_PRESENT_SHOPPING_CART_NOTIFICATION = @"ATGShoppingCartWillBePresented";

NSString *const ATG_RELOAD_HOME_PAGE_NOTIFICATION = @"ATGHomePageWillBeReloaded";

@interface ATGIpadViewController () <ATGProductDetailsStackCallbacks, UIPopoverControllerDelegate>
{
  BOOL next;
}
/*!
   @property popover
   @abstract Link to popover controller, if popover was displayed on screen
 */
@property (nonatomic, strong) UIPopoverController *popover;
/*!
   @property ownerButton
   @abstract Link for button in toolbar, which base for popover
 */
@property (nonatomic, weak) UIButton *ownerButton;
@property (nonatomic, strong) ATGProductDetailsStack *stack;
@property (nonatomic, strong) ATGProductPageViewController *productPage;
@property (nonatomic, strong) UIViewController *viewController;

- (void) shoppingCartHaveToBePresented;
- (void) reloadHomePage;
@end

@implementation ATGIpadViewController
@synthesize toolbar = _toolbar, popover = _popover, ownerButton = _ownerButton, baseView = _baseView, stack, productPage, viewController;

- (void) viewDidLoad {
  [super viewDidLoad];
  _toolbar = [[ATGMainToolbar alloc] init];
  _toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
  _toolbar.delegate = self;
  [_toolbar setToolbarItems];
  [self.view addSubview:_toolbar];

  self.viewController =  [self.storyboard instantiateViewControllerWithIdentifier:ATGHomePageController];
  [( (ATGHomeViewController_iPad *)self.viewController ) setDelegate:self];
  [self addChildViewController:self.viewController];
  [self.viewController didMoveToParentViewController:self];
  viewController.view.frame = _baseView.bounds;
  [_baseView addSubview:self.viewController.view];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(shoppingCartHaveToBePresented:)
                                               name:ATG_PRESENT_SHOPPING_CART_NOTIFICATION
                                             object:nil];
  //invoke this notification if you just have done action that required home page reloading
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reloadHomePage)
                                               name:ATG_RELOAD_HOME_PAGE_NOTIFICATION
                                             object:nil];
}

- (void) viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

#pragma mark - Rotate actions
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [_toolbar changeSearchWidthForOrientation:toInterfaceOrientation];
  CGRect frame = _toolbar.frame;
  if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
    frame.size.width = 1024;
  } else {
    frame.size.width = 768;
  }

  [_toolbar setFrame:frame];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  //re-display popover after rotation at correct place
  if ([_popover isPopoverVisible]) {
    [_popover dismissPopoverAnimated:NO];
    CGRect rect = [self.view convertRect:_ownerButton.frame fromView:_ownerButton.superview];
    [_popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    return;
  }
}

#pragma mark - Notification methods
- (void) shoppingCartHaveToBePresented:(id)pFlag {
  [self didDisplayCartSelected:[[self.toolbar.items objectAtIndex:22] customView]];
  if (pFlag) {
    [self didCloseButtonPressed];
  }
}

- (void) reloadHomePage {
  [self didDisplayHomePageSelected:nil];
}

#pragma mark - Toolbar delegate
- (void) didTouchBrowseButton:(id)pSender {
  if ([_popover isPopoverVisible]) {
    return;
  } else {
    //initialize controller
//    ATGSomeController *someController = [[ATGSomeController alloc] init];
//    _mPopover = [[UIPopoverController alloc]
//                 initWithContentViewController:someController];

//    CGRect rect = [self.view convertRect:[(UIButton*)pSender frame] fromView:[(UIButton*)pSender superview]];
//    [_mPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    _mOwnerButton = (UIButton*)pSender;
  }
}

- (void) didDisplaySiteSelected:(id)pSender {
  //implement action
}

- (void) didDisplayHomePageSelected:(id)pSender {
  [self.viewController removeFromParentViewController];
  [self.viewController.view removeFromSuperview];

  self.viewController =  [self.storyboard instantiateViewControllerWithIdentifier:ATGHomePageController];
  [( (ATGHomeViewController_iPad *)self.viewController ) setDelegate:self];
  [self addChildViewController:self.viewController];
  [self.viewController didMoveToParentViewController:self];
  viewController.view.frame = _baseView.bounds;
  [_baseView addSubview:self.viewController.view];
}

- (void) didDisplayCartSelected:(id)pSender {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CheckoutStoryboard_iPad" bundle:nil];
  ATGResizingNavigationController *rootController = [storyboard instantiateInitialViewController];
  ATGShoppingCartViewController_iPad *cntr = [rootController.viewControllers objectAtIndex:0];
  cntr.pdpDelegate = self;
  [[self popover] dismissPopoverAnimated:YES];
  [self setPopover:[[UIPopoverController alloc] initWithContentViewController:rootController]];
  self.popover.delegate = self;
  [rootController setPopoverController:[self popover]];
  [[self popover] presentPopoverFromRect:[(UIButton *) pSender bounds]
                                  inView:pSender
                permittedArrowDirections:UIPopoverArrowDirectionUp
                                animated:YES];
  [self setOwnerButton:pSender];
}

- (void) didDisplayWishListSelected:(id)pSender {
  //implement action
}

- (void) didDisplayGiftListSelected:(id)pSender {
  //implement action
}

- (void) didDisplayCompareSelected:(id)pSender {
  ATGResizingNavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:ATGCompareController];
  ATGCompareViewController *cntr = [navigation.viewControllers objectAtIndex:0];
  cntr.delegate = self;

  self.popover = [[UIPopoverController alloc] initWithContentViewController:navigation];
  self.popover.delegate = self;
  CGRect rect = [self.view convertRect:[(UIButton *) pSender frame] fromView:[(UIButton *) pSender superview]];
  [self.popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  _ownerButton = (UIButton *)pSender;
  navigation.popoverController = self.popover;
}

- (void) didDisplayProfileSelected:(id)pSender {
  UIStoryboard *sb = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:[NSBundle mainBundle]];
  ATGResizingNavigationController *controller = [sb instantiateViewControllerWithIdentifier:@"ATGNavigationController"];
  [[self popover] dismissPopoverAnimated:YES];
  self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
  self.popover.delegate = self;
  CGRect rect = [self.view convertRect:[(UIButton *) pSender frame] fromView:[(UIButton *) pSender superview]];
  [self.popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  _ownerButton = (UIButton *)pSender;
  controller.popoverController = _popover;
}

- (void) didDisplayMoreSelected:(id)pSender {
  {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MoreStoryboard_iPad" bundle:[NSBundle mainBundle]];
    ATGResizingNavigationController *controller = [sb instantiateViewControllerWithIdentifier:@"ATGNavigationController"];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    CGRect rect = [self.view convertRect:[(UIButton *) pSender frame] fromView:[(UIButton *) pSender superview]];
    [_popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _ownerButton = (UIButton *)pSender;
    controller.popoverController = _popover;
  }
}

#pragma mark - Compare view callback
- (void) didViewProductSelected:(NSString *)pProductId listItems:(NSArray *)pList commerceInfo:(NSDictionary *)pDict {
  [self.productPage removeFromParentViewController];
  [self.productPage.view removeFromSuperview];

  UIViewController *controller = [self.childViewControllers objectAtIndex:0];
  self.stack = [[ATGProductDetailsStack alloc] initWithProducts:pList currentID:pProductId];
  self.productPage = [[ATGProductPageViewController alloc] initWithProduct:[self.stack currentProductDetails] withSku:[pDict objectForKey:@"selectedSku"] quantity:[pDict objectForKey:@"quantity"] commerceItem:[pDict objectForKey:@"commerceItem"]];
  if (pDict != nil) {
    self.productPage.lastProduct = YES;
    self.productPage.firstProduct = YES;
  } else if (![self.stack hasNextProductDetails]) {
    self.productPage.lastProduct = YES;
  } else if (![self.stack hasPreviousProductDetails]) {
    self.productPage.firstProduct = YES;
  }
  self.productPage.delegate = self;
  [controller addChildViewController:self.productPage];
  [self.productPage didMoveToParentViewController:self];

  [self.popover dismissPopoverAnimated:NO];
  // set up an animation for presenting pdp

  [[self.productPage.view layer] addAnimation:[CATransition transitionForPresenting] forKey:@"PresentingPDP"];
  [controller.view addSubview:self.productPage.view];
}

#pragma mark - Product Page callbacks
- (void) didNextButtonPressed {
  if ([self.stack hasNextProductDetails]) {
    next = YES;
    [self.stack nextProductDetailsForObject:self];
  }
}

- (void) didPreviousButtonPressed {
  if ([self.stack hasPreviousProductDetails]) {
    next = NO;
    [self.stack previousProductDetailsForObject:self];
  }
}

- (void) didCloseButtonPressed {
  [self.productPage removeFromParentViewController];

  // set up an animation for closing pdp

  [[self.view layer] addAnimation:[CATransition transitionForDissmiss] forKey:@"ClosingPDP"];
  [self.productPage.view removeFromSuperview];

  if (self.ownerButton != nil) {
    CGRect rect = [self.view convertRect:self.ownerButton.frame fromView:self.ownerButton.superview];
    [self.popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
}

#pragma mark - Product stack callbacks
- (void) productDetailsStack:(ATGProductDetailsStack *)stack didGetProductDetails:(ATGGenericProductDetails *)details {
  [self.productPage removeFromParentViewController];
  [self.productPage.view removeFromSuperview];

  UIViewController *controller = [self.childViewControllers objectAtIndex:0];
  self.productPage = [[ATGProductPageViewController alloc] initWithProduct:details withSku:nil quantity:nil commerceItem:nil];

  if (![self.stack hasNextProductDetails]) {
    self.productPage.lastProduct = YES;
  } else if (![self.stack hasPreviousProductDetails]) {
    self.productPage.firstProduct = YES;
  }

  [controller addChildViewController:self.productPage];
  [self.productPage didMoveToParentViewController:self];
  self.productPage.delegate = self;

  [controller.view addSubview:self.productPage.view];

  //apply different animation regarding we moved forward or back in stack
  if (next) {
    [[self.productPage.innerView layer] addAnimation:[CATransition transitionForForwardNavigation] forKey:@"PresentingNextPDP"];
  } else {
    [[self.productPage.innerView layer] addAnimation:[CATransition transitionForBackwardNavigation] forKey:@"PresentingPreviousPDP"];
  }
}

#pragma mark - UIPopoverController delegate
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  self.ownerButton = nil;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Protocol Implementation

- (void) displayProfileScreen {
  NSUInteger profileItemIndex = [[[self toolbar] items]
                                 indexOfObjectPassingTest: ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop) {
                                   UIBarButtonItem *item = (UIBarButtonItem *)pObject;
                                   UIView *customView = [item customView];
                                   if ([customView isKindOfClass:[UIButton class]]) {
                                     UIButton *button = (UIButton *)customView;
                                     NSArray *actions = [button actionsForTarget:self
                                                                 forControlEvent:UIControlEventTouchUpInside];
                                     for (NSString *action in actions) {
                                       SEL selector = NSSelectorFromString (action);
                                       if ( selector == @selector(didDisplayProfileSelected:) ) {
                                         *pStop = YES;
                                         return YES;
                                       }
                                     }
                                   }
                                   return NO;
                                 }
                                ];
  UIBarButtonItem *profileItem = [[[self toolbar] items] objectAtIndex:profileItemIndex];
  [self didDisplayProfileSelected:[profileItem customView]];
}

- (void) displayMyOrdersScreen {
  [self displayProfileScreen];
  UINavigationController *contentController =
    (UINavigationController *)[[self popover] contentViewController];
  // Content view controller might be changed due to expired session,
  // in this case instead of Profile screen there would be displayed Login screen.
  // So we're updating the content controller only if Profile screen is actually presented.
  if ([[[contentController viewControllers] objectAtIndex:0]
       isKindOfClass:[ATGAccountViewController class]]) {
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
    UIViewController *myOrdersController =
      [profileStoryboard instantiateViewControllerWithIdentifier:ATGSceneIdOrders];
    [contentController pushViewController:myOrdersController animated:YES];
  }
}

- (void) displayOrderDetailsScreenForOrder:(NSString *)pOrderID {
  [self displayProfileScreen];
  UINavigationController *contentController =
    (UINavigationController *)[[self popover] contentViewController];
  // Content view controller might be changed due to expired session,
  // in this case instead of Profile screen there would be displayed Login screen.
  // So we're updating the content controller only if Profile screen is actually presented.
  if ([[[contentController viewControllers] objectAtIndex:0]
       isKindOfClass:[ATGAccountViewController class]]) {
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
    UIViewController *myOrdersController =
      [profileStoryboard instantiateViewControllerWithIdentifier:ATGSceneIdOrders];
    [contentController pushViewController:myOrdersController animated:NO];
    [[contentController delegate] navigationController:contentController
                                willShowViewController:myOrdersController
                                              animated:NO];
    ATGOrderDetailsViewController_iPad *orderDetailsController =
      [profileStoryboard instantiateViewControllerWithIdentifier:ATGSceneIdOrderDetails];
    [orderDetailsController setOrderID:pOrderID];
    [contentController pushViewController:orderDetailsController animated:YES];
  }
}

@end