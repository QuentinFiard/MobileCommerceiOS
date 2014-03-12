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

#import <ATGMobileClient/ATGRelatedProductGrid.h>
#import <ATGMobileClient/ATGProductGridViewCell.h>
#import <ATGMobileClient/ATGRelatedProduct.h>
#import <ATGMobileClient/ATGProduct.h>

#pragma mark - ATGRelatedProductGrid Private Protocol Definition
#pragma mark -

@interface ATGRelatedProductGrid () <ATGGridViewDelegate, ATGGridViewDataSource>

#pragma mark - IB Properties

@property (nonatomic, readwrite, strong) IBOutlet ATGProductGridViewCell *cellPrototype;

#pragma mark - Private Protocol

- (NSInteger) numberOfColumns;

@end

#pragma mark - ATGRelatedProductGrid Implementation
#pragma mark -

@implementation ATGRelatedProductGrid

#pragma mark - Synthesized Properties

@synthesize relatedProducts;
@synthesize cellPrototype;
@synthesize productGridDelegate;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  // Do not display prototype itself. We'll create its clones instead.
  [cellPrototype removeFromSuperview];

  // Cells height is defined with IB.
  [self setRowHeight:[cellPrototype frame].size.height];
  // This grid fully manages underlying ATGGridView.
  [self setDataSource:self];
  [self setDelegate:self];
  // User can't edit related products list.
  [self setEditingEnabed:NO];
}

#pragma mark - ATGGridViewDataSource

- (NSInteger) numberOfRowsInGridView:(ATGGridView *)pGridView {
  if ([[self relatedProducts] count] % [self numberOfColumns]) {
    return [[self relatedProducts] count] / [self numberOfColumns] + 1;
  }
  return [[self relatedProducts] count] / [self numberOfColumns];
}

- (NSInteger) gridView:(ATGGridView *)pGridView numberOfColumnsInRow:(NSInteger)pRow {
  if (pRow < [self numberOfRowsInGridView:pGridView] - 1) {
    // It's not the last row, so number of columns is predefined.
    return [self numberOfColumns];
  } else if ([[self relatedProducts] count] % [self numberOfColumns]) {
    // It's the last row and it should not be fully filled.
    return [[self relatedProducts] count] % [self numberOfColumns];
  } else {
    return [self numberOfColumns];
  }
}

- (ATGGridViewCell *) gridView:(ATGGridView *)pGridView cellAtIndexPath:(NSIndexPath *)pIndexPath {
  // Create a clone of prototype cell to display it within the grid.
  ATGProductGridViewCell *cell = [[self cellPrototype] copy];
  // Get the proper product
  NSInteger index = [pIndexPath row] * [self numberOfColumns] + [pIndexPath column];
  ATGRelatedProduct *product = [[self relatedProducts] objectAtIndex:index];
  // and populate cell's properties with product's values.
  [cell setImageURL:[product mediumImageUrl]];
  [cell setProductName:[product displayName]];
  
  if ([[product highestSalePrice] compare:[product lowestSalePrice]] != NSOrderedSame) {
    // set a price range
    [cell setHighestPrice:[product highestSalePrice]];
    [cell setLowestPrice:[product lowestSalePrice]];
  } else {
    // single price
    [cell setPrice:[product lowestSalePrice]];
    if ([[product lowestSalePrice] compare: [product lowestListPrice]] != NSOrderedSame) {
      // product is on sale, display 'was price'
      [cell setOldPrice:[product lowestListPrice]];
    }
  }
  [cell setCurrencyCode:[[product parentProduct] currencyCode]];
  [cell setSiteID:[product siteId]];
  [cell setSiteName:[product siteName]];
  return cell;
}

#pragma mark - ATGGridViewDelegate

- (void) gridView:(ATGGridView *)pGridView didSelectCellAtIndexPath:(NSIndexPath *)pIndexPath {
  // Dispatch a message to grid's delegate.
  NSInteger index = [pIndexPath row] * [self numberOfColumns] + [pIndexPath column];
  ATGRelatedProduct *product = [[self relatedProducts] objectAtIndex:index];
  [[self productGridDelegate] didSelectProductWithID:[product repositoryId] onSiteWithID:[product siteId]];
}

- (CGFloat) gridView:(ATGGridView *)pGridView widthForColumnsInRow:(NSInteger)pRow {
  // All cells has equal width with prototype cell.
  return [[self cellPrototype] frame].size.width;
}

#pragma mark - Private Protocol Implementation

- (NSInteger) numberOfColumns {
  // Number of columns within the grid is predefined and it's defined with device orientation.
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (orientation == UIInterfaceOrientationPortrait ||
      orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return 3;
  }
  return 4;
}

@end