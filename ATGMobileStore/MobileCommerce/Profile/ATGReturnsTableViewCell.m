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

#import "ATGReturnsTableViewCell.h"
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGRestManager.h>

#pragma mark - ATGOrdersTableViewCell Private Protocol
#pragma mark -
#define INTERLABEL_PAD 5.0

@interface ATGReturnsTableViewCell ()

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *returnIDLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *returnIDCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *itemsCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *dateCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *statusCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *itemsLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, strong) NSNumberFormatter *numberFormatter;

@end

@implementation ATGReturnsTableViewCell

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  
  // apply styles
  [self.returnIDLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.returnIDCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.itemsCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.itemsLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.dateCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.dateLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.siteCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.siteLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.statusCaptionLabel applyStyleWithName:@"formFieldLabel"];
  [self.statusLabel applyStyleWithName:@"formFieldBlackLabel"];
  [self.contentView applyStyleWithName:@"orderHistoryTableViewCell"];
  
  // Update localizable sources after the view is loaded from NIB.
  NSString *caption = NSLocalizedStringWithDefaultValue
    (@"ATGReturnsTableViewCell.ItemsCaption", nil, [NSBundle mainBundle], @"Items:",
     @"'Items:' caption to be used on the returns cell.");
  [[self itemsCaptionLabel] setText:caption];
  self.itemsCaptionLabel.frame = [self.itemsCaptionLabel textRectForBounds:self.itemsCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGReturnsTableViewCell.DatePlacedCaption", nil, [NSBundle mainBundle],
     @"Submitted:", @"'Submitted:' caption to be used on the returns cell.");
  [[self dateCaptionLabel] setText:caption];
  self.dateCaptionLabel.frame = [self.dateCaptionLabel textRectForBounds:self.dateCaptionLabel.frame limitedToNumberOfLines:1];

  caption = NSLocalizedStringWithDefaultValue(@"ATGReturnsTableViewCell.SiteCaption", nil, [NSBundle mainBundle],
    @"Site:", @"'Site:' caption to be used on the returns cell.");
  [[self siteCaptionLabel] setText:caption];
  self.siteCaptionLabel.frame = [self.siteCaptionLabel textRectForBounds:self.siteCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGReturnsTableViewCell.StatusCaption", nil, [NSBundle mainBundle], @"Return Status:",
     @"'Return Status:' caption to be used on the returns cell.");
  [[self statusCaptionLabel] setText:caption];
  self.statusCaptionLabel.frame = [self.statusCaptionLabel textRectForBounds:self.statusCaptionLabel.frame limitedToNumberOfLines:1];
  
  caption = NSLocalizedStringWithDefaultValue
    (@"ATGReturnsTableViewCell.ReturnIDCaption", nil, [NSBundle mainBundle], @"Return #:",
     @"'Return #:' caption to be used on the returns cell.");
  [[self returnIDCaptionLabel] setText:caption];
  self.returnIDCaptionLabel.frame = [self.returnIDCaptionLabel textRectForBounds:self.returnIDCaptionLabel.frame limitedToNumberOfLines:1];
  
  [self setNumberFormatter:[[NSNumberFormatter alloc] init]];
  [[self numberFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
  [[self numberFormatter] setLocale:[NSLocale currentLocale]];
  
  [self setDateFormatter:[[NSDateFormatter alloc] init]];
  [[self dateFormatter] setLocale:[NSLocale currentLocale]];
  NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ddMMyyyy" options:0
                                                          locale:[NSLocale currentLocale]];
  [[self dateFormatter] setDateFormat:dateFormat];
  
  UIView *underlay = [[UIView alloc] initWithFrame:CGRectMake(7, 5, 116, 116)];
  underlay.layer.cornerRadius = 8.0;
  underlay.backgroundColor = [UIColor whiteColor];
  [self.contentView insertSubview:underlay belowSubview:self.productImageView];
  
  UIImageView *imageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product-image-box-for-iphone"]];
  imageOverlay.frame = CGRectMake(7, 5, 116, 116);
  [self.contentView addSubview:imageOverlay];
}

- (void)setObject:(id)object {
  ATGReturnRequest *returnRequest = (ATGReturnRequest *)object;
  [[self returnIDLabel] setText:returnRequest.requestId];
  self.returnIDLabel.left = self.returnIDCaptionLabel.right + INTERLABEL_PAD;
  [[self itemsLabel] setText:[[self numberFormatter]
                              stringFromNumber:returnRequest.returnItemCount]];
  self.itemsLabel.left = self.itemsCaptionLabel.right + INTERLABEL_PAD;
  [[self dateLabel] setText:[[self dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:[returnRequest.submittedDate doubleValue]/1000.0]]];
  self.dateLabel.left = self.dateCaptionLabel.right + INTERLABEL_PAD;
  [[self siteLabel] setText:returnRequest.siteName];
  [[self statusLabel] setText:returnRequest.stateDetailAsUserResource];
  [[self productImageView] setImageURL:[ATGRestManager getAbsoluteImageString:returnRequest.thumbnailImageUrl]];
}

@end
