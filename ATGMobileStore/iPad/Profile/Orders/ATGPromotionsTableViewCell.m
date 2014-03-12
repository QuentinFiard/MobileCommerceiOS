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

#import <ATGMobileClient/ATGPricingAdjustment.h>
#import "ATGPromotionsTableViewCell.h"

#pragma mark - ATGPromotionsTableViewCell Private Protocol Definition
#pragma mark -

@interface ATGPromotionsTableViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *captionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *promotionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *promotionImage;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *couponPromotionImage;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *couponCodeTextField;

#pragma mark - Custom Properties

@property (nonatomic, readwrite) UIEdgeInsets insets;
@property (nonatomic, readwrite, strong) NSMutableArray *clones;

#pragma mark - Auxiliary Methods

- (CGFloat) promotionsHeight;

@end

#pragma mark - ATGPromotionsTableViewCell Implementation
#pragma mark -

@implementation ATGPromotionsTableViewCell

#pragma mark - Synthesized Properties

@synthesize captionLabel;
@synthesize promotionImage;
@synthesize couponPromotionImage;
@synthesize promotionLabel;
@synthesize couponPromotions;
@synthesize otherPromotions;
@synthesize insets;
@synthesize clones;
@synthesize couponCode;
@synthesize couponCodeTextField;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  self.captionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGPromotionsTableViewCell.CellCaption",
                                                             nil, [NSBundle mainBundle], @"Promotions:",
                                                             @"Caption of the cell with order applied promotions.");
  

  if (self.couponCodeTextField.enabled) {
    self.couponCodeTextField.placeholder = NSLocalizedStringWithDefaultValue(@"ATGPromotionsTableViewCell.iPad.PlaceholderPromoCode",
                                                                             nil, [NSBundle mainBundle], @"Enter Promo Code",
                                                                             @"Placeholder of the promo code text field which is displayed when no coupon code applied to order.");
    self.couponCodeTextField.text = @"";
  } else {
    self.couponCodeTextField.text = NSLocalizedStringWithDefaultValue(@"ATGGiftOptionsTableViewCell.NoneSelected", nil, [NSBundle mainBundle], @"None",
                                                                      @"Text to be displayed if there is no promotions.");
  }

  CGFloat topInset = self.captionLabel.frame.origin.y;
  CGFloat bottomInset = self.bounds.size.height - self.promotionLabel.frame.origin.y - self.promotionLabel.frame.size.height;
  self.insets = UIEdgeInsetsMake(topInset, self.promotionImage.frame.origin.x, bottomInset,
                                 self.bounds.size.width - self.promotionLabel.frame.origin.x - self.promotionLabel.frame.size.width);

  self.clones = [[NSMutableArray alloc] init];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  // Do not display IB outlets. We're going to make some clones of them instead.
  self.promotionImage.hidden = YES;
  self.promotionLabel.hidden = YES;
  self.couponPromotionImage.hidden = YES;

  if (! self.couponPromotions) {
    self.couponPromotions = [NSArray array];
  }

  if (self.couponPromotions.count + self.otherPromotions.count > 0)
    self.couponCodeTextField.text = self.couponCode;

  // First of all, remove all previously created clones.
  for (UIView *view in self.clones) {
    [view removeFromSuperview];
  }
  [self.clones removeAllObjects];

  // Maximum size to be occupied by the single promotion text.
  CGSize maxSize = CGSizeMake(self.promotionLabel.bounds.size.width, 1000);
  CGSize stubPromotionSize = [self.promotionLabel.text sizeWithFont:self.promotionLabel.font];
  CGFloat stubInsets = self.promotionLabel.bounds.size.height - stubPromotionSize.height;
  // Do not shift first promotion item.
  CGFloat shift = 0;
  // Iterate over all specified promotions, both coupon and generic.
  for (ATGPricingAdjustment *promotion in [self.couponPromotions arrayByAddingObjectsFromArray:self.otherPromotions]) {
    // Make a clone of the promotion label.
    UILabel *currentPromotionLabel = [[UILabel alloc] initWithFrame:self.promotionLabel.frame];
    currentPromotionLabel.font = self.promotionLabel.font;
    currentPromotionLabel.textColor = self.promotionLabel.textColor;
    currentPromotionLabel.lineBreakMode = self.promotionLabel.lineBreakMode;
    currentPromotionLabel.numberOfLines = self.promotionLabel.numberOfLines;
    currentPromotionLabel.text = promotion.pricingModel;
    CGSize promotionSize = [promotion.pricingModel sizeWithFont:currentPromotionLabel.font
                                  constrainedToSize:maxSize
                                      lineBreakMode:currentPromotionLabel.lineBreakMode];
    // Position it properly, occupy as many space as needed to contain all the promotion text.
    CGRect frame = currentPromotionLabel.frame;
    frame.origin.y += shift;
    frame.size.height = promotionSize.height + stubInsets;
    currentPromotionLabel.frame = frame;
    [self.contentView addSubview:currentPromotionLabel];
    [self.clones addObject:currentPromotionLabel];

    // Make a clone of the promotion image.
    UIImage *image = [self.couponPromotions containsObject:promotion] ?
                     self.couponPromotionImage.image : self.promotionImage.image;
    UIImageView *currentPromotionImage = [[UIImageView alloc] initWithImage:image];
    // And reposition it to right place.
    frame = self.promotionImage.frame;
    frame.origin.y += shift;
    currentPromotionImage.frame = frame;
    [self.contentView addSubview:currentPromotionImage];
    [self.clones addObject:currentPromotionImage];

    // Next promotion item will be displayed below previous one.
    shift += promotionSize.height + stubInsets;
  }
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  CGFloat promotionsHeight = self.promotionsHeight;
  return CGSizeMake(self.bounds.size.width, self.promotionLabel.frame.origin.y + promotionsHeight + self.insets.bottom);
}

#pragma mark - ATGPromotionsTableViewCell Private Protocol Implementation

- (CGFloat) promotionsHeight {
  CGSize stubPromotionSize = [self.promotionLabel.text sizeWithFont:self.promotionLabel.font];
  CGFloat stubInsets = self.promotionLabel.bounds.size.height - stubPromotionSize.height;
  CGFloat promotionsHeight = 0;
  CGSize maxSize = CGSizeMake(self.promotionLabel.bounds.size.width, CGFLOAT_MAX);
  for (ATGPricingAdjustment *promotion in [self.couponPromotions arrayByAddingObjectsFromArray:self.otherPromotions]) {
    CGSize promotionSize = [promotion.pricingModel sizeWithFont:self.promotionLabel.font
                                              constrainedToSize:maxSize
                                                  lineBreakMode:self.promotionLabel.lineBreakMode];
    promotionsHeight += promotionSize.height + stubInsets;
  }
  return promotionsHeight;
}

@end