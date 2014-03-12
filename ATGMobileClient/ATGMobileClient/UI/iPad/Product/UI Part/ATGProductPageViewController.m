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
#import <ATGMobileClient/ATGGridCollectionView.h>
#import <ATGMobileClient/ATGRelatedProduct.h>
#import <ATGMobileClient/ATGCommerceItem.h>
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import <ATGUIElements/ATGRotateButton.h>
#import "ATGProductPageViewController.h"
#import "ATGBaseProductDetailsPage_iPad.h"
#import "ATGRelatedProductGrid.h"
#import "ATGProductDetailsStack.h"

typedef enum {
  ATGProductPageDetails,
  ATGProductPageRelated,
  ATGProductPageRecently
}
ATGProductPageState;

static const CGFloat ATGNoItemsMessageFontSize = 17;

#define ATG_PRODUCTPAGE_RELATEDGRID_ID @"ATGRelatedProductsPage"

#pragma mark - ATGProductPageViewController private protocol declaration
#pragma mark -
@interface ATGProductPageViewController () <ATGProductManagerDelegate, UIScrollViewDelegate, ATGRelatedProductGridDelegate, ATGGridCollectionViewDelegate, ATGProductDetailsStackCallbacks>
{
  ATGProductPageState currentState;
  int relatedLastIndex;
}

#pragma mark - IB Outlets
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet ATGRotateButton *details;
@property (weak, nonatomic) IBOutlet ATGRotateButton *relatedBtn;
@property (weak, nonatomic) IBOutlet ATGRotateButton *recentlyBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftChevron;
@property (weak, nonatomic) IBOutlet UIButton *rightChevron;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet ATGGridCollectionView *relatedProductsCarousel;

#pragma mark - Custom properties
@property (nonatomic, strong) ATGProductManagerRequest *request;
@property (nonatomic, strong) ATGProduct *product;
@property (nonatomic, strong) NSArray *recentlyViewed;
@property (nonatomic, strong) NSArray *relatedItems;
@property (nonatomic, strong) NSString *initialSku;

@property (nonatomic, strong) ATGBaseProductDetailsPage_iPad *productDetailsPage;
@property (nonatomic, strong) ATGRelatedProductGrid *relatedGrid;
@property (nonatomic) UIInterfaceOrientation currentOrientation;

@property (nonatomic, weak) ATGImageView *fullImage;

@property (nonatomic, strong) ATGProductDetailsStack *productStack;

#pragma mark - IB Actions
- (IBAction) didPressDetailsButton:(id)sender;
- (IBAction) didPressRelatedButton:(id)sender;
- (IBAction) didPressRecentlyButton:(id)sender;

#pragma mark - Private methods
- (void) reloadView;
- (void) presentFullImage;
- (void) dismissFullImage;
- (void) layoutControls;
- (void) loadState:(ATGProductPageState)pNewState;

@end

#pragma mark - ATGProductPageViewController implementation
#pragma mark -
@implementation ATGProductPageViewController
#pragma mark - Synthesized Properties
@synthesize leftChevron;
@synthesize rightChevron;
@synthesize backButton;
@synthesize details;
@synthesize relatedBtn;
@synthesize recentlyBtn;
@synthesize innerView, fullImage, relatedItems;
@synthesize tabView, recentlyViewed;
@synthesize productDetailsPage, currentOrientation, relatedGrid, request;
@synthesize closeButton;

#pragma mark - Public interface

- (id) initWithProductId:(NSString *)pProductId SKU:(NSString *)pSKUId{
  self = [self initWithProductId:pProductId productStack:nil];
  self.initialSku = pSKUId;
  return self;
}

- (id) initWithCommerceItem:(ATGCommerceItem *)pCommerceItem commerceItemList:pList {
  self = [self initWithProductId:pCommerceItem.prodId productList:pList];
  if (self) {
    self.commerceItem = pCommerceItem;
  }
  return self;
}
- (id) initWithProductId:(NSString *)pProductId productStack:(ATGProductDetailsStack *)pStack {
  //Load certain view layout regarding to device orientation
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

  NSBundle *bundle = [NSBundle atgResourceBundle];

  if ( UIInterfaceOrientationIsLandscape(orientation) ) {
    self = [super initWithNibName:@"ATGProductPageViewController" bundle:bundle];
  } else {
    self = [super initWithNibName:@"ATGProductPageViewController_Portrait" bundle:bundle];
  }
  if (self) {
    if (pStack) {
      self.productStack = pStack;
    }
    self.currentOrientation = orientation;
    currentState = ATGProductPageDetails;
    [self requestProductWithId:pProductId];
  }
  return self;
}
- (id) initWithProductId:(NSString *)pProductId productList:(NSArray *)pList {
  return [self initWithProductId:pProductId productStack:[[ATGProductDetailsStack alloc] initWithProducts:pList currentID:pProductId]];
}

