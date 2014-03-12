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

#import "ATGCommerceManager.h"
#import "ATGOrder.h"
#import "ATGBaseProduct.h"
#import "ATGProfileManager.h"
#import "ATGCommerceManagerRequest.h"

NSString *const ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION = @"kATGShoppingCartItemsChangedNotification";
NSString *const ATG_SHOPPING_CART_ITEMS_NUMBER_KEY = @"kATGShoppingCartItemsCountKey";

static NSString *const ATGActorChainGetShoppingCart = @"/atg/commerce/ShoppingCartActor/summary";
static NSString *const ATGActorChainGetCartFeaturedItems = @"/atg/commerce/ShoppingCartActor/featuredItems";
static NSString *const ATGActorChainClaimCoupon =
    @"/atg/store/order/purchase/CouponActor/claimCoupon";
static NSString *const ATGActorChainRemoveItemFromCart =
    @"/atg/commerce/order/purchase/CartModifierActor/removeItemFromOrder";
static NSString *const ATGActorChainChangeSKUOfItemInCart =
    @"/atg/commerce/order/purchase/CartModifierActor/removeAndAddItemToOrder";
static NSString *const ATGActorChainGetCartItemsCount =
    @"/atg/commerce/ShoppingCartActor/totalCommerceItemCount";
static NSString *const ATGActorChainAddItemToCart =
    @"/atg/commerce/order/purchase/CartModifierActor/addItemToOrder";
static NSString *const ATGActorChainGetShippingAddresses =
    @"/atg/commerce/order/purchase/ShippingGroupActor/getShippingAddresses";
static NSString *const ATGActorChainShipToExistingAddress =
    @"/atg/commerce/order/purchase/ShippingGroupActor/shipToExistingAddress";
static NSString *const ATGActorChainEditShippingAddress =
    @"/atg/commerce/order/purchase/ShippingGroupActor/editShippingAddress";
static NSString *const ATGActorChainShipToNewAddress =
    @"/atg/commerce/order/purchase/ShippingGroupActor/shipToNewAddress";
static NSString *const ATGActorChainGetShippingMethods =
    @"/atg/commerce/pricing/AvailableShippingMethodsActor/getAvailablePricedShippingMethods";
static NSString *const ATGActorChainSetShippingMethod =
    @"/atg/commerce/order/purchase/ShippingGroupActor/setShippingMethod";
static NSString *const ATGActorChainApplyStoreCredits =
    @"/atg/store/mobile/order/purchase/MobileBillingFormHandlerActor/applyStoreCredits";
static NSString *const ATGActorChainBillToExistingCard =
    @"/atg/store/mobile/order/purchase/MobileBillingFormHandlerActor/billToSavedCard";
static NSString *const ATGActorChainBillToExistingAddress =
    @"/atg/store/mobile/order/purchase/MobileBillingFormHandlerActor/billToSavedAddress";
static NSString *const ATGActorChainBillToNewAddress =
    @"/atg/store/mobile/order/purchase/MobileBillingFormHandlerActor/billToNewAddress";
static NSString *const ATGActorChainGetBillingAddresses =
    @"/atg/store/mobile/order/purchase/MobileBillingFormHandlerActor/billingAddresses";
static NSString *const ATGActorChainCreateBillingAddress =
    @"/atg/userprofiling/ProfileActor/createNewBillingAddress";
static NSString *const ATGActorChainGetOrderConfirmationDetails =
    @"/atg/commerce/order/purchase/ConfirmOrderActor/confirmOrder";
static NSString *const ATGActorChainPlaceOrder =
    @"/atg/commerce/order/purchase/CommitOrderActor/commitOrder";

static ATGCommerceManager *commerceManager;

@interface ATGCommerceManager ()

@end

@implementation ATGCommerceManager

@synthesize restManager = _restManager;

#pragma mark - Init and Dealloc

- (id) init {
  self = [super init];
  if (self) {
  }
  return self;
}

