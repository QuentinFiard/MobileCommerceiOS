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

#import "ATGCartTableViewCell.h"
#import <ATGUIElements/ATGImageView.h>
#import <ATGUIElements/ATGPrefixLabel.h>
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileClient/ATGRestManager.h>

static NSString *const ATGQuantityKey = @"quantity";
static NSString *const ATGPriceKey = @"unitPrice";
static NSString *const ATGPriceQuantityDelimiter = @"x";
static const CGFloat ATGRightInset = 7;
static const CGFloat ATGInnerInset = 5;

#pragma mark - ATGCartTableViewCell Private Protocol
#pragma mark -

@interface ATGCartTableViewCell ()

#pragma mark - IB Outlets

// UI elements displayed when the cell is not selected.
@property (nonatomic, readwrite, weak) IBOutlet UIView *contentDefaultView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameDefaultLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *skuPropertiesDefaultLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productDefaultImage;
// UI elements displayed when the cell is selected.
@property (nonatomic, readwrite, weak) IBOutlet UIView *contentSelectedView;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameSelectedLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *skuPropertiesSelectedLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productSelectedImage;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *editSKUButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet ATGPrefixLabel *quantitySelectedLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) NSNumberFormatter *quantityFormatter;

#pragma mark - UI Event Handlers

- (IBAction)didTouchShareButton:(id)sender;
- (IBAction)didTouchRemoveButton:(id)sender;
- (IBAction)didTouchEditSKUButton:(id)sender;

#pragma mark - Private Protocol Definition

- (void)setQuantity:(NSUInteger)quantity;
- (void)fitStrings:(NSArray *)pStrings intoLabel:(UILabel *)pLabel
    addEndingComma:(BOOL)addEndingComma;

@end

#pragma mark - ATGCartTableViewCell
#pragma mark -

@implementation ATGCartTableViewCell

#pragma mark - Properties

@synthesize productName;
@synthesize oldPrice;
@synthesize SKUProperties;
@synthesize imageURL;
@synthesize currencyCode;
@synthesize itemId;
@synthesize skuId;
@synthesize productId;
@synthesize delegate;
@synthesize priceBeans;
@synthesize quantity;
@synthesize priceFormatter;
@synthesize quantityFormatter;
@synthesize contentDefaultView;
@synthesize productNameDefaultLabel;
@synthesize skuPropertiesDefaultLabel;
@synthesize productDefaultImage;
@synthesize contentSelectedView;
@synthesize productNameSelectedLabel;
@synthesize skuPropertiesSelectedLabel;
@synthesize productSelectedImage;
@synthesize editSKUButton;
@synthesize shareButton;
@synthesize removeButton;
@synthesize quantitySelectedLabel;

#pragma mark - Custom Properties Setter Methods

- (void)setProductName:(NSString *)pProductName {
  if (pProductName != self->productName) {
    self->productName = [pProductName copy];
    // Update labels to display proper value.
    [[self productNameDefaultLabel] setText:[self productName]];
    [[self productNameSelectedLabel] setText:[self productName]];
  }
}

- (void)setOldPrice:(NSDecimalNumber *)pOldPrice {
  if (pOldPrice != self->oldPrice) {
    self->oldPrice = pOldPrice;
    // We need to re-layout self, because old price has changed.
    // Maybe we have to hide/show the old price label?
    [self setNeedsLayout];
  }
}

- (void)setImageURL:(NSString *)pImageURL {
  if (pImageURL != self->imageURL) {
    self->imageURL = [pImageURL copy];
    // Start loading product image from server.
    [[self productDefaultImage] setImageURL:[ATGRestManager getAbsoluteImageString:[self imageURL]]];
    [[self productSelectedImage] setImageURL:[ATGRestManager getAbsoluteImageString:[self imageURL]]];
  }
}

