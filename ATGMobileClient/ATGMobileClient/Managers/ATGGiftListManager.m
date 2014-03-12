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

#import "ATGGiftListManager.h"
#import "ATGProfileManager.h"
#import <ATGMobileCommon/ATGMemoryCache.h>
#import <ATGMobileCommon/ATGRepositoryCoreDataCache.h>
#import "ATGGiftList+Additions.h"
#import "ATGGiftItem.h"
#import "ATGGiftListManagerRequest.h"

extern NSString *const ATG_SHOPPING_CART_ITEMS_NUMBER_KEY;
extern NSString *const ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION;

static const NSTimeInterval ATGGiftListCacheTimeoutSec = 30 * 60;

static NSString *const ATGGiftListCacheName = @"ATGGiftListCache";
static NSString *const ATGUserGiftListsItemName = @"ATGUserGiftLists";
static NSString *const ATGGiftListTypesItemName = @"ATGGiftListTypes";

static NSString *const ATGActorGetUserGiftLists =
    @"/atg/commerce/gifts/GiftlistActor/profileGiftlists";
static NSString *const ATGActorGetGiftListItems =
    @"/atg/commerce/gifts/GiftlistLookupActor/items";
static NSString *const ATGActorGetWishListItems =
    @"/atg/commerce/gifts/GiftlistLookupActor/viewWishlist";
static NSString *const ATGActorCreateGiftList =
    @"/atg/commerce/gifts/GiftlistActor/createGiftlist";
static NSString *const ATGActorDeleteGiftList =
    @"/atg/commerce/gifts/GiftlistActor/removeGiftlist";
static NSString *const ATGActorUpdateGiftList =
    @"/atg/commerce/gifts/GiftlistActor/updateGiftlist";
static NSString *const ATGActorGetGiftList =
    @"/atg/commerce/gifts/GiftlistLookupActor/info";
static NSString *const ATGActorGetGiftListTypes =
    @"/atg/commerce/gifts/GiftlistActor/giftlistTypes";
static NSString *const ATGActorAddGiftItemToCart =
    @"/atg/commerce/order/purchase/CartModifierActor/addItemToOrder";
static NSString *const ATGActorDeleteGiftItem =
    @"/atg/commerce/gifts/GiftlistActor/removeItemFromGiftlist";
static NSString *const ATGActorDeleteAllGiftItems =
    @"/atg/commerce/gifts/GiftlistActor/removeAllItems";
static NSString *const ATGActorFindGiftLists =
    @"/atg/commerce/gifts/GiftlistSearchActor/search";
static NSString *const ATGActorCopyGiftItemToGiftList =
    @"/atg/commerce/gifts/GiftlistActor/copyToGiftlist";
static NSString *const ATGActorMoveGiftItemToGiftList =
    @"/atg/commerce/gifts/GiftlistActor/moveToGiftlist";
static NSString *const ATGActorCopyGiftItemToWishList =
    @"/atg/commerce/gifts/GiftlistActor/copyToWishlist";
static NSString *const ATGActorMoveGiftItemToWishList =
    @"/atg/commerce/gifts/GiftlistActor/moveToWishlist";
static NSString *const ATGActorMoveCartItemToGiftList =
    @"/atg/commerce/gifts/GiftlistActor/moveItemsFromCart";
static NSString *const ATGActorMoveCartItemToWishList =
    @"/atg/commerce/gifts/GiftlistActor/moveItemsFromCartToWishlist";
static NSString *const ATGActorAddProductToGiftList =
    @"/atg/commerce/gifts/GiftlistActor/addItemToGiftlist";
static NSString *const ATGActorAddProductToWishList =
    @"/atg/commerce/gifts/GiftlistActor/addItemToWishlist";
static NSString *const ATGActorConvertWishList =
    @"/atg/commerce/gifts/GiftlistActor/convertWishlist";

static NSString *const ATGWishListPseudoRepositoryID = @"WISHLIST";

static NSString *const ATGGiftListErrorDomain = @"ATGGiftListErrorDomain";

static ATGGiftListManager *managerInstance;

#pragma mark - ATGGiftList+ATGGiftListManager Category Definition
#pragma mark -