+ (ATGCommerceManager *) commerceManager {
  static dispatch_once_t pred_commerce_manager;
  dispatch_once(&pred_commerce_manager,
                ^{
                  commerceManager = [[ATGCommerceManager alloc] init];
                  commerceManager.shoppingCartActorChain = ATGActorChainGetShoppingCart;
                  commerceManager.addItemToCartActorChain = ATGActorChainAddItemToCart;
                  commerceManager.removeAndAddItemToCartActorChain = ATGActorChainChangeSKUOfItemInCart;
                  commerceManager.claimCouponActorChain = ATGActorChainClaimCoupon;
                  commerceManager.commitOrderActorChain = ATGActorChainPlaceOrder;
                }
                );
  return commerceManager;
}

- (ATGRestManager *) restManager {
  if (_restManager == nil) {
    _restManager = [ATGRestManager restManager];
  }
  return _restManager;
}

#pragma mark - Public Methods

- (ATGCommerceManagerRequest *)getCartFeaturedItems:(id <ATGCommerceManagerDelegate>)pDelegate {
  DebugLog(@"Fetching shopping cart featured items\n");
  SEL featuredItemsErrorSelector = @selector(didErrorGettingCartFeaturedItems:);
  ATGCommerceManagerRequest *request = [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  request.delegate = pDelegate;
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetCartFeaturedItems
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got featured items response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![request sendError:error withSelector:featuredItemsErrorSelector]) {
           NSDictionary *productsDictionary = [pResponseObject objectForKey:@"products"];
           NSMutableArray *products = [NSMutableArray arrayWithCapacity:productsDictionary.count];
           for (NSDictionary *dict in productsDictionary) {
             [products addObject:[ATGBaseProduct objectFromDictionary:dict]];
           }

           [request setRequestResults:products];
           [request sendResponse:@selector(didGetCartFeaturedItems:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while retrieving cart featured items\n");
         [request sendError:pError withSelector:featuredItemsErrorSelector];
       }];
  request.operation = operation;
  return request;
}

- (ATGCommerceManagerRequest *) getShoppingCart:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *shoppingCartRequest = [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  shoppingCartRequest.delegate = pDelegate;

  DebugLog(@"Loading Shopping Cart from server...");
  SEL cartErrorSelector = @selector(didErrorGettingShoppingCart:);
  id<ATGRestOperation> operation = [[[self restManager] restSession]
                                    executePostRequestForActorPath:self.shoppingCartActorChain
                                    parameters:nil
                                    requestFactory:nil
                                    options:ATGRestRequestOptionNone
                                    success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
                                      DebugLog(@"Got shopping cart response from server\n");
                                      NSError *error = [ATGRestManager checkForError:pResponseObject];
                                      if (![shoppingCartRequest sendError:error
                                                             withSelector:cartErrorSelector]) {
                                        ATGOrder *cart =
                                            (ATGOrder *)[ATGOrder
                                                         objectFromDictionary:[pResponseObject
                                                                               objectForKey:@"order"]];
                                        [shoppingCartRequest setRequestResults:cart];
                                        [shoppingCartRequest sendResponse:@selector(didGetShoppingCart:)];
                                        NSDictionary *userInfo =
                                            [NSDictionary
                                                dictionaryWithObject:[cart totalCommerceItemCount]
                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
                                        [[NSNotificationCenter defaultCenter]
                                            postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                                            object:self
                                            userInfo:userInfo];
                                      }
                                    }
                                    failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
                                      DebugLog(@"Server returned error while fetching shopping cart: %@\n",
                                               pError);
                                      [shoppingCartRequest sendError:pError withSelector:cartErrorSelector];
                                    }];
  shoppingCartRequest.operation = operation;

  return shoppingCartRequest;
}

- (ATGCommerceManagerRequest *)addItemToShoppingCartWithSkuId:(NSString *)pSkuId
                                                    productId:(NSString *)pProductId
                                                     quantity:(NSString *)pQuantity
                                                     delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  return [self addItemToShoppingCartWithSkuId:pSkuId productId:pProductId quantity:pQuantity shippingGroupId:nil locationId:nil delegate:pDelegate];
}

