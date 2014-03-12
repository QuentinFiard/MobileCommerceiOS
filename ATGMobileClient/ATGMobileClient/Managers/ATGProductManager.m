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

#import "ATGProductManager.h"
#import "ATGRelatedProduct.h"
#import <ATGMobileCommon/ATGRepositoryCoreDataCache.h>
#import "ATGComparisonsItem.h"
#import "ATGProductManagerRequest.h"
#import <ATGMobileClient/ATGRestManager.h>

const int ATG_PRODUCT_CACHE_TIME_OUT_SEC = 600;

static ATGProductManager *productManager;

static NSString *const ATG_PRODUCT_INVENTORY_ACTOR_PATH = @"/atg/store/inventory/InventoryActor/getInventoryBySkuForProduct";
static NSString *const ATG_NOTIFY_ME_ACTOR_PATH  = @"/atg/store/inventory/InventoryActor/notifyMeWhenBackInStock";
static NSString *const ATG_PRODUCT_ACTOR_PATH = @"/atg/commerce/catalog/ProductCatalogActor/getProduct";
static NSString *const ATG_PRODUCT_FILTER_PROPERTY_NAME = @"filterBySite";
static const NSInteger ATG_RECENT_PRODUCTS_SIZE = 21;
static NSString *const ATG_RECENT_PRODUCTS_PATH = @"/atg/commerce/catalog/ProductCatalogActor/sendViewItemEventGetRecentlyViewedProducts";
static NSString *const ATG_SEND_VIEW_ITEM_EVENT_PATH = @"/atg/commerce/catalog/ProductCatalogActor/sendViewItemEvent";
static NSString *const ATGComparisonsHandlerActorPath = @"/atg/commerce/catalog/comparison/ProductListHandlerActor/";
static NSString *const ATGComparisonsHandlerAddChain = @"addProduct";
static NSString *const ATGComparisonsHandlerRemoveChain = @"deleteProduct";
static NSString *const ATGComparisonsHandlerClearListChain = @"clearList";
static NSString *const ATGComparisonsHandlerGetListChain = @"summary";
static NSString *const ATGComparisonsHandlerProductParameter = @"productID";
static NSString *const ATGComparisonsHandlerSiteParameter = @"siteID";
static NSString *const ATGComparisonsHandlerSkuParameter = @"skuID";
static NSString *const ATGComparisonsHandlerCategoryParameter = @"categoryID";



@interface ATGProductManager ()

/*!
   @property
   @abstract The product cache
 */
@property (strong, atomic) id <ATGCache> productCache;

- (ATGProductManagerRequest *) loadProductWithId:(NSString *)pProductId fromCurrentSiteOnly:(BOOL)currentSiteOnly
                       withRecentlyViewedProducts:(BOOL)pWithRecentlyViewedProducts delegate:(id)pDelegate;
/*
   @method
   @abstract Gets the product from the cache
   @discussion The ATGRenderableProduct will be returned from from the cache if one exists and
   the cache timeout of @link ATG_PRODUCT_CACHE_TIME_OUT_SEC @/link has not elapsed.
   Otherwise nil is returned.
 */
- (ATGProduct *) getProductFromCache:(NSString *)pProductId;

- (void) sendViewItemEventForProductId:(NSString *)productID;

@end

@implementation ATGProductManager

@synthesize productCache = _productCache, restManager = _restManager, getProductActorChain = _getProductActorChain,
  getRecentProductsActorChain = _getRecentProductsActorChain;

#pragma mark - Init and Dealloc

- (id) initWithCache:(id <ATGCache>)pCache {
  self = [super init];
  if (self) {
    _productCache = pCache;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:ATG_CLEAR_PRODUCT_CACHE object:nil];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ATG_CLEAR_PRODUCT_CACHE object:nil];
}

+ (ATGProductManager *) productManager {
  static dispatch_once_t pred_product_manager;
  dispatch_once(&pred_product_manager,
                ^{
                  productManager =
                    [[ATGProductManager alloc] initWithCache:[[ATGRepositoryCoreDataCache alloc] initWithEntityDescriptionName:[ATGProduct entityDescriptorName] expiryTime:ATG_PRODUCT_CACHE_TIME_OUT_SEC]];
                  productManager.getProductActorChain = ATG_PRODUCT_ACTOR_PATH;
                  productManager.getRecentProductsActorChain = ATG_RECENT_PRODUCTS_PATH;
                }
                );
  return productManager;
}

