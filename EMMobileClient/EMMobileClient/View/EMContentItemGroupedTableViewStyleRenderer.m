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



#import "EMContentItemGroupedTableViewStyleRenderer.h"
#import <QuartzCore/QuartzCore.h>

#define DARK_GRAY_FILL [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0]
#define LIGHT_GRAY_FILL [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]
#define WHITE_FILL [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]
#define MIDDLE_WHITE_FILL [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0]
#define BRIGHT_WHITE_FILL [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0]
#define BLUE_HIGHLIGHT_FILL [UIColor colorWithRed:2.0/255.0 green:119.0/255.0 blue:240.0/255.0 alpha:1.0]

@implementation EMContentItemGroupedTableViewStyleRenderer
@synthesize style = _style;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundView = nil;
    self.selectedBackgroundView = nil;
  }
  return self;
}

- (void)setStyle:(EMCollectionViewGroupedTableCellStyle)style {
  _style = style;
  UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
  backgroundView.clipsToBounds = YES;
  UIView *sBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
  sBackgroundView.clipsToBounds = YES;
  
  if (self.style == EMCollectionViewGroupedTableCellStyleTop) {
    //draw the dark gray border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 52)
                                               cornerRadius:8.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the 1px thick light gray color under border (it is larger than 1px, but will be overlapped to appear 1px thick)
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 1, 298, 52)
                                               cornerRadius:8.0
                                            backgroundColor:LIGHT_GRAY_FILL]];
    //draw the fill white color
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 2, 298, 52)
                                               cornerRadius:8.0
                                            backgroundColor:WHITE_FILL]];
    //draw dark gray border, make it longer than 44 so it cuts off the bottom of the rounded rect.
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 52)
                                               cornerRadius:8.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw blue highlight color
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 1, 298, 52)
                                                cornerRadius:8.0
                                             backgroundColor:BLUE_HIGHLIGHT_FILL]];
  } else if (self.style == EMCollectionViewGroupedTableCellStyleMiddle) {
    //draw the dark gray border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 44)
                                               cornerRadius:0.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the 1px thick white color at top
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 0, 298, 44)
                                               cornerRadius:0.0
                                            backgroundColor:BRIGHT_WHITE_FILL]];
    //draw the white fill color
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 1, 298, 43)
                                               cornerRadius:0.0
                                            backgroundColor:WHITE_FILL]];
    //draw the dark gray border
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 44)
                                               cornerRadius:0.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the blue highlight
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 0, 298, 44)
                                                cornerRadius:0.0
                                             backgroundColor:BLUE_HIGHLIGHT_FILL]];
  } else if (self.style == EMCollectionViewGroupedTableCellStyleBottom) {
    //draw the dark gray border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 20)
                                               cornerRadius:0.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the white bottom border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, -6, 298, 50)
                                               cornerRadius:8.0
                                            backgroundColor:MIDDLE_WHITE_FILL]];
    //draw the dark gray border back over parts the white covered up
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 12, 300, 31)
                                               cornerRadius:8.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the white fill color
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, -6, 298, 48)
                                               cornerRadius:8.0
                                            backgroundColor:WHITE_FILL]];
    //draw a 1px white line at top of cell
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 0, 298, 1)
                                               cornerRadius:8.0
                                            backgroundColor:BRIGHT_WHITE_FILL]];
    //draw dark gray border
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 20)
                                                cornerRadius:0.0
                                             backgroundColor:DARK_GRAY_FILL]];
    //draw white border for bottom
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, -6, 298, 50)
                                                cornerRadius:8.0
                                             backgroundColor:MIDDLE_WHITE_FILL]];
    //draw gray back on parts white covered up
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 12, 300, 31)
                                                cornerRadius:8.0
                                             backgroundColor:DARK_GRAY_FILL]];
    //draw the blue highlight color
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, -6, 298, 49)
                                                cornerRadius:8.0
                                             backgroundColor:BLUE_HIGHLIGHT_FILL]];
  } else if (self.style == EMCollectionViewGroupedTableCellStyleTopBottom) {
    //draw the dark gray border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 43)
                                               cornerRadius:8.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the light gray line under border
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 1, 298, 40)
                                               cornerRadius:8.0
                                            backgroundColor:LIGHT_GRAY_FILL]];
    //draw the white border for bottom
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 20, 298, 24)
                                               cornerRadius:8.0
                                            backgroundColor:MIDDLE_WHITE_FILL]];
    //draw the dark gray parts back over the white
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 20, 300, 23)
                                               cornerRadius:8.0
                                            backgroundColor:DARK_GRAY_FILL]];
    //draw the white fill color
    [backgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 2, 298, 40)
                                               cornerRadius:8.0
                                            backgroundColor:WHITE_FILL]];
    //draw the dark gray border
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 0, 300, 43)
                                                cornerRadius:8.0
                                             backgroundColor:DARK_GRAY_FILL]];
    //draw the white border for the bottom
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 20, 298, 24)
                                                cornerRadius:8.0
                                             backgroundColor:MIDDLE_WHITE_FILL]];
    //draw back the gray border over parts of white
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(10, 20, 300, 23)
                                                cornerRadius:8.0
                                             backgroundColor:DARK_GRAY_FILL]];
    //draw the blue highlight fill
    [sBackgroundView addSubview:[self constructViewWithFrame:CGRectMake(11, 1, 298, 43)
                                                cornerRadius:8.0
                                             backgroundColor:BLUE_HIGHLIGHT_FILL]];
  }
  
  self.backgroundView = backgroundView;
  self.selectedBackgroundView = sBackgroundView;
}

- (UIView *)constructViewWithFrame:(CGRect)pFrame cornerRadius:(CGFloat)pRadius backgroundColor:(UIColor *)pColor {
  UIView *view = [[UIView alloc] initWithFrame:pFrame];
  view.layer.cornerRadius = pRadius;
  view.backgroundColor = pColor;
  return view;
}

@end