- (ATGCommerceManagerRequest *)addItemToShoppingCartWithSkuId:(NSString *)pSkuId
                                                    productId:(NSString *)pProductId
                                                     quantity:(NSString *)pQuantity
                                              shippingGroupId:(NSString *)pShippingGroupId
                                                   locationId:(NSString*)pLocationId
                                                     delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  return [self addItemToShoppingCartWithSkuId:pSkuId productId:pProductId quantity:pQuantity shippingGroupId:pShippingGroupId locationId:pLocationId delegate:pDelegate
                                      success:^(id pResponseObject, ATGCommerceManagerRequest *pRequest) {
                                        NSNumber *count = [pResponseObject objectForKey:@"totalCommerceItemCount"];
                                        [pRequest setRequestResults:count];
                                        [pRequest sendResponse:@selector(didAddItemToShoppingCart:)];
                                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:count
                                                                                             forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
                                        [[NSNotificationCenter defaultCenter]
                                          postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                                                        object:self
                                                      userInfo:userInfo];
                                      }
                                   actorChain:self.addItemToCartActorChain];
}



- (ATGCommerceManagerRequest *)addItemToShoppingCartWithSkuId:(NSString *)pSkuId
                                                    productId:(NSString *)pProductId
                                                     quantity:(NSString *)pQuantity
                                              shippingGroupId:(NSString *)pShippingGroupId
                                                   locationId:(NSString*)pLocationId
                                                     delegate:(id <ATGCommerceManagerDelegate>)pDelegate
                                                      success:(void(^)(id pResponseObject, ATGCommerceManagerRequest *request))pSuccess
                                                   actorChain:(NSString *)pActorChain
 {
  ATGCommerceManagerRequest *addItemRequest =  [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  addItemRequest.delegate = pDelegate;
  SEL addToCartErrorSelector = @selector(didErrorAddingItemToShoppingCart:);
  DebugLog(@"Adding Item to Shopping Cart...");

  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:pSkuId, @"catalogRefIds",
                                                                                      pProductId, @"productId", pQuantity, @"quantity", nil];
  if (pShippingGroupId) {
    [parameters setValue:pShippingGroupId forKey:@"shippingGroupNickname"];
  }
  if (pLocationId) {
    [parameters setValue:pLocationId forKey:@"locationId"];
  }

  id<ATGRestOperation> operation =
    [[[self restManager] restSession]
      executePostRequestForActorPath:pActorChain
                          parameters:parameters
                      requestFactory:nil
                             options:ATGRestRequestOptionNone
                             success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
                               DebugLog(@"Got item addition response from server\n");
                               NSError *error = [ATGRestManager checkForError:pResponseObject];
                               if (![addItemRequest sendError:error withSelector:addToCartErrorSelector]) {
                                 pSuccess(pResponseObject, addItemRequest);
                               }
                             }
                             failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
                               DebugLog(@"Got error from server while adding item to cart\n");
                               [addItemRequest sendError:pError withSelector:addToCartErrorSelector];
                             }];
  addItemRequest.operation = operation;

  return addItemRequest;
}





- (ATGCommerceManagerRequest *)claimCouponWithCode:(NSString *)pCouponCode
                                          delegate:(id<ATGCommerceManagerDelegate>)pDelegate {
  return [self claimCouponWithCode:pCouponCode andRenderShoppingCart:NO delegate:pDelegate];
}

- (ATGCommerceManagerRequest *)claimCouponWithCode:(NSString *)pCouponCode
                             andRenderShoppingCart:(BOOL)pRenderCart
                                          delegate:(id<ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *claimCouponRequest = [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  claimCouponRequest.delegate = pDelegate;
  SEL claimCouponError = @selector(didErrorClaimingCoupon:);
  DebugLog(@"Claiming coupon given code %@\n", pCouponCode);
  
  NSDictionary *parameters =
      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:pRenderCart], @"cart",
                                                 pCouponCode, @"couponClaimCode", pCouponCode, @"couponCode", nil];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:self.claimCouponActorChain
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Coupon claimed successfully\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![claimCouponRequest sendError:error withSelector:claimCouponError]) {
           //NSString *orderKey = pRenderCart ? @"order" : @"orderSummary";
           NSDictionary *dict = [pResponseObject objectForKey:@"order"];
           dict = (dict ? dict : [pResponseObject objectForKey:@"orderSummary"]);
           ATGOrder *cart =
              (ATGOrder *)[ATGOrder objectFromDictionary:dict];
           cart.couponCode = (cart.couponCode ? cart.couponCode : [pResponseObject valueForKey:@"couponCode"]);
           [claimCouponRequest setRequestResults:cart];
           [claimCouponRequest sendResponse:@selector(didClaimCoupon:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while claiming coupon: %@\n", pError);
         [claimCouponRequest sendError:pError withSelector:claimCouponError];
       }];

  claimCouponRequest.operation = operation;

  return claimCouponRequest;
}