- (ATGRestManager *) restManager {
  if (_restManager == nil) {
    _restManager = [ATGRestManager restManager];
  }
  return _restManager;
}

#pragma mark - Public Methods

- (ATGProductManagerRequest *) getProduct:(NSString *)pProductId
                                 delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate {
  return [self getProduct:pProductId fromCurrentSiteOnly:NO withRecentlyViewedProducts:NO delegate:pDelegate];
}

- (ATGProductManagerRequest *) getProduct:(NSString *)pProductId fromCurrentSiteOnly:(BOOL)pCurrentSiteOnly
                  withRecentlyViewedProducts:(BOOL)pWithRecentlyViewedProducts delegate:(id)pDelegate {
  //check for nil id
  if (![pProductId isNotBlank]) {
    if ([pDelegate respondsToSelector:@selector(didErrorGettingProduct:)]) {
      NSError *error = [NSError errorWithDomain:ATG_ERROR_DOMAIN code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringWithDefaultValue(@"mobile.product.nullProductId", nil, [NSBundle mainBundle], @"ATGRenderableProduct ID cannot be null.", @"The product ID was null"), NSLocalizedDescriptionKey, nil]];
      [pDelegate performSelectorOnMainThread:@selector(didErrorGettingProduct:) withObject:error waitUntilDone:NO];
      return nil;
    }
  }
  DebugLog(@"Getting product %@", pProductId);
  ATGProduct *product = [self getProductFromCache:pProductId];
  if (product == nil) {
    DebugLog(@"ATGRenderableProduct %@ not found in cache, loading from server", pProductId);
    return [self loadProductWithId:pProductId fromCurrentSiteOnly:pCurrentSiteOnly withRecentlyViewedProducts:pWithRecentlyViewedProducts delegate:pDelegate];
  }
  
  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  request.product = product;
  request.delegate = pDelegate;
  
  [request sendResponse:@selector(didGetProduct:)];
  
  if (pWithRecentlyViewedProducts) {
    return [self getRecentProducts:pDelegate];
  }
  
  return request;
}

- (void) insertProductToCache:(ATGProduct *)pProduct {
  if (pProduct.repositoryId != nil) {
    DebugLog(@"Adding ATGRenderableProduct %@ into cache", pProduct.repositoryId);
    [self.productCache insertItemIntoCache:pProduct withID:pProduct.repositoryId];
  }
}

- (ATGProduct *) getProductFromCache:(NSString *)pProductId {
  ATGProduct *product = [self.productCache getItemFromCacheWithID:pProductId];

  return product;
}

- (void) clearCache {
  DebugLog(@"Clearing product Cache");
  [self.productCache clearCache];
}

- (ATGProductManagerRequest *) getProductInventoryLevel:(NSString *)pProductId delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate {
  DebugLog(@"Loading ATGRenderableProduct %@ inventory from server.", pProductId);
  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  request.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingInventoryLevel:);
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pProductId, @"productId", nil];

  id <ATGRestOperation> operation = [self.restManager.restSession executePostRequestForActorPath:ATG_PRODUCT_INVENTORY_ACTOR_PATH parameters:params requestFactory:nil options:ATGRestRequestOptionNone success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![request sendError:error withSelector:errorSelector]) {
                                         DebugLog (@"Got inventory %@", pResponseObject);
                                         [request setProductInventory:(ATGProductInventory *)[ATGProductInventory objectFromDictionary:[pResponseObject objectForKey:@"inventoryStates"]]];
                                         [request sendResponse:@selector(didGetInventoryLevel:)];
                                       }
                                     }
                                     failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       [request sendError:pError withSelector:errorSelector];
                                     }
                                    ];

  request.operation = operation;
  return request;
}

