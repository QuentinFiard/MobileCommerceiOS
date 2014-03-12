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

#import "ATGGiftListManagerDelegate.h"

@class ATGGiftList;
@class ATGGiftItem;
@class ATGOrder;
@class ATGGiftListManagerRequest;


/*!
   @class ATGGiftListManager
   @abstract This class implements tasks to be used when querying or modifying user's gift lists.
   @discussion You obtain instance of this class by sending
   a @link //apple_ref/occ/clm/ATGGiftListManager/instance @/link message to the ATGGiftListManager class.
 */
@interface ATGGiftListManager : NSObject

/*!
   @method instance
   @abstract This method returns a singleton instance of the ATGGiftListManager.
 */
+ (ATGGiftListManager *) instance;

/*!
   @method getUserGiftListsForDelegate:
   @abstract This method queries the list of user's gift lists.
   @param delegate Delegate object to be notified about success/error of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) getUserGiftListsForDelegate:(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method getGiftListDetails:delegate:
   @abstract This method retrieves generic information for a gift list specified by its ID.
   @param giftListID ID of gift list whose parameters should be retrieved.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) getGiftList:(NSString *)giftListID delegate:(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method getGiftListItems:delegate:
   @abstract This method retrieves all gift list items for a list specified by its ID.
   @param giftListID ID of gift list whose items should be returned.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) getGiftListItems:(NSString *)giftListID
 delegate                                :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method getWishListItemsForDelegate:
   @abstract This method retrieves all wish list items.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) getWishListItemsForDelegate:(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method createGiftListWithName:type:addressId:date:publish:description:instructions:delegate
   @abstract Creates a new gift list for the current user.
   @param name Gift list name.
   @param type Gift list type. List of available types can be retrieved with
   @link //apple_ref/occ/instm/ATGGiftListManager/getGiftListTypes @/link.
   @param addressId Repository ID of address to be used by the new gift list.
   @param date Gift list's event date.
   @param publish Pass <code>YES</code> to publish this new gift list.
   @param description Gift list description.
   @param instruction Gift list special instructions.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return Request being executed.
 */
- (ATGGiftListManagerRequest *) createGiftListWithName:(NSString *)name
         type                                          :(NSString *)type
    addressId                                     :(NSString *)addressID
         date                                          :(NSDate *)date
      publish                                       :(BOOL)publish
  description                                   :(NSString *)description
 instructions                                  :(NSString *)instructions
     delegate                                      :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method removeGiftList:delegate:
   @abstract This method removes an existing gift list.
   @param giftList Gift list to be removed.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return Request being executed.
 */
- (ATGGiftListManagerRequest *) removeGiftList:(ATGGiftList *)giftList
 delegate                              :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method updateGiftList:delegate:
   @abstract Updates an existing gift list.
   @param giftList Gift list with new parameter values specified.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return Request being executed.
 */
- (ATGGiftListManagerRequest *) updateGiftList:(ATGGiftList *)giftList
 delegate                              :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method getGiftListTypesForDelegate:
   @abstract This method retrieves a list of available gift list types.
   @discussion You should use only gift list types received from this method invocation.
   All other values will result in error from server.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) getGiftListTypesForDelegate:(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method addGiftItemToCart:delegate:
   @abstract This method adds an existing gift item to user's shopping cart.
   @param giftItem Gift item to be added.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) addGiftItemToCart:(ATGGiftItem *)giftItem
 delegate                                 :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method removeGiftItem:delegate:
   @abstract This method removes a gift item from its gift list.
   @param giftItem Item to be removed.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) removeGiftItem:(ATGGiftItem *)giftItem
 delegate                              :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method removeAllItemsFromGiftList:delegate:
   @abstract This method removes all gift items from a gift list.
   @param giftList Gift list whose items should be removed.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) removeAllItemsFromGiftList:(ATGGiftList *)giftList
 delegate                                          :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method findGiftListsByFirstName:lastName:delegate:
   @abstract This method searches for gift lists published by user specified by first and last names.
   @param firstName First name of user whose gift lists should be found.
   @param lastName First name of user whose gift lists should be found.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) findGiftListsByFirstName:(NSString *)firstName
 lastName                                        :(NSString *)lastName
 delegate                                        :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method copyGiftItem:toGiftList:andRemove:
   @abstract This method copies a gift item to another gift list and then removes source item (if requested).
   @param giftItem Gift list item to be copied.
   @param giftListID ID of destination gift list.
   @param remove Specify <code>YES</code>, if gift item should be removed from source gift list.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) copyGiftItem:(ATGGiftItem *)giftItem
 toGiftList                          :(NSString *)giftListID
  andRemove                           :(BOOL)remove
   delegate                            :(id <ATGGiftListManagerDelegate>)delegate;