@interface ATGGiftList (ATGGiftListManager) <NSCopying>

@end

#pragma mark - ATGGiftListManager Private Protocol
#pragma mark -

@interface ATGGiftListManager ()

#pragma mark - Cache Properties

@property (nonatomic, readwrite, strong) ATGMemoryCache *memoryCache;
@property (nonatomic, readwrite, strong) ATGRepositoryCoreDataCache *coreDataCache;

#pragma mark - Private Protocol Definition

// This method will actually retrieve gift list items for the gift list specified.
// You may pass a WISHLIST pseudo ID to get gift items of a wish list.
- (ATGGiftListManagerRequest *)internalGetGiftListItems:(NSString *)giftListID
                                        delegate:(id <ATGGiftListManagerDelegate>)delegate
                                         success:(void (^)(NSArray *))successBlock;
// This method retrieves a REST session from the ATGRestManager.
- (ATGRestSession *)restSession;

@end

#pragma mark - ATGGiftListManager Implementation
#pragma mark -

@implementation ATGGiftListManager

#pragma mark - Synthesized Properties

@synthesize memoryCache;
@synthesize coreDataCache;

#pragma mark - Singleton Instance

+ (ATGGiftListManager *)instance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
                  managerInstance = [[ATGGiftListManager alloc] init];
                }
                );
  return managerInstance;
}

#pragma mark - NSObject

- (id)init {
  self = [super init];
  if (self) {
    [self setMemoryCache:[[ATGMemoryCache alloc] initWithCacheName:ATGGiftListCacheName
                                                         sizeLimit:0
                                                        expiryTime:ATGGiftListCacheTimeoutSec]];
    [self setCoreDataCache:[[ATGRepositoryCoreDataCache alloc]
                            initWithEntityDescriptionName:[ATGGiftList entityDescriptorName]
                                               expiryTime:ATGGiftListCacheTimeoutSec]];
  }
  return self;
}

#pragma mark - Public Protocol Implementation

- (void)clearCaches {
  [[self memoryCache] clearCache];
  [[self coreDataCache] clearCache];
}

- (ATGGiftListManagerRequest *)getUserGiftListsForDelegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  // First query the cache to check, if we've retrieved user's gift lists already.
  NSDictionary *userLists = [[self memoryCache] getItemFromCacheWithID:ATGUserGiftListsItemName];
  if (userLists) {
    // There is something in the cache, use this value.
    // Perform the task on main queue, this will always happen on the main thread.
    if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetUserLists:)]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [pDelegate giftListManagerDidGetUserLists:userLists];
      });
    }
  } else {
    // Nothing in the cache, query the server for the result.
    id<ATGRestOperation> operation =
        [[self restSession]
         executePostRequestForActorPath:ATGActorGetUserGiftLists
         parameters:nil
         requestFactory:nil
         options:ATGRestRequestOptionNone
         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
           // First, check if server has returned some sort of error.
           if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
             // No errors got from server, parse its response.
             NSMutableDictionary *userLists = [[NSMutableDictionary alloc] init];
             for (NSDictionary *giftListEntry in [pResponseObject objectForKey:@"giftlists"]) {
               NSString *listId = [giftListEntry objectForKey:@"repositoryId"];
               NSString *name = [giftListEntry objectForKey:@"name"];
               [userLists setObject:name forKey:listId];
             }
             NSDictionary *result = [userLists copy];
             // Update inner cache for future use.
             [[self memoryCache] insertItemIntoCache:result withID:ATGUserGiftListsItemName];
             // And perform delegate's method on main thread.
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetUserLists:)]) {
               dispatch_async(dispatch_get_main_queue(), ^{
                 [pDelegate giftListManagerDidGetUserLists:result];
               });
             }
           }
         }
         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
           [request sendError:pError];
         }];
    [request setOperation:operation];
  }
  return request;
}

- (ATGGiftListManagerRequest *)getGiftListItems:(NSString *)pGiftListID
                                delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  return [self internalGetGiftListItems:pGiftListID delegate:pDelegate success:^(NSArray * pItems) {
            if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetGiftItems:forGiftList:)]) {
              [pDelegate giftListManagerDidGetGiftItems:pItems forGiftList:pGiftListID];
            }
          }];
}

