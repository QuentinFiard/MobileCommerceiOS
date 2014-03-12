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
 @abstract Factory protocol for making REST requests

 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGRestClient/iOS-rest-client/ATGRestRequestFactory.h#1 $$Change: 848678 $

 */ 

#import "ATGRest.h"
#import "ATGRestOperation.h"

@protocol ATGRestRequestFactory <NSObject>

/*!
 @property 
 @abstract NSStringEncoding used during requests
*/
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/*!
 @method
 @abstract create a HTTP request using the specified method, path, parameters, and ATGRestRequestOptions
 @param pMethod HTTP method
 @param pPath URL
 @param pParameters NSDictionary of HTTP request parameters 
 @param pOptions request options
*/
- (NSMutableURLRequest *)requestWithHTTPMethod:(ATGHTTPMethod)pMethod path:(NSURL *)pPath parameters:(NSDictionary *)pParameters options:(ATGRestRequestOptions) pOptions;

/*!
 @method
 @abstract modify the given parameters as determined the class's implementation based on the request options
 @param pParameters a NSDictionary of the parameters to modify
 @param pOptions request options
*/
- (NSDictionary *)modifyParams:(NSDictionary *)pParameters options:(ATGRestRequestOptions)pOptions;

/*!
 @method
 @abstract modify the given request URL as determined by the class's implementation based on the request options
 @param pURL url to modify
 @param pOptions request options
*/
- (NSURL *)modifyRequestURL:(NSURL *)pURL options:(ATGRestRequestOptions) pOptions;

/*!
 @method
 @abstract allocates and initializes a new JSON request operation with the provided url request
 @param pRequest url request
 @param pSuccess success block
 @param pFailure failure block
*/
- (id <ATGRestOperation>)JSONRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure;

/*!
 @method
 @abstract allocates and initializes a new HTTP request operation with the provided url request
 @param pRequest url request
 @param	pSuccess success block
 @param	pFailure failure block
*/
- (id <ATGRestOperation>)HTTPRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure;

/*!
 @method
 @abstract enqueue an ATGRestOperation
 @param operation the ATGRestOperation
*/
- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)operation;

/*!
 @method
 @abstract enqueue an ATGRestOperation with optional ATGRestRequestOptions
 @param operation the ATGRestOperation
 @param options optional ATGRestRequestOptions
*/
- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)operation withOptions:(ATGRestRequestOptions) options;

/*!
 @method
 @abstract set the HTTP user agent string
 @param pUserAgent user agent is set to this value
*/
- (void) setUserAgentString:(NSString *)pUserAgent;

/*!
 @method
 @abstract set a value on the HTTP request body
 @param pValue value to set
 @param pKey key to set value on
 @param pRequest HTTP request
*/
- (void)setValue:(id)pValue forKey:(NSString *)pKey onRequest:(NSMutableURLRequest*)pRequest;

@end
