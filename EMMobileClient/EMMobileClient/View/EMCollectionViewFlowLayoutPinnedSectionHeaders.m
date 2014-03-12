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



#import "EMCollectionViewFlowLayoutPinnedSectionHeaders.h"

@interface EMCollectionViewFlowLayoutPinnedSectionHeaders ()
@property (nonatomic, assign) CGFloat offset;
@end

@implementation EMCollectionViewFlowLayoutPinnedSectionHeaders

- (void)prepareLayout {
  [super prepareLayout];
  self.offset = self.collectionView.contentOffset.y;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, MAX(rect.size.width, self.collectionView.contentSize.width),MAX(rect.size.height, self.collectionView.contentSize.height))];
  NSMutableArray *sectionHeaders = [NSMutableArray arrayWithCapacity:0];
  
  for (UICollectionViewLayoutAttributes *atr in layoutAttributes) {
    if ([atr.representedElementKind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
      [sectionHeaders addObject:atr];
    }
  }
  
  for (int i = 0; i < sectionHeaders.count; i++) {
    UICollectionViewLayoutAttributes *atr = [sectionHeaders objectAtIndex:i];
    atr.zIndex = 2.0;
    if (i + 1 < sectionHeaders.count) {
      UICollectionViewLayoutAttributes *next = [sectionHeaders objectAtIndex:i + 1];
      if (self.offset > atr.frame.origin.y && self.offset < next.frame.origin.y - atr.frame.size.height) {
        atr.frame = CGRectOffset(atr.frame, 0, self.offset - atr.frame.origin.y);
      } else if (self.offset > atr.frame.origin.y && self.offset < next.frame.origin.y) {
        atr.frame = CGRectOffset(next.frame, 0, -atr.frame.size.height);
      }
    } else {
      if (self.offset > atr.frame.origin.y) {
        atr.frame = CGRectOffset(atr.frame, 0, self.offset - atr.frame.origin.y);
      }
    }
  }
 
  if (layoutAttributes.count > 0) {
    UICollectionViewLayoutAttributes *prevAttr = [layoutAttributes objectAtIndex:0];
    for (int i = 1; i < layoutAttributes.count; i++) {
      UICollectionViewLayoutAttributes *currAttr = [layoutAttributes objectAtIndex:i];
      if (currAttr.frame.origin.y > prevAttr.frame.origin.y + prevAttr.frame.size.height && currAttr.frame.origin.x > 0) { // new row
        currAttr.frame = CGRectMake(0, currAttr.frame.origin.y, currAttr.frame.size.width, currAttr.frame.size.height);
      }
      prevAttr = currAttr;
    }
  }
  return  layoutAttributes;
}

@end