- (ATGGiftListManagerRequest *)getWishListItemsForDelegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  return [self internalGetGiftListItems:ATGWishListPseudoRepositoryID delegate:pDelegate success:^(NSArray * pItems) {
            if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetWishListItems:)]) {
              [pDelegate giftListManagerDidGetWishListItems:pItems];
            }
          }];
}

- (ATGGiftListManagerRequest *)createGiftListWithName:(NSString *)pName
                                          type:(NSString *)pType
                                     addressId:(NSString *)pAddressID
                                          date:(NSDate *)pDate
                                       publish:(BOOL)pPublish
                                   description:(NSString *)pDescription
                                  instructions:(NSString *)pInstructions
                                      delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  // REST doesn't support dates when executing form handler's method.
  // So we have to split input date into date/month/year.
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComponents =
    [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:pDate];
  NSDictionary *parameters = @{@"isPublished": @(pPublish),
                               @"eventName": pName,
                               @"year": @([dateComponents year]),
                               @"month": @([dateComponents month] - 1),
                               @"date": @([dateComponents day]),
                               @"eventType": pType,
                               @"description": pDescription,
                               @"shippingAddressId": pAddressID,
                               @"instructions": pInstructions};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorCreateGiftList
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           // Successfully created a gift list. Get its ID from form handler,
           // we're going to update existing user lists cache.
           NSString *listId = [pResponseObject objectForKey:@"giftlistId"];
           //TODO: check listId != nil
           NSDictionary *userLists = [[self memoryCache]
                                      getItemFromCacheWithID:ATGUserGiftListsItemName];
           if (userLists && listId) {
             // There are user lists loaded already, update cached user lists with a new list.
             // Otherwise no updates needed, as all user lists will be retrieved from server.
             userLists = [userLists mutableCopy];
             [(NSMutableDictionary *)userLists setObject:pName forKey:listId];
             [[self memoryCache] insertItemIntoCache:[userLists copy]
                                              withID:ATGUserGiftListsItemName];
           }
           // Now we're ready to cache the gift list itself.
           // Create an object from empty dictionary, this will insert the object into
           // managed context.
           ATGGiftList *giftList = (ATGGiftList *)[ATGGiftList objectFromDictionary:nil];
           [giftList setRepositoryId:listId];
           [giftList setGiftlistId:listId];
           [giftList setName:pName];
           [giftList setType:pType];
           [giftList setAddressId:pAddressID];
           [giftList setAddressName:[pResponseObject objectForKey:@"addressName"]];
           [giftList setFirstName:[pResponseObject objectForKey:@"firstName"]];
           [giftList setLastName:[pResponseObject objectForKey:@"lastName"]];
           [giftList setDate:pDate];
           [giftList setPublicFlag:pPublish];
           [giftList setGiftListDescription:pDescription];
           [giftList setInstructions:pInstructions];
           [[self coreDataCache] insertItemIntoCache:giftList withID:listId];
           // And now everything is ready to notify the delegate.
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidCreateGiftList:)]) {
               // Return gift list clone to prevent it from being modified.
               [pDelegate giftListManagerDidCreateGiftList:[giftList copy]];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];
  return request;
}

- (ATGGiftListManagerRequest *)removeGiftList:(ATGGiftList *)pGiftList
                              delegate:(id <ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorDeleteGiftList
       parameters:@{@"giftlistId": [pGiftList giftlistId]}
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           // Successfully removed gift list from server, remove it from our caches too.
           NSString *listId = [pGiftList repositoryId];
           [[self coreDataCache] removeItemFromCacheWithID:listId];
           NSDictionary *userLists = [[self memoryCache]
                                      getItemFromCacheWithID:ATGUserGiftListsItemName];
           if (userLists) {
             // There are user lists loaded already, update cached user lists with a new list.
             // Otherwise no updates needed, as all user lists will be retrieved from server.
             userLists = [userLists mutableCopy];
             [(NSMutableDictionary *)userLists removeObjectForKey:listId];
             [[self memoryCache] insertItemIntoCache:[userLists copy]
                                              withID:ATGUserGiftListsItemName];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidRemoveGiftList:)]) {
               [pDelegate giftListManagerDidRemoveGiftList:listId];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];
  return request;
}

