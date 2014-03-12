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

#import "ATGOrderPlacedCell.h"
#import <ATGMobileClient/ATGOrder.h>
#import <ATGMobileClient/ATGReturnRequest.h>

#define CAPTION_AND_LABEL_PADDING 5.0

@interface ATGOrderPlacedCell()

@property (nonatomic, weak, readwrite) IBOutlet UILabel *statusCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *statusLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *dateCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *storeCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *storeLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *returnsCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *returnsLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *exchangesCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *exchangesLabel;

@property (nonatomic, weak, readwrite) IBOutlet UILabel *parentOrderCaptionLabel;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *parentOrderLabel;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ATGOrderPlacedCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
  // apply styles
  [self.statusCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.statusLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.dateCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.dateLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.storeCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.storeLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.returnsCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.returnsLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.exchangesCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.exchangesLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.parentOrderCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.parentOrderLabel applyStyleWithName:@"formFieldBlackLabel"];
  
  // Update localizable sources after the view is loaded from NIB.
  NSString *caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.StatusCaption", nil, [NSBundle mainBundle], @"Status:",
   @"'Status:' caption to be used on the order placed cell.");
  [[self statusCaptionLabel] setText:caption];
  self.statusCaptionLabel.frame = [self.statusCaptionLabel textRectForBounds:self.statusCaptionLabel.frame limitedToNumberOfLines:1];
  caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.DateCaption", nil, [NSBundle mainBundle],
   @"Order Placed:", @"'Order Placed:' caption to be used on the orders placed cell.");
  [[self dateCaptionLabel] setText:caption];
  self.dateCaptionLabel.frame = [self.dateCaptionLabel textRectForBounds:self.dateCaptionLabel.frame limitedToNumberOfLines:1];
  caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.StoreCaption", nil, [NSBundle mainBundle], @"Ordered On:",
   @"'Ordered On:' caption to be used on the orders placed cell, site ordered from.");
  [[self storeCaptionLabel] setText:caption];
  self.storeCaptionLabel.frame = [self.storeCaptionLabel textRectForBounds:self.storeCaptionLabel.frame limitedToNumberOfLines:1];
  caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.ReturnsCaption", nil, [NSBundle mainBundle], @"Returns from this order:",
   @"'Returns from this order:' caption to be used on the orders placed cell, items returned from order.");
  [[self returnsCaptionLabel] setText:caption];
  self.returnsCaptionLabel.frame = [self.returnsCaptionLabel textRectForBounds:self.returnsCaptionLabel.frame limitedToNumberOfLines:1];
  caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.ExchangesCaption", nil, [NSBundle mainBundle], @"Exchanges from this order:",
   @"'Exchanges from this order:' caption to be used on the orders placed cell, items exchanged from order.");
  [[self exchangesCaptionLabel] setText:caption];
  self.exchangesCaptionLabel.frame = [self.exchangesCaptionLabel textRectForBounds:self.exchangesCaptionLabel.frame limitedToNumberOfLines:1];
  caption = NSLocalizedStringWithDefaultValue
  (@"ATGPlacedOrderCell.ParentOrderCaption", nil, [NSBundle mainBundle], @"Parent order:",
   @"'Parent order:' caption to be used on the orders placed cell, relevant parent order.");
  [[self parentOrderCaptionLabel] setText:caption];
  self.parentOrderCaptionLabel.frame = [self.parentOrderCaptionLabel textRectForBounds:self.parentOrderCaptionLabel.frame limitedToNumberOfLines:1];

  [self setNumberFormatter:[[NSNumberFormatter alloc] init]];
  [[self numberFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
  [[self numberFormatter] setLocale:[NSLocale currentLocale]];
  
  [self setDateFormatter:[[NSDateFormatter alloc] init]];
  [[self dateFormatter] setLocale:[NSLocale currentLocale]];
  NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy" options:0
                                                          locale:[NSLocale currentLocale]];
  [[self dateFormatter] setDateFormat:dateFormat];
  
}

- (void)setObject:(id)object {
  ATGOrder *order = (ATGOrder *)object;
  
  self.statusLabel.text = order.status;
  self.statusLabel.left = self.statusCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  self.dateLabel.text = [self.dateFormatter stringFromDate:[order submittedDate]];
  self.dateLabel.left = self.dateCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  self.storeLabel.text = order.siteName;
  self.storeLabel.left = self.storeCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  NSString *returnText = @"";
  NSString *exchangeText = @"";
  if (order.returnRequests.count) {
    for (ATGReturnRequest *returnRequest in order.returnRequests) {
      returnText = (returnText.length > 0 ? [NSString stringWithFormat:@"%@, %@", returnText, returnRequest.requestId] : returnRequest.requestId);
      exchangeText = (exchangeText.length > 0 ? [NSString stringWithFormat:@"%@, %@", exchangeText, returnRequest.replacementOrderId] : returnRequest.replacementOrderId);
    }
  }

  if (returnText.length > 0) {
    self.returnsLabel.text = returnText;
    self.returnsLabel.left = self.returnsCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  } else {
    self.returnsCaptionLabel.hidden = TRUE;
    self.returnsLabel.hidden = TRUE;
  }

  if (exchangeText.length > 0) {
    self.exchangesLabel.text = exchangeText;
    self.exchangesLabel.left = self.exchangesCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  } else {
    self.exchangesCaptionLabel.hidden = TRUE;
    self.exchangesLabel.hidden = TRUE;
  }

  if (order.parentOrderId != nil) {
    self.parentOrderLabel.text = order.parentOrderId;
    self.parentOrderLabel.left = self.parentOrderCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  } else {
    self.parentOrderCaptionLabel.hidden = TRUE;
    self.parentOrderLabel.hidden = TRUE;
  }
}

@end
