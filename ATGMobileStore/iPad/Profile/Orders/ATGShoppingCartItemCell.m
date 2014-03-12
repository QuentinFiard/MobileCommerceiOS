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

#import "ATGShoppingCartItemCell.h"
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGRestManager.h>

#pragma mark - ATGShoppingCartItemCell Private Protocol Definition
#pragma mark -

@interface ATGShoppingCartItemCell ()

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *propertiesLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *quantityLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *quantityUnderlayImage;
@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteNameLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSMutableArray *clones;
@property (nonatomic, readwrite) UIEdgeInsets insets;
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) NSNumberFormatter *numberFormatter;

#pragma mark - Private Protocol

- (void) fitStrings:(NSArray *)strings intoLabel:(UILabel *)label;

@end

#pragma mark - ATGShoppingCartItemCell Implementation
#pragma mark -

@implementation ATGShoppingCartItemCell

#pragma mark - Synthesized Properties

@synthesize nameLabel;
@synthesize propertiesLabel;
@synthesize priceLabel;
@synthesize quantityLabel;
@synthesize quantityUnderlayImage;
@synthesize clones;
@synthesize priceFormatter;
@synthesize numberFormatter;
@synthesize insets;
@synthesize item;
@synthesize currencyCode;
@synthesize productImageView;

#pragma mark - Custom Properties

