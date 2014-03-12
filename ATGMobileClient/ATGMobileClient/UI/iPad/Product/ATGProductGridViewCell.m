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

#import "ATGProductGridViewCell.h"
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGStoreManager.h>
#import <CoreText/CoreText.h>
#import <ATGMobileClient/ATGRestManager.h>

static const CGFloat VIEWS_MARGIN = 0;

#pragma mark - UILabel NSCopying Replacement Declaration
#pragma mark -

@interface UILabel (ATGProductGridViewCell)

- (UILabel *) copy NS_RETURNS_RETAINED;

@end

#pragma mark - ATGProductGridViewCell Private Interface Declaration
#pragma mark -

@interface ATGProductGridViewCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productPriceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productOldPriceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteNameLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, weak) UIImageView *complexPriceImageView;

#pragma mark - Private Protocol Definition

- (UIImage *) complexPriceImageForSize:(CGSize)size priceFormatter:(NSNumberFormatter *)priceFormatter NS_RETURNS_NOT_RETAINED;

@end

#pragma mark - ATGProductGridViewCell Implementation
#pragma mark -

@implementation ATGProductGridViewCell

#pragma mark - Synthesized Properties

@synthesize productName;
@synthesize siteID;
@synthesize siteName;
@synthesize imageURL;
@synthesize highestPrice;
@synthesize lowestPrice;
@synthesize price;
@synthesize oldPrice;
@synthesize productImageView;
@synthesize productNameLabel;
@synthesize productPriceLabel;
@synthesize productOldPriceLabel;
@synthesize siteNameLabel;
@synthesize currencyCode;
@synthesize complexPriceImageView;

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  // Cell's inner contents should be placed into a contentView.
  // Move all contents defined with IB into contentView.
  for (UIView *view in[self subviews]) {
    if (view != [self contentView]) {
      [[self contentView] addSubview:view];
    }
  }
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  // Restore initial cell's state.
  [[self complexPriceImageView] removeFromSuperview];
  [[self productPriceLabel] setHidden:NO];
  [[self productOldPriceLabel] setHidden:NO];

  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setCurrencyCode:[self currencyCode]];

  CGRect bounds = [self bounds];
  CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
  // Y origin to be used while positioning cell's inner contents.
  CGFloat origin = [[self productImageView] frame].size.height;

  // ATGRenderableProduct image view is positioned properly automatically (defined with IB).
  [[self productImageView] setImageURL:[ATGRestManager getAbsoluteImageString:[self imageURL]]];

  // Calculate how much space do we need to display product's name.
  [[self productNameLabel] setText:[self productName]];
  CGSize actualSize = [[self productName] sizeWithFont:[[self productNameLabel] font]
                                     constrainedToSize:maxSize
                                         lineBreakMode:[[self productNameLabel] lineBreakMode]];
  // Position label properly.
  [[self productNameLabel] setFrame:CGRectMake(0, origin += VIEWS_MARGIN,
                                               bounds.size.width, actualSize.height)];
  origin += actualSize.height;

  if ([[self price] floatValue] > 0 && [[self oldPrice] floatValue] > 0) {
    // We have both list price and sale price. So don't dislpay price labels, we're going to create
    // a custom view for displaying this kind of price.
    [[self productPriceLabel] setHidden:YES];
    [[self productOldPriceLabel] setHidden:YES];

    // Create an image representation of product price and instantiate an UIImageView.
    UIImageView *priceImageView =
      [[UIImageView alloc] initWithImage:[self complexPriceImageForSize:maxSize
                                                         priceFormatter:formatter]];
    // Now reposition this image view properly.
    [priceImageView setFrame:CGRectMake(0, origin += VIEWS_MARGIN,
                                        bounds.size.width, [[priceImageView image] size].height)];
    // Add this view to cell's contents.
    [[self contentView] addSubview:priceImageView];
    // And save link to it for future use.
    [self setComplexPriceImageView:priceImageView];
    origin += actualSize.height;
  } else if ([[self price] floatValue] > 0) {
    // Only list price is specified, display appropriate label only.
    [[self productPriceLabel] setHidden:NO];
    [[self productOldPriceLabel] setHidden:YES];

    // Position list price label properly.
    [[self productPriceLabel] setText:[formatter stringFromNumber:[self price]]];
    actualSize = [[[self productPriceLabel] text] sizeWithFont:[[self productPriceLabel] font]
                                             constrainedToSize:maxSize
                                                 lineBreakMode:[[self productPriceLabel] lineBreakMode]];
    [[self productPriceLabel] setFrame:CGRectMake(0, origin += VIEWS_MARGIN,
                                                  bounds.size.width, actualSize.height)];
    origin += actualSize.height;
  } else {
    // If none of previous cases were triggered, then we have a price range.
    // Display proper labels and set price range text.
    [[self productPriceLabel] setHidden:NO];
    [[self productOldPriceLabel] setHidden:YES];

    NSString *priceString =
      [NSString stringWithFormat:@"%@ – %@",
       [formatter stringFromNumber:[self lowestPrice]],
       [formatter stringFromNumber:[self highestPrice]]];
    // Now reposition the label appropriately.
    actualSize = [priceString sizeWithFont:[[self productPriceLabel] font]
                         constrainedToSize:maxSize
                             lineBreakMode:[[self productPriceLabel] lineBreakMode]];
    [[self productPriceLabel] setFrame:CGRectMake(0, origin += VIEWS_MARGIN,
                                                  bounds.size.width, actualSize.height)];
    [[self productPriceLabel] setText:priceString];
    origin += actualSize.height;
  }

  [[self siteNameLabel] setHidden:YES];
  // Check, if the product came from other site.
  if (![[[[ATGStoreManager storeManager] restManager] currentSite] isEqualToString:[self siteID]]) {
    [[self siteNameLabel] setHidden:NO];
    // If this is the case, then display site name.
    NSString *format = NSLocalizedStringWithDefaultValue
        (@"ATGProductGridViewCell.SiteNameLabelFormat",
         nil, [NSBundle mainBundle], @"from %@",
         @"Format string to be used when displaying a notification "
         @"that product has came from different site. An only parameter "
         @"of this format is site name.");
    NSString *siteString = [NSString stringWithFormat:format, [self siteName]];
    actualSize = [siteString sizeWithFont:[[self siteNameLabel] font]
                        constrainedToSize:maxSize
                            lineBreakMode:[[self siteNameLabel] lineBreakMode]];
    [[self siteNameLabel] setFrame:CGRectMake(0, origin += VIEWS_MARGIN,
                                              bounds.size.width, actualSize.height)];
    [[self siteNameLabel] setText:siteString];
  }
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement {
  return YES;
}

