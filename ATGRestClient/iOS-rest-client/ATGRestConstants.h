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
 @abstract Constants for ATG Rest
 
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved. 
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGRestClient/iOS-rest-client/ATGRestConstants.h#1 $$Change: 848678 $
 
 */

/*!
 @enum 
 @abstract The HTTP Methods
 @constant ATGHTTPMethodGet HTTP Get
 @constant ATGHTTPMethodPost HTTP Post
 @constant ATGHTTPMethodPut HTTP Put
 @constant ATGHTTPMethodDelete HTTP Delete
 */
typedef enum {
  ATGHTTPMethodGet,
  ATGHTTPMethodPost,
  ATGHTTPMethodPut,
  ATGHTTPMethodDelete
} ATGHTTPMethod;

/*!
 @enum ATGRestRequestOptions
 @abstract ATG REST Request options
 @constant ATGRestRequestOptionNone no options selected
 @constant ATGRestRequestOptionReturnFormProperties return form handler properties in the response after invoking a form handler
 @constant ATGRestRequestOptionReturnFormExceptions return any possible form handler exceptions in the response after invoking a form handler
 @constant ATGRestRequestOptionUseHTTPS use HTTPS protocol for the request
 @constant ATGRestRequestOptionRequireSessionConfirmation request and add the session confirmation number
*/
enum {
  ATGRestRequestOptionNone   = 0,
  ATGRestRequestOptionReturnFormProperties = 1 << 0,
  ATGRestRequestOptionReturnFormExceptions = 1 << 1,
  ATGRestRequestOptionUseHTTPS      = 1 << 2,
  ATGRestRequestOptionRequireSessionConfirmation   = 1 << 3
};
typedef NSUInteger ATGRestRequestOptions;

/*!
 @constant
 @abstract The control param key for REST input
 */
extern NSString *const ATG_REST_INPUT;
/*!
 @constant
 @abstract The control param key for REST output
 */
extern NSString *const ATG_REST_OUTPUT;
/*!
 @constant
 @abstract The control param value for JSON used by @link REST_OUTPUT @/link and @link REST_INPUT @/link
 */
extern NSString *const ATG_REST_FORMAT_JSON;
/*!
 @constant
 @abstract The control param value for XML used by @link REST_OUTPUT @/link and @link REST_INPUT @/link
 */
extern NSString *const ATG_REST_FORMAT_XML;

/*!
 @constant
 @abstract The prefix for method arguments when invoking methods via REST
 */
extern NSString *const ATG_REST_ARG;

/*!
 @constant
 @abstract The session confirmation number variable
 */
extern NSString *const ATG_DYN_SESS_CONF;

/*!
 @constant
 @abstract The control param for using JSON input for collection or map values
 */
extern NSString *const ATG_REST_INPUT_JSON;
/*!
 @constant
 @abstract The control param for setting the return depth
 */
extern NSString *const ATG_REST_DEPTH;
/*!
 @constant
 @abstract the control param to set a null value
 */
extern NSString *const ATG_REST_NULL;
/*!
 @constant
 @abstract The control param to include RQL queries
 */
extern NSString *const ATG_REST_RQL;
/*!
 @constant
 @abstract The control param to to include a string that the rest server will include in it's response
 */
extern NSString *const ATG_REST_USER_INPUT;
/*!
 @constant
 @abstract The control param for propery filtering
 */
extern NSString *const ATG_REST_PROPERTY_FILTERS;
/*!
 @constant
 @abstract The control param for setting property filter templates
 */
extern NSString *const ATG_REST_PROPERTY_FILTER_TEMPLATES;
/*!
 @constant
 @abstract The control param for telling the server to handle your POST request as a GET request.
 */
extern NSString *const ATG_REST_VIEW;

/*!
 @constant
 @abstract The control param for returning form handler exceptions
 */
extern NSString *const ATG_REST_FORM_HANDLER_EXCEPTIONS;
/*!
 @constant
 @abstract The control param for returning form handler properties
 */
extern NSString *const ATG_REST_FORM_HANDLER_PROPERTIES;
/*!
 @constant
 @abstract The control param for setting for tag priorities
 */
extern NSString *const ATG_REST_FORM_TAG_PRIORITIES;

