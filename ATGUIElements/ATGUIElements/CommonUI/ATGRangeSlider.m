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



#import "ATGRangeSlider.h"

typedef enum {
  ATGRangeSliderTrackingStateNone = 0,
  ATGRangeSliderTrackingStateMin = 1,
  ATGRangeSliderTrackingStateMax = 2
} ATGRangeSliderTrackingState;

@interface ATGRangeSlider ()

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign) CGFloat minimumRange;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat distanceFromCenter;
@property (nonatomic, assign) ATGRangeSliderTrackingState currentTrackingState;


- (CGFloat)xForValue:(CGFloat)value;
- (CGFloat)valueForX:(CGFloat)x;
- (void)updateTrackHighlight;

@end

@implementation ATGRangeSlider
@synthesize selectedMinimumValue = _selectedMinimumValue, selectedMaximumValue = _selectedMaximumValue;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.currentTrackingState = ATGRangeSliderTrackingStateNone;
    
    self.selectedMinimumValue = 0.0;
    self.selectedMaximumValue = 1.0;
    self.minimumValue = 0.0;
    self.maximumValue = 1.0;
    
    UIImage *barBackground = [UIImage imageNamed:@"track-background"];
    self.trackBackground = [[UIImageView alloc] initWithImage:[barBackground resizableImageWithCapInsets:UIEdgeInsetsMake(0, barBackground.size.width/2.0, 0, barBackground.size.width/2.0)]];
    self.trackBackground.frame = CGRectMake(0, frame.size.height/2.0 - barBackground.size.height/2.0, frame.size.width, barBackground.size.height);
    [self addSubview:self.trackBackground];
    
    UIImage *trackHighlight = [UIImage imageNamed:@"track-highlight"];
    self.trackHighlighted = [[UIImageView alloc] initWithImage:[trackHighlight resizableImageWithCapInsets:UIEdgeInsetsMake(0, trackHighlight.size.width/2.0, 0, trackHighlight.size.width/2.0)]];
    self.trackHighlighted.center = self.center;
    [self addSubview:self.trackHighlighted];
    
    self.minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb"] highlightedImage:[UIImage imageNamed:@"thumb-highlight"]];
    [self addSubview:self.minThumb];
    
    self.maxThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb"] highlightedImage:[UIImage imageNamed:@"thumb-highlight"]];
    [self addSubview:self.maxThumb];
    
    self.minimumRange = (self.minThumb.frame.size.width + self.maxThumb.frame.size.width) / (2*frame.size.width);
    self.spacing = self.minThumb.frame.size.width/2.0;
  }
  
  return self;
}

- (void)setSelectedMinimumValue:(CGFloat)selectedMinimumValue {
  _selectedMinimumValue = MIN(MAX(selectedMinimumValue, self.minimumValue), self.maximumValue);
  [self layoutSubviews];
}

- (void)setSelectedMaximumValue:(CGFloat)selectedMaximumValue {
  _selectedMaximumValue = MAX(MIN(selectedMaximumValue, self.maximumValue), self.minimumValue);
  [self layoutSubviews];
}


- (void)layoutSubviews {
  [super layoutSubviews];
  self.minThumb.center = CGPointMake([self xForValue:self.selectedMinimumValue], self.frame.size.height/2.0);
  self.maxThumb.center = CGPointMake([self xForValue:self.selectedMaximumValue], self.frame.size.height/2.0);
  [self updateTrackHighlight];
}

- (CGFloat)xForValue:(CGFloat)value {
  return (self.frame.size.width-(self.spacing*2))*((value - self.minimumValue) / (self.maximumValue - self.minimumValue))+self.spacing;
}

- (CGFloat) valueForX:(CGFloat)x {
  return self.minimumValue + (x-self.spacing) / (self.frame.size.width-(self.spacing*2)) * (self.maximumValue - self.minimumValue);
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if(self.currentTrackingState == ATGRangeSliderTrackingStateNone) {
    return YES;
  }
  
  CGPoint touchPoint = [touch locationInView:self];
  if(self.currentTrackingState == ATGRangeSliderTrackingStateMin) {
    self.minThumb.center = CGPointMake(MAX([self xForValue:self.minimumValue],MIN(touchPoint.x - self.distanceFromCenter, [self xForValue:self.selectedMaximumValue - self.minimumRange])), self.minThumb.center.y);
    self.selectedMinimumValue = [self valueForX:self.minThumb.center.x];
    
  }
  if(self.currentTrackingState == ATGRangeSliderTrackingStateMax) {
    self.maxThumb.center = CGPointMake(MIN([self xForValue:self.maximumValue], MAX(touchPoint.x - self.distanceFromCenter, [self xForValue:self.selectedMinimumValue + self.minimumRange])), self.maxThumb.center.y);
    self.selectedMaximumValue = [self valueForX:self.maxThumb.center.x];
  }
  [self updateTrackHighlight];
  [self setNeedsLayout];
  
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  return YES;
}

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchPoint = [touch locationInView:self];
  
  if(CGRectContainsPoint(self.minThumb.frame, touchPoint)) {
    self.minThumb.highlighted = YES;
    self.currentTrackingState = ATGRangeSliderTrackingStateMin;
    self.distanceFromCenter = touchPoint.x - self.minThumb.center.x;
  }
  else if(CGRectContainsPoint(self.maxThumb.frame, touchPoint)) {
    self.maxThumb.highlighted = YES;
    self.currentTrackingState = ATGRangeSliderTrackingStateMax;
    self.distanceFromCenter = touchPoint.x - self.maxThumb.center.x;
    
  }
  return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  self.minThumb.highlighted = NO;
  self.maxThumb.highlighted = NO;
  if (self.currentTrackingState != ATGRangeSliderTrackingStateNone) {
    self.currentTrackingState = ATGRangeSliderTrackingStateNone;
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
  }
}

- (void)updateTrackHighlight{
  self.trackHighlighted.frame = CGRectMake(self.minThumb.center.x - self.spacing, (self.frame.size.height/2) - 5, self.maxThumb.center.x - self.minThumb.center.x + self.spacing * 2, self.trackHighlighted.frame.size.height);
}

@end

