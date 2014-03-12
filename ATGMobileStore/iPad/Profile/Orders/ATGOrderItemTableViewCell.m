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

#import "ATGOrderItemTableViewCell.h"
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGReturnItem.h>
#import <ATGUIElements/ATGImageView.h>
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGMobileClient/ATGReturnManager.h>
#import "ATGReturnsConfigurationTableViewCell.h"

#pragma mark - ATGOrderItemTableViewCell Private Protocol Definition
#pragma mark -

#define CAPTION_AND_LABEL_PADDING 5.0

@interface ATGOrderItemTableViewCell () <UIActionSheetDelegate>

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *skuCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *skuLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *quantityCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *quantityLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *sizeCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *sizeLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *colorCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *colorLabel;

@property (nonatomic, readwrite, weak) IBOutlet ATGImageView *productImageView;


@property (nonatomic, readwrite, weak) IBOutlet UILabel *priceCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *priceLabel;

@property (nonatomic, readwrite, weak) IBOutlet UILabel *reasonCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *reasonLabel;

@property (nonatomic, readwrite, weak) IBOutlet UILabel *refundCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *refundLabel;

@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *siteLabel;

@property (nonatomic, readwrite, weak) IBOutlet UILabel *statusCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, readwrite, weak) IBOutlet UITableView *returnsTable;
#pragma mark - Custom Properties
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) UIActionSheet *reasonActionSheet;
@property (nonatomic, weak) ATGCommerceItem *commerceItem;
@property (nonatomic, weak) ATGReturnItem *returnItem;

@end

#pragma mark - ATGOrderItemTableViewCell Implementation
#pragma mark -

@implementation ATGOrderItemTableViewCell

#pragma mark - Custom Properties

