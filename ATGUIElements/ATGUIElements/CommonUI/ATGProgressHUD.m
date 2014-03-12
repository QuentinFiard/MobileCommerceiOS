/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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

#import "ATGProgressHUD.h"

static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 16.f;
static const CGFloat kDetailsLabelFontSize = 12.f;

#pragma mark - ATGProgressHUD private interface declaration
#pragma mark -
@interface ATGProgressHUD ()
{
  BOOL useAnimation;
  CGAffineTransform rotationTransform;
  UILabel *label;
}

#pragma mark - Private methods
- (void)      registerForKVO;
- (void)      unregisterFromKVO;
- (NSArray *) observableKeypaths;
- (void)      updateUIForKeypath:(NSString *)keyPath;
- (void)      setupLabels;
- (void)      registerForNotifications;
- (void)      unregisterFromNotifications;
- (void) hideUsingAnimation:(BOOL)animated;
- (void) showUsingAnimation:(BOOL)animated;
- (void)      done;
- (void)      updateIndicators;
- (void) setTransformForCurrentOrientation:(BOOL)animated;
- (void) deviceOrientationDidChange:(NSNotification *)notification;
- (void) hideDelayed:(NSNumber *)animated;

#pragma mark - Custom properties
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, assign) CGSize size;

@end

#pragma mark - ATGProgressHUD implementation
#pragma mark -
@implementation ATGProgressHUD

#pragma mark - Class methods
+ (ATGProgressHUD *) showHUDAddedTo:(UIView *)pView animated:(BOOL)pAnimated {
  ATGProgressHUD *hud = [[ATGProgressHUD alloc] initWithView:pView];
  [pView addSubview:hud];
  [hud show:pAnimated];
  return hud;
}

#pragma mark - Lifecycle

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    /// Set default values for properties
    self.labelText = nil;
    self.opacity = 0.8f;
    self.color = nil;
    self.labelFont = [UIFont boldSystemFontOfSize:kLabelFontSize];
    self.xOffset = 0.0f;
    self.yOffset = 0.0f;
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                            | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.0f;

    rotationTransform = CGAffineTransformIdentity;

    [self setupLabels];
    [self updateIndicators];
    [self registerForKVO];
    [self registerForNotifications];
  }
  return self;
}

- (id) initWithView:(UIView *)pView {
  NSAssert(pView, @"View must not be nil.");
  id me = [self initWithFrame:pView.bounds];
  // We need to take care of rotation ourselves if we're adding the HUD to a window
  if ([pView isKindOfClass:[UIWindow class]]) {
    [self setTransformForCurrentOrientation:NO];
  }
  return me;
}

- (id) initWithWindow:(UIWindow *)pWindow {
  return [self initWithView:pWindow];
}

- (void) dealloc {
  [self unregisterFromNotifications];
  [self unregisterFromKVO];
}

#pragma mark - Show & hide methods

- (void) show:(BOOL)pAnimated {
  useAnimation = pAnimated;
  [self setNeedsDisplay];
  [self showUsingAnimation:useAnimation];
}

- (void) hide:(BOOL)pAnimated {
  useAnimation = pAnimated;
  [self hideUsingAnimation:useAnimation];
}

- (void) hide:(BOOL)pAnimated afterDelay:(NSTimeInterval)pDelay {
  [self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:pAnimated] afterDelay:pDelay];
}

- (void) hideDelayed:(NSNumber *)pAnimated {
  [self hide:[pAnimated boolValue]];
}

#pragma mark - Internal show & hide operations

- (void) showUsingAnimation:(BOOL)pAnimated {
  self.alpha = 0.0f;
  if (pAnimated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    self.alpha = 1.0f;
    [UIView commitAnimations];
  } else   {
    self.alpha = 1.0f;
  }
}

- (void) hideUsingAnimation:(BOOL)pAnimated {
  // Fade out
  if (pAnimated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.alpha = 0.02f;
    [UIView commitAnimations];
  } else   {
    self.alpha = 0.0f;
    [self done];
  }
}

- (void) animationFinished:(NSString *)pAnimationID finished:(BOOL)pFinished context:(void *)pContext {
  [self done];
}

- (void) done {
  self.alpha = 0.0f;
  if ([self.delegate respondsToSelector:@selector(hudWasHidden:)]) {
    [self.delegate performSelector:@selector(hudWasHidden:) withObject:self];
  }
  [self removeFromSuperview];
}