- (id) initWithProductId:(NSString *)pProductId dataSource:(id <ATGProductDetailsStackDataSource>)pDataSource {
  return [self initWithProductId:pProductId productStack:[[ATGProductDetailsStack alloc] initWithDataSource:pDataSource currentID:pProductId]];    
}

- (ATGProductManager *) productManager {
  return [ATGProductManager productManager];
}

- (void) requestProductWithId:(NSString *)pProductId {
  self.request = [[self productManager] getProduct:pProductId
                                            fromCurrentSiteOnly:NO
                                     withRecentlyViewedProducts:YES
                                                       delegate:self];
}

- (void) setProduct:(ATGProduct *)pProduct {
  _product = pProduct;
  self.relatedItems = [NSArray arrayWithArray:[pProduct.relatedProducts allObjects]];
  self.productDetailsPage = [self createProductDetailsPageForProduct:pProduct];

  // if configured to select a SKU when the PDP loads, try to find the SKU from the product's child SKUs, and pass it into the PDP.
  //
  if (self.initialSku && !self.commerceItem) {
    ATGSku *sku = nil;
    for (ATGSku *childSku in pProduct.childSKUs) {
      if ([childSku.repositoryId isEqualToString:self.initialSku]) {
        sku = childSku;
        break;
      }
    }

    if (sku)
      self.productDetailsPage.sku = sku;
  }

  [self reloadView];
}

- (ATGBaseProductDetailsPage_iPad *) createProductDetailsPageForProduct: (ATGProduct*) pProduct {
  return [[ATGBaseProductDetailsPage_iPad alloc] initWithProduct:pProduct commerceItem:self.commerceItem presenter:self];
}

#pragma mark - UIViewController
- (void) viewDidLoad {
  [super viewDidLoad];

  relatedLastIndex = -1;

  self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
  self.innerView.backgroundColor = [UIColor whiteColor];

  if ( UIInterfaceOrientationIsLandscape(currentOrientation) ) {
    self.tabView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pdp-overlay-tab-BG.png"]];
  } else {
    self.tabView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pdp-overlay-tab-vertical-BG.png"]];
  }

  if (self.details != nil) {
    [self.details applyOrientation:currentOrientation];
  }

  [self.relatedBtn applyOrientation:currentOrientation];
  [self.recentlyBtn applyOrientation:currentOrientation];
  
  self.details.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGProductPage.DetailsButtonText",
                                                                  nil, [NSBundle mainBundle],
                                                                  @"Details",
                                                                  @"Action button title for displaying product details.");
  self.relatedBtn.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGProductPage.RelatedButtonText",
                                                                     nil, [NSBundle mainBundle],
                                                                     @"Related",
                                                                     @"Action button title for displaying related items list.");
  self.recentlyBtn.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGProductPage.RecentlyButtonText",
                                                                      nil, [NSBundle mainBundle],
                                                                      @"Recently Viewed",
                                                                      @"Action button title for displaying recently viewed product list.");

  self.innerView.layer.cornerRadius = 10;
  self.innerView.layer.masksToBounds = YES;

  NSString *label = NSLocalizedStringWithDefaultValue
                      (@"ATGProductPageViewController.iPad.Accessibility.Label.CloseButton",
                      nil, [NSBundle mainBundle], @"Close",
                      @"Accessibility label to be used by the Close button on the ATGRenderableProduct Details Page");
  [[self closeButton] setAccessibilityLabel:label];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGProductPageViewController.iPad.Accessibility.Hint.CloseButton",
                     nil, [NSBundle mainBundle], @"Double tap to close product details.",
                     @"Accessibility hint to be used by the Close button on the ATGRenderableProduct Details Page");
  [[self closeButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGProductPageViewController.iPad.Accessibility.Label.PreviousButton",
            nil, [NSBundle mainBundle], @"Previous",
            @"Accessibility label to be used by the Previous ATGRenderableProduct button on the ATGRenderableProduct Details Page");
  [[self leftChevron] setAccessibilityLabel:label];
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGProductPageViewController.iPad.Accessibility.Hint.PreviousButton",
           nil, [NSBundle mainBundle], @"Double tap to load previous product details.",
           @"Accessibility hint to be used by the Previous ATGRenderableProduct button on the ATGRenderableProduct Details Page");
  [[self leftChevron] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGProductPageViewController.iPad.Accessibility.Label.NextButton",
            nil, [NSBundle mainBundle], @"Next",
            @"Accessibility hint to be used by the Next ATGRenderableProduct button on the ATGRenderableProduct Details Page");
  [[self rightChevron] setAccessibilityLabel:label];
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGProductPageViewController.iPad.Accessibility.Hint.NextButton",
           nil, [NSBundle mainBundle], @"Double tap to load next product details.",
           @"Accessibility hint to be used by the Next ATGRenderableProduct button on the ATGRenderableProduct Details Page");
  [[self rightChevron] setAccessibilityHint:hint];
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGProductPageViewController.iPad.Accessibility.Hint.RelatedButton",
           nil, [NSBundle mainBundle], @"Double tap to list related products.",
           @"Accessibility hint to be used by the Related Products button on the ATGRenderableProduct Details Page");
  [[self relatedBtn] setAccessibilityHint:hint];
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGProductPageViewController.iPad.Accessibility.Hint.RecentButton",
           nil, [NSBundle mainBundle], @"Double tap to list recently viewed products.",
           @"Accessibility hint to be used by the Recently Viewed Products button on the ATGRenderableProduct Details Page");
  [[self recentlyBtn] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGProductPageViewController.iPad.Accessibility.Label.BackButton",
            nil, [NSBundle mainBundle], @"Back",
            @"Accessibility label to be used by the Back button on the ATGRenderableProduct Details Page");
  [[self backButton] setAccessibilityLabel:label];
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGProductPageViewController.iPad.Accessibility.Hint.BackButton",
           nil, [NSBundle mainBundle], @"Double tap to return to previously displayed product details.",
           @"Accessibility hint to be used by the Back button on the ATGRenderableProduct Details Page");
  [[self backButton] setAccessibilityHint:hint];

  [[self view] setAccessibilityViewIsModal:YES];
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  
  [[self relatedProductsCarousel] setScrollDirection:UICollectionViewScrollDirectionHorizontal];
  self.relatedProductsCarousel.backgroundColor = [UIColor whiteColor];
  [[self relatedProductsCarousel] setAllowsChoosing:NO];
  [[self relatedProductsCarousel] setGridViewDelegate:self];
}