- (void)setSKUProperties:(NSArray *)pSKUProperties {
  if (pSKUProperties != self->SKUProperties) {
    self->SKUProperties = [pSKUProperties copy];
    // Fit all SKU properties into the properties labels.
    [self fitStrings:[self SKUProperties] intoLabel:[self skuPropertiesDefaultLabel] addEndingComma:NO];
    [self fitStrings:[self SKUProperties] intoLabel:[self skuPropertiesSelectedLabel] addEndingComma:YES];
    
    // Place selected quantity label next to SKU properties.
    CGRect skuPropertiesFrame = [[self skuPropertiesSelectedLabel] frame];
    CGSize skuPropertiesSize = [[[self skuPropertiesSelectedLabel] text]
                                sizeWithFont:[[self skuPropertiesSelectedLabel] font]];
    CGRect frame = [[self quantitySelectedLabel] frame];
    frame.origin.x = skuPropertiesFrame.origin.x + skuPropertiesSize.width;
    [[self quantitySelectedLabel] setFrame:frame];
  }
}

- (void)setCurrencyCode:(NSString *)pCurrencyCode {
  if (pCurrencyCode != self->currencyCode) {
    self->currencyCode = [pCurrencyCode copy];
    // Update formatter.
    [[self priceFormatter] setCurrencyCode:[self currencyCode]];
    // Update all price-related labels, this will re-calculate values with proper locale.
    [self setOldPrice:[self oldPrice]];
    [self setPriceBeans:[self priceBeans]];
  }
}

- (void)setQuantity:(NSUInteger)pQuantity {
  self->quantity = pQuantity;
  NSString *quantityString = [[self quantityFormatter]
                              stringFromNumber:[NSNumber numberWithInteger:pQuantity]];
  [[self quantitySelectedLabel] setText:quantityString];
  [self setNeedsLayout];
}