#pragma mark - UI
- (void) setupLabels {
  label = [[UILabel alloc] initWithFrame:self.bounds];
  label.adjustsFontSizeToFitWidth = NO;
  label.textAlignment = NSTextAlignmentCenter;
  label.opaque = NO;
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];
  label.font = self.labelFont;
  label.text = self.labelText;
  [self addSubview:label];
}

- (void) updateIndicators {
  BOOL isActivityIndicator = [self.indicator isKindOfClass:[UIActivityIndicatorView class]];
  BOOL isRoundIndicator = [self.indicator isKindOfClass:[ATGRoundProgressView class]];

  if (self.mode == ATGProgressHUDModeIndeterminate &&  !isActivityIndicator) {
    // Update to indeterminate indicator
    [self.indicator removeFromSuperview];
    self.indicator = [[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [(UIActivityIndicatorView *)self.indicator startAnimating];
    [self addSubview:self.indicator];
  } else if (self.mode == ATGProgressHUDModeDeterminate)   {
    if (!isRoundIndicator) {
      // Update to determinante indicator
      [self.indicator removeFromSuperview];
      self.indicator = [[ATGRoundProgressView alloc] init];
      [self addSubview:self.indicator];
    }
  } else if (self.mode == ATGProgressHUDModeCustomView && self.customView != self.indicator)   {
    // Update custom view indicator
    [self.indicator removeFromSuperview];
    self.indicator = self.customView;
    [self addSubview:self.indicator];
  } else if (self.mode == ATGProgressHUDModeText) {
    [self.indicator removeFromSuperview];
    self.indicator = nil;
  }
}

#pragma mark - Layout
- (void) layoutSubviews {
  // Entirely cover the parent view
  UIView *parent = self.superview;
  if (parent) {
    self.frame = parent.bounds;
  }
  CGRect bounds = self.bounds;

  // Determine the total width and height needed
  CGFloat maxWidth = bounds.size.width - 4 * self.margin;
  CGSize totalSize = CGSizeZero;

  CGRect indicatorF = self.indicator.bounds;
  indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
  totalSize.width = MAX(totalSize.width, indicatorF.size.width);
  totalSize.height += indicatorF.size.height;

  CGSize labelSize = [label.text sizeWithFont:label.font];
  labelSize.width = MIN(labelSize.width, maxWidth);
  totalSize.width = MAX(totalSize.width, labelSize.width);
  totalSize.height += labelSize.height;
  if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
    totalSize.height += kPadding;
  }

  totalSize.width += 2 * self.margin;
  totalSize.height += 2 * self.margin;

  // Position elements
  CGFloat yPos = roundf( ( (bounds.size.height - totalSize.height) / 2 ) ) + self.margin + self.yOffset;
  CGFloat xPos = self.xOffset;
  indicatorF.origin.y = yPos;
  indicatorF.origin.x = roundf( (bounds.size.width - indicatorF.size.width) / 2 ) + xPos;
  self.indicator.frame = indicatorF;
  yPos += indicatorF.size.height;

  if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
    yPos += kPadding;
  }
  CGRect labelF;
  labelF.origin.y = yPos;
  labelF.origin.x = roundf( (bounds.size.width - labelSize.width) / 2 ) + xPos;
  labelF.size = labelSize;
  label.frame = labelF;
  //yPos += labelF.size.height;

  // Enforce minsize and square rules
  CGFloat max = MAX(totalSize.width, totalSize.height);
  if (max <= bounds.size.width - 2 * self.margin) {
    totalSize.width = max;
  }
  if (max <= bounds.size.height - 2 * self.margin) {
    totalSize.height = max;
  }

  self.size = totalSize;
}

#pragma mark Background Drawing

- (void) drawRect:(CGRect)pRect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIGraphicsPushContext(context);

  if (self.dimBackground) {
    //Gradient colors
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {
      0.0f, 1.0f
    };
    CGFloat gradColors[8] = {
      0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    //Gradient center
    CGPoint gradCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    //Gradient radius
    float gradRadius = MIN(self.bounds.size.width, self.bounds.size.height);
    //Gradient draw
    CGContextDrawRadialGradient(context, gradient, gradCenter,
                                0, gradCenter, gradRadius,
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
  }

  // Set background rect color
  if (self.color) {
    CGContextSetFillColorWithColor(context, self.color.CGColor);
  } else {
    CGContextSetGrayFillColor(context, 0.0f, self.opacity);
  }


  // Center HUD
  CGRect allRect = self.bounds;
  // Draw rounded HUD background rect
  CGRect boxRect = CGRectMake(roundf( (allRect.size.width - self.size.width) / 2 ) + self.xOffset,
                              roundf( (allRect.size.height - self.size.height) / 2 ) + self.yOffset, self.size.width, self.size.height);
  float radius = 10.0f;
  CGContextBeginPath(context);
  CGContextMoveToPoint( context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) );
  CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
  CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
  CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
  CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);

  UIGraphicsPopContext();
}

