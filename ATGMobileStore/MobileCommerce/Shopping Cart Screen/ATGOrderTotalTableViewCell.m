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

#import "ATGOrderTotalTableViewCell.h"
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGMobileClient/ATGPricingAdjustment.h>

static const CGFloat ATGInputFontSize = 12;
static const CGFloat ATGErrorLabelFontSize = 11;
static const CGFloat ATGCouponInsets = 2;
static NSString *const ATGPromotionNameKey = @"promotion";

#pragma mark - ATGOrderTotalTableViewCell Private Protocol
#pragma mark -

@interface ATGOrderTotalTableViewCell () <UITextFieldDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *itemsTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *discountTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *storeCreditsTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *shippingTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *taxTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *orderTotalLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *discountImage;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *discountDescriptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *couponCodeInput;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;

@end

#pragma mark - ATGOrderTotalTableViewCell Implementation
#pragma mark -

@implementation ATGOrderTotalTableViewCell

#pragma mark - Properties

@synthesize itemsTotal, discountTotal, storeCreditsTotal, shippingTotal,
    taxTotal, orderTotal, currencyCode, orderEmpty, discounts, delegate,
    couponError, couponHidden, couponCode;
@synthesize itemsTotalLabel;
@synthesize discountTotalLabel;
@synthesize storeCreditsTotalLabel;
@synthesize shippingTotalLabel;
@synthesize taxTotalLabel;
@synthesize orderTotalLabel;
@synthesize discountImage;
@synthesize discountDescriptionLabel;
@synthesize couponCodeInput;

#pragma mark - NSObject