/*!
  @method
  @abstract Move commerce items from the shopping cart to the user's wishlist
  @param pCommerceItemIds commerce item IDs
  @param quantity quantity to move
  @param delegate
 */
- (ATGGiftListManagerRequest *)moveToWishlistFromCartCommerceItemWithId:(NSString *)pCommerceItemId
                                                                 quantity:(NSString *)pQuantity
                                                                 delegate:(id <ATGGiftListManagerDelegate>)pDelegate;
/*!
  @method
  @abstract Move a commerce item from the shopping cart to the specified giftlist
  @param pCommerceItemId commerce item ID
  @param pGiftlistId the ID of the giftlist to move the items into
  @param quantity quantity to move
  @param delegate
 */
- (ATGGiftListManagerRequest *)moveToGiftlistFromCartCommerceItemWithId:(NSString *)pCommerceItemId
                                                               giftlistId:(NSString *)pGiftlistId
                                                                 quantity:(NSString *)pQuantity
                                                                 delegate:(id <ATGGiftListManagerDelegate>)pDelegate;

/*!
   @method copyGiftItemToWishList:andRemove:delegate:
   @abstract This method copies a gift item to user's wish list and then removes source item (if requested).
   @param giftItem Gift list item to be copied.
   @param remove Specify <code>YES</code>, if gift item should be removed from source gift list.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) copyGiftItemToWishList:(ATGGiftItem *)giftItem
 andRemove                                     :(BOOL)remove
  delegate                                      :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method addProduct:sku:site:quantity:toGiftList:delegate:
   @abstract This method adds product/sku pair to the gift list.
   @param productID ID of product to be added to the gift list.
   @param skuID ID of SKU to be added to the gift list.
   @param quantity How many items add to the gift list.
   @param giftListID ID of gift list to be updated.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) addProduct:(NSString *)productID
        sku                               :(NSString *)skuID
   quantity                          :(NSString *)quantity
 toGiftList                        :(NSString *)giftListID
   delegate                          :(id <ATGGiftListManagerDelegate>)delegate;
/*!
   @method addProductToWishList:sku:site:quantity:delegate:
   @abstract This method adds product/sku pair to the wish list.
   @param productID ID of product to be added to the gift list.
   @param skuID ID of SKU to be added to the gift list.
   @param quantity How many items add to the gift list.
   @param delegate Delegate object to be notified about success/failure of the operation.
   @return ATGGiftListRequest being executed.
 */
- (ATGGiftListManagerRequest *) addProductToWishList:(NSString *)productID
      sku                                         :(NSString *)skuID
 quantity                                    :(NSString *)quantity
 delegate                                    :(id <ATGGiftListManagerDelegate>)delegate;
/*!
 @method convertWishListToGiftListWithName:type:addressId:date:publish:description:instructions:delegate
 @abstract Creates a new gift list for the current user and moves there all gift items from his wish list.
 @param name Gift list name.
 @param type Gift list type. List of available types can be retrieved with
 @link //apple_ref/occ/instm/ATGGiftListManager/getGiftListTypes @/link.
 @param addressId Repository ID of address to be used by the new gift list.
 @param date Gift list's event date.
 @param publish Pass <code>YES</code> to publish this new gift list.
 @param description Gift list description.
 @param instruction Gift list special instructions.
 @param delegate Delegate object to be notified about success/failure of the operation.
 @return Request being executed.
 */
- (ATGGiftListManagerRequest *)convertWishListToGiftListWithName:(NSString *)name
                                                     type:(NSString *)type
                                                addressId:(NSString *)addressId
                                                     date:(NSDate *)date
                                                  publish:(BOOL)publish
                                              description:(NSString *)description
                                             instructions:(NSString *)instructions
                                                 delegate:(id<ATGGiftListManagerDelegate>)delegate;
/*!
 @method clearChaces
 @abstract This method removes all cached data stored by current manager.
 */
- (void)clearCaches;

@end
