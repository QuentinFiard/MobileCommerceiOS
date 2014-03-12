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

@implementation NSObject (ATGRestAdditions)

+ (NSObject *) objectFromDictionary:(NSDictionary *)pDictionary {
  // Simple implementation, just create an object and init it with property values from the dictionary.
  NSObject *result = [[self alloc] init];
  if (pDictionary == [NSNull null])
    return [NSNull null];
  [result applyPropertiesFromDictionary:pDictionary];
  return result;
}

+ (NSArray *) namedObjectsFromDictionary:(NSDictionary *)pDictionary defaultObjectID:(NSString *)pID {
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[pDictionary count]];
  // Input dictionary contains a name->object key-value pairs, iterate over all names and create objects.
  for (NSString *name in pDictionary) {
    // Re-use existing code to create an object instance.
    NSObject *object = [self objectFromDictionary:[pDictionary objectForKey:name]];
    // Now apply object name and default object ID.
    [object setObjectName:name];
    [object setDefaultObjectID:pID];
    // That's it, the object is ready to use.
    [result addObject:object];
  }
  return result;
}

+ (NSArray *) objectsFromArray:(NSArray *)pArray {
  // An input array should contain dictionaries defining object property values.
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[pArray count]];
  // Just iterate over its values and create objects with already defined method.
  for (NSDictionary *dictionary in pArray) {
    [result addObject:[self objectFromDictionary:dictionary]];
  }
  return result;
}

- (id)dictionaryFromObject{
  return [self dictionaryFromObjectWithPrefix:nil];
}

- (id)dictionaryFromObjectWithPrefix:(NSString *)pPrefix{
  id<ATGPropertyNameList> entity = nil;
  //check if object responds to [ATGPropertyNameList propertyNames]
  if ([self respondsToSelector:@selector(propertyNames)]){
    entity = (id <ATGPropertyNameList>)self;
  }
  return [self dictionaryFromObjectWithPrefix:pPrefix withPropertyNames:[entity propertyNames]];
}
- (id)dictionaryFromObjectWithPrefix:(NSString *)pPrefix withPropertyNames:(NSArray *)pPropertyNames{
  if (pPropertyNames){
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (id propName in pPropertyNames) {
      id propValue = [self valueForKey:propName];
      if ([propValue respondsToSelector:@selector(dictionaryFromObject:)]) {
        DebugLog(@"Parsing %@", propName);
        id propResult = [propValue performSelector:@selector(dictionaryFromObject:) withObject:pPrefix];
        if (pPrefix == nil) {
          [dictionary setValue:propResult forKey:propName];
        } else   {
          [dictionary setValue:propResult forKey:[NSString stringWithFormat:@"%@.%@", pPrefix, propName]];
        }
      } else if ([self respondsToSelector:NSSelectorFromString(propName)])    {
        DebugLog(@"Setting property %@", propName);
        if (pPrefix == nil) {
          [dictionary setValue:propValue forKey:propName];
        } else   {
          [dictionary setValue:propValue forKey:[NSString stringWithFormat:@"%@.%@", pPrefix, propName]];
        }
      } else   {
        DebugLog(@"No property %@", propName);
      }
    }
    return dictionary;
  }
  else {
    //If we don't respont to propertyNames, return self.
    DebugLog(@"No sub-properties listed for self, returning self.");
    return self;
  }
}

- (void) applyPropertiesFromDictionary:(NSDictionary *)pDictionary {
  // An input dictionary conatins property name-value pairs.
  for (NSString *propertyName in pDictionary) {
    // Get initial property value, it would be used later.
    id propertyValue = [pDictionary objectForKey:propertyName];
    SEL parseSelector = NSSelectorFromString
                          ([NSString stringWithFormat:@"parse%@%@:",
                            [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]]);
    // Do we implement a 'parsePropertyName:' method?
    if ([self respondsToSelector:parseSelector]) {
      // True, get proper value from the method. This method receives initial property value from dictionary.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      propertyValue = [self performSelector:parseSelector withObject:propertyValue];
#pragma clang diagnostic pop
    }
    // Safety check for the property value.
    if (propertyValue == [NSNull null]) {
      propertyValue = nil;
    }
    SEL setterSelector = NSSelectorFromString
                           ([NSString stringWithFormat:@"set%@%@:",
                             [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]]);
    // Do we implement a 'setPropertyName:' method?
    if ([self respondsToSelector:setterSelector]) {
      // True, now check if method's input parameter is of BOOL type.
      NSMethodSignature *signature = [self methodSignatureForSelector:setterSelector];
      const char *argumentType = [signature getArgumentTypeAtIndex:2];
      if (strcmp(@encode(BOOL), argumentType) == 0 && [propertyValue respondsToSelector:@selector(boolValue)]) {
        // Input parameter is BOOL and property value can be converted to BOOL.
        // Ignore this warnig, we've already checked if propertyValue responds to boolValue.
        propertyValue = [NSNumber numberWithBool:[propertyValue boolValue]];
      }
      // We have a setter method for the property, just set the value.
      [self setValue:propertyValue forKey:propertyName];
    }
  }
}

- (void) setObjectName:(NSString *)pName {
  // Default implementation revokes the method from class, subclasses may change this behavior.
  [self doesNotRecognizeSelector:_cmd];
}

- (void) setDefaultObjectID:(NSString *)pID {
  // Default implementation revokes the method from class, subclasses may change this behavior.
  [self doesNotRecognizeSelector:_cmd];
}

@end