#pragma mark - KVO

- (void) registerForKVO {
  for (NSString *keyPath in[self observableKeypaths]) {
    [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
  }
}

- (void) unregisterFromKVO {
  for (NSString *keyPath in[self observableKeypaths]) {
    [self removeObserver:self forKeyPath:keyPath];
  }
}

- (NSArray *) observableKeypaths {
  return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont", @"progress", nil];
}

- (void) observeValueForKeyPath:(NSString *)pKeyPath ofObject:(id)pObject change:(NSDictionary *)pChange context:(void *)pContext {
  if (![NSThread isMainThread]) {
    [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:pKeyPath waitUntilDone:NO];
  } else {
    [self updateUIForKeypath:pKeyPath];
  }
}

- (void) updateUIForKeypath:(NSString *)pKeyPath {
  if ([pKeyPath isEqualToString:@"mode"] || [pKeyPath isEqualToString:@"customView"]) {
    [self updateIndicators];
  } else if ([pKeyPath isEqualToString:@"labelText"]) {
    label.text = self.labelText;
  } else if ([pKeyPath isEqualToString:@"labelFont"]) {
    label.font = self.labelFont;
  } else if ([pKeyPath isEqualToString:@"progress"]) {
    if ([self.indicator respondsToSelector:@selector(setProgress:)]) {
      [(id)self.indicator setProgress:self.progress];
    }
    return;
  }
  [self setNeedsLayout];
  [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void) registerForNotifications {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(deviceOrientationDidChange:)
             name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) unregisterFromNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) deviceOrientationDidChange:(NSNotification *)notification {
  UIView *superview = self.superview;
  if (!superview) {
    return;
  } else if ([superview isKindOfClass:[UIWindow class]]) {
    [self setTransformForCurrentOrientation:YES];
  } else {
    self.bounds = self.superview.bounds;
    [self setNeedsDisplay];
  }
}

- (void) setTransformForCurrentOrientation:(BOOL)pAnimated {
  // Stay in sync with the superview
  if (self.superview) {
    self.bounds = self.superview.bounds;
    [self setNeedsDisplay];
  }

  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  CGFloat radians = 0;
  if ( UIInterfaceOrientationIsLandscape(orientation) ) {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
      radians = -(CGFloat)M_PI_2;
    } else                                                                                         {
      radians = (CGFloat)M_PI_2;
    }
    // Window coordinates differ!
    self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
  } else {
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
      radians = (CGFloat)M_PI;
    } else                                                                                           {
      radians = 0;
    }
  }
  rotationTransform = CGAffineTransformMakeRotation(radians);

  if (pAnimated) {
    [UIView beginAnimations:nil context:nil];
  }
  [self setTransform:rotationTransform];
  if (pAnimated) {
    [UIView commitAnimations];
  }
}

@end

#pragma mark - ATGRoundProgressView implementation
#pragma mark -
@implementation ATGRoundProgressView {
  float _progress;
}

#pragma mark - Accessors

- (float) progress {
  return _progress;
}

- (void) setProgress:(float)pProgress {
  _progress = pProgress;
  [self setNeedsDisplay];
}

#pragma mark - Lifecycle

- (id) init {
  return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    _progress = 0.f;
  }
  return self;
}

#pragma mark - Drawing

- (void) drawRect:(CGRect)pRect {
  CGRect allRect = self.bounds;
  CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
  CGContextRef context = UIGraphicsGetCurrentContext();
  // Draw background
  CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);   // white
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.1f);   // translucent white
  CGContextSetLineWidth(context, 2.0f);
  CGContextFillEllipseInRect(context, circleRect);
  CGContextStrokeEllipseInRect(context, circleRect);
  // Draw progress
  CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
  CGFloat radius = (allRect.size.width - 4) / 2;
  CGFloat startAngle = -( (float)M_PI / 2 );  // 90 degrees
  CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);   // white
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);
}

@end