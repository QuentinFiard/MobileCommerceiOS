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

#import "ATGMobilePageAdaptor.h"
#import "ATGSearchViewController.h"
#import <EMMobileClient/EMMobilePage.h>
#import "ATGSearchBoxAdaptor.h"
#import <EMMobileClient/EMSearchBox.h>
#import <EMMobileClient/EMSearchBreadcrumb.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMBlockQueue.h>
#import <EMMobileClient/EMAdaptorManager.h>
#import "ATGBrowseViewController.h"
#import "ATGBaseBrowseResultsViewController.h"
#import "ATGConfigurationManager.h"
#import <EMMobileClient/EMSearchAdjustments.h>
#import <EMMobileClient/EMAdjustedSearch.h>
#import "ATGSortControl.h"
#import "ATGContentPathLookupManager.h"
#import "ATGResultsListSectionHeaderRenderer.h"

@interface ATGMobilePageAdaptor () <EMSortControlDelegate>
@property (nonatomic, strong) EMMobilePage *contentItem;
@property (nonatomic, weak) ATGSearchViewController *refinementViewController;
@property (nonatomic, weak) ATGSearchViewController *controller;
@end

@implementation ATGMobilePageAdaptor
- (void)layoutContents {  
  //No search Box, so we will make our own!
  [self layoutContentsForKey:@"HeaderContent"];
  
  if (![self.controller isKindOfClass:[ATGBrowseViewController class]] && ![self.controller isMemberOfClass:[ATGBaseBrowseSearchViewController_iPad class]]) {
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
  
  NSMutableDictionary *mutableAdaptorAttributes = [self.controller.adaptorManager.adaptorAttributes mutableCopy];
  [mutableAdaptorAttributes removeObjectForKey:@"toggleButton"];
  self.controller.adaptorManager.adaptorAttributes = [NSDictionary dictionaryWithDictionary:mutableAdaptorAttributes];
  
  [self layoutContentsForKey:@"MainContent"];
}

- (id)objectToBeRenderedForHeader {
  NSArray *sortOptions = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$..sortOptions" inRootContentItem:self.contentItem];
  NSArray *totalNumArray = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$..totalNumRecs" inRootContentItem:self.contentItem];
  NSNumber *totalNum;
  if (totalNumArray && totalNumArray.count > 0) {
    totalNum = totalNumArray[0];
  }
  CGRect containerFrame = CGRectZero;
  containerFrame.size = [self referenceSizeForHeader];
  UIView *contentView = [[UIView alloc] initWithFrame:containerFrame];
  contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
  UIView *containerView = [[UIView alloc] initWithFrame:containerFrame];
  containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
  
  [containerView addSubview:contentView];
  
  NSString *searchTerm = [[EMContentPathLookupManager contentPathLookupManager] contentForPath:@"$.contents.SecondaryContent.searchCrumbs.terms[0]" inRootContentItem:self.controller.rootContentItem];
  
  if (searchTerm != nil && IS_IPAD) {
    UILabel *searchTermLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.controller.view.bounds.size.width / 2, 30)];
    NSString *youSearchedFor = NSLocalizedStringWithDefaultValue(@"ATGResultsList.Header.YouSearchedFor", nil, [NSBundle mainBundle], @"You searched for:", @"Text displayed prior to your search term, on the results page header");
    
    searchTermLabel.text = [NSString stringWithFormat:@"%@ %@", youSearchedFor, searchTerm];
    searchTermLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:searchTermLabel];
    
    EMSearchAdjustments *searchAdjustment = (EMSearchAdjustments *)[[EMContentPathLookupManager contentPathLookupManager] contentForPath:@"$.contents.MainContent[?(@.name=Search Adjustments)]" inRootContentItem:self.controller.rootContentItem];
    if ([searchAdjustment respondsToSelector:@selector(adjustedSearches)] && searchAdjustment.adjustedSearches) {
      NSArray *adjustedSearches = [searchAdjustment.adjustedSearches allValues];
      EMAdjustedSearch *adjustedSearch = [(NSArray *)[adjustedSearches objectAtIndex:0] objectAtIndex:0];
      NSString *originalTerm = [searchAdjustment.originalTerms objectAtIndex:0];
      
      NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ '%@' %@ '%@'", NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Your.Search.For", nil, [NSBundle mainBundle], @"Your search for", @"This text renders before the search term when autocorrected ie Your search for: 'term' was corrected to 'corrected term'"), originalTerm, NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Was.Corrected.To", nil, [NSBundle mainBundle], @"was corrected to", @"This text renderers between the entered term and the corrected term, ie foo was corrected to food"), adjustedSearch.adjustedTerms]];
      
      searchTermLabel.attributedText = str;
    }
  }
  
  UIButton *refineButton;
  // don't display 'Filter' button when browsing or on iPhone
  if (![self.controller isKindOfClass:[ATGBaseBrowseResultsViewController class]] && IS_IPAD) {
    refineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refineButton.frame = CGRectZero;
    refineButton.translatesAutoresizingMaskIntoConstraints = NO;
    refineButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [refineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [refineButton setTitle:NSLocalizedStringWithDefaultValue(@"ATGResultsList.Header.FilterButtonTitle", nil, [NSBundle mainBundle], @"Filter", @"Title of Filter button, to filter/refine search results, located on results page header") forState:UIControlStateNormal];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu-divider"]];
    imgV.frame = CGRectMake(0, 0, 1, 30);
    [refineButton addSubview:imgV];
    [contentView addSubview:refineButton];
    [refineButton addTarget:self action:@selector(showRefinements:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  UIView *toggleViewiPhone =[self.controller.adaptorManager.adaptorAttributes valueForKey:@"toggleButton"];
  
  ATGSortControl *sortControl = [[ATGSortControl alloc] initWithFrame:CGRectMake(0, 0, (toggleViewiPhone || IS_IPAD ? 200 : 320), 30) sortOptions:sortOptions];
  sortControl.translatesAutoresizingMaskIntoConstraints = NO;
  sortControl.delegate = self;
  [contentView addSubview:sortControl];
  
  UILabel *resultsCount;
  if (IS_IPAD) {
    resultsCount = [[UILabel alloc] initWithFrame:CGRectZero];
    resultsCount.backgroundColor = [UIColor clearColor];
    resultsCount.textColor = [UIColor grayColor];
    resultsCount.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:resultsCount];
    resultsCount.textAlignment = NSTextAlignmentRight;
    if ([totalNum intValue] == 1) {
      resultsCount.text = [NSString stringWithFormat:@"%@ %@", totalNum, NSLocalizedStringWithDefaultValue(@"ATGResultsList.Header.Item", nil, [NSBundle mainBundle], @"item", @"Search results count, singular e.g: 1 item")];
    } else {
      resultsCount.text = [NSString stringWithFormat:@"%@ %@", totalNum, NSLocalizedStringWithDefaultValue(@"ATGResultsList.Header.Items", nil, [NSBundle mainBundle], @"items", @"Search results count, plural e.g: 2 items")];
    }
  }
  
  NSDictionary *views;
  
  if (refineButton && resultsCount) {
    views = NSDictionaryOfVariableBindings(contentView, refineButton, sortControl, resultsCount);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[resultsCount(==100)]-10-[sortControl(==200)]-3-[refineButton(==70)]-0-|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[refineButton(==30)]|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];
  } else if (resultsCount) {
    views = NSDictionaryOfVariableBindings(contentView, sortControl, resultsCount);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[resultsCount(==100)]-10-[sortControl(==200)]-0-|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[resultsCount(==30)]|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];
  } else {
    views = NSDictionaryOfVariableBindings(contentView, sortControl);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[sortControl]|"
                                                                        options:NSLayoutFormatAlignAllBottom
                                                                        metrics:nil
                                                                          views:views]];
    [containerView addSubview:toggleViewiPhone];
  }
  
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sortControl(==30)]|"
                                                                      options:NSLayoutFormatAlignAllBottom
                                                                      metrics:nil
                                                                        views:views]];
  
  return containerView;
}

- (void)showRefinements:(id)sender {
  
  self.refinementViewController = self.controller.refinementViewController;
  self.refinementViewController.rootContentItem = nil;
  [self.refinementViewController loadPageForContents:self.contentItem.secondaryContent];

  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.refinementViewController];
  navController.view.backgroundColor = [UIColor clearColor];
  [navController setNavigationBarHidden:NO];

  [self.controller presentViewController:navController animated:YES completion:^(void){}];
  
}

- (BOOL)sectionHeaderShouldPinToTop:(EMContentItemCollectionReusableView *)pSectionHeader {
  return YES;
}

- (CGSize)referenceSizeForHeader {
  return CGSizeMake(self.controller.view.bounds.size.width, 30);
}

- (void)didSelectSortAction:(EMAction *)pAction {
  [self.controller loadPageForAction:pAction];
}

- (Class)headerRendererClass {
  return [ATGResultsListSectionHeaderRenderer class];
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

