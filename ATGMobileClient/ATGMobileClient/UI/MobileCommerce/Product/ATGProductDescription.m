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

#import "ATGProductDescription.h"

#define kDescrDividerImage @"description-divider.png"

#pragma mark - ATGProductDescription private protocol declaration
#pragma mark -
@interface ATGProductDescription ()

#pragma mark - Custom properties
@property (nonatomic, strong) UILabel *detailsHeaderLabel;
@property (nonatomic, strong) UILabel *relatedHeaderLabel;
@property (nonatomic, strong) UILabel *detailsTextLabel;
@property (nonatomic, strong) UIImageView *bottomDivider;
@property (nonatomic, strong) UIImageView *topDivider;

#pragma mark - Private methods
- (CGFloat) roundSize:(CGFloat)pSize;
- (void) additionalInit;
@end

#pragma mark - ATGProductDescription implementation
#pragma mark -
@implementation ATGProductDescription
#pragma mark - Synthesized Properties
@synthesize detailsHeaderLabel, relatedHeaderLabel, detailsTextLabel, bottomDivider, topDivider;

#pragma mark - UIView
- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self additionalInit];
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self additionalInit];
  }
  return self;
}

- (void) layoutSubviews {
  [super layoutSubviews];
  [self layout];
}

#pragma mark - Private methods
- (void) additionalInit {
  self.backgroundColor = [UIColor descriptionBackgroundColor];
  topDivider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
  topDivider.image = [UIImage imageNamed:kDescrDividerImage];
  [topDivider setAlpha:0.5];
  [self addSubview:topDivider];

  self.detailsHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 260, 21)];
  [self.detailsHeaderLabel applyStyleWithName:@"productDetailsHeaderLabel"];
  self.detailsHeaderLabel.text = NSLocalizedStringWithDefaultValue(@"ATGProductDescription.Details", nil, [NSBundle mainBundle],
                                                                   @"Details", @"ATGRenderableProduct Details Title");
  self.detailsHeaderLabel.backgroundColor = [UIColor clearColor];
  self.detailsHeaderLabel.hidden = YES;
  [self addSubview:self.detailsHeaderLabel];

  self.detailsTextLabel = [[UILabel alloc] init];
  [self.detailsTextLabel applyStyleWithName:@"productDetailsTextLabel"];
  [self addSubview:self.detailsTextLabel];

  self.bottomDivider = [[UIImageView alloc] init];
  self.bottomDivider.image = [UIImage imageNamed:kDescrDividerImage];
  [self.bottomDivider setAlpha:0.5];
  [self addSubview:self.bottomDivider];
}

- (void) layout {
  CGSize textSize = [self.detailsTextLabel.text sizeWithFont:self.detailsTextLabel.font];
  CGFloat calculatedHeight = [self roundSize:(textSize.width / 260)] * textSize.height;


  self.detailsTextLabel.frame = CGRectMake(30, 35, 260, calculatedHeight);

  CGFloat stroke = 35 + calculatedHeight + 10;

  CGFloat viewHeight = 0;

  if (self.relatedHeaderLabel) {
    self.relatedHeaderLabel.frame = CGRectMake(30, stroke, 260, 21);
    viewHeight = stroke + 31;
  } else {
    viewHeight = stroke + 10;
  }

  self.bottomDivider.frame = CGRectMake(0, viewHeight - 5, 320, 5);

  CGRect rect = self.frame;
  rect.size.height = viewHeight;
  self.frame = rect;
}

- (void) setRelatedItemsVisible:(BOOL)visible {
  if (visible) {
    self.relatedHeaderLabel = [[UILabel alloc] init];
    [self.relatedHeaderLabel applyStyleWithName:@"productDetailsHeaderLabel"];
    self.relatedHeaderLabel.text = NSLocalizedStringWithDefaultValue(@"ATGProductDescription.Related", nil, [NSBundle mainBundle],
                                                                     @"Related Items", @"ATGRenderableProduct Related Items Title");
    [self addSubview:self.relatedHeaderLabel];
  } else {
    [self.relatedHeaderLabel removeFromSuperview];
    self.relatedHeaderLabel = nil;
  }
  [self setNeedsLayout];
}

- (void) setDetailsText:(NSString *)text {
  self.detailsTextLabel.text = text;
  self.detailsHeaderLabel.hidden = [text length] == 0;
  [self setNeedsLayout];
}

- (CGFloat) roundSize:(CGFloat)pSize {
  NSInteger num = pSize;
  if (pSize > num) {
    return num + 2;
  }
  return num;
}

@end