- (ATGCommerceManagerRequest *)changeSkuOfOldCommerceId:(NSString *)pCommerceId
                                          withProductId:(NSString *)pProductId
                                                toSkuId:(NSString *)pUpdatedSkuId
                                           withQuantity:(NSString *)pQuantity
                                               delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  return [self changeSkuOfOldCommerceId:pCommerceId withProductId:pProductId toSkuId:pUpdatedSkuId withQuantity:pQuantity shippingGroupId:nil locationId:nil delegate:pDelegate];
}

- (ATGCommerceManagerRequest *)changeSkuOfOldCommerceId:(NSString *)pCommerceId
                                          withProductId:(NSString *)pProductId
                                                toSkuId:(NSString *)pUpdatedSkuId
                                           withQuantity:(NSString *)pQuantity
                                        shippingGroupId:(NSString *)pShippingGroupId
                                             locationId:(NSString*)pLocationId
                                               delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *changeSkuRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  changeSkuRequest.delegate = pDelegate;
  SEL changeSkuError = @selector(didErrorChangingSku:);
  DebugLog(@"Changing SKU of Commerce ID %@ ...", pCommerceId);

  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:pUpdatedSkuId, @"catalogRefIds",
                                                                        pProductId, @"productId",
                                                                        pQuantity, @"quantity",
                                                                        pCommerceId, @"removalCommerceIds",
                              nil];
  if (pShippingGroupId) {
    [parameters setObject:pShippingGroupId forKey:@"shippingGroupNickname"];
  }
  
  if (pLocationId) {
    [parameters setObject:pLocationId forKey:@"locationId"];
  }
  
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:self.removeAndAddItemToCartActorChain
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got SKU change response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![changeSkuRequest sendError:error withSelector:changeSkuError]) {
           NSNumber *itemsCount = [pResponseObject objectForKey:@"totalCommerceItemCount"];
           [changeSkuRequest setRequestResults:itemsCount];
           [changeSkuRequest sendResponse:@selector(didChangeSku:)];
           NSDictionary *userInfo = [NSDictionary dictionaryWithObject:itemsCount
                                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
           [[NSNotificationCenter defaultCenter]
                postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                object:self
                userInfo:userInfo];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error from server while changing SKU\n");
         [changeSkuRequest sendError:pError withSelector:changeSkuError];
       }];

  changeSkuRequest.operation = operation;

  return changeSkuRequest;
}

- (ATGCommerceManagerRequest *)removeItemFromCart:(NSString *)pCommerceId
                                         delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *removeItemRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  removeItemRequest.delegate = pDelegate;
  SEL removeItemErrorSel = @selector(didErrorRemovingItemFromCart:);
  DebugLog(@"Removing item with Commerce ID %@ from cart...", pCommerceId);

  NSDictionary *parameters = [NSDictionary dictionaryWithObject:pCommerceId forKey:@"removalCommerceIds"];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainRemoveItemFromCart
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got removal response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![removeItemRequest sendError:error withSelector:removeItemErrorSel]) {
           ATGOrder *cart = (ATGOrder *)[ATGOrder
                                         objectFromDictionary:[pResponseObject objectForKey:@"order"]];
           [removeItemRequest setRequestResults:cart];
           [removeItemRequest sendResponse:@selector(didRemoveItemFromCart:)];
           NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[cart totalCommerceItemCount]
                                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
           [[NSNotificationCenter defaultCenter]
                postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                object:self
                userInfo:userInfo];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error from server while removing an item\n");
         [removeItemRequest sendError:pError withSelector:removeItemErrorSel];
       }];

  removeItemRequest.operation = operation;

  return removeItemRequest;
}


