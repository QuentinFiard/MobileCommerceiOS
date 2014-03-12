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

#import "ATGAddressTableViewCell.h"
#import <ATGMobileClient/ATGContactInfo.h>
#import <ATGMobileClient/ATGShippingGroup.h>

#define CAPTION_AND_LABEL_PADDING 5.0

@interface ATGAddressTableViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *addressCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *shippingMethodCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *shippingMethodLabel;
@end

@implementation ATGAddressTableViewCell

- (void) awakeFromNib {
  [super awakeFromNib];  
  NSString *localizedText = NSLocalizedStringWithDefaultValue(@"ATGAddressTableViewCell.AddressCaptionLabel", nil, [NSBundle mainBundle], @"Ship To:", @"Prefix for address which the order was shipped to");
  [[self addressCaptionLabel] setText:localizedText];
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGAddressTableViewCell.ShippingMethodCaptionLabel", nil, [NSBundle mainBundle], @"Via:", @"Prefix for shipping method which the order was shipped with");
  [[self shippingMethodCaptionLabel] setText:localizedText];
  
  [self.contentView applyStyleWithName:@"orderDetailsShipToCell"];
}

- (void)setObject:(id)object {
  
  id<ATGShippingGroup> shippingGroup = (id<ATGShippingGroup>)object;
  
  NSString *result = [NSString stringWithFormat:@"%@ %@\n%@", [shippingGroup.shippingAddress firstName], [shippingGroup.shippingAddress lastName], [shippingGroup.shippingAddress address1]];
  if ([[shippingGroup.shippingAddress address2] length]) {
    result = [NSString stringWithFormat:@"%@\n%@", result, [shippingGroup.shippingAddress address2]];
  }
  result = [NSString stringWithFormat:@"%@\n%@, %@ %@\n%@\n%@", result, [shippingGroup.shippingAddress city],
            [shippingGroup.shippingAddress state], [shippingGroup.shippingAddress postalCode], [shippingGroup.shippingAddress country],
            [shippingGroup.shippingAddress phoneNumber]];
  [[self addressLabel] setText:result];
  self.addressLabel.frame = [self.addressLabel textRectForBounds:self.addressLabel.frame limitedToNumberOfLines:6];
  
  self.addressLabel.top = self.addressCaptionLabel.bottom;
  
  self.shippingMethodLabel.text = shippingGroup.shippingMethod;
  self.shippingMethodLabel.top = self.shippingMethodCaptionLabel.bottom;
}

@end