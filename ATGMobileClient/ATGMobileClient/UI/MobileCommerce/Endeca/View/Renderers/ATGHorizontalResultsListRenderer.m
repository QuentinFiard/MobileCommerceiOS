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

#import "ATGHorizontalResultsListRenderer.h"

@implementation ATGHorizontalResultsListRenderer
@synthesize carousel = _carousel;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  if (self) {
   
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    self.carousel = [[ATGCarouselView alloc]initWithFrame:[self carouselFrame:frame] layout:layout pageSize:[self pageFrame:frame] itemSize:[self itemSize:frame] edgeInsets:[self edgeInsets:frame]];
    self.carousel.backgroundColor = [UIColor clearColor];
    self.carousel.showPageControl = NO;
    self.carousel.itemSpacing = 10.0;
    [self.carousel setScrollEnabled:NO];
    [self.carousel setScrollToPosition:UICollectionViewScrollPositionLeft];
    [self.contentView addSubview:self.carousel];
    
    UIImage *previousButtonImg = [UIImage imageNamed:[self previousPageButtonImage]];
    UIImage *nextsButtonImg = [UIImage imageNamed:[self nextPageButtonImage]];
    
    self.previousPageButton = [[ATGButton alloc] initWithFrame:[self previousPageButtonFrame:frame]];
    [self.previousPageButton setImage:previousButtonImg forState:UIControlStateNormal];
    [self.previousPageButton addTarget:self action:@selector(didPressPreviousPageArrow:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.previousPageButton];
    
    self.nextPageButton = [[ATGButton alloc]initWithFrame:[self nextPageButtonFrame:frame]];
    [self.nextPageButton setImage:nextsButtonImg forState:UIControlStateNormal];
    [self.nextPageButton addTarget:self action:@selector(didPressNextPageArrow:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.nextPageButton];

    [self updateNavigationButtonState];
  }
  return self;
}

- (IBAction)didPressPreviousPageArrow:(id)sender {
  [self.carousel scrollToPreviousPage];
  [self updateNavigationButtonState];
}

- (IBAction)didPressNextPageArrow:(id)sender {
  [self.carousel scrollToNextPage];
  [self updateNavigationButtonState];
}

- (void)setObject:(id)pObject {
  [self.carousel reloadData];
  
  NSInteger itemsPerPage = (self.carousel.pageSize.width + self.carousel.itemSpacing)/self.carousel.itemSize.width;
  NSInteger firstPage = (NSInteger)[[(NSDictionary *)pObject valueForKey:@"firstItem"] integerValue];
  firstPage = firstPage/itemsPerPage;
  
  [self.carousel scrollToPageAtIndex:firstPage animated:NO];
  [self updateNavigationButtonState];
}

- (void)updateNavigationButtonState {
  if ([self.carousel isOnFirstPage]) {
    [self.previousPageButton setHidden:YES];
    
  } else {
    [self.previousPageButton setHidden:NO];
  }
  
  if([self.carousel isOnLastPage]) {
    [self.nextPageButton setHidden:YES];
  } else {
    [self.nextPageButton setHidden:NO];
  }
}

-(CGSize)itemSize:(CGRect)rendererFrame {
  return CGSizeMake(80, 80);
}

-(CGSize)pageFrame:(CGRect)rendererFrame {
  return CGSizeMake(rendererFrame.size.width - 60, rendererFrame.size.height);
}

-(UIEdgeInsets)edgeInsets:(CGRect)rendererFrame {
  return UIEdgeInsetsZero;
}

-(CGRect)carouselFrame:(CGRect)rendererFrame {
  return CGRectMake(30, 0, rendererFrame.size.width - 60, rendererFrame.size.height);
}

-(CGRect)previousPageButtonFrame:(CGRect)rendererFrame {
  return CGRectMake(0, 55, 30, 30);
}

-(CGRect)nextPageButtonFrame:(CGRect)rendererFrame {
  return CGRectMake(290, 55, 30, 30);
}

-(NSString *) previousPageButtonImage {
  return @"icon-blp-resultsList-previousArrow";
}

-(NSString *) nextPageButtonImage {
  return @"icon-blp-resultsList-nextArrow";
}

@end