#pragma mark - Actions
- (IBAction) didPressDetailsButton:(id)pSender  {
  [self loadState:ATGProductPageDetails];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (IBAction) didPressRelatedButton:(id)pSender {
  if ([[((ATGProduct *)self.product).relatedProducts allObjects] count] != 0) {
    if ( UIInterfaceOrientationIsLandscape(currentOrientation) ) {
      [self loadState:ATGProductPageRelated];
    } else {
      [self.relatedBtn setSelected:YES];
      [self.recentlyBtn setSelected:NO];
      [[self relatedProductsCarousel] setObjectsToDisplay:[self relatedItems]];
    }
  }
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (IBAction) didPressRecentlyButton:(id)pSender {
  if ( UIInterfaceOrientationIsLandscape(currentOrientation) ) {
    [self loadState:ATGProductPageRecently];
  } else {
    [self.relatedBtn setSelected:NO];
    [self.recentlyBtn setSelected:YES];
    [[self relatedProductsCarousel] setObjectsToDisplay:[self recentlyViewed]];
  }
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}


#pragma mark - Private methods
- (void) reloadView {
  self.leftChevron.hidden = self.productStack ? ![self.productStack hasPreviousProductDetails] : YES;

  self.rightChevron.hidden = self.productStack ? ![self.productStack hasNextProductDetails] : YES;

  self.backButton.hidden = self.productStack ? [self.productStack isRootLevel] : YES;

  //if device orientation is landscape load certain product details state (details, related or recently viewed tab bar section)
  //if orientation is portrait - display related items at the bottom of view
  if ( UIInterfaceOrientationIsLandscape(self.currentOrientation) ) {
    [self loadState:currentState];
    [self layoutControls];
  } else {
    [self.innerView addSubview:self.productDetailsPage.view];
    [self.relatedBtn setSelected:YES];
    [self.recentlyBtn setSelected:NO];
    [[self relatedProductsCarousel] setObjectsToDisplay:[self relatedItems]];
  }
}

- (void) loadState:(ATGProductPageState)pNewState {
  //if state changed - remove previous view from screen
  if (currentState != pNewState) {
    if (currentState == ATGProductPageDetails) {
      [self.productDetailsPage.view removeFromSuperview];
      [self.details setSelected:NO];
      [self.details setEnabled:YES];
    } else if (currentState == ATGProductPageRelated) {
      [self.relatedGrid removeFromSuperview];
      [self.relatedBtn setSelected:NO];
      [self.relatedBtn setEnabled:YES];
    } else {
      [self.relatedGrid removeFromSuperview];
      [self.recentlyBtn setSelected:NO];
      [self.recentlyBtn setEnabled:YES];
    }
  }
  currentState = pNewState;
  //state changed - display needed view
  if (currentState == ATGProductPageDetails) {
    CGRect frame = self.productDetailsPage.view.frame;
    frame.origin.x = 40;
    frame.origin.y = 0;
    [self.productDetailsPage.view setFrame:frame];
    [self.innerView addSubview:self.productDetailsPage.view];
    [self.details setSelected:YES];
    [self.details setEnabled:NO];
  } else if (currentState == ATGProductPageRelated) {
    UIViewController *cntr = [[UIViewController alloc] initWithNibName:ATG_PRODUCTPAGE_RELATEDGRID_ID bundle:[NSBundle atgResourceBundle]];
    self.relatedGrid = (ATGRelatedProductGrid *) cntr.view;
    CGRect frame = self.relatedGrid.frame;
    frame.origin.x = 40;
    frame.origin.y = 0;
    [self.relatedGrid setFrame:frame];
    self.relatedGrid.relatedProducts = [self.product.relatedProducts allObjects];
    [self.innerView addSubview:self.relatedGrid];
    [self.relatedBtn setSelected:YES];
    [self.relatedBtn setEnabled:NO];
  } else {
    UIViewController *cntr = [[UIViewController alloc] initWithNibName:ATG_PRODUCTPAGE_RELATEDGRID_ID bundle:[NSBundle atgResourceBundle]];
    self.relatedGrid = (ATGRelatedProductGrid *)cntr.view;
    CGRect frame = self.relatedGrid.frame;
    frame.origin.x = 40;
    [self.relatedGrid setFrame:frame];
    self.relatedGrid.relatedProducts = self.recentlyViewed;
    if ([[self recentlyViewed] count] == 0) {
      NSString *noItemsMessage = NSLocalizedStringWithDefaultValue
                                   (@"ATGProductPageViewController.NoItemsMessage", nil, [NSBundle mainBundle],
                                   @"You have no recently viewed products yet.",
                                   @"Message to be displayed to user, if no recent items present.");
      CGSize maxSize = CGSizeMake([[self relatedGrid] bounds].size.width / 2, CGFLOAT_MAX);
      UILabel *noItemsAlert = [[UILabel alloc] initWithFrame:CGRectZero];
      [noItemsAlert setFont:[UIFont boldSystemFontOfSize:ATGNoItemsMessageFontSize]];
      [noItemsAlert setTextColor:[UIColor lightGrayColor]];
      [noItemsAlert setNumberOfLines:0];
      [noItemsAlert setLineBreakMode:NSLineBreakByWordWrapping];
      CGSize messageSize = [noItemsMessage sizeWithFont:[noItemsAlert font]
                                      constrainedToSize:maxSize
                                          lineBreakMode:[noItemsAlert lineBreakMode]];
      [noItemsAlert setFrame:CGRectMake(0, 0, messageSize.width, messageSize.height)];
      [noItemsAlert setTextAlignment:NSTextAlignmentCenter];
      [noItemsAlert setText:noItemsMessage];

      [[self relatedGrid] setBackgroundView:noItemsAlert];
    }
    [self.innerView addSubview:self.relatedGrid];
    [self.recentlyBtn setSelected:YES];
    [self.recentlyBtn setEnabled:NO];
  }
  [self.relatedGrid setProductGridDelegate:self];
}

- (void) presentFullImage {
  ATGImageView *fullImageView = [[ATGImageView alloc] initWithFrame:CGRectMake(0, 0, self.innerView.frame.size.width, self.innerView.frame.size.height) loadingImage:[ATGRestManager getAbsoluteImageString:self.product.fullImageUrl]];
  self.fullImage = fullImageView;
  self.fullImage.userInteractionEnabled = YES;
  self.fullImage.backgroundColor = [UIColor whiteColor];
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullImage)];
  //recognizer.numberOfTapsRequired = 2;
  [self.fullImage addGestureRecognizer:recognizer];
  [self.innerView addSubview:self.fullImage];

  [[self fullImage] setAccessibilityViewIsModal:YES];
  [[self fullImage] setIsAccessibilityElement:YES];
  [[self fullImage] setAccessibilityLabel:[[self product] displayName]];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGProductPageViewController.iPad.Accessibility.Hint.FullProductImage",
                     nil, [NSBundle mainBundle], @"Triple tap to display detailed product description.",
                     @"Accessibility hint to be used by the Full Image on the ATGRenderableProduct Details Page");
  [[self fullImage] setAccessibilityHint:hint];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void) dismissFullImage {
  [self.fullImage removeFromSuperview];
  [self setFullImage:nil];

  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

#pragma mark - Layout views

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
  //layout tab buttons
  CGFloat y = [self layoutControl:self.backButton y:self.backButton.frame.origin.y];
  y = [self layoutControl:self.details y:y];
  y = [self layoutControl:self.relatedBtn y:y];
  [self layoutControl:self.recentlyBtn y:y];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)pToInterfaceOrientation duration:(NSTimeInterval)pDuration {
  //device orientation changed  - load needed layout
  if ( UIInterfaceOrientationIsPortrait(pToInterfaceOrientation) ) {
    [[NSBundle atgResourceBundle] loadNibNamed:@"ATGProductPageViewController_Portrait" owner:self options:nil];
    [self.productDetailsPage willRotateToInterfaceOrientation:pToInterfaceOrientation duration:pDuration];
    self.currentOrientation = pToInterfaceOrientation;
    [self viewDidLoad];
    [self reloadView];
  } else if ( UIInterfaceOrientationIsLandscape(pToInterfaceOrientation) ) {
    [[NSBundle atgResourceBundle] loadNibNamed:@"ATGProductPageViewController" owner:self options:nil];
    [self.productDetailsPage willRotateToInterfaceOrientation:pToInterfaceOrientation duration:pDuration];
    self.currentOrientation = pToInterfaceOrientation;
    [self viewDidLoad];
    [self reloadView];
  }
}

