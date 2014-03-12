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

#import "ATGKeyValuePair+Additions.h"
#import <ATGMobileCommon/ATGCacheManagedDocument.h>
#import "ATGRestManager.h"

NSString *const ATG_KEY_VALUE_ENTITY_NAME = @"KeyValuePair";
NSString *const ATG_KEY_VALUE_ID_PROPERTY_NAME = @"key";
NSString *const ATG_ABOUT_US_KEY = @"AboutUs";
NSString *const ATG_PRIVACY_POLICY_KEY = @"PrivacyPolicy";
NSString *const ATG_SHIPPING_POLICY_KEY = @"ShippingPolicy";
NSString *const ATG_COUNTRY_BILLING_LIST_KEY = @"BillingCountryList";
NSString *const ATG_COUNTRY_SHIPPING_LIST_KEY = @"ShippingCountryList";
NSString *const ATG_STATES_LIST_KEY = @"StatesList";

@implementation ATGKeyValuePair (Additions)

+ (NSString *) entityDescriptorName {
  return ATG_KEY_VALUE_ENTITY_NAME;
}

+ (NSObject *) objectWithKey:(NSString *)pKey andValue:(NSDictionary *)pValue {
  // This is a managed object, so we have to get its instance from the managed object context,
  // not just create it with 'alloc' method. So we have to re-define the objectFromDictionary: method.
  // This implementation will shadow implementation defined by the category on the NSObject.
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityDescriptorName]
                                                       inManagedObjectContext:[ATGCacheManagedDocument sharedDocument].managedObjectContext];
  ATGKeyValuePair *result = [[self alloc]    initWithEntity:entityDescription
                             insertIntoManagedObjectContext:[ATGCacheManagedDocument sharedDocument].managedObjectContext];

  [result setKey:pKey];
  [result setValueWithJSON:pValue];
  return result;
}

+ (NSFetchRequest *) getFetchRequestForKey:(NSString *)pKey {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[ATGKeyValuePair entityDescription]];
  [request setPredicate:[NSPredicate predicateWithFormat:@"key == %@", pKey]];
  return request;
}

- (BOOL) validateForInsert:(NSError **)error {
  NSArray *results = [self.managedObjectContext executeFetchRequest:[ATGKeyValuePair getFetchRequestForKey:self.key] error:error];
  if (*error != nil) {
    NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    return NO;
  }
  if ([results count] == 1 && [results objectAtIndex:0] == self) {
    return YES;
  } else   {
    NSLog(@"WARNING: There are more than one key value pair with the key %@ in the cache.", self.key);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringWithDefaultValue(@"mobile.keyValue.keyExists", nil, [NSBundle mainBundle], @"Key already exists in cache.", @"Key already exists in cache."), NSLocalizedDescriptionKey, nil];
    *error = [NSError errorWithDomain:ATG_ERROR_DOMAIN code:1 userInfo:userInfo];
    return NO;
  }
}

- (id)getValueAsJSON {
  NSError *error = nil;
  id jsonObject = [NSJSONSerialization JSONObjectWithData:[self.value dataUsingEncoding:NSUTF8StringEncoding]
                                         options:NSJSONReadingMutableContainers
                                           error:&error];
  return jsonObject;
}

- (void)setValueWithJSON: (id)jsonObjectID{
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObjectID
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  self.value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end