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

#import "ATGSimpleProductGridCollectionViewCell_iPad.h"
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGBaseProduct.h>

@interface ATGSimpleProductGridCollectionViewCell_iPad ()

@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productPriceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productOldPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceDelimiterConstraint;

@property (nonatomic, readwrite, assign) CGFloat initialDelimiter;

@end

@implementation ATGSimpleProductGridCollectionViewCell_iPad

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setInitialDelimiter:[[self priceDelimiterConstraint] constant]];
}

- (void)setObjectToDisplay:(id)pObjectToDisplay {
  [super setObjectToDisplay:pObjectToDisplay];
  if ([pObjectToDisplay isKindOfClass:[ATGBaseProduct class]]) {
    ATGBaseProduct *product = pObjectToDisplay;
    NSString *url = [ATGRestManager getAbsoluteImageString:product.mediumImageUrl];
    [[self productImageView] setImageURL:url];
    [[self productNameLabel] setText:[product displayName]];
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setCurrencyCode:[product currencyCode]];
    if ([[product lowestListPrice] isEqualToNumber:[product lowestSalePrice]]) {
      [[self productOldPriceLabel] setText:nil];
      [[self productPriceLabel] setText:[priceFormatter stringFromNumber:[product lowestListPrice]]];
    } else {
      // First get an attributed string with old price value, this string would contain text decorations
      // defined with an IB.
      [[self productOldPriceLabel] setText:[priceFormatter stringFromNumber:[product lowestListPrice]]];
      NSMutableAttributedString *oldPrice = [[[self productOldPriceLabel] attributedText] mutableCopy];
      // Add strike-through decoration here, as IB can't do that.
      [oldPrice addAttribute:NSStrikethroughStyleAttributeName
                       value:@(NSUnderlineStyleSingle)
                       range:NSMakeRange(0, [oldPrice length])];
      // Load price format to be used.
      NSString *oldPriceFormat = NSLocalizedStringWithDefaultValue
          (@"ATGSimpleProductGridCollectionViewCell_iPad.Format.OldPrice",
           nil, [NSBundle mainBundle], @"was %1$@",
           @"Price format to be used by carousel items when displaying old price. First argument is price.");
      // And get an attributed string with that format. Get decorations to be used from the UILabel
      // created with an IB.
      [[self productOldPriceLabel] setText:oldPriceFormat];
      NSAttributedString *priceFormat = [[self productOldPriceLabel] attributedText];
      // Now we're ready to construct actual old price text.
      NSAttributedString *finalPriceValue = [[NSAttributedString alloc] initWithFormat:priceFormat
                                                                             arguments:oldPrice];
      [[self productOldPriceLabel] setAttributedText:finalPriceValue];
      [[self productPriceLabel] setText:[priceFormatter stringFromNumber:[product lowestSalePrice]]];
    }
    [[self priceDelimiterConstraint]
        setConstant:[[[self productOldPriceLabel] text] length] > 0 ? [self initialDelimiter] : 0];
  }
}

@end
