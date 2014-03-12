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



#import "EMContentItemList.h"
#import "EMContentItem.h"

@interface EMContentItemList ()
@property (nonatomic, retain) NSMutableArray *contentItemList;
@end

@implementation EMContentItemList
@synthesize contentItemList = _contentItemList;
- (id)init {
  if (self = [super init]) {
    self.contentItemList = [NSMutableArray arrayWithCapacity:0];
  }
  return self;
}

- (id)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        self.contentItemList = [NSMutableArray arrayWithCapacity:[array count]];
        [self.contentItemList addObjectsFromArray:array];
    }
    return self;
}

- (void) addContentItemsFromList:(EMContentItemList *)pContentItemList {
    for (EMContentItem *pContentItem in pContentItemList) {
        if (![self containsContentItem:pContentItem]) {
            [self.contentItemList addObject:pContentItem];
        }
    }
}

- (void)addContentItem:(EMContentItem *)pContentItem {
  if (![self containsContentItem:pContentItem]) {
    [self.contentItemList addObject:pContentItem];
  }
}

- (void)removeContentItem:(EMContentItem *)pContentItem {
  if ([self containsContentItem:pContentItem]) {
    [self.contentItemList removeObject:pContentItem];
  }
}

- (BOOL)containsContentItem:(EMContentItem *)pContentItem {
  if ([self.contentItemList containsObject:pContentItem]) {
    return YES;
  }
  return NO;
}

- (EMContentItem *)contentItemAtIndex:(NSUInteger)pIndex {
  if (self.contentItemList.count > pIndex) {
    return [self.contentItemList objectAtIndex:pIndex];
  }
  return nil;
}

- (NSUInteger)indexOfContentItem:(EMContentItem *)pContentItem {
  if ([self.contentItemList containsObject:pContentItem]) {
    return [self.contentItemList indexOfObject:pContentItem];
  }
  return NSNotFound;
}

- (EMContentItemList *)contentItemsWithType:(NSString *)pType {
    
  EMContentItemList *list = [[EMContentItemList alloc] init];
    
  for (EMContentItem *it in self.contentItemList) {
    if ([it.type isEqualToString:pType]) {
        [list addContentItem:it];
    }
  }
  return list;
}

- (NSUInteger)count {
  return [self.contentItemList count];
}

- (id)objectAtIndex:(NSUInteger)index {
    if (self.contentItemList.count > index) {
        return [self.contentItemList objectAtIndex:index];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];
  ((EMContentItemList *)copy).contentItemList = self.contentItemList;
  return copy;
}

- (NSString *)description {
  return self.contentItemList.description;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained []) stackbuf count:(NSUInteger)len {
  return [self.contentItemList countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
