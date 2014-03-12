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
#import "ATGSKUPicker.h"
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGRestManager.h>

#pragma mark - ATGSKUPicker private protocol declaration
#pragma mark -
@interface ATGSKUPicker ()

#pragma mark - IB Outlets
@property (nonatomic, strong) IBOutlet UITableViewCell *skuCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *skuColorCell;

#pragma mark - Custom properties
@property (nonatomic, strong) UITableView *skuTable;
@property (nonatomic, strong) NSArray *skuArray;

@end

#pragma mark - ATGSKUPicker implementation
#pragma mark -
@implementation ATGSKUPicker
#pragma mark - Synthesized Properties
@synthesize skuTable, skuArray;
@synthesize delegate, selectedSku, selectedSkuString, owner, skuType, colorsArray, skuCell, skuColorCell;

- (id) initWithFrame:(CGRect)pFrame andSkuArray:(NSArray *)pArray {
  CGRect rect = pFrame;
  CGFloat height = [pArray count] * 44;
  if (height > 400) {
    rect.size.height = 400;
  } else {
    rect.size.height = height;
  }
  self = [super initWithFrame:rect];
  if (self) {
    [self setSkuArray:pArray];
    [self setSkuTable:[[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) style:UITableViewStylePlain]];
    [self skuTable].dataSource = self;
    [self skuTable].delegate = self;
    [self skuTable].layer.cornerRadius = 10;
    [self skuTable].layer.borderWidth = 1.0f;
    [self skuTable].layer.shadowOpacity = 0.5;
    [self addSubview:[self skuTable]];

    [self setColorsArray:[[NSArray alloc] init]];
  }
  return self;
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // Return the number of rows in the section.
  return [[self skuArray] count];
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (pIndexPath.row == 0) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.contentView.backgroundColor = [UIColor messageBackgroundColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [[self skuArray] objectAtIndex:0];
    cell.textLabel.textColor = [UIColor textHighlightedColor];
    cell.textLabel.font = [UIFont skuPickerFont];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
  }

  NSString *cellIdentifier = @"SkuCell";

  if ([[self colorsArray] count] != 0) {
    cellIdentifier = @"ColorSkuCell";
  }

  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];

  if (!cell) {
    if ([colorsArray count] == 0) {
      [[NSBundle mainBundle] loadNibNamed:@"ATGSkuCell" owner:self options:nil];
      cell = skuCell;
      cell.accessibilityHint = NSLocalizedStringWithDefaultValue(
        @"ATGSKUPicker.SkuAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to select sku", @"sku picker accessibility hint.");
      self.skuCell = nil;
    } else {
      [[NSBundle mainBundle] loadNibNamed:@"ATGColorSkuCell" owner:self options:nil];
      cell = skuColorCell;
      cell.accessibilityHint = NSLocalizedStringWithDefaultValue(
        @"ATGSKUPicker.SkuAccessibilityHint", nil, [NSBundle mainBundle],
        @"Double tap to select sku", @"sku picker accessibility hint.");
      self.skuColorCell = nil;
    }
  }

  if ([[[self skuArray] objectAtIndex:pIndexPath.row] isEqualToString:[self selectedSkuString]]) {
    UIImageView *checkMark = (UIImageView *)[cell viewWithTag:3];
    checkMark.hidden = NO;
    cell.accessibilityTraits = UIAccessibilityTraitSelected;
  }

  UILabel *skuLabel = (UILabel *)[cell viewWithTag:4];
  skuLabel.text = [[self skuArray] objectAtIndex:pIndexPath.row];

  if ([[self colorsArray] count] != 0) {
    ATGImageView *skuColor = (ATGImageView *)[cell viewWithTag:5];
    skuColor.imageURL = [ATGRestManager getAbsoluteImageString:[colorsArray objectAtIndex:(pIndexPath.row - 1)]];
  }

  return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (pIndexPath.row != 0) {
    UITableViewCell *cell = [pTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self selectedSku] inSection:0]];
    UIImageView *checkMark = (UIImageView *)[cell viewWithTag:3];
    checkMark.hidden = YES;
    cell.accessibilityTraits = UIAccessibilityTraitNone;

    [self setSelectedSku:pIndexPath.row];

    cell = [pTableView cellForRowAtIndexPath:pIndexPath];
    checkMark = (UIImageView *)[cell viewWithTag:3];
    checkMark.hidden = NO;
    [self.delegate didSelectSkuName:[[self skuArray] objectAtIndex:[self selectedSku]] owner:[self owner] type:[self skuType]];
  }
  [pTableView deselectRowAtIndexPath:pIndexPath animated:NO];
}

@end