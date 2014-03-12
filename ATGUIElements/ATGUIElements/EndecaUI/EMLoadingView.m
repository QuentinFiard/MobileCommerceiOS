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



#import "EMLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EMLoadingView

@synthesize loadingLabel = _loadingLabel, backgroundView = _backgroundView;

- (id) initWithFrame:(CGRect)frame {
	if (self = [self initWithFrame:frame loadingLabelStyle:UIActivityIndicatorViewStyleGray]) {
		
    }
    return self;
}

- (id) initWithFrame:(CGRect)pFrame loadingLabelStyle:(UIActivityIndicatorViewStyle)pStyle {
  if (self = [super initWithFrame:pFrame]) {
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
  
    self.backgroundView = [[UIView alloc] initWithFrame:pFrame];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0.2;
    [self addSubview:self.backgroundView];
  
    self.loadingLabel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:pStyle];
    self.loadingLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
    self.loadingLabel.frame = CGRectMake(roundf((self.bounds.size.width - (self.loadingLabel.bounds.size.width + 20))/2),roundf((self.bounds.size.height - (self.loadingLabel.bounds.size.height + 20))/2), self.loadingLabel.bounds.size.height + 20, self.loadingLabel.bounds.size.width + 20);
    self.loadingLabel.layer.cornerRadius = 8.0;
    [self addSubview:self.loadingLabel];
  }
  return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGRect loadingLabelBounds = self.loadingLabel.bounds;
    
    self.loadingLabel.frame = CGRectMake(roundf((bounds.size.width - (loadingLabelBounds.size.width))/2),roundf((bounds.size.height - (loadingLabelBounds.size.height))/2), loadingLabelBounds.size.height, loadingLabelBounds.size.width);
}

- (void)startAnimatingInView:(UIView *)pView {
    [pView addSubview:self];
    [self.loadingLabel startAnimating];
}

@end