- (BOOL)accessibilityElementsHidden {
  return YES;
}

- (UIAccessibilityTraits)accessibilityTraits {
  return UIAccessibilityTraitSummaryElement;
}

- (NSString *)accessibilityLabel {
  NSString *summary = [[[self productNameLabel] text] stringByAppendingString:@". "];
  NSString *priceString = nil;
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setCurrencyCode:[self currencyCode]];
  if ([[self price] floatValue] > 0 && [[self oldPrice] floatValue] > 0) {
    priceString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue
                   (@"ATGProductGridViewCell.Accessibility.Label.Format.SalePrice",
                    nil, [NSBundle mainBundle], @"Price: %1$@, was %2$@.",
                    @"Format to be used when constructing an accessibility label for the product sale price. "
                    @"First parameter is product's sale price, second parameter is old list price."),
                   [formatter stringFromNumber:[self price]],
                   [formatter stringFromNumber:[self oldPrice]], nil];
  } else if ([[self price] floatValue] > 0) {
    priceString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue
                   (@"ATGProductGridViewCell.Accessibility.Label.Format.SimplePrice",
                    nil, [NSBundle mainBundle], @"Price: %@.",
                    @"Format to be used when constructing an accessibility label for the product price. "
                    @"String input parameter is product's current price."),
                   [formatter stringFromNumber:[self price]], nil];
  } else {
    priceString = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue
                   (@"ATGProductGridViewCell.Accessibility.Label.Format.PriceRange",
                    nil, [NSBundle mainBundle], @"Price: from %1$@ to %2$@.",
                    @"Format to be used when constructing an accessibility label for the product price. "
                    @"First parameter is product's lowest price, second parameter is product highest price."),
                   [formatter stringFromNumber:[self lowestPrice]],
                   [formatter stringFromNumber:[self highestPrice]], nil];
  }
  summary = [summary stringByAppendingString:priceString];
  if (![[self siteNameLabel] isHidden]) {
    summary = [[summary stringByAppendingString:@" "] stringByAppendingString:[[self siteNameLabel] text]];
  }
  return summary;
}

#pragma mark - Public Protocol Implementation

