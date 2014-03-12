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

#import "ATGGiftListItemCollectionViewCell.h"
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGGiftItem.h>

#pragma mark - ATGGiftListItemCollectionViewCell Private Protocol Definition
#pragma mark -

@interface ATGGiftListItemCollectionViewCell ()

@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *skuPropertiesLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *itemPriceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *priceDelimiterLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *oldPriceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIView *dimView;
@property (nonatomic, readwrite, weak) IBOutlet UIView *actionsContainerView;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *confirmationButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *giftlistButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *wishlistButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *compareButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *cartButton;

@property (nonatomic, readwrite, weak) UILabel *realPriceLabel;

- (IBAction)didTouchRemoveButton:(UIButton *)sender;
- (IBAction)didTouchConfirmButton:(UIButton *)sender;
- (IBAction)didTouchGiftListButton:(UIButton *)sender;
- (IBAction)didTouchWishListButton:(UIButton *)sender;
- (IBAction)didTouchCompareButton:(UIButton *)sender;
- (IBAction)didTouchCartButton:(UIButton *)sender;

@end

#pragma mark - ATGGiftListItemCollectionViewCell Implementation
#pragma mark -

@implementation ATGGiftListItemCollectionViewCell

#pragma mark - UIView

- (void)awakeFromNib {
  [super awakeFromNib];
  NSString *title = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Label.DeleteButton",
   nil, [NSBundle mainBundle], @"Remove item from gift/wish list",
   @"Accessibility label to be displayed on the 'Delete' button of the gift list cell.");
  NSString *hint = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Hint.DeleteButton",
   nil, [NSBundle mainBundle], @"Double tap to remove item from gift list.",
   @"Accessibility hint to be used by the 'Delete' button of the gift list cell.");
  [[self deleteButton] setAccessibilityLabel:title];
  [[self deleteButton] setAccessibilityHint:hint];
  
  title = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Label.GiftlistButton",
   nil, [NSBundle mainBundle], @"Move item to another gift list",
   @"Accessibility label to be displayed on the 'Gift List' button of the gift list cell.");
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Hint.GiftlistButton",
   nil, [NSBundle mainBundle], @"Double tap to move item to another gift list.",
   @"Accessibility hint to be used by the 'Gift List' button of the gift list cell.");
  [[self giftlistButton] setAccessibilityLabel:title];
  [[self giftlistButton] setAccessibilityHint:hint];
  
  title = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Label.WishlistButton",
   nil, [NSBundle mainBundle], @"Move item to wish list",
   @"Accessibility label to be displayed on the 'Wish List' button of the gift list cell.");
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Hint.WishlistButton",
   nil, [NSBundle mainBundle], @"Double tap to move item to wish list.",
   @"Accessibility hint to be used by the 'Wish List' button of the wish list cell.");
  [[self wishlistButton] setAccessibilityLabel:title];
  [[self wishlistButton] setAccessibilityHint:hint];
  
  title = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Label.CompareButton",
   nil, [NSBundle mainBundle], @"Add item to compare",
   @"Accessibility label to be displayed on the 'Compare' button of the gift list cell.");
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Hint.CompareButton.",
   nil, [NSBundle mainBundle], @"Double tap to add item to compare.",
   @"Accessibility hint to be used by the 'Compare' button of the gift list cell.");
  [[self compareButton] setAccessibilityLabel:title];
  [[self compareButton] setAccessibilityHint:hint];
  
  title = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Label.CartButton",
   nil, [NSBundle mainBundle], @"Add item to cart",
   @"Accessibility label to be displayed on the 'Cart' button of the gift list cell.");
  hint = NSLocalizedStringWithDefaultValue
  (@"ATGGiftListItemCollectionViewCell.Accessibility.Hint.CartButton",
   nil, [NSBundle mainBundle], @"Double tap to add item to cart.",
   @"Accessibility hint to be used by the 'Cart' button of the gift list cell.");
  [[self cartButton] setAccessibilityLabel:title];
  [[self cartButton] setAccessibilityHint:hint];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [[self dimView] setHidden:![self isChosen]];
  [[self actionsContainerView] setHidden:![self isChosen]];
}

#pragma mark - ATGGridCollectionViewCell

- (void)setChosen:(BOOL)pChosen {
  [super setChosen:pChosen];
  [[self confirmationButton] setHidden:YES];
}