- (void)setPriceBeans:(NSArray *)pPriceBeans {
  if (self->priceBeans != pPriceBeans) {
    self->priceBeans = [pPriceBeans copy];
  }
  NSInteger totalQuantity = 0;
  for (NSDictionary *unitPrice in [self priceBeans]) {
    NSNumber *unitQuantity = [unitPrice objectForKey:ATGQuantityKey];
    totalQuantity += [unitQuantity integerValue];
  }
  [self setQuantity:totalQuantity];
  
  for (UIView *subview in[[self contentDefaultView] subviews]) {
    if (subview != [self productNameDefaultLabel] &&
        subview != [self skuPropertiesDefaultLabel] &&
        subview != [self productDefaultImage]) {
      [subview removeFromSuperview];
    }
  }
  
  CGFloat totalHeight = 0;
  CGSize boundsSize = [[self contentDefaultView] bounds].size;
  CGFloat minOrigin = boundsSize.width;
  NSMutableArray *allLabels = [[NSMutableArray alloc] init];
  for (NSDictionary *priceBean in [self priceBeans]) {
    NSNumber *unitQuantity = [priceBean objectForKey:ATGQuantityKey];
    NSNumber *price = [priceBean objectForKey:ATGPriceKey];
    ATGPrefixLabel *priceLabel =
    [[ATGPrefixLabel alloc] initWithFrame:[[self contentView] bounds]];
    [priceLabel applyStyleWithName:@"searchPriceLabel"];
    [priceLabel setPrefix:ATGPriceQuantityDelimiter];
    [priceLabel setPrefixColor:[UIColor textColor]];
    [priceLabel setText:[[self priceFormatter] stringFromNumber:price]];
    CGSize labelSize = [priceLabel sizeThatFits:CGSizeZero];
    CGRect labelFrame = CGRectMake(boundsSize.width - ATGRightInset - labelSize.width,
                                   totalHeight, labelSize.width, labelSize.height);
    [priceLabel setFrame:labelFrame];
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [allLabels addObject:priceLabel];
    
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:[[self contentView] bounds]];
    [quantityLabel applyStyleWithName:@"searchPriceLabel"];
    [quantityLabel setText:[[self quantityFormatter] stringFromNumber:unitQuantity]];
    labelSize = [[quantityLabel text] sizeWithFont:[quantityLabel font]];
    labelFrame = CGRectMake(labelFrame.origin.x - ATGInnerInset - labelSize.width,
                            totalHeight, labelSize.width, labelSize.height);
    [quantityLabel setFrame:labelFrame];
    [quantityLabel setBackgroundColor:[UIColor clearColor]];
    // Insert quantity label before price label to make screen reader read cell properly.
    [allLabels insertObject:quantityLabel atIndex:[allLabels indexOfObject:priceLabel]];
    
    minOrigin = MIN(minOrigin, labelFrame.origin.x);
    totalHeight += labelSize.height;
    
    if (![price isEqualToNumber:[self oldPrice]]) {
      ATGPrefixLabel *oldPriceLabel = [[ATGPrefixLabel alloc] init];
      [oldPriceLabel applyStyleWithName:@"formTextLabel"];
      NSString *prefix = NSLocalizedStringWithDefaultValue
      (@"ATGCartTableViewCell.OldPricePrefix", nil, [NSBundle mainBundle],
       @"was", @"Prefix to be displayed before list price value.");
      [oldPriceLabel setPrefix:prefix];
      [oldPriceLabel setText:[[self priceFormatter] stringFromNumber:[self oldPrice]]];
      [oldPriceLabel setTextStrikeThrough:YES];
      labelSize = [oldPriceLabel sizeThatFits:CGSizeZero];
      labelFrame = CGRectMake(boundsSize.width - ATGRightInset - labelSize.width,
                              totalHeight, labelSize.width, labelSize.height);
      [oldPriceLabel setFrame:labelFrame];
      [oldPriceLabel setBackgroundColor:[UIColor clearColor]];
      [allLabels addObject:oldPriceLabel];
      
      totalHeight += labelSize.height;
      minOrigin = MIN(minOrigin, labelFrame.origin.x);
    }
  }
  for (UIView *view in allLabels) {
    CGRect frame = [view frame];
    frame.origin.y += (boundsSize.height - totalHeight) / 2;
    [view setFrame:frame];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleBottomMargin];
    [[self contentDefaultView] addSubview:view];
  }
  
  CGRect frame = [[self productNameDefaultLabel] frame];
  frame.size.width = minOrigin - ATGInnerInset - frame.origin.x;
  [[self productNameDefaultLabel] setFrame:frame];
  
  frame = [[self skuPropertiesDefaultLabel] frame];
  frame.size.width = minOrigin - ATGInnerInset - frame.origin.x;
  [[self skuPropertiesDefaultLabel] setFrame:frame];
  [self fitStrings:[self SKUProperties] intoLabel:[self skuPropertiesDefaultLabel] addEndingComma:NO];
}

-(void)setIsNavigable:(BOOL)isNavigable
{
  _isNavigable = isNavigable;
  if (!_isNavigable)
  {
    [self.editSKUButton setEnabled:NO];
    [self.shareButton setHidden:YES];
  }
}

#pragma mark - Instance Management

