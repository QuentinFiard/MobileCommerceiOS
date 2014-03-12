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

#import "ATGMemoryCache.h"

@interface ATGMemoryCacheItem : NSObject

@property (nonatomic, strong, readonly) NSDate *cacheTime;
@property (nonatomic, strong) id cachedObject;

- (BOOL) isExpired:(NSTimeInterval)expiryTime;

@end

@implementation ATGMemoryCacheItem

@synthesize cacheTime = _cacheTime,
cachedObject = _cachedObject;

- (id) initWithItemToCache:(id)pItem {
  self = [super init];
  if (self) {
    _cacheTime = [NSDate date];
    _cachedObject = pItem;
  }
  return self;
}

- (BOOL) isExpired:(NSTimeInterval)expiryTime {
  NSDate *expirationDate = [NSDate dateWithTimeInterval:expiryTime sinceDate:self.cacheTime];
  if ([(NSDate *)[NSDate date] compare:expirationDate] == NSOrderedDescending) {
    return YES;
  }

  return NO;
}

@end

@interface ATGMemoryCache ()
@property (nonatomic, strong) NSCache *cache;
@end

@implementation ATGMemoryCache

@synthesize cache = _cache,
expiryTime = _expiryTime;

- (id) initWithCacheName:(NSString *)pName sizeLimit:(NSUInteger)pSizeLimit expiryTime:(NSTimeInterval)pExpiryTime {
  self = [super init];
  if (self) {
    _cache = [[NSCache alloc] init];
    self.cache.name = pName;
    self.cache.countLimit = pSizeLimit;
    _expiryTime = pExpiryTime;
  }
  return self;
}

- (id) getItemFromCacheWithID:(NSString *)pID {
  DebugLog(@"Checking %@ cache for object with id %@", self.cache.name, pID);
  ATGMemoryCacheItem *wrappedItem = [self.cache objectForKey:pID];

  if (wrappedItem == NULL) {
    DebugLog(@"No object with id %@ found in cache %@", pID, self.cache.name);
    return NULL;
  }

  DebugLog(@"Object with id %@ found in cache %@", pID, self.cache.name);
  if ([wrappedItem isExpired:self.expiryTime]) {
    DebugLog(@"Object with id %@ found is cache %@ is expired, removing item and returning NULL", pID, self.cache.name);
    [self removeItemFromCacheWithID:pID];
    return NULL;
  }

  return wrappedItem.cachedObject;
}

- (void) insertItemIntoCache:(id)pItem withID:(NSString *)pID {
  DebugLog(@"Inserting Item with id into cache %@.", pID, self.cache.name);
  ATGMemoryCacheItem *wrappedItem = [[ATGMemoryCacheItem alloc] initWithItemToCache:pItem];
  [self.cache setObject:wrappedItem forKey:pID];
}

- (void) removeItemFromCacheWithID:(NSString *)pID {
  DebugLog(@"Removing item with id %@ from cache %@.", pID, self.cache.name);
  [self.cache removeObjectForKey:pID];
}

- (void) clearCache {
  DebugLog(@"Clearing cache for %@.", self.cache.name);
  [self.cache removeAllObjects];
}

@end

static NSString * ATG_PAGING_KEY_PREFIX = @"ATGPagingMemoryCache-";
static NSUInteger ATG_INDEX_OFFSET = 1;
@implementation ATGPagingMemoryCache

- (NSArray *) getItemsFromCacheWithStartIndex:(NSUInteger)pIndex howMany:(NSUInteger)pHowMany {
  if (pIndex > self.cache.countLimit || pIndex - ATG_INDEX_OFFSET + pHowMany > self.cache.countLimit) {
    return nil;
  }
  NSString *cacheKey = [ATG_PAGING_KEY_PREFIX stringByAppendingString:[[NSNumber numberWithInt:self.cache.countLimit] stringValue]];
  NSArray *items = [self getItemFromCacheWithID:cacheKey];
  return [items subarrayWithRange:NSMakeRange(pIndex - ATG_INDEX_OFFSET, pHowMany)];
}

- (void) insertItemsIntoCache:(NSArray *)pItems startIndex:(NSUInteger)pStartIndex {
  if ([pItems count] == 0) {
    //Nothing to cache
  } else if (pStartIndex < self.cache.countLimit && [pItems count] + pStartIndex - ATG_INDEX_OFFSET < self.cache.countLimit)     {
    //Range in first page
    NSMutableArray *cachedItems = [[self getItemsFromCacheWithStartIndex:0 howMany:self.cache.countLimit] mutableCopy];
    if (!cachedItems) {
      cachedItems = [NSMutableArray array];
      for (int i = 0; i < self.cache.countLimit; i++) {
        [cachedItems insertObject:[NSNull null] atIndex:i];
      }
    }
    [cachedItems replaceObjectsInRange:NSMakeRange(pStartIndex - ATG_INDEX_OFFSET, [pItems count]) withObjectsFromArray:pItems range:NSMakeRange(0, [pItems count])];
    NSString *cacheKey = [ATG_PAGING_KEY_PREFIX stringByAppendingString:[[NSNumber numberWithInt:self.cache.countLimit] stringValue]];
    [self insertItemIntoCache:cachedItems withID:cacheKey];
  } else   {
    DebugLog(@"Ignoring items %d through %d to cache. Only cache items between %d and %d", pStartIndex, pStartIndex + [pItems count], 0, self.cache.countLimit);
  }
}

@end