- (ATGProductManagerRequest *) registerBackInStockNotificationsForProduct:(NSString *)pProductId sku:(NSString *)pSkuId emailAddress:(NSString *)pEmailAddress delegate:(NSObject <ATGProductManagerDelegate> *)pDelegate {
  DebugLog(@"Registering to be notified of %@-%@.", pProductId, pSkuId);
  SEL errorSelector = @selector(didErrorRegisteringBackInStockNotification:);
  ;
  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  request.delegate = pDelegate;
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pProductId, @"productId", pSkuId, @"catalogRefId", pEmailAddress, @"emailAddress", nil];

  id <ATGRestOperation> operation = [self.restManager.restSession executePostRequestForActorPath:ATG_NOTIFY_ME_ACTOR_PATH parameters:params requestFactory:nil options:ATGRestRequestOptionReturnFormExceptions success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![request sendError:error withSelector:errorSelector]) {
                                         DebugLog (@"Back in stock notification registered: %@", pResponseObject);
                                         [request sendResponse:@selector(didRegisterBackInStockNotification:)];
                                       }
                                     }
                                     failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                         DebugLog (@"Back in stock notification error: %@", pError);
                                         error = pError;
                                       }
                                       /* else if (pFormExceptions)    {
                                         DebugLog (@"Back in stock notification error: %@", pFormExceptions);
                                         NSDictionary *userInfo = [NSMutableDictionary dictionary];
                                         NSString *errorMessage = NSLocalizedStringWithDefaultValue (@"ATGCommerceManager.AddToCartError", nil,
                                                                                                     [NSBundle mainBundle], @"Error adding to cart.",
                                                                                                     @"Error message adding to cart");
                                         [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                                         if ([pFormExceptions isKindOfClass:[NSArray class]]) {
                                           [userInfo setValue:pFormExceptions forKey:ATG_FORM_EXCEPTION_KEY];
                                         }
                                         error = [NSError errorWithDomain:ATGProductManagerErrorDomain code:-1 userInfo:userInfo];
                                       } */
                                       [request sendError:error withSelector:errorSelector];
                                     }
                                    ];

  request.operation = operation;
  return request;
}

- (ATGProductManagerRequest *) getRecentProducts:(NSObject <ATGProductManagerDelegate> *)pDelegate {
  SEL success = @selector(didGetRecentProducts:);
  SEL failure = @selector(didErrorGettingRecentProducts:);

  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  [request setDelegate:pDelegate];

  NSDictionary *params = @{ @"size" : [NSNumber numberWithInteger:ATG_RECENT_PRODUCTS_SIZE] };
  id <ATGRestOperation> restOperation =
  [[[self restManager] restSession] executePostRequestForActorPath:self.getRecentProductsActorChain
                                                         parameters:params
                                                         requestFactory:nil
                                                                options:ATGRestRequestOptionNone
                                                                success:
     ^(id <ATGRestOperation> pOperation, id pResponseObject) {
       NSError *error = [ATGRestManager checkForError:pResponseObject];
       if (![request sendError:error withSelector:failure]) {
         // Recently viewed products have the same properties as related items have.
         // So we're just reusing existing object.
         NSArray *products = [ATGRelatedProduct objectsFromArray:[pResponseObject objectForKey:@"recentlyViewedProducts"]];
         [request setRecentProducts:products];
         if ([pDelegate respondsToSelector:success]) {
           [pDelegate performSelectorOnMainThread:success withObject:products waitUntilDone:NO];
         }
       }
     }
                                                                failure:
     ^(id <ATGRestOperation> pOperation, NSError *pError) {
       [request sendError:pError withSelector:failure];
     }
    ];
  [request setOperation:restOperation];
  return request;
}

