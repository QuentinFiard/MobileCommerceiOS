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

#import "ATGCompareItem.h"
#import <ATGMobileClient/ATGProductGridViewCell.h>
#import <ATGMobileClient/ATGComparisonsItem.h>

#pragma mark - ATGCompareItem private protocol declaration
#pragma mark -
@interface ATGCompareItem ()
#pragma mark - IB Properties
@property (nonatomic, readwrite, weak) IBOutlet UIButton *viewButton;
@property (nonatomic, weak) IBOutlet UIButton *removeButton;
@property (nonatomic, weak) IBOutlet ATGProductGridViewCell *productView;
@property (nonatomic, weak) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *colorsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorsListLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizesListLabel;
@property (weak, nonatomic) IBOutlet UILabel *featuresTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *featuresListTitle;

#pragma mark - IB Actions
- (IBAction) didPressViewButton:(id)sender;
- (IBAction) didPressDeleteButton:(id)sender;
@end

#pragma mark - ATGCompareItem implementation
#pragma mark -
@implementation ATGCompareItem
#pragma mark - Synthesized Properties
@synthesize colorsTitleLabel;
@synthesize colorsListLabel;
@synthesize sizesTitleLabel;
@synthesize sizesListLabel;
@synthesize featuresTitleLabel;
@synthesize featuresListTitle;
@synthesize viewButton, removeButton, productView, view, delegate;

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  ATGComparisonsItem *product = [self objectToDisplay];
  [self.productView setImageURL:[product mediumImageUrl]];
  [self.productView setProductName:[product displayName]];
  
  // TODO: move this somewhere else.. maybe ProductGridViewCell
  if ([[product highestSalePrice] compare:[product lowestSalePrice]] != NSOrderedSame) {
    [self.productView setHighestPrice:[product highestSalePrice]];
    [self.productView setLowestPrice:[product lowestSalePrice]];
  } else {
    NSNumber *price = [product lowestSalePrice] ? [product lowestSalePrice] : [product lowestListPrice];
    [self.productView setPrice:price];
    if ([[product lowestSalePrice] compare:[product lowestListPrice]] == NSOrderedDescending) {
      [self.productView setOldPrice:[product lowestListPrice]];
    }
  }
  
  [self.productView setSiteID:[product siteId]];
  [self.productView setSiteName:[product siteName]];
  [[self productView] setNeedsLayout];

  //setup title text. hide empty labels
  if ([product.colors count] == 0) {
    self.colorsListLabel.hidden = YES;
    self.colorsTitleLabel.hidden = YES;
  } else {
    [[self colorsListLabel] setHidden:NO];
    [[self colorsTitleLabel] setHidden:NO];
    self.colorsTitleLabel.text =  NSLocalizedStringWithDefaultValue(
      @"ATGCompareProducts.ColorInfoTitle", nil, [NSBundle mainBundle],
      @"Colors:", @"Header title for list of product colors on compare screen");
    self.colorsListLabel.text = [product.colors componentsJoinedByString:@" / "];
  }
  if ([product.sizes count] == 0) {
    self.sizesListLabel.hidden = YES;
    self.sizesTitleLabel.hidden = YES;
  } else {
    [[self sizesListLabel] setHidden:NO];
    [[self sizesTitleLabel] setHidden:NO];
    self.sizesTitleLabel.text =  NSLocalizedStringWithDefaultValue(
      @"ATGCompareProducts.SizeInfoTitle", nil, [NSBundle mainBundle],
      @"Sizes:", @"Header title for list of product sizes on compare screen");
    self.sizesListLabel.text = [product.sizes componentsJoinedByString:@" / "];
  }
  if ([product.featureDisplayNames count] == 0) {
    self.featuresListTitle.hidden = YES;
    self.featuresTitleLabel.hidden = YES;
  } else {
    [[self featuresListTitle] setHidden:NO];
    [[self featuresTitleLabel] setHidden:NO];
    self.featuresTitleLabel.text =  NSLocalizedStringWithDefaultValue(
      @"ATGCompareProducts.FeatureInfoTitle", nil, [NSBundle mainBundle],
      @"Features:", @"Header title for list of product features on compare screen");
    self.featuresListTitle.text = [product.featureDisplayNames componentsJoinedByString:@", "];
  }
}

#pragma mark - UIAccessibility
- (BOOL) isAccessibilityElement {
  return NO;
}

- (NSInteger) accessibilityElementCount {
  if ([[self colorsListLabel] isHidden] &&
      [[self sizesListLabel] isHidden] &&
      [[self featuresListTitle] isHidden]) {
    return 3;
  } else {
    return 4;
  }
}

- (NSInteger) indexOfAccessibilityElement:(id)pElement {
  for (NSInteger index = 0; index < [self accessibilityElementCount]; index++) {
    if (pElement == [self accessibilityElementAtIndex:index]) {
      return index;
    }
  }
  return NSNotFound;
}

- (id) accessibilityElementAtIndex:(NSInteger)pIndex {
  if (pIndex == 0) {
    return [self productView];
  } else if (pIndex == 1 && [[self colorsListLabel] isHidden] &&
             [[self sizesListLabel] isHidden] && [[self featuresListTitle] isHidden]) {
    return [self viewButton];
  } else if (pIndex == 1) {
    NSString *description = @"";
    if (![[self colorsListLabel] isHidden]) {
      description = [description stringByAppendingString:[[self colorsTitleLabel] text]];
      description = [description stringByAppendingString:@" "];
      description = [description stringByAppendingString:[[[[self colorsListLabel] text] componentsSeparatedByString:@" / "] componentsJoinedByString:@", "]];
      description = [description stringByAppendingString:@". "];
    }
    if (![[self sizesListLabel] isHidden]) {
      description = [description stringByAppendingString:[[self sizesTitleLabel] text]];
      description = [description stringByAppendingString:@" "];
      description = [description stringByAppendingString:[[[[self sizesListLabel] text] componentsSeparatedByString:@" / "] componentsJoinedByString:@", "]];
      description = [description stringByAppendingString:@". "];
    }
    if (![[self featuresListTitle] isHidden]) {
      description = [description stringByAppendingString:[[self featuresTitleLabel] text]];
      description = [description stringByAppendingString:@" "];
      description = [description stringByAppendingString:[[self featuresListTitle] text]];
      description = [description stringByAppendingString:@". "];
    }
    [[self colorsListLabel] setAccessibilityLabel:description];
    return [self colorsListLabel];
  } else if (pIndex == 2 && [[self colorsListLabel] isHidden] &&
             [[self sizesListLabel] isHidden] && [[self featuresListTitle] isHidden]) {
    return [self removeButton];
  } else if (pIndex == 2) {
    return [self viewButton];
  } else if (pIndex == 3) {
    return [self removeButton];
  }
  return nil;
}

#pragma mark - Private methods

- (IBAction) didPressViewButton:(id)pSender {
  if ([self.delegate respondsToSelector:@selector(didPressViewProduct:)]) {
    [self.delegate performSelector:@selector(didPressViewProduct:) withObject:[self objectToDisplay]];
  }
}

- (IBAction) didPressDeleteButton:(id)pSender {
  if ([self.delegate respondsToSelector:@selector(didPressDeleteProduct:)]) {
    [self.delegate performSelector:@selector(didPressDeleteProduct:) withObject:[self objectToDisplay]];
  }
}

@end