- (ATGCommerceManagerRequest *)shipToExistingAddress:(NSString *)pNickname
                                            delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *shipRequest = [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  shipRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorShippingToExistingAddress:);
  DebugLog(@"Shipping to existing address with nickname %@", pNickname);

  NSDictionary *parameters =
      [NSDictionary dictionaryWithObjectsAndKeys:pNickname, @"shipToAddressName", nil];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainShipToExistingAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got ship to existing address server response\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![shipRequest sendError:error withSelector:errorSelector]) {
           [shipRequest setRequestResults:pResponseObject];
           [shipRequest sendResponse:@selector(didShipToExistingAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while shipping to existing address\n");
         [shipRequest sendError:pError withSelector:errorSelector];
       }];
  shipRequest.operation = operation;

  return shipRequest;
}


- (ATGCommerceManagerRequest *)shipToNewAddress:(ATGContactInfo *)pAddress
                               andSaveToProfile:(BOOL)pSaveAddress
                                       delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *shipRequest = [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  shipRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorShippingToNewAddress:);
  DebugLog(@"Shipping to new address %@ ...", pAddress);

  NSMutableDictionary *parameters =
      [NSMutableDictionary dictionaryWithObjectsAndKeys:[pAddress newNickname], @"newShipToAddressName",
          [NSNumber numberWithBool:pSaveAddress], @"saveShippingAddress",
          [pAddress firstName], @"firstName",
          [pAddress lastName], @"lastName",
          [pAddress phoneNumber], @"phoneNumber",
          [pAddress address1], @"address1",
          [pAddress postalCode], @"postalCode",
          [pAddress city], @"city",
          [pAddress state], @"state",
          [pAddress country], @"country", nil];
  if ([[pAddress address2] length] > 0) {
    [parameters setObject:[pAddress address2] forKey:@"address2"];
  }
  
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainShipToNewAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got ship to new address server response\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![shipRequest sendError:error withSelector:errorSelector]) {
           [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_ADDRESS_CACHE
                                                               object:self];
           [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_CACHE
                                                               object:self];
           [shipRequest setRequestResults:pResponseObject];
           [shipRequest sendResponse:@selector(didShipToNewAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while shipping to new address\n");
         [shipRequest sendError:pError withSelector:errorSelector];
       }];

  shipRequest.operation = operation;

  return shipRequest;
}


- (ATGCommerceManagerRequest *)updateShippingMethod:(NSString *)pShippingMethod
                                           delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *shipMethodUpdateRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  shipMethodUpdateRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorUpdatingShippingMethod:);
  DebugLog(@"Changing shipping method to %@ ...", pShippingMethod);

  NSDictionary *parameters = [NSDictionary dictionaryWithObject:pShippingMethod forKey:@"shippingMethod"];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainSetShippingMethod
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got update shipping method response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![shipMethodUpdateRequest sendError:error withSelector:errorSelector]) {
           [shipMethodUpdateRequest sendResponse:@selector(didUpdateShippingMethod:)];
         }
         [[NSNotificationCenter defaultCenter]
                 postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                               object:self
                             userInfo:nil];
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while updating shipping method\n");
         [shipMethodUpdateRequest sendError:pError withSelector:errorSelector];
       }];

  shipMethodUpdateRequest.operation = operation;

  return shipMethodUpdateRequest;
}


- (ATGCommerceManagerRequest *)editShippingAddress:(ATGContactInfo *)pEditedAddress
                               withCurrentNickname:(NSString *)pNickname
                                          delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *editShipAddressRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  editShipAddressRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorEditingShippingAddress:);
  DebugLog(@"Editing shipping address...");
  
  NSMutableDictionary *parameters =
      [NSMutableDictionary dictionaryWithDictionary:[pEditedAddress dictionaryFromObject]];
  [parameters setObject:pNickname forKey:@"nickname"];
  [parameters setObject:pNickname forKey:@"editShippingAddressNickName"];
  [parameters setObject:[pEditedAddress newNickname] forKey:@"shippingAddressNewNickName"];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainEditShippingAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got edit address response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![editShipAddressRequest sendError:error withSelector:errorSelector]) {
           [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_ADDRESS_CACHE
                                                               object:self];
           [editShipAddressRequest sendResponse:@selector(didEditShippingAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while editing shipping address\n");
         [editShipAddressRequest sendError:pError withSelector:errorSelector];
       }];

  editShipAddressRequest.operation = operation;

  return editShipAddressRequest;
}

