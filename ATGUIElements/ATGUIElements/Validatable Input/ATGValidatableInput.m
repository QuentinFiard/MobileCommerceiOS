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

#import "ATGValidatableInput.h"
#import "ATGRequiredValidator.h"
#import <QuartzCore/QuartzCore.h>
#import <ATGMobileCommon/NSObject+ATGAdditions.h>

#pragma mark - ATGValidatableInput Private Protocol
#pragma mark -

// Private interface, it defines properties/methods which should not be exposed to class users.
@interface ATGValidatableInput ()

// Internal property, do not expose it.
@property (nonatomic, readwrite, assign) CGRect rightViewRect;
@property (nonatomic, readwrite, strong) id<UITextFieldDelegate> innerDelegate;
@property (nonatomic, readwrite, strong) NSMutableArray *validators;
@property (nonatomic, readwrite, weak) UIView *underlay;
@property (nonatomic, readwrite, weak) UIImageView *backgroundImageView;
@property (nonatomic, readwrite, weak) id<UITextFieldDelegate> outerDelegate;
@property (nonatomic, readwrite, weak) UILabel *messageLabel;

- (BOOL) isRightViewRectHidden;

@end

#pragma mark - ATGValidatableInputLayer
#pragma mark -

// ATGValidatableInput will use this class as its backing layer.
@interface ATGValidatableInputLayer : CALayer

@property (nonatomic, readwrite, assign) CGRect rightViewRect;

@end

#pragma mark - ATGValidatableInputDelegate
#pragma mark -

// ATGValidatableInput will use this class as its delegate.
@interface ATGValidatableInputDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, readwrite, weak) ATGValidatableInput *input;

// Simple init method.
- (id) initWithValidatableInput:(ATGValidatableInput *)pInput;

@end

#pragma mark - ATGValidatableInputLayer Implementation
#pragma mark -

@implementation ATGValidatableInputLayer

#pragma mark - CALayer

+ (BOOL) needsDisplayForKey:(NSString *)pKey {
  if ([@"rightViewRect" isEqualToString:pKey]) {
    // Re-draw self if the 'rightViewRect' property has changed.
    return YES;
  }
  return [super needsDisplayForKey:pKey];
}

#pragma mark - Instance Management

- (id) initWithLayer:(id)pLayer {
  self = [super initWithLayer:pLayer];
  if (self && [pLayer isKindOfClass:[ATGValidatableInputLayer class]]) {
    [self setRightViewRect:[(ATGValidatableInputLayer *) pLayer rightViewRect]];
  }
  return self;
}

@end

#pragma mark - ATGValidatableInputDelegate Implementation
#pragma mark -

@implementation ATGValidatableInputDelegate

#pragma mark - Instance Management

- (id) initWithValidatableInput:(ATGValidatableInput *)pInput {
  self = [super init];
  if (self) {
    [self setInput:pInput];
  }
  return self;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)pTextField {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    return [[[self input] delegate] textFieldShouldBeginEditing:pTextField];
  }
  return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)pTextField {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    [[[self input] delegate] textFieldDidBeginEditing:pTextField];
  }
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)pTextField {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    return [[[self input] delegate] textFieldShouldEndEditing:pTextField];
  }
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)pTextField {
  [[self input] validate];
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    [[[self input] delegate] textFieldDidEndEditing:pTextField];
  }
}

- (BOOL) textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
 replacementString:(NSString *)pString {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    return [[[self input] delegate] textField:pTextField shouldChangeCharactersInRange:pRange
                      replacementString:pString];
  }
  return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)pTextField {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    return [[[self input] delegate] textFieldShouldClear:pTextField];
  }
  return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)pTextField {
  if ([[[self input] delegate] respondsToSelector:_cmd]) {
    return [[[self input] delegate] textFieldShouldReturn:pTextField];
  }
  return YES;
}

@end

#pragma mark - ATGValidatableInput Implementation
#pragma mark -

@implementation ATGValidatableInput

#pragma mark - Custom Properties

