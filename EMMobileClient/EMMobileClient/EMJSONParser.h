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

#import <ATGMobileCommon/JSONParser.h>
#import <ATGMobileCommon/JSONParserDelegate.h>

/*!
 
 @class
 @abstract EMJSONParser is used to parse JSON into EM* objects.
 @discussion It extends the parsing functionality in @link JSONParser /@link through its implementing the @link JSONParserDelegate /@link protocol. 
 */


/*!
 @constant
 @abstract default key for fetching content item type
 */
static NSString *const TYPE_KEY = @"@type";

/*!
 @constant
 @abstract default key for fetching content item class
 */
static NSString *const CLASS_KEY = @"@class";

/*!
 @constant
 @abstract default prefix for EM constructed objects.
 */
static NSString *const EM_CLASS_PREFIX = @"EM";

/*!
 @constant
 @abstract default class package of Endeca model objects
 */
static NSString *const CLASS_PACKAGE = @"com.endeca.infront.cartridge.model.";

@interface EMJSONParser : JSONParser  <JSONParserDelegate>

/*!
 @method
 @abstract subclassing hook for overriding the content item class for a give type
 @discussion default behavior is to construct a class with the following format:
  EM_CLASS_PREFIX + pType
 @param pType is the string value returned for key TYPE_KEY
 @return the class to be constructed for the specified type
 */
- (Class)contentItemClassForType:(NSString *)pType;

/*!
 @method
 @abstract subclassing hook for overriding the data object class for a give class
 @discussion default behavior is to construct a class with the following format:
  return pClass after replacing occurence of CLASS_PACKAGE with EM_CLASS_PREFIX
 @param pClass is the string value returned for key CLASS_KEY
 @return the class to be constructed for the specified class
 */
- (Class)dataObjectClassForClass:(NSString *)pClass;
@end