- (ATGCommerceManagerRequest *)getAvailableBillingAddresses:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *getAvailableBillingAddressesRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  getAvailableBillingAddressesRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingAvailableBillingAddresses:);
  DebugLog(@"Getting available billing addresses");

  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetBillingAddresses
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got billing addresses server response\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![getAvailableBillingAddressesRequest sendError:error withSelector:errorSelector]) {
           NSArray *addresses = [ATGContactInfo objectsFromArray:[pResponseObject objectForKey:@"shippingAddresses"]];
           [getAvailableBillingAddressesRequest setRequestResults:addresses];
           [getAvailableBillingAddressesRequest sendResponse:@selector(didGetAvailableBillingAddresses:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while retrieving billing addresses\n");
         [getAvailableBillingAddressesRequest sendError:pError withSelector:errorSelector];
       }];

  getAvailableBillingAddressesRequest.operation = operation;

  return getAvailableBillingAddressesRequest;
}

- (ATGCommerceManagerRequest *)getAvailableShippingAddress:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *getAvailableShippingAddressesRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  getAvailableShippingAddressesRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingAvailableShippingAddresses:);
  DebugLog(@"Getting available shipping addresses");

  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetShippingAddresses
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got shipping addresses response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![getAvailableShippingAddressesRequest sendError:error withSelector:errorSelector]) {
           NSArray *addresses = [ATGContactInfo objectsFromArray:[pResponseObject objectForKey:@"shippingAddresses"]];
           [getAvailableShippingAddressesRequest setRequestResults:addresses];
           [getAvailableShippingAddressesRequest sendResponse:@selector(didGetAvailableShippingAddresses:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while retrieving shipping addresses\n");
         [getAvailableShippingAddressesRequest sendError:pError withSelector:errorSelector];
       }];

  getAvailableShippingAddressesRequest.operation = operation;

  return getAvailableShippingAddressesRequest;
}


- (ATGCommerceManagerRequest *)getOrderSummaryForConfirmation:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *orderSummaryRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  orderSummaryRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingOrderSummaryForConfirmation:);
  DebugLog(@"Fetching Summary of Order (before it is placed)... ");
  
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetOrderConfirmationDetails
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got order confirmation summary from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![orderSummaryRequest sendError:error withSelector:errorSelector]) {
           ATGOrder *cart = (ATGOrder *)[ATGOrder
                                         objectFromDictionary:[pResponseObject objectForKey:@"order"]];
           [cart setCouponCode:[pResponseObject objectForKey:@"couponCode"]];
           [cart setSecurityStatus:[pResponseObject objectForKey:@"securityStatus"]];
           [cart setEmail:[pResponseObject objectForKey:@"email"]];
           [orderSummaryRequest setRequestResults:cart];
           [orderSummaryRequest sendResponse:@selector(didGetOrderSummaryForConfirmation:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while retrieving order confirmation summary\n");
         [orderSummaryRequest sendError:pError withSelector:errorSelector];
       }];

  orderSummaryRequest.operation = operation;

  return orderSummaryRequest;
}


- (ATGCommerceManagerRequest *)commitOrder:(NSString *)pConfirmationEmailAddress
                                  delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *commitOrderRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  commitOrderRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorCommittingOrder:);
  DebugLog(@"Committing Order... ");
  
  NSDictionary *parameters =
      pConfirmationEmailAddress ? [NSDictionary dictionaryWithObject:pConfirmationEmailAddress
                                                              forKey:@"confirmEmailAddress"] : nil;
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:self.commitOrderActorChain
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got commit order server response\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![commitOrderRequest sendError:error withSelector:errorSelector]) {
           [commitOrderRequest setRequestResults:[pResponseObject objectForKey:@"orderId"]];
           [commitOrderRequest sendResponse:@selector(didCommitOrder:)];
           NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
           NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0]
                                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
           [center postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                                 object:self
                               userInfo:userInfo];
           [center postNotificationName:ATG_CLEAR_CACHED_ORDERS_NOTIFICATION object:self];
           [center postNotificationName:ATG_CLEAR_PROFILE_CACHE object:self];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while placing an order\n");
         [commitOrderRequest sendError:pError withSelector:errorSelector];
       }];

  commitOrderRequest.operation = operation;

  return commitOrderRequest;
}