- (void) setCurrencyCode:(NSString *)pCurrencyCode {
  [[self priceFormatter] setCurrencyCode:pCurrencyCode];
  currencyCode = [pCurrencyCode copy];
}

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];
  
  [self setClones:[NSMutableArray array]];
  
  CGRect bounds = [[self contentView] bounds];
  CGRect nameFrame = [[self nameLabel] frame];
  CGRect propertiesFrame = [[self siteNameLabel] frame];
  CGRect priceFrame = [[self priceLabel] frame];
  [self setInsets:UIEdgeInsetsMake(nameFrame.origin.y, nameFrame.origin.x,
                                   bounds.size.height - propertiesFrame.origin.y - propertiesFrame.size.height,
                                   bounds.size.width - priceFrame.origin.x - priceFrame.size.width)];
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [self setPriceFormatter:formatter];
  
  formatter = [[NSNumberFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [self setNumberFormatter:formatter];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];
  
  [[self productImageView] setImageURL:[ATGRestManager getAbsoluteImageString:[[self item] thumbnailImage]]];
  
  // Do not display IB outlets, we're going create their clones instead.
  [[self priceLabel] setHidden:YES];
  [[self quantityLabel] setHidden:YES];
  [[self quantityUnderlayImage] setHidden:YES];
  
  // First, remove all clones previously created.
  for (UIView *view in[self clones]) {
    [view removeFromSuperview];
  }
  [[self clones] removeAllObjects];
  
  // Clones' block should be positioned at center of the cell. Calculate frame.origin.y for the first clone.
  CGFloat origin = ([[self contentView] bounds].size.height -
                    [[[self item] unitPrices] count] * [[self quantityUnderlayImage] bounds].size.height) / 2;
  // Iterate over all price beans defined for the current item. Each price bean should have its own price.
  for (NSDictionary *priceBean in[[self item] unitPrices]) {
    // Get inner contents.
    NSNumber *quantity = [priceBean objectForKey:@"quantity"];
    NSNumber *price = [priceBean objectForKey:@"unitPrice"];
    
    // Create a clone of the underlay.
    UIImageView *currentUnderlay = [[UIImageView alloc] initWithFrame:[[self quantityUnderlayImage] frame]];
    [currentUnderlay setContentMode:[[self quantityUnderlayImage] contentMode]];
    [currentUnderlay setImage:[[self quantityUnderlayImage] image]];
    // And position it properly.
    CGRect frame = [currentUnderlay frame];
    frame.origin.y = origin;
    [currentUnderlay setFrame:frame];
    [[self contentView] addSubview:currentUnderlay];
    [[self clones] addObject:currentUnderlay];
    
    // Create a clone of the quantity label.
    UILabel *currentQuantity = [[UILabel alloc] initWithFrame:[[self quantityLabel] frame]];
    [currentQuantity setFont:[[self quantityLabel] font]];
    [currentQuantity setTextAlignment:[[self quantityLabel] textAlignment]];
    [currentQuantity setTextColor:[[self quantityLabel] textColor]];
    // Don't forget to set quantity value.
    [currentQuantity setText:[[self numberFormatter] stringFromNumber:quantity]];
    [currentQuantity setBackgroundColor:[[self quantityLabel] backgroundColor]];
    frame = [currentQuantity frame];
    frame.origin.y = origin;
    [currentQuantity setFrame:frame];
    [[self contentView] addSubview:currentQuantity];
    [[self clones] addObject:currentQuantity];
    
    // Create a clone of the price label.
    UILabel *currentPrice = [[UILabel alloc] initWithFrame:[[self priceLabel] frame]];
    [currentPrice setFont:[[self priceLabel] font]];
    [currentPrice setTextAlignment:[[self priceLabel] textAlignment]];
    [currentPrice setTextColor:[[self priceLabel] textColor]];
    // Don't forget to set price value.
    [currentPrice setText:[[self priceFormatter] stringFromNumber:price]];
    frame = [currentPrice frame];
    frame.origin.y = origin;
    [currentPrice setFrame:frame];
    [[self contentView] addSubview:currentPrice];
    [[self clones] addObject:currentPrice];
    
    // Next set of clones will be located below previous set.
    origin += frame.size.height;
  }
  
  // Update SKU name.
  [[self nameLabel] setText:[[[self item] sku] displayName]];
  // Which properties are defined for the current SKU?
  NSMutableArray *skuProperties = [[NSMutableArray alloc] init];
  if ([[[self item] sku] color]) {
    [skuProperties addObject:[[[self item] sku] color]];
  }
  if ([[[self item] sku] size]) {
    [skuProperties addObject:[[[self item] sku] size]];
  }
  if ([[[self item] sku] woodFinish]) {
    [skuProperties addObject:[[[self item] sku] woodFinish]];
  }
  // Draw the properties inside the properties label.
  [self fitStrings:skuProperties intoLabel:[self propertiesLabel]];
  
  if ([[[ATGRestManager restManager] currentSite] isEqualToString:[[self item] siteId]]) {
    // Commerce item is added at the current site, do not display site name label.
    [[self siteNameLabel] setHidden:YES];
  } else {
    // Commerce item has been added on some other site, display label with this site name.
    [[self siteNameLabel] setHidden:NO];
    NSString *siteFormat = NSLocalizedStringWithDefaultValue
    (@"ATGOrderItemTableViewCell.SiteNameFormat",
     nil, [NSBundle mainBundle], @"from %@",
     @"This format would be used by the ShoppingCart screen when rendering commerce item from "
     @"another site. Format's parameter is site name.");
    [[self siteNameLabel] setText:[NSString stringWithFormat:siteFormat, [[self item] siteName]]];
    // Place site name label at the very bottom of the cell.
    CGRect siteNameFrame = [[self siteNameLabel] frame];
    CGRect previousLabelFrame = [[self nameLabel] frame];
    if ([[[self propertiesLabel] text] length] > 0) {
      previousLabelFrame = [[self propertiesLabel] frame];
    }
    siteNameFrame.origin.y = previousLabelFrame.origin.y + previousLabelFrame.size.height;
    [[self siteNameLabel] setFrame:siteNameFrame];
  }
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  [self layoutSubviews];
  
  CGRect propertiesFrame = [[self nameLabel] frame];
  if ([[[self propertiesLabel] text] length] > 0) {
    propertiesFrame = [[self propertiesLabel] frame];
  }
  if (![[self siteNameLabel] isHidden]) {
    propertiesFrame = [[self siteNameLabel] frame];
  }
  
  CGFloat heightByProperties = propertiesFrame.origin.y + propertiesFrame.size.height + [self insets].bottom;
  CGRect priceFrame = [[self priceLabel] frame];
  CGFloat heightByPrices = [self insets].top +
  [[[self item] unitPrices] count] * priceFrame.size.height +
  [self insets].bottom;
  return CGSizeMake( pSize.width, MAX(heightByPrices, heightByProperties) );
}