- (ATGGiftListManagerRequest *)updateGiftList:(ATGGiftList *)pGiftList
                              delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  // REST doesn't support dates when executing form handler's method.
  // So we have to split input date into date/month/year.
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComponents =
    [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                fromDate:[pGiftList date]];
  NSDictionary *parameters = @{@"giftlistId": [pGiftList giftlistId],
                               @"isPublished": @([pGiftList isPublic]),
                               @"eventName": [pGiftList name],
                               @"year": @([dateComponents year]),
                               @"month": @([dateComponents month] - 1),
                               @"date": @([dateComponents day]),
                               @"eventType": [pGiftList type],
                               @"description": [pGiftList giftListDescription],
                               @"shippingAddressId": [pGiftList addressId],
                               @"instructions": [pGiftList instructions]};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorUpdateGiftList
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           // Successfully updated gift list on server, update local caches as well.
           NSDictionary *userLists = [[self memoryCache]
                                      getItemFromCacheWithID:ATGUserGiftListsItemName];
           if (userLists) {
             // There are user lists loaded already, update cached user lists with a new list.
             // Otherwise no updates needed, as all user lists will be retrieved from server.
             userLists = [userLists mutableCopy];
             [(NSMutableDictionary *)userLists setObject:[pGiftList name] forKey:[pGiftList giftlistId]];
             [[self memoryCache] insertItemIntoCache:[userLists copy]
                                              withID:ATGUserGiftListsItemName];
           }
           ATGGiftList *giftList = [[self coreDataCache] getItemFromCacheWithID:[pGiftList repositoryId]];
           if (giftList) {
             [giftList setPublicFlag:[pGiftList isPublic]];
             [giftList setName:[pGiftList name]];
             [giftList setDate:[pGiftList date]];
             [giftList setType:[pGiftList type]];
             [giftList setGiftListDescription:[pGiftList giftListDescription]];
             [giftList setAddressId:[pGiftList addressId]];
             [giftList setAddressName:[pGiftList addressName]];
             [giftList setInstructions:[pGiftList instructions]];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidUpdateGiftList:)]) {
               [pDelegate giftListManagerDidUpdateGiftList:pGiftList];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];
  return request;
}

- (ATGGiftListManagerRequest *)getGiftList:(NSString *)pGiftListID
                           delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  ATGGiftList *giftList = [[self coreDataCache] getItemFromCacheWithID:pGiftListID];
  if ([[giftList name] length] > 0) {
    // There is a gift list name specified, hence gift list properties are populated already.
    // Nothing to do here, just notify the delegate.
    dispatch_async(dispatch_get_main_queue(), ^{
                     if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetGiftList:)]) {
                       [pDelegate giftListManagerDidGetGiftList:giftList];
                     }
                   });
  } else {
    // Populate gift list properties with data received from server.
    id <ATGRestOperation> operation =
        [[self restSession]
         executePostRequestForActorPath:ATGActorGetGiftList
         parameters:@{@"giftlistId": pGiftListID}
         requestFactory:nil
         options:ATGRestRequestOptionNone
         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
           if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
             ATGGiftList *list = giftList;
             if (list) {
               // There is a gift list instance got from cache, then we have to update it.
               [list applyPropertiesFromDictionary:[pResponseObject objectForKey:@"giftlist"]];
             } else {
               // Otherwise create a new gift list instance.
               list = (ATGGiftList *)[ATGGiftList
                                      objectFromDictionary:[pResponseObject objectForKey:@"giftlist"]];
               [[self coreDataCache] insertItemIntoCache:list withID:[list repositoryId]];
             }
             [list setGiftlistId:[list repositoryId]];
             dispatch_async(dispatch_get_main_queue(), ^{
               if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetGiftList:)]) {
                 [pDelegate giftListManagerDidGetGiftList:[list copy]];
               }
             });
           }
         }
         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
           [request sendError:pError];
         }];
    [request setOperation:operation];
  }
  return request;
}

