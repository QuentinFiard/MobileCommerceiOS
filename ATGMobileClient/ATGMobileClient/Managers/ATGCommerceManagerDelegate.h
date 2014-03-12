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
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGCommerceManagerDelegate.h#1 $$Change: 848678 $
 
 */

@class ATGCommerceManagerRequest;

/*!
 @protocol
 @abstract Callback methods for @link ATGCommerceManager @/link
 */
@protocol ATGCommerceManagerDelegate <NSObject>
@optional

/*!
 @method didGetCartFeaturedItems:
 @abstract This method is called when featured items recieved from server.
 @param request Request being executed.
 */
- (void) didGetCartFeaturedItems:(ATGCommerceManagerRequest *)request;
/*!
 @method didErrorGettingCartFeaturedItems:
 @abstract This method is called when some error occured.
 @param request Request being executed.
 */
- (void) didErrorGettingCartFeaturedItems:(ATGCommerceManagerRequest *)request;

/*!
 @method
 @abstract Delegate callback when the shopping cart is fetched
 @discussion The shopping cart returned will always come from the server - the cart is not cached
 */
- (void) didGetShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback if there is an error getting the shopping cart
 */
- (void) didErrorGettingShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when an item is added to the shopping cart
 */
- (void) didAddItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback if there is an error adding an item to the shopping cart
 */
- (void) didErrorAddingItemToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when a coupon code has been claimed
 */
- (void) didClaimCoupon:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error when claiming a coupon
 */
- (void) didErrorClaimingCoupon:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when a sku has been changed
 */
- (void) didChangeSku:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error changing a sku
 */
- (void) didErrorChangingSku:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when an item has been removed from the cart
 */
- (void) didRemoveItemFromCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error removing an item from the cart
 */
- (void) didErrorRemovingItemFromCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have set the shipping address to an existing address
 */
- (void) didShipToExistingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error setting the shipping address to an existing address
 */
- (void) didErrorShippingToExistingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have set the shipping address to a new address
 */
- (void) didShipToNewAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error setting the shipping address to a new address
 */
- (void) didErrorShippingToNewAddress:(ATGCommerceManagerRequest *)pRequest;

@optional
/*!
 @method
 @abstract Delegate callback when we have updated the shipping method
 */
- (void) didUpdateShippingMethod:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error updating the shipping method
 */
- (void) didErrorUpdatingShippingMethod:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have edited the shipping address
 */
- (void) didEditShippingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error editing the shipping address
 */
- (void) didErrorEditingShippingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have getting available shipping addresses
 */
- (void) didGetAvailableShippingAddresses:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error getting available shipping addresses
 */
- (void) didErrorGettingAvailableShippingAddresses:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have getting available billing addresses
 */
- (void) didGetAvailableBillingAddresses:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error getting available billing addresses
 */
- (void) didErrorGettingAvailableBillingAddresses:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have committed an order
 */
- (void) didCommitOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error committing an order
 */
- (void) didErrorCommittingOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have gotten the order summary information
 */
- (void) didGetOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error getting the order summary information
 */
- (void) didErrorGettingOrderSummaryForConfirmation:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when we have gotten the available shipping methods
 */
- (void) didGetAvailableShippingMethods:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error getting the available shipping methods
 */
- (void) didErrorGettingAvailableShippingMethods:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback for selecting a saved credit card
 */
- (void) didBillToSavedCard:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error selecting a saved credit card
 */
- (void) didErrorBillingToSavedCard:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback for entering new card
 */
- (void) didBillToNewCard:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error entering a new card
 */
- (void) didErrorBillingToNewCard:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback for clearing all payments
 */
- (void) didClearPayments:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error clearing all payments
 */
- (void) didErrorClearingPayments:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback for entering new billing address
 */
- (void) didBillToNewAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error entering a new billing address
 */
- (void) didErrorBillingToNewAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when entering a new card with saved address
 */
- (void) didBillToSavedAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error committing an order
 */
- (void) didErrorBillingToSavedAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when new billing address created
 */
- (void) didCreateBillingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error creating billing address
 */
- (void) didErrorCreateBillingAddress:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when the count of items in the cart has been retreived
 */
- (void) didGetCartItemCount:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error getting the count of items in the cart
 */
- (void) didErrorGettingCartItemCount:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when store credits were applied to an order
 */
- (void) didAppliedStoreCreditsToOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there was an error applying store credit to the order
 */
- (void) didErrorAppliedStoreCreditsToOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when an order is confirmed
 */
- (void) didConfirmOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there is an error confirming an order
 */
- (void) didErrorConfirmingOrder:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when multiple items have been added to the cart
 */
- (void) didAddMultipleItemsToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there was an error adding multiple items to the cart
 */
- (void) didErrorAddingMultipleItemsToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when an incomplete order is merged into the cart and then deleted
 */
- (void) didMergeOrderToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

/*!
 @method
 @abstract Delegate callback when there was an error merging an order to the cart
 */
- (void) didErrorMergingOrderToShoppingCart:(ATGCommerceManagerRequest *)pRequest;

@end //end ATGCommerceManagerDelegate
