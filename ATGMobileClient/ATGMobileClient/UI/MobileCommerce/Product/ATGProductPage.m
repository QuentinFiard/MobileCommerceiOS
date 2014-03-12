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

#import "ATGProductPage.h"
#import <ATGUIElements/ATGImageView.h>
#import "ATGProductDescription.h"
#import <ATGUIElements/ATGButton.h>
#import "ATGSkuInventory.h"
#import <ATGMobileClient/ATGGridCollectionView.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGRestManager.h>

static NSString *const ATGHTMLStringHeader = @"<html><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no\"/><head><style type=\"text/css\">#outer {display: table;height:100px; position: static;}#middle {display: table-cell; vertical-align: middle; width: 100%;}#inner {position: relative; top: -50%;width:145px;}p{text-align:center;margin-top: 0px;margin-bottom: 20px;}#price { font-family:Helvetica; font-size:17px; color:B75A00;} #delimeter { font-family:Verdana;font-size: 11px; color:#516691;} #wasPrice { font-family:Verdana;font-size: 11px; color:#516691; text-decoration:line-through;}</style></head>";
static NSString *const ATGHTMLStringBody = @"<body><div id=\"outer\"><div id=\"middle\"><div id=\"inner\">%@</div></div></div></body></html>";

const CGFloat ATGObjHeight  = 60.0;
const CGFloat ATGObjWidth = 80.0;
const CGFloat ATGImageHeight = 300;
const CGFloat ATGImageWidth = 175;
NSString *const ATGFramePropertyName = @"frame";

#pragma mark - NSString Category implementation
#pragma mark -
@implementation NSString (SortCompare)

- (NSInteger) stringCompare:(NSString *)pStr2 {
  return [(NSString *) self localizedCaseInsensitiveCompare:pStr2];
}

- (NSInteger) sizeCompare:(NSString *)pStr2 {
  NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], nil] forKeys:[NSArray arrayWithObjects:@"XS", @"S", @"M", @"L", @"XL", @"XXL", @"XXXL", @"XXXXL", nil]];
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *num2 = [formatter numberFromString:pStr2];
  NSNumber *num1;
  if (num2 != nil) {
    num1 = [formatter numberFromString:(NSString *)self];
  } else {
    num1 = [dict objectForKey:(NSString *)self];
    num2 = [dict objectForKey:pStr2];
  }
  return [num1 compare:num2];
}

@end

#pragma mark - ATGProductPage private interface declaration
#pragma mark -
@interface ATGProductPage () <ATGGridCollectionViewDelegate>

#pragma mark - IB Outlets
//outlets
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet ATGButton *finishButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet ATGImageView *productImage;
@property (nonatomic, weak) IBOutlet ATGProductDescription *productDescription;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *skuIndicator;
@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UIWebView *priceView;
@property (nonatomic, weak) IBOutlet UIImageView *skuDivider;
@property (nonatomic, weak) IBOutlet UIView *skuPicker1;
@property (nonatomic, weak) IBOutlet UIView *skuPicker2;
@property (nonatomic, weak) IBOutlet UIView *quantityPicker;
@property (nonatomic, weak) IBOutlet UIView *divider1;
@property (nonatomic, weak) IBOutlet UIView *divider2;
@property (nonatomic, weak) IBOutlet UIView *divider3;
@property (nonatomic, weak) IBOutlet UIView *divider4;
@property (nonatomic, weak) IBOutlet UIView *divider5;

#pragma mark - Custom properties
@property (nonatomic, strong) ATGProductManagerRequest *productRequest;
@property (nonatomic, strong) ATGCommerceManagerRequest *commerceRequest;
@property (nonatomic, readwrite, weak) ATGGridCollectionView *relatedProductsCarousel;

@property (nonatomic, strong) ATGSku *selectedSKU;
@property (nonatomic, strong) NSString *inventoryStatus;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSString *errorProductUrl;
@property (nonatomic, readwrite, copy) NSString *originalSkuID;
@property (nonatomic, readwrite, copy) NSString *originalQuantity;
@property (nonatomic, readwrite, assign) ATGSkuInventoryLevel inventoryLevel;
@property (nonatomic, readwrite, assign) BOOL colorSkuSelected;
@property (nonatomic, readwrite, assign) BOOL sizeSkuSelected;
@property (nonatomic, readwrite, assign) BOOL finishSkuSelected;
@property (nonatomic, readwrite, assign) BOOL fullSizePhoto;
@property (nonatomic, readwrite, assign) BOOL skuDidChanged;
@property (nonatomic, readwrite, assign) CGFloat scrollHeight;

#pragma mark - Product properties
//products
@property (nonatomic, strong) ATGProduct *product;
@property (nonatomic, strong) NSArray *productSKU;
@property (nonatomic, strong) NSArray *relatedItems;
@property (nonatomic, strong) ATGSku *someSku;
@property (nonatomic, strong) ATGProductInventory *inventory;

#pragma mark - Private methods
- (NSArray *)  getSkuArrayForType:(NSString *)type;
- (ATGSku *)   getSkuForName:(NSString *)name type:(NSString *)type;
- (NSString *) getColorSwatchUrlForColor:(NSString *)pColor;
- (NSString *) createPriceLabels;
- (void)       updatePrice:(NSNumber *)price wasPrice:(NSNumber *)wasPrice;
- (void)       getInventoryStatusForSku:(NSString *)skuId;

