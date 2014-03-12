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
 @abstract ATGJSONPathParser class used to fetch pieces of content from a JSON dicitioary based on a JSON path.
 @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
 
 */

#ifndef JSONPath_ATGJSONPathParser_h
#define JSONPath_ATGJSONPathParser_h

#import "ATGJSONPathParserDelegate.h"
#import "ATGJSONPathManager.h"

@class ATGJSONPathManager;

/*!
 
 @class
 @abstract ATGJSONPathParser is used to fetch pieces of content from a JSON object that is serialized into an @link NSDictionary /@link, given a path token.
 @discussion A parser that processes a JSON to fetch contents that satisfy the given path token.
    JSON path tokens are @link NSString /@link objects indicating the descendants to inspect and filters to apply to the content. A @link ATGJSONPathManager /@link must be used to tokenize and process the JSON path, and determine which @link ATGJSONPathParser /@link method must be invoked to fetch matching content.
    The result set is one of two types: @link NSArray /@link or @link NSDictionary /@link, both of which may be empty if no satisfying content is found in the JSON.
 
 */

typedef enum classTypes {
    DICTIONARY,
    ARRAY,
    STRING,
    NUMBER,
    OTHER
} JSONObjectClassType;


@interface ATGJSONPathParser : NSObject

@property(nonatomic, weak) id<ATGJSONPathParserDelegate> delegate;

/*!
 @method
 @abstract method checks if unknownObject is of a type defined by JSONObjectClassType enum. If it is not, an exception is thrown.
 */
+ (id) checkObjectTypeAndThrowError:(id) unknownObject;


/*!
 @method
 @abstract method returns the class type of object define by the JSONObjectClassType enum.
 */
+ (JSONObjectClassType) getKindOfClass:(id) object;

/*!
 @method
 @abstract method to fetch the root object. Exists for the sake of completeness, if this class is ever extended
 @param contentJSON a @link NSDictionary /@link containing the desired content
 @return the same dictionary that is passed in
 */
- (id) getContentFromRoot:(id) contentJSON;


/*!
 @method
 @abstract method to process the recursive descent operator (i.e. "..")
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param nodename the @link NSString /@link token that follows the descent operator in the path; value may also be nil or a wildcard. Used to perform an exhaustive search through the content without losing the original hierarchy of the descendant nodes.
 @param nodeFilter the @link NSString /@link token that follows the nodename token in the path; value may also be nil or contain a wildcard. Used to apply any necessary filters on the node described by nodename before hierarchy and ordering properties are destroyed as a result of performing an exhaustive search through the content.
 @param manager a reference to the @link ATGJSONPathManager /@link that initiated the JSON path processing and owns the current instance of the @link ATGJSONPathParser /@link
 @return an @link NSArray /@link containing the content items satisfying the nodename and nodeFilter conditions in the path
 */
- (id) getDescendantsRecursively:(id) contentJSON withNodename:(NSString *) nodename forNodeFilter:(NSString *) nodeFilter pathManager:(ATGJSONPathManager *) manager;


/*!
 @method
 @abstract method to fetch the immediate child of the content with key nodename  
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param nodename a @link NSString /@link token containing the name of the child to fetch contents of
 @return a @link NSArray /@link containing the content items whose key in contentJSON is nodename
 */
- (id) getChild:(id) contentJSON withNodename:(NSString *) nodename;


/*!
 @method
 @abstract generic method to determine the type of filter to apply to the given content dictionary and invoke appropriate methods to perform the filtering and return the obtained results
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param nodeFilter a @link NSString /@link for the token in the JSON path describing the filter to apply
 @param manager an instance of @link ATGJSONPathManager /@link that initiated the JSON path processing and owns the current instance of the @link ATGJSONPathParser /@link
 @return content items from contentJSON satisfying the given filter condition
 */
- (id) getContentFromCurrent:(id) contentJSON forNodeFilter:(NSString *) nodeFilter pathManager:(ATGJSONPathManager *) manager;


/*!
 @method
 @abstract method to fetch content item at a given index; path has the following general format: ${.node1}*.node2[index] 
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param index the location of the content item to fetch in the given content
 @return the content item at the given index;
         nil if index is invalid or the index does not exist in the given contentJSON
 */
