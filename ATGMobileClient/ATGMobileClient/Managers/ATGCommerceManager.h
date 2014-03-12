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
   @abstract Manager for commerce related server calls

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGCommerceManager.h#1 $$Change: 848678 $

 */

#import "ATGCommerceManagerDelegate.h"

@class ATGRestManager;
@class ATGCommerceManagerRequest;
@class ATGContactInfo;
@class ATGCreditCard;

/*!
   @const
   @abstract This notification will be send when shopping cart is changed.
 */
extern NSString *const ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION;
/*!
   @const
   @abstract Current number of shopping cart items is stored with this key inside the
   notification's userInfo.
 */
extern NSString *const ATG_SHOPPING_CART_ITEMS_NUMBER_KEY;

/*!
   @constant
   @abstract Error domain to be used when validator creates an NSError instance.
 */
static NSString * const ATGCommerceManagerErrorDomain = @"com.atg.ATGCommerceManager";

/*!
   @class
   @abstract Class responsible for fetching commerce-related items from the server, and executing
   commerce-related requests on the server via REST. These include fetching the shopping cart,
   applying a coupon, checking out, etc.
 */
@interface ATGCommerceManager : NSObject

/*!
   @property
   @abstract The REST manager
 */
@property (nonatomic, weak, readonly) ATGRestManager *restManager;

/*!
   @property
   @abstract The path of the actor chain that retrieves the shopping cart
 */
@property (nonatomic, strong) NSString *shoppingCartActorChain;

/*!
   @property
   @abstract The path of the actor chain that adds an item to the shopping cart
 */
@property (nonatomic, strong) NSString *addItemToCartActorChain;

/*!
   @property
   @abstract The path of the actor chain that removes and then adds an item to the shopping cart
 */
@property (nonatomic, strong) NSString *removeAndAddItemToCartActorChain;

/*!
   @property
   @abstract The path of the actor chain that applies a coupon to the order
 */
@property (nonatomic, strong) NSString *claimCouponActorChain;

/*!
   @property
   @abstract The path of the actor chain that commits an order
 */
@property (nonatomic, strong) NSString *commitOrderActorChain;

/*!
   @method
   @abstract Get the shared commerce manager.
 */
+ (ATGCommerceManager *) commerceManager;

/*!
   @method getCartFeaturedItems:
   @abstract Retrieves featured items from server.
   @param delegate Delegate object to be notified when success/error occured.
   @return Request being executed.
 */
- (ATGCommerceManagerRequest *) getCartFeaturedItems:(id <ATGCommerceManagerDelegate>)delegate;

/*!
   @method
   @abstract Gets the shopping cart
 */
- (ATGCommerceManagerRequest *) getShoppingCart:(id)pDelegate;

/*!
   @method
   @abstract Adds the given quantity of an item with the specified sku and product id, to the shopping cart
   @param pSkuId the SKU id of the item
   @param pProductId the id of the product
   @param pQuantity the number of such items to be added to the cart
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) addItemToShoppingCartWithSkuId:(NSString *)pSkuId productId:(NSString *)pProductId
 quantity                                                     :(NSString *)pQuantity delegate:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
 @method
 @abstract Adds the given quantity of an item with the specified sku and product id, to the shopping cart
 @param pSkuId the SKU id of the item
 @param pProductId the id of the product
 @param pQuantity the number of such items to be added to the cart
 @param pShippingGroupId the ID of the shipping group to add the item to
 @param pLocationId the location ID (e.g. the store where the product will be picked up from)
 @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *)addItemToShoppingCartWithSkuId:(NSString *)pSkuId
                                                    productId:(NSString *)pProductId
                                                     quantity:(NSString *)pQuantity
                                              shippingGroupId:(NSString *)pShippingGroupId
                                                   locationId:(NSString *)pLocationId
                                                     delegate:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
 @method
 @abstract Adds the given quantity of an item with the specified sku and product id, to the shopping cart
 @param pSkuId the SKU id of the item
 @param pProductId the id of the product
 @param pQuantity the number of such items to be added to the cart
 @param pShippingGroupId the ID of the shipping group to add the item to
 @param pLocationId the location ID (e.g. the store where the product will be picked up from)
 @param pDelegate the delegate for this request
 @param pSuccess block performed when the rest call is successful
 @param pActorChain actor chain url
 */