- (void)    layoutControls;
- (CGFloat) layoutControl:(UIView *)view y:(CGFloat)y;

- (void) reloadView;
- (BOOL) reloadSKUPicker:(UIView *)picker type:(NSString *)type;
- (void) reloadQuantityPicker;
- (void) reloadStatus;
- (void) reloadPickers;

- (void) didSelectSkuPicker:(UITapGestureRecognizer *)sender;
- (void) didSelectQuantityPicker;

#pragma mark - IB Actions
- (IBAction) didPressAddButton:(id)sender;

@end

#pragma mark - ATGProductPage implementation
#pragma mark -
@implementation ATGProductPage

#pragma mark - Custom Properties Accessor Methods

- (void)setProductQuantity:(NSString *)pProductQuantity {
  self->_productQuantity = [pProductQuantity copy];
  if (![self originalQuantity]) {
    [self setOriginalQuantity:pProductQuantity];
  }
}

- (void)setSkuId:(NSString *)pSkuId {
  self->_skuId = [pSkuId copy];
  if (![self originalSkuID]) {
    [self setOriginalSkuID:pSkuId];
  }
}

- (void) dealloc {
  [self.productDescription removeObserver:self forKeyPath:ATGFramePropertyName];
  [self.productRequest cancelRequest];
  [self.productRequest cancelRequest];
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
  [super viewDidLoad];

  if (![self productTitle]) {
    self.title = NSLocalizedStringWithDefaultValue(@"mobile.productDetails.title", nil, [NSBundle mainBundle], @"ATGRenderableProduct Details", @"ATGRenderableProduct Details Title");
  } else {
    self.title = [self productTitle];
  }

  self.currencyFormatter = [[NSNumberFormatter alloc] init];
  [self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

  UITapGestureRecognizer *tapProductImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapProductImage:)];
  tapProductImage.numberOfTapsRequired = 1;

  [self.productImage addGestureRecognizer:tapProductImage];
  [self.productImage setAccessibilityLabel:self.product.displayName];
  [self.productImage setAccessibilityHint:NSLocalizedStringWithDefaultValue(
     @"ATGProductPage.ProductImageAccessibilityHint",
     nil, [NSBundle mainBundle],
     @"Double tap to enlarge or shrink the product image",
     @"ATGRenderableProduct image accessibility hint.")];
  self.productImage.imageURL = [ATGRestManager getAbsoluteImageString:[self itemImageUrl]];
  self.productImage.blanksImage  = NO;

  [self.productDescription addObserver:self forKeyPath:ATGFramePropertyName options:NSKeyValueObservingOptionNew context:NULL];

  UITapGestureRecognizer *rec1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectSkuPicker:)];
  [[self skuPicker1] addGestureRecognizer:rec1];
  UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectSkuPicker:)];
  [[self skuPicker2] addGestureRecognizer:rec2];
  UITapGestureRecognizer *rec3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectQuantityPicker)];
  [[self quantityPicker] addGestureRecognizer:rec3];

  self.priceView.hidden = YES;
  [self skuPicker1].hidden = YES;
  [self skuPicker2].hidden = YES;
  self.statusLabel.hidden = YES;
  [self.statusLabel applyStyleWithName:@"productStatusLabel"];
  self.finishButton.enabled = NO;
  [self.finishButton applyStyleWithName:@"miniButton"];
  [self divider1].hidden = YES;
  [self divider2].hidden = YES;
  [self divider3].hidden = YES;
  [self divider4].hidden = YES;
  [self divider5].hidden = YES;
  [self divider1].backgroundColor = [UIColor borderLightColor];
  [self divider2].backgroundColor = [UIColor borderLightColor];
  [self divider3].backgroundColor = [UIColor borderLightColor];
  [self divider4].backgroundColor = [UIColor borderLightColor];
  [self divider5].backgroundColor = [UIColor borderLightColor];
  [[self skuIndicator] startAnimating];

  self.productRequest = [[ATGProductManager productManager] getProduct:[self productId] delegate:self];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 //iOS 7.0 supported
  // Dont overlap the navigation item with the scrollable content (for ios 7)
  if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
#endif

}

- (void) observeValueForKeyPath:(NSString *)pKeyPath ofObject:(id)pObject change:(NSDictionary *)pChange context:(void *)pContext {
  CGFloat contentHeight = ATGImageHeight + self.productDescription.frame.size.height;

  if ([self relatedProductsCarousel]) {
    [[self relatedProductsCarousel] setFrame:CGRectMake(0, contentHeight, 320, ATGObjHeight)];
    contentHeight = contentHeight + ATGObjHeight;
  }

  [self.scrollView setContentSize:CGSizeMake(320, contentHeight)];
}

- (void) viewDidUnload {
  [self.productDescription removeObserver:self forKeyPath:ATGFramePropertyName];
  [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:@"productToProduct"]) {
    ATGProductPage *ctrl = pSegue.destinationViewController;
    ctrl.productId = self.selectedProduct.repositoryId;
  }
}

#pragma mark - SKU Pickers