- (id) getContentFromCurrent:(id) contentJSON atIndex:(NSInteger) index;


/*!
 @method
 @abstract method to filter content using applicable keywords of the underlying language; valid keywords are count and lastObject, thus this is simply another way of performing index filtering by specifying an index relative to the size of the current node rather than an exact position
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param script the filter to apply to the contentJSON; corresponding token in the JSON path has the following general format: node[(@.count{-, +}#)] or node[(@.lastObject)]
 @return the content item from contentJSON obtained by applying the script filter
 */
- (id) getContentFromCurrent:(id) contentJSON forScriptFilter:(NSString *) script;


/*!
 @method
 @abstract method to fetch content satisfying a query expression
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param expression the query to apply to the given content; corresponding token in the JSON path has the following general format: node[?(@.child1)] or node[?(@.someBooleanExpression)]
     <b>Note:</b> if the boolean expression contains numbers like in node[?(@.price<'13')], then the numerical value <b>must</b> be enclosed in single quotations
 @param manager an instance of @link ATGJSONPathManager /@link that initiated the JSON path processing and owns the current instance of the @link ATGJSONPathParser /@link
 @return the content item from contentJSON obtained by applying the expression filter
 */
- (id) getContentFromCurrent:(id) contentJSON forExpressionFilter:(NSString *) expression pathManager:(ATGJSONPathManager *) manager;


/*!
 @method
 @abstract a helper method for @link ATGJSONPathParser::getContentFromCurrent:forExprFilter /@link that fetches all content satisfying a given boolean statement
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param statementTokens the boolean statement to apply as the filter; the statement is tokenized to three parts: left-hand-side, boolean-operation, right-hand-side and should be passed to the statememtTokens array in exactly this order
 @return all content items in contentJSON that satisfy the given boolean expression
 */
- (id) getContentFromCurrent:(id) contentJSON satisfyingBooleanStatement:(NSArray *) statementTokens;


/*!
 @method
 @abstract method to fetch content based on a union operation
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param unionExpression the expression token in the JSON path indicating the items to be unionized. Token is generally of the format [a,b,c,...] where a, b, c may be any combination of array indices, alternative names, script filters, expression filters; items within the square brackets must be comma separated.
 @param manager an instance of @link ATGJSONPathManager /@link that initiated the JSON path processing and owns the current instance of the @link ATGJSONPathParser /@link
 @return all items in contentJSON satisfying the contents of unionExpression. 
    <b>Note:</b> If an item in contentJSON satisfies more than one of the items in unionExpression, then the result set will have a copy of that item for each sub-expression in unionExpression that it satisfies.
 */
- (id) getContentFromCurrent:(id) contentJSON withUnionOf:(NSString *) unionExpression pathManager:(ATGJSONPathManager *)manager;


/*!
 @method
 @abstract method to fetch content based on the given slice operator
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @param sliceExpression an expression describing the slicing; generally, corresponding token in the JSON path has the format: [startIndex:endIndex:stepSize], or [startIndex:] which gets everything starting from startIndex up to the end of contentJSON with a default step size of 1, or [:endIndex] which fetches everything from the start of the contentJSON up to endIndex with default step size of 1
 @param manager an instance of @link ATGJSONPathManager /@link that initiated the JSON path processing and owns the current instance of the @link ATGJSONPathParser /@link
 @return content from contentJSON obtained from applying the slice filter
 */
- (id) getContentFromCurrent:(id) contentJSON forSliceFilter:(NSString *) sliceExpression pathManager:(ATGJSONPathManager *) manager;


/*!
 @method
 @abstract a helper method for @link ATGJSONPathParser::getContentFromCurrent:forExpressoinFilter /@link that returns YES if a given path exists in contentJSON and NO otherwise
 @param pathTokens an @link NSArray /@link of @link NSString /@link tokens comprising the JSON path
 @param contentJSON an @link NSDictionary /@link containing the desired content
 @return YES if the JSON path indicated by pathTokens exists in contentJSON; NO otherwise
 */
- (BOOL) pathExists:(NSArray *)pathTokens inContent:(id) contentJSON;

@end

#endif