#pragma mark - ATGGridCollectionViewDelegate

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didSelectObject:(id)pObject {
  // push it onto the stack
  ATGBaseProduct *product = [self.productStack pushProducts:@[pObject] setCurrent:((ATGBaseProduct *)pObject).repositoryId];
  // and set it as the current product
  [self productDetailsStack:self.productStack didGetProductDetails:product];
}

#pragma mark - Product manager delegate
- (void) didGetProduct:(ATGProductManagerRequest *)pProductRequest {
  self.product = pProductRequest.product;
}

- (void)didErrorGettingProduct:(ATGProductManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:pRequest.error.localizedDescription];
}

- (void) didGetRecentProducts:(NSArray *)pProducts {
  NSPredicate *otherProductsPredicate =
    [NSPredicate predicateWithBlock: ^BOOL (id pEvaluatedObject, NSDictionary * pBindings) {
       ATGRelatedProduct *related = (ATGRelatedProduct *)pEvaluatedObject;
       return ![related.repositoryId isEqualToString:self.product.repositoryId];
     }
    ];
  self.recentlyViewed = [pProducts filteredArrayUsingPredicate:otherProductsPredicate];//
  //[self reloadView];
}

- (void) didErrorGettingRecentProducts:(NSError *)pError {
  //[self alertWithTitleOrNil:nil withMessageOrNil:[error localizedFailureReason]];
}

