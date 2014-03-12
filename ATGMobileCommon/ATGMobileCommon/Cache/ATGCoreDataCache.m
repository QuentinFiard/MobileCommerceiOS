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

#import "ATGCoreDataCache.h"

NSString *const ATG_CACHE_TIME_KEY = @"cacheTime";

@interface ATGCoreDataCache ()

@property (nonatomic, copy) NSString *entityName;
@end

@implementation ATGCoreDataCache

@synthesize entity = _entity, document = _document, expiryTime = _expiryTime, entityName = _entityName, idPropertyName = _idPropertyName;

+ (NSPredicate *) predicateForKey:(NSString *)pKey andId:(NSString *)pID {
  return [NSPredicate predicateWithFormat:@"%K == %@", pKey, pID];
}

- (id) initWithEntityDescriptionName:(NSString *)pEntityName idPropertyName:(NSString *)pIDPropertyName expiryTime:(NSTimeInterval)pExpiryTime {
  self = [super init];
  if (self) {
    self.entityName = pEntityName;
    self.idPropertyName = pIDPropertyName;
    _expiryTime = pExpiryTime;
  }
  return self;
}

- (NSEntityDescription *) entity {
  if (!_entity) {
    _entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.document.managedObjectContext];
  }
  return _entity;
}

- (id) getItemFromCacheWithID:(NSString *)pID {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:self.entity];
  [request setPredicate:[ATGCoreDataCache predicateForKey:self.idPropertyName andId:pID]];
  NSError *error;
  id result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
  if (result == nil) {
    //If nil, an error has occured
    DebugLog(@"Error requesting %@ with ID:%@. Error: %@", self.entity.name, pID, error);
    return nil;
  } else if ([result count] > 1)     {
    //Returned more than 1 with that id. Delete all and return nil
    DebugLog(@"Found more than one %@ with ID = %@. Deleting all.", self.entity.name, pID);
    for (NSManagedObject *item in result) {
      [self.document.managedObjectContext deleteObject:item];
    }
    return nil;
  } else if ([result count] == 1)     {
    //Check the cache time
    id<ATGCachableItem> entity = [result lastObject];
    NSDate *expirationDate = [NSDate dateWithTimeInterval:self.expiryTime sinceDate:entity.cacheTime];
    if ([(NSDate *)[NSDate date] compare:expirationDate] == NSOrderedDescending) {
      //Expired, delete item
      [self.document.managedObjectContext deleteObject:entity];
      return nil;
    }
    DebugLog(@"Found %@ with ID %@ in cache.", self.entity.name, pID);
    return entity;
  } else   {
    DebugLog(@"%@ with ID %@ not found in cache", self.entity.name, pID);
    return nil;
  }
}

- (void) insertItemIntoCache:(id)pItem withID:(NSString *)pID {
  [pItem setValue:pID forKey:self.idPropertyName];
  ( (id <ATGCachableItem>)pItem ).cacheTime = [NSDate date];
  [self.document insertObject:pItem];
}

- (void) removeItemFromCacheWithID:(NSString *)pID {
  NSManagedObject *item = [self getItemFromCacheWithID:pID];
  if (item) {
    [self.document.managedObjectContext deleteObject:item];
  }
}

- (void) clearCache {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:self.entity];
  //This should save some resources since we don't need this.
  [request setIncludesPropertyValues:NO];
  NSError *error;
  id result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
  if (result == nil) {
    //If nil, an error has occured
    DebugLog(@"Error requesting all %@s for delete. Error: %@", self.entity.name, error);
    return;
  } else   {
    for (NSManagedObject *item in result) {
      [self.document.managedObjectContext deleteObject:item];
    }
  }
}

- (NSArray *) getAllWithSortDescriptors:(NSArray *)pSort {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:self.entity];
  [request setSortDescriptors:pSort];
  NSError *error;
  id result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
  if (result == nil) {
    //If nil, an error has occured
    DebugLog(@"Error requesting all %@s. Error: %@", self.entity.name, error);
    return nil;
  } else if ([result count] >= 1)     {
    //Check the cache time
    id <ATGCachableItem> entity = [result lastObject];
    NSDate *expirationDate = [NSDate dateWithTimeInterval:self.expiryTime sinceDate:entity.cacheTime];
    if ([(NSDate *)[NSDate date] compare:expirationDate] == NSOrderedDescending) {
      //Expired, delete items
      for (id <ATGCachableItem> expiredItem in result) {
        [self.document.managedObjectContext deleteObject:expiredItem];
      }
      return nil;
    }
    DebugLog(@"Found %d %@ in cache.", [result count], self.entity.name);
    return result;
  } else   {
    DebugLog(@"%@s not found in cache.", self.entity.name);
    return nil;
  }
}

- (ATGCacheManagedDocument *) document {
  if (!_document) {
    self.document = [ATGCacheManagedDocument sharedDocument];
  }
  return _document;
}

@end