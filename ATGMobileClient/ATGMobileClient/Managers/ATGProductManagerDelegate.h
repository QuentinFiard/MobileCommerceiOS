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

/*!
 
 @header
 
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGProductManagerDelegate.h#1 $$Change: 848678 $
 
 */
@class ATGProductManagerRequest;

/*!
 @protocol
 @abstract Call back methods for @link ATGProductManager @/link
 */
@protocol ATGProductManagerDelegate <NSObject>
@optional
/*!
 @method
 @abstract Delegate call back when getting a ATGRenderableProduct
 @discussion Success callback for @link //apple_ref/occ/instm/ATGProductManager/getProduct:delegate: [ATGProductManager getProduct:delegate:]@/link.
 @link //apple_ref/occ/instp/ATGProductManagerRequest/product ATGProductManagerRequest.product@/link will be set to an instance of @link ATGProduct @/link.
 */
- (void) didGetProduct:(ATGProductManagerRequest *)pRequest;
/*!
 @method
 @abstract Delegate call back if there is an error getting the product
 @discussion Error callback for @link //apple_ref/occ/instm/ATGProductManager/getProduct:delegate: [ATGProductManager getProduct:delegate:]@/link.
 @link //apple_ref/occ/instp/ATGManagerRequest/error ATGManagerRequest.error@/link will be set to an instance of @link NSError @/link.
 */
- (void) didErrorGettingProduct:(ATGProductManagerRequest *)pRequest;
/*!
 @method
 @abstract Delegate call back when a ATGRenderableProduct's inventory levels are fetched.
 */
- (void) didGetInventoryLevel:(ATGProductManagerRequest *)pRequst;
/*!
 @method
 @abstract Delegate call back if there is an error getting the product
 */
- (void) didErrorGettingInventoryLevel:(ATGProductManagerRequest *)pRequest;
/*!
 @method
 @abstract Delegate call back when a ATGRenderableProduct's inventory levels are fetched.
 */
- (void) didRegisterBackInStockNotification:(ATGProductManagerRequest *)pRequst;
/*!
 @method
 @abstract Delegate call back if there is an error getting the product
 */
- (void) didErrorRegisteringBackInStockNotification:(ATGProductManagerRequest *)pRequest;

/*!
 @method didErrorGettingRecentProducts:
 @abstract This method is called when manager was unable to retrieve recently viewed products.
 @param error Error received from server.
 */
- (void) didErrorGettingRecentProducts:(NSError *)error;
/*!
 @method didGetRecentProducts:
 @abstract This method is called when recently viewed products are ready to be displayed.
 @param products Array of ATGRelatedProduct objects, represent recently viewed products.
 */
- (void) didGetRecentProducts:(NSArray *)products;
/*!
 @method didAddProductToComparisons:
 @abstract This method is called when successfully added a product to Comparisons list.
 @param request REST request.
 */
- (void) didAddProductToComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didErrorAddingProductToComparisons:
 @abstract This method is called when the manager was unable to add product to Comparisons.
 @param request REST request.
 */
- (void) didErrorAddingProductToComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didClearComparisons:
 @abstract This method is called when successfully cleared the Comparisons list.
 @param request REST request.
 */
- (void) didClearComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didErrorClearingComparisons:
 @abstract This method is called when the manager was unable to clear Comparisons.
 @param request REST request.
 */
- (void) didErrorClearingComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didRemoveItemFromComparisons:
 @abstract This method is called when successfully removed an item from the Comparisons list.
 @param request REST request.
 */
- (void) didRemoveItemFromComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didErrorRemovingItemFromComparisons:
 @abstract This method is called when the manager was unable to remove product from Comparisons.
 @param request REST request.
 */
- (void) didErrorRemovingItemFromComparisons:(ATGProductManagerRequest *)request;
/*!
 @method didGetComparisonsList:
 @abstract This method is called after the manager successfully retrieved a list of products to be compared.
 @param items Array of ATGComparisonsItem objects, representing current Comparisons list.
 */
- (void) didGetComparisonsList:(NSArray *)items;
/*!
 @method didErrorGettingComparisonsList:
 @abstract This method is called when the manager was unable to retrieve Comparisons.
 @param request REST request.
 */
- (void) didErrorGettingComparisonsList:(ATGProductManagerRequest *)request;

@end