- (BOOL) reloadSKUPicker:(UIView *)pPicker type:(NSString *)pType {
  UILabel *skuLabel = (UILabel *)[pPicker viewWithTag:1];
  BOOL oneSku = NO;
  if ([[self getSkuArrayForType:pType] count] < 2) {
    if ([self skuId] == nil) {
      [self setSelectedSKU:[self.productSKU objectAtIndex:0]];
      oneSku = YES;
    }
    [[pPicker viewWithTag:2] setHidden:YES];
    pPicker.accessibilityTraits = UIAccessibilityTraitNone;
    pPicker.accessibilityHint = nil;
  } else {
    pPicker.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.SkuCellHint", nil, [NSBundle mainBundle], @"Double tap to open sku picker", @"SKU cell accessibility hint");
  }

  NSString *text;
  BOOL result;

  if (([self skuId] != nil) || (oneSku)) {
    if ([pType isEqualToString:ATGColor]) {
      text = [self selectedSKU].color;
    } else if ([pType isEqualToString:ATGSize]) {
      text = [self selectedSKU].size;
    } else if ([pType isEqualToString:ATGFinish]) {
      text = [self selectedSKU].woodFinish;
    } else if ([pType isEqualToString:ATGFeature]) {
      text = [self selectedSKU].displayName;
    }
    [skuLabel applyStyleWithName:@"skuLabel"];
    [self getInventoryStatusForSku:[self selectedSKU].repositoryId];
    result = YES;
  } else {
    if ([pType isEqualToString:ATGColor]) {
      text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.ColorLabelTitle", nil, [NSBundle mainBundle], @"Color", @"Color Label Title");
    } else if ([pType isEqualToString:ATGSize]) {
      text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.SizeLabelTitle", nil, [NSBundle mainBundle], @"Size", @"Size Label Title");
    } else if ([pType isEqualToString:ATGFinish]) {
      text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.WoodfinishLabelTitle", nil, [NSBundle mainBundle], @"Finish", @"Finish Label Title");
    } else if ([pType isEqualToString:ATGFeature]) {
      text = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.DisplaynameLabelTitle", nil, [NSBundle mainBundle], @"Feature", @"Feature Label Title");
    }
    [skuLabel applyStyleWithName:@"prefixSkuLabel"];
    result = NO;
  }

  skuLabel.text = text;
  return result;
}

- (void) reloadQuantityPicker {
  [self quantityPicker].accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.SkuQntCellHint", nil, [NSBundle mainBundle], @"Double tap to open quantity picker", @"SKU quantity cell accessibility hint");

  UILabel *skuLabel = (UILabel *)[[self quantityPicker] viewWithTag:1];
  UILabel *qntLabel = (UILabel *)[[self quantityPicker] viewWithTag:3];

  NSString *qntString = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.QuantityLabelTitle", nil, [NSBundle mainBundle], @"Quantity:", @"Quantity Label Title");
  skuLabel.text = qntString;

  if ([self productQuantity] == nil) {
    [self setProductQuantity:@"1"];
  }
  qntLabel.text = [self productQuantity];
  [self divider3].hidden = NO;
  [self divider4].hidden = NO;
}

- (void) reloadPickers {
  [self divider1].hidden = YES;
  [self divider2].hidden = YES;
  [self skuPicker1].hidden = YES;
  [self skuPicker2].hidden = YES;

  if ([self.someSku.type isEqualToString:ATGProductClothingType]) {
    [self skuPicker1].hidden = NO;
    [self divider1].hidden = NO;
    BOOL noSize = [[self getSkuArrayForType:ATGSize] count] == 0;
    [self skuPicker2].hidden = noSize;
    [self divider2].hidden = noSize;
    [self setColorSkuSelected:[self reloadSKUPicker:[self skuPicker1] type:ATGColor]];
    [self setSizeSkuSelected:[self reloadSKUPicker:[self skuPicker2] type:ATGSize]];
  }

  if ([self.someSku.type isEqualToString:ATGProductFurnitureType]) {
    [self skuPicker1].hidden = NO;
    [self divider1].hidden = NO;
    [self setFinishSkuSelected:[self reloadSKUPicker:[self skuPicker1] type:ATGFinish]];
  }

  if ([self.someSku.type isEqualToString:ATGProductSingleSku]) {
    if ([self.productSKU count] > 1) {
      [self skuPicker1].hidden = NO;
      [self divider1].hidden = NO;
      [self setFinishSkuSelected:[self reloadSKUPicker:[self skuPicker1] type:ATGFeature]];
    } else {
      [self setSelectedSKU:[self.productSKU objectAtIndex:0]];
      [self setFinishSkuSelected:YES];
    }
  }

  [self reloadQuantityPicker];
}

