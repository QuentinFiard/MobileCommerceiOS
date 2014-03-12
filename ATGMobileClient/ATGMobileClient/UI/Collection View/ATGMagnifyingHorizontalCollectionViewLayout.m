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



#import "ATGMagnifyingHorizontalCollectionViewLayout.h"

@implementation ATGMagnifyingHorizontalCollectionViewLayout

- (CGSize)collectionViewContentSize {
  NSInteger itemsNumber = [[self collectionView] numberOfItemsInSection:0];
  CGSize itemSize = [self actualItemSize];
  CGSize gridSize = [[self collectionView] bounds].size;
  if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
    return CGSizeMake(itemSize.width * (itemsNumber - 1) + gridSize.width, itemSize.height);
  } else {
    return CGSizeMake(itemSize.width, itemSize.height * (itemsNumber - 1) + gridSize.height);
  }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)pRect {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  for (NSInteger item = 0; item < [[self collectionView] numberOfItemsInSection:0]; item++) {
    [result addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item
                                                                                   inSection:0]]];
  }
  return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)pIndexPath {
  UICollectionViewLayoutAttributes *result =
  [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:pIndexPath];
  CGSize gridSize = [[self collectionView] bounds].size;
  CGSize itemSize = [self actualItemSize];
  [result setZIndex:1];
  [result setSize:itemSize];
  if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
    CGPoint center = CGPointMake(gridSize.width / 2 + [pIndexPath item] * itemSize.width,
                                 gridSize.height / 2);
    CGFloat barrelRadius = 300;
    CGFloat visibleOffset = center.x - [[self collectionView] contentOffset].x - gridSize.width / 2;
    CGFloat observationAngle = visibleOffset / barrelRadius;
    CGFloat scaleFactor = 1 - 0.5 * ABS(visibleOffset) / gridSize.width;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    transform = CATransform3DRotate(transform, observationAngle, 0, 1, 0);
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1);
    [result setTransform3D:transform];
    
    [result setAlpha:scaleFactor];
    [result setCenter:center];
  }
  return result;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)pProposedContentOffset
                                 withScrollingVelocity:(CGPoint)pVelocity {
  CGSize gridSize = [[self collectionView] bounds].size;
  if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
    pProposedContentOffset.x += gridSize.width / 2;
    for (NSInteger item = 0; item < [[self collectionView] numberOfItemsInSection:0]; item++) {
      UICollectionViewLayoutAttributes *attributes =
      [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
      if (ABS(attributes.center.x - pProposedContentOffset.x) <= attributes.size.width / 2) {
        pProposedContentOffset.x = attributes.center.x;
      }
    }
    pProposedContentOffset.x -= gridSize.width / 2;
  } else {
    pProposedContentOffset.y += gridSize.height / 2;
    for (NSInteger item = 0; item < [[self collectionView] numberOfItemsInSection:0]; item++) {
      UICollectionViewLayoutAttributes *attributes =
      [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
      if (ABS(attributes.center.y - pProposedContentOffset.y) <= attributes.size.height / 2) {
        pProposedContentOffset.y = attributes.center.y;
      }
    }
    pProposedContentOffset.y -= gridSize.height / 2;
  }
  return pProposedContentOffset;
}

#pragma mark - Private Protocol Implementation

- (CGSize)actualItemSize {
  CGSize referenceSize = [self itemSize];
  if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
    CGFloat rowHeight = [[self collectionView] bounds].size.height;
    return CGSizeMake(referenceSize.width * rowHeight / referenceSize.height, rowHeight);
  } else {
    CGFloat rowWidth = [[self collectionView] bounds].size.width;
    return CGSizeMake(rowWidth, referenceSize.height * rowWidth / referenceSize.width);
  }
}

@end