- (ATGGiftListManagerRequest *)getGiftListTypesForDelegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  NSArray *types = [[self memoryCache] getItemFromCacheWithID:ATGGiftListTypesItemName];
  if (types) {
    // Types already retrieved, just use them.
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetGiftListTypes:)]) {
        [pDelegate giftListManagerDidGetGiftListTypes:types];
      }
    });
  } else {
    id<ATGRestOperation> operation =
        [[self restSession]
         executePostRequestForActorPath:ATGActorGetGiftListTypes
         parameters:nil
         requestFactory:nil
         options:ATGRestRequestOptionNone
         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
           if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
             NSArray *result = [ATGGiftListType objectsFromArray:[pResponseObject objectForKey:@"giftlistTypes"]];
             [[self memoryCache] insertItemIntoCache:result withID:ATGGiftListTypesItemName];
             dispatch_async(dispatch_get_main_queue(), ^{
               if ([pDelegate respondsToSelector:@selector(giftListManagerDidGetGiftListTypes:)]) {
                 [pDelegate giftListManagerDidGetGiftListTypes:result];
               }
             });
           }
         }
         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
           [request sendError:pError];
         }];
    [request setOperation:operation];
  }
  return request;
}

- (ATGGiftListManagerRequest *)addGiftItemToCart:(ATGGiftItem *)pGiftItem
                                 delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"giftlistId": [[pGiftItem giftList] giftlistId],
                               @"giftlistItemId": [pGiftItem repositoryId],
                               @"productId": [pGiftItem productId],
                               @"siteId": [pGiftItem siteId],
                               @"catalogRefIds": [pGiftItem skuId],
                               @"quantity": [pGiftItem quantity]};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorAddGiftItemToCart
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           NSNumber *count = [pResponseObject objectForKey:@"totalCommerceItemCount"];
           NSDictionary *userInfo = [NSDictionary dictionaryWithObject:count
                                                                forKey:ATG_SHOPPING_CART_ITEMS_NUMBER_KEY];
           [[NSNotificationCenter defaultCenter]
              postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
              object:self
              userInfo:userInfo];
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidAddGiftItemToCart:)]) {
               [pDelegate giftListManagerDidAddGiftItemToCart:pGiftItem];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)removeGiftItem:(ATGGiftItem *)pGiftItem
                              delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"giftlistId": [[pGiftItem giftList] giftlistId],
                               @"giftItemId": [pGiftItem repositoryId]};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorDeleteGiftItem
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           ATGGiftList *list = [pGiftItem giftList];
           // Gift item has been successfully removed from the list, now
           // update local cache object to reflect this change.
           [list removeItemsObject:pGiftItem];
           if ([pDelegate respondsToSelector:@selector(giftListManagerDidRemoveItemFromGiftList:)]) {
             dispatch_async(dispatch_get_main_queue(), ^{
               [pDelegate giftListManagerDidRemoveItemFromGiftList:list];
             });
           }
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)removeAllItemsFromGiftList:(ATGGiftList *)pGiftList
                                          delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorDeleteAllGiftItems
       parameters:@{@"giftlistId": [pGiftList giftlistId]}
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           // All gift items successfully removed from the list, now we have
           // to update local copy to reflect its new state.
           // Always update gift list item got from cache, do not update user's working copy!
           ATGGiftList *list = [[self coreDataCache] getItemFromCacheWithID:[pGiftList repositoryId]];
           [list removeItems:[[list items] set]];
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidRemoveAllItemsFromGiftList:)]) {
               [pDelegate giftListManagerDidRemoveAllItemsFromGiftList:[list copy]];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)findGiftListsByFirstName:(NSString *)pFirstName
                                        lastName:(NSString *)pLastName
                                        delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  // Form handler's output contains array, so we have to increase output depth.
  // Check input parameters for nil, pass empty strings if nothing specified.
  NSDictionary *parameters = @{@"firstName": pFirstName ? pFirstName : @"",
                               @"lastName": pLastName ? pLastName : @""};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorFindGiftLists
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           NSArray *result = [ATGGiftList objectsFromArray:[pResponseObject objectForKey:@"giftlists"]];
           for (ATGGiftList *giftList in result) {
             // Always update |giftListId| property!
             [giftList setGiftlistId:[giftList repositoryId]];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidFindGiftLists:)]) {
               [pDelegate giftListManagerDidFindGiftLists:result];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)copyGiftItem:(ATGGiftItem *)pGiftItem
                          toGiftList:(NSString *)pGiftListID
                           andRemove:(BOOL)pRemove
                            delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"sourceGiftlistId": [[pGiftItem giftList] giftlistId],
                               @"destinationGiftlistId": pGiftListID,
                               @"giftItemId": [pGiftItem repositoryId]};
  NSString *actor = pRemove ? ATGActorMoveGiftItemToGiftList : ATGActorCopyGiftItemToGiftList;
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:actor
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           ATGGiftList *destination = [[self coreDataCache] getItemFromCacheWithID:pGiftListID];
           if ([destination items]) {
             // Destination gift list has its item downloaded, so we have to drop these items
             // in order to re-download newly created item. First remove gift items objects.
             [destination removeItems:[[destination items] set]];
           }
           if (pRemove) {
             // Source gift item should be removed from its gift list.
             [[pGiftItem giftList] removeItemsObject:pGiftItem];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidCopyItemToGiftList:)]) {
               [pDelegate giftListManagerDidCopyItemToGiftList:pGiftListID];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)moveToWishlistFromCartCommerceItemWithId:(NSString *)pCommerceItemId
                                                                 quantity:(NSString *)pQuantity
                                                                 delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"itemIds": pCommerceItemId, @"quantity": pQuantity};
  id<ATGRestOperation> operation =
          [[self restSession]
                  executePostRequestForActorPath:ATGActorMoveCartItemToWishList
                                   parameters:parameters
                                   requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
                                     if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
                                       ATGGiftList *wishlist = [[self coreDataCache] getItemFromCacheWithID:ATGWishListPseudoRepositoryID];
                                       if ([wishlist items]) {
                                         // Wishlist items already downloaded, clear its |items| property to re-download them later.
                                         // First remove items objects to delete them from underlying database.
                                         [wishlist removeItems:[[wishlist items] set]];
                                       }
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                         if ([pDelegate respondsToSelector:@selector(giftListManagerDidMoveItemToWishList)]) {
                                           [pDelegate giftListManagerDidMoveItemToWishList];
                                         }
                                       });
                                     } 
                                   }
                                  failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
                                    [request sendError:pError];
                                  }];
  [request setOperation:operation];
  return request;
}

