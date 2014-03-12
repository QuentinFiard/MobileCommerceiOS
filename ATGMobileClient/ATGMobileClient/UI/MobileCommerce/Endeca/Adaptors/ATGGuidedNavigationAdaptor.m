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

#import "ATGGuidedNavigationAdaptor.h"
#import <EMMobileClient/EMGuidedNavigation.h>
#import <EMMobileClient/EMResultsList.h>
#import <EMMobileClient/EMRangeFilterBreadcrumb.h>
#import <EMMobileClient/EMAdaptorManager.h>
#import "ATGBrowseViewController.h"
#import <EMMobileClient/EMSearchBox.h>
#import <EMMobileClient/EMNavigationAction.h>
#import <EMMobileClient/EMBreadcrumbs.h>
#import "ATGSearchBoxAdaptor.h"
#import "ATGContentPathLookupManager.h"
#import "ATGSearchRootViewController.h"
#import "ATGConfigurationManager.h"

@interface ATGGuidedNavigationAdaptor ()
@property (nonatomic, strong) EMGuidedNavigation *contentItem;
@end

@implementation ATGGuidedNavigationAdaptor
@synthesize contentItem = _contentItem;

- (void)layoutContents {
  [self layoutContentsForKey:@"navigation"];
  
  EMResultsList *resultsList = nil;
  id retval = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$.contents.MainContent.contents[?(@.name=Results List)]" inRootContentItem:self.controller.rootContentItem];
  
  if ([retval isKindOfClass:[EMResultsList class]]) {
    resultsList = (EMResultsList *)retval;
  }
  
  if (resultsList && [resultsList.totalNumRecs intValue] == 0) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"GuidedNavigation.NoResults.Title", nil, [NSBundle mainBundle], @"No Results for Filter", @"Text Displayed for Filter combo with no Results") message:@"" delegate:self cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"GuidedNavigation.NoResults.Accept", nil, [NSBundle mainBundle], @"Accept", @"Accept the message understanding there are no results") otherButtonTitles:NSLocalizedStringWithDefaultValue(@"GuidedNavigation.NoResults.Clear", nil, [NSBundle mainBundle], @"Clear", @"Clear the currently applied filter"), nil];
    
    NSMutableDictionary *adaptorAttributes = [NSMutableDictionary dictionaryWithDictionary:self.controller.adaptorManager.adaptorAttributes];
    [adaptorAttributes setObject:self forKey:[NSValue valueWithNonretainedObject:alertView]];
    self.controller.adaptorManager.adaptorAttributes = [NSDictionary dictionaryWithDictionary:adaptorAttributes]; //This adaptor must survive until the alertview delegate is called.
    [alertView show];
  }
  
  if ([self.controller isKindOfClass:[ATGBrowseViewController class]]) {
    self.controller.navigationItem.title = NSLocalizedStringWithDefaultValue(@"GuidedNavigation.navigationbar.title", nil, [NSBundle mainBundle], @"Browse", @"Navigation Bar title");
    if (self.controller.navigationItem.rightBarButtonItem) {
      self.controller.navigationItem.rightBarButtonItem.target = self;
      self.controller.navigationItem.rightBarButtonItem.action = @selector(showProducts:);
    } else {
      self.controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"GuidedNavigation.navigationbar.rightBarButton.title", nil, [NSBundle mainBundle], @"Results", @"Navigation Bar right bar button title for switching to results view") style:UIBarButtonItemStyleBordered target:self action:@selector(showProducts:)];
    }
  } else if ([self.controller isKindOfClass:[ATGSearchRootViewController class]]){
    EMSearchBox *searchBox = [[ATGConfigurationManager sharedManager] searchBox];
    ATGSearchBoxAdaptor *searchBoxAdaptor = [[ATGSearchBoxAdaptor alloc] initWithContentItem:searchBox controller:self.controller];
    [self.adaptors addObject:searchBoxAdaptor];
  }
}

- (void)showProducts:(id)sender {
  ATGSearchViewController *vc = [[UIStoryboard storyboardWithName:@"MobileCommerce_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ATGAssemblerViewController"];
  vc.action = self.controller.action;
  [vc loadPageForContentItem:self.controller.rootContentItem];
  [self.controller.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    EMBreadcrumbs *breadCrumbs = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$.contents.SecondaryContent[?(@.name=Breadcrumbs)]" inRootContentItem:self.controller.rootContentItem];
    NSArray *rangeCrumbs = breadCrumbs.rangeFilterCrumbs;
    for (EMRangeFilterBreadcrumb *crumb in rangeCrumbs) {
      if ([crumb.propertyName isEqualToString:@"sku.activePrice"]) {
        [self.controller reloadPageForAction:crumb.removeAction];
      }
    }
  }
  NSMutableDictionary *mutableD = [NSMutableDictionary dictionaryWithDictionary:self.controller.adaptorManager.adaptorAttributes];
  [mutableD removeObjectForKey:[NSValue valueWithNonretainedObject:alertView]];
  self.controller.adaptorManager.adaptorAttributes = [NSDictionary dictionaryWithDictionary:mutableD];
}

@end