- (ATGProductGridViewCell *) copy {
  // We're about to create a copy of self. Instantiate a new instance with simple method.
  ATGProductGridViewCell *result = [[[self class] alloc] initWithFrame:[self frame]];

  // Then create copies of it's essential contents.
  // And add them to clone's properties.
  ATGImageView *imageViewCopy = [[ATGImageView alloc] initWithFrame:[[self productImageView] frame]];
  [imageViewCopy setContentMode:[[self productImageView] contentMode]];
  [result setProductImageView:imageViewCopy];
  [[result contentView] addSubview:imageViewCopy];

  UILabel *productNameLabelCopy = [[self productNameLabel] copy];
  [result setProductNameLabel:productNameLabelCopy];
  [[result contentView] addSubview:productNameLabelCopy];

  UILabel *productPriceLabelCopy = [[self productPriceLabel] copy];
  [result setProductPriceLabel:productPriceLabelCopy];
  [[result contentView] addSubview:productPriceLabelCopy];

  UILabel *productOldPriceLabelCopy = [[self productOldPriceLabel] copy];
  [result setProductOldPriceLabel:productOldPriceLabelCopy];
  [[result contentView] addSubview:productOldPriceLabelCopy];

  UILabel *siteNameLabelCopy = [[self siteNameLabel] copy];
  [result setSiteNameLabel:siteNameLabelCopy];
  [[result contentView] addSubview:siteNameLabelCopy];

  return result;
}

#pragma mark - Private Protocol Implementation