- (ATGCommerceManagerRequest *)getAvailableShippingMethods:(NSString *)pIncludePrices
                                                  delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  ATGCommerceManagerRequest *shipMethodsRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  shipMethodsRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingAvailableShippingMethods:);
  DebugLog(@"Requesting available shipping methods...");

  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetShippingMethods
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got shipping methods response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![shipMethodsRequest sendError:error withSelector:errorSelector]) {
           [shipMethodsRequest setRequestResults:pResponseObject];
           [shipMethodsRequest sendResponse:@selector(didGetAvailableShippingMethods:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while retrieving shipping methods\n");
         [shipMethodsRequest sendError:pError withSelector:errorSelector];
       }];

  shipMethodsRequest.operation = operation;

  return shipMethodsRequest;
}

- (ATGCommerceManagerRequest *)billToSavedCard:(NSString *)pCreditCardName
                            verificationNumber:(NSString *)pNumber
                                      delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate {
  DebugLog(@"Requesting to pay with saved card");
  SEL errorSelector = @selector(didErrorBillingToSavedCard:);
  ATGCommerceManagerRequest *billingRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  billingRequest.delegate = pDelegate;

  NSDictionary *parameters = [NSDictionary
                              dictionaryWithObjectsAndKeys:pCreditCardName, @"storedCreditCardName",
                              pNumber, @"newCreditCardVerificationNumber", nil];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainBillToExistingCard
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got billing response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![billingRequest sendError:error withSelector:errorSelector]) {
           [billingRequest sendResponse:@selector(didBillToSavedCard:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while billing to existing card\n");
         [billingRequest sendError:pError withSelector:errorSelector];
       }];

  billingRequest.operation = operation;

  return billingRequest;
}

- (ATGCommerceManagerRequest *)billToNewAddressWithVerificationNumber:(NSString *)pNumber
    delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate {
  DebugLog(@"Requesting to pay with new credit card and new address");
  SEL errorSelector = @selector(didErrorBillingToSavedCard:);
  ATGCommerceManagerRequest *billingRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  billingRequest.delegate = pDelegate;

  NSDictionary *parameters = [NSDictionary dictionaryWithObject:pNumber
                                                         forKey:@"newCreditCardVerificationNumber"];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainBillToNewAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got billing response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![billingRequest sendError:error withSelector:errorSelector]) {
           NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
           [center postNotificationName:ATG_CLEAR_PROFILE_ADDRESS_CACHE object:self];
           [center postNotificationName:ATG_CLEAR_PROFILE_CACHE object:self];
           [center postNotificationName:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:self];
           [billingRequest sendResponse:@selector(didBillToNewAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while billing to new address\n");
         [billingRequest sendError:pError withSelector:errorSelector];
       }];

  billingRequest.operation = operation;

  return billingRequest;
}

- (ATGCommerceManagerRequest *)billToSavedAddress:(NSString *)pAddressName
                               verificationNumber:(NSString *)pNumber
                                         delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate {
  DebugLog(@"Requesting to pay with new credit card and saved address");
  SEL errorSelector = @selector(didErrorBillingToSavedCard:);
  ATGCommerceManagerRequest *billingRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  billingRequest.delegate = pDelegate;
  
  NSDictionary *parameters = [NSDictionary
                              dictionaryWithObjectsAndKeys:pAddressName, @"storedAddressSelection",
                              pNumber, @"newCreditCardVerificationNumber", nil];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainBillToExistingAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got billing response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![billingRequest sendError:error withSelector:errorSelector]) {
           NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
           [center postNotificationName:ATG_CLEAR_PROFILE_CACHE object:self];
           [center postNotificationName:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:self];
           [billingRequest sendResponse:@selector(didBillToSavedAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while billing to existing address\n");
         [billingRequest sendError:pError withSelector:errorSelector];
       }];

  billingRequest.operation = operation;

  return billingRequest;
}