- (ATGGiftListManagerRequest *)moveToGiftlistFromCartCommerceItemWithId:(NSString *)pCommerceItemId
                                                               giftlistId:(NSString *)pGiftlistId
                                                                 quantity:(NSString *)pQuantity
                                                                 delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"giftlistId": pGiftlistId, @"quantity": pQuantity,
                               @"itemIds": pCommerceItemId};
  id<ATGRestOperation> operation =
          [[self restSession]
                  executePostRequestForActorPath:ATGActorMoveCartItemToGiftList
                                      parameters:parameters
                                  requestFactory:nil
                                         options:ATGRestRequestOptionNone
                                         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
                                             ATGGiftList *list = [[self coreDataCache] getItemFromCacheWithID:pGiftlistId];
                                             if ([list items]) {
                                               [list removeItems:[[list items] set]];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                               if ([pDelegate respondsToSelector:@selector(giftListManagerDidMoveItemToGiftList)]) {
                                                 [pDelegate giftListManagerDidMoveItemToGiftList];
                                               }
                                             });
                                           }
                                         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
                                           [request sendError:pError];
                                         }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)copyGiftItemToWishList:(ATGGiftItem *)pGiftItem
                                     andRemove:(BOOL)pRemove
                                      delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"giftlistId": [[pGiftItem giftList] giftlistId],
                               @"giftItemId": [pGiftItem repositoryId]};
  NSString *actor = pRemove ? ATGActorMoveGiftItemToWishList : ATGActorCopyGiftItemToWishList;
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:actor
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           ATGGiftList *wishlist = [[self coreDataCache] getItemFromCacheWithID:ATGWishListPseudoRepositoryID];
           if ([wishlist items]) {
             // Wishlist items already downloaded, clear its |items| property to re-download them later.
             // First remove items objects to delete them from underlying database.
             [wishlist removeItems:[[wishlist items] set]];
           }
           if (pRemove) {
             [[pGiftItem giftList] removeItemsObject:pGiftItem];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidCopyItemToWishList)]) {
               [pDelegate giftListManagerDidCopyItemToWishList];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)addProduct:(NSString *)pProductID
                               sku:(NSString *)pSkuID
                          quantity:(NSString *)pQuantity
                        toGiftList:(NSString *)pGiftListID
                          delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"giftlistId": pGiftListID,
                               @"productId": pProductID,
                               @"catalogRefIds": pSkuID,
                               @"quantity": pQuantity};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorAddProductToGiftList
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           ATGGiftList *list = [[self coreDataCache] getItemFromCacheWithID:pGiftListID];
           if ([list items]) {
             [list removeItems:[[list items] set]];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidAddItemToGiftList:)]) {
               [pDelegate giftListManagerDidAddItemToGiftList:pGiftListID];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)addProductToWishList:(NSString *)pProductID
                                         sku:(NSString *)pSkuID
                                    quantity:(NSString *)pQuantity
                                    delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  NSDictionary *parameters = @{@"productId": pProductID, @"catalogRefIds": pSkuID, @"quantity": pQuantity};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorAddProductToWishList
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           ATGGiftList *list = [[self coreDataCache] getItemFromCacheWithID:ATGWishListPseudoRepositoryID];
           if ([list items]) {
             [list removeItems:[[list items] set]];
           }
           dispatch_async(dispatch_get_main_queue(), ^{
             if ([pDelegate respondsToSelector:@selector(giftListManagerDidAddItemToWishList)]) {
               [pDelegate giftListManagerDidAddItemToWishList];
             }
           });
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];

  return request;
}

