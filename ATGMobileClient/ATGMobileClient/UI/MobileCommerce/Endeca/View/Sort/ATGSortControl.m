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



#import "ATGSortControl.h"
#import <EMMobileClient/EMSortOptionLabel.h>
#import "ATGSortOptionPair.h"
#import "NSArray+InitializeWithDefaults.h"

#define SORT_KEY @"Ns="
#define SORT_SEPARATOR @"%7C"
#define ATG_SORT_KEY @"sort="
#define ATG_SORT_SEPARATOR @"%3A"

@interface ATGSortControl ()
@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@end

@implementation ATGSortControl

- (id)initWithFrame:(CGRect)frame sortOptions:(NSArray *)pSortOptions {
  if (self = [super initWithFrame:frame]) {
    [self addSubview:[self controlWithSortOptions:[self makePairsFromSorts:pSortOptions]]];
  }
  return self;
}

- (NSArray *)makePairsFromSorts:(NSArray *)pSortOptions {

  NSMutableArray *sortsOrder = [NSMutableArray arrayWithCapacity:0];
  NSMutableDictionary *sortKeys = [NSMutableDictionary dictionaryWithCapacity:0];
  
  //Find all sort keys
  for (EMSortOptionLabel *sortOption in pSortOptions) {
    NSRange sortParamLocation =  [sortOption.state rangeOfString:SORT_KEY];
    NSString *sortSeparator = SORT_SEPARATOR;
    
    if (sortParamLocation.length == 0) {
      sortParamLocation = [sortOption.state rangeOfString:ATG_SORT_KEY];
      sortSeparator = ATG_SORT_SEPARATOR;
    }
    
    if (sortParamLocation.length > 0) {
      NSString *temp = [sortOption.state substringFromIndex:sortParamLocation.location + sortParamLocation.length];
      NSString *sortKey = [temp substringToIndex:[temp rangeOfString:sortSeparator].location];
      NSMutableArray *arr = [NSMutableArray arrayWithArray:[sortKeys valueForKey:sortKey]];
      [arr addObject:sortOption];
      if (arr.count == 1)
        [sortsOrder addObject:sortKey]; //This is used to preserve sort order only add the first time since these might be pairs.
      [sortKeys setObject:[NSArray arrayWithArray:arr] forKey:sortKey];
    } else {
      [sortKeys setObject:[NSArray arrayWithObject:sortOption] forKey:@"Default"];
      [sortsOrder addObject:@"Default"]; //This is used to preserve sort order
    }
  }

  NSMutableArray *sorts = [NSMutableArray initializeWithObjectClass:[NSObject class] size:sortsOrder.count];

  //Group the sorts by key, preserve sort order by replacing objects in pre-initialized sorts array at sortsOrders indexOfObject:key index.
  for (NSString *key in [sortKeys allKeys]) {
    NSArray *value = [sortKeys valueForKey:key];
    if (value.count > 1) {
      [sorts replaceObjectAtIndex:[sortsOrder indexOfObject:key] withObject:[[ATGSortOptionPair alloc] initWithDefaultSort:[value objectAtIndex:0] secondarySort:[value objectAtIndex:1]]];
    } else {
      [sorts replaceObjectAtIndex:[sortsOrder indexOfObject:key] withObject:[value objectAtIndex:0]];
    }
  }
  
  return self.sorts = sorts;
}

- (UISegmentedControl *)controlWithSortOptions:(NSArray *)pSortOptions {
  UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:[NSArray array]];
  [segControl addTarget:self action:@selector(sort:) forControlEvents:UIControlEventValueChanged];
  segControl.frame = self.bounds;
  [segControl setBackgroundImage:[UIImage imageNamed:@"emptyBackground"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [segControl setBackgroundImage:[UIImage imageNamed:@"emptyBackgroundSelected"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
  [segControl setDividerImage:[UIImage imageNamed:@"menu-divider"] forLeftSegmentState:UIControlStateNormal | UIControlStateSelected rightSegmentState:UIControlStateNormal | UIControlStateSelected barMetrics:UIBarMetricsDefault];
 
  [segControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];
  
  [segControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateSelected];
  
  for (int i = 0; i < pSortOptions.count; i++) {
    EMSortOptionLabel *sort = [pSortOptions objectAtIndex:i];
    NSString *title = [sort.label stringByReplacingOccurrencesOfString:@"sort." withString:@""];
    title = [title stringByReplacingOccurrencesOfString:@"common." withString:@""];
    [segControl insertSegmentWithTitle:title atIndex:i animated:NO];
    
    if ([sort.selected boolValue] && i > 0) {
      [segControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    } else if (i == 0) {
      [segControl setSelectedSegmentIndex:0];
    }
    
  }
  return segControl;
}

- (void)sort:(id)sender {
  UISegmentedControl *segControl = (UISegmentedControl *)sender;
  id obj = [self.sorts objectAtIndex:segControl.selectedSegmentIndex];
  EMAction *sortAction = [self.sorts objectAtIndex:segControl.selectedSegmentIndex];
  if ([obj isKindOfClass:[ATGSortOptionPair class]]) {
    sortAction = [(ATGSortOptionPair *)obj actionForNextSort];
  }
  if ([self.delegate respondsToSelector:@selector(didSelectSortAction:)]) {
    [self.delegate didSelectSortAction:sortAction];
  }
}

@end
