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

#import "ATGConfirmationPane.h"

static const CGFloat ATGMaskCornerRadius = 8;
static const CGFloat ATGShadowOffset = 5;
static const CGFloat ATGContentOffset = 10;

#pragma mark - ATGConfirmationPane private protocol declaration
#pragma mark - 

@interface ATGConfirmationPane ()

#pragma mark - Custom properties
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UILabel *captionLabel;

@end

#pragma mark - ATGConfirmationPane implemetation
#pragma mark -

@implementation ATGConfirmationPane
#pragma mark - Synthesized properties
@synthesize actionLabel, captionLabel;

- (id) initWithFrame:(CGRect)pContainerFrame {
  self = [super initWithFrame:pContainerFrame];
  if (self) {
    // Do not allow user interactions. This will propagate touches to action blocker.
    [self setUserInteractionEnabled:NO];
    // Clib all subviews to be located inside this container.
    [self setClipsToBounds:YES];
    // Apply some styling.
    [[self layer] setCornerRadius:ATGMaskCornerRadius];
    [[self layer] setBorderWidth:1];
    [[self layer] setBackgroundColor:[[UIColor messageBackgroundColor] CGColor]];
    [[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[self layer] setShadowOpacity:1];
    [[self layer] setShadowPath:[[UIBezierPath
                                  bezierPathWithRoundedRect:[self bounds]
                                               cornerRadius:ATGMaskCornerRadius]
                                 CGPath]];
    [[self layer] setShadowOffset:CGSizeMake(ATGShadowOffset, ATGShadowOffset)];

    // Caption, displayed on the top of confirmation pane.
    self.captionLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(ATGContentOffset, 0,
                                             pContainerFrame.size.width - ATGContentOffset * 2,
                                              pContainerFrame.size.height / 2)];
    [self.captionLabel applyStyleWithName:@"formTitleLabel"];
    [[self captionLabel] setBackgroundColor:[UIColor clearColor]];
    [[self captionLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self captionLabel] setTextColor:[UIColor whiteColor]];
    [self addSubview:[self captionLabel]];

    // White pane to be displayed at the bottom of the pane.
    UIView *delimiter = [[UIView alloc]
                         initWithFrame:CGRectMake(0, pContainerFrame.size.height / 2,
                                                  pContainerFrame.size.width,
                                                  pContainerFrame.size.height / 2)];
    [[delimiter layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[delimiter layer] setBorderWidth:1];
    [[delimiter layer] setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self addSubview:delimiter];

    // Label which emulates a button.
    self.actionLabel = [[UILabel alloc]
                   initWithFrame:CGRectMake(ATGContentOffset,
                                            pContainerFrame.size.height / 2 + 1,
                                            pContainerFrame.size.width - ATGContentOffset * 2,
                                            pContainerFrame.size.height / 2)];
    [self.actionLabel applyStyleWithName:@"formTitleLabel"];
    [self addSubview:[self actionLabel]];

    // Load an image with disclosure indicator.
    UIImage *image = [UIImage imageNamed:@"icon-arrowLEFT"];
    CGSize size = [image size];
    CGRect imageFrame = CGRectMake(pContainerFrame.size.width - ATGContentOffset - size.width,
                                   pContainerFrame.size.height / 2 + (pContainerFrame.size.height / 2 - size.height) / 2,
                                   size.width, size.height);
    // Image view with this disclosure.
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithFrame:imageFrame];
    [disclosureIndicator setImage:image];
    // Arrow is pointed left. Need to invert its direction.
    [disclosureIndicator setTransform:CGAffineTransformMakeScale(-1, 1)];
    [self addSubview:disclosureIndicator];
  }
  return self;
}

- (void) setButtonText:(NSString *)pText {
  [self actionLabel].text = pText;
}

- (void) setHeaderText:(NSString *)pText {
  [self captionLabel].text = pText;
}

@end