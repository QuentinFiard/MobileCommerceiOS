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
   @abstract Manager for store related server calls.

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGStoreManager.h#1 $$Change: 848678 $

 */

#import "ATGStoreManagerDelegate.h"

@class ATGRestManager;

/*!
   @constant
   @abstract The amount of time in seconds that a store in the cache is valid for.
 */
extern const int ATG_STORE_CACHE_TIME_OUT_SEC;

/*!
   @constant
   @abstract The amount of time in seconds that state list or country list is valid for
 */
extern const int ATG_COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC;
/*!
   @const
   @abstract Store lookup component path for service request
 */
extern NSString *const ATG_STORE_LOOKUP_COMPONENT_PATH;
/*!
   @const
   @abstract Shipping and returns component path for service request
 */
extern NSString *const ATG_SHIPPING_AND_RETURNS_COMPONENT_PATH;
/*!
   @const
   @abstract Privacy and terms component path for service request
 */
extern NSString *const ATG_PRIVACY_AND_TERMS_COMPONENT_PATH;
/*!
   @const
   @abstract About us component path for service request
 */
extern NSString *const ATG_ABOUT_US_COMPONENT_PATH;
/*!
   @const
   @abstract Country restrictions component path for service request
 */
extern NSString *const ATG_COUNTRY_RESTRICTIONS_COMPONENT_PATH;
/*!
   @const
   @abstract State list component path for service request
 */
extern NSString *const ATG_STATE_LIST_COMPONENT_PATH;

@class ATGStoreManagerRequest;

/*!
   @class
   @abstract Provides the methods to get store information
   @discussion CoreData is used to cache the responses from the server.
 */
@interface ATGStoreManager : NSObject {
}

@property (nonatomic, weak, readonly) ATGRestManager *restManager;
/*!
   @method
   @abstract Gets the shared ATGStoreManager instance
 */
+ (ATGStoreManager *) storeManager;
/*!
   @method
   @abstract Get a list of stores
   @discussion Results are stored in a cache which is valid for @link STORE_CACHE_TIME_OUT_SEC @/link.

   Currently, all stores are fetched in this call. This call should be updated to
   support fetching stores in pages to handle large number of stores.
 */
- (ATGStoreManagerRequest *) getStores:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get the shipping policy
   @discussion Results are stored in a cache which is valid for @link STORE_CACHE_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getShippingPolicy:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get the privacy policy
   @discussion Results are stored in a cache which is valid for @link STORE_CACHE_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getPrivacyPolicy:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get information about the company
   @discussion Results are stored in a cache which is valid for @link STORE_CACHE_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getAboutUs:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get a list of contries that can be shipped to
   @discussion Results are stored in a cache which is valid for @link COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getShippingCountryList:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get a list of contries that can be billed to
   @discussion Results are stored in a cache which is valid for @link COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getBillingCountryList:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method
   @abstract Get a list of states for a given contry code.
   @discussion Results are stored in a cache which is valid for @link COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC @/link
 */
- (ATGStoreManagerRequest *) getStatesList:(NSString *)pCountryCode delegate:(NSObject <ATGStoreManagerDelegate> *)pDelegate;
/*!
   @method getMobileSitesForDelegate:
   @abstract Use this method to retrieve a list of available sites from server.
   @param delegate Delegate object to be notified about operation success/failure.
   @discussion Results are stored into a cache which is valid for half an hour.
 */
- (ATGStoreManagerRequest *) getMobileSitesForDelegate:(NSObject <ATGStoreManagerDelegate> *)delegate;

/*!
   @method clearStoresCache:
   @abstract Use this method to invalidate the cached list of stores.
   @discussion Clears the cached stores (if there are any).
 */
- (void) clearStoresCache;

/*!
 @method clearCache
 @abstract Use this method to invalidate all caches
 */
- (void)clearCache;
@end