#pragma mark - ATGOrderItemTableViewCell Private Protocol Implementation

- (void) fitStrings:(NSArray *)pStrings intoLabel:(UILabel *)pLabel {
  // Container to hold actual string widthes.
  CGFloat *maxWidth = calloc( [pStrings count], sizeof(CGFloat) );
  // Container to hold output string widthes.
  CGFloat *resultWidth = calloc( [pStrings count], sizeof(CGFloat) );
  NSInteger i = 0;
  // Calculate actual string widthes.
  for (NSString *property in pStrings) {
    CGSize textSize = [property sizeWithFont:[pLabel font]];
    maxWidth[i++] = textSize.width;
  }
  // How many properties are we going to fit?
  NSInteger totalProperties = [pStrings count];
  // How many properties remained?
  NSInteger propertiesRemained = totalProperties;
  // How much space do we have?
  CGFloat totalWidth = [pLabel bounds].size.width;
  // Standard delimiter to be used to separate property values, should not be localized.
  NSString *delimiter = @", ";
  // And its width.
  CGFloat delimiterWidth = [delimiter sizeWithFont:[pLabel font]].width;
  // We will fit all properties specified.
  while (propertiesRemained > 0) {
    // This flag indicates that some property is displayed entirely.
    BOOL somePropertyUpdated = NO;
    // Main loop through all properties.
    for (NSInteger i = 0; i < totalProperties; i++) {
      // Modify unmodified properties only.
      if (!resultWidth[i]) {
        // Is there enough space to fit the property? All properties are equal,
        // so divide the space available between properties equally.
        if (maxWidth[i] <= (totalWidth - (propertiesRemained - 1) * delimiterWidth) / propertiesRemained) {
          // It fits! Save the result.
          resultWidth[i] = maxWidth[i];
          // One less property to be fitted.
          propertiesRemained--;
          // And we have less space left.
          totalWidth -= delimiterWidth + maxWidth[i];
          // Save the flag.
          somePropertyUpdated = YES;
        }
      }
    }
    // If we have displayed a property in its entirety, try to fit all other properties into the remaining
    // space. Otherwise divide the remaining space equally between the remaining properties and exit the loop.
    if (!somePropertyUpdated) {
      // Otherwise divide the space remained between properties equally.
      for (NSInteger i = 0; i < totalProperties; i++) {
        // Update unmodified properties only.
        if (!resultWidth[i]) {
          // Equal part of space to be used by the property.
          resultWidth[i] = (totalWidth - (propertiesRemained - 1) * delimiterWidth) / propertiesRemained;
        }
      }
      // At this point we should fit all properties specified. Just exit the loop.
      propertiesRemained = 0;
    }
  }
  // Now we will set the label's text. Start with empty string, we will add
  // property values one by one.
  [pLabel setText:@""];
  // Loop through all the properties specified.
  for (i = 0; i < totalProperties; i++) {
    // The whole property value.
    NSString *property = (NSString *)[pStrings objectAtIndex:i];
    // Will we display it entirely?
    if (resultWidth[i] != maxWidth[i]) {
      // No, trim the value to fit its room.
      for (NSInteger length = [property length]; length > 0; length--) {
        // Cut the value from the tail and append dots.
        // This will produce an actual string we will display to user.
        NSString *trimmed = [property substringToIndex:length];
        // Standard trim-replacement characters. Should not be localized.
        trimmed = [trimmed stringByAppendingString:@"..."];
        // Does the trimmed string fits the space allocated?
        if ([trimmed sizeWithFont:[pLabel font]].width <= resultWidth[i]) {
          // Yes, save the trimmed value and exit the trimming loop.
          property = trimmed;
          break;
        }
        // If the trimmed string doesn't fit the space allocated, just cut one more char.
      }
    }
    // Update the label's text, append current property value.
    [pLabel setText:[[pLabel text] stringByAppendingString:property]];
    if (i < totalProperties - 1) {
      [pLabel setText:[[pLabel text] stringByAppendingString:delimiter]];
    }
  }
  // Free memory chunks allocated with calloc() calls.
  free(maxWidth);
  free(resultWidth);
}

@end
