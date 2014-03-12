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

#import "ATGReturnSummaryTableViewCell.h"
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGCreditCard.h>
#import <ATGMobileCommon/NSObject+ATGRestAdditions.h>

typedef enum {
  ATGReturnSummaryTableViewCellStringValueHeaderText,
  ATGReturnSummaryTableViewCellStringValueHeaderHeight,
  ATGReturnSummaryTableViewCellStringValueRowHeight,
  ATGReturnSummaryTableViewCellStringValueRowCount,
  ATGReturnSummaryTableViewCellStringValueCaption,
  ATGReturnSummaryTableViewCellStringValueDetail
} ATGReturnSummaryTableViewCellStringValue;

@interface ATGReturnSummaryTableViewCell () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView *summaryTableView;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) UILabel *promoLabel;
@property (nonatomic, strong) ATGReturnRequest *returnRequest;
@property (nonatomic, assign) NSInteger appyToSection;
@property (nonatomic, assign) NSInteger refundSummarySection;
@end

@implementation ATGReturnSummaryTableViewCell

// Sets self.returnRequest to pReturnRequest.  Additionally, removes
// refundMethod objects from returnRequest.refundMethodList of refundMethod.amount <= 0
- (void)setReturnRequest:(ATGReturnRequest *)pReturnRequest {
  _returnRequest = pReturnRequest;
  if (_returnRequest.refundMethodList){
    _returnRequest.refundMethodList = [ATGReturnSummaryTableViewCell filteredArrayFromRefurnMethodList:_returnRequest.refundMethodList];
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    UITableView *summaryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    summaryTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    summaryTableView.dataSource = self;
    summaryTableView.delegate = self;
    summaryTableView.scrollEnabled = NO;
    [self.contentView addSubview:summaryTableView];
    self.summaryTableView = summaryTableView;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.numberFormatter = formatter;
        
    UILabel *promoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [promoLabel applyStyleWithName:@"formTextLabel"];
    self.promoLabel = promoLabel;
    self.appyToSection = 0;
    self.refundSummarySection = -1;
  }
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.refundSummarySection + (self.returnRequest.promotionDisplayNameValueAdjustments || fabs([self.returnRequest.nonReturnItemSubtotalAdjustment floatValue]) > 0 ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == self.refundSummarySection) {
    return 5;
  } else if (section == self.refundSummarySection + 1) {
    int count = 1; //This is adjustments section, so far only pricing
    if (fabs([self.returnRequest.nonReturnItemSubtotalAdjustment floatValue]) > 0) {
      count += 1; //Add 1 more for nonReturnItemSubtotalAdjustment
    }
    if (self.returnRequest.promotionDisplayNameValueAdjustments) {
      count += 1; //Add 1 more for promotionDisplayNameValueAdjustments
    }
    return count;
  } else {
    return 2;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == self.appyToSection) {
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundAppliedSection.Header", nil, [NSBundle mainBundle], @"Apply Refund To", @"Header which explains what the refund was applied to");
  } else if (section == self.refundSummarySection) {
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.Header", nil, [NSBundle mainBundle], @"Refund Summary", @"Header which explains the refund summary");
  } else {
    return @"";
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return (section == self.refundSummarySection || section == self.appyToSection ? 40.0 : 1.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return (section == 4 ? 30.0 : 1.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ((indexPath.section == self.refundSummarySection + 1 && (indexPath.row == 2 || (indexPath.row == 1 && self.returnRequest.promotionDisplayNameValueAdjustments && [self.returnRequest.nonReturnItemSubtotalAdjustment floatValue] == 0)))) {
    return 60.0 + self.returnRequest.promotionDisplayNameValueAdjustments.count * 20.0;
  } else if (indexPath.section >= self.refundSummarySection || indexPath.row < 1) {
    return 44.0;
  }
  NSDictionary *dictionary = [self.returnRequest.refundMethodList objectAtIndex:indexPath.section];
  NSObject *valueForCreditCard = [dictionary valueForKey:@"creditCard"];
  return (valueForCreditCard && valueForCreditCard != [NSNull null]) ? 120.0 : 44.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if ((indexPath.section < self.refundSummarySection || (indexPath.section == self.refundSummarySection + 1)) && indexPath.row > 0) {
    cell = [tableView dequeueReusableCellWithIdentifier:@"SmallText"];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SmallText"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  }
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
  }
  cell.textLabel.text = [self stringValueFor:ATGReturnSummaryTableViewCellStringValueCaption inSection:indexPath.section row:indexPath.row];
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.detailTextLabel.text = [self stringValueFor:ATGReturnSummaryTableViewCellStringValueDetail inSection:indexPath.section row:indexPath.row];
  return cell;
}

- (void)setObject:(id)object {
  self.returnRequest = (ATGReturnRequest *)object;
  self.refundSummarySection = self.appyToSection + self.returnRequest.refundMethodList.count;
  [self.summaryTableView reloadData];
}

- (NSString *)applyToDetailTextForIndex:(NSInteger)index {
  NSDictionary *dictionary = [self.returnRequest.refundMethodList objectAtIndex:index];
  return [self.numberFormatter stringFromNumber:[dictionary valueForKey:@"amount"]];
}

- (NSString *)applyToTextForIndex:(NSInteger)index {
  NSDictionary *dictionary = [self.returnRequest.refundMethodList objectAtIndex:index];
  NSObject *valueForCreditCard = [dictionary valueForKey:@"creditCard"];
  if (valueForCreditCard && valueForCreditCard != [NSNull null]) {
    return NSLocalizedStringWithDefaultValue(@"ATGRefundSummaryTableViewCell.CreditCardSection.Title", nil, [NSBundle mainBundle], @"Credit Card", @"Credit Card Caption");
  } else {
    return NSLocalizedStringWithDefaultValue(@"ATGRefundSummaryTableViewCell.StoreCreditSection.Title", nil, [NSBundle mainBundle], @"Store Credit", @"Store Credit Caption");
  }
}

- (NSString *)applyToSecondaryTextForIndex:(NSInteger)index {
  NSDictionary *dictionary = [self.returnRequest.refundMethodList objectAtIndex:index];
  NSObject*obj = self.returnRequest.refundMethodList;
  NSObject *valueForCreditCard = [dictionary valueForKey:@"creditCard"];
  if (valueForCreditCard && valueForCreditCard != [NSNull null]) {
    return [(ATGCreditCard *)[ATGCreditCard objectFromDictionary:[dictionary valueForKey:@"creditCard"]] multiLineDescription];
  } else {
    return NSLocalizedStringWithDefaultValue(@"ATGRefundSummaryTableViewCell.StoreCreditSection.Note", nil, [NSBundle mainBundle], @"Applied to your next purchase", @"Store credit applied to note");
  }
}

- (NSString *)refundSummaryDetailTextForIndex:(NSInteger)index {
  if (index == 0)
    return [self.numberFormatter stringFromNumber:self.returnRequest.totalReturnItemRefund];
  else if (index == 1) {
    [self.numberFormatter setNegativeFormat:[@"- " stringByAppendingString:[self.numberFormatter positiveFormat]]];
    return [self.numberFormatter stringFromNumber:self.returnRequest.nonReturnItemSubtotalAdjustment];
  } else if (index == 2)
    return [self.numberFormatter stringFromNumber:self.returnRequest.actualShippingRefund];
  else if (index == 3)
    return [self.numberFormatter stringFromNumber:self.returnRequest.actualTaxRefund];
  else
    return [self.numberFormatter stringFromNumber:self.returnRequest.totalRefundAmount];
}

- (NSString *)refundSummaryTextForIndex:(NSInteger)index {
  if (index == 0)
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.RefundOfItems", nil, [NSBundle mainBundle], @"Refund of Items", @"Refund of Items cost caption");
  else if (index == 1)
    return [NSString stringWithFormat:@"%@%@", NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.Adjustments", nil, [NSBundle mainBundle], @"Adjustments", @"Refund Adjustments caption"), (fabs([self.returnRequest.nonReturnItemSubtotalAdjustment floatValue]) > 0.0 ? @"*" : @"")];
  else if (index == 2)
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.RefundOfShipping", nil, [NSBundle mainBundle], @"Refund of Shipping", @"Refund of Shipping cost caption");
  else if (index == 3)
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.RefundOfTaxes", nil, [NSBundle mainBundle], @"Refund of Taxes", @"Refund of Taxes cost caption");
  else
    return NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.RefundSummarySection.TotalRefund", nil, [NSBundle mainBundle], @"Total Refund", @"Total Refund value caption");
}

- (NSString *)adjustmentTextForIndex:(NSInteger)index {
  if (index == 0) {
    return [NSString stringWithFormat:@"*%@", NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.Adjustments", nil, [NSBundle  mainBundle], @"Pricing & Promotion Adjustments", @"Title for adjustments area in refund summary")];
  } else if ((index == 1 && fabs([self.returnRequest.nonReturnItemSubtotalAdjustment floatValue]) > 0) || !self.returnRequest.promotionDisplayNameValueAdjustments) {
    NSString *adjustments = NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.Adjustments.Default", nil, [NSBundle  mainBundle], @"The pricing of items remaining on the order has changed as a result of this return", @"Default Adjustments Detail Text"); 
    return adjustments;
  } else {
    NSString *adjustments = [NSString stringWithFormat:@"%@", NSLocalizedStringWithDefaultValue(@"ATGReturnSummaryTableViewCell.Adjustments.PromoAdjustments", nil, [NSBundle mainBundle], @"The following promotion(s) have either been lost or resulted in a change in value due to this return:", @"Explanation of what the promo adjustments are")];
    for (int i =0; i < [self.returnRequest.promotionDisplayNameValueAdjustments allKeys].count; i++) {
      NSString *key = [[self.returnRequest.promotionDisplayNameValueAdjustments allKeys] objectAtIndex:i];
      adjustments = [NSString stringWithFormat:@"%@%@", (adjustments.length > 0 ? [NSString stringWithFormat:@"%@\n", adjustments] : @""), key];
    }
    return adjustments;
  }
}

- (NSString *)stringValueFor:(ATGReturnSummaryTableViewCellStringValue)stringValue inSection:(NSInteger)section row:(NSInteger)row {
  if (section < self.refundSummarySection) {
    if (stringValue == ATGReturnSummaryTableViewCellStringValueCaption) {
      if (row == 0)
        return [self applyToTextForIndex:section];
      else
        return [self applyToSecondaryTextForIndex:section];
    }
    else {
      if (row == 0) 
        return [self applyToDetailTextForIndex:section];
      else
        return @"";
    }
  } else if (section == self.refundSummarySection) {
    if (stringValue == ATGReturnSummaryTableViewCellStringValueCaption)
      return [self refundSummaryTextForIndex:row];
    else
      return [self refundSummaryDetailTextForIndex:row];
  } else if (section == self.refundSummarySection + 1) {
    if (stringValue == ATGReturnSummaryTableViewCellStringValueCaption)
      return [self adjustmentTextForIndex:row];
    else
      return @"";
  } else
    return @"";
}



+ (CGFloat)heightForReturnSummaryWithReturnRequest:(ATGReturnRequest *)retReq {
  CGFloat height = 310.0; //The refund summary, and order summary are always present and 250 px each. There are 3 headers of 30px each.

  // loop through return methods that will be displayed (which is why we call the filteredArrayFromRefurnMethodList)
  for (NSDictionary *returnMethod in [ATGReturnSummaryTableViewCell filteredArrayFromRefurnMethodList:retReq.refundMethodList]) {
    NSObject *valueForCreditCard = [returnMethod valueForKey:@"creditCard"];
    if (valueForCreditCard && valueForCreditCard != [NSNull null]) {
      height += 175;
    } else {
      height += 100;
    }
  }
  
  //We only show the adjustments if they exists
  if (retReq.promotionDisplayNameValueAdjustments) {
    height += 140 + retReq.promotionDisplayNameValueAdjustments.count * 20.0;
  } else if (fabs([retReq.nonReturnItemSubtotalAdjustment floatValue]) > 0.0) {
    height += 88;
  }
  
  return height;
}

// returns a new list with refundMethods that have objects with amount <= 0 removed
// essentially removes useless refundMethod.
+ (NSArray *)filteredArrayFromRefurnMethodList:(NSArray *)pReturnMethodList {
  NSMutableArray *filteredReturnMethodList = [[NSMutableArray alloc] init];
  for (int i = 0; i < pReturnMethodList.count; i ++){
    NSObject *returnMethod = [pReturnMethodList objectAtIndex:i];
    NSString *amountString = [returnMethod valueForKey:@"amount"];
    double amount = [amountString doubleValue];

    if (amount > 0){
      [filteredReturnMethodList addObject:returnMethod];
    }
  }
  return filteredReturnMethodList;
}

@end
