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

#import "ATGHorizontalResultsListRenderer_iPad.h"

@implementation ATGHorizontalResultsListRenderer_iPad

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.carousel.translatesAutoresizingMaskIntoConstraints = NO;
    self.previousPageButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.nextPageButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat yPositionBttns = (frame.size.height/2) - 25;
    NSMutableArray *constraints = [[NSMutableArray alloc]initWithCapacity:0];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[carousel]-50-|"  options:0 metrics:nil views:@{@"carousel":self.carousel}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[carousel(130)]"  options:0 metrics:nil views:@{@"carousel":self.carousel}]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[previousPageButton]" options:0 metrics:nil views:@{@"previousPageButton":self.previousPageButton}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[previousPageButton]", yPositionBttns] options:0 metrics:nil views:@{@"previousPageButton":self.previousPageButton}]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[nextPageButton]-5-|" options:0 metrics:nil views:@{@"nextPageButton":self.nextPageButton}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[nextPageButton]", yPositionBttns] options:0 metrics:nil views:@{@"nextPageButton":self.nextPageButton}]];
    
    [self.contentView addConstraints:constraints];
  }

  return self;
}

-(CGSize)itemSize:(CGRect)rendererFrame {
  return CGSizeMake(160, 130);
}

-(CGSize)pageFrame:(CGRect)rendererFrame {
  return CGSizeMake(rendererFrame.size.width - 100, rendererFrame.size.height - 20);
}

-(UIEdgeInsets)edgeInsets:(CGRect)rendererFrame {
  return UIEdgeInsetsZero;
}

-(CGRect)carouselFrame:(CGRect)rendererFrame {
  return CGRectZero;
}

-(CGRect)previousPageButtonFrame:(CGRect)rendererFrame {
  return CGRectZero;
}

-(CGRect)nextPageButtonFrame:(CGRect)rendererFrame {
  return CGRectZero;
}

-(NSString *) previousPageButtonImage {
  return @"icon-blp-resultsList-previousArrow@2x";
}

-(NSString *) nextPageButtonImage {
  return @"icon-blp-resultsList-nextArrow@2x";
}

- (void)layoutSubviews {
  CGSize pageSize = [self pageFrame:self.frame];
  self.carousel.frame = CGRectMake(0, 0, pageSize.width, pageSize.height - 20);
  self.carousel.pageSize = pageSize;
  self.carousel.itemSize = [self itemSize:CGRectNull];

  // We want to show a MAX of 4 items
  NSInteger numItemsPerPage = MIN(4, (self.frame.size.width - 100) / self.carousel.itemSize.width);
  CGFloat remainingSpace = self.frame.size.width - 100 - (numItemsPerPage * self.carousel.itemSize.width);
  if (numItemsPerPage > 1)
    self.carousel.itemSpacing = remainingSpace / (numItemsPerPage - 1);
  else
    self.carousel.itemSpacing = remainingSpace;

  [self.carousel reloadData];
  [self.carousel setNeedsLayout];

  [super layoutSubviews];
}

@end
