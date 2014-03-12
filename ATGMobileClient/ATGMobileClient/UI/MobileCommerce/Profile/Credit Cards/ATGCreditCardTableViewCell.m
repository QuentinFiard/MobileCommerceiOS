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

#import "ATGCreditCardTableViewCell.h"
#import <ATGMobileClient/ATGCreditCard.h>

#pragma mark - ATGCreditCardTableViewCell Private Protocol
#pragma mark -

@interface ATGCreditCardTableViewCell ()

#pragma mark - IB Outlets

#pragma mark - Custom Properties

@property (nonatomic, readwrite) UIEdgeInsets insets;

@end

#pragma mark - ATGCreditCardTableViewCell Implementation
#pragma mark -

@implementation ATGCreditCardTableViewCell

#pragma mark - Synthesized Properties

@synthesize creditCard;
@synthesize cardNameLabel;
@synthesize cardIdentifierLabel;
@synthesize expirationDateLabel;
@synthesize addressLabel;
@synthesize expirationCaptionLabel;
@synthesize checkmarkImageView;
@synthesize addressCaptionLabel;
@synthesize insets;
@synthesize accessoryButton;
@synthesize defaultCardLabel;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  // Save default margins defined with IB for future use. We're going to take into account these margins
  // when calculating a required cell height.
  CGRect cardNameFrame = [self convertRect:[[self cardNameLabel] bounds]
                                  fromView:[self cardNameLabel]];
  CGRect cardIdFrame = [self convertRect:[[self cardIdentifierLabel] bounds]
                                fromView:[self cardIdentifierLabel]];
  CGRect addressFrame = [self convertRect:[[self addressLabel] bounds]
                                 fromView:[self addressLabel]];
  CGRect bounds = [self bounds];

  CGFloat leftMargin = cardNameFrame.origin.x;
  CGFloat topMargin = cardNameFrame.origin.y;
  CGFloat rightMargin = bounds.size.width - cardIdFrame.origin.x - cardIdFrame.size.width;
  CGFloat bottomMargin = bounds.size.height - addressFrame.origin.y - addressFrame.size.height;

  [self setInsets:UIEdgeInsetsMake(topMargin, leftMargin, bottomMargin, rightMargin)];

  [[self defaultCardLabel] setText:NSLocalizedStringWithDefaultValue
     (@"ATGCreditCardTableViewCell.DefaultCardLabel",
      nil, [NSBundle mainBundle], @"Default",
     @"'Default' label displayed next to default credit card.")];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  [[self cardNameLabel] setText:[[self creditCard] nickname]];
  NSString *format = NSLocalizedStringWithDefaultValue
                       (@"ATGCreditCardTableViewCell.CardIdentifierFormat",
                        nil, [NSBundle mainBundle], @"%1$@ ...%2$@",
                       @"Specifies format of the card identification string. First parameter is card type, "
                       @"second parameter are last four digits of card's number.");
  [[self cardIdentifierLabel] setText:[NSString stringWithFormat:format,
                                       [self.creditCard creditCardTypeDisplayName],
                                       [[self creditCard] maskedCreditCardNumber]]];
  ATGContactInfo *billingAddress = [[self creditCard] billingAddress];
  NSString *address = [NSString stringWithFormat:@"%@ %@\n%@",
                       [billingAddress firstName], [billingAddress lastName], [billingAddress address1]];
  if ([[billingAddress address2] length]) {
    address = [NSString stringWithFormat:@"%@\n%@", address, [billingAddress address2]];
  }
  address = [NSString stringWithFormat:@"%@\n%@, %@ %@\n%@\n%@",
             address, [billingAddress city], [billingAddress state], [billingAddress postalCode],
             [billingAddress country], [billingAddress phoneNumber]];
  [[self addressLabel] setText:address];
  if ([self expirationCaptionLabel]) {
    format = NSLocalizedStringWithDefaultValue
               (@"ATGCreditCardTableViewCell.ExpirationDateFormatNoPrefix",
                nil, [NSBundle mainBundle], @"%1$@ / %2$@",
               @"Specifies format to be used when displaying card's expiration date when displaying card totals. "
               @"First parameter of this format is expiration month, second parameter is expiration year.");
  } else {
    format = NSLocalizedStringWithDefaultValue
               (@"ATGCreditCardTableViewCell.ExpirationDateFormatWithPrefix",
                nil, [NSBundle mainBundle], @"Exp. %1$@ / %2$@",
               @"Specifies format to be used when displaying card's expiration date when dislpaying "
               @"a list of credit cards. First parameter of this format is expiration month, "
               @"second parameter is expiration year.");
  }
  [[self expirationDateLabel] setText:[NSString stringWithFormat:format,
                                       [[self creditCard] expirationMonth],
                                       [[self creditCard] expirationYear]]];
  [[self defaultCardLabel] setHidden:![[[self creditCard] repositoryId]
                                       isEqualToString:[[self creditCard] defaultCreditCardId]]];
  
  _cardAmountLabel.layer.zPosition = 10;
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  [self layoutIfNeeded];

  CGSize maxSize = CGSizeMake([[self addressLabel] bounds].size.width, 1000);
  CGSize addressSize = [[[self addressLabel] text] sizeWithFont:[[self addressLabel] font]
                                              constrainedToSize:maxSize];
  CGRect addressFrame = [self convertRect:[[self addressLabel] bounds] fromView:[self addressLabel]];

  CGFloat requiredHeight = addressFrame.origin.y + addressSize.height + [self insets].bottom;

  return CGSizeMake(pSize.width, requiredHeight);
}

- (void)setCheckMarkHidden:(BOOL)pHidden {
  [[self checkmarkImageView] setHidden:pHidden];
}

@end
