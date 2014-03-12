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

#import "ATGBarButton.h"
#import <ATGMobileClient/ATGDataFormatters.h>

// Additional space to be allocated for the caption button.
static const CGFloat ATGDefaultNavigationItemSpace = 40;

#pragma mark - ATGBarButton private interface declaration
#pragma mark -

@interface ATGBarButton ()

@property (nonatomic, readwrite, weak) UILabel *badgeLabel;

@end

#pragma mark - ATGBarButton Implementation
#pragma mark -

@implementation ATGBarButton

#pragma mark - Instance Management

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [badgeLabel applyStyleWithName:@"barButtonItemBadge_iPad"];
    
    [[badgeLabel layer] setShadowOffset:CGSizeMake(1, 1)];
    
    [self setBadgeLabel:badgeLabel];
    [self addSubview:badgeLabel];
  }
  return self;
}

#pragma mark - UIView

- (CGSize) sizeThatFits:(CGSize)pSize {
  CGFloat width = 0;
  if ([[self currentTitle] length]) {
    CGSize size = [[self currentTitle] sizeWithFont:[[self titleLabel] font]];
    width = size.width + ATGDefaultNavigationItemSpace;
  } else if ([self currentBackgroundImage]) {
    CGSize size = [[self currentBackgroundImage] size];
    width = MAX(width, size.width);
  }
  return CGSizeMake(width, pSize.height);
}

- (void) layoutSubviews {
  [super layoutSubviews];
  [[self badgeLabel] setHidden:[self badgeValue] == 0];
  [[self badgeLabel] setText:[[ATGDataFormatters decimalFormatter]
                        stringFromNumber:[NSNumber numberWithInteger:[self badgeValue]]]];
  CGSize labelSize = [[[self badgeLabel] text] sizeWithFont:[[self badgeLabel] font]];
  labelSize.height += 2 * 3;
  labelSize.width = labelSize.width + 2 * 3 <= labelSize.height ?
                    labelSize.height : labelSize.width + 2 * 3;
  CGRect buttonBounds = [self bounds];
  [[self badgeLabel] setFrame:CGRectMake(buttonBounds.size.width - labelSize.width - 5,
                                   buttonBounds.size.height - labelSize.height - 5,
                                   labelSize.width, labelSize.height)];
  [[[self badgeLabel] layer] setCornerRadius:labelSize.height / 2];
  [self bringSubviewToFront:self.badgeLabel];
}

#pragma mark - UIAccessibility Protocol Implementation

- (NSString *) accessibilityValue {
  if ([self badgeValue]) {
    NSString *format =
      NSLocalizedStringWithDefaultValue(@"ATGBarButtonItem.Accessibility.Value.ItemsFormat", nil, [NSBundle mainBundle],
                                        @"Items: %@.", @"Format to be used when constructin an accessibility value of a toolbar button.");
    return [NSString stringWithFormat:format, [[self badgeLabel] text]];
  }
  return nil;
}

@end