- (void) setValue:(id)pValue {
  if ([pValue isKindOfClass:[NSString class]]) {
    [self setText:pValue];
  }
}

- (id) value {
  return [self text];
}

#pragma mark - CALayer

+ (Class) layerClass {
  return [ATGValidatableInputLayer class];
}

#pragma mark - Instance Management

- (void) doAdditionalInitialization {
  // Default instance values.
  [self setBorderWidth:5];
  [self setErrorWidthFraction:.35];

  // An array to hold all validators.
  [self setValidators:[[NSMutableArray alloc] init]];

  // By default, all inputs are required.
  ATGRequiredValidator *validator = [[ATGRequiredValidator alloc] init];
  [[self validators] addObject:validator];

  // Necessary appearance tweaking.
  [self setBorderStyle:UITextBorderStyleNone];
  [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];

  // Create a white underlay to be displayed under the input text.
  // This will make input field opaque.
  CGRect bounds = [self bounds];
  UIView *underlay = [[UIView alloc] initWithFrame:CGRectMake([self borderWidth], [self borderWidth],
                                                       bounds.size.width - 2 * [self borderWidth],
                                                       bounds.size.height - 2 * [self borderWidth])];
  // Do not catch user touches with this underlay.
  [underlay setUserInteractionEnabled:NO];
  [underlay setBackgroundColor:[UIColor whiteColor]];
  // Display this underlay at the very bottom.
  [self insertSubview:underlay atIndex:0];
  [self setUnderlay:underlay];

  // Create a UILabel displaying an error message.
  UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  // Make it transparent, as UITextField is transparent itself.
  [messageLabel setBackgroundColor:[UIColor clearColor]];
  // We're overriding a setRigthView: method, so use super-implementation.
  [super setRightView:messageLabel];
  [self setMessageLabel:messageLabel];
  if ([self isPad]) {
    [super setRightViewMode:UITextFieldViewModeUnlessEditing];
  } else {
    [self setRightViewMode:UITextFieldViewModeAlways];
  }
  [messageLabel applyStyleWithName:@"validationErrorTextLabel"];
  [messageLabel setNumberOfLines:0];
  [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [messageLabel setTextAlignment:NSTextAlignmentCenter];

  // Background image, it will be used when rendering self inside of a UITableViewCell.
  UIImageView *background = [[UIImageView alloc] initWithFrame:[self bounds]];
  [self insertSubview:background atIndex:0];
  [self setBackgroundImageView:background];

  // Create a separate instance of UITextFieldDelegate. It appears that UITextField
  // can not be a delegate of self (it causes an infinite recursion at some points).
  [self setInnerDelegate:[[ATGValidatableInputDelegate alloc] initWithValidatableInput:self]];
  // We're overriding a setDelegate: method, so assign an actual input delegate with super-implementation.
  [super setDelegate:[self innerDelegate]];

  // Listen for important property changes to re-layout self when needed.
  [[self layer] addObserver:self forKeyPath:@"cornerRadius"
                    options:NSKeyValueObservingOptionNew context:NULL];
  [self addObserver:self forKeyPath:@"errorWidthFraction"
            options:NSKeyValueObservingOptionNew context:NULL];
  [self addObserver:self forKeyPath:@"borderWidth"
            options:NSKeyValueObservingOptionNew context:NULL];
}

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    [self doAdditionalInitialization];
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    [self doAdditionalInitialization];
  }
  return self;
}

- (void) dealloc {
  // It's important to de-register self from listeneing property changes.
  // Otherwise the system will not be able to deallocate an input field instance.
  [[self layer] removeObserver:self forKeyPath:@"cornerRadius"];
  [self removeObserver:self forKeyPath:@"errorWidthFraction"];
  [self removeObserver:self forKeyPath:@"borderWidth"];
  // Now it's safe to deallocate everything.
}

