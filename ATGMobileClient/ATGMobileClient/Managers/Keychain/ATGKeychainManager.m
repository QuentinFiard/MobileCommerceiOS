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

#import "ATGKeychainManager.h"

NSString *const ATG_KEYCHAIN_EMAIL_PROPERTY = @"email";
NSString *const ATG_KEYCHAIN_PASSWORD_PROPERTY = @"password";
NSString *const ATG_KEYCHAIN_NAME_PROPERTY = @"name";
NSString *const ATG_KEYCHAIN_LOCALE_PROPERTY = @"locale";

@implementation ATGKeychainManager

// This variable will contain shared instance of the keychain manager.
static ATGKeychainManager *_instance;

+ (ATGKeychainManager *) instance {
  // First-time usage?
  if (_instance == nil) {
    // Allocate self, this will fill in the _instance variable.
    _instance = [[self alloc] init];
  }
  return _instance;
}

- (id) init {
  // If we have an instance, hence we're initializing a newly allocated instance.
  if (_instance != nil) {
    return _instance;
  }
  // First time initializing the manager.
  self = [super init];
  if (self) {
    // Init self and save a link into shared variable.
    _instance = self;
  }
  return _instance;
}

// This method returns an application name. It is stored in a main bundle.
- (NSString *) applicationName {
  // Just retrieve the name.
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSString *) stringForKey:(NSString *)pKey {
  // Construct a dictionary with query key-value pairs.
  NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
  // We save all string as passwords.
  [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [queryDictionary setObject:[self applicationName] forKey:(__bridge id)kSecAttrService];
  // We use the keys as account names.
  [queryDictionary setObject:pKey forKey:(__bridge id)kSecAttrAccount];
  // Return stored data from the keychain.
  [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
  // Keychain function states that we have to allocate memory manually.
  CFDataRef returnData = nil;
  NSString *result = nil;
  CFDictionaryRef query = ( (__bridge_retained CFDictionaryRef)queryDictionary );
  // Retrieve the data.
  if ( errSecSuccess == SecItemCopyMatching(query,
                                            (CFTypeRef *)&returnData) ) {
    // Success! We've found it. Save it to be returned.
    result = [[NSString alloc] initWithData:(__bridge NSData *)returnData
                                   encoding:NSUTF8StringEncoding];
    CFRelease(returnData);
  }

  CFRelease(query);
  return result;
}

- (void) setString:(NSString *)pString forKey:(NSString *)pKey {
  // Construct a dictionary with query key-value pairs.
  // We will search for an item to be updated using this dictionary.
  NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
  [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [queryDictionary setObject:[self applicationName] forKey:(__bridge id)kSecAttrService];
  [queryDictionary setObject:pKey forKey:(__bridge id)kSecAttrAccount];
  // Construct a dictionary with new value for value key.
  NSData *value = [pString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *updateDictionary = [NSDictionary dictionaryWithObject:value
                                                               forKey:(__bridge id)kSecValueData];
  // First, try to update an existing (if any) item.
  if ( errSecItemNotFound == SecItemUpdate( (__bridge CFDictionaryRef)queryDictionary,
                                            (__bridge CFDictionaryRef)updateDictionary ) ) {
    // Can't find the item specified! Create a new one.
    [queryDictionary addEntriesFromDictionary:updateDictionary];
    SecItemAdd( (__bridge CFDictionaryRef)queryDictionary, NULL );
  }
}

- (void) removeStringForKey:(NSString *)pKey {
  // Construct a dictionary with query key-value pairs.
  // We will search for an item to be deleted using this dictionary.
  NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
  [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [queryDictionary setObject:[self applicationName] forKey:(__bridge id)kSecAttrService];
  [queryDictionary setObject:pKey forKey:(__bridge id)kSecAttrAccount];
  SecItemDelete( (__bridge CFDictionaryRef)queryDictionary );
}

@end