- (id)initWithStyle:(UITableViewCellStyle)pStyle reuseIdentifier:(NSString *)pReuseIdentifier {
  self = [super initWithStyle:pStyle reuseIdentifier:pReuseIdentifier];
  if (self) {
    // Do not highlight the cell when it's selected.
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    // Cell views are located in a NIB file. Get them. And tell the NIB proper owner.
    [[NSBundle mainBundle] loadNibNamed:@"ATGCartTableViewCell" owner:self options:nil];

    // mViewContentDefault and mViewContentSelected are set from NIB file.
    [[self contentView] addSubview:[self contentDefaultView]];
    CGRect frame = [[self contentDefaultView] frame];
    frame.size.width = [[self contentView] bounds].size.width;
    [[self contentDefaultView] setFrame:frame];
    [[self contentView] addSubview:[self contentSelectedView]];
    [[self contentView] setClipsToBounds:YES];

    // Edit SKU should be a round-rect button.
    [[[self editSKUButton] layer] setBorderColor:[[UIColor borderColor] CGColor]];
    [[[self editSKUButton] layer] setBorderWidth:1];
    [[[self editSKUButton] layer] setCornerRadius:[[self editSKUButton] bounds].size.height / 2];

    [[self productNameDefaultLabel] setAccessibilityHint:NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.CellAccessibilityHint", nil, [NSBundle mainBundle],
         @"Double tap to expand options", @"Accessibility hint used by cart cell.")];

    // Update the Quantity label of the Edit SKU button with proper prefix.
    NSString *quantityPrefix = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.QuantityPrefix", nil, [NSBundle mainBundle], @"Qty.",
         @"Prefix to be displayed before quantity, if the cell is selected.");
    [[self quantitySelectedLabel] setPrefix:quantityPrefix];
    [[self quantitySelectedLabel] setPrefixColor:[UIColor borderColor]];
    [[self quantitySelectedLabel] applyStyleWithName:@"formFieldLabel"];

    // Create a number formatter to be used when calculating price strings.
    [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
    [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self priceFormatter] setLocale:[NSLocale currentLocale]];

    // Create a number formatter to be used when calculating quantity strings.
    [self setQuantityFormatter:[[NSNumberFormatter alloc] init]];
    [[self quantityFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
    // By default, use the US locale.
    [[self quantityFormatter] setLocale:[NSLocale currentLocale]];

    NSString *editButtonLabel = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.EditSkuAccessibilityLabel", nil, [NSBundle mainBundle],
         @"Edit", @"Accessibility label to be used by 'Edit SKU' button.");
    [[self editSKUButton] setAccessibilityLabel:editButtonLabel];
    NSString *editButtonHint = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.EditSkuAccessibilityHint", nil, [NSBundle mainBundle],
         @"Allows you to change product selection.",
         @"Accessibility hint to be used by 'Edit SKU' button.");
    [[self editSKUButton] setAccessibilityHint:editButtonHint];

    NSString *shareButtonLabel = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.ShareAccessibilityLabel", nil, [NSBundle mainBundle],
         @"Share", @"Accessibility label to be used by 'Share' button.");
    [[self shareButton] setAccessibilityLabel:shareButtonLabel];
    NSString *shareButtonHint = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.ShareAccessibilityHint", nil, [NSBundle mainBundle],
         @"Opens Email application to compose a letter.",
         @"Accessibility hint to be used by 'Share' button.");
    [[self shareButton] setAccessibilityHint:shareButtonHint];

    NSString *removeButtonLabel = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.RemoveAccessibilityLabel", nil, [NSBundle mainBundle],
         @"Remove", @"Accessibility label to be used by 'Remove' button.");
    [[self removeButton] setAccessibilityLabel:removeButtonLabel];
    NSString *removeButtonHint = NSLocalizedStringWithDefaultValue
        (@"ATGCartTableViewCell.RemoveAccessibilityHint", nil, [NSBundle mainBundle],
         @"Removes an item from cart.",
         @"Accessibility hint to be used by 'Remove' button.");
    [[self removeButton] setAccessibilityHint:removeButtonHint];
    
    // apply styles
    [self.productNameDefaultLabel applyStyleWithName:@"smallProductTitleLabel"];
    [self.skuPropertiesDefaultLabel applyStyleWithName:@"formFieldLabel"];
    [self.productNameSelectedLabel applyStyleWithName:@"productTitleLabel"];
    [self.skuPropertiesSelectedLabel applyStyleWithName:@"formFieldLabel"];
  }
  return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  // Choose proper view to be displayed based on the selection mode.
  UIView *fromView = [self isSelected] ? [self contentDefaultView] : [self contentSelectedView];
  UIView *toView = [self isSelected] ? [self contentSelectedView] : [self contentDefaultView];
  [toView setAlpha:1];
  [fromView setAlpha:0];
}

#pragma mark - UITableViewCell

