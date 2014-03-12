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

#import "MobileCommerceAppDelegate.h"
#import "ATGConnectionListener.h"
#import "ATGLoginViewController.h"
#import "ATGMobileCommerceAccessHandler.h"
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGAccessHandler.h>
#import <ATGMobileClient/ATGKeychainManager.h>
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileCommon/ATGCacheManagedDocument.h>

@interface MobileCommerceAppDelegate()
@property NSInteger currentViewTypeId;
@property (nonatomic, strong) UIViewController *navigationViewController;
@property (nonatomic, strong) UIViewController *visualizerViewController;
@end

@implementation MobileCommerceAppDelegate

void uncaughtExceptionHandler(NSException *exception) {
  NSLog(@"Uncaught exception: %@", exception);
  if ([NSInternalInconsistencyException isEqualToString:exception.name]) {
    //CoreData issue, should delete and reinstall.
    NSLog(@"There was an error reading from the application bundle. The app should be deleted and reinstalled.");
  }
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  appResignedActive = NO;
  
  // Apply the styles defined in our Theme.json file using ATGThemeManager
  [[ATGThemeManager themeManager] applyAllStyles];

  ATGMobileCommerceAccessHandler *accessHandler = [[ATGMobileCommerceAccessHandler alloc] init];
  [[ATGAccessHandler accessHandler] setDelegate: accessHandler];
  
  // instantiate the core data document.
  ATGCacheManagedDocument *document = [ATGCacheManagedDocument sharedDocument];
  [document execute: nil];
  
  // get settings defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([self isPhone]) {
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    
    self.tabBarController = (ATGTabBarController *)self.window.rootViewController;
    accessHandler.tabBarController = self.tabBarController;
  } else if ([self isPad]) {
    // check if we want to display json visualizer or the store based on user settings
    NSInteger typeId = [defaults integerForKey:@"viewType"];
    UIStoryboard *sb = [[self.window rootViewController] storyboard];
    self.navigationViewController = self.window.rootViewController;
    self.visualizerViewController = [sb instantiateViewControllerWithIdentifier:@"ATGJSONPathVisualizerViewController"];
    
    if (typeId == 0) {
      [self.window setRootViewController:self.navigationViewController];
    } else if (typeId == 1) {
      [self.window setRootViewController:self.visualizerViewController];
    }
    self.currentViewTypeId = typeId;
  }
  
  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
  
  //getting current system language. If language was changed, than clear product cache.
  NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
  NSString *currentLanguage = [languages objectAtIndex:0];
  
  if (![[[ATGKeychainManager instance] stringForKey:ATG_KEYCHAIN_LOCALE_PROPERTY] isEqualToString:currentLanguage]) {
    [[ATGProductManager productManager] clearCache];
  }
  [[ATGKeychainManager instance] setString:currentLanguage forKey:ATG_KEYCHAIN_LOCALE_PROPERTY];
  
  // Start listening for internet connection status.
  [[ATGConnectionListener instance] startListening];
  
  return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application {
  appResignedActive = YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
  if ([self isPad]) {
    // check if we want to display json visualizer or the store based on user settings
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Need to do this in order to get the latest changes.
    // The auto-infromation saving for defaults has a schedule of its own and does not always refresh by the time we get here.
    // We are basically forcing a re-sync so we get the latest settings whenever we are reading/using them.
    [defaults synchronize];
    NSInteger typeId = [defaults integerForKey:@"viewType"];
    
    if (self.currentViewTypeId != typeId) {
      if (typeId == 0) {
        [self.window setRootViewController:self.navigationViewController];
      } else if (typeId == 1) {
        [self.window setRootViewController:self.visualizerViewController];
      }
      self.currentViewTypeId = typeId;
    }
  }
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
  if ([self isPhone]) {
    if (appResignedActive) {
      UIViewController *currentViewController = self.tabBarController.selectedViewController;
      if (currentViewController.presentedViewController) {
        [currentViewController dismissLoginViewControllerAnimated:YES];
      } else if ([currentViewController respondsToSelector:@selector(reloadData)]) {
        [currentViewController performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
      }
    }
    
    [self.tabBarController updateCartItemsCount];
    appResignedActive = NO;
  } else if ([self isPad]) {
    ATGRootViewController_iPad *rootViewController = (ATGRootViewController_iPad *)self.navigationViewController.presentingViewController;
    [rootViewController updateCartItemsCount];
  }
}

- (void) awakeFromNib {
}

@end