#pragma mark - Product Page callbacks
- (void) didPressNextButton:(id)pSender {
  if ([self.productStack hasNextProductDetails]) {
    [self.productStack nextProductDetailsForObject:self];
  }
}

- (void) didPressPreviousButton:(id)pSender {
  if ([self.productStack hasPreviousProductDetails]) {
    [self.productStack previousProductDetailsForObject:self];
  }
}

- (void) didPressCloseButton {
//  [[ATGRootViewController_iPad rootViewController] popViewController];
}

- (void) didPressBackButton {
  [self requestProductWithId:[self.productStack popProductsList].repositoryId];
}

#pragma mark - Product stack callbacks
- (void) productDetailsStack:(ATGProductDetailsStack *)pStack didGetProductDetails:(ATGBaseProduct *)pProduct {
  [self requestProductWithId:pProduct.repositoryId];
}

#pragma mark - ATGRelatedProductGridDelegate

- (void) didSelectProductWithID:(NSString *)productID onSiteWithID:(NSString *)siteID {
  // push it onto the stack
  ATGBaseProduct *clickedProduct = nil;
  for(ATGBaseProduct *gridProduct in self.relatedGrid.relatedProducts){
    if ([gridProduct.repositoryId isEqualToString:productID]) {
      clickedProduct = gridProduct;
      break;
    }
  }
  if(clickedProduct){
    ATGBaseProduct *product = [self.productStack pushProducts:@[clickedProduct] setCurrent:clickedProduct.repositoryId];
    // and set it as the current product
    [self productDetailsStack:self.productStack didGetProductDetails:product];
    //[self requestProductWithId:productID];
    [self didPressDetailsButton:nil];
  }
}

@end