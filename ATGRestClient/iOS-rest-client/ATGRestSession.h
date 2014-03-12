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
 @abstract Represents a REST session with an ATG server. Contains session data and provides methods for making REST requests.

 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGRestClient/iOS-rest-client/ATGRestSession.h#1 $$Change: 848678 $

 */

#import "ATGRest.h"
#import "ATGRestRequestFactory.h"
@protocol ATGRestLoginHandler;

/*!
 @class
 @abstract Provides the framework to interact with an ATG server using the RESTful protocol.
 */
@interface ATGRestSession : NSObject {
  @public
    volatile int requestedSessionConfirmation;
}

/*!
 @property
 @abstract The host name of the server
 */
@property (nonatomic,copy) NSString *host;
/*!
 @property 
 @abstract The port number of the server
 */
@property (nonatomic) NSInteger port;
/*!
 @property 
 @abstract The username
 */
@property (copy,nonatomic) NSString *username;
/*!
 @property
 @abstract The password
 */
@property (copy,nonatomic) NSString *password;

/*!
 @property 
 @abstract The context root used by REST.
 */
@property (copy,nonatomic) NSString *restContextRoot;

/*!
 @property 
 @abstract Whether or not HTTPS is used
 */
@property (nonatomic) BOOL useHttps;
/*!
 @property 
 @abstract The user id of the user after logging in
 */
@property (copy,nonatomic) NSString *userId;
/*!
 @property 
 @abstract The session confirmation number after logging in
 */
@property (copy,nonatomic) NSString *sessionConfirmationNumber;
/*!
 @property 
 @abstract The character encoding used to encode/decode server communication
 */
@property (nonatomic) NSStringEncoding characterEncoding;

/*!
 @property 
 @abstract The factory used to create requests
 @discussion Be default, it uses a ATGProfileServerLoginHandler
 */
@property (strong,nonatomic) id<ATGRestRequestFactory> requestFactory;

/*!
 @property 
 @abstract Handler for login
 */
@property (strong,nonatomic) id<ATGRestLoginHandler> loginHandler;

/*!
 @method
 @abstract The URL to the host, including the protocol, host name, and port
 */
- (NSURL *)hostURLWithOptions:(ATGRestRequestOptions)pOptions;

/*!
 @method 
 @abstract Creates a new session
 @discussion This method creates the session to handle REST requests.  The first thing that this method does is attempt to
 retrieve the session confirmation number.  To ensure that this is the first and only request made to the server,
 [ASIHTTPRequest.sharedQueue setMaxConcurrentOperationCount:1] is called which will make sure that no requests are made
 until we receive the session confirmation number.  This is then set back to the default value of 4.
 @param pHost The host name
 @param pPort The host port
 @param pUsername The username
 @param pPassword The password
 @result The newly created session
 */
+ (ATGRestSession *) newSessionForHost:(NSString *)pHost port:(NSInteger) pPort username:(NSString *) pUsername password:(NSString *)pPassword;


