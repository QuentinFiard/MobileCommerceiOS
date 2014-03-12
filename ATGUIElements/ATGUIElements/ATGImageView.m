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
#import "ATGImageView.h"
#import <ATGMobileCommon/ATGPhotoManager.h>

#pragma mark - ATGImageView private interface declaration
#pragma mark -

@interface ATGImageView ()
/*!
   @method
   @abstract Aligns activity indicator view's center with this view's center
 */
- (void) alignIndicator;

@end

#pragma mark - ATGImageView implementation
#pragma mark -

@implementation ATGImageView
#pragma mark - Synthesized properties
@synthesize imageURL = _imageURL, indicator = _indicator, showsIndicator = _showsIndicator, blanksImage = _blanksImage, tapLayer = _tapLayer, operation = _operation;

#pragma mark - Lifecycle
- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.showsIndicator = YES;
    self.blanksImage = YES;
    self.tapLayer = [CALayer layer];
    self.tapLayer.backgroundColor = [UIColor grayColor].CGColor;
    self.tapLayer.opacity = 0.6;
    self.tapLayer.cornerRadius = 3.0;
    self.contentMode = UIViewContentModeScaleAspectFit;
  }
  return self;
}

- (id) initWithFrame:(CGRect)aFrame {
  self = [super initWithFrame:aFrame];
  if (self) {
    self.showsIndicator = YES;
    self.blanksImage = YES;
    self.tapLayer = [CALayer layer];
    self.tapLayer.backgroundColor = [UIColor grayColor].CGColor;
    self.tapLayer.opacity = 0.6;
    self.tapLayer.cornerRadius = 3.0;
    self.contentMode = UIViewContentModeScaleAspectFit;
  }
  return self;
}

- (id) initWithFrame:(CGRect)pFrame loadingImage:(NSString *)pImageURL {
  self = [self initWithFrame:pFrame];
  if (self) {
    self.imageURL = pImageURL;
  }
  return self;
}

- (void) awakeFromNib {
  [self startIndicator];
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self alignIndicator];
}

- (void) setIndicator:(UIActivityIndicatorView *)indicator {
  {
    if (_indicator != indicator) {
      [_indicator stopAnimating];
      [_indicator removeFromSuperview];

      _indicator = indicator;

      [self addSubview:_indicator];

      [self alignIndicator];
    }
  }
}

- (void) alignIndicator {
  _indicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void) stopIndicator {
  [_indicator stopAnimating];
}

- (void) startIndicator {
  if (_showsIndicator) {
    if (!_indicator) {
      _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      _indicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
      [self addSubview:_indicator];
    }

    [_indicator startAnimating];
  }
}

- (void) downloadImage {
  [self.operation cancel];
  DebugLog(@"Downloading image for url: %@", self.imageURL);
  
  void (^success)(id <ATGRestOperation> pOperation, id pResponseObject);
  
  success = ^(id < ATGRestOperation > pOperation, id pResponseObject) {
    [self stopIndicator];
    self.image = [UIImage imageWithData:pResponseObject];
  };
  
  void (^failure)(id <ATGRestOperation> pOperation, NSError *pError);
  
  failure =  ^(id <ATGRestOperation> pOperation, NSError *pError) {
    [self stopIndicator];
    DebugLog (@"Error occured: %@", [pError localizedFailureReason]);
  };

  self.operation = [ATGPhotoManager requestForAbsoluteImageURL:self.imageURL success:success failure:failure];
  
}


- (void) setImageURL:(NSString *)url {
  //release old value
  if ([[self imageURL] isEqualToString:url]) {
    // The value is not changed, so nothing should be done. Do not update internal state and
    // do not reload image from server.
    return;
  } else {
    _imageURL = url;
  }
  
  //reset old image
  if (self.blanksImage) {
    self.image = nil;
  }
  
  if (self.imageURL) {
    if ([self.imageURL rangeOfString:@"http"].length == 0) {
      if ([self.delegate respondsToSelector:@selector(absoluteURLForRelative:)]) {
        _imageURL = [self.delegate absoluteURLForRelative:url];
      }
    }
    
    [self startIndicator];
    //download image for view
    [self downloadImage];
  }
}

#pragma mark - Touches proccessing

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.tapLayer removeFromSuperlayer];
  self.tapLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self.layer addSublayer:self.tapLayer];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.tapLayer removeFromSuperlayer];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.tapLayer removeFromSuperlayer];
}

- (void) dealloc {
  [self.operation cancel];
  self.imageURL = nil;
  self.indicator = nil;
}

@end