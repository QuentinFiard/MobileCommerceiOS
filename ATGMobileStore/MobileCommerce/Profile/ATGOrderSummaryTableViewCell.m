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

#import "ATGOrderSummaryTableViewCell.h"
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGPricingAdjustment.h>

typedef enum {
  ATGOrderSummaryTableViewCellSectionRows = 0,
  ATGOrderSummaryTableViewCellSectionSupplementaryInformation = 1
} ATGOrderSummaryTableViewCellSection;

@interface ATGOrderSummaryTableViewCell() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView *summaryTableView;
@property (nonatomic, strong) ATGOrder *order;

@property (nonatomic, assign) NSInteger subtotalIndex;
@property (nonatomic, assign) NSInteger discountIndex;
@property (nonatomic, assign) NSInteger shippingIndex;
@property (nonatomic, assign) NSInteger taxIndex;
@property (nonatomic, assign) NSInteger totalIndex;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) UILabel *paymentCaptionLabel;

@property (nonatomic, strong) UILabel *billToCaptionLabel;
@property (nonatomic, strong) UILabel *billToLabel;

@property (nonatomic, strong) UILabel *promoLabel;

@end

@implementation ATGOrderSummaryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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
      
      UILabel *billToCaptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      [billToCaptionLabel applyStyleWithName:@"formTitleLabel"];
      self.billToCaptionLabel = billToCaptionLabel;
      
      UILabel *billToLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      [billToLabel applyStyleWithName:@"formTextLabel"];
      self.billToLabel = billToLabel;
      
      UILabel *paymentCaptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      [paymentCaptionLabel applyStyleWithName:@"formTitleLabel"];
      self.paymentCaptionLabel = paymentCaptionLabel;

      UILabel *promoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      [promoLabel applyStyleWithName:@"formTextLabel"];
      self.promoLabel = promoLabel;
      
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
  headerView.backgroundColor = [UIColor clearColor];
  
  if (section == ATGOrderSummaryTableViewCellSectionSupplementaryInformation) {
    self.promoLabel.frame = CGRectMake(14, 0, 292, 15 * self.order.priceInfo.adjustments.count);
    self.promoLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:self.promoLabel];
    if (self.order.creditCard || ([self.order.storeCreditsAppliedTotal stringValue].length > 0 && [self.order.storeCreditsAppliedTotal floatValue] > 0)) {
      self.paymentCaptionLabel.frame = CGRectMake(self.promoLabel.left, self.promoLabel.bottom + 5.0, self.promoLabel.width, 14);
      self.paymentCaptionLabel.backgroundColor = [UIColor clearColor];
      self.paymentCaptionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.PaymentCaptionLabel", nil, [NSBundle mainBundle], @"Payment", @"Payment caption, as seen on the order details page above the payment type");
      [headerView addSubview:self.paymentCaptionLabel];
    }
    return headerView;
  }
  UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 5, 292, 40)];
  headerLabel.backgroundColor = [UIColor clearColor];
  [headerLabel applyStyleWithName:@"formTitleLabel"];
  headerLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Title", nil, [NSBundle mainBundle], @"Order Summary", @"Order summary section title, as seen on the order details page");
  [headerView addSubview:headerLabel];
  return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == ATGOrderSummaryTableViewCellSectionRows) {
    return 40.0;
  } else {
    return 25 + self.order.priceInfo.adjustments.count * 15.0;
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.order && section == ATGOrderSummaryTableViewCellSectionRows) {
    NSInteger index = 0;
    if ([self.order.priceInfo.rawSubtotal stringValue].length > 0) {
      self.subtotalIndex = index;
      index += 1;
    }
    if ([self.order.priceInfo.discountAmount stringValue].length > 0) {
      self.discountIndex = index;
      index += 1;
    }
    if ([self.order.priceInfo.shipping stringValue].length > 0) {
      self.shippingIndex = index;
      index += 1;
    }
    if ([self.order.priceInfo.tax stringValue].length > 0) {
      self.taxIndex = index;
      index += 1;
    }
    if ([self.order.priceInfo.total stringValue].length > 0) {
      self.totalIndex = index;
      index += 1;
    }
    return index;
  }
  if (self.order.creditCard || ([self.order.storeCreditsAppliedTotal stringValue].length > 0 && [self.order.storeCreditsAppliedTotal floatValue] > 0)) {
    int count = self.order.creditCard ? 1 : 0;
    count += ([self.order.storeCreditsAppliedTotal stringValue].length > 0 && [self.order.storeCreditsAppliedTotal floatValue] > 0) ? 1 : 0;
    return count;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ATGOrderSummaryTableViewCellSectionRows || (indexPath.section != ATGOrderSummaryTableViewCellSectionRows  && ((self.order.creditCard && indexPath.row > 0) || !self.order.creditCard) )) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewCell"];
    }
    cell.textLabel.text = [self cellTextForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self cellDetailTextForRowAtIndexPath:indexPath];
    return cell;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCell"];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PaymentCell"];
    }
    cell.textLabel.numberOfLines = 0;
    ATGCreditCard *card = self.order.creditCard;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[card multiLineDescription]];
    NSRange range = [[attributedString string] rangeOfString:@"\n"];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:NSMakeRange(0, range.location)];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(range.location, attributedString.length - range.location)];
    cell.textLabel.attributedText = attributedString;
    cell.detailTextLabel.text = card.formattedAmount;
    return cell;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ATGOrderSummaryTableViewCellSectionSupplementaryInformation && self.order.creditCard && indexPath.row == 0) {
    return 180;
  }
  return tableView.rowHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)setObject:(id)object {
  self.order = (ATGOrder *)object;
  [self.summaryTableView reloadData];
  
  NSString *promos = @"";
 
  for (ATGPricingAdjustment *adjustment in self.order.priceInfo.adjustments) {
    promos = [NSString stringWithFormat:@"%@", (promos.length > 0 ? [NSString stringWithFormat:@"%@, %@", promos, adjustment.pricingModel] : [NSString stringWithFormat:@"*%@", adjustment.pricingModel])];
  }
  self.promoLabel.text = promos;

  NSString *result = [NSString stringWithFormat:@"%@ %@\n%@", [self.order.creditCard.billingAddress firstName], [self.order.creditCard.billingAddress lastName], [self.order.creditCard.billingAddress address1]];
  if ([[self.order.creditCard.billingAddress address2] length]) {
    result = [NSString stringWithFormat:@"%@\n%@", result, [self.order.creditCard.billingAddress address2]];
  }
  result = [NSString stringWithFormat:@"%@\n%@, %@ %@\n%@\n%@", result, [self.order.creditCard.billingAddress city],
            [self.order.creditCard.billingAddress state], [self.order.creditCard.billingAddress postalCode], [self.order.creditCard.billingAddress country],
            [self.order.creditCard.billingAddress phoneNumber]];
   self.billToLabel.text = [NSString stringWithFormat:@"%@", result];
}

