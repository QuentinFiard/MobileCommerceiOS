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

#import "ATGResultsListAdaptor_iPad.h"
#import <EMMobileClient/EMResultsList.h>
#import <EMMobileClient/EMRecord.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMNavigationAction.h>
#import "ATGResults.h"
#import <EMMobileClient/EMContentItemRenderer.h>
#import <EMMobileClient/EMAssemblerViewController.h>
#import "ATGBaseBrowseSearchViewController_iPad.h"
#import "ATGResultsListGridRenderer_iPad.h"
#import "ATGBaseBrowseResultsViewController.h"

#define SORT_KEY @"Ns="
#define SORT_SEPARATOR @"%7C"
#define SINGLE_RESULTS_LIST_OFFSET_KEY @"resultsOffset"

@interface ATGResultsListAdaptor_iPad ()
@property (nonatomic, strong) EMResultsList *contentItem;
@property (nonatomic, strong) NSString *resultsState;
@property (nonatomic, strong) ATGBaseBrowseSearchViewController_iPad *controller;
@property (nonatomic, strong) UIPopoverController *refinementPopOver;
@end

@implementation ATGResultsListAdaptor_iPad
@synthesize contentItem = _contentItem, resultsState = _resultsState;

- (void)layoutContents {
  [super layoutContents];
  
  self.controller.view.backgroundColor = [UIColor whiteColor];
  
  self.resultsState = [self.contentItem.pagingActionTemplate.navigationState stringByReplacingOccurrencesOfString:@"No=%7Boffset%7D&" withString:@""];
  self.resultsState = [self.resultsState stringByReplacingOccurrencesOfString:@"&Nrpp=%7BrecordsPerPage%7D" withString:@""];
  
  [self.controller.results addResults:self.contentItem.records forState:self.resultsState atIndex:[self.contentItem.firstRecNum intValue] - 1];
  
  if (self.controller.popOver.popoverVisible) {
    [self.controller.popOver presentPopoverFromRect:CGRectMake(self.controller.view.width - 20, 30, 1, 1) inView:self.controller.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
}

- (NSInteger)numberOfItemsInContentItem {
  return  [self.controller.results resultsForState:self.resultsState].count;
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  EMRecord *record = [self.controller.results recordForState:self.resultsState atIndex:pIndex];
  return record;
}

- (Class)rendererClassForIndex:(NSInteger)pIndex {
  return [ATGResultsListGridRenderer_iPad class];
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  return ([self.controller isKindOfClass:[ATGBaseBrowseResultsViewController class]] ? CGSizeMake(220, 220) : CGSizeMake(256, 256));
}

- (CGFloat)minimumLineSpacing {
  return 0;
}

- (CGFloat)minimumInteritemSpacing {
  return 0;
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
  EMRecord *record = [self.controller.results recordForState:self.resultsState atIndex:pIndex];
  [self.controller loadDetailsForProduct:(id <RenderableProduct>)record withDataSource:self];
}

#pragma mark - Paging
- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex {
  
  if (pIndex %2 == 0)
    [[ATGThemeManager themeManager] applyStyle:@"resultsListEvenRow" toObject:pRenderer.backgroundView];
  else
    [[ATGThemeManager themeManager] applyStyle:@"resultsListOddRow" toObject:pRenderer.backgroundView];
  
  NSInteger lastItem = [self.controller.results resultsForState:self.resultsState].count - 1;
  EMNavigationAction *pagingAction = [self pagingActionForNext];
  if (pIndex == lastItem && pIndex < [self.contentItem.totalNumRecs intValue] - 1) {
    [self.controller loadNextPageForAction:(EMAction *)pagingAction withAttributes:nil];
  }
}

- (EMNavigationAction *)pagingActionForNext {
  EMNavigationAction *pagingAction = self.contentItem.pagingActionTemplate;
  
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7Boffset%7D" withString:[NSString stringWithFormat:@"%@", self.contentItem.lastRecNum]];
  
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7BrecordsPerPage%7D" withString:[NSString stringWithFormat:@"%@", self.contentItem.recsPerPage]];
  return pagingAction;
}

#pragma mark - ATGProductDetailsStackDataSource
- (NSArray *) initialProducts {
  NSArray *records = [self.controller.results resultsForState:self.resultsState];
  NSMutableArray *products = [NSMutableArray array];
  for (id product in records) {
    [products addObject:[self.controller.results getRecord:product]];
  }
  return products;
}

- (BOOL) nextProductsForStack:(id <ATGProductDetailsStack>)stack {
  return NO;
}

@end
