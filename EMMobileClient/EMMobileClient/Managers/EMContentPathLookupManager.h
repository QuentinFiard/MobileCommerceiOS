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
 @abstract EMContentPathLookupManager class used to fetch pieces of content by type, or path
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

@class EMContentItem, ATGJSONPathManager;
@protocol ATGJSONPathParserDelegate;

/*!
 @class
 @abstract EMContentPathLookupManager is used to fetch pieces of content by type or path
 @discussion singleton manager with capability to fetch content via path or type. 
    Content paths are @link NSString /@link objects which take the following form:
        ContentItem.contentItemList[ContentItem]
        ContentItem.contentItem
        ContentItem.contentItemList[ContentItem].contentItem...
        ContentItem.contentItemList[ContentItem].contentItemList...
    Content types are @link NSString /@link objects which describe the @link EMContentItem /@link
 */
@interface EMContentPathLookupManager : NSObject

/*!
 @method
 @abstract static method for getting singleton instance
 @return shared EMContentPathLookupManager instance
 */
+ (EMContentPathLookupManager *)contentPathLookupManager;

/*!
 @property
 @abstract an object which implements @link ATGJSONPAthParserDelegate /@link
 @discussion the @link EMContentItemPathLookupManager /@link uses an EMContentItemConverter by default
 */
@property (nonatomic, strong) id<ATGJSONPathParserDelegate> jsonPathParserDelegate;

/*!
 @property
 @abstract extension point for adding custom JSONPath tokens/handling
 @discussion an instance of @link ATGJSONPathManager /@link is the default
 */
@property (nonatomic, strong) ATGJSONPathManager *jsonPathManager;

/*!
 @method
 @abstract method for fetching content via path relative to an @link EMContentItem /@link
 @param pPath a @link NSString /@link object which describes the content location which is
    to be returned. Content paths are @link NSString /@link objects which take the following form:
        ContentItem.contentItemList[ContentItem]
        ContentItem.contentItem
        ContentItem.contentItemList[ContentItem].contentItem...
        ContentItem.contentItemList[ContentItem].contentItemList...
 @param pContentItem an @link EMContentItem /@link object which contains the desired content
 @return an object of type @link EMContentItem /@link or @link EMContentItemList /@link
 */
- (id)contentForPath:(NSString *)pPath inRootContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract method for fetching content via type within an @link EMContentItem /@link
 @param pType the @link NSString /@link object which defines the @link EMContentItem @/link
    type
 @param pContentItem an @link EMContentItem /@link object which contains the desired content
 @return an object of type @link EMContentItem /@link or nil if not found.
 */
- (EMContentItem *)contentWithType:(NSString *)pType inRootContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract method for fetching content via type within an @link EMContentItem /@link, method 
    takes an additional kvp which can be used to differentiate content with the same type. The
    pAttributeKey should be accessible via the @link EMContentItem /@link objects attributes property.
 @param pType the @link NSString /@link object which defines the @link EMContentItem @/link
    type
 @param pAttributeKey the @link NSString /@link object which is the key for a kvp defined in the 
    @link EMContentItem /@link objects attribute property
 @param pAttributeValue the @link NSString /@link object which is the value for a kvp defined in the 
    @link EMContentItem /@link objects attribute property
 @param pContentItem an @link EMContentItem /@link object which contains the desired content
 @return an object of type @link EMContentItem /@link or nil if not found.
 */
- (EMContentItem *)contentWithType:(NSString *)pType attributeKey:(NSString *)pAttributeKey attributeValue:(NSString *)pAttributeValue inRootContentItem:(EMContentItem *)pContentItem;
@end
