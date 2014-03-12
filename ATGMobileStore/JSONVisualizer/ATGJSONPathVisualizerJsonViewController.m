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



#import "ATGJSONPathVisualizerJsonViewController.h"

#import <EMMobileClient/EMContentItem.h>
#import <EMMobileClient/EMContentItemList.h>
#import <EMMobileClient/EMDataObject.h>

@interface ATGJSONPathVisualizerJsonViewController ()
@property (nonatomic, strong) UITextView *jsonTextView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) id currentJsonData;

- (void)displayFormattedJson;
- (void)displayRawJson;
- (NSString *)buildRawJsonFromDictionary:(NSDictionary *)dictionary withDepth:(NSInteger)depth;
@end

@implementation ATGJSONPathVisualizerJsonViewController

- (void)loadView {
  [super loadView];
  
  self.view.backgroundColor = (UIColor *)[[ATGThemeManager themeManager] findResourceById:@"quaternaryColor"];
  
  self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Formatted JSON", @"Raw JSON"]];
  self.segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
  self.segmentedControl.selectedSegmentIndex = 0;
  [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateNormal];
  [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil] forState:UIControlStateSelected];
  [self.segmentedControl addTarget:self action:@selector(switchJsonView:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:self.segmentedControl];
  
  self.jsonTextView = [[UITextView alloc] initWithFrame:CGRectZero];
  self.jsonTextView.textAlignment = NSTextAlignmentLeft;
  self.jsonTextView.font = [UIFont fontWithName:@"Courier" size:14.0f];
  [self.jsonTextView setEditable:NO];
  [self.view addSubview:self.jsonTextView];
  
  self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
  self.jsonTextView.translatesAutoresizingMaskIntoConstraints = NO;
  
  NSDictionary *views = @{@"textView":self.jsonTextView, @"segControl":self.segmentedControl};
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%d-[segControl(==250)]", 198] options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[textView]-5-|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[segControl(==30)]-10-[textView]-5-|" options:0 metrics:nil views:views]];
  
  self.currentJsonData = nil;
}

- (void)switchJsonView:(id)sender {
  UISegmentedControl *segControl = (UISegmentedControl *)sender;
  if (segControl.selectedSegmentIndex == 0) {
    [self displayFormattedJson];
  } else if (segControl.selectedSegmentIndex == 1) {
    [self displayRawJson];
  }
}

- (void)loadJSON:(id)json {
  self.currentJsonData = json;
  
  if (self.segmentedControl.selectedSegmentIndex == 0) {
    [self displayFormattedJson];
  } else if (self.segmentedControl.selectedSegmentIndex == 1) {
    [self displayRawJson];
  }
}

- (void)displayFormattedJson {
  if (self.currentJsonData) {
    id json = self.currentJsonData;
    NSMutableString *jsonStr = [[NSMutableString alloc] initWithCapacity:0];
    
    if ([json isKindOfClass:[EMContentItem class]]) {
      EMContentItem *item = (EMContentItem *)json;
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n", item.description]];
      
    } else if ([json isKindOfClass:[EMContentItemList class]]) {
      EMContentItemList *list = (EMContentItemList *)json;
      for (EMContentItem *item in list) {
        [jsonStr appendString:[NSString stringWithFormat:@"%@\n", item.description]];
      }
      
    } else if ([json isKindOfClass:[NSArray class]]) {
      for (id item in ((NSArray *)json)) {
        if ([item isKindOfClass:[NSString class]]) {
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", (NSString *)item]];
          
        } else if ([item isKindOfClass:[NSNumber class]]) {
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [(NSNumber *)item stringValue]]];
          
        } else if ([item isKindOfClass:[EMDataObject class]]) {
          EMDataObject *edo = (EMDataObject *)item;
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", edo.description]];
          
        }
      }
    } else if ([json isKindOfClass:[NSString class]]) {
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", (NSString *)json]];
      
    } else if ([json isKindOfClass:[NSNumber class]]) {
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [(NSNumber *)json stringValue]]];
      
    } else if ([json isKindOfClass:[EMDataObject class]]) {
      EMDataObject *edo = (EMDataObject *)json;
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", edo.description]];
      
    }
    
    [self.jsonTextView setText:jsonStr];
  }
}

