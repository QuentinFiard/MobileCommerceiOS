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
#import "ATGActionBlocker.h"

#pragma mark - ATGActionBlocker private interface declaration
#pragma mark -

@interface ATGActionBlocker ()

@property (nonatomic, readwrite, strong) UIView *backgroundView;
@property (nonatomic, readwrite, strong) UIView *view;
@property (nonatomic, readwrite, strong) UIView *baseView;
@property (nonatomic, readwrite, assign) SEL action;
@property (nonatomic, readwrite, weak) id target;
@property (nonatomic, readwrite, strong) void (^actionBlock)(void);

#pragma mark - Private methods
- (void) backgroundTouched:(UIGestureRecognizer *)recognizer;

@end

#pragma mark - ATGActionBlocker implementation
#pragma mark -

@implementation ATGActionBlocker

static ATGActionBlocker *sharedModalBlocker = nil;

#pragma mark - Class methods

+ (id) sharedModalBlocker {
  @synchronized(self) {
    if (sharedModalBlocker == nil) {
      sharedModalBlocker = [[ATGActionBlocker alloc] init];
    }
  }
  return sharedModalBlocker;
}

- (id) init {
  self = [super init];

  //init blocker view with base view and background view
  [self setBaseView:[[UIApplication sharedApplication] keyWindow]];
  [self setBackgroundView:[[UIView alloc] initWithFrame:[[self baseView] frame]]];
  //set color and transparency for blocker view
  self.bgColor = [UIColor blackColor];
  self.bgAlpha = 0.5f;
  [self backgroundView].opaque = YES;
  //set action on touch event
  UIGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
  [tapRecognizer setDelegate:self];
  [[self backgroundView] addGestureRecognizer:tapRecognizer];

  [[self backgroundView] addSubview:[self view]];

  return self;
}

#pragma mark - Public methods
- (void) showView:(UIView *)pView withTarged:(id)pTarget andAction:(SEL)pAction {
  //teardown previous state
  [self dismissBlockView];

  [self setView:pView];
  [self setTarget:pTarget];
  [self setAction:pAction];
  [self setBaseView:[[UIApplication sharedApplication] keyWindow]];
  [self setActionBlock:nil];

  //and view on blocker view
  [[self backgroundView] addSubview:[self view]];
  //block base view
  [[self baseView] addSubview:[self backgroundView]];
  [[self backgroundView] setFrame:[[self baseView] bounds]];
}

- (void) showBlockView:(UIView *)pView withFrame:(CGRect)pFrame withTarget:(id)pTarget andAction:(SEL)pAction forView:(UIView *)pBaseView {
  //teardown previous state
  [self dismissBlockView];

  [self setBaseView:pBaseView];
  [self setView:pView];
  [self setTarget:pTarget];
  [self setAction:pAction];
  [self setActionBlock:nil];

  [[self backgroundView] setFrame:pFrame];
  [[self backgroundView] addSubview:[self view]];
  [[self baseView] addSubview:[self backgroundView]];
}

- (void) showBlockView:(UIView *)pView withFrame:(CGRect)pFrame
           actionBlock:( void ( ^)(void) )pBlock forView:(UIView *)pBaseView {
  [self showBlockView:pView withFrame:pFrame withTarget:nil andAction:NULL
              forView:pBaseView];
  // Copy the block specified. This will move the block into the heap
  // preventing it from being destructed when end-of-block-scope is reached.
  [self setActionBlock:pBlock];
}

- (void) dismissBlockView {
  //remove view from block view
  [[self view] removeFromSuperview];
  [self setView:nil];
  [self setTarget:nil];
  [self setAction:nil];
  //unblock base view
  [[self backgroundView] removeFromSuperview];
  [self setBaseView:nil];
  [self setActionBlock:NULL];
}

- (void) setBGColor:(UIColor *)newColor {
  mBGColor = [newColor colorWithAlphaComponent:[self bgAlpha]];
  [self backgroundView].backgroundColor = [self bgColor];
}

- (UIColor *) bgColor {
  return mBGColor;
}

- (void) setBGAlpha:(float)newAlpha {
  mBGAlpha = newAlpha;
  [self backgroundView].backgroundColor = [[self bgColor] colorWithAlphaComponent:[self bgAlpha]];
}

- (float) bgAlpha {
  return mBGAlpha;
}

- (void) setFrame:(CGRect)frame {
  [self backgroundView].frame = frame;
}

- (CGRect) frame {
  return [self backgroundView].frame;
}

#pragma mark - Private mthods implementation
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)pRecognizer
        shouldReceiveTouch:(UITouch *)pTouch {
  return [pTouch view] == [self backgroundView];
}

- (void) backgroundTouched:(UIGestureRecognizer *)pRecognizer {
  if ([pRecognizer state] != UIGestureRecognizerStateEnded) {
    return;
  }
  if ([self target] && [self action] && [[self target] respondsToSelector:[self action]]) {
    // We have a target and action specified, call them.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [[self target] performSelector:[self action]];
#pragma clang diagnostic pop
  } else if ([self actionBlock]) {
    // Otherwise action block to be specified
    [self actionBlock]();
  }
}

#pragma mark -
#pragma mark Memory management
- (void) releaseMemory {
  sharedModalBlocker = nil;
}

@end