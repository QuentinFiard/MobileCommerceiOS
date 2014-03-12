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
 @abstract ATGJSONPathManager class used to process a tokenized JSON path.
 @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
 
 */

#ifndef JSONPath_ATGJSONPathManager_h
#define JSONPath_ATGJSONPathManager_h

#import "ATGJSONPathTokenizer.h"
#import "ATGJSONPathParser.h"

@class ATGJSONPathParser;

/*!
 
 @class
 @abstract ATGJSONPathManager is used to fetch pieces of content from a JSON object, that is serialized into an @link NSDictionary /@link, given a JSON path.
 @discussion A manager that processes a JSON path and fetches content from the given JSON dictionary by invoking appropriate methods in @link ATGJSONPathParser /@link. 
 Users of this manager simply need to pass to it a valid JSON path and a valid @link NSDictionary /@link containing the serialized JSON without any knowledge of the lower level implementation of the parser.
 <b>Note:</b> This manager assumes that the given JSON path and JSON dicitionary are valid objects and <b> does not </b> perform any validations or error checks.
 A JSON path is a @link NSString /@link object describing the path to follow in the given JSON dictionary to obtain the desired content.
 The result set is one of two types: @link NSArray /@link or @link NSDictionary /@link, both of which may be empty if no satisfying content is found in the JSON.
 
 */


@interface ATGJSONPathManager : NSObject

@property(strong, nonatomic) ATGJSONPathParser *jsonPathParser;
@property(strong, nonatomic) ATGJSONPathTokenizer *jsonPathTokenizer;

/*!
 @method
 @abstract method fetched pieces of content from a JSON dictionary given a JSON path
 @param path a @link NSString /@link describing the path to follow in the given JSON dictionary to obtained the desired content
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @return content from contentJSON that satisfies the requirements defined by path
 */
- (id) getContentForPath:(NSString *)path fromContent:(id)contentJSON;

/*!
 @method
 @abstract method to obtain the tokenizer used by the manager by those who hold a reference to the manager
 @return an instance of @link ATGJSONPathTokenizer /@link to be used to tokenize a JSON path
 */
- (ATGJSONPathTokenizer *) getTokenizer;

/*!
 @method
 @abstract method to obtain the parser used by the manager by those who hold a reference to the manager
 @return an instance of @link ATGJSONPathParser /@link to be used to parse the contents of a JSON object based on the given JSON path
 */
- (ATGJSONPathParser *) getParser;

@end


#endif
