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

#import "ATGResultsListAdaptor.h"
#import <EMMobileClient/EMResultsList.h>
#import <EMMobileClient/EMRecord.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMNavigationAction.h>
#import "ATGResults.h"
#import <EMMobileClient/EMContentItemRenderer.h>
#import "ATGSearchViewController.h"
#import "ATGResultsListGridRenderer.h"
#import "ATGResultsListSingleRenderer.h"
#import <EMMobileClient/EMAdaptorManager.h>
#import "ATGSingleProductGridViewCell.h"

#define SORT_KEY @"Ns="
#define SORT_SEPARATOR @"%7C"
#define SINGLE_RESULTS_LIST_OFFSET_KEY @"resultsOffset"

typedef enum {
  LayoutStateList,
  LayoutStateGrid,
  LayoutStateSingle
} LayoutState;

static LayoutState mlayoutState = LayoutStateList;

@interface ATGResultsListAdaptor () <ATGCarouselDelegate, ATGCarouselDataSource>
@property (nonatomic, strong) EMResultsList *contentItem;
@property (nonatomic, strong) NSString *resultsState;
@property (nonatomic, weak) ATGSearchViewController *controller;
@property (nonatomic, strong) UIButton *toggleButton;

@end

@implementation ATGResultsListAdaptor
@synthesize contentItem = _contentItem, resultsState = _resultsState;

- (void)layoutContents {
  [super layoutContents];
  
  if ([self.contentItem.totalNumRecs integerValue] == 1)
    mlayoutState = LayoutStateSingle;
  
  self.resultsState = [self.contentItem.pagingActionTemplate.navigationState stringByReplacingOccurrencesOfString:@"No=%7Boffset%7D&" withString:@""];
  self.resultsState = [self.resultsState stringByReplacingOccurrencesOfString:@"&Nrpp=%7BrecordsPerPage%7D" withString:@""];
  
  [self.controller.results addResults:self.contentItem.records forState:self.resultsState atIndex:[self.contentItem.firstRecNum intValue] - 1];
  self.controller.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 0, 0);
  
  self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.toggleButton.frame = CGRectMake(235, 5, 77, 21);
  [self.toggleButton addTarget:self action:@selector(toggleLayout:) forControlEvents:UIControlEventTouchUpInside];
  [self updateToggleButtonState];
  
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.controller.adaptorManager.adaptorAttributes];
  [dictionary setValue:self.toggleButton forKey:@"toggleButton"];
  self.controller.adaptorManager.adaptorAttributes = [NSDictionary dictionaryWithDictionary:dictionary];
    
}

- (NSInteger)numberOfItemsInContentItem {
  if (mlayoutState == LayoutStateSingle)
    return 1;
  
  return  [self.controller.results resultsForState:self.resultsState].count;
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  if (mlayoutState == LayoutStateSingle) {
    NSNumber *firstItem = [self.controller.adaptorManager.adaptorAttributes valueForKey:SINGLE_RESULTS_LIST_OFFSET_KEY];
    if (firstItem) {
      NSMutableDictionary *mutableD = [NSMutableDictionary dictionaryWithDictionary:self.controller.adaptorManager.adaptorAttributes];
      [mutableD removeObjectForKey:SINGLE_RESULTS_LIST_OFFSET_KEY];
      self.controller.adaptorManager.adaptorAttributes = [NSDictionary dictionaryWithDictionary:mutableD];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:(firstItem ? firstItem : @0), @"firstItem", [NSNumber numberWithInt:MIN([self.controller.results resultsForState:self.resultsState].count, [self.contentItem.totalNumRecs intValue]) ], @"totalItems",  nil];
  }
  
  EMRecord *record = [self.controller.results recordForState:self.resultsState atIndex:pIndex];
  return record;
}

- (Class)rendererClassForIndex:(NSInteger)pIndex {
 if (mlayoutState == LayoutStateList)
   return [super rendererClassForIndex:pIndex];
  else if (mlayoutState == LayoutStateGrid)
    return [ATGResultsListGridRenderer class];
  else
    return [ATGResultsListSingleRenderer class];
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  if (mlayoutState == LayoutStateList)
    return CGSizeMake(320, 80);
  else if (mlayoutState == LayoutStateGrid)
    return CGSizeMake(159, 159);
  else
    return CGSizeMake(320, (IS_IPHONE5 ? 424 : 340));
}

- (CGFloat)minimumLineSpacing {
    return 1;
}

- (CGFloat)minimumInteritemSpacing {
    return 1;
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
  EMRecord *record = [self.controller.results recordForState:self.resultsState atIndex:pIndex];
  [self.controller loadDetailsForProduct:(id<RenderableProduct>)record];
}