- (void)setObjectToDisplay:(id)pObjectToDisplay {
  [super setObjectToDisplay:pObjectToDisplay];
  if ([pObjectToDisplay isKindOfClass:[ATGGiftItem class]]) {
    ATGGiftItem *giftItem = (ATGGiftItem *)pObjectToDisplay;
    [[self productImageView] setImageURL:[ATGRestManager getAbsoluteImageString:[giftItem mediumImageUrl]]];
    [[self productNameLabel] setText:[giftItem displayName]];
    
    NSMutableString *skuProperties = [[NSMutableString alloc] init];
    if ([[giftItem size] length]) {
      [skuProperties appendString:[giftItem size]];
    }
    if ([[giftItem color] length]) {
      if ([skuProperties length]) {
        [skuProperties appendString:@", "];
      }
      [skuProperties appendString:[giftItem color]];
    }
    if ([[giftItem woodFinish] length]) {
      if ([skuProperties length]) {
        [skuProperties appendString:@", "];
      }
      [skuProperties appendString:[giftItem woodFinish]];
    }
    [[self skuPropertiesLabel] setText:skuProperties];
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setCurrencyCode:[giftItem currencyCode]];
    NSAttributedString *price = nil;
    if ([giftItem salePrice]) {
      NSDictionary *attributes = @{NSFontAttributeName: [[self itemPriceLabel] font],
                                   NSForegroundColorAttributeName: [[self itemPriceLabel] textColor]};
      NSAttributedString *newPrice =
      [[NSAttributedString alloc] initWithString:[priceFormatter stringFromNumber:[giftItem salePrice]]
                                      attributes:attributes];

      attributes = @{NSFontAttributeName: [[self oldPriceLabel] font],
                     NSForegroundColorAttributeName: [[self oldPriceLabel] textColor],
                     NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)};
      NSAttributedString *oldPrice =
          [[NSAttributedString alloc] initWithString:[priceFormatter stringFromNumber:[giftItem listPrice]]
                                          attributes:attributes];
      
      NSString *format = NSLocalizedStringWithDefaultValue
          (@"ATGGiftListItemCollectionViewCell.SalePriceFormat",
           nil, [NSBundle mainBundle], @"%1$@ was %2$@",
           @"String format to be used when displaying an gift item price which product is on sale."
           @"First attribute is sale price, second attribute is a list price.");
      attributes = @{NSFontAttributeName: [[self priceDelimiterLabel] font],
                     NSForegroundColorAttributeName: [[self priceDelimiterLabel] textColor]};
      price = [[NSAttributedString alloc] initWithFormat:format
                                              attributes:attributes
                                               arguments:newPrice, oldPrice, nil];
    } else {
      NSDictionary *attributes = @{NSFontAttributeName: [[self itemPriceLabel] font],
                                   NSForegroundColorAttributeName: [[self itemPriceLabel] textColor]};
      NSDecimalNumber *listPrice = [giftItem listPrice];
      if (listPrice == nil) {
        listPrice = [NSDecimalNumber zero];
      }
      price = [[NSAttributedString alloc] initWithString:[priceFormatter
                                                          stringFromNumber:listPrice]
                                              attributes:attributes];
    }
    NSMutableParagraphStyle *priceParagrapth = [[NSMutableParagraphStyle alloc] init];
    [priceParagrapth setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *resultingPriceString = [price mutableCopy];
    [resultingPriceString addAttribute:NSParagraphStyleAttributeName
                                 value:priceParagrapth
                                 range:NSMakeRange(0, [price length])];
    [[self realPriceLabel] removeFromSuperview];
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [[self contentView] insertSubview:priceLabel belowSubview:[self dimView]];
    [priceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:priceLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:[self contentView]
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:priceLabel
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:[self contentView]
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:priceLabel
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:[self skuPropertiesLabel]
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:priceLabel
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:[self siteNameLabel]
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0];
    [[self contentView] addConstraints:@[leading, trailing, top, bottom]];
    [priceLabel setAttributedText:resultingPriceString];
    [self setRealPriceLabel:priceLabel];
    
    if ([[[ATGRestManager restManager] currentSite] isEqualToString:[giftItem siteId]]) {
      [[self siteNameLabel] setHidden:YES];
    } else {
      [[self siteNameLabel] setHidden:NO];
      NSString *format = NSLocalizedStringWithDefaultValue
          (@"ATGGiftListItemCollectionViewCell.SiteNameFormat",
           nil, [NSBundle mainBundle], @"from %@",
           @"String format to be used when displaying a gift item origin site.");
      [[self siteNameLabel] setText:[NSString stringWithFormat:format, [giftItem siteName]]];
    }
  }
}

#pragma mark - Private Protocol Implementation

- (IBAction)didTouchRemoveButton:(UIButton *)pSender {
  [UIView transitionWithView:[self actionsContainerView]
                    duration:.3
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:^{
                    [[self confirmationButton] setHidden:NO];
                  }
                  completion:NULL];
}

- (IBAction)didTouchConfirmButton:(UIButton *)pSender {
  if ([[self delegate] respondsToSelector:@selector(removeGiftItem:forCell:)]) {
    [[self delegate] removeGiftItem:[self objectToDisplay] forCell:self];
  }
}

- (IBAction)didTouchGiftListButton:(UIButton *)pSender {
  if ([[self delegate] respondsToSelector:@selector(moveGiftItemToGiftList:forCell:)]) {
    [[self delegate] moveGiftItemToGiftList:[self objectToDisplay] forCell:self];
  }
}

- (IBAction)didTouchWishListButton:(UIButton *)pSender {
  if ([[self delegate] respondsToSelector:@selector(moveGiftItemToWishList:forCell:)]) {
    [[self delegate] moveGiftItemToWishList:[self objectToDisplay] forCell:self];
  }
}

- (IBAction)didTouchCompareButton:(UIButton *)pSender {
  if ([[self delegate] respondsToSelector:@selector(compareGiftItem:forCell:)]) {
    [[self delegate] compareGiftItem:[self objectToDisplay] forCell:self];
  }
}

- (IBAction)didTouchCartButton:(UIButton *)pSender {
  if ([[self delegate] respondsToSelector:@selector(addGiftItemToCart:forCell:)]) {
    [[self delegate] addGiftItemToCart:[self objectToDisplay] forCell:self];
  }
}

@end
