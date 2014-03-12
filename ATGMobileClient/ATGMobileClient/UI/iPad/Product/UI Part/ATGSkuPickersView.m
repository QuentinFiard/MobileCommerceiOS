/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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

#import "ATGSkuPickersView.h"
#import "ATGPickerTableViewController.h"
#import "ATGSku.h"
#import "ATGSkuTypes.h"

@interface ATGSkuPickersView ()

@property (nonatomic, strong) NSDictionary *skuTree;

@property (nonatomic, strong) NSMutableDictionary *selectedSkusByOption;

@end

@implementation ATGSkuPickersView

- (id)initWithFrame:(CGRect)frame product:(ATGProduct *)pProduct sku:(ATGSku *)pSku delegate:(NSObject<ATGSkuPickerDelegate>*)pDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    self.selectedSkusByOption = [NSMutableDictionary new];
    self.delegate = pDelegate;
    
    [self initSkuTreeWithSkus:pProduct.childSKUs types:pProduct.skuProperties];
    
    if ([self.skuTree count] == 0) {
      // there's nothing to select, no pickers will be rendered
      [self.delegate didSelectSku:[pProduct.childSKUs anyObject]];
      return self;
    }

    CGRect pickerFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,238,44);

    for (NSString *property in [self.skuTree allKeys]) {
      NSMutableArray *dataArray = [NSMutableArray array];
      [dataArray addObjectsFromArray:[[self.skuTree objectForKey:property] allKeys]];
      
      // sort the array
      if ([property isEqualToString:[ATGSize lowercaseString]]) {
        [dataArray sortUsingSelector:@selector(sizeCompare:)];
      } else {
        [dataArray sortUsingSelector:@selector(stringCompare:)];
      }
      
      ATGPickerTableViewController *pickerTableView = [[ATGPickerTableViewController alloc] initWithType:property dataArray:dataArray delegate:nil];
      NSString *singleValue;
      if (dataArray.count == 1) {
        singleValue = [dataArray objectAtIndex:0];
      }
      ATGPopoverPicker *picker = [[ATGPopoverPicker alloc] initWithFrame:pickerFrame pickerViewController:pickerTableView type:property singleValue:singleValue delegate:self];
      pickerTableView.delegate = picker;
      // if we're initializing with an already selected SKU, select its options in the pickers
      if (pSku) {
        [picker didSelectValue:[pSku valueForKey:property] forType:property];
      }
      [self addSubview:picker];
      pickerFrame.origin.y += 44 + 7;
    }
    
    CGRect myFrame = self.frame;
    
    myFrame.size.height = (44 + 7) * [self.skuTree count] - 7;

    self.frame = myFrame;
  }
  return self;
}

// calculate the selected sku by taking the intersection of sets of skus from selected options
- (ATGSku *) calculateSelectedSku {
  NSMutableSet *result;
  for (NSMutableSet *set in [self.selectedSkusByOption allValues]) {
    if (!result) {
      result = [NSMutableSet setWithSet:set];
    } else {
      [result intersectSet:set];
    }
  }
  // this shouldn't happen, but just in case...
  if ([result count] != 1) DebugLog(@"ERROR: can't calculate selected sku");
  
  return [result anyObject];
}

// takes in an array of ATGSku and sets up the 'sku tree',
// nested dictionaries in the form: type -> selection -> [skus]
// e.g.: "Color" -> "Blue" -> ["bluesku1", "bluesku2"]
- (void) initSkuTreeWithSkus:(NSSet *) pSkus types:(NSSet *) pTypes {
  // initialize the data struture
  NSMutableDictionary *types = [NSMutableDictionary new];
  self.skuTree = types;
  // place the skus in the correct buckets
  for (ATGSku *sku in pSkus) {
    for (NSString *type in pTypes) {
      // if the sku has a value for the type, e.g. "color"
      if ([sku valueForKey:type]) {
        NSMutableDictionary *typeDict = [types objectForKey:type];
        if (typeDict == nil) {
          // initialize the type dictionary of options
          typeDict = [NSMutableDictionary new];
          [types setObject:typeDict forKey:type];
        }
        // option, e.g. "blue"
        NSMutableSet *option = [typeDict objectForKey:[sku valueForKey:type]];
        if (option == nil) {
          // initialize the option set of skus
          option = [NSMutableSet new];
          [typeDict setObject:option forKey:[sku valueForKey:type]];
        }
        [option addObject:sku];
      }
    }
  }
  if (types.count == 0 && pSkus.count > 1) {
    //If there are multiple skus but no types, use displayName
    for (ATGSku *sku in pSkus) {
      NSString *type = @"displayName";
      NSMutableDictionary *typeDict = [types objectForKey:type];
      if (typeDict == nil) {
        // initialize the type dictionary of options
        typeDict = [NSMutableDictionary new];
        [types setObject:typeDict forKey:type];
      }
      NSMutableSet *option = [typeDict objectForKey:[sku valueForKey:type]];
      if (option == nil) {
        // initialize the option set of skus
        option = [NSMutableSet new];
        [typeDict setObject:option forKey:[sku valueForKey:type]];
      }
      [option addObject:sku];
    }
  }
}

#pragma mark - ATGPickerDelegate
- (void) didSelectValue:(NSString *)pSelected forType:(NSString *)pType {
  [self.selectedSkusByOption setValue:[[self.skuTree objectForKey:pType] objectForKey:pSelected] forKey:pType];
  if ([self.selectedSkusByOption count] == [self.skuTree count]) {
    [self.delegate didSelectSku:[self calculateSelectedSku]];
  }
}

@end