#pragma mark - NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)pKeyPath ofObject:(id)pObject
                         change:(NSDictionary *)pChange context:(void *)pContext {
  if ([@"cornerRadius" isEqualToString:pKeyPath]) {
    CGFloat radius = [[pChange objectForKey:NSKeyValueChangeNewKey] floatValue];
    UIView *leftView = [[UIView alloc] initWithFrame:[self leftViewRectForBounds:[self bounds]]];
    [leftView setBackgroundColor:[UIColor whiteColor]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:[leftView bounds]
                                               byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                     cornerRadii:CGSizeMake(radius - [self borderWidth],
                                                 radius - [self borderWidth])];
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setBackgroundColor:[[UIColor colorWithWhite:1 alpha:1] CGColor]];
    [mask setPath:[path CGPath]];
    [[leftView layer] setMask:mask];
    [super setLeftView:leftView];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    [self setNeedsLayout];
  } else if ([@"errorWidthFraction" isEqualToString:pKeyPath] || [@"borderWidth" isEqualToString:pKeyPath]) {
    [self setNeedsLayout];
  }
}

#pragma mark - UIAccessibility

- (BOOL)accessibilityElementsHidden {
  return YES;
}

- (BOOL)isAccessibilityElement {
  return YES;
}

- (NSString *) accessibilityValue {
  if ([[[self messageLabel] text] length] == 0) {
    return [super accessibilityValue];
  }
  NSString *value = [super accessibilityValue];
  return [NSString stringWithFormat:@"%@. %@", value, [[self messageLabel] text]];
}

- (NSString *)accessibilityLabel {
  if ([[self leftView] isAccessibilityElement]) {
    return [[self leftView] accessibilityLabel];
  } else {
    return [super accessibilityLabel];
  }
}

#pragma mark - UITextField

- (CGRect) textRectForBounds:(CGRect)pBounds {
  CGRect leftViewRect = [self leftViewRectForBounds:pBounds];
  CGRect rightViewRect = [self rightViewRectForBounds:pBounds];
  if ( CGRectEqualToRect([self rightViewRect], CGRectZero) ) {
    // It's the first time we're calculating text bounds. Initialize the backing layer with proper value.
    [(ATGValidatableInputLayer *)[self layer] setRightViewRect:rightViewRect];
  } else {
    rightViewRect = [self rightViewRect];
  }
  return CGRectMake(leftViewRect.origin.x + leftViewRect.size.width, [self borderWidth],
                    rightViewRect.origin.x - leftViewRect.origin.x - leftViewRect.size.width - [self borderWidth],
                    pBounds.size.height - 2 * [self borderWidth]);
}

- (CGRect) editingRectForBounds:(CGRect)pBounds {
  // Edit text in the same area as displaying it.
  return [self textRectForBounds:pBounds];
}

- (CGRect) leftViewRectForBounds:(CGRect)pBounds {
  CGRect leftViewFrame = [[self leftView] frame];
  return CGRectMake(10, [self borderWidth],
                    leftViewFrame.size.width, pBounds.size.height - 2 * [self borderWidth]);
}

- (CGRect) rightViewRectForBounds:(CGRect)pBounds {
  CGFloat width = [[[self messageLabel] text] length] == 0 ? 0 :
                  (pBounds.size.width - 2 * [self borderWidth]) * [self errorWidthFraction];
  if ([self isRightViewRectHidden]) {
    width = 0;
  }
  return CGRectMake(pBounds.size.width - width - [self borderWidth], [self borderWidth],
                    width, pBounds.size.height - 2 * [self borderWidth]);
}

- (void) setDelegate:(id <UITextFieldDelegate>)pDelegate {
  // Do not update actual input field's delegate. It should always be our custom implementation.
  [self setOuterDelegate:pDelegate];
}

- (id <UITextFieldDelegate>) delegate {
  // Expose the delegate previously set by the setDelegate: method.
  return [self outerDelegate];
}

- (void) setRightView:(UIView *)pRightView {
  // Ignore this view.
}

