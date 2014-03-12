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

#import "ATGBarButtonItem.h"

#pragma mark - ATGBarButtonItem Private Protocol Definition
#pragma mark -

@interface ATGBarButtonItem ()
{
  NSInteger mBadgeValue;
}

// Full control over item initialization process.
- (id) initWithIcon:(UIImage *)icon
              title:(NSString *)title
         badgeValue:(NSInteger)badgeValue
          styleName:(NSString*)pStyleName
             target:(id)target
             action:(SEL)action;

/*!
 @method addDividerToView
 @abstract Creates a toolbar divider.
 @param view the view to add a divider to
 @param height
 @return Fully configured button item.
 */
+ (ATGBarButton *) addDividerToView:(UIView *)pView
                             height:(CGFloat)pHeight;

@end

#pragma mark - ATGBarButtonItem Implementation
#pragma mark -

@implementation ATGBarButtonItem

static NSString *const NavBarDividerImageName = @"menu-divider.png";

#pragma mark - Factory Methods

+ (ATGBarButtonItem *) backButtonItemForTarget:(id)pTarget action:(SEL)pAction {
  ATGBarButtonItem *item = [[self alloc] initWithTarget:pTarget styleName:@"navBarBackButton" action:pAction];
  NSString *label = NSLocalizedStringWithDefaultValue
                      (@"ATGBarButtonItem.Accessibility.Label.Back",
                       nil, [NSBundle mainBundle], @"Back",
                      @"Accessibility label to be used by the Back navigation button.");
  [[item customView] setAccessibilityLabel:label];
  return item;
}

+ (ATGBarButtonItem *) barButtonItemWithTitle:(NSString *)pTitle height:(CGFloat)pHeight target:(id)pTarget
                                     selector:(SEL)pSelector divider:(BOOL)pDivider {
  ATGBarButton *button = [ATGBarButton buttonWithType:UIButtonTypeCustom];
  [button applyStyleWithName:@"navBarButton_iPad"];
  
  CGRect frame = CGRectZero;
  frame.size = [pTitle sizeWithFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
  frame.size.width = frame.size.width + 10;
  frame.size.height = pHeight;
  button.frame = frame;
  UIEdgeInsets insets = button.contentEdgeInsets;
  insets.left = -5;
  button.contentEdgeInsets = insets;
  [button setTitle:pTitle forState:UIControlStateNormal];
  [button addTarget:pTarget action:pSelector forControlEvents:UIControlEventTouchUpInside];
  if (pDivider) {
    button = (ATGBarButton *)[self addDividerToView:button height:pHeight];
  }
  return [[ATGBarButtonItem alloc] initWithCustomView:button];
}

+ (ATGBarButtonItem *) barButtonItemFromImageNamed:(NSString *)pImgName accessibilityLabel:(NSString *)pAccessibilityLabel
                                            height:(CGFloat)pHeight target:(id)pTarget selector:(SEL)pSelector divider:(BOOL)pDivider {
  UIImage *img = [UIImage imageNamed:pImgName];
  ATGBarButton *button = [[ATGBarButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width + 20, pHeight)];
  button.accessibilityLabel = pAccessibilityLabel;
  UIEdgeInsets insets = button.contentEdgeInsets;
  insets.left = -5;
  button.contentEdgeInsets = insets;
  [button setImage:img forState:UIControlStateNormal];
  [button addTarget:pTarget action:pSelector forControlEvents:UIControlEventTouchUpInside];
  if (pDivider) {
    button = [self addDividerToView:button height:pHeight];
  }
  
  return [[ATGBarButtonItem alloc] initWithCustomView:button];
}

+ (ATGBarButton *) addDividerToView:(UIView *)pView height:(CGFloat)pHeight {
  UIImage *dividerImg = [UIImage imageNamed:NavBarDividerImageName];
  UIImageView *dividerView = [[UIImageView alloc] initWithFrame:CGRectMake(pView.frame.size.width, 0, dividerImg.size.width, pHeight)];
  dividerView.clipsToBounds = YES;
  dividerView.contentMode = UIViewContentModeScaleAspectFit;
  dividerView.image = dividerImg;
  ATGBarButton *buttonWithDivider = [[ATGBarButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                                   pView.frame.size.width + dividerView.frame.size.width,
                                                                                   pHeight)];
  [buttonWithDivider addSubview:pView];
  [buttonWithDivider addSubview:dividerView];
  return buttonWithDivider;
}

#pragma mark - Instance Management

- (id) initWithTarget:(id)pTarget styleName:(NSString*) pStyleName action:(SEL)pAction {
  self = [self initWithIcon:nil title:nil
                 badgeValue:0 styleName: pStyleName target:pTarget action:pAction];
  return self;
}

- (id) initWithIcon:(UIImage *)pIcon title:(NSString *)pTitle badgeValue:(NSInteger)pBadgeValue
              styleName:(NSString*) pStyleName target:(id)pTarget action:(SEL)pAction {
  ATGBarButton *button = [[ATGBarButton alloc] init];
  [button setImage:pIcon forState:UIControlStateNormal];
  [button setTitle:pTitle forState:UIControlStateNormal];
  [[button titleLabel] setFont:[UIFont systemFontOfSize:14]];
  [button addTarget:pTarget action:pAction forControlEvents:UIControlEventTouchUpInside];
  if (pStyleName)
    [button applyStyleWithName:pStyleName];
  self = [super initWithCustomView:button];
  if (self) {
    mBadgeValue = pBadgeValue;
    [button setBadgeValue:pBadgeValue];
  }
  return self;
}

- (void)setPopover:(UIPopoverController *)pPopover {
  if (self.popover) {
    [self.popover dismissPopoverAnimated:YES];
  }
  _popover = pPopover;
}

#pragma mark - ATGBarButtonItem

- (void) setBadgeValue:(NSInteger)pBadgeValue {
  mBadgeValue = pBadgeValue;
  [(ATGBarButton *)[self customView] setBadgeValue:pBadgeValue];
  [[self customView] setNeedsLayout];
}

- (NSInteger) badgeValue {
  return mBadgeValue;
}

@end