- (void)setSelected:(BOOL)pSelected animated:(BOOL)pAnimated {
  [super setSelected:pSelected animated:pAnimated];
  [self setNeedsLayout];
  if (pSelected) {
    [self setBackgroundColor:[UIColor cartTableCellSelectedBackgroundColor]];
  } else {
    [self setBackgroundColor:[UIColor tableCellBackgroundColor]];
  }
}

- (void)setHighlighted:(BOOL)pHighlighted animated:(BOOL)pAnimated {
  // Prevent highlighting of the cell.
  // Highlighting triggers preemptive layoutSubviews method calls; and this breaks
  // all animations.
  [super setHighlighted:NO animated:NO];
}

#pragma mark - ATGExpandableTableViewCell

- (CGFloat)expandedHeight {
  // How many space do we need when the selected view is on the screen?
  return [[self contentSelectedView] bounds].size.height;
}

#pragma mark - UI Event Handlers

- (IBAction)didTouchShareButton:(id)pSender {
  [[self delegate] cartTableViewCell:self didTouchShareButton:pSender];
}

- (IBAction)didTouchRemoveButton:(id)pSender {
  [[self delegate] cartTableViewCell:self didTouchRemoveButton:pSender];
}

- (IBAction)didTouchEditSKUButton:(id)pSender {
  [[self delegate] cartTableViewCell:self didTouchEditSkuButton:pSender];
}

#pragma mark - Private Protocol Implementation

// This method tries to fit the strings specified into a singla label.
- (void)fitStrings:(NSArray *)pStrings intoLabel:(UILabel *)pLabel
    addEndingComma:(BOOL)addEndingComma {
  // Container to hold actual string widthes.
  CGFloat *maxWidth = calloc([pStrings count], sizeof(CGFloat));
  // Container to hold output string widthes.
  CGFloat *resultWidth = calloc([pStrings count], sizeof(CGFloat));
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
      // Modifly unmodified properties only.
      if (!resultWidth[i]) {
        // Is there enough space to fit the property? All properties are equal,
        // so divide the space available between properties equally.
        if (maxWidth[i] <= (totalWidth - (propertiesRemained - (addEndingComma ? 0 : 1)) *
                            delimiterWidth) / propertiesRemained) {
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
    // If we have displayed some property entirelly, try to fit all other properties
    // into space remained. Otherwise divide the remained space between the properties
    // remained equally and exit the loop.
    if (!somePropertyUpdated) {
      // Otherwise divide the space remained between properties equally.
      for (NSInteger i = 0; i < totalProperties; i++) {
        // Update unmodified properties only.
        if (!resultWidth[i]) {
          // Equal part of space to be used by the property.
          resultWidth[i] = (totalWidth - (propertiesRemained - (addEndingComma ? 0 : 1)) *
                            delimiterWidth) / propertiesRemained;
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
    // Add a delimiter between properties.
    if (addEndingComma || (i != totalProperties - 1)) {
      property = [property stringByAppendingString:delimiter];
    }
    // Update the label's text, append current property value.
    [pLabel setText:[[pLabel text] stringByAppendingString:property]];
  }
  // Free memory chunks allocated with calloc() calls.
  free(maxWidth);
  free(resultWidth);
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement {
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger)accessibilityElementCount {
  return [self isSelected] ? [[[self contentSelectedView] subviews] count] :
         [[[self contentDefaultView] subviews] count];
}

- (NSInteger)indexOfAccessibilityElement:(id)pElement {
  if ([self isSelected]) {
    return [[[self contentSelectedView] subviews] indexOfObject:pElement];
  } else {
    return [[[self contentDefaultView] subviews] indexOfObject:pElement];
  }
}

- (id)accessibilityElementAtIndex:(NSInteger)pIndex {
  if ([self isSelected]) {
    return [[[self contentSelectedView] subviews] objectAtIndex:pIndex];
  } else {
    return [[[self contentDefaultView] subviews] objectAtIndex:pIndex];
  }
}

@end