- (ATGCommerceManagerRequest *)
    applyStoreCreditsToOrderWithDelegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate {
  DebugLog(@"Requesting to pay with new credit card and saved address");
  SEL errorSelector = @selector(didErrorAppliedStoreCreditsToOrder:);
  ATGCommerceManagerRequest *billingRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  billingRequest.delegate = pDelegate;

  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainApplyStoreCredits
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got store credits response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![billingRequest sendError:error withSelector:errorSelector]) {
           if ([[pResponseObject objectForKey:@"payedWithStoreCredits"] isKindOfClass:[NSNumber class]]) {
             [billingRequest setRequestResults:[pResponseObject objectForKey:@"payedWithStoreCredits"]];
             [billingRequest sendResponse:@selector(didAppliedStoreCreditsToOrder:)];
           } else {
             NSDictionary *rawCards = [pResponseObject objectForKey:@"creditCards"];
             NSArray *creditCards = [ATGCreditCard namedObjectsFromDictionary:rawCards
                                                              defaultObjectID:nil];
             [billingRequest setRequestResults:creditCards];
             [billingRequest sendResponse:@selector(didAppliedStoreCreditsToOrder:)];
           }
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while applying store credits\n");
         [billingRequest sendError:pError withSelector:errorSelector];
       }];

  billingRequest.operation = operation;

  return billingRequest;
}

- (ATGCommerceManagerRequest *)createBillingAddress:(ATGContactInfo *)pAddress
                                               save:(BOOL)pSaveAddr
                                           delegate:(id <ATGCommerceManagerDelegate>)pDelegate {
  DebugLog(@"Creating New Address on server.");
  ATGCommerceManagerRequest *billingRequest = [[ATGCommerceManagerRequest alloc] init];
  billingRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorCreateBillingAddress:);

  NSMutableDictionary *parameters = [NSMutableDictionary
                                     dictionaryWithObjectsAndKeys:[pAddress firstName], @"firstName",
                                     [pAddress lastName], @"lastName",
                                     [pAddress address1], @"address1",
                                     [pAddress city], @"city",
                                     [pAddress state], @"state",
                                     [pAddress country], @"country",
                                     [pAddress postalCode], @"postalCode",
                                     [pAddress phoneNumber], @"phoneNumber", nil];
  if ([[pAddress address2] length] > 0) {
    [parameters setObject:[pAddress address2] forKey:@"address2"];
  }
  [parameters setObject:[NSNumber numberWithBool:NO] forKey:@"useShippingAddressAsDefault"];
  [parameters setObject:[NSNumber numberWithBool:pSaveAddr] forKey:@"saveBillingAddress"];
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainCreateBillingAddress
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got address creation server response\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![billingRequest sendError:error withSelector:errorSelector]) {
           if (pSaveAddr) {
             [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_ADDRESS_CACHE
                                                                 object:self];
           }
           [billingRequest sendResponse:@selector(didCreateBillingAddress:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error while creating a billing address\n");
         [billingRequest sendError:pError withSelector:errorSelector];
       }];

  billingRequest.operation = operation;

  return billingRequest;
}

- (ATGCommerceManagerRequest *)getCartItemCount:(id <ATGCommerceManagerDelegate>)pDelegate {
  DebugLog(@"Fetching count of items in the cart");
  ATGCommerceManagerRequest *cartCountRequest =
      [[ATGCommerceManagerRequest alloc] initWithCommerceManager:self];
  cartCountRequest.delegate = pDelegate;
  SEL errorSelector = @selector(didErrorGettingCartItemCount:);

  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorChainGetCartItemsCount
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         DebugLog(@"Got items count response from server\n");
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![cartCountRequest sendError:error withSelector:errorSelector]) {
           NSNumber *count = [pResponseObject objectForKey:@"totalCommerceItemCount"];
           [cartCountRequest setRequestResults:count];
           [cartCountRequest sendResponse:@selector(didGetCartItemCount:)];
           NSDictionary *userInfo = [NSDictionary dictionaryWithObject:count
                                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
           [[NSNotificationCenter defaultCenter]
                postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                object:self
                userInfo:userInfo];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog(@"Got error from server while querying cart items count\n");
         [cartCountRequest sendError:pError withSelector:errorSelector];
       }];

  cartCountRequest.operation = operation;

  return cartCountRequest;
}

@end