- (ATGGiftListManagerRequest *)convertWishListToGiftListWithName:(NSString *)pName
                                                     type:(NSString *)pType
                                                addressId:(NSString *)pAddressId
                                                     date:(NSDate *)pDate
                                                  publish:(BOOL)pPublish
                                              description:(NSString *)pDescription
                                             instructions:(NSString *)pInstructions
                                                 delegate:(id<ATGGiftListManagerDelegate>)pDelegate {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];
  NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *dateComponents =
      [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:pDate];
  NSDictionary *parameters = @{@"isPublished": @(pPublish),
                               @"eventName": pName,
                               @"year": @([dateComponents year]),
                               @"month": @([dateComponents month] - 1),
                               @"date": @([dateComponents day]),
                               @"eventType": pType,
                               @"description": pDescription,
                               @"shippingAddressId": pAddressId,
                               @"instructions": pInstructions};
  id<ATGRestOperation> operation =
      [[self restSession]
       executePostRequestForActorPath:ATGActorConvertWishList
       parameters:parameters
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
           NSString *listId = [pResponseObject objectForKey:@"giftlistId"];
           NSDictionary *userLists = [[self memoryCache]
                                      getItemFromCacheWithID:ATGUserGiftListsItemName];
           if (userLists) {
             userLists = [userLists mutableCopy];
             [(NSMutableDictionary *)userLists setObject:pName forKey:listId];
             [[self memoryCache] insertItemIntoCache:[userLists copy]
                                              withID:ATGUserGiftListsItemName];
           }
           ATGGiftList *wishList = [[self coreDataCache]
                                    getItemFromCacheWithID:ATGWishListPseudoRepositoryID];
           [wishList removeItems:[[wishList items] set]];
           ATGGiftList *giftList = (ATGGiftList *)[ATGGiftList objectFromDictionary:nil];
           [giftList setRepositoryId:listId];
           [giftList setGiftlistId:listId];
           [giftList setName:pName];
           [giftList setType:pType];
           [giftList setAddressId:pAddressId];
           [giftList setAddressName:[pResponseObject objectForKey:@"addressName"]];
           [giftList setFirstName:[pResponseObject objectForKey:@"firstName"]];
           [giftList setLastName:[pResponseObject objectForKey:@"lastName"]];
           [giftList setDate:pDate];
           [giftList setPublicFlag:pPublish];
           [giftList setGiftListDescription:pDescription];
           [giftList setInstructions:pInstructions];
           [[self coreDataCache] insertItemIntoCache:giftList withID:listId];
           if ([pDelegate respondsToSelector:@selector(giftListManagerDidConvertWishListToGiftList:)]) {
             dispatch_async(dispatch_get_main_queue(), ^{
               [pDelegate giftListManagerDidConvertWishListToGiftList:[giftList copy]];
             });
           }
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         [request sendError:pError];
       }];
  [request setOperation:operation];
  return request;
}