- (ATGProductManagerRequest *) getComparisonsList:(id <ATGProductManagerDelegate>)pDelegate {
  SEL failure = @selector(didErrorGettingComparisonsList:);

  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  [request setDelegate:pDelegate];
  [request setOperation:[[[ATGRestManager restManager] restSession]
                         executePostRequestForActorPath:[ATGComparisonsHandlerActorPath stringByAppendingString:ATGComparisonsHandlerGetListChain]
                                             parameters:nil
                                            requestFactory:nil
                                                   options:ATGRestRequestOptionNone
                                                   success: ^(id <ATGRestOperation> pOperation, id pResponseObject) {
                           if (![request sendError:[ATGRestManager checkForError:pResponseObject]
                                      withSelector:failure]) {
                             // Parse server response. ATGComparisonsItem has properties defined
                             // with the same names as server expects, so no special handling here.
                             NSArray *result = [ATGComparisonsItem objectsFromArray:[pResponseObject objectForKey:@"products"]];
                             // Dispatch this task to main queue, this will perform operation on main thread.
                             dispatch_async (dispatch_get_main_queue (), ^{
                                               [pDelegate didGetComparisonsList:result];
                                             }
                                             );
                           }
                         }
                         failure: ^(id <ATGRestOperation> pOperation, NSError * pError) {
                           [request sendError:pError withSelector:failure];
                         }
   ]];
  return request;
}

- (ATGProductManagerRequest *) addProductToComparisons:(NSString *)pProductID
                                                siteID:(NSString *)pSiteID
                                              delegate:(id <ATGProductManagerDelegate>)pDelegate {
  SEL success = @selector(didAddProductToComparisons:);
  SEL failure = @selector(didErrorAddingProductToComparisons:);

  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  [request setDelegate:pDelegate];
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              pProductID, ATGComparisonsHandlerProductParameter,
                              pSiteID, ATGComparisonsHandlerSiteParameter, nil];
  [request setOperation:[[[ATGRestManager restManager] restSession]
                         executePostRequestForActorPath:[ATGComparisonsHandlerActorPath stringByAppendingString:ATGComparisonsHandlerAddChain]
                                 parameters:parameters
                             requestFactory:nil
                                    options:ATGRestRequestOptionReturnFormExceptions
                                    success: ^(id <ATGRestOperation> pOperation, id pResponseObject) {
                           if (![request sendError:[ATGRestManager checkForError:pResponseObject]
                                      withSelector:failure]) {
                             [request sendResponse:success];
                           }
                         }
                                    failure: ^(id <ATGRestOperation> pOperation, NSError * pError) {
                                      if (![request sendError:pError withSelector:failure]) {
                                        [request sendError:pError withSelector:failure];
                                      }
                         }
   ]];
  return request;
}

- (ATGProductManagerRequest *) removeItemFromComparisons:(ATGComparisonsItem *)pItem
                                                delegate:(id <ATGProductManagerDelegate>)pDelegate {
  SEL success = @selector(didRemoveItemFromComparisons:);
  SEL failure = @selector(didErrorRemovingItemFromComparisons:);

  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  [request setDelegate:pDelegate];
  NSDictionary *parameters = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              [pItem repositoryId], ATGComparisonsHandlerProductParameter,
                              [pItem siteId], ATGComparisonsHandlerSiteParameter,
                              [pItem skuId], ATGComparisonsHandlerSkuParameter,
                              [pItem categoryId], ATGComparisonsHandlerCategoryParameter, nil];
  [request setOperation:[[[ATGRestManager restManager] restSession]
                         executePostRequestForActorPath:[ATGComparisonsHandlerActorPath stringByAppendingString:ATGComparisonsHandlerRemoveChain]
                                 parameters:parameters
                             requestFactory:nil
                                    options:ATGRestRequestOptionReturnFormExceptions
                                    success: ^(id <ATGRestOperation> pOperation, id pResponseObject) {
                           if (![request sendError:[ATGRestManager checkForError:pResponseObject]
                                      withSelector:failure]) {
                             [request sendResponse:success];
                           }
                         }
                                    failure: ^(id <ATGRestOperation> pOperation, NSError * pError) {
                                      if (![request sendError:pError withSelector:failure]) {
                                        [request sendError:pError withSelector:failure];
                                      }
                         }
   ]];
  return request;
}

