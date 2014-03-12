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



#import "ATGTabBarController.h"
#import <ATGMobileClient/ATGCommerceManager.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGSearchViewController.h>
#import "ATGShoppingCartViewController.h"
#import "ATGProfileViewController.h"
#import "ATGStoreTableController.h"
#import "ATGSitesListViewController.h"
#import <ATGMobileClient/ATGStoreManager.h>
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGMobileClient/ATGHomeViewController.h>


#import "ATGAccountViewController.h"

NSString *const ATG_TAB_BAR_TAG_ORDER_ID = @"ATG_TAB_BAR_TAG_ORDER_ID";

static NSString *const ATGStoryboardProfile = @"ProfileStoryboard_iPad";

@interface ATGTabBarController () <ATGCommerceManagerDelegate, UITabBarControllerDelegate, ATGSitesListViewControllerDelegate>
@property (weak, nonatomic) ATGNavigationController *homeViewController;
@property (weak, nonatomic) ATGNavigationController *cartViewController;
@property (weak, nonatomic) ATGNavigationController *profileViewController;

@property (nonatomic, strong)  ATGCommerceManagerRequest *updateItemsRequest;

// Callback method to be called when shopping cart is changed.
- (void) shoppingCartChangedNotification:(NSNotification *)notification;

@end

@implementation ATGTabBarController

-(void)viewDidLoad{
  [super viewDidLoad];
  self.delegate = self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(shoppingCartChangedNotification:)
                                               name:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                                             object:nil];
  
  //Set this before we restore the users order
  self.homeViewController = self.viewControllers[0];
  self.cartViewController = self.viewControllers[2];
  self.profileViewController = self.viewControllers[4];
  
  //Set text for tab bar items
  
  //Home
  [self.viewControllers[0] tabBarItem].title = [ATGHomeViewController toolbarAccessibilityLabel];
  [self.viewControllers[0] tabBarItem].accessibilityHint = [ATGHomeViewController toolbarAccessibilityLabel];
  //Search
  [self.viewControllers[1] tabBarItem].title = [ATGSearchViewController toolbarAccessibilityLabel];
  [self.viewControllers[1] tabBarItem].accessibilityHint = [ATGSearchViewController toolbarAccessibilityLabel];
  //Cart
  [self.viewControllers[2] tabBarItem].title = [ATGShoppingCartViewController toolbarAccessibilityLabel];
  [self.viewControllers[2] tabBarItem].accessibilityHint = [ATGShoppingCartViewController toolbarAccessibilityLabel];
  //Stores
  [self.viewControllers[3] tabBarItem].title = [ATGStoreTableController toolbarAccessibilityLabel];
  [self.viewControllers[3] tabBarItem].accessibilityHint = [ATGStoreTableController toolbarAccessibilityLabel];
  //Profile
  NSMutableArray *viewC = [self.viewControllers mutableCopy];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ATGStoryboardProfile bundle:nil];
  ATGAccountViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ATGAccountViewController"];
  [viewC insertObject:controller atIndex:4];
  self.viewControllers = [NSArray arrayWithArray:viewC];
  
  [self.viewControllers[4] tabBarItem].title = [ATGProfileViewController toolbarAccessibilityLabel];
  [self.viewControllers[4] tabBarItem].accessibilityHint = [ATGProfileViewController toolbarAccessibilityLabel];
  
  //More
  [self.viewControllers[5] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.ContactUsTitle", nil, [NSBundle mainBundle],
   @"Contact Us", @"Title to be displayed on the 'Contact Us' row.");
  
  [self.viewControllers[6] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.ShippingReturnsRowTitle", nil, [NSBundle mainBundle],
   @"Shipping + Returns", @"Title to be displayed on the 'Shipping+Returns' row.");
  
  [self.viewControllers[7] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.PrivacyTermsRowTitle", nil, [NSBundle mainBundle],
   @"Privacy + Terms", @"Title to be displayed on the 'Privacy+Terms' row.");
  
  [self.viewControllers[8] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.AboutUsRowTitle", nil, [NSBundle mainBundle],
   @"About Us", @"Title to be displayed on the 'About Us' row.");
  
  [self.viewControllers[9] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.AvailableSites", nil, [NSBundle mainBundle],
   @"Available Sites", @"Title to be displayed on the 'Available Sites' row.");
  ATGSitesListViewController *sitesViewController = self.viewControllers[9];
  sitesViewController.delegate = self;

  [self.viewControllers[10] tabBarItem].title = NSLocalizedStringWithDefaultValue
  (@"ATGMoreViewController.Copyright", nil, [NSBundle mainBundle],
  @"Copyright", @"Title to be displayed on the 'Copyright' row.");
  
  //Set customizableViewControllers to nil if you don't want to allow tab order editing
  self.customizableViewControllers = nil;
  
  //Handle if order has changed
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *vcTagOrder = [defaults arrayForKey:ATG_TAB_BAR_TAG_ORDER_ID];
  if(vcTagOrder != nil){
    NSMutableArray *newVCOrder = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
    for(NSNumber *tag in vcTagOrder){
      [newVCOrder addObject:self.viewControllers[[tag intValue]]];
    }
    self.viewControllers = newVCOrder;
  }
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION object:nil];
  // No need to query the server anymore.
  [[self updateItemsRequest] setDelegate:nil];
  [[self updateItemsRequest] cancelRequest];
}