#pragma mark - Private Protocol Implementation

- (ATGGiftListManagerRequest *)internalGetGiftListItems:(NSString *)pGiftListID
                                        delegate:(id <ATGGiftListManagerDelegate>)pDelegate
                                         success:(void (^)(NSArray *))pSuccessBlock {
  ATGGiftListManagerRequest *request = [[ATGGiftListManagerRequest alloc] init];
  [request setDelegate:pDelegate];

  // First query the cache to check, if we've retrieved gift list items already.
  ATGGiftList *list = [[self coreDataCache] getItemFromCacheWithID:pGiftListID];
  if ([[list items] count] > 0) {
    // There are gift items on the list, just reuse them.
    dispatch_async(dispatch_get_main_queue(), ^{
      pSuccessBlock ([[list items] array]);
    });
  } else {
    NSString *actor = [pGiftListID isEqualToString:ATGWishListPseudoRepositoryID] ?
        ATGActorGetWishListItems : ATGActorGetGiftListItems;
    // Nothing found, either we have an outdated data or there is no data at all. Fetch it.
    id<ATGRestOperation> operation =
        [[self restSession]
         executePostRequestForActorPath:actor
         parameters:@{@"giftlistId": pGiftListID}
         requestFactory:nil
         options:ATGRestRequestOptionNone
         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
           if (![request sendError:[ATGRestManager checkForError:pResponseObject]]) {
             ATGGiftList *giftList = list;
             if (giftList) {
               // There is a gift list stored in the cache! Reuse this instance, just update its items.
               NSArray *giftItems = [ATGGiftItem objectsFromArray:[pResponseObject objectForKey:@"items"]];
               [giftList setItems:[NSOrderedSet orderedSetWithArray:giftItems]];
             } else {
               // No gift list found in the cache, create a new instance and save it.
               giftList = (ATGGiftList *)[ATGGiftList objectFromDictionary:pResponseObject];
               // We're inserting resulting gift list with ID specified by input parameter.
               // This will cause wish list to be saved with repositoryId property value equal to WISHLIST.
               // I.e. cache implementation updates repositoryId property to the value specified by ID property.
               // So wish list items will be successfully found when requesting items for a gift list with
               // repositoryId equal to wish list pseudo ID.
               [[self coreDataCache] insertItemIntoCache:giftList withID:pGiftListID];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
               pSuccessBlock ([[giftList items] array]);
             });
           }
         }
         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
           [request sendError:pError];
         }];
    [request setOperation:operation];
  }
  return request;
}

- (ATGRestSession *)restSession {
  return [[ATGRestManager restManager] restSession];
}

@end



#pragma mark - ATGGiftList+ATGGiftListManager Category Implementation
#pragma mark -

@implementation ATGGiftList (ATGGiftListManager)

- (id)copyWithZone:(NSZone *)pZone {
  ATGGiftList *clone = (ATGGiftList *)[[NSManagedObject allocWithZone:pZone] initWithEntity:[self entity]
                                                             insertIntoManagedObjectContext:nil];
  [clone setRepositoryId:[self repositoryId]];
  [clone setGiftlistId:[self giftlistId]];
  [clone setName:[self name]];
  [clone setType:[self type]];
  [clone setAddressId:[self addressId]];
  [clone setAddressName:[self addressName]];
  [clone setDate:[self date]];
  [clone setPublicFlag:[self isPublic]];
  [clone setGiftListDescription:[self giftListDescription]];
  [clone setInstructions:[self instructions]];
  [clone setFirstName:[self firstName]];
  [clone setLastName:[self lastName]];
  return clone;
}

@end
