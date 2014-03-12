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
 @abstract EMAssemblerConnection class used to facilitate communication with an assembler based application
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 
 */

#import "AFHTTPClient.h"

@class EMAssemblerConnectionURLBuilder;
@class EMAssemblerRequestOperation;

typedef enum {
    EMAssemblerResponseFormatJSON,
    EMAssemblerResponseFormatXML,
    EMAssemblerResponseFormatNone
} EMAssemblerResponseFormat;

/*!
 @class
 @abstract EMAssemblerConnection is used to facilitate communication with an assembler based application
 @discussion Create a connection with a host, port, contextPath and responseFormat and begin querying for content 
    using the fetchContent:forSiteRootPath:actionString:success:failure:
 
    Assembler query typically follows this format:
        http://host:port/contextPath/format/siteRootPath/contentPath/actionPath?queryString
 
    The siteRootPath, contentPath, and actionString (actionPath?queryString) are returned as part of an objects
    navigation/record action.
 
 */
@interface EMAssemblerConnection : AFHTTPClient

/*!
 @property 
 @abstract Assembler response format, currently supports EMAssemblerResponseFormatJSON, 
    EMAssemblerResponseFormatXML, or EMAssemblerResponseFormatNone. Use EMAssemblerResponseFormatNone
    when response format has custom configuration.
 */
@property (nonatomic) EMAssemblerResponseFormat responseFormat;

/*!
 @property 
 @abstract Assembler application root context path
 */
@property (nonatomic, copy) NSString* contextPath;

/*!
 @property 
 @abstract Assembler application port
 */
@property (nonatomic) NSInteger port;

/*!
 @property 
 @abstract Assembler application host
 */
@property (nonatomic, copy) NSString *host;

/*!
 @property
 @abstract The delegate used to contruct connection URLs
 */
@property (nonatomic) EMAssemblerConnectionURLBuilder *urlBuilder;

/*!
 @method
 @abstract initialize connection with host, port, context path, and response format
 @discussion constructs connection http://pHost:pPort/pContextPath/pResponseFormat
 @param pHost Assembler application host
 @param pPort Assembler application port
 @param pContextPath Assembler application root context path
 @param pResponseFormat Assembler response format, supports EMAssemblerResponseFormatJSON or EMAssemblerResponseFormatXML
 */
- (id)initWithHost:(NSString *)pHost 
              port:(NSInteger)pPort 
       contextPath:(NSString *)pContextPath 
    responseFormat:(EMAssemblerResponseFormat)pResponseFormat
        urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder;

/*!
 @method
 @abstract convenience constructor creates connection with host, port, context path, and response format
 @discussion constructs connection http://pHost:pPort/pContextPath/pResponseFormat
 @param pHost Assembler application host
 @param pPort Assembler application port
 @param pContextPath Assembler application root context path
 @param pResponseFormat Assembler response format, supports EMAssemblerResponseFormatJSON or EMAssemblerResponseFormatXML
 */
+ (EMAssemblerConnection *)connectionWithHost:(NSString *)pHost 
                                         port:(NSInteger)pPort 
                                  contextPath:(NSString *)pContextPath 
                               responseFormat:(EMAssemblerResponseFormat)pResponseFormat
                                   urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder;

/*!
 @method
 @abstract initialize connection with secure (https)host, port, context path, and response format
 @discussion constructs connection https://pHost:pPort/pContextPath/pResponseFormat
 @param pHost Assembler application host - must be configured to use https
 @param pPort Assembler application port
 @param pContextPath Assembler application root context path
 @param pResponseFormat Assembler response format, supports EMAssemblerResponseFormatJSON or EMAssemblerResponseFormatXML
 */
- (id)initWithSecureHost:(NSString *)pHost 
                    port:(NSInteger)pPort 
             contextPath:(NSString *)pContextPath 
          responseFormat:(EMAssemblerResponseFormat)pResponseFormat
              urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder;

/*!
 @method
 @abstract convenience constructor creates connection with secure (https)host, port, context path, and response format
 @discussion constructs connection https://pHost:pPort/pContextPath/pResponseFormat
 @param pHost Assembler application host - must be configured to use https
 @param pPort Assembler application port
 @param pContextPath Assembler application root context path
 @param pResponseFormat Assembler response format, supports EMAssemblerResponseFormatJSON or EMAssemblerResponseFormatXML
 */
+ (EMAssemblerConnection *)connectionWithSecureHost:(NSString *)pHost 
                                               port:(NSInteger)pPort 
                                        contextPath:(NSString *)pContextPath 
                                     responseFormat:(EMAssemblerResponseFormat)pResponseFormat
                                         urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder;


/*!
 @method
 @abstract Assembler query interface
 @discussion Assembler query typically follows this format:
    http://host:port/contextPath/format/siteRootPath/contentPath/actionPath?queryString
 
    The siteRootPath, contentPath, and actionString (actionPath?queryString) are returned as part of an objects
    navigation/record action.
 @param pContentPath root content path within a site
 @param pSiteRootPath Application site root
 @param pActionString concatenated actionPath/queryString typically represented as navigation or record state
 @discussion any queryString passed into the actionString must be prefixed by a '?' ie. ?foo=bar 
             queryStrings that are prefixed by an actionPath should also contain a '?' ie. /bop?foo=bar
 @param success responseObject the @link NSData /@link returned via HTTP from the Assembler
                operation the wrapped HTTP request
 @param failure error the @link NSError /@link 
                operation the wrapped HTTP request
 */
- (void)fetchContent:(NSString *)pContentPath 
     forSiteRootPath:(NSString *)pSiteRootPath
        actionString:(NSString *)pActionString
             success:(void (^)(EMAssemblerRequestOperation *operation, id responseObject))success 
             failure:(void (^)(EMAssemblerRequestOperation *operation, NSError *error))failure;

/*!
 @method
 @abstract Provides a string representation of the supplied format type.
 @discussion returns the format type string
 @param pFormat the format to convert
 */
- (NSString *)formatTypeToString:(EMAssemblerResponseFormat)pFormat;

@end