- (void)displayRawJson {
  if (self.currentJsonData) {
    id json = self.currentJsonData;
    NSMutableString *jsonStr = [[NSMutableString alloc] initWithCapacity:0];

    if ([json isKindOfClass:[EMContentItem class]]) {
      EMContentItem *item = (EMContentItem *)json;
      [jsonStr appendString:[self buildRawJsonFromDictionary:item.attributes withDepth:0]];
      
    } else if ([json isKindOfClass:[EMContentItemList class]]) {
      EMContentItemList *list = (EMContentItemList *)json;
      for (EMContentItem *item in list) {
        [jsonStr appendString:[NSString stringWithFormat:@"%@\n", [self buildRawJsonFromDictionary:item.attributes withDepth:0]]];
      }
      
    } else if ([json isKindOfClass:[NSArray class]]) {
      for (id item in ((NSArray *)json)) {
        if ([item isKindOfClass:[NSString class]]) {
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", (NSString *)item]];
          
        } else if ([item isKindOfClass:[NSNumber class]]) {
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [(NSNumber *)item stringValue]]];
          
        } else if ([item isKindOfClass:[EMDataObject class]]) {
          EMDataObject *edo = (EMDataObject *)item;
          [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [self buildRawJsonFromDictionary:edo.dictionary withDepth:0]]];
          
        }
      }
    } else if ([json isKindOfClass:[NSString class]]) {
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", (NSString *)json]];
      
    } else if ([json isKindOfClass:[NSNumber class]]) {
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [(NSNumber *)json stringValue]]];
      
    } else if ([json isKindOfClass:[EMDataObject class]]) {
      EMDataObject *edo = (EMDataObject *)json;
      [jsonStr appendString:[NSString stringWithFormat:@"%@\n\n", [self buildRawJsonFromDictionary:edo.dictionary withDepth:0]]];
      
    }
    
    [self.jsonTextView setText:jsonStr];
  }
}

- (NSString *)buildRawJsonFromDictionary:(NSDictionary *)dictionary withDepth:(NSInteger)depth {
  NSMutableString *indent = [[NSMutableString alloc] initWithCapacity:0];
  NSMutableString *retval = [[NSMutableString alloc] initWithCapacity:0];
  
  // build indent based on depth
  for (NSInteger i = 0; i < depth; i++) {
    [indent appendString:@"  "];
  }
  
  // recursively grab the raw json
  for (id key in [dictionary allKeys]) {
    id val = [dictionary objectForKey:key];
    
    [retval appendString:[NSString stringWithFormat:@"\n%@%@ = ", indent, key]];
    
    if ([val isKindOfClass:[EMContentItem class]]) {
      [retval appendString:[self buildRawJsonFromDictionary:((EMContentItem *)val).attributes withDepth:depth + 1]];
      
    } else if ([val isKindOfClass:[EMContentItemList class]]) {
      for (EMContentItem *item in (EMContentItemList *)val) {
        [retval appendString:[self buildRawJsonFromDictionary:item.attributes withDepth:depth + 1]];
      }
      
    } else if ([val isKindOfClass:[EMDataObject class]]) {
      [retval appendString:[self buildRawJsonFromDictionary:((EMDataObject *)val).dictionary withDepth:depth + 1]];
      
    } else if ([val isKindOfClass:[NSArray class]]) {
      for (id item in (NSArray *)val) {
        [retval appendString:indent];
        
        if ([item isKindOfClass:[EMContentItem class]]) {
          [retval appendString:[self buildRawJsonFromDictionary:((EMContentItem *)item).attributes withDepth:depth + 1]];
          
        } else if ([item isKindOfClass:[EMContentItemList class]]) {
          for (EMContentItem *i in (EMContentItemList *)item) {
            [retval appendString:[self buildRawJsonFromDictionary:i.attributes withDepth:depth + 1]];
          }
          
        } else if ([item isKindOfClass:[EMDataObject class]]) {
          [retval appendString:[self buildRawJsonFromDictionary:((EMDataObject *)item).dictionary withDepth:depth + 1]];
          
        } else {
          [retval appendString:[NSString stringWithFormat:@"%@", item]];
          
        }
      }
    } else {
      [retval appendString:[NSString stringWithFormat:@"%@", val]];
    }
  }
  return retval;
}

@end
