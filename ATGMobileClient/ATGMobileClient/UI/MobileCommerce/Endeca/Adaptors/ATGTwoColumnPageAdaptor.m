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

#import "ATGTwoColumnPageAdaptor.h"
#import "ATGSearchViewController.h"
#import <EMMobileClient/EMMobilePage.h>
#import "ATGSearchBoxAdaptor.h"
#import <EMMobileClient/EMSearchBox.h>
#import <EMMobileClient/EMSearchBreadcrumb.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMBlockQueue.h>
#import "ATGBrowseViewController.h"
#import "ATGConfigurationManager.h"
#import "ATGContentPathLookupManager.h"
#import <EMMobileClient/EMTwoColumnPage.h>

@interface ATGTwoColumnPageAdaptor ()
@property (nonatomic, strong) EMTwoColumnPage *contentItem;
@property (nonatomic, weak) ATGSearchViewController *refinementViewController;
@end

@implementation ATGTwoColumnPageAdaptor
- (void)layoutContents {
  //No search Box, so we will make our own!
  [self layoutContentsForKey:@"HeaderContent"];

  if (![self.controller isKindOfClass:[ATGBrowseViewController class]]) {
    if (((EMContentItemList *)[self.contentItem.attributes valueForKey:@"SecondaryContent"]).count > 0) {
      self.controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:
          NSLocalizedStringWithDefaultValue(@"ATGMobilePageAdaptor.RightBarButtonTitle.Filter", nil, [NSBundle mainBundle], @"Filter", @"Navigation Bar Button which is clicked to display the filter controller")
                                                                                           style:UIBarButtonItemStyleBordered
                                                                                          target:self
                                                                                          action:@selector(showRefinements:)];
      self.controller.navigationItem.rightBarButtonItem.width = 65;
    }

    EMSearchBox *searchBox = [[ATGConfigurationManager sharedManager] searchBox];
    ATGSearchBoxAdaptor *searchBoxAdaptor = [[ATGSearchBoxAdaptor alloc] initWithContentItem:searchBox controller:self.controller];

    NSArray *searchCrumbs = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$.SecondaryContent[?(@.name=Breadcrumbs)].searchCrumbs" inRootContentItem:self.contentItem];
    NSString *searchTerm = @"";
    if (searchCrumbs.count > 0) {
      EMSearchBreadcrumb *searchCrumb = [searchCrumbs objectAtIndex:0];
      searchTerm = (searchCrumb.correctedTerms ? searchCrumb.correctedTerms : searchCrumb.terms);
    }
    [searchBoxAdaptor setSearchTerm:searchTerm];
    [self.adaptors addObject:searchBoxAdaptor];
  } else {
    [self.controller.dataReadyBlockQueue addBlock:^() {
      self.controller.navigationItem.rightBarButtonItem.target = self;
      self.controller.navigationItem.rightBarButtonItem.action = @selector(showBrowse:);
    }];
  }

  [self layoutContentsForKey:@"MainContent"];
}

- (void)showRefinements:(id)sender {
  ATGSearchViewController *refinmentController = [[ATGSearchViewController alloc] init];
  self.refinementViewController = refinmentController;
  [self.refinementViewController loadPageForContents:self.contentItem.secondaryContent];
  self.refinementViewController.action = self.controller.action;
  self.refinementViewController.reloadContentPath = @"$.contents.SecondaryContent";

  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.refinementViewController];
  navController.view.backgroundColor = [UIColor clearColor];
  [navController setNavigationBarHidden:NO];

  self.refinementViewController.title = NSLocalizedStringWithDefaultValue(@"ATGGuidedNavigationAdaptor.NavigationBar.Title", nil, [NSBundle mainBundle], @"Filter By...", @"Navigation Bar Title for the guided navigation controller")
      ;
  self.refinementViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"ATGGuidedNavigationAdaptor.NavigationBar.RightBarButtonItem", nil, [NSBundle mainBundle], @"Done", @"guided navigation controller done button title")
                                                                                                     style:UIBarButtonItemStyleBordered
                                                                                                    target:self
                                                                                                    action:@selector(hideRefinements:)];
  [self.controller presentViewController:navController animated:YES completion:^(void){}];

}

- (void)hideRefinements:(id)sender {
  [self.controller dismissViewControllerAnimated:YES completion:nil];
  if (self.refinementViewController.rootContentItem) {
    [self.controller loadPageForContentItem:self.refinementViewController.rootContentItem];
  }
}

- (void)showBrowse:(id)sender {
  [UIView transitionWithView:self.controller.navigationController.view
                    duration:0.5f
                     options:UIViewAnimationOptionTransitionFlipFromLeft
      animations:^(void) {
        [self.controller loadPageForContents:[[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$.SecondaryContent" inRootContentItem:self.contentItem]];
      } completion:^(BOOL completion) {
    self.controller.navigationItem.rightBarButtonItem.title = NSLocalizedStringWithDefaultValue(@"ATGMobilePageAdaptor.NavigationBar.RightBarButton.Title", nil, [NSBundle mainBundle], @"Results", @"Mobile Page guided navigation right bar button title for showing results");
  }];
}
@end