- (ATGCommerceManagerRequest *)addItemToShoppingCartWithSkuId:(NSString *)pSkuId
                                                    productId:(NSString *)pProductId
                                                     quantity:(NSString *)pQuantity
                                              shippingGroupId:(NSString *)pShippingGroupId
                                                   locationId:(NSString *)pLocationId
                                                     delegate:(id <ATGCommerceManagerDelegate>)pDelegate
                                                      success:(void (^)(id pResponseObject, ATGCommerceManagerRequest *request))pSuccess
                                                   actorChain:(NSString *)pActorChain;

/*!
   @method
   @abstract Claims the given coupon code
   @param pCouponCode the coupon code to claim
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) claimCouponWithCode:(NSString *)pCouponCode delegate:(id <ATGCommerceManagerDelegate>)pDelegate;
/*!
 @method claimCouponWithCode:andRenderShoppingCart:delegate:
 @abstract Claims coupon code specified.
 @param couponCode Coupon to be claimed.
 @param renderCart Pass YES to render shopping cart details in response,
 otherwise order review details will be rendered.
 @param delegate Delegate to be notified about success/error of the operation.
 @return REST request being executed.
 */
- (ATGCommerceManagerRequest *)claimCouponWithCode:(NSString *)couponCode
                             andRenderShoppingCart:(BOOL)renderCart
                                          delegate:(id<ATGCommerceManagerDelegate>)delegate;

/*!
   @method
   @abstract Removes the item with pCommerceId and adds pProductId/pUpdatedSkuId to the cart
   @param pCommerceId the old commerce item id to be updated
   @param pProductId the product Id of the item being updated
   @param pUpdatedSkuId the new sku Id to be added
   @param pQuantity the quantity of the new sku to be added
   @param pDelegate the delegate for this request
   @discussion this call allows the client to change the sku in one server call - i.e. without
   first making a call to remove the old sku and then a call to add the new sku
 */
- (ATGCommerceManagerRequest *) changeSkuOfOldCommerceId:(NSString *)pCommerceId withProductId:(NSString *)pProductId
 toSkuId                                                :(NSString *)pUpdatedSkuId withQuantity:(NSString *)pQuantity delegate:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
 @method
 @abstract Removes the item with pCommerceId and adds pProductId/pUpdatedSkuId to the cart
 @param pCommerceId the old commerce item id to be updated
 @param pProductId the product Id of the item being updated
 @param pUpdatedSkuId the new sku Id to be added
 @param pQuantity the quantity of the new sku to be added
 @param pShippingGroupId (optional) shipping group ID to add item to
 @param pLocationId (optional) location ID for in-store pickup
 @param pDelegate the delegate for this request
 @discussion this call allows the client to change the sku in one server call - i.e. without
 first making a call to remove the old sku and then a call to add the new sku
 */
- (ATGCommerceManagerRequest *)changeSkuOfOldCommerceId:(NSString *)pCommerceId
                                          withProductId:(NSString *)pProductId
                                                toSkuId:(NSString *)pUpdatedSkuId
                                           withQuantity:(NSString *)pQuantity
                                        shippingGroupId:(NSString *)pShippingGroupId
                                             locationId:(NSString*)pLocationId
                                               delegate:(id <ATGCommerceManagerDelegate>)pDelegate;
/*!
   @method
   @abstract Removes the item with pCommerceId from the cart
   @param pCommerceId the old commerce item id to be updated
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) removeItemFromCart:(NSString *)pCommerceId delegate:(id <ATGCommerceManagerDelegate>)pDelegate;


/*!
   @method
   @abstract Requests to ship to an existing address with the given nickname
   @param pNickname the the nickname of the existing address to ship to
   @param pDelegate the delegate for this request
   @discussion this call will return the available shipping methods for that address
 */
- (ATGCommerceManagerRequest *) shipToExistingAddress:(NSString *)pNickname delegate:(id <ATGCommerceManagerDelegate>)pDelegate;