/*! 
 @method
 @abstract Logins the the user using the username and password set on the session
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions The ATGRestRequestOptions for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
-(id<ATGRestOperation>) login:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure;

/*! 
 @method
 @abstract Logs out the the user
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions The ATGRestRequestOptions for the request
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
-(id<ATGRestOperation>) logout:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions))pFailure;

/*! 
 @method
 @abstract Executes the method on the component
 @param pMethodName method on component to execute
 @param pComponentPath path to server side component, ie. /atg/xx/xxx/xxx
 @param pArguments Argument list for the method.  Adds arg1=<object>, arg2=<object2>, ... , argn=<objectn> to the URL.  It DOES NOT check for duplicates
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeMethod:(NSString *)pMethodName component:(NSString *) pComponentPath arguments:(NSArray *)pArguments parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;
/*! 
 @method
 @abstract Retrieves the REST representation of the component
 @param pComponentPath path to server side component, ie. /atg/xx/xxx/xxx
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) getComponent:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Retrieves the REST representation of the component as a POST
 @discussion This method differs from @link //apple_ref/occ/instm/ATGRestSession/getComponent:parameters:requestFactory:success:failure: [ATGRestSessionAF getComponent:parameters:requestFactory:success:failure:]@/link
 by adding the parameter values to the POST Body.  It sets @link ATG_REST_VIEW @/link to TRUE on the request.
 @param pComponentPath path to server side component, ie. /atg/xx/xxx/xxx
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) getComponentAsPost:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Gets the value from a component
 @param pPropertyName Name of bean property to query
 @param pComponentPath path to server side component, ie. /atg/xx/xxx/xxx
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) getPropertyValue:(NSString *)pPropertyName component:(NSString *)pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Executes the form handler method on the component
 @discussion If the ATGRestSession.sessionConfirmationNumber
 is invalid, the server will return a 409.  In the case of the 409, the ATGRestSession.sessionConfirmationNumber will be invalidated, and the server will attempt to get a new one.  If this is successful, the form handler request will
 be re-attempted. 
 @param pMethodName The handle method of the form handler to execute.  You should remove the "handle" substring. ie. "handleUpdateCard" becomes "updateCard".
 @param pComponentPath path to server side component, ie. /atg/xx/xxx/xxx
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeFormHandler:(NSString *)pMethodName component:(NSString *) pComponentPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError , NSArray *pFormExceptions))pFailure;

/*! 
 @method
 @abstract Executes the IndirectUrlTemplate registered on the server
 @discussion The component path given corresponds to the IndirectUrlTemplate registered on the server.  The REST client
 will call the the URL using the relative path of ATGRestSession.restContextRoot/\ref REST_SERVICE and the path to the item.
 @param pComponentPath The path of the IndirectUrlTemplate registered on the server to be accessed by REST
 @param pArguments Argument list for the method.  Adds arg1=<object>, arg2=<object2>, ... , argn=<objectn> to the URL.  It DOES NOT check for duplicates
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeServiceRequestForComponent:(NSString *)pComponentPath withArguments:(NSArray *)pArguments requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Executes the IndirectUrlTemplate registered on the server
 @discussion The component path given corresponds to the IndirectUrlTemplate registered on the server.  The REST client
 will call the the URL using the relative path of ATGRestSession.restContextRoot/\ref REST_SERVICE and the path to the item.
 @param pComponentPath The path of the IndirectUrlTemplate registered on the server to be accessed by REST
 @param pArguments Argument list for the method.  Adds arg1=<object>, arg2=<object2>, ... , argn=<objectn> to the URL.  It DOES NOT check for duplicates
 @param pParameters Properties to set on the component before execution and rest control properties
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeServiceRequestPostForComponent:(NSString *)pComponentPath withArguments:(NSArray *)pArguments parameters:(NSDictionary *) pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pRperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Executes a HTTP request for an absolute URL
 @discussion Used for retrieving images, etc.
 @param pURL absolute URL to request
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeGetRequestToAbsoluteURL:(NSURL *)pURL requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Executes the model actor chain registered on the server
 @discussion Parameters are encoded in the POST body and a HTTP request is made using the relative path of ATGRestSession.restContextRoot/\ref REST_MODELACTOR and the path to the model actor.
 @param pActorPath path to server side actor chain service, ie. /atg/xx/xxx/xxx
 @param pParameters HTTP request parameters to set (available to actor) and REST control properties
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executePostRequestForActorPath:(NSString *)pActorPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*! 
 @method
 @abstract Executes the model actor chain registered on the server
 @discussion Parameters are appended as query params on the URL and a HTTP request is made using the relative path of ATGRestSession.restContextRoot/\ref REST_MODELACTOR and the path to the model actor.
 @param pActorPath path to server side actor chain service, ie. /atg/xx/xxx/xxx
 @param pParameters HTTP request parameters to set (available to actor) and REST control properties
 @param pRequestFactory The ATGRestRequestFactory to create the request. The session's factory will be used if nil
 @param pOptions Options of type @link ATGRestRequestOptions /@link for the request
 @param pSuccess the block to be executed on success
 @param pFailure the block to be exectured on error
 */
- (id <ATGRestOperation>) executeGetRequestForActorPath:(NSString *)pActorPath parameters:(NSDictionary *)pParameters requestFactory:(id <ATGRestRequestFactory>)pRequestFactory options:(ATGRestRequestOptions) pOptions success:(void ( ^ ) ( id <ATGRestOperation> pOperation , id pResponseObject ))pSuccess failure:(void ( ^ ) ( id <ATGRestOperation> pOperation , NSError *pError ))pFailure;

/*!
 @method
 @abstract Resets the session confirmation number's state within this REST session
 @discussion Calling this method will result in a new session confirmation number being requested from the server
 */
-(void) resetSessionConfirmationNumber;
@end
