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

#import <ATGUIElements/ATGImageView.h>
#import "ATGHomeCarouselPromoCell.h"
#import "ATGRestManager.h"
#import "UIDevice+ATGAdditions.h"

@interface ATGHomeCarouselPromoCell ()
  @property (nonatomic, readwrite, strong) ATGImageView *heroImage;
  @property (nonatomic, readwrite, strong) ATGImageView *promoImage;
@end

@implementation ATGHomeCarouselPromoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setIsAccessibilityElement:YES];
      self.accessibilityLabel = NSLocalizedStringWithDefaultValue
        (@"ATGCHeroView.ItemAccessibilityLabel", nil, [NSBundle mainBundle],
        @"Promotional item", @"Promotional item accessibility label.");
      self.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGHeroView.ItemAccessibilityHint", nil,
        [NSBundle mainBundle], @"Slide to change promotional product", @"Promotional item accessibility hint.");

      CGRect imageFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
      self.frame = imageFrame;

      // Create the hero image
      self.heroImage = [[ATGImageView alloc] initWithFrame:imageFrame];
      self.heroImage.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
      self.heroImage.autoresizesSubviews = YES;
      self.heroImage.translatesAutoresizingMaskIntoConstraints = NO;
      if ([UIDevice isPhone])
        self.heroImage.contentMode = UIViewContentModeScaleAspectFit;
      else
        self.heroImage.contentMode = UIViewContentModeCenter;

      // Create the promotion text image
      self.promoImage = [[ATGImageView alloc] initWithFrame:imageFrame];
      //indicator for promo to continue indicating, when hero already loaded
      self.promoImage.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
      self.promoImage.autoresizesSubviews = YES;
      self.promoImage.translatesAutoresizingMaskIntoConstraints = NO;
      if ([UIDevice isPhone])
        self.promoImage.contentMode = UIViewContentModeScaleAspectFit;
      else
        self.promoImage.contentMode = UIViewContentModeCenter;

      [self.contentView addSubview:self.heroImage];
      [self.contentView addSubview:[self promoImage]];

      // Add the visual constrains
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[hero]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:@{@"hero": self.heroImage}]];
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hero]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:@{@"hero": self.heroImage}]];
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[promo]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:@{@"promo": self.promoImage}]];
      [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[promo]|"
                                                                               options:NSLayoutFormatAlignAllTop
                                                                               metrics:nil
                                                                                 views:@{@"promo": self.promoImage}]];
    }
    return self;
}

- (void)setRecord:(ATGHomeBanner *) pRecord {
  [self.heroImage setImageURL:[ATGRestManager getAbsoluteImageString:pRecord.deviceDescription]];
  [self.promoImage setImageURL:[ATGRestManager getAbsoluteImageString:pRecord.derivedDeviceImage]];
}

@end

