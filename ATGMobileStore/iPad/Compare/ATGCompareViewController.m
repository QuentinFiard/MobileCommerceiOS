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

#import "ATGCompareViewController.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGGridCollectionView.h>
#import <ATGMobileClient/ATGComparisonsItem.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import "ATGRootViewController_iPad.h"

#pragma mark - ATGCompareScrollView Definition
#pragma mark -

@interface ATGCompareScrollView : UIScrollView

- (NSArray *) compareItems;

@end

#pragma mark - ATGCompareViewController Private Protocol Definition
#pragma mark -

@interface ATGCompareViewController () <ATGGridCollectionViewDelegate>
#pragma mark - Custom properties
@property (nonatomic, strong) NSMutableArray *compareItems;
@property (nonatomic, strong) ATGProductManagerRequest *request;
#pragma mark - IB Properties
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortByButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *firstTextMessage;
@property (weak, nonatomic) IBOutlet UILabel *secondTextMessage;
@property (nonatomic, readwrite, weak) IBOutlet ATGGridCollectionView *compareItemsGrid;

#pragma mark - Private methods declaration
- (void) reloadData;
- (void) didPressContinueShoppingButton;

#pragma mark - IB Actions
- (IBAction) didPressSortButton:(id)sender;
- (IBAction) didPressShareButton:(id)sender;
@end

#pragma mark - ATGCompareViewController implementation
#pragma mark -
@implementation ATGCompareViewController
#pragma mark - Synthesized
@synthesize sortByButton;
@synthesize shareButton;
@synthesize firstTextMessage;
@synthesize secondTextMessage;
@synthesize compareItems, request;

#pragma mark - NSObject
- (id) initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    self.compareItems = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  //set all needed localized values
  self.title = NSLocalizedStringWithDefaultValue(@"ATGComparePage.PageTitle", nil, [NSBundle mainBundle], @"Compare Products", @"Title to be displayed on product compare view for iPad");

  self.sortByButton.title = NSLocalizedStringWithDefaultValue(@"ATGComparePage.SortByPrice", nil, [NSBundle mainBundle], @"ATGSort by: Price", @"This title is used by button that sorts compare items by price.");

  self.shareButton.title = NSLocalizedStringWithDefaultValue(@"ATGComparePage.ShareButtonTitle", nil, [NSBundle mainBundle], @"Share", @"Title of the toolbar button allowing the user to share list of products being compared.");

  [[self compareItemsGrid] setGridViewDelegate:self];
  [[self compareItemsGrid] setAllowsChoosing:NO];
  self.compareItemsGrid.allowsSelection = NO;
  [[self compareItemsGrid] setScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  request = [[ATGProductManager productManager] getComparisonsList:self];
}

#pragma mark - Private methods

- (void) reloadData {
  if ([compareItems count] == 0) {
    //compare list is empty. Display message and button to continue shopping
    UIImage *image = [UIImage imageNamed:@"btn-compare-large.png"];
    UIButton *continueShopping = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 35)];
    [continueShopping setTitle:NSLocalizedStringWithDefaultValue(@"ATGShoppingCartViewController_iPad.ContinueButtonTitle", nil, [NSBundle mainBundle], @"Continue Shopping", @"Title to be displayed on the 'Continue Shopping' button on empty shopping cart screen.") forState:UIControlStateNormal];
    [continueShopping setBackgroundImage:image forState:UIControlStateNormal];
    [continueShopping setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    continueShopping.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [continueShopping addTarget:self action:@selector(didPressContinueShoppingButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:continueShopping];
    barItem.width = ATGPhoneScreenWidth;
    self.toolbarItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], barItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];

    [self.firstTextMessage setHidden:NO];
    [self.secondTextMessage setHidden:NO];
    self.firstTextMessage.text = NSLocalizedStringWithDefaultValue(@"ATGCompareViewController_iPad.EmptyCompareMainMessage", nil, [NSBundle mainBundle], @"You have not selected any products to compare.", @"Main text to be displayed when compare list is empty.");
    self.secondTextMessage.text = NSLocalizedStringWithDefaultValue(@"ATGCompareViewController_iPad.EmptyCompareSubMessage", nil, [NSBundle mainBundle], @"You may add items to Comparisons from any product page.", @"Sub text to be displayed when compare list is empty.");
  } else {
    //comparison products was loaded - create view for them. And layout scroll view.
    [self.firstTextMessage setHidden:YES];
    [self.secondTextMessage setHidden:YES];
  }
  [[self compareItemsGrid] setObjectsToDisplay:[self compareItems]];
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (CGSize) contentSizeForViewInPopover {
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if ( UIInterfaceOrientationIsPortrait(orientation) ) {
    return CGSizeMake(768, 432);
  }
  return CGSizeMake(1024, 432);
}

