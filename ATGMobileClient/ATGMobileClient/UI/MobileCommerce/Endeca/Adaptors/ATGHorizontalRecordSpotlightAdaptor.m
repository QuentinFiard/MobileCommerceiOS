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

#import "ATGHorizontalRecordSpotlightAdaptor.h"
#import "ATGHorizontalRecordSpotlightRenderer.h"
#import <EMMobileClient/EMHorizontalRecordSpotlight.h>
#import "ATGSearchViewController.h"
#import <ATGUIElements/ATGCarouselView.h>
#import "ATGFeaturedProductSpotlightCarouselCell.h"
#import "ATGHorizontalRecordSpotlightSectionHeaderRenderer.h"

@interface ATGHorizontalRecordSpotlightAdaptor () <ATGCarouselDelegate, ATGCarouselDataSource>
@property (nonatomic, strong) EMHorizontalRecordSpotlight *contentItem;
@end

@implementation ATGHorizontalRecordSpotlightAdaptor
@synthesize contentItem = _contentItem;

- (NSInteger)numberOfItemsInContentItem {
  return 1;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  return CGSizeMake(320, 100);
}

- (CGSize)referenceSizeForHeader {
  return CGSizeMake(320, 30);
}

- (CGSize)referenceSizeForFooter {
  return CGSizeMake(320, 1);
}

- (id)objectToBeRenderedForHeader {
  return self.contentItem.name;
}

-(Class)headerRendererClass {
  return [ATGHorizontalRecordSpotlightSectionHeaderRenderer class];
}

- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex {
  ATGHorizontalRecordSpotlightRenderer *renderer = (ATGHorizontalRecordSpotlightRenderer *)pRenderer;
  [renderer.carousel registerClass:[ATGFeaturedProductSpotlightCarouselCell class] forCellWithReuseIdentifier:@"Cell"];
  renderer.carousel.delegate = self;
  renderer.carousel.dataSource = self;
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (void)carousel:(ATGCarouselView *)pCarousel didSelectItemAtIndex:(NSInteger)pIndex isActiveItem:(BOOL)pActiveItem {
  [(ATGSearchViewController *)self.controller loadDetailsForProduct:(id<RenderableProduct>)[self.contentItem.records objectAtIndex:pIndex]];
}

- (UICollectionViewCell *)carousel:(ATGCarouselView *)pCarousel cellForItemAtIndex:(NSInteger)pIndex {
  ATGFeaturedProductSpotlightCarouselCell *cell = (ATGFeaturedProductSpotlightCarouselCell *)[pCarousel dequeueReusableCellWithReuseIdentifier:@"Cell" forIndex:pIndex];
  if (pIndex >= 0 && pIndex < [self.contentItem.records count]) {
    EMRecord *record = (EMRecord *)[self.contentItem.records objectAtIndex:pIndex];
    [cell setRecord:record];
  } else {
    [cell setRecord:nil]; // placeholder cell to handle cases where current page has fewer items to render than its max capacity
  }
  return cell;
}

- (NSInteger)numberOfItemsInCarousel:(ATGCarouselView *)pCarousel {
  return self.contentItem.records.count;
}

@end

