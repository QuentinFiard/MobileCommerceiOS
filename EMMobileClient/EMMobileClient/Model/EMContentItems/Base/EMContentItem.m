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



#import "EMContentItem.h"
#import "EMContentItemList.h"

@interface EMContentItem()
- (NSString *)descriptionWithIndent:(NSInteger)depth;
@end

@implementation EMContentItem
@synthesize type = _type, name = _name, attributes = _attributes, subcontent = _subcontent; 

- (id)initWithDictionary:(NSDictionary *)pDictionary {
  if (self = [super init]) {
    self.attributes = pDictionary;
    NSMutableArray *subcontent = [NSMutableArray arrayWithCapacity:0];
    //NSLog(@"CONTENT_ITEM: %@", pDictionary.description);
    for (NSString *key in [pDictionary allKeys]) {
      id currObj = [pDictionary objectForKey:key];
      NSString *theKey = key;
          
      if ([theKey rangeOfString:@"@"].location == 1) {
        theKey = [theKey substringFromIndex:1];
      }
          
      SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [theKey stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[theKey substringToIndex:1] uppercaseString]]]);
  
      if ([[self class] instancesRespondToSelector:sel]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:sel withObject:currObj];
        #pragma clang diagnostic pop
      }
          
      if ([currObj isKindOfClass:[EMContentItemList class]]) {
        [subcontent addObject:currObj];
      }
    }
    self.subcontent = subcontent;
  }
  return self;
}

- (NSString *)description {
  return [self descriptionWithIndent:0];
}

- (NSString *)descriptionWithIndent:(NSInteger)depth {
  NSMutableString *description = [[NSMutableString alloc] initWithCapacity:0];
  NSMutableString *indent = [[NSMutableString alloc] initWithCapacity:0];
  
  for (NSInteger index = 0; index < depth; index++) {
    [indent appendString:@"\t"];
  }
  
  [description appendString:[NSString stringWithFormat:@"%@# Content Item With:\n", indent]];
  [description appendString:[NSString stringWithFormat:@"%@    Type: %@\n", indent, self.type]];
  [description appendString:[NSString stringWithFormat:@"%@    Name: %@\n", indent, self.name]];
  [description appendString:[NSString stringWithFormat:@"%@    Subcontent (number of items: %d) [", indent, self.subcontent.count]];
  
  if (self.subcontent.count > 0) {
    [description appendString:@"\n"];
  }
  
  for (id item in self.subcontent) {
    if ([item isKindOfClass:[EMContentItemList class]]) {
      EMContentItemList *contentItemList = (EMContentItemList *)item;
      for (EMContentItem *contentItem in contentItemList) {
        [description appendString:[NSString stringWithFormat:@"%@",[contentItem descriptionWithIndent:depth + 1]]];
      }
    } else if ([item isKindOfClass:[EMContentItem class]]) {
      EMContentItem *contentItem = (EMContentItem *)item;
      [description appendString:[NSString stringWithFormat:@"%@",[contentItem descriptionWithIndent:depth + 1]]];
    }
  }
  
  if (self.subcontent.count > 0) {
    [description appendString:[NSString stringWithFormat:@"%@    ]\n", indent]];
  } else {
    [description appendString:@" ]\n"];
  }
  
  return description;
}

- (BOOL)isContentItemWithType:(NSString *)pType andValue:(NSString *)pValue forKey:(NSString *)pKey {
  if ([self.type isEqualToString:pType] && ((!pKey && !pValue) || [[self.attributes valueForKey:pKey] isEqualToString:pValue])) {
    return YES;
  }
  return NO;
}
@end
