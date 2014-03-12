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
 @abstract EMContentItem class is a base implementation of a content item.
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

/*!
 @class
 @abstract EMContentItem class is a base implementation of a content item.
 @discussion content items are created by parsing the @type property of a map in an assembler response
 */
@interface EMContentItem : NSObject

/*!
 @property
 @abstract the content item type, from @type 
 */
@property (nonatomic, copy) NSString *type;

/*!
 @property
 @abstract the content item name, from name 
 */
@property (nonatomic, copy) NSString *name;

/*!
 @property
 @abstract an @link NSArray /@link of @link EMContentItemList /@link
    objects representing the content items subcontent
 */
@property (nonatomic, copy) NSArray *subcontent;

/*!
 @property
 @abstract all key value pairs from the original parsed object 
 */
@property (nonatomic, copy) NSDictionary *attributes;

/*!
 @method
 @abstract constructor
 @param pDictionary the @link NSDictionary @/link used to create 
    the content item
 @return a newly constructed content item
 */
- (id)initWithDictionary:(NSDictionary *)pDictionary;

/*!
 @method
 @abstract conveinience method for checking if a content item is of a 
    particular type, with an additional kvp for equality testing.
 @param pType the @link NSString /@link describing content item type
 @param pValue a @link NSString /@link which is a value in the content items
    attribute dictionary
 @param pKey a @link NSString /@link which is a key in the content items
    attribute dictionary
 @return void
 */
- (BOOL)isContentItemWithType:(NSString *)pType andValue:(NSString *)pValue forKey:(NSString *)pKey;
@end
