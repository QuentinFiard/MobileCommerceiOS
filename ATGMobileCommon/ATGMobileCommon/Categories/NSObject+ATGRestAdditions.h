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

@protocol ATGPropertyNameList <NSObject>
- (NSArray *) propertyNames;
@end

/*!
   @category NSObject (ATGRestAdditions)
   @abstract This category defines additional method enabling automatic data parsing.
   @discussion This category allows creating of proper object structures defined with an
   NSDictionary or NSArray JSON representation.
 */
@interface NSObject (ATGRestAdditions)

/*!
   @method objectFromDictionary:
   @abstract Creates proper object defined with an NSDictionary instance.
   @discussion This method creates an instance of proper class. In order to create an ATGOrder instance
   just send a [ATGOrder objectFromDictionary:dictionary] message. This method is re-used by other
   factory methods defined by this cateogry.
   @param dictionary An NSDictionary instance with object property values.
   @return Fully initialized object or NSNull null if dictionary is null.
 */
+ (NSObject *) objectFromDictionary:(NSDictionary *)dictionary;
/*!
   @method namedObjectsFromDictionary:defaultObjectID:
   @abstract Creates a collection of objects defined with an NSDictionary containing a name->object values.
   @discussion This method iterates over all key-value pairs defined by an input dictionary and creates objects
   from their values (please, note that values of this dictionary should be of NSDictionary type).
   Then this method sends a @link //apple_ref/occ/intfm/NSObject/setObjectName: setObjectName: @/link and
   @link //apple_ref/occ/intfm/NSObject/setDefaultObjectID: setDefaultObjectID: @/link messages to a newly
   created object. And only then this object is added to a resulting collection.
   <br/>
   Here's an example of valid input dictionary. Consider a dictionary with user's available addresses.
   In this case dictionary keys would be addresses names ('Home', 'Work', etc.) values would be dictionaries
   with appropriate repository item property values ({'repositoryID': 'id', 'firstName': 'Stuart',
   'lastName': 'Schmidt'...}).
   In case of user addresses defaultObjectID input parameter should be a repository ID of the contact-info
   repository item which is used as default shipping address.
   @param dictionary An NSDictionary instance defining a name->object value pairs.
   @param ID Defines an ID of default object.
   @return Collection of fully initialized objects.
 */
+ (NSArray *) namedObjectsFromDictionary:(NSDictionary *)dictionary defaultObjectID:(NSString *)ID;
/*!
   @method objectsFromArray:
   @abstract Creates a collection of object defined with a collection of NSDictionary instances.
   @discussion This method iterates over input collection items and creates objects from their values
   (please, note that values of this collection should be of NSDictionary type).
   @param array Collection of NSDictionary instances defining objects values.
   @return Collection of fully initialized objects.
 */
+ (NSArray *) objectsFromArray:(NSArray *)array;

/*!
 @method
 @abstract Creates a dictionary that represents the properties of this object. 
 Uses the ATGPropertyNameList protocol to find what properties to add to the
 dictionary. Recursivley calls [dictionaryFromObject] on property values before 
 adding it to the dictionary. If there are so properties to add, self should be 
 returned.Default implementation calls [self dictionaryFromObjectWithPrefix:nil].
 */
- (id)dictionaryFromObject;

/*!
 @method
 @abstract Creates a dictionary that represents the properties of this object with
 the format "prefix.propertyName" as the dictionary keys. Uses the 
 ATGPropertyNameList protocol to find what properties to add to the dictionary.
 Recursivley calls [dictionaryFromObject] on property values before adding it
 to the dictionary. If there are so properties to add, self should be returned.
 Default implementation calls 
 [self dictionaryFromObjectWithPrefix:pPrefix withPropertyNames:self.propertyNames].
 @param pPrefix The prefix to add to the dictionary keys for each property name
 */
- (id)dictionaryFromObjectWithPrefix:(NSString *)pPrefix;

/*!
 @method
 @abstract Creates a dictionary that represents the properties of this object with
 the format "prefix.propertyName" as the dictionary keys. Uses the
 pPropertyName param to find what properties to add to the dictionary.
 Recursivley calls [dictionaryFromObject] on property values before adding it 
 to the dictionary. If there are so properties to add, self should be returned.
 @param pPrefix The prefix to add to the dictionary keys for each property name
 @param pPropertyNames the list of properties to add to the dictionary
 */
- (id)dictionaryFromObjectWithPrefix:(NSString *)pPrefix withPropertyNames:(NSArray *)pPropertyNames;
/*!
   @method applyPropertiesFromDictionary:
   @abstract This method applies property values from an input dictionary param.
   @discussion This method iterates over all key-value pairs defined by the input dictionary.
   Key stands for object propery name, value defines its value.
   First, this method checks if message receiver implements a <code>parse&lt;PropertyName&gt;:</code> method.
   If this is the case, property value is taken from this method; value contained in the initial dictionary
   is passed as input parameter into this method. Implement this method to return value of the proper type.
   The 'parse' method is allowed to return nothing. Just set proper property value manually.
   if property value returned is an <code>NSNull</code> instance, it's substained with <code>nil</code> value.
   Then, this method checks if the message receiver implements a <code>set&lt;PropertyName&gt;:</code> method.
   If this is the case, this method is invoked with prevously constructed property value.
   @param dictionary An NSDictionary instance defining object property values.
 */
- (void) applyPropertiesFromDictionary:(NSDictionary *)dictionary;
/*!
   @method setObjectName:
   @abstract Implement this method in subclasses to name instances properly.
   @param name Object name to be set.
 */
- (void) setObjectName:(NSString *)name;
/*!
   @method setDefaultObjectID:
   @abstract Implement this method in subclasses to set ID of default object.
   @param ID An ID of default object.
 */
- (void) setDefaultObjectID:(NSString *)ID;

@end