- (void) setCurrencyCode:(NSString *)pCurrencyCode {
  [[self priceFormatter] setCurrencyCode:pCurrencyCode];
  _currencyCode = [pCurrencyCode copy];
}

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  //Localized Text
  NSString *localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.SkuCaptionLabel", nil, [NSBundle mainBundle], @"SKU #:", @"Prefix for sku which the product has");
  [[self skuCaptionLabel] setText:localizedText];
  self.skuCaptionLabel.frame = [self.skuCaptionLabel textRectForBounds:self.skuCaptionLabel.frame limitedToNumberOfLines:1];
  self.skuLabel.left = self.skuCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.QuantityCaptionLabel", nil, [NSBundle mainBundle], @"Quantity:", @"Prefix for quantity of which was ordererd");
  [[self quantityCaptionLabel] setText:localizedText];
  self.quantityCaptionLabel.frame = [self.quantityCaptionLabel textRectForBounds:self.quantityCaptionLabel.frame limitedToNumberOfLines:1];
  self.quantityLabel.left = self.quantityCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.SizeCaptionLabel", nil, [NSBundle mainBundle], @"Size:", @"Prefix for size of the product that was ordererd");
  [[self sizeCaptionLabel] setText:localizedText];
  self.sizeCaptionLabel.frame = [self.sizeCaptionLabel textRectForBounds:self.sizeCaptionLabel.frame limitedToNumberOfLines:1];
  self.sizeLabel.left = self.sizeCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ColorCaptionLabel", nil, [NSBundle mainBundle], @"Color:", @"Prefix for color of the product that was ordererd");
  [[self colorCaptionLabel] setText:localizedText];
  self.colorCaptionLabel.frame = [self.colorCaptionLabel textRectForBounds:self.colorCaptionLabel.frame limitedToNumberOfLines:1];
  self.colorLabel.left = self.colorCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.PriceCaptionLabel", nil, [NSBundle mainBundle], @"Price:", @"Prefix for price of the product that was ordererd");
  [[self priceCaptionLabel] setText:localizedText];
  self.priceCaptionLabel.frame = [self.priceCaptionLabel textRectForBounds:self.priceCaptionLabel.frame limitedToNumberOfLines:1];
  self.priceLabel.left = self.priceCaptionLabel.right + CAPTION_AND_LABEL_PADDING;

  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.RefundCaptionLabel", nil, [NSBundle mainBundle], @"Refund:", @"Prefix for refund amount of the product that was returned");
  [[self refundCaptionLabel] setText:localizedText];
  self.refundCaptionLabel.frame = [self.refundCaptionLabel textRectForBounds:self.refundCaptionLabel.frame limitedToNumberOfLines:1];
  self.refundLabel.left = self.refundCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReasonCaptionLabel", nil, [NSBundle mainBundle], @"Reason:", @"Prefix for reason why the product was returned");
  [[self reasonCaptionLabel] setText:localizedText];
  self.reasonCaptionLabel.frame = [self.reasonCaptionLabel textRectForBounds:self.reasonCaptionLabel.frame limitedToNumberOfLines:1];
  self.reasonLabel.left = self.reasonCaptionLabel.right + CAPTION_AND_LABEL_PADDING;

  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.SiteCaptionLabel", nil, [NSBundle mainBundle], @"Site:", @"Prefix for site of the product that was ordererd");
  [[self siteCaptionLabel] setText:localizedText];
  self.siteCaptionLabel.frame = [self.siteCaptionLabel textRectForBounds:self.siteCaptionLabel.frame limitedToNumberOfLines:1];
  self.siteLabel.left = self.siteCaptionLabel.right + CAPTION_AND_LABEL_PADDING;
  
  localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.StatusCaptionLabel", nil, [NSBundle mainBundle], @"Status:", @"Prefix for status of the product that was returned");
  [[self statusCaptionLabel] setText:localizedText];
  self.statusCaptionLabel.frame = [self.statusCaptionLabel textRectForBounds:self.statusCaptionLabel.frame limitedToNumberOfLines:1];
  self.statusLabel.left = self.statusCaptionLabel.right + CAPTION_AND_LABEL_PADDING;

  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [self setPriceFormatter:formatter];

  formatter = [[NSNumberFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [self setNumberFormatter:formatter];
  
  UIView *underlay = [[UIView alloc] initWithFrame:CGRectMake(7, 5, 116, 116)];
  underlay.layer.cornerRadius = 8.0;
  underlay.backgroundColor = [UIColor whiteColor];
  [self.contentView insertSubview:underlay belowSubview:self.productImageView];
  
  UIImageView *imageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product-image-box-for-iphone"]];
  imageOverlay.frame = CGRectMake(7, 5, 116, 116);
  [self.contentView addSubview:imageOverlay];
}

// get the quantity to display from a return item, depending on the context
- (NSString *)getQuantityForDisplayFromReturnItem:(ATGReturnItem *)pReturnItem {
  if ([self.reuseIdentifier isEqualToString:@"ATGOrderItemReturnConfigureCell"]) {
    return [pReturnItem.commerceItem.qty stringValue];
  }
  return pReturnItem.quantityToReturn ? [pReturnItem.quantityToReturn stringValue] : [pReturnItem.commerceItem.qty stringValue];
}

- (void)setObject:(id)object {
  ATGCommerceItem *item;
  if ([object isKindOfClass:[ATGReturnItem class]]) {
    item = ((ATGReturnItem *)object).commerceItem;
    self.returnItem = (ATGReturnItem *)object;
    self.reasonLabel.text = self.returnItem.returnReasonDescription ? self.returnItem.returnReasonDescription : [[[ATGReturnManager instance] returnReasons] objectForKey:self.returnItem.returnReason];
    self.quantityLabel.text = [self getQuantityForDisplayFromReturnItem:self.returnItem];
    self.refundLabel.text = [self.priceFormatter stringFromNumber:self.returnItem.refundAmount];
    [self.returnsTable reloadData];
  } else {
    item = (ATGCommerceItem *)object;
    self.quantityLabel.text = [NSString stringWithFormat:@"%i", item.totalQuantity];
  }
  self.commerceItem = item;
  self.accessoryView.hidden = !item.isNavigableProduct;
  self.skuLabel.text = item.sku.repositoryId;
  if (item.sku.size) {
    self.sizeLabel.text = item.sku.size;
  } else {
    self.sizeCaptionLabel.hidden = TRUE;
    self.sizeLabel.hidden = TRUE;
  }
  if (item.sku.woodFinish) {
    NSString *localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.WoodFinishCaptionLabel", nil, [NSBundle mainBundle], @"Wood Finish:", @"Prefix for wood finish of the product that was ordererd");
    [[self colorCaptionLabel] setText:localizedText];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
      self.colorCaptionLabel.frame = [self.colorCaptionLabel textRectForBounds:CGRectMake(130, 67, 106, 11) limitedToNumberOfLines:1];
    }
    self.colorLabel.left = self.colorCaptionLabel.right+ 5.0;
    self.colorLabel.text = item.sku.woodFinish;
  } else if (item.sku.color) {
    NSString *localizedText = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ColorCaptionLabel", nil, [NSBundle mainBundle], @"Color:", @"Prefix for color of the product that was ordererd");
    [[self colorCaptionLabel] setText:localizedText];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
      self.colorCaptionLabel.frame = [self.colorCaptionLabel textRectForBounds:self.colorCaptionLabel.frame limitedToNumberOfLines:1];
    }
    self.colorLabel.left = self.colorCaptionLabel.right + 5.0;
    self.colorLabel.text = item.sku.color;
  }
  self.siteLabel.text = item.siteName;
  self.priceLabel.text = [self.priceFormatter stringFromNumber:item.totalPrice];
  self.productNameLabel.text = item.sku.displayName;
  self.productImageView.imageURL = [ATGRestManager getAbsoluteImageString:item.thumbnailImage];
}

