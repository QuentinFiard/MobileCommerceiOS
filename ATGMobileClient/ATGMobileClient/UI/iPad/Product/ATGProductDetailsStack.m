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

#import "ATGProductDetailsStack.h"
#import <ATGMobileClient/ATGBaseProduct.h>
#import "ATGCommerceItemConverter.h"

// List of all available converters. Initialized when ATGProductDetailsStack class is loaded.
static NSArray *ATGProductDetailsConverters;

#pragma mark - NSArray (ATGProductDetailsStack) Category Definition
#pragma mark -

@interface NSArray (ATGProductDetailsStack)

- (NSArray *) arrayByConvertingToProductDetails NS_RETURNS_RETAINED;

@end

#pragma mark - ATGProductDetailsStack Private Protocol Definition
#pragma mark -

@interface ATGProductDetailsStack ()

#pragma mark - Private Properties

// NSMutableArray of NSArrays of ATGGenericProductDetails
// It's a stack of product lists. Each product list contains instances of ATGGenericProductDetails.
@property (nonatomic, readwrite, strong) NSMutableArray *productLists;
// NSMutableArray of NSNumbers
// It's a stack of positions. It's necessary for proper popping out a product list from stack.
@property (nonatomic, readwrite, strong) NSMutableArray *productListPositions;
// YES if initWithDataSource: init method has been called, NO otherwise.
@property (nonatomic, readwrite, getter = isInitializedFromDataSource) BOOL initializedFromDataSource;
// Reference to DataSource this stack has been initialized from.
@property (nonatomic, readwrite, weak) id <ATGProductDetailsStackDataSource> dataSource;
// YES if query to DataSource has been submitted and no answer received yet, NO otherwise.
@property (nonatomic, readwrite, getter = isQueryingDataSource) BOOL queryingDataSource;
// Result from previous call to DataSource's nextProductsForStack: method.
// This value will be returned, if stack's hasNextProductDetails method is invoked and stack is still
// querying a DataSource.
@property (nonatomic, readwrite) BOOL previousDataSourceAnswer;
// Reference to object who requested previous/next product details.
@property (nonatomic, readwrite, weak) id <ATGProductDetailsStackCallbacks> callbacksObject;
// YES if stack object should send didGetProductDetails: message to its callback object, NO otherwise.
@property (nonatomic, readwrite) BOOL shouldNotifyCallbacksObject;

#pragma mark - Private Methods

// Returns a list of products the user can navigate through.
- (NSArray *) currentProductsList;
- (void)      incrementCurrentPosition;
- (void)      decrementCurrentPosition;
// Returns index in the currentProductsList, represents user's current navigational position.
- (NSInteger) currentPosition;

@end

#pragma mark - ATPProductDetailsStack Implementation
#pragma mark -

@implementation ATGProductDetailsStack

#pragma mark - Synthesized Properties

@synthesize productLists;
@synthesize productListPositions;
@synthesize initializedFromDataSource;
@synthesize dataSource;
@synthesize queryingDataSource;
@synthesize previousDataSourceAnswer;
@synthesize callbacksObject;
@synthesize shouldNotifyCallbacksObject;

#pragma mark - Class Loader

+ (void) initialize {
  // When ATGProductDetailsStack is first used, initialize the list of product details converters.
  // This list will be used by the NSArray category to convert self into array of
  // ATGGenericProductDetails objects.
  ATGProductDetailsConverters = @[[[ATGCommerceItemConverter alloc] init],[[ATGProductConverter alloc] init], [[ATGGiftItemConverter alloc] init]];
}

#pragma mark - Init Methods

- (id) init {
  self = [super init];
  if (self) {
    // These objects are required for the stack to function properly.
    [self setProductLists:[[NSMutableArray alloc] init]];
    [self setProductListPositions:[[NSMutableArray alloc] init]];
  }
  return self;
}

- (id) initWithProducts:(NSArray *)pProducts currentID:(NSString *)pProductID {
  self = [self init];
  if (self) {
    // Initialized from static list of products.
    [self setInitializedFromDataSource:NO];
    // Save this list of products for future use.
    [self pushProducts:pProducts setCurrent:pProductID];
  }
  return self;
}