- (void) reloadStatus {
  NSString *buttonTitle = nil;
  [self.finishButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];

  if (self.updateCard) {
    if ([self inventoryLevel] == ATGSkuInventoryLevelUnavailable) {
      buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.EmailMe", nil, [NSBundle mainBundle], @"Email Me", @"Email Me Button Title");
      [self.finishButton addTarget:self action:@selector(didPressEmailMeButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
      if ([self skuDidChanged]) {
        buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.UpdateCartBtn", nil, [NSBundle mainBundle], @"Update Cart", @"Update Cart Button Title");
      } else {
        buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.backBtnTitle", nil, [NSBundle mainBundle], @"Back To Cart", @"Back To Cart Button Title");
      }
      [self.finishButton addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
  } else {
    if (self.inventoryStatus == nil || [self inventoryLevel] == ATGSkuInventoryLevelBackorderable) {
      buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.addBtnTitle", nil, [NSBundle mainBundle], @"Add to Cart", @"Add to Cart Button Title");
      [self.finishButton addTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self inventoryLevel] == ATGSkuInventoryLevelPreorderable) {
      buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Preorder", nil, [NSBundle mainBundle], @"Preorder", @"Preorder Button Title");
      [self.finishButton addTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self inventoryLevel] == ATGSkuInventoryLevelUnavailable) {
      buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.EmailMe", nil, [NSBundle mainBundle], @"Email Me", @"Email Me Button Title");
      [self.finishButton addTarget:self action:@selector(didPressEmailMeButton) forControlEvents:UIControlEventTouchUpInside];
    }
  }

  self.statusLabel.text = self.inventoryStatus;
  [self.finishButton setTitle:buttonTitle forState:UIControlStateNormal];

  if ( !( ([self colorSkuSelected] && [self sizeSkuSelected]) || ([self finishSkuSelected]) ) ) {
    self.finishButton.enabled = NO;
    self.statusLabel.hidden = YES;
    [self divider5].hidden = YES;
  } else {
    self.finishButton.enabled = YES;
    self.statusLabel.hidden = NO;
    [self divider5].hidden = NO;
  }
}

- (ATGSKUPicker *) createDialog:(NSString *)pTitle forPicker:(UIView *)pOwner {
  NSMutableArray *pickArray = [[NSMutableArray alloc] init];
  [pickArray addObject:pTitle];
  [pickArray addObjectsFromArray:[self getSkuArrayForType:pTitle]];

  ATGSKUPicker *picker = [[ATGSKUPicker alloc] initWithFrame:CGRectMake(130, 50, 180, 264) andSkuArray:pickArray];
  picker.delegate = self;
  picker.owner = pOwner;
  picker.skuType = pTitle;

  if ([pTitle isEqualToString:ATGColor] || [pTitle isEqualToString:ATGFinish]) {
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    for (int i = 1; i < [pickArray count]; i++) {
      NSString *value = [self getColorSwatchUrlForColor:[pickArray objectAtIndex:i]];
      [colors addObject:value];
    }
    picker.colorsArray = [NSArray arrayWithArray:colors];
  }

  return picker;
}

- (void) didSelectSkuPicker:(UITapGestureRecognizer *)pRecognizer {
  ATGSKUPicker *picker;
  NSString *title;
  NSString *type = nil;
  if ([self.someSku.type isEqualToString:ATGProductClothingType]) {
    if (pRecognizer.view == [self skuPicker1]) {
      title = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.ColorLabelTitle", nil, [NSBundle mainBundle], @"Color", @"Color Label Title");
      type = ATGColor;
    } else {
      title = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.SizeLabelTitle", nil, [NSBundle mainBundle], @"Size", @"Size Label Title");
      type = ATGSize;
    }
  } else if ([self.someSku.type isEqualToString:ATGProductFurnitureType]) {
    title = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.WoodfinishLabelTitle", nil, [NSBundle mainBundle], @"Finish", @"Finish Label Title");
    type = ATGFinish;
  } else if ([self.someSku.type isEqualToString:ATGProductSingleSku]) {
    title = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.DisplaynameLabelTitle", nil, [NSBundle mainBundle], @"Feature", @"Feature Label Title");
    type = ATGFeature;
  }


  if ([[self getSkuArrayForType:type] count] < 2) {
    return;
  }

  picker = [self createDialog:title forPicker:pRecognizer.view];

  if ([title isEqualToString:ATGColor] && [self colorSkuSelected]) {
    picker.selectedSkuString = [self selectedSKU].color;
  } else if ([title isEqualToString:ATGFinish] && [self finishSkuSelected]) {
    if ([self.someSku.type isEqualToString:ATGProductSingleSku]) {
      picker.selectedSkuString = [self selectedSKU].displayName;
    } else {
      picker.selectedSkuString = [self selectedSKU].woodFinish;
    }
  } else if ([title isEqualToString:ATGSize] && [self sizeSkuSelected]) {
    picker.selectedSkuString = [self selectedSKU].size;
  } else if ([title isEqualToString:ATGFeature] && [self finishSkuSelected]) {
    picker.selectedSkuString = [self selectedSKU].displayName;
  }

  [[ATGActionBlocker sharedModalBlocker] showView:picker withTarged:self andAction:@selector(dismissBlocker)];
  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"ATGProductPage.PickerView.AccessibilityAnnouncementNotification", nil, [NSBundle mainBundle], @"%@ picker view is shown", @"Picker view appearence notification"), title]);
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void) didSelectQuantityPicker {
  NSMutableArray *pickArray = [[NSMutableArray alloc] init];
  [pickArray addObject:ATGQuantity];
  [pickArray addObjectsFromArray:[NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil]];
  ATGSKUPicker *picker = [[ATGSKUPicker alloc] initWithFrame:CGRectMake(190, 50, 110, 264) andSkuArray:pickArray];
  picker.selectedSkuString = [self productQuantity];
  picker.delegate = self;
  picker.owner = [self quantityPicker];

  [[ATGActionBlocker sharedModalBlocker] showView:picker withTarged:self andAction:@selector(dismissBlocker)];

  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"ATGProductPage.PickerView.AccessibilityAnnouncementNotification", nil, [NSBundle mainBundle], @"%@ picker view is shown", @"Picker view appearence notification"), ATGQuantity]);
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

#pragma mark - Private methods

