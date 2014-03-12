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
   @abstract Manager for profile related server calls.

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGProfileManager.h#1 $$Change: 848678 $

 */

#import "ATGRestManager.h"
#import "ATGProfileManagerDelegate.h"
#import <ATGMobileCommon/ATGCache.h>

@class ATGProfileManagerRequest;
@class ATGProfile;

/*!
   @const
   @abstract User profile actor path
 */
extern NSString *const ATG_PROFILE_ACTOR_PATH;

/*!
   @const
   @abstract User addresses list actor path
 */
extern NSString *const ATG_ADDRESSES_LIST_ACTOR_PATH;

/*!
   @const
   @abstract User orders list actor path
 */
extern NSString *const ATG_ORDERS_LIST_ACTOR_PATH;

/*!
   @const
   @abstract Order details actor path
 */
extern NSString *const ATG_ORDER_DETAILS_ACTOR_PATH;

/*!
   @const
   @abstract Credit card remove actor path
 */
extern NSString *const ATG_CREDIT_CARD_REMOVE_ACTOR_PATH;

/*!
   @const
   @abstract Credit card list actor path
 */
extern NSString *const ATG_CREDIT_CARD_LIST_ACTOR_PATH;

/*!
 @const
 @abstract Update credit card actor path
 */
extern NSString *const ATG_CREDIT_CARD_UPDATE_ACTOR_PATH;

/*!
 @const
 @abstract Validate credit card actor path
 */
extern NSString *const ATG_CREDIT_CARD_VALIDATE_ACTOR_PATH;

/*!
 @const
 @abstract Credit card billing address actor path
 */
extern NSString *const ATG_CREDIT_CARD_BILLING_ACTOR_PATH;

/*!
 @const
 @abstract Create card with billing address actor path
 */
extern NSString *const ATG_CREDIT_CARD_CREATE_BILLING_ACTOR_PATH;

/*!
 @const
 @abstract Address edit actor path
 */
extern NSString *const ATG_ADDRESS_EDIT_ACTOR_PATH;

/*!
 @const
 @abstract Address remove actor path
 */
extern NSString *const ATG_ADDRESS_REMOVE_ACTOR_PATH;

/*!
 @const
 @abstract Address create actor path
 */
extern NSString *const ATG_ADDRESS_CREATE_ACTOR_PATH;

/*!
 @const
 @abstract Profile edit actor path
 */
extern NSString *const ATG_PROFILE_EDIT_ACTOR_PATH;

/*!
 @const
 @abstract Reset password actor path
 */
extern NSString *const ATG_RESET_PASSWORD_ACTOR_PATH;

/*!
 @const
 @abstract Skip login actor path
 */
extern NSString *const ATG_SKIP_LOGIN_ACTOR_PATH;

/*!
 @const
 @abstract Change password actor path
 */
extern NSString *const ATG_CHANGE_PASSWORD_ACTOR_PATH;

/*!
 @const
 @abstract Security status actor path
 */
extern NSString *const ATG_SECURITY_STATUS_ACTOR_PATH;

/*!
 @const
 @abstract Chechout create user actor path
 */
extern NSString *const ATG_CHECKOUT_CREATE_USER_ACTOR_PATH;

/*!
 @const
 @abstract Create create user actor path
 */
extern NSString *const ATG_CREATE_USER_ACTOR_PATH;

/*!
   @const
   @abstract The size of the pages to get when fetching orders
 */
extern NSUInteger const ATG_ORDER_PAGE_SIZE;

/*!
   @constant
   @abstract ATGProfileManagerErrorDomain Error domain to be used when validator creates an NSError instance.
 */
extern NSString *const ATGProfileManagerErrorDomain;

/*!
 @constant
 @abstract Key identifying address list object in the cache
 */
extern NSString *const ATG_CACHED_ADDRESS_LIST_OBJECT_CACHE_NAME;

/*!
 @constant
 @abstract Key identifying credit card list object in the cache
 */
extern NSString *const ATG_CACHED_CREDIT_CARD_LIST_OBJECT_CACHE_NAME;

/*!
 @constant
 @abstract Key identifying profile object in the cache
 */
extern NSString *const ATG_PROFILE_OBJECT_CACHE_NAME;

/*!
 @constant
 @abstract Key identifying personal info object in the cache
 */
extern NSString *const ATG_PERSONAL_INFO_OBJECT_CACHE_NAME;

/*!
   @class
   @abstract Class responsible for fetching and editing profile data
 */
@interface ATGProfileManager : NSObject

/*!
   @property
   @abstract The REST manager
 */
@property (nonatomic, weak, readonly) ATGRestManager *restManager;

/*!
   @property
   @abstract The path of the actor chain that retrieves a profile
 */
@property (nonatomic, strong) NSString *getProfileActorChain;


/*!
    @property
    @abstract The profile cache
 */
@property(nonatomic, strong) id <ATGCache> profileCache;

/*!
    @property
    @abstract The orders cache
 */
@property(nonatomic, strong) id <ATGCache> cachedOrders;

/*!
    @property
    @abstract The list of orders cache
 */
@property(nonatomic, strong) id <ATGPagingCache> cachedListofOrders;


+ (ATGProfileManager *) profileManager;

/*!
   @method
   @abstract Logs in using the restSession using the login and password provided
   @param pLogin the login id of the user
   @param pPassword the password of the user
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) login:(NSString *)pLogin withPassword:(NSString *)pPassword
                     delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Logs the user out
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) logout:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Places an @link ATGProfile @/link object in the request results
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) getProfile:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Changes the password of the user
   @param pOldPassword the old password of the user
   @param pConfirmPassword the confirmed new password of the user
   @param pNewPassword the new password of the user
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) changePassword:(NSString *)pOldPassword
                   withConfirmPassword:(NSString *)pConfirmPassword
                       withNewPassword:(NSString *)pNewPassword
                              delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Resets the password
   @param pEmailAddress address to send the password to
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) resetPassword:(NSString *)pEmailAddress
                             delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Gets the security status of the current user
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) getSecurityStatus:(id <ATGProfileManagerDelegate>)pDelegate;

/*
    @method
    @abstract Clears profile cache
 */
- (void)clearCachedProfile;

/*
    @method
    @abstract Clears the cache of orders
 */
- (void)clearCachedOrders;

/*
    @method
    @abstract Clears the cache of all orders
 */
- (void)clearCachedListofOrders;

/*
    @method
    @abstract Clears cached addresses
 */
- (void)clearCachedListofAddresses;

/*
    @method
    @abstract Clears cached credit card info
 */
- (void)clearCachedListofCreditCards;

/*
    @method
    @abstract Clears all cached info
 */
- (void)clearAllCache;


@end