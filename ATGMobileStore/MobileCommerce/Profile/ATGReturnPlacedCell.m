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

#import "ATGReturnPlacedCell.h"
#import <ATGMobileClient/ATGReturnRequest.h>

#define CAPTION_AND_LABEL_PADDING 5.0

@interface ATGReturnPlacedCell()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *statusCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *statusLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *dateCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *originalOrderCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *originalOrderLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *exchangesCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *exchangesLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ATGReturnPlacedCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
  // apply styles
  [self.statusCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.statusLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.dateCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.dateLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.originalOrderCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.originalOrderLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.exchangesCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.exchangesLabel applyStyleWithName:@"formFieldBlackLabel"];
  
  // Update localizable sources after the view is loaded from NIB.
  NSString *caption = NSLocalizedStringWithDefaultValue
    (@"ATGPlacedReturnCell.StatusCaption", nil, [NSBundle mainBundle], @"Status:",
     @"'Status:' caption to be used on the return placed cell.");
  [[self statusCaptionLabel] setText:caption];
  self.statusCaptionLabel.frame = [self.statusCaptionLabel textRectForBounds:self.statusCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGPlacedReturnCell.DateCaption", nil, [NSBundle mainBundle],
     @"Submitted:", @"'Submitted:' caption to be used on the return placed cell.");
  [[self dateCaptionLabel] setText:caption];
  self.dateCaptionLabel.frame = [self.dateCaptionLabel textRectForBounds:self.dateCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGPlacedReturnCell.ExchangesCaption", nil, [NSBundle mainBundle], @"Replacement Order:",
     @"'Replacement Order:' caption to be used on the return placed cell, items exchanged from order.");
  [[self exchangesCaptionLabel] setText:caption];
  self.exchangesCaptionLabel.frame = [self.exchangesCaptionLabel textRectForBounds:self.exchangesCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGPlacedReturnCell.ParentOrderCaption", nil, [NSBundle mainBundle], @"From Order:",
     @"'From Order:' caption to be used on the returns placed cell, relevant parent order.");
  [[self originalOrderCaptionLabel] setText:caption];
  self.originalOrderCaptionLabel.frame = [self.originalOrderCaptionLabel textRectForBounds:self.originalOrderCaptionLabel.frame limitedToNumberOfLines:1];
  
  [self setDateFormatter:[[NSDateFormatter alloc] init]];
  [[self dateFormatter] setLocale:[NSLocale currentLocale]];
  NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy" options:0
                                                          locale:[NSLocale currentLocale]];
  [[self dateFormatter] setDateFormat:dateFormat];
  
}

- (void)setObject:(id)object {
  ATGReturnRequest *returnRequest = (ATGReturnRequest *)object;
  
  self.statusLabel.text = returnRequest.stateDetailAsUserResource;
  self.statusLabel.left = self.statusCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  self.dateLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:[returnRequest.submittedDate doubleValue]/1000.00]];
  self.dateLabel.left = self.dateCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  self.originalOrderLabel.text = returnRequest.orderId;
  self.originalOrderLabel.left = self.originalOrderCaptionLabel.right + CAPTION_AND_LABEL_PADDING;

  if (returnRequest.replacementOrderId) {
    self.exchangesCaptionLabel.hidden = NO;
    self.exchangesLabel.hidden = NO;
    self.exchangesLabel.text = returnRequest.replacementOrderId;
    self.exchangesLabel.left = self.exchangesCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  } else {
    self.exchangesCaptionLabel.hidden = YES;
    self.exchangesLabel.hidden = YES;
  }
 
}

@end