/*!
 @constant
 @abstract The default NSStringEncoding type for encoding/decoding server commmunication
 */
extern NSStringEncoding const ATG_DEFAULT_STRING_ENCODING;
/*!
 @constant
 @abstract The key to add your to application plist to change the charachter encoding used for encoding/decoding server communication
 */
extern NSString *const ATG_DEFAULT_STRING_ENCODING_KEY;

/*!
 @constant
 @abstract The default boolean for whether or not use use HTTPs for all server communication
 */
extern BOOL const ATG_USE_HTTPS;
/*!
 @constant
 @abstract The key to add your to application plist to change the use of HTTPS
 */
extern NSString *const ATG_USE_HTTPS_KEY;
/*!
 @constant
 @abstract Key for the result in the response
 */
extern NSString *const ATG_REST_RESPONSE;
/*!
 @constant
 @abstract Key for the form exceptions in the response
 */
extern NSString *const ATG_REST_FORM_EXCEPTIONS;
/*!
 @constant
 @abstract Key for the form component in the response
 */
extern NSString *const ATG_REST_FORM_COMPONENT;
/*!
 @constant
 @abstract The context root substring for accessing ATG Components
 */
extern NSString *const ATG_REST_BEAN;
/*!
 @constant
 @abstract The context root substring for accessing ATG Repositories
 */
extern NSString *const ATG_REST_REPOSITORY;
/*!
 @constant
 @abstract The context root substring for accessing Indirect URL templates
 */
extern NSString *const ATG_REST_SERVICE;
/*!
 @constant
 @abstract The context root substring for accessing Model Actors
 */
extern NSString *const ATG_REST_MODELACTOR;

/*!
 @constant
 @abstract The ATG charset string key
 */
extern NSString *const ATG_CHARSET;

#pragma mark -
#pragma mark REST Exceptions

/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientException;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionCodeKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionDataKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionErrorKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionURLKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionParamsKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionArgumentsKey;
/*!
 @constant
 @abstract REST client exception key for userInfo Object
 */
extern NSString *const ATGRestClientExceptionHTTPMethodKey;

extern NSString *const ATGMethodNotImplmentedException;
/*!
 @constant
 @abstract Key used for storing FormHandler exceptions in the userInfo on an @link NSError @/link
 */
extern NSString *const ATG_FORM_EXCEPTION_KEY;


/*!
 @constant
 @abstract Key of notification posted when the reachability status changes
 */
extern NSString *const ATGNetworkingReachabilityDidChangeNotification;

/*!
 @constant
 @abstract The user agent string suffix used to itendify devices with Retina displays
 */
extern NSString *const ATG_RETINA_USER_AGENT_STRING;
/*!
 @constant
 @abstract The user agent string suffix used to itendify devices without Retina displays
 */
extern NSString *const ATG_NON_RETINA_USER_AGENT_STRING;

/*!
 @class
 @abstract Provides the framework to interact with an ATG server using the RESTful protocol.
 */
@interface ATGRestConstants : NSObject
/*!
 @method
 @abstract Converts the @link HTTPMethod @/link to a string value that could be used on a request
 @param pMethod @link HTTPMethod @/link to convert to a @link NSString @/link
 */
+ (NSString *) getHTTPMethodString:(ATGHTTPMethod) pMethod;
/*!
 @method
 @abstract Converts a @link NSString @/link encoding into the corresponding @link NSStringEncoding @/link enum
 @param pEncoding @link NSString @/link of encoding
 */
+ (NSStringEncoding) getEncodingFromString:(NSString *) pEncoding;
/*!
 @method
 @abstract Converts an @link NSStringEncoding @/link to it's corresponding @link NSString @/link
 @param pEncoding @link NSStringEncoding @/link of encoding
 */
+ (NSString *) getStringFromEncoding:(NSStringEncoding) pEncoding;

/*!
 @method
 @abstract Formats the user-agent string for the requests.
 */
+ (NSString *) formatUserAgentPropertyString:(NSArray *)pProperties;
/*!
 @method
 @abstract Gets the various components of the user-agent string
 */
+ (NSArray *) getUserAgentProperties;
/*!
 @method
 @abstract Gets the user-agent string to use for requests.
 */
+ (NSString *) getUserAgent;
@end