- (UIImage *) complexPriceImageForSize:(CGSize)pSize priceFormatter:(NSNumberFormatter *)pPriceFormatter {
  // We're going to create an image representing both list price and sale price (i.e. string in the
  // following format: $100.00 was $200 -strokethrough-.
  // This string consists of three different part each using different styling. All these parts should
  // be aligned by their baselines.
  // So we're using a CoreText APIs to render this complex string.

  // First of all create a resulting decorated string, it will contain all three text parts.
  CFMutableAttributedStringRef priceString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);

  // For the first part of the string use font defined with list price label.
  CTFontRef font = CTFontCreateWithName( (__bridge CFStringRef)[[[self productPriceLabel] font] fontName],
                                         [[[self productPriceLabel] font] pointSize], NULL );
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              (__bridge id)font, kCTFontAttributeName,
                              [[[self productPriceLabel] textColor] CGColor], kCTForegroundColorAttributeName,
                              nil];
  // Create a decorated string for the first text part.
  CFAttributedStringRef currentPriceString =
    CFAttributedStringCreate(kCFAllocatorDefault,
                             (__bridge CFStringRef)[[pPriceFormatter stringFromNumber:[self price]]
                                                    stringByAppendingString:@" "],
                             (__bridge CFDictionaryRef)attributes);
  // And add it to the resulting string.
  CFAttributedStringReplaceAttributedString(priceString, CFRangeMake(0, 0), currentPriceString);

  // CoreText objects are not managed by ARC, so release all objects manually.
  CFRelease(font);
  // The second part of the string should use font defined with sale price label.
  font = CTFontCreateWithName( (__bridge CFStringRef)[[[self productOldPriceLabel] font] fontName],
                               [[[self productOldPriceLabel] font] pointSize], NULL );
  attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, kCTFontAttributeName,
                [[[self productOldPriceLabel] textColor] CGColor], kCTForegroundColorAttributeName, nil];
  // Second part of the string is a 'was' prefix.
  NSString *prefix = NSLocalizedStringWithDefaultValue
      (@"ATGProductGridViewCell.SalePricePrefix",
       nil, [NSBundle mainBundle], @"was",
       @"Prefix to be displayed before a sale price when displaying "
       @"a product in a grid.");
  // Add an extra space to separate the prefix from sale price.
  prefix = [prefix stringByAppendingString:@" "];
  // Create a decorated string.
  CFAttributedStringRef oldPricePrefix =
    CFAttributedStringCreate(kCFAllocatorDefault, (__bridge CFStringRef)prefix,
                             (__bridge CFDictionaryRef)attributes);
  // And append it to the resulting string.
  CFAttributedStringReplaceAttributedString(priceString,
                                            CFRangeMake(CFAttributedStringGetLength(priceString), 0),
                                            oldPricePrefix);

  // The third part of the string will use the same font and color.
  attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
  // However, we're adding a FAKE decorating attribute to designate which part of the resulting string
  // should be strokethough.
  [(NSMutableDictionary *) attributes setObject:[NSNumber numberWithBool:YES] forKey:@"Strikethrough"];
  // Create a decorated string with sale price.
  CFAttributedStringRef oldPriceString =
    CFAttributedStringCreate(kCFAllocatorDefault,
                             (__bridge CFStringRef)[pPriceFormatter stringFromNumber:[self oldPrice]],
                             (__bridge CFDictionaryRef)attributes);
  CFAttributedStringReplaceAttributedString(priceString,
                                            CFRangeMake(CFAttributedStringGetLength(priceString), 0),
                                            oldPriceString);

  CFRange wholeString = CFRangeMake( 0, CFAttributedStringGetLength(priceString) );

  // Decorate the resulting string to be aligned in the center.
  CTTextAlignment alignment = kCTCenterTextAlignment;
  CTParagraphStyleSetting settings[] =
  { { kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment } };
  CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
  CFAttributedStringSetAttribute(priceString, wholeString, kCTParagraphStyleAttributeName, paragraphStyle);

  // Create necessary objects to render the resulting decorated string.
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(priceString);
  CGSize actualSize =
    CTFramesetterSuggestFrameSizeWithConstraints(framesetter, wholeString, NULL, pSize, NULL);
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect( path, NULL, CGRectMake(0, 0, pSize.width, actualSize.height) );
  CTFrameRef frame = CTFramesetterCreateFrame(framesetter, wholeString, path, NULL);

  // Begin an image context, we're going to extract resulting image from it.
  UIGraphicsBeginImageContext( CGSizeMake(pSize.width, actualSize.height) );
  // CoreText uses a positive coordinates, while iOS UIKit uses negative.
  // So we have to flip the context.
  CGContextSetTextMatrix(UIGraphicsGetCurrentContext(), CGAffineTransformIdentity);
  CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, actualSize.height);
  CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);

  // Render the string.
  CTFrameDraw( frame, UIGraphicsGetCurrentContext() );

  // Unfortunatelly, iOS version of CoreText doesn't support strikethrough decoration.
  // So we're drawing a line by ourselves.
  // Get the single line from the frame rendered and extract all its runs.
  CFArrayRef allStringRuns =
    CTLineGetGlyphRuns( (__bridge CTLineRef)[(__bridge NSArray *)CTFrameGetLines(frame) objectAtIndex:0] );
  // We need the last run to be strokethrough.
  CTRunRef oldPriceRun = (__bridge CTRunRef)[(__bridge NSArray *) allStringRuns lastObject];
  // Calculate it's bounds.
  CGRect oldPriceBounds = CTRunGetImageBounds( oldPriceRun, UIGraphicsGetCurrentContext(), CFRangeMake(0, 0) );
  CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),
                                   [[[self productOldPriceLabel] textColor] CGColor]);
  // Draw the line across the text.
  // CoreText returns proper size from CTRunGetImageBounds function, however it's origin is not accurate.
  // CoreText places the resulting rect at the text ending point, so we have to shift coordinates left
  // when drawing a line.
  CGContextMoveToPoint( UIGraphicsGetCurrentContext(),
                        CGRectGetMinX(oldPriceBounds) - CGRectGetWidth(oldPriceBounds),
                        CGRectGetMidY(oldPriceBounds) );
  CGContextAddLineToPoint( UIGraphicsGetCurrentContext(),
                           CGRectGetMaxX(oldPriceBounds) - CGRectGetWidth(oldPriceBounds),
                           CGRectGetMidY(oldPriceBounds) );
  CGContextStrokePath( UIGraphicsGetCurrentContext() );

  // Now the image is ready, extract it from the context.
  UIImage *priceImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  // Release all CoreText objects, as they're not managed by ARC.
  CFRelease(frame);
  CFRelease(path);
  CFRelease(framesetter);
  CFRelease(paragraphStyle);
  CFRelease(oldPriceString);
  CFRelease(oldPricePrefix);
  CFRelease(currentPriceString);
  CFRelease(font);
  CFRelease(priceString);

  return priceImage;
}

@end

#pragma mark - UILabel NSCopying Replacement Implementation
#pragma mark -

@implementation UILabel (ATGProductGridViewCell)

- (UILabel *) copy {
  // We're about to create a clone of label. Create a new instance with simple method.
  UILabel *result = [[UILabel alloc] initWithFrame:[self frame]];

  // And copy essential property values to this new instance.
  [result setFont:[self font]];
  [result setTextAlignment:[self textAlignment]];
  [result setTextColor:[self textColor]];
  [result setNumberOfLines:[self numberOfLines]];
  [result setLineBreakMode:[self lineBreakMode]];

  return result;
}

@end