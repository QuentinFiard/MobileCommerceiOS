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
#import "ATGDatePicker.h"
#import "ATGDataFormatters.h"

#pragma mark - ATGBorderedLabel Definition
#pragma mark -

@interface ATGBorderedLabel : UILabel

#pragma mark - Custom Properties

@property (nonatomic, readwrite, assign) CGFloat borderWidth;

@end

#pragma mark - ATGDatePicker Private Protocol
#pragma mark -

@interface ATGDatePicker ()

#pragma mark - Custom Proeprties

@property (nonatomic, readwrite, assign) NSInteger currentMonthIndex;
@property (nonatomic, readwrite, assign) NSInteger _year;

#pragma mark - Private Protocol Definition

- (UILabel *)createEnabledLabel;
- (UILabel *)createDisabledLabel;
- (BOOL)canSelectMonthWithIndex:(NSUInteger)index;

@end

#pragma mark - ATGDatePicker Implementation
#pragma mark -

@implementation ATGDatePicker

@synthesize year, month, mDelegate;
@synthesize currentMonthIndex;

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    self.dataSource = self;
    self.delegate = self;

    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
      [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    [self set_year:[weekdayComponents year]];
    // Date components return 1 for January, so we have to subtract one.
    [self setCurrentMonthIndex:[weekdayComponents month] - 1];
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    self.dataSource = self;
    self.delegate = self;

    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
      [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
    [self set_year:[weekdayComponents year]];
    [self setCurrentMonthIndex:[weekdayComponents month] - 1];
  }
  return self;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pPickerView {
  return 2;
}

- (UIView *)pickerView:(UIPickerView *)pPickerView
            viewForRow:(NSInteger)pRow
          forComponent:(NSInteger)pComponent
           reusingView:(UIView *)pView {
  if (pComponent == 0) {
    // Check, if month presented by the row can be selected (i.e. located in future).
    // If this is the case, return enabled-styled labels, otherwise return disabled label.
    UILabel *result = [self canSelectMonthWithIndex:pRow] ?
        [self createEnabledLabel] : [self createDisabledLabel];
    [result setText:[[[ATGDataFormatters dateFormatter] monthSymbols] objectAtIndex:pRow]];
    return result;
  } else if (pComponent == 1) {
    // Every year can be selected, as all years are located in future by design.
    UILabel *result = [self createEnabledLabel];
    [result setText:[NSString stringWithFormat:@"%i", [self _year] + pRow]];
    return result;
  }
  return nil;
}

- (NSInteger) pickerView:(UIPickerView *)pPickerView numberOfRowsInComponent:(NSInteger)pComponent {
  if (pComponent == 0) {
    return 12;
  }
  return 30;
}

- (void) pickerView:(UIPickerView *)pPickerView didSelectRow:(NSInteger)pRow inComponent:(NSInteger)pComponent {
  if (pComponent == 0) {
    // Check, if selected month is allowed to be selected.
    if (![self canSelectMonthWithIndex:pRow]) {
      // If this is not the case, then iterate to next month until appropriate month is found.
      // We'll find valid month for sure, as at least December is always valid.
      [self selectRow:pRow + 1 inComponent:pComponent animated:YES];
      [self pickerView:pPickerView didSelectRow:pRow + 1 inComponent:pComponent];
      return;
    }
    
    self.month = [[[ATGDataFormatters dateFormatter] monthSymbols] objectAtIndex:pRow];
    NSInteger yIndex = [self selectedRowInComponent:1];
    self.year = [NSString stringWithFormat:@"%i", [self _year] + yIndex];
  }

  if (pComponent == 1) {
    // We've changed the year, so there might be some changes in month column outfit.
    // That's why we have to reload this component.
    [self reloadComponent:0];
    // Emulate user event to check, if previously selected month is valid for selection
    // with regard to the newly selected year.
    [self pickerView:pPickerView didSelectRow:[self selectedRowInComponent:0] inComponent:0];
    self.year = [NSString stringWithFormat:@"%i", [self _year] + pRow];
    NSInteger mIndex = [self selectedRowInComponent:0];
    self.month = [[[ATGDataFormatters dateFormatter] monthSymbols] objectAtIndex:mIndex];
  }
  if ( (self.month != nil) && (self.year != nil) ) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM / yyyy"];
    NSDate *newDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ / %@", month, year]];
    
    if ([self.mDelegate respondsToSelector:@selector(didSelectDate:)]) {
      [self.mDelegate didSelectDate:newDate];
    }
  }
}

- (CGFloat)pickerView:(UIPickerView *)pPickerView widthForComponent:(NSInteger)pComponent {
  return (pComponent == 0 ? 2 : 1) * [pPickerView bounds].size.width / 3;
}

- (void) setDate:(NSDate *)pDate {
  //calculate index of month in date picker. select this month
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"MMMM"];
  NSString *selectedMonth = [formatter stringFromDate:pDate];
  NSUInteger index = [[[ATGDataFormatters dateFormatter] monthSymbols] indexOfObject:selectedMonth];
  self.month = selectedMonth;
  [self selectRow:index inComponent:0 animated:YES];

  //calculate index of year in date picker and select it.
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [formatter setDateFormat:@"yyyy"];
  NSNumber *selectedYear = [numberFormatter numberFromString:[formatter stringFromDate:pDate]];
  self.year = [formatter stringFromDate:pDate];
  index = [selectedYear integerValue] - [self _year];
  [self selectRow:index inComponent:1 animated:YES];
  [self pickerView:self didSelectRow:index inComponent:1];
}

#pragma mark - Private Protocol Implementation

- (UILabel *)createEnabledLabel {
  ATGBorderedLabel *result = [[ATGBorderedLabel alloc] initWithFrame:CGRectZero];
  [result setBorderWidth:10];
  [result setTextColor:[UIColor blackColor]];
  [result setBackgroundColor:[UIColor clearColor]];
  [result setFont:[UIFont boldSystemFontOfSize:17]];
  return result;
}

- (UILabel *)createDisabledLabel {
  UILabel *result = [self createEnabledLabel];
  [result setTextColor:[UIColor darkGrayColor]];
  return result;
}

- (BOOL)canSelectMonthWithIndex:(NSUInteger)pIndex {
  if ([self selectedRowInComponent:1] > 0) {
    // Selected year is not current, hence all months can be selected.
    return YES;
  } else {
    // For the current year only previous months are not allowed to be selected.
    // All other months are valid.
    return pIndex >= [self currentMonthIndex];
  }
}

@end

#pragma mark - ATGBorderedLabel Implementation
#pragma mark -

@implementation ATGBorderedLabel

@synthesize borderWidth;

- (void)drawTextInRect:(CGRect)pRect {
  pRect = CGRectMake([self borderWidth], [self borderWidth],
                     pRect.size.width - 2 * [self borderWidth], pRect.size.height - 2 * [self borderWidth]);
  [super drawTextInRect:pRect];
}

@end
