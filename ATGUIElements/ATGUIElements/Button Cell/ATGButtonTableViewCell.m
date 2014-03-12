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

#import "ATGButtonTableViewCell.h"
#import "ATGButton.h"

#pragma mark - ATGButtonTableViewCell private interface declaration
#pragma mark -

@interface ATGButtonTableViewCell ()

@property (nonatomic, readwrite) UIButton *button;

@end

#pragma mark - ATGButtonTableViewCell Implementation
#pragma mark -

@implementation ATGButtonTableViewCell

#pragma mark - Instance Management

- (id) initWithReuseIdentifier:(NSString *)pReuseIdentifier showUnderlay:(BOOL)pShowUnderlay {
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:pReuseIdentifier];
  if (self) {
    // Make self completely transparent.
    UIView *background = [[UIView alloc] initWithFrame:CGRectZero];
    [background setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:background];

    CGRect bounds = [self bounds];

    if (pShowUnderlay) {
      // Add an underlay image.
      UIImageView *underlay = [[UIImageView alloc]
                               initWithImage:[UIImage imageNamed:@"table-underlay"]];
      CGSize imageSize = [[underlay image] size];
      CGRect frame = CGRectMake(0, (bounds.size.height - imageSize.height) / 2 - 10,
                                bounds.size.width, imageSize.height);
      [underlay setFrame:frame];
      [self insertSubview:underlay atIndex:0];

      // Make the while underlay tall enough to span till the end of the table.
      CGRect whiteFrame = CGRectMake(0, frame.origin.y + frame.size.height - 22,
                                     bounds.size.width, 500);
      UIView *whiteUnderlay = [[UIView alloc] initWithFrame:whiteFrame];
      [self insertSubview:whiteUnderlay atIndex:0];
      [whiteUnderlay setBackgroundColor:[UIColor whiteColor]];
    }

    // Add a button.
    UIButton *button = [[ATGButton alloc] initWithFrame:CGRectZero];
    [button applyStyleWithName:@"blueButton"];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin];
    [button setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
    [[self contentView] addSubview:button];
    [self setButton:button];
  }
  [self setBackgroundColor:[UIColor clearColor]];
  UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
  backView.backgroundColor = [UIColor clearColor];
  self.backgroundView = backView;
  return self;
}

- (id) initWithReuseIdentifier:(NSString *)pReuseIdentifier {
  self = [self initWithReuseIdentifier:pReuseIdentifier showUnderlay:YES];
  return self;
}

- (id) init {
  self = [self initWithReuseIdentifier:nil];
  return self;
}

- (id) initWithStyle:(UITableViewCellStyle)pStyle
     reuseIdentifier:(NSString *)pReuseIdentifier {
  self = [self initWithReuseIdentifier:pReuseIdentifier];
  return self;
}

#pragma mark - UITableViewCell

- (UILabel *) textLabel {
  return nil;
}

- (UILabel *) detailTextLabel {
  return nil;
}

- (UIImageView *) imageView {
  return nil;
}

- (void) setSelected:(BOOL)pSelected animated:(BOOL)pAnimated {
  [super setSelected:NO animated:NO];
}

- (void) setHighlighted:(BOOL)pHighlighted animated:(BOOL)pAnimated {
  [super setHighlighted:NO animated:NO];
}

@end