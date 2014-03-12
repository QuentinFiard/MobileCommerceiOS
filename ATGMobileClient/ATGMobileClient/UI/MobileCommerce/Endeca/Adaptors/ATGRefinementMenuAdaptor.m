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

#import "ATGRefinementMenuAdaptor.h"
#import <EMMobileClient/EMAssemblerViewController.h>
#import <EMMobileClient/EMRefinementMenu.h>
#import <EMMobileClient/EMRefinement.h>
#import <EMMobileClient/EMAdaptorManager.h>
#import <EMMobileClient/EMBlockQueue.h>
#import "ATGBrowseViewController.h"
#import "ATGSearchRootViewController.h"
#import "ATGBrowseViewController_iPad.h"

@interface ATGRefinementMenuAdaptor ()
@property (nonatomic, strong) EMRefinementMenu *contentItem;
@property (nonatomic, assign) BOOL loadingRefinements;
@end

@implementation ATGRefinementMenuAdaptor
@synthesize contentItem = contentItem;

- (NSInteger)numberOfItemsInContentItem {
  if (!self.collapsed)
    return self.contentItem.refinements.count + (self.contentItem.moreLink ? 1 : 0);
  return 0;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  return CGSizeMake(320, 44);
}

- (CGSize)referenceSizeForHeader {
  return CGSizeMake(320, 30);
}

- (CGSize)referenceSizeForFooter {
  return CGSizeMake(320, 0);
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  if ([self moreLinkCellAtIndex:pIndex]) {
    return self.contentItem.moreLink.label;
  } else {
    EMDataObject *obj = [self.contentItem.refinements objectAtIndex:pIndex];
    return obj;
  }
}

- (id)objectToBeRenderedForHeader {
  return (self.collapsed ?  [NSString stringWithFormat:@"\u25B2 %@", self.contentItem.name] : [NSString stringWithFormat:@"\u25BC %@", self.contentItem.name]);
}

- (CGFloat)minimumLineSpacing {
  return 1;
}

- (UIEdgeInsets)edgeInsets {
  return UIEdgeInsetsMake(1.0, 0.0, self.collapsed ? 0.0 : 1.0, 0.0);
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return self.loadingRefinements && [self moreLinkCellAtIndex:pIndex] ? NO : YES;
}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
  if ([self moreLinkCellAtIndex:pIndex]) {
    self.loadingRefinements = YES;
    [self.controller reloadPageForAction:(EMAction *)self.contentItem.moreLink];
    
    NSInteger section = [self.controller.adaptorManager indexOfContentItem:self.contentItem];
    NSArray *indexPaths = [self.controller.collectionView  indexPathsForVisibleItems];
    NSArray* sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSInteger row = ((NSIndexPath *)[sortedIndexPaths objectAtIndex:0]).row;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
    
    void(^currentBlock)(void) = ^() {
      [self.controller.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    };
    
    [self.controller.dataReadyBlockQueue addBlock:currentBlock];
  } else {
    [self loadRefinementResultsForAction: (EMAction *)[self.contentItem.refinements objectAtIndex:pIndex]];
  }
}

- (void) loadRefinementResultsForAction: (EMAction *) pAction {
  if ([self.controller isKindOfClass:[ATGBrowseViewController class]] ||  [self.controller isKindOfClass:[ATGBrowseViewController_iPad class]]) {
    ATGSearchViewController *browseController;
    if ([self.controller isKindOfClass:[ATGBrowseViewController_iPad class]]) {
      browseController = [[ATGBrowseViewController_iPad alloc] initWithAction:pAction];
      ((ATGBaseBrowseSearchViewController_iPad *)browseController).rootViewController = ((ATGBaseBrowseSearchViewController_iPad *)self.controller).rootViewController;
    } else {
      browseController = [[UIStoryboard storyboardWithName:@"MobileCommerce_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ATGBrowseAssemblerViewController"];
      ((ATGBrowseViewController *)browseController).action = pAction;
    }
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"browse.control.back.button", nil, [NSBundle mainBundle], @"Back", @"Back Button Title") style:UIBarButtonItemStyleBordered target:nil action:nil];
    browseController.navigationItem.backBarButtonItem = backButtonItem;
    [self.controller.navigationController pushViewController:browseController animated:YES];
  } else if ([self.controller isKindOfClass:[ATGSearchRootViewController class]]) {
    [(ATGSearchRootViewController *)self.controller presentBrowseViewControllerWithAction:pAction];
  }else {
    [self.controller reloadPageForAction:pAction];
  }
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (BOOL)moreLinkCellAtIndex:(NSInteger)pIndex {
  return self.contentItem.moreLink && pIndex == self.contentItem.refinements.count;
}


@end
