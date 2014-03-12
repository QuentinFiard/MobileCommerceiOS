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

#import "EMPageControl.h"
#import "UIView+Layout.h"

// TODO: this needs reimplementing without using Three20 styles - could be that you can specify the normal and current dots as UIImages, or as UIColors, or both (with UIImages overriding colors maybe?)

@implementation EMPageControl

@synthesize numberOfPages       = _numberOfPages;
@synthesize currentPage         = _currentPage;
//@synthesize dotStyle            = _dotStyle;
@synthesize hidesForSinglePage  = _hidesForSinglePage;



- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
//    self.dotStyle = @"pageDot:";
    self.hidesForSinglePage = NO;
    self.contentMode = UIViewContentModeRedraw;
  }

  return self;
}




#pragma mark -
#pragma mark Properties


//- (TTStyle*)normalDotStyle {
//  if (!_normalDotStyle) {
//    _normalDotStyle = [[[TTStyleSheet globalStyleSheet] styleWithSelector:_dotStyle
//                                                        forState:UIControlStateNormal] retain];
//  }
//  return _normalDotStyle;
//}
//
//
//
//- (TTStyle*)currentDotStyle {
//  if (!_currentDotStyle) {
//    _currentDotStyle = [[[TTStyleSheet globalStyleSheet] styleWithSelector:_dotStyle
//                                                         forState:UIControlStateSelected] retain];
//  }
//  return _currentDotStyle;
//}


#pragma mark -
#pragma mark UIView


- (void)drawRect:(CGRect)rect {
//  if(_numberOfPages <= 1 && _hidesForSinglePage) {
//    return;
//  }
//
//  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
//  TTBoxStyle* boxStyle = [self.normalDotStyle firstStyleOfClass:[TTBoxStyle class]];
//
//  CGSize dotSize = [self.normalDotStyle addToSize:CGSizeZero context:context];
//
//  CGFloat dotWidth = dotSize.width + boxStyle.margin.left + boxStyle.margin.right;
//  CGFloat totalWidth = (dotWidth * _numberOfPages) - (boxStyle.margin.left + boxStyle.margin.right);
//  CGRect contentRect = CGRectMake(round(self.width/2 - totalWidth/2),
//                                  round(self.height/2 - dotSize.height/2),
//                                  dotSize.width, dotSize.height);
//
//  for (NSInteger i = 0; i < _numberOfPages; ++i) {
//    contentRect.origin.x += boxStyle.margin.left;
//
//    context.frame = contentRect;
//    context.contentFrame = contentRect;
//
//    if (i == _currentPage) {
//      [self.currentDotStyle draw:context];
//    } else {
//      [self.normalDotStyle draw:context];
//    }
//    contentRect.origin.x += dotSize.width + boxStyle.margin.right;
//  }
}


//- (CGSize)sizeThatFits:(CGSize)size {
//  TTStyleContext* context = [[[TTStyleContext alloc] init] autorelease];
//  CGSize dotSize = [self.normalDotStyle addToSize:CGSizeZero context:context];
//
//  CGFloat margin = 0;
//  TTBoxStyle* boxStyle = [self.normalDotStyle firstStyleOfClass:[TTBoxStyle class]];
//  if (boxStyle) {
//    margin = boxStyle.margin.right + boxStyle.margin.left;
//  }
//
//  return CGSizeMake((dotSize.width * _numberOfPages) + (margin * (_numberOfPages-1)),
//                    dotSize.height);
//}


#pragma mark -
#pragma mark UIControl


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  if (self.touchInside) {
    CGPoint point = [touch locationInView:self];

    if (point.x < self.width / 2) {
      self.currentPage = self.currentPage - 1;

    } else {
      self.currentPage = self.currentPage + 1;
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

#pragma mark -
#pragma mark Public


- (void)setNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages != _numberOfPages && numberOfPages >= 0) {

    _numberOfPages = MAX(0, numberOfPages);
    [self setNeedsDisplay];
  }
}



- (void)setCurrentPage:(NSInteger)currentPage {
  if (currentPage != _currentPage) {
    _currentPage = MAX(0, MIN(_numberOfPages - 1,currentPage));
    [self setNeedsDisplay];
  }
}

//- (void)setDotStyle:(NSString*)dotStyle {
//  if (![dotStyle isEqualToString:_dotStyle]) {
//    [_dotStyle release];
//    _dotStyle = [dotStyle copy];
//    TT_RELEASE_SAFELY(_normalDotStyle);
//    TT_RELEASE_SAFELY(_currentDotStyle);
//  }
//}


@end