- (void) updateCartItemsCount {
  [self.updateItemsRequest setDelegate:nil];
  [self.updateItemsRequest cancelRequest];
  self.updateItemsRequest = [[ATGCommerceManager commerceManager] getCartItemCount:self];
}

- (ATGNavigationController *) switchToHomeScreen{
  [self.homeViewController popToRootViewControllerAnimated:NO];
  self.selectedViewController = self.homeViewController;
  return self.homeViewController;
}

- (ATGNavigationController *) switchToProfileScreen{
  self.selectedViewController = self.profileViewController;
  return self.profileViewController;
}

- (ATGNavigationController *) switchToCartScreen{
  [self.cartViewController popToRootViewControllerAnimated:NO];
  self.selectedViewController = self.cartViewController;
  return self.cartViewController;
}

- (void) reloadHomeScreen {
  for (UIViewController * controller in self.homeViewController.viewControllers) {
    if ([controller isKindOfClass:[ATGHomeViewController class]]) {
      [((ATGHomeViewController *)controller).collectionView reloadData];
      break;
    }
  }
}

- (void) shoppingCartChangedNotification:(NSNotification *)pNotification {
  // Get numer of cart items and put it onto proper toolbar button.
  NSInteger count = [(NSNumber *)[[pNotification userInfo]
                                  objectForKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY] integerValue];

  if (count > 0)
    self.cartViewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",count];
  else
    self.cartViewController.tabBarItem.badgeValue = nil;
}

-(void)tabBarController:(UITabBarController *)pTabBarController didSelectViewController:(UIViewController *)pViewController{
  if (pViewController == self.cartViewController) {
    //Pop to root on the shopping cart tab to make sure they arn't in the middle of the check out flow.
    [pViewController.navigationController popToRootViewControllerAnimated:NO];
  }
}

-(void)tabBarController:(UITabBarController *)pTabBarController didEndCustomizingViewControllers:(NSArray *)pViewControllers changed:(BOOL)pChanged{
  if (pChanged) {
    //Save
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *order = [NSMutableArray arrayWithCapacity:pViewControllers.count];
    for(UIViewController *vc in pViewControllers  ){
      [order addObject:[NSNumber numberWithInt:vc.tabBarItem.tag]];
    }
    [defaults setObject:order forKey:ATG_TAB_BAR_TAG_ORDER_ID];
    [defaults synchronize];
  }
}

#pragma mark - ATGSitesListViewControllerDelegate

- (void) viewController:(ATGSitesListViewController *)pController didSelectSiteWithId:(NSString *)pSiteId {
  [[ATGStoreManager storeManager] restManager].currentSite = pSiteId;
  [[ATGStoreManager storeManager] clearCache];
  [self.viewControllers[1] popToRootViewControllerAnimated:NO];
  [self reloadHomeScreen];
  [self switchToHomeScreen];
}

@end
