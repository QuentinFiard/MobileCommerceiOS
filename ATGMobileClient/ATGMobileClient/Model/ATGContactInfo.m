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

#import "ATGContactInfo.h"

static NSArray *propertyList;

@implementation ATGContactInfo

@synthesize nickname = _nickname,
firstName = _firstName,
lastName = _lastName,
middleName = _middleName,
address1 = _address1,
address2 = _address2,
city = _city,
state = _state,
postalCode = _postalCode,
country = _country,
phoneNumber = _phoneNumber,
useShippingAddressAsDefault = _useShippingAddressAsDefault,
addressId = _addressId,
repositoryId = _repositoryId,
newNickname = _newNickname,
isGiftAddress;

+ (NSArray *) namedObjectsFromDictionary:(NSDictionary *)pDictionary defaultObjectID:(NSString *)pID {
  NSArray *addresses = [super namedObjectsFromDictionary:pDictionary defaultObjectID:pID];
  return [addresses sortedArrayUsingComparator: ^NSComparisonResult (id pObj1, id pObj2)
          {
            ATGContactInfo *address1 = (ATGContactInfo *)pObj1;
            ATGContactInfo *address2 = (ATGContactInfo *)pObj2;
            // Display default address first.
            if ([address1 useShippingAddressAsDefault]) {
              return NSOrderedAscending;
            } else if ([address2 useShippingAddressAsDefault]) {
              return NSOrderedDescending;
            } else {
              // All other addresses should be sorted by their name.
              return [[address1 nickname] compare:[address2 nickname]];
            }
          }
  ];
}

- (id) init {
  self = [super init];
  if (self) {
    if (propertyList == nil) {
      propertyList = [NSArray arrayWithObjects:@"nickname", @"newNickname", @"firstName",
                      @"lastName", @"middleName", @"address1", @"address2", @"city",
                      @"state", @"postalCode", @"country", @"phoneNumber", nil];
    }
  }

  return self;
}

- (BOOL)isEqual:(id)object {
  if (self == object) return YES;
  for (NSString *property in @[@"firstName", @"lastName", @"address1", @"address2", @"city", @"state", @"postalCode", @"country"]) {
    if (![[self valueForKey:property] isEqualToString:[object valueForKey:property]]) {
      return NO;
    }
  }
  return YES;
}

- (NSString *) description {
  return [NSString stringWithFormat
  :@"Contact Info: \r nickname: %@\r newNickname: %@\r firstName: %@\r middleName: %@\r lastName: %@\r" \
          "address1: %@\r address2: %@\r city: %@\r state: %@\r postalCode: %@\r country: %@\r phoneNumber: %@\r" \
          "useShippingAddressAsDefault: %d\r repositoryId: %@\r, addressId: %@\r, giftAddress: %@",
          _nickname, _newNickname, _firstName, _middleName ,_lastName, _address1, _address2, _city, _state, _postalCode, _country, _phoneNumber, _useShippingAddressAsDefault, _repositoryId, _addressId, [self isGiftAddress] ? @"true":@"false"];
}

- (id) copyWithZone:(NSZone *)zone {
  ATGContactInfo *infoCopy = [[[self class] allocWithZone:zone] init];

  [infoCopy setNickname:_nickname];
  [infoCopy setNewNickname:_newNickname];
  [infoCopy setFirstName:_firstName];
  [infoCopy setMiddleName:_middleName];
  [infoCopy setLastName:_lastName];
  [infoCopy setAddress1:_address1];
  [infoCopy setAddress2:_address2];
  [infoCopy setCity:_city];
  [infoCopy setState:_state];
  [infoCopy setPostalCode:_postalCode];
  [infoCopy setCountry:_country];
  [infoCopy setPhoneNumber:_phoneNumber];
  [infoCopy setRepositoryId:_repositoryId];
  [infoCopy setAddressId:_addressId];
  [infoCopy setUseShippingAddressAsDefault:_useShippingAddressAsDefault];

  return infoCopy;
}

- (NSArray *) propertyNames {
  return propertyList;
}

- (void) setObjectName:(NSString *)pName {
  [self setNickname:pName];
}

- (void) setDefaultObjectID:(NSString *)pID {
  //can be NSNull
  if ([pID isKindOfClass:[NSString class]]) {
    [self setUseShippingAddressAsDefault:[pID isEqualToString:[self repositoryId]]];
  }
}

@end