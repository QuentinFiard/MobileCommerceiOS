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

/*!

   @header
   @abstract Manager for products related server calls.

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGProductManager.h#1 $$Change: 848678 $

 */

#import "ATGProduct.h"
#import "ATGSku.h"
#import "ATGProductInventory.h"
#import <ATGMobileCommon/ATGCache.h>
#import "ATGProductManagerDelegate.h"

@class ATGRestManager;

@class ATGComparisonsItem;

/*!
   @const
   @abstract ATGRenderableProduct inventory component path
 */
extern NSString *const ATG_PRODUCT_INVENTORY_COMPONENT_PATH;
/*!
   @const
   @abstract Back in stock notifications component path
 */
extern NSString *const ATG_BACK_IN_STOCK_COMPONENT_PATH;
/*!
   @const
   @abstract 'notify me' action form handler name
 */
extern NSString *const ATG_NOTIFY_ME_FORM_HANDLER_NAME;
/*!
   @const
   @abstract ATGRenderableProduct catalog component_path
 */
extern NSString *const ATG_PRODUCT_CATALOG_COMPONENT_PATH;

/*!
   @constant
   @abstract The amount of time in seconds that a product in the cache is valid for.
 */
extern const int ATG_PRODUCT_CACHE_TIME_OUT_SEC;

@class ATGProductManagerRequest;

/*!
   @constant
   @abstract Error domain to be used when validator creates an NSError instance.
 */
static NSString *const ATGProductManagerErrorDomain = @"com.atg.ATGProductManager";

@class ATGProductManager;

/*!
   @class
   @abstract Provides the necessary calls to get products from the server or the CoreData cache.
 */
@interface ATGProductManager : NSObject {
}

/*!
   @property
   @abstract The REST manager
 */
@property (nonatomic, weak, readonly) ATGRestManager *restManager;

/*!
   @property
   @abstract The path of the actor chain that retrieves a product
 */
@property (nonatomic, strong) NSString *getProductActorChain;

/*!
   @property
   @abstract The path of the actor chain that retrieves recently viewed products
 */
@property(nonatomic, strong) NSString *getRecentProductsActorChain;

/*!
   @method
   @abstract Get the shared product manager.
 */
+ (ATGProductManager *) productManager;

/*!
   @method
   @abstract Inits a new class with a give CoreData context
   @param pContext the CoreData NSManagedObjectContext
 */
- (id) initWithCache:(id <ATGCache>)pCache;

/*!
   @method
   @abstract Gets the product with a given ID.
   @discussion The product will be either fetched from the server configured in the @link ATGRestManager @/link or from the CoreData cache if the product has been previously fetched and the cache timeout has not been reached. @link //apple_ref/occ/intfm/ATGProductManagerDelegate/didGetProduct: [ATGProductManagerDelegate didGetProduct:]@/link
 */
- (ATGProductManagerRequest *) getProduct:(NSString *)pProductId delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate;
/*!
   @method getProduct:fromCurrentSiteOnly:delegate:
   @abstract Retrieves a product with a given ID.
   @duscussion The product will be either fetched from server or from CoreData cache
   if the product has been previously cached and cache timeout has not been reached.
   This method allows you to define, if product contents and the product itself should be
   filtered by site and catalog.
   @param productID ID of product to be retrieved.
   @param currentSiteOnly Defines, if the product contents should be filtered by catalog/site.
   Specify YES, if you do not want the server to return products from catalog/site different
   from user's current site/catalog. If you specify NO with this parameter, no filtering
   will be applied at server-side.
   @param delegate Object which will receive success/failure messages.
   @return Current product fetch request.
 */
- (ATGProductManagerRequest *) getProduct:(NSString *)productID fromCurrentSiteOnly:(BOOL)currentSiteOnly
                withRecentlyViewedProducts:(BOOL)pWithRecentlyViewedProducts delegate:(NSObject <ATGProductManagerDelegate> *)delegate;

/*!
   @method
   @abstract Clears all products from the cache
 */
- (void) clearCache;

/*!
   @method
   @abstract Get the inventory level for a given product.
   @discussion The values of this call will never be cached to ensue the data is always up to date.
 */
- (ATGProductManagerRequest *) getProductInventoryLevel:(NSString *)pProductId delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate;

/*!
 @method
 @abstract Get the inventory levels for a SKU at nearby stores
*/
- (ATGProductManagerRequest *) getInventoryLevelAtNearbyStoresWithSkuId:(NSString *)pSkuId delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate;

/*!
   @method
   @abstract Register an email to get notificaitons when a product/sku is back in stock
 */
- (ATGProductManagerRequest *) registerBackInStockNotificationsForProduct:(NSString *)pProductId sku:(NSString *)pSkuId emailAddress:(NSString *)pEmailAddress delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate;

/*!
   @method getRecentProducts:
   @abstract Retrieves products recently viewed by current user.
   @param delegate Pass an object which will receive success/error messages from manager.
   @return Request which is being performed.
 */
- (ATGProductManagerRequest *) getRecentProducts:(NSObject <ATGProductManagerDelegate> *)delegate;
/*!
   @method getComparisonsList:
   @abstract Retrieves products added to the Comparisons List.
   @param delegate This object will receive messages about successfully/failure method execution.
   @return Request which is being executed.
 */
- (ATGProductManagerRequest *) getComparisonsList:(id <ATGProductManagerDelegate>)delegate;
/*!
   @method removeFromComparisonsProduct:delegate:
   @abstract This method removes a product from the comparisons list.
   @param item Comparisons item to be removed from the list.
   @param delegate This object will receive success/failure messages from manager.
   @return Request which is being executed.
 */
- (ATGProductManagerRequest *) removeItemFromComparisons:(ATGComparisonsItem *)item
 delegate                                               :(id <ATGProductManagerDelegate>)delegate;
/*!
   @method addProductToComparisons:delegate:
   @abstract This method adds a product into comparisons list.
   @param productID ID of product to be added to the list.
   @param siteID ID of site the product belongs to.
   @param delegate This object will receive success/failure messages from the manager.
   @return Request which is being executed.
 */
- (ATGProductManagerRequest *) addProductToComparisons:(NSString *)productID
   siteID                                               :(NSString *)siteID
 delegate                                             :(id <ATGProductManagerDelegate>)delegate;
/*!
   @method clearComparisonsList:
   @abstract This method removes all objects from the comparisons list.
   @param delegate This object will receive success/failure messages from the manager.
   @return Request which is being executed.
 */
- (ATGProductManagerRequest *) clearComparisonsList:(id <ATGProductManagerDelegate>)delegate;

/*
   @method
   @abstract Inserts a product into the CoreData cache.
   @param pProduct The product to insert
 */
- (void) insertProductToCache:(ATGProduct *)pProduct;

@end