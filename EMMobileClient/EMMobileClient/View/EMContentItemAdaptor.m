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

#import "EMContentItemAdaptor.h"
#import "EMAdaptorManager.h"
#import "EMContentItemRenderer.h"
#import "EMContentItemList.h"
#import "EMContentItem.h"
#import "EMAssemblerViewController.h"

@interface EMContentItemAdaptor ()
@property (nonatomic, readwrite) BOOL collapsed;
@end

@implementation EMContentItemAdaptor
@synthesize contentItem = _contentItem, adaptors = _adaptors, controller = _controller;

- (NSString *)getClassPrefix {
  return @"";
}

- (id)initWithContentItem:(EMContentItem *)pContentItem controller:(EMAssemblerViewController *)pController {
  if ((self = [super init])) {
    self.contentItem = pContentItem;
    self.controller = pController;
    self.adaptors = [NSMutableArray arrayWithCapacity:0];
    [self layoutContents];
  }
  return self;
}

- (void)layoutContentsForKey:(NSString *)pKey {
  if ([self.contentItem.attributes valueForKey:pKey]) {
    EMContentItemList *contentList = (EMContentItemList *)[self.contentItem.attributes valueForKey:pKey];
    for (EMContentItem *it in contentList) {
      EMContentItemAdaptor *adaptor = [self.controller.adaptorManager adaptorForContentItem:it controller:self.controller];
      if (adaptor)
        [self.adaptors addObject:adaptor];
    }
  }
}

- (void)layoutContents {
  [self layoutContentsForKey:@"contents"];
}

#pragma mark -
#pragma Main Rendering Hooks

- (NSInteger)numberOfItemsInContentItem {
  return 0;
}

- (Class)rendererClassForIndex:(NSInteger)pIndex {
  NSString *className = [self.contentItem.type stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
  NSString *baseRendererClassName = [NSString stringWithFormat:@"%@%@Renderer", [self getClassPrefix], className];
  Class baseRendererClass = NSClassFromString(baseRendererClassName);
  
  // if no class is found try without the prefix
  if(baseRendererClass == nil) {
    baseRendererClassName = [NSString stringWithFormat:@"%@Renderer", self.contentItem.type];
    baseRendererClass = NSClassFromString(baseRendererClassName);

    // if no class is found still then use the default adapter
    if (baseRendererClass == nil)
      baseRendererClass = [EMContentItemRenderer class];
  }

  return baseRendererClass;
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  return self.contentItem;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  return CGSizeMake(0, 0);
}

- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex{
  //No-Op stub
}

#pragma mark -
#pragma Header Rendering Hooks

- (Class)headerRendererClass {
  NSString *className = [self.contentItem.type stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
  NSString *baseHeaderRendererClassName = [NSString stringWithFormat:@"%@%@SectionHeaderRenderer",
          [self getClassPrefix], className];
  Class baseHeaderRendererClass = NSClassFromString(baseHeaderRendererClassName);
  
  // if no class is found try without the prefix
  if(baseHeaderRendererClass == nil) {
    baseHeaderRendererClassName = [NSString stringWithFormat:@"%@SectionHeaderRenderer", self.contentItem.type];
    baseHeaderRendererClass = NSClassFromString(baseHeaderRendererClassName);

    // if no class is found still then use the default adapter
    if (baseHeaderRendererClass == nil)
      baseHeaderRendererClass = [EMContentItemCollectionReusableView class];
  }

  return baseHeaderRendererClass;
}

- (id)objectToBeRenderedForHeader {
  return self.contentItem;
}

- (CGSize)referenceSizeForHeader {
  return CGSizeMake(0, 0);
}

#pragma mark -
#pragma Footer Rendering Hooks

- (Class)footerRendererClass {
  NSString *className = [self.contentItem.type stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
  NSString *baseFooterRendererClassName = [NSString stringWithFormat:@"%@%@SectionFooterRenderer",
          [self getClassPrefix], className];
  Class baseFooterRendererClass = NSClassFromString(baseFooterRendererClassName);
  
  // if no class is found try without the prefix
  if(baseFooterRendererClass == nil) {
    baseFooterRendererClassName = [NSString stringWithFormat:@"%@SectionFooterRenderer", self.contentItem.type];
    baseFooterRendererClass = NSClassFromString(baseFooterRendererClassName);

    // if no class is found still then use the default adapter
    if (baseFooterRendererClass == nil)
      baseFooterRendererClass = [EMContentItemCollectionReusableView class];
  }
  
  return baseFooterRendererClass;
}

- (id)objectToBeRenderedForFooter {
  return self.contentItem;
}

- (CGSize)referenceSizeForFooter {
  return CGSizeMake(0, 0);
}

#pragma mark -
#pragma SupplementaryElement Hook

- (void)usingRenderer:(EMContentItemCollectionReusableView *)pRenderer forSupplementaryElementOfKind:(NSString *)pKind {
  
}

#pragma mark -
#pragma Other Delegate Stuffs

- (CGFloat)minimumLineSpacing {
  return 0;
}

- (UIEdgeInsets)edgeInsets {
  return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)minimumInteritemSpacing {
  return 0;
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return NO;
}

- (void)didHighlightItemAtIndex:(NSInteger)pIndex {
  
}

- (void)didUnhighlightItemAtIndex:(NSInteger)pIndex {

}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
    
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return NO;
}

#pragma mark -
#pragma NSObject override

- (NSString *)description {
  return [NSString stringWithFormat:@"ContentItem: %@", self.contentItem.type];
}

@end