#pragma mark -
#pragma Paging
- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex {
  
  if (pIndex %2 == 0)
    [[ATGThemeManager themeManager] applyStyle:@"resultsListEvenRow" toObject:pRenderer.backgroundView];
  else
    [[ATGThemeManager themeManager] applyStyle:@"resultsListOddRow" toObject:pRenderer.backgroundView];
  
  if (mlayoutState != LayoutStateSingle) {
    NSInteger lastItem = [self.controller.results resultsForState:self.resultsState].count - 1;
    EMNavigationAction *pagingAction = [self pagingActionForNext];
    if (pIndex == lastItem && pIndex != [self.contentItem.totalNumRecs intValue] - 1) {
      [self.controller loadNextPageForAction:(EMAction *)pagingAction withAttributes:nil];
    }
  }
  
  if ([pRenderer isKindOfClass:[ATGResultsListSingleRenderer class]]) {
    ATGResultsListSingleRenderer *renderer = (ATGResultsListSingleRenderer *)pRenderer;
    [renderer.carousel registerClass:[ATGSingleProductGridViewCell class] forCellWithReuseIdentifier:@"Cell"];
    renderer.carousel.delegate = self;
    renderer.carousel.dataSource = self;
  }
  
}

- (void)usingRenderer:(EMContentItemCollectionReusableView *)pRenderer forSupplementaryElementOfKind:(NSString *)pKind {
  if ([pKind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(235, 5, 77, 21);
    [self.toggleButton addTarget:self action:@selector(toggleLayout:) forControlEvents:UIControlEventTouchUpInside];
    [self updateToggleButtonState];
    
    [pRenderer addSubview:self.toggleButton];
  }
}

- (EMNavigationAction *)pagingActionForNext {
  EMNavigationAction *pagingAction = self.contentItem.pagingActionTemplate;
  
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7Boffset%7D" withString:[NSString stringWithFormat:@"%@", self.contentItem.lastRecNum]];
  
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7BrecordsPerPage%7D" withString:[NSString stringWithFormat:@"%@", self.contentItem.recsPerPage]];
  return pagingAction;
}

#pragma mark -
#pragma ToggleButton
- (void)toggleLayout:(id)sender {
  if (mlayoutState == LayoutStateList)
    mlayoutState = LayoutStateGrid;
  else if (mlayoutState == LayoutStateGrid)
    mlayoutState = LayoutStateSingle;
  else
    mlayoutState = LayoutStateList;
  [self updateToggleButtonState];
  
  [UIView transitionWithView:self.controller.collectionView
                    duration:0.5f
                     options:UIViewAnimationOptionTransitionFlipFromLeft
                  animations:^(void) {
                    [self.controller.collectionView setContentOffset:CGPointMake(0, 0)];
                    [self.controller.collectionView reloadData];
                  } completion:NULL];
}

- (void)updateToggleButtonState {
  if (mlayoutState == LayoutStateList)
    [self.toggleButton setImage:[UIImage imageNamed:@"results-toggle-list"] forState:UIControlStateNormal];
  else if (mlayoutState == LayoutStateGrid)
    [self.toggleButton setImage:[UIImage imageNamed:@"results-toggle-thumb"] forState:UIControlStateNormal];
  else
    [self.toggleButton setImage:[UIImage imageNamed:@"results-toggle-single"] forState:UIControlStateNormal];
}

#pragma mark -
#pragma ATGCarouselDelegate

- (void)carousel:(ATGCarouselView *)pCarousel didSelectItemAtIndex:(NSInteger)pIndex isActiveItem:(BOOL)pActiveItem {
  if (pActiveItem) {
    EMRecord *record = (EMRecord *)[self.controller.results recordForState:self.resultsState atIndex:pIndex];
    [self.controller loadDetailsForProduct:(id<RenderableProduct>)record];
  }
}

- (UICollectionViewCell *)carousel:(ATGCarouselView *)pCarousel cellForItemAtIndex:(NSInteger)pIndex {
  ATGSingleProductGridViewCell *cell = (ATGSingleProductGridViewCell *)[pCarousel dequeueReusableCellWithReuseIdentifier:@"Cell" forIndex:pIndex];
  
  EMRecord *record = (EMRecord *)[self.controller.results recordForState:self.resultsState atIndex:pIndex];
  [cell setRecord:record];
  
  NSInteger lastItem = [self.controller.results resultsForState:self.resultsState].count - 1;
  EMNavigationAction *pagingAction = [self pagingActionForNext];
  
  if (pIndex == lastItem && pIndex!= [self.contentItem.totalNumRecs intValue] - 1) {
    NSDictionary *adaptorAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pIndex - 1] forKey:SINGLE_RESULTS_LIST_OFFSET_KEY];
    [self.controller loadNextPageForAction:(EMAction *)pagingAction withAttributes:adaptorAttributes];
  }
  
  return cell;

}

#pragma mark -
#pragma ATGCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(ATGCarouselView *)pCarousel {
  return [self.controller.results resultsForState:self.resultsState].count;
}

@end