- (id) initWithDataSource:(id <ATGProductDetailsStackDataSource>)pDataSource
                currentID:(NSString *)pProductID {
  self = [self init];
  if (self) {
    // Initialized with a data source specified.
    [self setInitializedFromDataSource:YES];
    [self setDataSource:pDataSource];
    // Save initially available list of products for future use.
    [self pushProducts:[pDataSource initialProducts] setCurrent:pProductID];
  }
  return self;
}

#pragma mark - NSObject

- (NSString *) description {
  return [NSString stringWithFormat:@"{%@, current: %d}", [self productLists], [self currentPosition]];
}

#pragma mark - Public Protocol Implementation

- (ATGBaseProduct *) currentProductDetails {
  NSArray *currentProductsList = [self currentProductsList];
  // First, check if current position is valid.
  if ([self currentPosition] < 0) {
    // We're trying to get inexisting product details. Do not fail with error, just return nothing.
    [self incrementCurrentPosition];
    return nil;
  } else if ([self currentPosition] > [currentProductsList count] - 1) {
    // We're trying to get inexisting product details. Do not fail with error, just return nothing.
    [self decrementCurrentPosition];
    return nil;
  } else {
    // Current position is valid, return product details object.
    return [currentProductsList objectAtIndex:[self currentPosition]];
  }
}

- (BOOL) hasPreviousProductDetails {
  // It doesn't matter if we've initialized with a static products list or with a data source,
  // previous items must be loaded already, so no checks needed.
  return [self currentPosition] > 0;
}

- (void) previousProductDetailsForObject:(id <ATGProductDetailsStackCallbacks>)pObject {
  // Do not notify the previously saved callback object, if next products page arrives.
  [self setShouldNotifyCallbacksObject:NO];
  // It doesn't matter if we've initialized with a static products list or with a data source,
  // previous items must be loaded already, so no checks needed.
  // Just decrement current position and return product details. If no previous product exists,
  // there will be returned nothing.
  [self decrementCurrentPosition];
  [pObject productDetailsStack:self didGetProductDetails:[self currentProductDetails]];
}

- (BOOL) hasNextProductDetails {
  // If we've initialized with a data source object and navigating through the initial list of products,
  // then we have to check if there is a product available already.
  if ([self isInitializedFromDataSource] && [[self productLists] count] == 1
      && [[self currentProductsList] count] < [self currentPosition] + 1) {
    // ATGRenderableProduct details are not ready yet.
    // Do not query the data source object twice.
    if (![self isQueryingDataSource]) {
      [self setQueryingDataSource:YES];
      // Save the answer for future use. If the user requests next product existence,
      // this value would be returned to him.
      [self setPreviousDataSourceAnswer:[[self dataSource] nextProductsForStack:self]];
    }
    return [self previousDataSourceAnswer];
  } else {
    // We're navigating through the static list of products. Just query the array.
    return [[self currentProductsList] count] > [self currentPosition] + 1;
  }
}

- (void) nextProductDetailsForObject:(id <ATGProductDetailsStackCallbacks>)pObject {
  // If we've initialized with a data source object and navigating through the initial list of products,
  // then we have to check if there is a product available already.
  if ([self isInitializedFromDataSource] && [[self productLists] count] == 1
      && [[self currentProductsList] count] < [self currentPosition] + 1) {
    // ATGRenderableProduct details are not ready yet.
    if (![self isQueryingDataSource]) {
      // Notify the callback object when the next products page arrives.
      [self setShouldNotifyCallbacksObject:YES];
      [self setQueryingDataSource:YES];
      // Save the object to send it message later.
      [self setCallbacksObject:pObject];
      // Query the data source object for the next page of products.
      [self setPreviousDataSourceAnswer:[[self dataSource] nextProductsForStack:self]];
    }
  } else {
    // We're navigating through the static list of products. Just query the array.
    [self incrementCurrentPosition];
    [pObject productDetailsStack:self didGetProductDetails:[self currentProductDetails]];
  }
}