- (void) reloadView {
  self.title = self.product.displayName;
  [(UILabel *)[[self navigationItem] titleView] setText:[self title]];

  self.productImage.imageURL = [ATGRestManager getAbsoluteImageString:self.product.largeImageUrl];
  self.priceView.hidden = NO;
  [self divider1].hidden = NO;
  if ([self selectedSKU] == nil) {
    [self.priceView loadHTMLString:[self createPriceLabels] baseURL:nil];
  } else {
    [self updatePrice:[self selectedSKU].salePrice wasPrice:[self selectedSKU].listPrice];
  }

  [self reloadPickers];
  [self reloadStatus];
  [self layoutControls];

  if (self.product.longDescription != nil) {
    [self.productDescription setDetailsText:self.product.longDescription];
  } else {
    [self.productDescription setDetailsText:self.product.productDescription];
  }
  [self.productDescription setRelatedItemsVisible:[self.relatedItems count] > 0];


  if ([self.relatedItems count] > 0) {
    ATGGridCollectionView *relatedProductsCarousel =
        [[ATGGridCollectionView alloc] initWithFrame:CGRectZero cellsNibName:@"ATGSimpleProductItem"];
    [relatedProductsCarousel setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [relatedProductsCarousel setGridViewDelegate:self];
    [relatedProductsCarousel setObjectsToDisplay:[self relatedItems]];
    [relatedProductsCarousel setBackgroundColor:[UIColor clearColor]];
    [self.scrollView addSubview:relatedProductsCarousel];
    [self setRelatedProductsCarousel:relatedProductsCarousel];
  } else {
    [[self relatedProductsCarousel] removeFromSuperview];
  }
}

- (NSArray *) getSkuArrayForType:(NSString *)pType {
  NSMutableArray *partialSku = [NSMutableArray array];
  if ([pType isEqualToString:ATGSize]) {
    for (int i = 0; i < [self.productSKU count]; i++) {
      ATGSku *sku = [self.productSKU objectAtIndex:i];
      if (sku.size != nil && ![partialSku containsObject:sku.size]
          && (![self colorSkuSelected] || [sku.color isEqualToString:[self selectedSKU].color])) {
        [partialSku addObject:sku.size];
      }
    }
  } else if ([pType isEqualToString:ATGColor]) {
    for (int i = 0; i < [self.productSKU count]; i++) {
      ATGSku *sku = [self.productSKU objectAtIndex:i];
      if (sku.color != nil && ![partialSku containsObject:sku.color]
          && (![self sizeSkuSelected] || [sku.size isEqualToString:[self selectedSKU].size])) {
        [partialSku addObject:sku.color];
      }
    }
  } else if ([pType isEqualToString:ATGFeature]) {
    if ([self.someSku.type isEqualToString:ATGProductSingleSku]) {
      for (int i = 0; i < [self.productSKU count]; i++) {
        ATGSku *sku = [self.productSKU objectAtIndex:i];
        if (sku.displayName != nil && ![partialSku containsObject:sku.displayName]) {
          [partialSku addObject:sku.displayName];
        }
      }
    }
  } else if ([pType isEqualToString:ATGFinish]) {
    for (int i = 0; i < [self.productSKU count]; i++) {
      ATGSku *sku = [self.productSKU objectAtIndex:i];
      if (sku.woodFinish != nil && ![partialSku containsObject:sku.woodFinish]) {
        [partialSku addObject:sku.woodFinish];
      }
    }
  }
  
  if ([pType isEqualToString:ATGSize]) {
    [partialSku sortUsingSelector:@selector(sizeCompare:)];
  } else {
    [partialSku sortUsingSelector:@selector(stringCompare:)];
  }
  
  return partialSku;
}

- (ATGSku *) getSkuForName:(NSString *)pName type:(NSString *)pType {
  for (int i = 0; i < [self.productSKU count]; i++) {
    ATGSku *sku = [self.productSKU objectAtIndex:i];
    if ([pType isEqualToString:ATGColor]) {
      if ([self selectedSKU]) {
        if ([sku.color isEqualToString:pName] && [[self selectedSKU].size isEqualToString:sku.size]) {
          return sku;
        }
      } else {
        if ([sku.color isEqualToString:pName]) {
          return sku;
        }
      }
    }
    if ([pType isEqualToString:ATGSize]) {
      if ([self selectedSKU]) {
        if ([sku.size isEqualToString:pName] && [[self selectedSKU].color isEqualToString:sku.color]) {
          return sku;
        }
      } else {
        if ([sku.size isEqualToString:pName]) {
          return sku;
        }
      }
    }
    if ([pType isEqualToString:ATGFinish]) {
      if ([sku.woodFinish isEqualToString:pName]) {
        return sku;
      }
    }
    if ([pType isEqualToString:ATGFeature]) {
      if ([sku.displayName isEqualToString:pName]) {
        return sku;
      }
    }
  }
  return nil;
}

- (NSString *) getColorSwatchUrlForColor:(NSString *)pColor {
  for (int i = 0; i < [self.productSKU count]; i++) {
    ATGSku *sku = [self.productSKU objectAtIndex:i];
    if ([sku.color isEqualToString:pColor] || [[sku woodFinish] isEqualToString:pColor]) {
      return sku.colorSwatchUrl;
    }
  }
  return nil;
}

- (NSString *) createPriceLabels {
  NSString *htmlString;

  if ([self.product.lowestSalePrice compare:self.product.highestSalePrice] == NSOrderedSame) {
    // highest price equal to lowest -- single price
    htmlString = [NSString stringWithFormat:@"<p><span id=\"price\">%@</span><br>", [self.currencyFormatter stringFromNumber:self.product.lowestSalePrice]];
  } else {
    // price range
    htmlString = [NSString stringWithFormat:@"<p><span id=\"delimeter\">%@</span> <span id=\"price\">%@</span><br><span id=\"delimeter\">%@</span> <span id=\"price\">%@</span><br>", NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.From", nil, [NSBundle mainBundle], @"From", @"delimeter 'from' for price"), [self.currencyFormatter stringFromNumber:self.product.lowestSalePrice], NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.To", nil, [NSBundle mainBundle], @"To", @"delimeter 'to' for price"), [self.currencyFormatter stringFromNumber:self.product.highestSalePrice]];
  }

  // check if the list prices are different from the sale prices
  if ([self.product.lowestSalePrice compare:self.product.lowestListPrice] != NSOrderedSame || [self.product.highestSalePrice compare:self.product.highestListPrice] != NSOrderedSame) {
    // product is on sale -- display 'was price'
    if ([self.product.lowestListPrice compare:self.product.highestListPrice] == NSOrderedSame) {
      // single price
      htmlString = [htmlString stringByAppendingString:[NSString stringWithFormat:@"<span id=\"delimeter\">%@</span><br><span id=\"wasPrice\">%@</span></p>", NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Was", nil, [NSBundle mainBundle], @"was", @"delimeter for was price"), [self.currencyFormatter stringFromNumber:self.product.lowestListPrice]]];
      
    } else {
      // price range
      htmlString = [htmlString stringByAppendingString:[NSString stringWithFormat:@"<span id=\"delimeter\">%@</span><br><span id=\"wasPrice\">%@</span> <span id=\"delimeter\">-<span> <span id=\"wasPrice\">%@</span></p>", NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Was", nil, [NSBundle mainBundle], @"was", @"delimeter for was price"), [self.currencyFormatter stringFromNumber:self.product.lowestListPrice], [self.currencyFormatter stringFromNumber:self.product.highestListPrice]]];
    }
  }
  NSString *body = [NSString stringWithFormat:ATGHTMLStringBody, htmlString];
  return [NSString stringWithFormat:@"%@%@", ATGHTMLStringHeader, body];
}

- (void) updatePrice:(NSNumber *)pPrice wasPrice:(NSNumber *)pWasPrice {
  NSString *htmlString;
  if (pPrice == nil || [pWasPrice compare: pPrice] == NSOrderedSame) {
    htmlString = [NSString stringWithFormat:@"<p><span id=\"price\">%@</span></p>", [self.currencyFormatter stringFromNumber:pWasPrice]];
  } else {
    htmlString = [NSString stringWithFormat:@"<p><span id=\"price\">%@</span><br><span id=\"delimeter\">%@</span><br><span id=\"wasPrice\">%@</span></p>", [self.currencyFormatter stringFromNumber:pPrice], NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Was", nil, [NSBundle mainBundle], @"was", @"delimeter for was price"), [self.currencyFormatter stringFromNumber:pWasPrice]];
  }
  NSString *body = [NSString stringWithFormat:ATGHTMLStringBody, htmlString];
  [self.priceView loadHTMLString:[NSString stringWithFormat:@"%@%@", ATGHTMLStringHeader, body] baseURL:nil];
}

- (void) getInventoryStatusForSku:(NSString *)pSKuId {
  ATGSkuInventory *level = [self.inventory.skuInventory objectForKey:pSKuId];
  [self setInventoryLevel:level.availability];
  switch (level.availability) {
  case ATGSkuInventoryLevelAvailable:
    self.inventoryStatus = nil;
    break;
  case ATGSkuInventoryLevelBackorderable:
    self.inventoryStatus = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Backordered", nil, [NSBundle mainBundle], @"Backordered", @"Backordered status of product");
    break;

  case ATGSkuInventoryLevelPreorderable:
    self.inventoryStatus = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.AvailableSoon", nil, [NSBundle mainBundle], @"Available Soon", @"ATGRenderableProduct will be available soon");
    break;

  case ATGSkuInventoryLevelUnavailable:
    self.inventoryStatus = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.Unavailable", nil, [NSBundle mainBundle], @"Out of Stock", @"ATGRenderableProduct is out of stock");
    break;

  default:
    break;
  }
}

- (CGFloat) layoutControl:(UIView *)pView y:(CGFloat)pY {
  CGRect frame = pView.frame;
  frame.origin.y = pY;
  pView.frame = frame;
  if (!pView.hidden) {
    pY += frame.size.height;
  }
  return pY;
}

- (void) layoutControls {
  CGFloat y = [self layoutControl:[self divider1] y:[self divider1].frame.origin.y];
  y = [self layoutControl:[self skuPicker1] y:y];
  y = [self layoutControl:[self divider2] y:y];
  y = [self layoutControl:[self skuPicker2] y:y];
  y = [self layoutControl:[self divider3] y:y];
  y = [self layoutControl:[self quantityPicker] y:y];
  y = [self layoutControl:[self divider4] y:y];
  y = [self layoutControl:[self statusLabel] y:y];
  y = [self layoutControl:[self finishButton] y:y];
  [self layoutControl:[self divider5] y:y + 20];
}

#pragma mark - ATGGridCollectionViewDelegate

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didSelectObject:(id)pObject {
  [self setSelectedProduct:pObject];
  [self performSegueWithIdentifier:@"productToProduct" sender:self];
}

#pragma mark - Actions

- (void) didPressEmailMeButton {
  ATGEmailMeView *emailMe = [[ATGEmailMeView alloc] initWithFrame:CGRectMake(20, 100, 280, 88)];
  emailMe.productId = self.product.repositoryId;
  emailMe.skuId = [self selectedSKU].repositoryId;
  emailMe.delegate = self;
  [[ATGActionBlocker sharedModalBlocker] showView:emailMe withTarged:self andAction:@selector(hideBlockView)];
}

- (void) didPressAddButton:(id)sender {
  NSString *btnTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.AddingCartBtn", nil, [NSBundle mainBundle], @"Adding...", @"Adding Cart Button Title");
  [self.finishButton setTitle:btnTitle forState:UIControlStateNormal];
  [self.finishButton setEnabled:NO];

  //remove old touch event and replace him with new event for viewing cart
  [self.finishButton removeTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.commerceRequest cancelRequest];
  self.commerceRequest =
      [[ATGCommerceManager commerceManager] addItemToShoppingCartWithSkuId:[self selectedSKU].repositoryId
                                                                 productId:self.product.repositoryId
                                                                  quantity:[self productQuantity]
                                                                  delegate:self];
  DebugLog(@"Item added to cart");
}

- (void) didPressBackButton {
  if ([self skuDidChanged]) {
    [self.commerceRequest cancelRequest];
    [self.finishButton setEnabled:NO];
    self.commerceRequest =
        [[ATGCommerceManager commerceManager] changeSkuOfOldCommerceId:[self commerceItemId]
                                                         withProductId:[self.product repositoryId]
                                                               toSkuId:[[self selectedSKU] repositoryId]
                                                          withQuantity:[self productQuantity]
                                                              delegate:self];
  } else {
    [[self navigationController] popViewControllerAnimated:YES];
  }
}

- (void) hideBlockView {
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
}

- (void) handleTapProductImage:(UIGestureRecognizer *)sender {
  if (![self fullSizePhoto]) {
    CGRect rect = self.productImage.frame;
    rect.size = CGSizeMake(320, 380);
    self.productImage.frame = rect;
    rect = self.productDescription.frame;
    rect.origin = CGPointMake(0, 380);
    self.productDescription.frame = rect;
    if (self.relatedProductsCarousel != nil) {
      rect = self.relatedProductsCarousel.frame;
      rect.origin = CGPointMake(0, 380 + self.productDescription.frame.size.height);
      self.relatedProductsCarousel.frame = rect;
      [self.scrollView setContentSize:CGSizeMake(320, self.relatedProductsCarousel.frame.origin.y + 60)];
    } else {
      [self.scrollView setContentSize:CGSizeMake(320, self.productDescription.frame.origin.y + self.productDescription.frame.size.height)];
    }
    self.productImage.imageURL = [ATGRestManager getAbsoluteImageString:self.product.fullImageUrl];
    //image could have transparent background, so hide everything beneath
    [self container].hidden = YES;
    [self skuIndicator].hidden = YES;
    [self setFullSizePhoto:YES];
  } else {
    CGRect rect = self.productImage.frame;
    rect.size = CGSizeMake(175, 300);
    self.productImage.frame = rect;
    rect = self.productDescription.frame;
    rect.origin = CGPointMake(0, 300);
    self.productDescription.frame = rect;
    if (self.relatedProductsCarousel != nil) {
      rect = self.relatedProductsCarousel.frame;
      rect.origin = CGPointMake(0, 300 + self.productDescription.frame.size.height);
      self.relatedProductsCarousel.frame = rect;
      [self.scrollView setContentSize:CGSizeMake(320, self.relatedProductsCarousel.frame.origin.y + 60)];
    } else {
      [self.scrollView setContentSize:CGSizeMake(320, self.productDescription.frame.origin.y + self.productDescription.frame.size.height)];
    }
    self.productImage.imageURL = [ATGRestManager getAbsoluteImageString:self.product.largeImageUrl];
    [self container].hidden = NO;
    if ([[self skuIndicator] isAnimating]) {
      [self skuIndicator].hidden = NO;
    }
    [self setFullSizePhoto:NO];
  }
}

- (void) dismissBlocker {
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
}

- (void) didSelectSKUinPicker:(UIView *)picker {
}

#pragma mark - Sku Picker delegate
- (void) didSelectSkuName:(NSString *)pName owner:(UIView *)pOwner type:(NSString *)pType {
  [self setSkuDidChanged:YES];

  if (pOwner == [self quantityPicker]) {
    [self setProductQuantity:pName];
    UILabel *textLabel = (UILabel *)[pOwner viewWithTag:3];
    textLabel.text = pName;
  } else {
    [self setSelectedSKU:[self getSkuForName:pName type:pType]];
    [self getInventoryStatusForSku:[self selectedSKU].repositoryId];
    UILabel *textLabel = (UILabel *)[pOwner viewWithTag:1];
    textLabel.text = pName;
    [textLabel applyStyleWithName:@"skuLabel"];

    if ([pType isEqualToString:ATGColor]) {
      [self setColorSkuSelected:YES];
    } else if ([pType isEqualToString:ATGSize]) {
      [self setSizeSkuSelected:YES];
    } else if ([pType isEqualToString:ATGFinish]) {
      [self setFinishSkuSelected:YES];
    } else if ([pType isEqualToString:ATGFeature]) {
      [self setFinishSkuSelected:YES];
    }
  }
  if ([[self originalSkuID] isEqualToString:[[self selectedSKU] repositoryId]] &&
      [[self originalQuantity] isEqualToString:[self productQuantity]]) {
    [self setSkuDidChanged:NO];
  }
  [self reloadStatus];
  [self layoutControls];


  if ( ([self colorSkuSelected] && [self sizeSkuSelected]) || [self finishSkuSelected] ) {
    [self updatePrice:[self selectedSKU].salePrice wasPrice:[self selectedSKU].listPrice];
  }

  [self dismissBlocker];
}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)pActionSheet clickedButtonAtIndex:(NSInteger)pButtonIndex {
  if ([pActionSheet cancelButtonIndex] != pButtonIndex) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.errorProductUrl]];
  }
  [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Product Mananager delegates
- (void) didGetProduct:(ATGProductManagerRequest *)pProductRequest {
  [[self skuIndicator] stopAnimating];

  self.product = pProductRequest.product;
  self.productSKU = [self.product.childSKUs allObjects];
  self.relatedItems = [self.product.relatedProducts allObjects];
  [self.currencyFormatter setCurrencyCode:self.product.currencyCode];
  if ([self.product.currencyCode isEqualToString:@"USD"]) {
    [self.currencyFormatter setCurrencyDecimalSeparator:@"."];
  } else if ([self.product.currencyCode isEqualToString:@"EUR"]) {
    [self.currencyFormatter setCurrencyDecimalSeparator:@","];
  }

  if ([self productQuantity] != nil) {
    for (int i = 0; i < [self.productSKU count]; i++) {
      ATGSku *sku = [self.productSKU objectAtIndex:i];
      if ([sku.repositoryId isEqualToString:[self skuId]]) {
        [self setSelectedSKU:sku];
      }
    }
  }

  self.someSku = [self.product.childSKUs anyObject];

  [self reloadView];

  self.productRequest = [[ATGProductManager productManager] getProductInventoryLevel:[self productId]
                                                                            delegate:self];
}

- (void) didErrorGettingProduct:(ATGProductManagerRequest *)pRequest {
  [[self skuIndicator] stopAnimating];

  self.productRequest = nil;

  if ([[pRequest error] code] == 13) {
    // It's a wrong site error.
    NSString *url = [[[[ATGRestManager restManager] restSession] hostURLWithOptions:(ATGRestRequestOptionNone)] absoluteString];
    url = [url stringByAppendingString:[[[pRequest error] userInfo]
                                        objectForKey:NSURLErrorFailingURLStringErrorKey]];
    self.errorProductUrl = url;
    NSString *title = NSLocalizedStringWithDefaultValue(@"ATGProductPage.ActionSheetWrongSiteTitle",
                                                        nil, [NSBundle mainBundle],
                                                        @"This product can be displayed on main site only.",
                                                        @"Title to be displayed on the action sheet.");
    NSString *cancel = NSLocalizedStringWithDefaultValue
                         (@"ATGLoginViewController.CancelButtonTitle",
                         nil, [NSBundle mainBundle], @"Cancel",
                         @"Title to be used by the Cancel button.");
    NSString *action = NSLocalizedStringWithDefaultValue(@"ATGProductPate.ActionSheetWrongSiteAction",
                                                         nil, [NSBundle mainBundle], @"View on main site",
                                                         @"Action button title.");
    UIActionSheet *actionSheet =
      [[UIActionSheet alloc] initWithTitle:title delegate:self
                         cancelButtonTitle:cancel destructiveButtonTitle:nil
                         otherButtonTitles:action, nil];
    [actionSheet showInView:[self view]];
  } else {
    [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  }
}

- (void) didGetInventoryLevel:(ATGProductManagerRequest *)pRequest {
  self.inventory = pRequest.productInventory;
  if (self.selectedSKU) {
    [self getInventoryStatusForSku:self.selectedSKU.repositoryId];
  }
  [self reloadPickers];
  [self reloadStatus];
  [self layoutControls];
  DebugLog(@"Got inventory level");
  self.productRequest = nil;
}

- (void) didErrorGettingInventoryLevel:(ATGProductManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  self.productRequest = nil;
}

#pragma mark - Commerce manager delegates

- (void) didAddItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  DebugLog(@"Item added to cart");
  NSString *buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.addBtnTitle", nil, [NSBundle mainBundle], @"Add to Cart", @"Add to Cart Button Title");
  [self.finishButton setTitle:buttonTitle forState:UIControlStateNormal];
  [self.finishButton addTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.finishButton setEnabled:YES];

  self.commerceRequest = nil;
}

- (void) didErrorAddingItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  self.commerceRequest = nil;
  NSString *buttonTitle = NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.addBtnTitle", nil, [NSBundle mainBundle], @"Add to Cart", @"Add to Cart Button Title");
  [self.finishButton setTitle:buttonTitle forState:UIControlStateNormal];
  [self.finishButton addTarget:self action:@selector(didPressAddButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.finishButton setEnabled:YES];
}

- (void) didChangeSku:(ATGCommerceManagerRequest *)pRequest {
  self.commerceRequest = nil;
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void) didErrorUpdatingQuantityOfItem:(ATGCommerceManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  [self.finishButton setEnabled:YES];
  self.commerceRequest = nil;
}

#pragma mark - ATGEmailMeDelegate

- (void) didErrorRegisteringBackInStockNotification:(NSError *)pError {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

- (void) didSelectHelp {
  [self performSegueWithIdentifier:ATGSegueIdProductToMoreDetails sender:self];
}

@end
