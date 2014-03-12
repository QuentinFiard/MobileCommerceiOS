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
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGGiftListManagerDelegate.h#1 $$Change: 848678 $
 
 */
#import "ATGLoginDelegate.h"
#import "ATGGiftList.h"
/*!
 @protocol ATGGiftListManagerDelegate
 @abstract Conform to this protocol if you want to receive messages from ATGGiftListManager object.
 @discussion All ATGGiftListManager methods querying or modifying user's gift lists require a delegate object
 to be passed. This object will receive messages about manager's successful or failed requests.
 */
@protocol ATGGiftListManagerDelegate <ATGLoginDelegate>

@required

/*!
 @method giftListManagerDidFailWithError:
 @abstract This method is called if gift list manager was unable to perform its previous task.
 @param error Error which prevented the manager from executing the task successfully.
 */
- (void) giftListManagerDidFailWithError:(NSError *)error;

@optional

/*!
 @method giftListManagerDidGetUserLists:
 @abstract This method is called if the gift list manager successfully retrieved list of user's gift lists.
 @param giftLists Dictionary containing user's gift lists names and repository IDs. Keys of this dictionary
 are gift lists IDs, values are gift lists names.
 */
- (void) giftListManagerDidGetUserLists:(NSDictionary *)giftLists;
/*!
 @method giftListManagerDidGetGiftItems:forGiftList:
 @abstract This method is called if the gift list manager successfully retrieved items for a gift list.
 @param items Array of ATGGiftItem instances, represents gift list items.
 @param giftListID ID of a gift list whose items are returned.
 */
- (void) giftListManagerDidGetGiftItems:(NSArray *)items forGiftList:(NSString *)giftListID;
/*!
 @method giftListManagerDidGetWishListItems:
 @abstract This method is called if the gift list manager successfully retrieved items for a wish list.
 @param items Array of ATGGiftItem instances, representing wish list items.
 */
- (void) giftListManagerDidGetWishListItems:(NSArray *)items;
/*!
 @method giftListManagerDidCreateGiftList:
 @abstract This method is called if the gift list manager successfully created a gift list.
 @param giftList A newly created gift list.
 */
- (void) giftListManagerDidCreateGiftList:(ATGGiftList *)giftList;
/*!
 @method giftListManagerDidRemoveGiftList:
 @abstract This method is called after the gift list manager successfully removed a gift list.
 @param giftListID ID of the removed gift list.
 */
- (void) giftListManagerDidRemoveGiftList:(NSString *)giftListID;
/*!
 @method giftListManagerDidUpdateGiftList:
 @abstract This method is called after the gift list manager successfully updated a gift list.
 @param giftList Gift list instance populated with new property values.
 */
- (void) giftListManagerDidUpdateGiftList:(ATGGiftList *)giftList;
/*!
 @method giftListManagerDidGetGiftList:
 @abstract This method is called after the gift list manager successfully retrieved gift list.
 @param giftList Gift list instance populated with all required property values.
 */
- (void) giftListManagerDidGetGiftList:(ATGGiftList *)giftList;
/*!
 @method giftListManagerDidGetGiftListTypes:
 @abstract This method is called after the gift list manager successfully retrieved available gift list types.
 @param types Array of ATGGiftListType instances, each representing an available gift list type.
 */
- (void) giftListManagerDidGetGiftListTypes:(NSArray *)types;
/*!
 @method giftListManagerDidAddGiftItemToCart:
 @abstract This method is called after the gift manager successfully added a gift item to the cart.
 @param giftItem Item which has been added to the cart.
 */
- (void) giftListManagerDidAddGiftItemToCart:(ATGGiftItem *)giftItem;
/*!
 @method giftListManagerDidRemoveItemFromGiftList:
 @abstract This method is called after the gift manager successfully removed a gift item from the list.
 @param giftList Updated gift list without an item removed.
 */
- (void) giftListManagerDidRemoveItemFromGiftList:(ATGGiftList *)giftList;
/*!
 @method giftListManagerDidRemoveAllItemsFromGiftList:
 @abstract This method is called after the gift manager successfully removed all gift items from the list.
 @param giftList Update gift list with empty gift items list.
 */
- (void) giftListManagerDidRemoveAllItemsFromGiftList:(ATGGiftList *)giftList;
/*!
 @method giftListManagerDidFindGiftLists:
 @abstract This method is called after the gift manager successfully returned from search.
 @param giftLists Array of <code>ATGGiftList</code> instances, each representing a published gift list.
 */
- (void) giftListManagerDidFindGiftLists:(NSArray *)giftLists;
/*!
 @method giftListManagerDidCopyItemToGiftList:
 @abstract This method is called after the gift manager successfully moved/copied gift item to another list.
 @param giftListID ID of destination gift list.
 */
- (void) giftListManagerDidCopyItemToGiftList:(NSString *)giftListID;
/*!
 @method giftListManagerDidCopyItemToWishList
 @abstract This method is called after the gift manager successfully moved/copied gift item to user wish list.
 */
- (void) giftListManagerDidCopyItemToWishList;
/*!
 @method giftListManagerDidAddItemToGiftList:
 @abstract This method is called after the gift manager successfully added an item to the gift list.
 @param giftListID ID of updated gift list.
 */
- (void) giftListManagerDidAddItemToGiftList:(NSString *)giftListID;
/*!
 @method giftListManagerDidAddItemToWishList
 @abstract This method is called after the gift manager successfully added an item to user's wish list.
 */
- (void) giftListManagerDidAddItemToWishList;
/*!
 @method giftListManagerDidConvertWishListToGiftList:
 @abstract This method is called after the gift manager successfully converted wish list to gift list.
 @param giftList Newly created gift list.
 */
- (void)giftListManagerDidConvertWishListToGiftList:(ATGGiftList *)giftList;

- (void)giftListManagerDidMoveItemToWishList;
- (void)giftListManagerDidMoveItemToGiftList;

@end