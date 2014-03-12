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

#import "ATGProductList_ATGCategoryChildren.h"
#import "ATGProductList_ATGCategoryChildrenAdaptor.h"
#import "ATGProductList_ATGCategoryChildrenRenderer.h"
#import "ATGSearchViewController.h"
#import "ATGCategoryChildrenPagingCellRenderer.h"
#import "ATGSortControl.h"
#import "ATGBaseBrowseResultsViewController.h"

#import <ATGMobileClient/ATGBaseProduct.h>

@interface ATGProductList_ATGCategoryChildrenAdaptor () <ATGCategoryChildrenPagingCellDelegate, EMSortControlDelegate>
@property (nonatomic, strong) ATGProductList_ATGCategoryChildren *contentItem;
@property (nonatomic, strong) NSString *resultsState;
@end



@implementation ATGProductList_ATGCategoryChildrenAdaptor
@synthesize contentItem = _contentItem, resultsState = _resulstsState;

- (NSInteger)numberOfItemsInContentItem {
  NSInteger totalPageCount = [self.contentItem.totalNumRecs integerValue] / [self.contentItem.recsPerPage integerValue];
  if (totalPageCount > 0) {
    if (([self.contentItem.totalNumRecs integerValue] % [self.contentItem.recsPerPage integerValue]) > 0) {
       totalPageCount += 1;
    }
  }  
  
  if (totalPageCount > 1) {
    return self.contentItem.atgContents.childProducts.count + 1;
  }
  return self.contentItem.atgContents.childProducts.count;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  if (pIndex == self.contentItem.atgContents.childProducts.count) {
    return CGSizeMake(320, 30);
  }
  return CGSizeMake(320, 80);
}

- (CGFloat)minimumLineSpacing {
  return 1;
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  if (pIndex < self.contentItem.atgContents.childProducts.count) {
    return YES;
  }
  return NO;
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  if (pIndex < self.contentItem.atgContents.childProducts.count) {
    return YES;
  }
  return NO;
}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
  if (pIndex < self.contentItem.atgContents.childProducts.count) {
    ATGBaseProduct *product = [self.contentItem.atgContents.childProducts objectAtIndex:pIndex];
    [((ATGSearchViewController *)self.controller) loadDetailsForProduct:(id<RenderableProduct>)product];
  }
}

- (void)loadNextPage {
  EMNavigationAction *pagingAction = self.contentItem.pagingActionTemplate;
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7BpageNum%7D" withString:[[NSNumber numberWithInt:[self.contentItem.atgContents.currentPageNumber intValue] + 1] stringValue]];
  
  [self.controller loadPageForAction:pagingAction];
}

- (void)loadPreviousPage {
  EMNavigationAction *pagingAction = self.contentItem.pagingActionTemplate;
  pagingAction.navigationState = [pagingAction.navigationState stringByReplacingOccurrencesOfString:@"%7BpageNum%7D" withString:[[NSNumber numberWithInt:[self.contentItem.atgContents.currentPageNumber intValue] - 1] stringValue]];
  
  [self.controller loadPageForAction:pagingAction];
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  if (pIndex == self.contentItem.atgContents.childProducts.count) {
    NSInteger totalPageCount = [self.contentItem.totalNumRecs integerValue] / [self.contentItem.recsPerPage integerValue];
    if (totalPageCount > 0) {
      if (([self.contentItem.totalNumRecs integerValue] % [self.contentItem.recsPerPage integerValue]) > 0) {
        totalPageCount += 1;
      }
    }
    
    PagingCellState state;
    if ([self.contentItem.atgContents.currentPageNumber integerValue] == 1 && totalPageCount > 1) {
       state = ShowNext;
      
    } else if ([self.contentItem.atgContents.currentPageNumber integerValue] > 1 && [self.contentItem.atgContents.currentPageNumber integerValue] < totalPageCount) {
      state = ShowNextAndPrevious;
    } else {
      state = ShowPrevious;
    }
    
    return [NSNumber numberWithInt:state];
    
  } else {
    ATGBaseProduct *product = (ATGBaseProduct *)[self.contentItem.atgContents.childProducts objectAtIndex:pIndex];
    return product;
  }
}

- (Class)rendererClassForIndex:(NSInteger)pIndex {
  if (pIndex == self.contentItem.atgContents.childProducts.count) {
    return [ATGCategoryChildrenPagingCellRenderer class];
  }
  return [ATGProductList_ATGCategoryChildrenRenderer class];
}

- (BOOL)sectionHeaderShouldPinToTop:(EMContentItemCollectionReusableView *)pSectionHeader {
  return YES;
}

- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex {
  if ([pRenderer isKindOfClass:[ATGProductList_ATGCategoryChildrenRenderer class]]) {
    if (pIndex %2 == 0)
      [[ATGThemeManager themeManager] applyStyle:@"resultsListEvenRow" toObject:pRenderer.backgroundView];
    else
      [[ATGThemeManager themeManager] applyStyle:@"resultsListOddRow" toObject:pRenderer.backgroundView];
  } else if ([pRenderer isKindOfClass:[ATGCategoryChildrenPagingCellRenderer class]]) {
    ((ATGCategoryChildrenPagingCellRenderer *)pRenderer).delegate = self;
  }
}

@end