- (ATGBaseProduct *) pushProducts:(NSArray *)pProducts setCurrent:(NSString *)pProductID {
  // We're leaving current navigational scope, so do not notify the callback object about next products page.
  [self setShouldNotifyCallbacksObject:NO];
  // Always convert input arrays' objects into ATGGenericProductDetails.
  NSArray *productDetailsArray = [pProducts arrayByConvertingToProductDetails];
  // Find a product specified with its ID.
  NSInteger current = [productDetailsArray indexOfObjectPassingTest:
                       ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop)
                       {
                         if ([pProductID isEqualToString:[(ATGBaseProduct *) pObject repositoryId]]) {
                           *pStop = YES;
                           return YES;
                         }
                         return NO;
                       }
                      ];
  if (current == NSNotFound) {
    // Not found current product? Raise an exception.
    [NSException raise:NSInvalidArgumentException
                format:@"Can't find product with ID=(%@) within the products list specified: %@",
     pProductID, pProducts];
  }
  // Now we're ready to actually push the products list onto the stack.
  [[self productLists] addObject:productDetailsArray];
  // Push the position of the product specified with productID parameter onto the stack.
  [[self productListPositions] addObject:[NSNumber numberWithInteger:current]];
  // And now the currentProductDetails method will return proper value.
  return [self currentProductDetails];
}

- (ATGBaseProduct *) popProductsList {
  if ([[self productLists] count] == 1) {
    return nil;
  }
  // Actually pop from stack previously added objects.
  [[self productLists] removeLastObject];
  [[self productListPositions] removeLastObject];
  // And now the currentProductDetails method will return proper value.
  return [self currentProductDetails];
}

- (BOOL) isRootLevel {
  return ([[self productLists] count] == 1) ? YES : NO;
}

#pragma mark - ATGProductDetailsStack

- (void) dataSource:(id <ATGProductDetailsStackDataSource>)pDataSource
     didGetProducts:(NSArray *)pProducts {
  if ([pProducts count] > 0) {
    // There are products returned. Add them to the root list of products.
    NSArray *rootList = [[self productLists] objectAtIndex:0];
    // Always convert the array to ATGGenericProductDetails.
    rootList = [rootList arrayByAddingObjectsFromArray:[pProducts arrayByConvertingToProductDetails]];
    // Switch array instances.
    [[self productLists] removeObjectAtIndex:0];
    [[self productLists] insertObject:rootList atIndex:0];
  }
  [self setQueryingDataSource:NO];
  if ([self shouldNotifyCallbacksObject]) {
    // We're still navigating through the root
    [self incrementCurrentPosition];
    [[self callbacksObject] productDetailsStack:self didGetProductDetails:[self currentProductDetails]];
  }
}

#pragma mark - Private Protocol Implementation

- (NSArray *) currentProductsList {
  return [[self productLists] lastObject];
}

- (NSInteger) currentPosition {
  return [(NSNumber *)[[self productListPositions] lastObject] integerValue];
}

- (void) incrementCurrentPosition {
  NSInteger currentPosition = [self currentPosition];
  [[self productListPositions] removeLastObject];
  [[self productListPositions] addObject:[NSNumber numberWithInteger:currentPosition + 1]];
}

- (void) decrementCurrentPosition {
  NSInteger currentPosition = [self currentPosition];
  [[self productListPositions] removeLastObject];
  [[self productListPositions] addObject:[NSNumber numberWithInteger:currentPosition - 1]];
}

@end

#pragma mark - NSArray (ATGProductDetailsStack) Category Implementation
#pragma mark -

@implementation NSArray (ATGProductDetailsStack)

- (NSArray *) arrayByConvertingToProductDetails {
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
  // Convert each object inside an array.
  for (id object in self) {
    ATGBaseProduct *details = nil;
    if ([object isKindOfClass:[ATGBaseProduct class]]) {
      details = object;
    } else {
      // Query all available converters for result.
      for (id <ATGProductDetailsConverter> converter in ATGProductDetailsConverters) {
        ATGBaseProduct *converterResult = [converter convertObject:object];
        details = converterResult ? converterResult : details;
      }
    }
    if (details) {
      // One of the converters has actually converted the object to proper instance. Use this instance.
      [result addObject:details];
    } else {
      // Can't convert the object. Throw an exception.
      [NSException raise:NSInvalidArgumentException
                  format:@"Can't convert object of class (%@) to ATGGenericProductDetails.", [object class]];
    }
  }
  return [result copy];
}

@end