- (ATGProductManagerRequest *) clearComparisonsList:(id <ATGProductManagerDelegate>)pDelegate {
  SEL success = @selector(didClearComparisons:);
  SEL failure = @selector(didErrorClearingComparisons:);

  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  [request setDelegate:pDelegate];
  [request setOperation:[[[ATGRestManager restManager] restSession]
                         executePostRequestForActorPath:[ATGComparisonsHandlerActorPath stringByAppendingString:ATGComparisonsHandlerClearListChain]
                                 parameters:nil
                             requestFactory:nil
                                    options:ATGRestRequestOptionReturnFormExceptions
                                    success: ^(id <ATGRestOperation> pOperation, id pResponseObject) {
                           if (![request sendError:[ATGRestManager checkForError:pResponseObject]
                                      withSelector:failure]) {
                             [request sendResponse:success];
                           }
                         }
                                    failure: ^(id <ATGRestOperation> pOperation, NSError * pError) {
                           if (![request sendError:pError withSelector:failure]) {
                             [request sendError:pError withSelector:failure];
                           }
                         }
   ]];
  return request;
}

#pragma mark - Private Methods

- (ATGProductManagerRequest *) loadProductWithId:(NSString *)pProductId fromCurrentSiteOnly:(BOOL)pCurrentSiteOnly
                       withRecentlyViewedProducts:(BOOL)pWithRecentlyViewedProducts delegate:(id)pDelegate {
  DebugLog(@"Loading ATGRenderableProduct %@ from server.", pProductId);
  ATGProductManagerRequest *request = [[ATGProductManagerRequest alloc] initWithProductManager:self];
  SEL errorSelector = @selector(didErrorGettingProduct:);
  request.delegate = pDelegate;

  NSDictionary *parameters =
    @{ATG_PRODUCT_FILTER_PROPERTY_NAME : pCurrentSiteOnly ? @"true" : @"false",
      @"filterByCatalog" : pCurrentSiteOnly ? @"true" : @"false", 
      @"productId" : pProductId,
      @"getRecentlyViewedProducts" : pWithRecentlyViewedProducts ? @"true" : @"false",
      @"size" : @(ATG_RECENT_PRODUCTS_SIZE)};
  
  id <ATGRestOperation> operation = [self.restManager.restSession executePostRequestForActorPath:self.getProductActorChain parameters:parameters requestFactory:nil options:ATGRestRequestOptionNone success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (error) {
                                         // Update error instance with additional data.
                                         NSInteger errorCode = [[pResponseObject objectForKey:@"errorCode"] integerValue];
                                         if (errorCode == 13) {
                                           // It's a 'Wrong site' error, get proper product URL from the error object.
                                           NSMutableDictionary *userInfo = [[error userInfo] mutableCopy];
                                           [userInfo setObject:[pResponseObject objectForKey:@"url"]
                                                        forKey:NSURLErrorFailingURLStringErrorKey];
                                           error = [NSError errorWithDomain:[error domain] code:errorCode userInfo:userInfo];
                                         }
                                       }
                                       if (![request sendError:error withSelector:errorSelector]) {
                                         ATGProduct *product = (ATGProduct *)[ATGProduct objectFromDictionary:[pResponseObject objectForKey:@"product"]];
                                         [request.productManager insertProductToCache:product];
                                         request.product = product;
                                         [request sendResponse:@selector(didGetProduct:)];
                                         
                                         NSArray *products = [ATGRelatedProduct objectsFromArray:[pResponseObject objectForKey:@"recentlyViewedProducts"]];
                                         [request setRecentProducts:products];
                                         if ([pDelegate respondsToSelector:@selector(didGetRecentProducts:)]) {
                                           [pDelegate performSelectorOnMainThread:@selector(didGetRecentProducts:) withObject:products waitUntilDone:NO];
                                         }
    
                                       }
                                     }
                                     failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       [request sendError:pError withSelector:errorSelector];
                                     }
                                    ];

  request.operation = operation;
  return request;
}

- (void) sendViewItemEventForProductId:(NSString *)pProductID {
  NSDictionary *params = @{ @"productId" : pProductID };
  [[[self restManager] restSession] executePostRequestForActorPath:ATG_SEND_VIEW_ITEM_EVENT_PATH
                                                      parameters:params
                                                      requestFactory:nil
                                                      options:ATGRestRequestOptionNone
                                                      success:
   ^(id <ATGRestOperation> pOperation, id pResponseObject) {
     // Do nothing -- no response expected
   }
                                                      failure:
   ^(id <ATGRestOperation> pOperation, NSError * pError) {
     // Do nothing
   }
  ];
}

@end