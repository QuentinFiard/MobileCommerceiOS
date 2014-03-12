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

#import "ATGOrderReviewAddressTableViewCell.h"
#import <ATGMobileClient/ATGContactInfo.h>

#pragma mark - ATGAddressTableViewCell Private Protocol Definition
#pragma mark -

@interface ATGOrderReviewAddressTableViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *nameLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite) UIEdgeInsets insets;

@end

#pragma mark - ATGAddressTableViewCell Implementation
#pragma mark -

@implementation ATGOrderReviewAddressTableViewCell

#pragma mark - Synthesized Properties

@synthesize address;
@synthesize addressLabel;
@synthesize nameLabel;
@synthesize insets;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];
  
  CGRect addressFrame = [self convertRect:[[self addressLabel] bounds] fromView:[self addressLabel]];
  CGRect bounds = [self bounds];
  
  CGFloat bottomMargin = bounds.size.height - addressFrame.origin.y - addressFrame.size.height;
  
  [self setInsets:UIEdgeInsetsMake(0, 0, bottomMargin, 0)];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];
  
  NSString *name = [[[self address] firstName] stringByAppendingFormat:@" %@", [[self address] lastName]];
  if ([[self address] isGiftAddress]) {
    NSString *template = NSLocalizedStringWithDefaultValue
    (@"ATGAddressTableViewCell.NameTemplate",
     nil, [NSBundle mainBundle], @"Gift List: %@",
     @"Address name template to be used when address came from a gift list. "
     @"An only parameter of the template is gift list owner's name.");
    name = [NSString stringWithFormat:template, name];
  }
  
  [[self nameLabel] setText:name];
  
  NSString *result = [[self address] address1];
  if ([[[self address] address2] length]) {
    result = [NSString stringWithFormat:@"%@\n%@", result, [[self address] address2]];
  }
  result = [NSString stringWithFormat:@"%@\n%@, %@ %@\n%@\n%@", result, [[self address] city],
            [[self address] state], [[self address] postalCode], [[self address] country],
            [[self address] phoneNumber]];
  [[self addressLabel] setText:result];
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  [self layoutIfNeeded];
  
  CGSize maxSize = CGSizeMake([[self addressLabel] bounds].size.width, 1000);
  CGSize addressSize = [[[self addressLabel] text] sizeWithFont:[[self addressLabel] font] constrainedToSize:maxSize];
  CGRect addressFrame = [self convertRect:[[self addressLabel] bounds] fromView:[self addressLabel]];
  
  CGFloat requiredHeight = addressFrame.origin.y + addressSize.height + [self insets].bottom;
  
  return CGSizeMake(pSize.width, requiredHeight);
}

@end

