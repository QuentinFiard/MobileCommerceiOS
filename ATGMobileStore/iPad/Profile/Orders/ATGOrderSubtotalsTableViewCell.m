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

#import "ATGOrderSubtotalsTableViewCell.h"

#pragma mark - ATGOrderSubtotalsTableViewCell Private Protocol Definition
#pragma mark -

@interface ATGOrderSubtotalsTableViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *subtotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *shippingLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *discountsLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *taxLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *subtotalCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *shippingCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *discountsCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *taxCaptionLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;

@end

#pragma mark - ATGOrderSubtotalsTableViewCell Implementation
#pragma mark -

@implementation ATGOrderSubtotalsTableViewCell

#pragma mark - Custom Properties

- (void) setCurrencyCode:(NSString *)pCurrencyCode {
  [[self priceFormatter] setCurrencyCode:pCurrencyCode];
  [self setNeedsLayout];
}

- (NSString *) currencyCode {
  return [[self priceFormatter] currencyCode];
}

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setNegativeFormat:[[formatter minusSign] stringByAppendingString:[formatter positiveFormat]]];
  [formatter setLocale:[NSLocale currentLocale]];
  [self setPriceFormatter:formatter];

  NSString *caption = NSLocalizedStringWithDefaultValue
                        (@"ATGOrderSubtotalsTableViewCell.SubtotalCaption",
                         nil, [NSBundle mainBundle], @"Items:",
                        @"Caption to be displayed next to order subtotal value on the order details screen.");
  [[self subtotalCaptionLabel] setText:caption];
  caption = NSLocalizedStringWithDefaultValue
              (@"ATGOrderSubtotalTableViewCell.ShippingCaption",
               nil, [NSBundle mainBundle], @"Shipping:",
              @"Caption to be displayed next to order shipping value on the order details screen.");
  [[self shippingCaptionLabel] setText:caption];
  caption = NSLocalizedStringWithDefaultValue
              (@"ATGOrderSubtotalTableViewCell.DiscountsCaption",
               nil, [NSBundle mainBundle], @"Discounts:",
              @"Caption to be displayed next to order discounts value on the order details screen.");
  [[self discountsCaptionLabel] setText:caption];
  caption = NSLocalizedStringWithDefaultValue
              (@"ATGOrderSubtotalTableViewCell.TaxCaption",
               nil, [NSBundle mainBundle], @"Tax:",
              @"Caption to be displayed next to the tax total value on the order details screen.");
  [[self taxCaptionLabel] setText:caption];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  [[self subtotalLabel] setText:[[self priceFormatter] stringFromNumber:[self subtotal]]];
  [[self shippingLabel] setText:[[self priceFormatter] stringFromNumber:[self shipping]]];
  if ([[self discounts] floatValue] > 0) {
    NSDecimalNumber *discounts = [NSDecimalNumber decimalNumberWithDecimal:[[self discounts] decimalValue]];
    NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
    discounts = [discounts decimalNumberByMultiplyingBy:minusOne];
    [[self discountsLabel] setText:[[self priceFormatter] stringFromNumber:discounts]];
  } else {
    [[self discountsLabel] setText:@"—"];
  }
  [[self taxLabel] setText:[[self priceFormatter] stringFromNumber:[self tax]]];
}

@end