/*!
   @method
   @abstract Requests to ship to a new address
   @param pAddress the new address to ship to
   @param pSaveAddress indicator of whether to save the address to the profile or not
   @param pDelegate the delegate for this request
   @discussion this call will return the available shipping methods for that address
 */
- (ATGCommerceManagerRequest *) shipToNewAddress:(ATGContactInfo *)pAddress andSaveToProfile:(BOOL)pSaveAddress delegate:(id <ATGCommerceManagerDelegate>)pDelegate;


/*!
   @method
   @abstract Requests to change the shipping method to the given shipping method
   @param pShippingMethod the new shipping method to be used
   @param pDelegate the delegate for this request
   @discussion this call will just return an empty form handler response
 */
- (ATGCommerceManagerRequest *) updateShippingMethod:(NSString *)pShippingMethod delegate:(id <ATGCommerceManagerDelegate>)pDelegate;


/*!
   @method
   @abstract Requests to edit the shipping address with the given nickname to have the values in the given
   @link ATGContactInfo @/link.  If a new nickname is given in the incoming @link ATGContactInfo @/link
   then the nickname of the address will be changed to its value.
   @param pEditedAddress an @link ATGContactInfo @/link containing the values that the edited address should have
   @param pNickname the nickname of the address to be edited
   @param pDelegate the delegate for this request
   @discussion this call will just return an empty form handler response
 */
- (ATGCommerceManagerRequest *) editShippingAddress:(ATGContactInfo *)pEditedAddress withCurrentNickname:(NSString *)pNickname
 delegate                                          :(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Requests the avilable shipping addresses
   @param pDelegate the delegate for this request
   @discussion this call will return a list of @link ATGContactInfo @/link objects
 */
- (ATGCommerceManagerRequest *) getAvailableShippingAddress:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Requests the avilable billing addresses
   @param pDelegate the delegate for this request
   @discussion this call will return a list of @link ATGContactInfo @/link objects
 */
- (ATGCommerceManagerRequest *) getAvailableBillingAddresses:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Requests to commit the current order, i.e. check out
   @param pConfirmationEmailAddress the email address of an anonymous user that wants an email confirmation of their order
   @param pDelegate the delegate for this request
   @discussion this call will return the order id of the committed order
 */
- (ATGCommerceManagerRequest *) commitOrder:(NSString *)pConfirmationEmailAddress delegate:(id <ATGCommerceManagerDelegate>)pDelegate;


/*!
   @method
   @abstract Requests to fetch all of the data that we need to display the order confirmation
   page to the user, before he/she places the order.  This information includes the shopping cart,
   billing address, shipping address, shipping method, payment method, etc.
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) getOrderSummaryForConfirmation:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Requests to fetch all of the available shipping methods for the current cart
   @param pIncludePrices is a "true" or "false" indicator of whether or not we want the prices for those shipping methods
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) getAvailableShippingMethods:(NSString *)pIncludePrices delegate:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Create new billing address for credit card
   @param pAddress billing address object
   @param pSaveAddr save address to profile
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) createBillingAddress:(ATGContactInfo *)pAddress save:(BOOL)pSaveAddr delegate:(id <ATGCommerceManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Bills to a saved card
   @param pCreditCardName name of the credit card to bill to
   @param pNumber credit card CSV code
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) billToSavedCard:(NSString *)pCreditCardName verificationNumber:(NSString *)pNumber delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate;


/*!
   @method
   @abstract Bill to a new card with new billing address
   @param pNumber credit card CSV code
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) billToNewAddressWithVerificationNumber:(NSString *)pNumber delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate;

/*!
   @method
   @abstract Bill to new credit card with existing billing address
   @param pAddressName nickname of address to bill to
   @param pNumber credit card CSV code
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) billToSavedAddress:(NSString *)pAddressName verificationNumber:(NSString *)pNumber delegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Pre-verify order before verify csv code
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) applyStoreCreditsToOrderWithDelegate:(NSObject <ATGCommerceManagerDelegate> *)pDelegate;

/*!
   @method
   @abstract Requests the total number of commerce items in the cart
   @param pDelegate the delegate for this request
 */
- (ATGCommerceManagerRequest *) getCartItemCount:(id <ATGCommerceManagerDelegate>)pDelegate;

@end //end ATGCommerceManager
