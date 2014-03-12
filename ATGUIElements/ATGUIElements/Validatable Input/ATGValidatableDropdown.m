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

#import "ATGValidatableDropdown.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>

/*
 ******************* NOTE ********************
   This class does not use Automatic Reference Counting. To enable ARC, remove the
   "-fno-objc-arc" compiler flag from the Compile Sources Build Phase for the
   project.
 */

#pragma mark - ATGValidatableDropdown Private Protocol
#pragma mark -

@interface ATGValidatableDropdown ()

@property (nonatomic, readwrite, strong) UILabel *messageLabel;

#pragma mark - UI Event Handlers

- (void) handleTapRecognizer:(UITapGestureRecognizer *)recognizer;

@end

#pragma mark - ATGValidatableDropdown Implementation
#pragma mark -

@implementation ATGValidatableDropdown

#pragma mark - Instance Management

- (void) doAdditionalInit {
  // Dropdown should display an arrow image next to the input field.
  arrowImageView = [[UIImageView alloc] initWithImage:[UIImage locateImageNamed:@"icon-storeCell-more"]];
  [arrowImageView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *recognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
  [arrowImageView addGestureRecognizer:recognizer];
  [recognizer release];
  [arrowImageView setBackgroundColor:[UIColor whiteColor]];
  [arrowImageView setContentMode:UIViewContentModeCenter];

  CGRect imageFrame = [arrowImageView bounds];
  CGRect viewFrame = CGRectMake(0, 0, 100, 45);
  // Create an actual view to be used as right overlay view.
  UIView *rightView = [[UIView alloc] initWithFrame:viewFrame];
  [rightView setBackgroundColor:[UIColor clearColor]];
  [rightView addSubview:arrowImageView];
  // Layout everything properly.
  [arrowImageView setFrame:CGRectMake(0, 0, imageFrame.size.width + 20, viewFrame.size.height)];
  [arrowImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
   UIViewAutoresizingFlexibleHeight];
  UIView *previousRightView = [self rightView];
  // We've overridden the setRightView: in the superclass, so we have to call UITextField's implementation.
  struct objc_super uiFieldSpec = {
    self, [UITextField class]
  };
  objc_msgSendSuper(&uiFieldSpec, @selector(setRightView:), rightView);
  // When calling the setRightView: method, UITextField removes mMessageLabel from its superview,
  // as it was previous right overlay view. So mMessageLabel should be added to the container view
  // only when the right view is set.
  [rightView addSubview:previousRightView];
  [previousRightView setFrame:CGRectMake(imageFrame.size.width + 20, 0, viewFrame.size.width - imageFrame.size.width - 20, viewFrame.size.height)];
  [rightView release];
  [previousRightView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
}

- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    [self doAdditionalInit];
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    [self doAdditionalInit];
  }
  return self;
}

- (void) dealloc {
  [arrowImageView release];
  [super dealloc];
}

#pragma mark - UITextField

- (CGRect) textRectForBounds:(CGRect)pBounds {
  CGRect result = [super textRectForBounds:pBounds];
  result.size.width += [self borderWidth];
  return result;
}

- (CGRect) rightViewRectForBounds:(CGRect)pBounds {
  CGRect result = [super rightViewRectForBounds:pBounds];
  result.origin.x -= [arrowImageView bounds].size.width + [self borderWidth];
  result.size.width += [arrowImageView bounds].size.width + [self borderWidth];
  return result;
}

#pragma mark - ATGValidatableInput

- (void) invalidate:(NSString *)pMessage {
  [CATransaction begin];
  // Animate the arrow image only if the input field is changing its validity.
  if ( ([pMessage length] * [[[self messageLabel] text] length] == 0) &&
       ([pMessage length] + [[[self messageLabel] text] length] > 0) ) {
    CABasicAnimation *imageFade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [imageFade setFromValue:[NSNumber numberWithFloat:0]];
    [imageFade setToValue:[NSNumber numberWithFloat:1]];
    [[arrowImageView layer] addAnimation:imageFade forKey:@"fade"];
  }
  [super invalidate:pMessage];
  [CATransaction commit];
}

#pragma mark - UI Event Handlers

- (void) handleTapRecognizer:(UITapGestureRecognizer *)pRecognizer {
  if ([pRecognizer state] == UIGestureRecognizerStateEnded) {
    [self becomeFirstResponder];
  }
}

@end