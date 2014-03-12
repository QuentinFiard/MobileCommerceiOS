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

#import <ATGMobileClient/ATGLoginDelegate.h>
#import <ATGMobileClient/ATGGiftListManagerDelegate.h>
#import "ATGGiftListsViewController.h"
#import "ATGProductDetailsPage_iPad.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGGiftListManager.h>
#import "ATGLoginViewController.h"
#import <ATGMobileClient/ATGGiftListManagerRequest.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>
#import "ATGRootViewController_iPad.h"

static NSString *const ATGSelectGiftListControllerID = @"atgSelectGiftListRootNavigationController";

#pragma mark - ATGProductDetailsPage_iPad implementation
#pragma mark -
@implementation ATGProductDetailsPage_iPad

#pragma mark - Actions implementation
- (IBAction) didPressAddToCompareButton:(id)pSender {
  self.productRequest = [[ATGProductManager productManager] addProductToComparisons:self.product.repositoryId siteID:self.product.siteId delegate:self];
}

- (IBAction)didTouchAddToWishListButton:(UIButton *)pSender {
  [[self popover] dismissPopoverAnimated:YES];
  if (self.sku && self.quantity) {
    [[ATGGiftListManager instance] addProductToWishList:self.product.repositoryId
                                                    sku:self.sku.repositoryId
                                               quantity:self.quantity
                                               delegate:self];
  } else {
    NSString *message = NSLocalizedStringWithDefaultValue
        (@"ATGProductPage_iPad.ErrorMessage.WishListNoSkuSelected",
         nil, [NSBundle mainBundle], @"Select SKU to be added to your wish list, please.",
         @"Error message to be displayed if trying to add product to wish list with no SKU selected.");
    [self alertWithTitleOrNil:nil withMessageOrNil:message];
  }
}

- (IBAction)didTouchAddToGiftListButton:(UIButton *)pSender {
  if (self.sku && self.quantity) {
    UIStoryboard *giftListStoryboard =
        [UIStoryboard storyboardWithName:@"GiftListStoryboard_iPad" bundle:nil];
    ATGResizingNavigationController *contents =
        [giftListStoryboard instantiateViewControllerWithIdentifier:ATGSelectGiftListControllerID];
    [self setPopover:[[UIPopoverController alloc] initWithContentViewController:contents]];
    [contents setPopoverController:[self popover]];
    ATGGiftListsViewController *listController = (ATGGiftListsViewController *)[contents topViewController];
    [listController setDelegate:self];
    [[self popover] presentPopoverFromRect:[pSender bounds]
                                    inView:pSender
                  permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                  animated:YES];
  } else {
    NSString *message = NSLocalizedStringWithDefaultValue
        (@"ATGProductPage_iPad.ErrorMessage.GiftListNoSkuSelected",
         nil, [NSBundle mainBundle], @"Select SKU to be added to your gift list, please.",
         @"Error message to be displayed if trying to add product to gift list with no SKU selected.");
    [self alertWithTitleOrNil:nil withMessageOrNil:message];
  }
}

#pragma mark - ATGGiftListManagerDelegate

- (void)giftListManagerDidFailWithError:(NSError *)pError {
  [self alertWithTitleOrNil:nil withMessageOrNil:[pError localizedDescription]];
}

#pragma mark - ATGGiftListsViewControllerDelegate

- (BOOL)viewController:(ATGGiftListsViewController *)pController didSelectGiftList:(NSString *)pGiftListID {
  [[ATGGiftListManager instance] addProduct:self.product.repositoryId
                                        sku:self.sku.repositoryId
                                   quantity:self.quantity
                                 toGiftList:pGiftListID
                                   delegate:self];
  [[self popover] dismissPopoverAnimated:YES];
  return NO;
}

- (BOOL)viewControllerShouldDisplayNewGiftListButton:(ATGGiftListsViewController *)pController {
  return YES;
}

#pragma mark - ATGLoginDelegate

- (void)requiresLogin {
  UIStoryboard *giftListStoryboard = [UIStoryboard storyboardWithName:@"GiftListStoryboard_iPad" bundle:nil];
  ATGResizingNavigationController *contents =
      [giftListStoryboard instantiateViewControllerWithIdentifier:@"ATGResizingNavigationController"];
  ATGLoginViewController *loginController = (ATGLoginViewController *)[contents topViewController];
  [loginController setDelegate:self];
  [self setPopover:[[UIPopoverController alloc] initWithContentViewController:contents]];
  [contents setPopoverController:[self popover]];
  [[self popover] presentPopoverFromRect:[[self wishListButton] bounds]
                                  inView:[self wishListButton]
                permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                animated:YES];
}

#pragma mark - ATGLoginViewControllerDelegate

- (void)didLogin {
  [self didTouchAddToWishListButton:nil];
}

- (void) didPressViewCartButton {
  [[ATGRootViewController_iPad rootViewController] displayCart];
}

@end