#pragma mark -
#pragma mark RETURNS REASON TABLE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ([self.reuseIdentifier isEqualToString:@"ATGOrderItemNonReturnableCell"] ? 1 : 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    ATGReturnsConfigurationTableViewCell *cell;
    if ([self.reuseIdentifier isEqualToString:@"ATGOrderItemReturnConfigureImmutableCell"]) {
      cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCellImmutableQuantity"];
      cell.captionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnQuantityCaption", nil, [NSBundle mainBundle], @"Return Quantity", @"When in return mode, show this as the caption for prefacing return quantitiy");
      cell.detailLabel.text = [(self.returnItem.quantityToReturn ? self.returnItem.quantityToReturn : @0) stringValue];
      return cell;
    } else if ([self.reuseIdentifier isEqualToString:@"ATGOrderItemNonReturnableCell"]) {
      cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCellImmutableNonReturnableReason"];
      cell.detailLabel.text = self.returnItem.commerceItem.returnableDescription;
      return cell; //TODO: confifure this with the non-return reason
    } else {
      cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCellQuantity"];
      cell.captionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnQuantityCaption", nil, [NSBundle mainBundle], @"Return Quantity", @"When in return mode, show this as the caption for prefacing return quantitiy");
      cell.detailLabel.text = [(self.returnItem.quantityToReturn ? self.returnItem.quantityToReturn : @0) stringValue];
      cell.quantityStepper.minimumValue = 0;
      cell.quantityStepper.maximumValue = [self.commerceItem.qty integerValue];
      [cell.quantityStepper addTarget:self action:@selector(updateQuantity:) forControlEvents:UIControlEventValueChanged];
      return cell;
    }
  } else {
    ATGReturnsConfigurationTableViewCell *cell;
    if ([self.reuseIdentifier isEqualToString:@"ATGOrderItemReturnConfigureImmutableCell"]) {
      cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCellImmutableReason"];
    } else {
      cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCell"];
    }
    cell.captionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonCaption", nil, [NSBundle mainBundle], @"Return Reason", @"When in return mode, show this as the caption for prefacing return reason");
    cell.detailLabel.text = (self.returnItem.returnReasonDescription.length > 0 ? self.returnItem.returnReasonDescription : NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.SelectReasonCaption", nil, [NSBundle mainBundle], @"Select Reason", @"When in return mode, show this as the caption for selecting return reason"));
    return cell;
  }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.row > 0 && ![self.reuseIdentifier isEqualToString:@"ATGOrderItemReturnConfigureImmutableCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row > 0) {
    self.reasonActionSheet = [[UIActionSheet alloc] init];
    self.reasonActionSheet.title = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalSelectPrompt", nil, [NSBundle mainBundle], @"Select Reason", @"When in return mode, show this as the prompt for selecting return reason");
    self.reasonActionSheet.delegate = self;
    for (NSString *reason in [[ATGReturnManager instance].returnReasons allValues]) {
      [self.reasonActionSheet addButtonWithTitle:reason];
    }
    [self.reasonActionSheet addButtonWithTitle:NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalCancelButtonTitle", nil, [NSBundle mainBundle], @"Cancel", @"When in return mode, show this as the title for cancel selection of return reason")];
    self.reasonActionSheet.cancelButtonIndex = [[ATGReturnManager instance].returnReasons allValues].count;
    ATGReturnsConfigurationTableViewCell *cell = (ATGReturnsConfigurationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.reasonActionSheet showInView:cell];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex != actionSheet.cancelButtonIndex) {
    self.returnItem.returnReasonDescription = [actionSheet buttonTitleAtIndex:buttonIndex];
    // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
    id view = [self superview];
    while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
      view = [view superview];
    }
    [(UITableView *)view reloadData];
  }
}

- (void)updateQuantity:(id)sender {
  UIStepper *stepper = (UIStepper *)sender;
  self.returnItem.quantityToReturn = [NSNumber numberWithDouble:stepper.value];

  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }
  [(UITableView *)view reloadData];
}


@end