- (void)awakeFromNib {
  // Do some additional styling not available in the IB.
  // Update all labels with localized content and proper color.
  NSString *prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.ItemsTotalCaption", nil, [NSBundle mainBundle],
       @"Items:", @"Caption to be displayed next to items total amount.");
  [[self itemsTotalLabel] setPrefix:prefix];
  [[self itemsTotalLabel] applyStyleWithName:@"generalTextLabel"];
  prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.DiscountTotalCaption", nil, [NSBundle mainBundle],
       @"Discount:", @"Caption to be displayed next to discount total amount.");
  [[self discountTotalLabel] setPrefix:prefix];
  [[self discountTotalLabel] applyStyleWithName:@"generalTextLabel"];
  prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.StoreCreditsTotalCaption", nil, [NSBundle mainBundle],
       @"Store Credit:", @"Caption to be displayed next to store credits total amount.");
  [[self storeCreditsTotalLabel] setPrefix:prefix];
  [[self storeCreditsTotalLabel] applyStyleWithName:@"generalTextLabel"];
  prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.ShippingTotalCaption", nil, [NSBundle mainBundle],
       @"Shipping:", @"Caption to be displayed next to shipping total amount.");
  [[self shippingTotalLabel] setPrefix:prefix];
  [[self shippingTotalLabel] applyStyleWithName:@"generalTextLabel"];
  prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.TaxTotalCaption", nil, [NSBundle mainBundle],
       @"Tax:", @"Caption to be displayed next to tax total amount.");
  [[self taxTotalLabel] setPrefix:prefix];
  [[self taxTotalLabel] applyStyleWithName:@"generalTextLabel"];
  prefix = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.OrderTotalCaption", nil, [NSBundle mainBundle],
       @"Total:", @"Caption to be displayed next to order total amount.");
  [[self orderTotalLabel] setPrefix:prefix];
  [[self orderTotalLabel] applyStyleWithName:@"priceLabel"];

  // Construct a number formatter to be used when displaying prices.
  [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
  [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
  // We will use special syntax for negative amounts. It will be something like '-$10'.
  [[self priceFormatter] setNegativeFormat:[[[self priceFormatter] minusSign]
                                            stringByAppendingString:[[self priceFormatter] positiveFormat]]];
  [[self priceFormatter] setLocale:[NSLocale currentLocale]];

  // Update coupon input field with styling and localized content.
  NSString *couponPlaceholder = NSLocalizedStringWithDefaultValue
      (@"ATGOrderTotalTableViewCell.CouponPlaceholder", nil, [NSBundle mainBundle],
       @"Coupon Code", @"Placeholder to be displayed in the coupon code input field.");
  [[self couponCodeInput] setPlaceholder:couponPlaceholder];
  [[self couponCodeInput] setDelegate:self];
  [[self couponCodeInput] setReturnKeyType:UIReturnKeyGo];
  [[self couponCodeInput] setBorderWidth:ATGCouponInsets];
  [[[self couponCodeInput] layer] setCornerRadius:[[self couponCodeInput] bounds].size.height / 2];
  [[[self couponCodeInput] layer] setBorderColor:[[UIColor borderColor] CGColor]];
  [[[self couponCodeInput] layer] setBorderWidth:1];
  // Do not validate input coupon code.
  [[self couponCodeInput] removeAllValidators];
  // Force an input layout. We need its input view actual size.
  [[self couponCodeInput] layoutIfNeeded];
  [[self couponCodeInput] setTextAlignment:NSTextAlignmentCenter];
  [[self couponCodeInput] setAutocorrectionType:UITextAutocorrectionTypeNo];
  // And receive input in an upper case.
  [[self couponCodeInput] setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
  [[self couponCodeInput] applyStyle:ATGTextFieldFormText];

  [self.discountDescriptionLabel applyStyleWithName:@"formTextLabel"];
  
  ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:nil];
  [[self couponCodeInput] setInputAccessoryView:toolbar];
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  void (^layoutViews)(UIView *, UIView*) = ^(UIView *pTarget, UIView *pAnchor) {
    CGRect targetFrame = [pTarget frame];
    CGRect anchorFrame = [pAnchor frame];
    targetFrame.origin.y = CGRectGetMaxY(anchorFrame);
    [pTarget setFrame:targetFrame];
  };
  
  layoutViews([self discountTotalLabel], [self itemsTotalLabel]);
  layoutViews([self storeCreditsTotalLabel], [self discountTotalLabel]);
  layoutViews([self shippingTotalLabel], [self storeCreditsTotalLabel]);
  layoutViews([self taxTotalLabel], [self shippingTotalLabel]);
  [[self storeCreditsTotalLabel] setHidden:NO];
  [[self discountTotalLabel] setHidden:NO];

  // Use proper locale when displaying prices.
  [[self priceFormatter] setCurrencyCode:[self currencyCode]];

  // Update all price amounts. Hide unnecessary labels, if order is empty.
  [[self itemsTotalLabel] setText:[[self priceFormatter] stringFromNumber:[self itemsTotal]]];
  [[self itemsTotalLabel] setHidden:[self isOrderEmpty]];
  if ([[NSDecimalNumber zero] compare:[self discountTotal]] == NSOrderedAscending) {
    self.discountTotal = [NSDecimalNumber numberWithFloat:[self.discountTotal floatValue] * -1.0 ];
  }
  [[self discountTotalLabel] setText:[[self priceFormatter] stringFromNumber:[self discountTotal]]];
  [[self discountTotalLabel] setHidden:[self isOrderEmpty]];
  if (![self storeCreditsTotal]) {
    [self setStoreCreditsTotal:[[NSDecimalNumber alloc] initWithInteger:0]];
  }
  // Important note. SB JSON library sometimes parses decimal values to be NSNumber instances
  // instead of NSDecimalNumber. Because of that price-related properties of this class
  // can contain instances of wrong type. That's it's important to create NSDecimalNumber values
  // for further usage instead of using current property values.
  NSDecimalNumber *storeCreditsToDisplay = nil;
  if ([[self orderTotal] compare:[self storeCreditsTotal]] == NSOrderedDescending) {
    storeCreditsToDisplay = [NSDecimalNumber
                             decimalNumberWithDecimal:[[self storeCreditsTotal] decimalValue]];
  } else {
    storeCreditsToDisplay = [NSDecimalNumber decimalNumberWithDecimal:[[self orderTotal] decimalValue]];
  }
  NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
  storeCreditsToDisplay = [storeCreditsToDisplay decimalNumberByMultiplyingBy:minusOne];
  [[self storeCreditsTotalLabel] setText:[[self priceFormatter] stringFromNumber:storeCreditsToDisplay]];
  [[self storeCreditsTotalLabel] setHidden:[self isOrderEmpty]];
  [[self shippingTotalLabel] setText:[[self priceFormatter] stringFromNumber:[self shippingTotal]]];
  [[self shippingTotalLabel] setHidden:[self isOrderEmpty]];
  [[self taxTotalLabel] setText:[[self priceFormatter] stringFromNumber:[self taxTotal]]];
  [[self taxTotalLabel] setHidden:[self isOrderEmpty]];
  NSDecimalNumber *orderTotalToDisplay = [NSDecimalNumber zero];
  if ([[self orderTotal] compare:storeCreditsToDisplay] == NSOrderedDescending) {
    orderTotalToDisplay = [NSDecimalNumber decimalNumberWithDecimal:[[self orderTotal] decimalValue]];
    orderTotalToDisplay = [orderTotalToDisplay decimalNumberByAdding:storeCreditsToDisplay];
  }
  [[self orderTotalLabel] setText:[[self priceFormatter] stringFromNumber:orderTotalToDisplay]];

  // Do not display discount accessory, if no discounts applied.
  [[self discountImage] setHidden:[self isOrderEmpty] ||
                                  [[self discountTotal]
                                   compare:[NSNumber numberWithInteger:0]] == NSOrderedSame];
  [[self discountDescriptionLabel] setHidden:[[self discountImage] isHidden]];
  // Construct a multi-line text with all discounts applied to order.
  [[self discountDescriptionLabel] setText:nil];
  for (ATGPricingAdjustment *discount in [self discounts]) {
    if ([[self discountDescriptionLabel] text]) {
      [[self discountDescriptionLabel] setText:
       [[[self discountDescriptionLabel] text] stringByAppendingString:@"\n"]];
    } else {
      [[self discountDescriptionLabel] setText:@""];
    }
    [[self discountDescriptionLabel] setText:
     [[[self discountDescriptionLabel] text]
      stringByAppendingString:[discount pricingModel]]];
  }

  CGRect couponFrame = [[self couponCodeInput] frame];
  CGRect discountsFrame = [[self discountDescriptionLabel] frame];
  CGSize maxSize = CGSizeMake(discountsFrame.size.width,
                              couponFrame.origin.y - discountsFrame.origin.y);
  CGSize actualSize = [[[self discountDescriptionLabel] text]
                            sizeWithFont:[[self discountDescriptionLabel] font]
                       constrainedToSize:maxSize
                           lineBreakMode:[[self discountDescriptionLabel] lineBreakMode]];
  discountsFrame.size.height = actualSize.height;
  [[self discountDescriptionLabel] setFrame:discountsFrame];
  
  if ([self discountTotal] == nil ||
      [[NSNumber numberWithInteger:0] compare:[self discountTotal]] == NSOrderedSame) {
    [[self discountTotalLabel] setHidden:YES];
    layoutViews([self storeCreditsTotalLabel], [self itemsTotalLabel]);
    layoutViews([self shippingTotalLabel], [self storeCreditsTotalLabel]);
    layoutViews([self taxTotalLabel], [self shippingTotalLabel]);
  }
  if ([[NSNumber numberWithInteger:0] compare:storeCreditsToDisplay] == NSOrderedSame) {
    [[self storeCreditsTotalLabel] setHidden:YES];
    UIView *anchor = [[self discountTotalLabel] isHidden] ?
                      [self itemsTotalLabel] : [self discountTotalLabel];
    layoutViews([self shippingTotalLabel], anchor);
    layoutViews([self taxTotalLabel], [self shippingTotalLabel]);
  }

  // Do not display coupon input, if order is empty.
  // Remove this input from view hierarchy to prevent screen reader from reading it.
  if ([self isOrderEmpty] || [self isCouponHidden]) {
    [[self couponCodeInput] removeFromSuperview];
  } else {
    [[self contentView] addSubview:[self couponCodeInput]];
  }
  
  if (![self isCouponEditable]) {
    [[self couponCodeInput] setEnabled:NO];
  } else {
    [[self couponCodeInput] setEnabled:YES];
  }
  
  [[self couponCodeInput] setText:[self couponCode]];

  [[self couponCodeInput] invalidate:[self couponError]];
  [[self couponCodeInput] setNeedsLayout];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([(ATGValidatableInput *) textField validate]) {
    // There is a code specified. Notify the delegate to claim a coupon.
    [[self delegate] claimCouponWithCode:[textField text]];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [pTextField resignFirstResponder];
  return YES;
}

#pragma mark - Custom Methods

- (CGFloat)height {
  [self layoutIfNeeded];
  // Make enough space to display everything.
  CGRect itemsFrame = [[self itemsTotalLabel] frame];
  CGRect totalFrame = [[self orderTotalLabel] frame];
  return totalFrame.origin.y + totalFrame.size.height + itemsFrame.origin.y;
}

@end