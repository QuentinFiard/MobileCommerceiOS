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

#import "ATGGiftOptionsTableViewCell.h"

#pragma mark - ATGGiftOptionsTableViewCell Private Protocol Definition
#pragma mark -

@interface ATGGiftOptionsTableViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *captionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *optionsLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *giftNoteLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite) UIEdgeInsets insets;

@end

#pragma mark - ATGGiftOptionsTableViewCell Implementation
#pragma mark -

@implementation ATGGiftOptionsTableViewCell

#pragma mark - Synthesized Properties

@synthesize captionLabel;
@synthesize optionsLabel;
@synthesize giftNoteLabel;
@synthesize giftOptions;
@synthesize giftNote;
@synthesize insets;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  NSString *caption = NSLocalizedStringWithDefaultValue
                        (@"ATGGiftOptionsTableViewCell.CellCaption",
                         nil, [NSBundle mainBundle], @"Gift Options:",
                        @"Captions to be used by the cell dislpaying gift wrap/note settings.");
  [[self captionLabel] setText:caption];

  CGFloat topInset = [[self captionLabel] frame].origin.y;
  CGFloat bottomInset = [self bounds].size.height - [[self giftNoteLabel] frame].origin.y -
                        [[self giftNoteLabel] frame].size.height;
  [self setInsets:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  NSString *option = nil;
  switch ([self giftOptions]) {
  case ATGGiftOptionsNone:
    option = NSLocalizedStringWithDefaultValue
               (@"ATGGiftOptionsTableViewCell.NoneSelected",
                nil, [NSBundle mainBundle], @"None",
               @"Text to be displayed as gift option, if nothing selected.");
    break;

  case ATGGiftOptionsGiftWrap:
    option = NSLocalizedStringWithDefaultValue
               (@"ATGGiftOptionsTableViewCell.GiftWrapSelected",
                nil, [NSBundle mainBundle], @"Wrap",
               @"Text to be displayed as gift option, if gift wrap only selected.");
    break;

  case ATGGiftOptionsGiftNote:
    option = NSLocalizedStringWithDefaultValue
               (@"ATGGiftOptionsTableViewCell.GiftNoteSelected",
                nil, [NSBundle mainBundle], @"Note",
               @"Text to be displayed as gift option, if gift note only selected.");
    break;

  case ATGGiftOptionsBoth:
    option = NSLocalizedStringWithDefaultValue
               (@"ATGGiftOptionsTableViewCell.BothSelected",
                nil, [NSBundle mainBundle], @"Wrap + Note",
               @"Text to be displayed as gift option, if both gift wrap and note provided.");
  }
  [[self optionsLabel] setText:option];

  [[self giftNoteLabel] setText:[self giftNote]];
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  CGSize maxSize = [[self giftNoteLabel] bounds].size;
  maxSize.height = CGFLOAT_MAX;
  CGSize giftNoteSize = CGSizeZero;
  if ([self giftNote]) {
    giftNoteSize = [[self giftNote] sizeWithFont:[[self giftNoteLabel] font]
                               constrainedToSize:maxSize
                                   lineBreakMode:[[self giftNoteLabel] lineBreakMode]];
  }
  CGFloat requiredHeight = [[self giftNoteLabel] frame].origin.y + giftNoteSize.height +
                           [self insets].bottom;
  CGFloat requiredWidth = [self bounds].size.width;
  return CGSizeMake(requiredWidth, requiredHeight);
}

@end