- (NSString *)cellTextForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != ATGOrderSummaryTableViewCellSectionRows) {
    return NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.StoreCredit", nil, [NSBundle mainBundle], @"Store credit", @"Text that describes the value in the the store credit cell");
  } else if (indexPath.row == self.subtotalIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Subtitle", nil, [NSBundle mainBundle], @"Subtotal", @"Text that describes the value in the the subtotal cell");
  } else if (indexPath.row == self.discountIndex) {
    NSString *discount = NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Discount", nil, [NSBundle mainBundle], @"Discount", @"Text that describes the value in the the discount cell");
    if (self.order.priceInfo.adjustments.count > 0 && [discount rangeOfString:@"*"].length == 0) {
      discount = [NSString stringWithFormat:@"%@*", discount];
    }
    return discount;
  } else if (indexPath.row == self.shippingIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Shipping", nil, [NSBundle mainBundle], @"Shipping", @"Text that describes the value in the the shipping cell");
  } else if (indexPath.row == self.taxIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Tax", nil, [NSBundle mainBundle], @"Tax", @"Text that describes the value in the the tax cell");
  } else if (indexPath.row == self.totalIndex) {
    return NSLocalizedStringWithDefaultValue(@"ATGOrderSummaryTableViewCell.OrderSummary.Total", nil, [NSBundle mainBundle], @"Total", @"Text that describes the value in the the total cell");
  } else {
    return @"";
  }
}

- (NSString *)cellDetailTextForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != ATGOrderSummaryTableViewCellSectionRows) {
    return [NSString stringWithFormat:@"%@", [self.numberFormatter stringFromNumber:self.order.storeCreditsAppliedTotal]];
  } else if (indexPath.row == self.subtotalIndex) {
    return [self.numberFormatter stringFromNumber:self.order.priceInfo.rawSubtotal];
  } else if (indexPath.row == self.discountIndex) {
    return [NSString stringWithFormat:@"%@%@", ([self.order.priceInfo.discountAmount floatValue] > 0.0 ? @"-" : @""), [self.numberFormatter stringFromNumber:self.order.priceInfo.discountAmount]];
  } else if (indexPath.row == self.shippingIndex) {
    return [self.numberFormatter stringFromNumber:self.order.priceInfo.shipping];
  } else if (indexPath.row == self.taxIndex) {
    return [self.numberFormatter stringFromNumber:self.order.priceInfo.tax];
  } else if (indexPath.row == self.totalIndex) {
    return [self.numberFormatter stringFromNumber:self.order.priceInfo.total];
  } else {
    return @"";
  }
}

+ (CGFloat)heightForOrder:(ATGOrder *)pOrder {

  CGFloat height = 0.0;
  height += 50.0; //This is the top of the table, including the header text
  
  NSInteger index = 0;
  if ([pOrder.priceInfo.rawSubtotal stringValue].length > 0) {
    index += 1;
  }
  if ([pOrder.priceInfo.discountAmount stringValue].length > 0) {
    index += 1;
  }
  if ([pOrder.priceInfo.shipping stringValue].length > 0) {
    index += 1;
  }
  if ([pOrder.priceInfo.tax stringValue].length > 0) {
    index += 1;
  }
  if ([pOrder.priceInfo.total stringValue].length > 0) {
    index += 1;
  }
  height += index * 44.0;
  height += 15.0 * pOrder.priceInfo.adjustments.count;
  height += (pOrder.creditCard || ([pOrder.storeCreditsAppliedTotal stringValue].length > 0 && [pOrder.storeCreditsAppliedTotal floatValue] > 0) ? 40.0 : 0.0);
  height += (pOrder.creditCard ? 180.0 : 0.0);
  height += (([pOrder.storeCreditsAppliedTotal stringValue].length > 0 && [pOrder.storeCreditsAppliedTotal floatValue] > 0) ? 44.0 : 0.0);
  height += 10.0; //Bottom Padding
  
  return height;
}

@end
