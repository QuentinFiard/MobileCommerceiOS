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



#import "EMJSONParser.h"
#import "EMContentItem.h"
#import "EMDataObject.h"
#import "EMContentItemList.h"

static EMJSONParser *parser;

NSString *const TYPE_KEY = @"@type";
NSString *const CLASS_KEY = @"@class";
NSString *const CLASS_PREFIX = @"EM";
NSString *const CLASS_PACKAGE = @"com.endeca.infront.cartridge.model.";

@implementation EMJSONParser

+ (EMJSONParser *)sharedParser {
    static dispatch_once_t pred_json_parser;
    dispatch_once(&pred_json_parser,
                  ^{
                      parser = [[EMJSONParser alloc] init];
                  }
                  );
    return parser;
}

- (Class) classForObjectWithAttribute:(NSString *) pAttribute value:(NSString *) pValue {
    Class clazz = nil;
    if ([pAttribute isEqualToString:TYPE_KEY]) {
        NSString *contentItemClassString = [NSString stringWithFormat:@"%@%@", CLASS_PREFIX, pValue];
        clazz = NSClassFromString(contentItemClassString);
        if (!clazz)
            clazz = [EMContentItem class];
    } else if ([pAttribute isEqualToString: CLASS_KEY]) {
        NSString *dataObjectClassString = [pValue stringByReplacingOccurrencesOfString:CLASS_PACKAGE withString:CLASS_PREFIX];
        clazz = NSClassFromString(dataObjectClassString);
        if (!clazz)
            clazz = [EMDataObject class];
    }
    return clazz;
}

- (id) parseArray:(NSArray *) pArray {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    EMContentItemList *contentItemList = [[EMContentItemList alloc] init];
    for (id it in (NSArray *) pArray) {
        if ([it isKindOfClass:[NSDictionary class]]) {
            id created = [self parseDictionary:(NSDictionary *)it];
            if ([created isKindOfClass:[EMContentItem class]]) {
                [contentItemList addContentItem:created];
            } else {
                NSLog(@"ADDING OBJECT TO ARRAY: %@", ((EMDataObject *)created).description);
                [arr addObject:created];
            }
        } else {
            [arr addObject:it];
        }
    }
    if ([contentItemList count] > 0 && [arr count] < 1) {
        NSLog(@"Setting Value: %@", contentItemList.description);
        return contentItemList;
    } else if ([contentItemList count] < 1 && [arr count] > 0) {
        NSLog(@"Setting Value: %@", arr.description);
        return arr;
    } else  {
        NSLog(@"Empty object: %@", pArray.description);
        return nil;
    }
}

- (EMContentItem *)parseDictionary:(NSDictionary *)pDictionary {
    // We (EMJSONParser) implement the JSONParserDelegate protocol, so pass 'self' to the superclass.
    return [super parseDictionary: pDictionary usingDelegate: self];
}

@end
