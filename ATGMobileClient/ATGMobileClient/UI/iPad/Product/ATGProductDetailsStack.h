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

@class ATGBaseProduct;
@class ATGProductDetailsStack;
@protocol ATGProductDetailsStackDataSource;

/*!
   @protocol ATGProductDetailsStackCallbacks
   @abstract Adopt this protocol to communicate with @link //apple_ref/occ/cl/ATGProductDetailsStack @/link
   @discussion This protocol defines messages which can be sent by the product stack in response to
   queries to its contents.
 */
@protocol ATGProductDetailsStackCallbacks <NSObject>

@required

/*!
   @method productDetailsStack:didGetProductDetails:
   @abstract Called when the stack has product details object to be displayed.
   @param stack ATGProductDetailsStack object which sent the message.
   @param detail ATGRenderableProduct details of the requested product. Can be nil.
 */
- (void) productDetailsStack:(ATGProductDetailsStack *)stack
 didGetProductDetails       :(ATGBaseProduct *)details;

@end

/*!
   @protocol ATGProductDetailsStack
   @abstract Defines callback methods to be called by external auxiliary objects (e.g. data source).
   @discussion This protocol is adopted by the @link //apple_ref/occ/cl/ATGProductDetailsStack @/link class.
 */
@protocol ATGProductDetailsStack <NSObject>

@required

/*!
   @method dataSource:didGetProducts:
   @abstract Call this method from data source object when the next page of products is available.
   @discussion Call this method in response to nextProducts
 */
- (void) dataSource:(id <ATGProductDetailsStackDataSource>)dataSource
 didGetProducts    :(NSArray *)products;

@end

/*!
   @protocol ATGProductDetailsStackDataSource
   @abstract Conform to this protocol if you want to provide products available for user navigation
   on page by page basis.
 */
@protocol ATGProductDetailsStackDataSource <NSObject>

@required

/*!
   @method initialProducts
   @abstract Implement this method to return an array of products loaded already.
   @return Array of already loaded products.
 */
- (NSArray *) initialProducts;
/*!
   @method nextProductsForStack:
   @abstract Implement this method to query the server for the next page of products and notify the stack.
   @param stack ATGProductDetailsStack object to be notified when the next page of products is available.
   @return YES if more products can be loaded from server, NO otherwise.
 */
- (BOOL) nextProductsForStack:(id <ATGProductDetailsStack>)stack;

@end

/*!
   @class ATGProductDetailsStack
   @abstract Use instance of this class with conjunction with PDP screen to trace user's navigation through
   a list of available products (got from search, wish list, etc.) and through product's related products.
   @discussion When you pass an array of products into the stack (either from a data source object or
   through the <code>pushProducts:setCurrent:</code> method), array's inner objects are converted to
   ATGGenericProductDetails instances. If some of inner objects couldn't be converted, an exception would
   be thrown.
 */
@interface ATGProductDetailsStack : NSObject <ATGProductDetailsStack>

/*!
   @method initWithProducts:currentID:
   @abstract Initializes the stack with a static list of products.
   @discussion Use this initialization method, if initial list of products available for navigation
   is fully loaded from server already; or you'll be unable to modify this list later.
   If the underlying products list can be updated with new data while browsing the PDP screen,
   use @link //apple_ref/occ/instm/ATGProductDetailsStack/initWithDataSource:currentID: @/link method.
   @param products List of products available for navigation.
   @param productID ID of product to start navigation from. <code>products</code> parameter must have a
   product with this ID or an exception will be raised.
   @return Fully configured stack instance.
 */
- (id) initWithProducts:(NSArray *)products currentID:(NSString *)productID;
/*!
   @method initWithDataSource:currentID:
   @abstract Initializes the stack with a list of products loaded on page by page basis.
   @discussion Use this method to initialize the stack with products loaded page by page. If the user requests
   a product details which are not loaded yet, the stack would ask its data source to provide it all the
   necessary data.
   If the underlying product list is fully loaded already,
   use @link //apple_ref/occ/instm/ATGProductDetailsStack/initWithProducts:currentID: @/link method.
   @param dataSource Object which will provide product instances available for navigation.
   The stack instance doesn't retain the data source object.
   @param productID ID of product to start navigation from. Initial list of products returned by the
   <code>dataSource</code> must have a product with this ID or an exception will be raised.
   @return Fully configured stack instance.
 */
- (id) initWithDataSource:(id <ATGProductDetailsStackDataSource>)dataSource
 currentID               :(NSString *)productID;

/*!
   @method hasPreviousProductDetails
   @abstract Call this method to know if there is a previous object in current navigable products list.
   @return YES if there is a previous product, NO otherwise.
 */
- (BOOL) hasPreviousProductDetails;
/*!
   @method hasNextProductDetails
   @abstract Call this method to know if there is a next object in current navigable products list.
   @return YES if there is a next product, NO otherwise.
 */
- (BOOL) hasNextProductDetails;
/*!
   @method nextProductDetailsForObject:
   @abstract Use this method to get the next product in the currently navigable products list.
   @param object An object to receive a callback message when the next product is ready to use.
   Stack doesn't retain this object.
 */
- (void) nextProductDetailsForObject:(id <ATGProductDetailsStackCallbacks>)object;
/*!
   @method previousProductDetailsForObject:
   @abstract Use this method to get the previous product in the currently navigable products list.
   @param object An object to receive a callback message when the previous product is ready to use.
   Stack doesn't retain this object.
 */
- (void) previousProductDetailsForObject:(id <ATGProductDetailsStackCallbacks>)object;
/*!
   @method currentProductDetails
   @abstract Use this method to get the current product.
   @return Details for the current product.
 */
- (ATGBaseProduct *) currentProductDetails;
/*!
   @method pushProducts:setCurrent:
   @abstract Pushes a static list of products onto the stack.
   @discussion Use this method to add a static list of products available for navigation
   to the top of the stack. When this method is called, the user would navigate through the specified list.
   @param products List of products to be navigated through.
   @param productID ID of product to start navigation from. <code>products</code> array must have a
   product with this ID or an exception will be raised.
   @return ATGRenderableProduct details object for the product with ID specified with <code>productID</code> parameter.
 */
- (ATGBaseProduct *) pushProducts:(NSArray *)products setCurrent:(NSString *)productID;
/*!
   @method popProductsList
   @abstract Pops a static list of products out of the stack.
   @return ATGRenderableProduct details object from previous list.
 */
- (ATGBaseProduct *) popProductsList;
/*!
   @method isRootLevel
   @abstract Call this method to know if stack on root level or not.
   @return YES if it is root level, NO otherwise.
 */
- (BOOL) isRootLevel;
@end