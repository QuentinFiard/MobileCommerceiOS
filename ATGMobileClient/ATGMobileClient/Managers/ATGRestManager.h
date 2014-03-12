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
   @abstract Responsible for establishing connection to the server.

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGRestManager.h#1 $$Change: 848678 $

 */

#import <iOS-rest-client/ATGAddParameterRestRequestFactory.h>

enum {
  ATGRestRequestOptionIgnorePushSite   = 1 << 32,
  ATGRestRequestOptionIgnoreLocale     = 1 << 31
};
typedef NSUInteger ATGMobileRestRequestOptions;


/*!
   @constant
   @abstract The domain used for @link NSError @/link created by the REST comminications.
 */
extern NSString *const ATG_ERROR_DOMAIN;
/*!
   @constant
   @abstract Key used for storing exceptions in the userInfo on an @link NSError @/link
 */
extern NSString *const ATG_ERROR_EXCEPTION_KEY;
/*!
   @constant
   @abstract The domain used for @link NSError @/link created is the user is required to log in.
 */
extern NSString *const ATG_AUTHENTICATION_DOMAIN;
/*!
   @constant
   @abstract The key used in the Info.plist to store the REST host name.
 */
extern NSString *const ATG_REST_SERVER_HOST_KEY;
/*!
   @constant
   @abstract The key used in the Info.plinst to store the REST port number
 */
extern NSString *const ATG_REST_SERVER_PORT_KEY;
/*!
   @constant
   @abstract The date format string to use for interpreting data strings.
 */
extern NSString *const ATG_REST_DATE_FORMAT;
/*!
   @constant
   @abstract The locale of the data formatter
 */
extern NSString *const ATG_REST_DATE_FORMAT_LOCALE;

/*!
   @constant
   @abstract The notification name to signal the address cache should be cleared
 */
extern NSString *const ATG_CLEAR_PROFILE_ADDRESS_CACHE;
/*!
   @constant
   @abstract The notification name to signal the credit card cache to clear.,
 */
extern NSString *const ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE;

/*!
   @constant
   @abstract The notification name to signal the credit card cache to clear.,
 */
extern NSString *const ATG_CLEAR_PROFILE_CACHE;
/*!
 @const ATG_CLEAR_CACHED_ORDERS_NOTIFICATION
 @abstract Send this notification to clear all cached user orders.
 */
extern NSString *const ATG_CLEAR_CACHED_ORDERS_NOTIFICATION;
/*!
   @constant
   @abstract The notificaiton name to signal the product cache to be cleared.
 */
extern NSString *const ATG_CLEAR_PRODUCT_CACHE;
/*!
   @constant
   @abstract The key used in the Info.plist to store the recommendation retailer id
 */
extern NSString *const ATG_RECOMMENDATIONS_RETAILER_ID_KEY;

/*!
   @class
   @abstract Provides the framework to interact with an ATG server using the RESTful protocol.
 */
@interface ATGRestManager : NSObject {
}
/*!
   @property
   @abstract The session for the REST server
 */
@property (nonatomic, strong, readonly) ATGRestSession *restSession;
/*!
   @property
   @abstract The current site
 */
@property (nonatomic, copy) NSString *currentSite;
/*!
   @property
   @abstract The current locale
 */
@property (nonatomic, weak, readonly) NSString *currentLocale;

/*!
   @method
   @abstract Get the shared @link ATGRestManager @/link instance
 */
+ (ATGRestManager *) restManager;
/*!
   @method
   @abstract Create a request to get an image from the REST server
   @discussion Images will be cached automatically when using this request.
 */
+ (id <ATGRestOperation>) requestForImageURL:(NSString *)pURL success:( void ( ^)(id <ATGRestOperation> pOperation, id pResponseObject) )pSuccess failure:( void ( ^)(id <ATGRestOperation> pOperation, NSError * pError) )pFailure;
/*!
   @method
   @abstract Creates a request to get an image from a URL
   @discussion Imaged will be cahced automattically when using this request.
 */
+ (id <ATGRestOperation>) requestForAbsoluteImageURL:(NSString *)pURL success:( void ( ^)(id <ATGRestOperation> pOperation, id pResponseObject) )pSuccess failure:( void ( ^)(id <ATGRestOperation> pOperation, NSError * pError) )pFailure;
/*!
   @method
   @abstract Clears all cached images
 */
+ (void) clearImageCache;
/*!
   @method
   @abstract Checks a REST response for errors
 */
+ (NSError *) checkForError:(id)pResponse;
/*!
   @method
   @abstract Gets the shared data formatter that uses @link ATG_REST_DATE_FORMAT @/link and @link ATG_REST_DATE_FORMAT_LOCALE @/link
 */
+ (NSDateFormatter *) dateFormatter;
/*!
   @method
   @abstract Adds a prefix to a given string
 */
+ (NSString *) prefixString:(NSString *)pString withPrefix:(NSString *)pPrefix;


/*!
 @method
 @abstract Get the absolute path for a relative image. It will use the base URL 
 from the REST session.
 */
+ (NSString *) getAbsoluteImageString:(NSString *)pImageURL;

@end

@interface ATGMultisiteRestRequestFactory : ATGAddParameterRestRequestFactory

@end