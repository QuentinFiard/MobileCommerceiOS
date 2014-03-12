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

#import <UIKit/UIKit.h>
#import "EMAdaptorManager.h"
#import "EMContentItem.h"
#import "EMContentItemList.h"
#import "EMContentItemAdaptorFactory.h"
#import "EMAssemblerViewController.h"
#import "EMContentItemRenderer.h"

@interface EMAdaptorManager ()
@property (nonatomic, strong) NSMutableArray *adaptorSections;
- (EMContentItemAdaptor *)adaptorForItemAtIndexPath:(NSIndexPath *)pIndexPath;
@end

@implementation EMAdaptorManager
@synthesize adaptorSections = _adaptorSections;

- (id)init {
  if ((self = [super init])) {
      self.adaptorSections = [NSMutableArray arrayWithCapacity:0];
  }
  return self;
}

- (void)constructAdaptorForContentItem:(EMContentItem *)pContentItem withController:(EMAssemblerViewController *)pController {
  [self.adaptorSections removeAllObjects];
  EMContentItemAdaptor *adaptor = [self adaptorForContentItem:pContentItem controller:pController];
  [self parseAdaptors:adaptor];
}

- (void)constructAdaptorForContentItemList:(EMContentItemList *)pContentItemList withController:(EMAssemblerViewController *)pController {
  [self.adaptorSections removeAllObjects];
  for (EMContentItem *it in pContentItemList) {
    EMContentItemAdaptor *adaptor = [self adaptorForContentItem:it controller:pController];
    [self parseAdaptors:adaptor];
  }
}

- (EMContentItemAdaptor *)adaptorForContentItem:(EMContentItem *)pContentItem controller:(EMAssemblerViewController *)pController   {
  return [[EMContentItemAdaptorFactory sharedFactory] adaptorForContentItem:pContentItem withController:pController];
}

- (void)parseAdaptors:(EMContentItemAdaptor *)pAdaptor {
  [self.adaptorSections addObject:pAdaptor];
    
  for (EMContentItemAdaptor *adaptor in pAdaptor.adaptors) {
    if (adaptor.adaptors.count > 0) {
        [self parseAdaptors:adaptor];
    } else {
      [self.adaptorSections addObject:adaptor];
    }
  }
}

- (NSInteger)indexOfContentItem:(EMContentItem *)pContentItem {
  for (int i = 0; i < self.adaptorSections.count; i++) {
    EMContentItemAdaptor *adaptor = [self.adaptorSections objectAtIndex:i];
    if ([adaptor.contentItem isEqual:pContentItem])
      return i;
  }
  return NSNotFound;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.adaptorSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [((EMContentItemAdaptor *)[self.adaptorSections objectAtIndex:section]) numberOfItemsInContentItem];
}

- (EMContentItemAdaptor *)adaptorForItemAtIndexPath:(NSIndexPath *)pIndexPath {
  return [self adaptorForItemInSection:pIndexPath.section];
}

- (EMContentItemAdaptor *)adaptorForItemInSection:(NSInteger)pSection {
  return [self.adaptorSections objectAtIndex:pSection];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  
  Class rendererClass = [adaptor rendererClassForIndex:indexPath.row];
  NSString *cellIdentifier = [NSString stringWithFormat:@"%@", NSStringFromClass(rendererClass)];
  [collectionView registerClass:rendererClass forCellWithReuseIdentifier:cellIdentifier];
  
  EMContentItemRenderer *renderer = (EMContentItemRenderer *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  
  [adaptor usingRenderer:renderer forIndex:indexPath.row];
  id obj = [adaptor objectToBeRenderedAtIndex:indexPath.row];
  [renderer setObject:obj];
  return renderer;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)pCollectionView viewForSupplementaryElementOfKind:(NSString *)pKind atIndexPath:(NSIndexPath *)pIndexPath {
  
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:pIndexPath];
  Class rendererClass;
  id obj;
 
  if ([pKind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
    rendererClass = [adaptor headerRendererClass];
    obj = [adaptor objectToBeRenderedForHeader];
  } else if ([pKind isEqualToString:@"UICollectionElementKindSectionFooter"]) {
    rendererClass = [adaptor footerRendererClass];
    obj = [adaptor objectToBeRenderedForFooter];
  }
  
  NSString *cellIdentifier = [NSString stringWithFormat:@"%@", NSStringFromClass(rendererClass)];
  [pCollectionView registerClass:rendererClass forSupplementaryViewOfKind:pKind withReuseIdentifier:cellIdentifier];
  EMContentItemCollectionReusableView *renderer = (EMContentItemCollectionReusableView *)[pCollectionView dequeueReusableSupplementaryViewOfKind:pKind withReuseIdentifier:cellIdentifier forIndexPath:pIndexPath];
  [adaptor usingRenderer:renderer forSupplementaryElementOfKind:pKind];
  [renderer setObject:obj];
  return renderer;
}

#pragma mark -
#pragma UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  CGSize size = [adaptor sizeForRendererAtIndex:indexPath.row];
  if (size.height > 0.0 && size.width > 0.0)
      return size;
    
  Class rendererClass = [adaptor rendererClassForIndex:indexPath.row];
  EMContentItemRenderer *renderer = [[rendererClass alloc] initWithFrame:CGRectZero];
  id obj = [adaptor objectToBeRenderedAtIndex:indexPath.row];
  [renderer setObject:obj];
    
  return renderer.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
  EMContentItemAdaptor *adaptor = [self adaptorForItemInSection:section];
  return [adaptor minimumLineSpacing];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
  
  EMContentItemAdaptor *adaptor = [self adaptorForItemInSection:section];
  return [adaptor referenceSizeForHeader];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
  EMContentItemAdaptor *adaptor = [self adaptorForItemInSection:section];
  return [adaptor referenceSizeForFooter];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
  EMContentItemAdaptor *adaptor = [self adaptorForItemInSection:section];
  return [adaptor edgeInsets];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
  EMContentItemAdaptor *adaptor = [self adaptorForItemInSection:section];
  return [adaptor minimumInteritemSpacing];
}

#pragma mark -
#pragma UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
   
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  return [adaptor shouldHighlightItemAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  return [adaptor didHighlightItemAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  return [adaptor didUnhighlightItemAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)pCollectionView didSelectItemAtIndexPath:(NSIndexPath *)pIndexPath {
  [pCollectionView deselectItemAtIndexPath:pIndexPath animated:YES];
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:pIndexPath];
  return [adaptor didSelectItemAtIndex:pIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  EMContentItemAdaptor *adaptor = [self adaptorForItemAtIndexPath:indexPath];
  return [adaptor shouldSelectItemAtIndex:indexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
  return YES;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  UICollectionView *collectionView = (UICollectionView *)scrollView;
  [collectionView.collectionViewLayout invalidateLayout];
}

@end