- (UIView *) rightView {
  return nil;
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];
  CGRect textRect = [self textRectForBounds:[self bounds]];
  CGRect underlayFrame = CGRectMake([self borderWidth], [self borderWidth],
                                    textRect.origin.x + textRect.size.width - [self borderWidth],
                                    textRect.size.height);
  [[self underlay] setFrame:underlayFrame];
  [[self backgroundImageView] setFrame:[self bounds]];
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  CGSize maxSize = [self rightViewRectForBounds:[self bounds]].size;
  maxSize.height = CGFLOAT_MAX;
  CGSize requiredSize = CGSizeZero;
  if ([[self messageLabel] text]) {
    requiredSize = [[[self messageLabel] text] sizeWithFont:[[self messageLabel] font]
                                          constrainedToSize:maxSize
                                              lineBreakMode:[[self messageLabel] lineBreakMode]];
  }
  return CGSizeMake(pSize.width, MAX(pSize.height, requiredSize.height + 2 * [self borderWidth]));
}

#pragma mark - ATGValidatableInput

- (void) addValidator:(id <ATGInputValidator>)pValidator {
  [[self validators] addObject:pValidator];
}

- (void) removeAllValidators {
  [[self validators] removeAllObjects];
}

- (BOOL) validate {
  if ([self isFirstResponder]) {
    // UITextField contains a private instance of UIFieldEdit as its subview.
    // For some reason this edit field tries to render self in context of WEB thread.
    // However, while rendering custom ATGValidatableInputLayer we perfomr a layout process
    // (it's part of UIKit so it's illegal to layout views from the WEB thread).
    // That's why we have to resign first responder. This will remove the UIFieldEdit from
    // input's subviews collection.
    // validate method will be called again during the resignFirstResponder call,
    // so everything will be set when the resignFirstResponder method returns.
    [self resignFirstResponder];
    return [[[self messageLabel] text] length] == 0;
  }
  // All validators must not report error for the value to be correct.
  for (id <ATGInputValidator> validator in [self validators]) {
    NSError *error = [validator validateValue:[self value]];
    if (error) {
      // Got an error! save the message and quit validating.
      [self invalidate:[error localizedDescription]];
      return NO;
    }
  }
  [self invalidate:nil];
  return YES;
}

- (void) invalidate:(NSString *)pMessage {
  BOOL valid = [pMessage length] == 0;
  NSString *transitionSubtype =
    [[[self messageLabel] text] length] == 0 ? kCATransitionFromRight : kCATransitionFromLeft;
  BOOL messageChanged = ![[[self messageLabel] text] isEqualToString:pMessage];
  [self setNeedsLayout];
  [CATransaction begin];

  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rightViewRect"];
  [animation setFromValue:[NSValue valueWithCGRect:[self rightViewRectForBounds:[self bounds]]]];
  [[self messageLabel] setText:pMessage];
  [animation setToValue:[NSValue valueWithCGRect:[self rightViewRectForBounds:[self bounds]]]];
  [[self layer] addAnimation:animation forKey:@"resize"];
  [(ATGValidatableInputLayer *)[self layer] setRightViewRect:[self rightViewRectForBounds:[self bounds]]];

  if (messageChanged) {
    CATransition *messagePush = [CATransition animation];
    [messagePush setType:kCATransitionPush];
    [messagePush setSubtype:transitionSubtype];
    [[[self messageLabel] layer] addAnimation:messagePush forKey:@"appear"];
  }

  CABasicAnimation *backgroundColor = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
  [backgroundColor setToValue:(id)[(valid ? [UIColor clearColor]:[UIColor errorColor])CGColor]];
  [[self layer] addAnimation:backgroundColor forKey:@"background"];
  [self setBackgroundColor:valid ? [UIColor clearColor]:[UIColor errorColor]];

  [CATransaction commit];
}

#pragma mark - Private Protocol Implementation

- (BOOL) isRightViewRectHidden {
  switch ([self rightViewMode]) {
  case UITextFieldViewModeNever :
    return YES;

  case UITextFieldViewModeAlways :
    return NO;

  case UITextFieldViewModeUnlessEditing:
    return [self isEditing];

  case UITextFieldViewModeWhileEditing:
    return ![self isEditing];
  }
}

@end