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
 @abstract EMContentItemList class acts as a typed @link NSMutableArray /@link for managing a list of
    @link EMContentItem /@link objects
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

@class EMContentItem;

/*!
 @class
 @abstract EMContentItemList class acts as a typed @link NSMutableArray /@link for managing a list of
    @link EMContentItem /@link objects
 @discussion content item lists are a local object created to manage lists of @link EMContentItem /@link
    objects, EMContentItemLists are manually constructed via inspection in @link JSONParser /@link
 */
@interface EMContentItemList : NSMutableArray

/*!
 @method
 @abstract add @link EMContentItem /@link from given list to current list
 @param pContentItemList the @link EMContentItemList @/link from which @link EMContentItem /@link to add
 @return void
 */
- (void) addContentItemsFromList:(EMContentItemList *)pContentItemList;

/*!
 @method
 @abstract add @link EMContentItem /@link to list
 @param pContentItem the @link EMContentItem @/link to add
 @return void
 */
- (void)addContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract remove @link EMContentItem /@link from list
 @param pContentItem the @link EMContentItem @/link to remove
 @return void
 */
- (void)removeContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract check for @link EMContentItem /@link in list
 @param pContentItem the @link EMContentItem @/link to look for
 @return YES if @link EMContentItem /@link is in list, otherwise NO
 */
- (BOOL)containsContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract get @link EMContentItem /@link from list
 @param pIndex the @link NSUInteger @/link index of @link EMContentItem /@link
    within list.
 @return @link EMContentItem @/link or nil.
 */
- (EMContentItem *)contentItemAtIndex:(NSUInteger)pIndex;

/*!
 @method
 @abstract get index of @link EMContentItem /@link in list
 @param pContentItem the @link EMContentItem /@link to find index of
 @return index of @link EMContentItem /@link or NSNotFound
 */
- (NSUInteger)indexOfContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract get list of all @link EMContentItem /@link objects with a 
    given type from within the list
 @param pType the @link NSString @/link that represents the 
    @link EMContentItem /@link type
 @return an EMContentItemList, which may be empty;
 */
- (EMContentItemList *)contentItemsWithType:(NSString *)pType;

/*!
 @method
 @abstract get count of @link EMContentItem /@link objects in list
 @return number of @link EMContentItem /@link objects in list
 */
- (NSUInteger)count;

/*!
 @method
 @abstract fast enumeration, see method in Apple Docs for more info.
 */
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained []) stackbuf count:(NSUInteger)len;

@end