#pragma mark - ATGGridCollectionViewDelegate

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView didSelectObject:(id)pObject {
  // NOOP, just implement required method.
}

- (void)gridCollectionView:(ATGGridCollectionView *)pGridView
           willDisplayCell:(ATGGridCollectionViewCell *)pCell {
  [(ATGCompareItem *)pCell setDelegate:self];
}

#pragma mark - IBAction implementation
- (void) didPressContinueShoppingButton {
  [[ATGRootViewController_iPad rootViewController].popover dismissPopoverAnimated:YES];
}

- (IBAction) didPressSortButton:(id)pSender {
  //sorting list of product by price
  NSArray *sortedArray = [self.compareItems sortedArrayUsingComparator: ^NSComparisonResult (id pObj1, id pObj2)
                          {
                            ATGComparisonsItem *address1 = (ATGComparisonsItem *)pObj1;
                            ATGComparisonsItem *address2 = (ATGComparisonsItem *)pObj2;

                            return [address1.lowestSalePrice compare:address2.lowestSalePrice];
                          }
                         ];
  self.compareItems = [NSMutableArray arrayWithArray:sortedArray];

  [self reloadData];
}
- (IBAction) didPressShareButton:(id)pSender {
  //TODO implement sharing function
}

#pragma mark - Orientation handling

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)pFromInterfaceOrientation {
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

#pragma mark - Compare item callbacks
- (void) didPressViewProduct:(ATGComparisonsItem *)pProduct {
  [[ATGRootViewController_iPad rootViewController] displayDetailsForProductId:pProduct.repositoryId inList:self.compareItems];
}

- (void) didPressDeleteProduct:(ATGComparisonsItem *)pProduct {
  //remove compare item from list on server
  self.request = [[ATGProductManager productManager] removeItemFromComparisons:pProduct delegate:self];
}

#pragma mark - Product manager callbacks
- (void) didGetComparisonsList:(NSArray *)pItems {
  self.compareItems = [NSMutableArray arrayWithArray:pItems];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  //We got list of product. Reload view to display them.
  [self reloadData];
}

- (void) didRemoveItemFromComparisons:(ATGProductManagerRequest *)pRequest {
  DebugLog(@"ATGRenderableProduct removed from comparison list");
  [self setRequest:[[ATGProductManager productManager] getComparisonsList:self]];
}

- (void) didErrorRemovingItemFromComparisons:(ATGProductManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
}

- (void)viewDidUnload {
  [self setCompareItemsGrid:nil];
  [super viewDidUnload];
}
@end

#pragma mark - ATGCompareScrollView Implementation
#pragma mark -

@implementation ATGCompareScrollView

#pragma mark - UIAccessibility

- (BOOL) isAccessibilityElement {
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger) accessibilityElementCount {
  return [[self compareItems] count];
}

- (id) accessibilityElementAtIndex:(NSInteger)index {
  return [[self compareItems] objectAtIndex:index];
}

- (NSInteger) indexOfAccessibilityElement:(id)element {
  for (NSInteger index = 0; index < [self accessibilityElementCount]; index++) {
    if (element == [self accessibilityElementAtIndex:index]) {
      return index;
    }
  }
  return NSNotFound;
}

#pragma mark - Private Protocol Implementation

- (NSArray *) compareItems {
  NSPredicate *filter = [NSPredicate
                         predicateWithBlock: ^BOOL (id pEvaluatedObject,
                                                    NSDictionary * pBindings) {
                           return [pEvaluatedObject isKindOfClass:[ATGCompareItem class]];
                         }
                        ];
  return [[self subviews] filteredArrayUsingPredicate:filter];
}

@end