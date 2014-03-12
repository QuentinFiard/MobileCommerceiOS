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

#import "ATGSort.h"
#define UNSELECTED_STATE @"UNSELECTED"
#define BDL [NSBundle mainBundle]

@interface ATGSort ()
@property (nonatomic, strong) NSDictionary *renderableSortKeys;
@end

@implementation ATGSort
@synthesize label = _label;

- (id)initWithDictionary:(NSDictionary *)pDictionary {
  self = [super initWithDictionary:pDictionary];
  if (self) {
    
    NSLocalizedStringWithDefaultValue(@"mobile.keyValue.keyExists", nil, [NSBundle mainBundle], @"Key already exists in cache.", @"Key already exists in cache.");
    self.renderableSortKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortTopPicks", nil, BDL, @"Top Picks", @"Text in sort bar"), @"common.topPicks",
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortTopPicksUnselected", nil, BDL, @"Top Picks", @"Text in sort bar"), [NSString stringWithFormat:@"common.topPicks%@", UNSELECTED_STATE],
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortNameASC", nil, BDL, @"Name \u25B2", @"Text in sort bar, unicode arrow for indicating direction"), @"sort.nameAZ",
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortNameDSC", nil, BDL, @"Name \u25BC", @"Text in sort bar, unicode arrow for indicating direction"), @"sort.nameZA",
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortNameASCUnselected", nil, BDL, @"Name", @"Text in sort bar"), [NSString stringWithFormat:@"sort.nameAZ%@", UNSELECTED_STATE],
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortNameDSCUnselected", nil, BDL, @"Name", @"Text in sort bar"), [NSString stringWithFormat:@"sort.nameZA%@", UNSELECTED_STATE],
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortPriceASC", nil, BDL, @"Price \u25B2", @"Text in sort bar, unicode arrow for indicating direction"), @"sort.priceLH",
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortPriceDSC", nil, BDL, @"Price \u25BC", @"Text in sort bar, unicode arrow for indicating direction"), @"sort.priceHL",
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortPriceASCUnselected", nil, BDL, @"Price", @"Text in sort bar"), [NSString stringWithFormat:@"sort.priceLH%@", UNSELECTED_STATE],
                               NSLocalizedStringWithDefaultValue(@"mobile.searchController.sortPriceDSCUnselected", nil, BDL, @"Price", @"Text in sort bar"), [NSString stringWithFormat:@"sort.priceHL%@", UNSELECTED_STATE],
                               nil];
    
  }
  return self;
}


- (NSString *)label {
  NSString *rendereableSortKey = [self.renderableSortKeys valueForKey:_label];
  if ([self.selected boolValue])
    return rendereableSortKey;
  else {
    return [self.renderableSortKeys valueForKey:[NSString stringWithFormat:@"%@%@", _label, UNSELECTED_STATE]];
  }
   
}

@end
