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

#import "ATGCreditCard.h"

static NSArray *propertyList;
static NSDictionary *typesToDisplayNames;

@interface ATGCreditCard ()
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;
@end

@implementation ATGCreditCard

@synthesize nickname = _nickname,
newNickname = _newNickname,
creditCardNumber = _creditCardNumber,
creditCardType = _creditCardType,
expirationYear = _expirationYear,
expirationMonth = _expirationMonth,
defaultCreditCardId = _defaultCreditCardId,
repositoryId = _repositoryId,
billingAddress = _billingAddress,
maskedCreditCardNumber = _maskedCreditCardNumber,
selectedBillingAddress = _selectedBillingAddress,
matchedSecondaryAddressId = _matchedSecondaryAddressId,
editBillAddress = _editBillAddress;

+ (void)initialize {
  NSBundle *bundle = [NSBundle atgResourceBundle];
  NSString *path = [bundle pathForResource:@"CreditCardTypes" ofType:@"plist"];
  typesToDisplayNames = [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (NSArray *) creditCardTypeDisplayNames {
  return [typesToDisplayNames allValues];
}

- (id) init {
  self = [super init];
  if (self) {
    if (propertyList == nil) {
      propertyList = [NSArray arrayWithObjects:@"nickName", @"newNickname", @"creditCardNumber",
                      @"creditCardType", @"expirationYear", @"expirationMonth",
                      @"billingAddress", @"repositoryId", @"defaultCreditCardNickname",
                      nil];
    }
    if (!typesToDisplayNames) {

    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)pZone {
  ATGCreditCard *card = [[ATGCreditCard alloc] init];
  [card setNickname:[self nickname]];
  [card setNewNickname:[self newNickname]];
  [card setCreditCardNumber:[self creditCardNumber]];
  [card setCreditCardType:[self creditCardType]];
  [card setExpirationYear:[self expirationYear]];
  [card setExpirationMonth:[self expirationMonth]];
  [card setRepositoryId:[self repositoryId]];
  [card setDefaultCreditCardId:[self defaultCreditCardId]];
  [card setMaskedCreditCardNumber:[self maskedCreditCardNumber]];
  [card setBillingAddress:[self billingAddress]];
  [card setSelectedBillingAddress:[self selectedBillingAddress]];
  [card setMatchedSecondaryAddressId:[self matchedSecondaryAddressId]];
  [card setEditBillAddress:[self editBillAddress]];
  return card;
}

- (NSArray *) propertyNames {
  return propertyList;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Credit Card: \r nickname: %@\r newNickname: %@\r creditCardNumber: %@\r" \
          "creditCardType: %@\r expirationYear: %@\r expirationMonth: %@\r defaultCreditCardId: %@\r repositoryId: %@\r" \
          "billingAddress: %@\r maskedCreditCardNumber: %@\r selectedBillingAddress %@\r matchedSecondaryAddressId %@ editBillAddress %@",
          _nickname, _newNickname, _creditCardNumber, _creditCardType, _expirationYear, _expirationMonth, _defaultCreditCardId,
          _repositoryId, _billingAddress, _maskedCreditCardNumber, _selectedBillingAddress, _matchedSecondaryAddressId, _editBillAddress];
}

- (void) setObjectName:(NSString *)pName {
  [self setNickname:pName];
}

- (void) setDefaultObjectID:(NSString *)pID {
  self.defaultCreditCardId = pID;
}

- (NSString *)parseCreditCardNumber:(NSString *)pRawNumber {
  [self setMaskedCreditCardNumber:pRawNumber];
  return pRawNumber;
}

- (ATGContactInfo *) parseBillingAddress:(NSDictionary *)pAddress {
  if(pAddress == [NSNull null])
    return nil;
  return (ATGContactInfo *)[ATGContactInfo objectFromDictionary:pAddress];
}

- (void)setCreditCardTypeFromDisplayName:(NSString *)pDisplayName {
  NSArray *type = [typesToDisplayNames allKeysForObject:pDisplayName];
  if ([type count] > 0) {
    self.creditCardType = [type objectAtIndex:0];
  } else {
    DebugLog(@"WARNING: Credit Card Type '%@' not found", pDisplayName);
  }
}

- (NSString *)creditCardTypeDisplayName {
  return [typesToDisplayNames objectForKey:self.creditCardType];
}

- (NSString *)formattedAmount {
  if(!self.priceFormatter) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.currencyCode];
    self.priceFormatter = formatter;
  }
  return [self.priceFormatter stringFromNumber:self.amount];
}

- (NSString *)multiLineDescription {
  return [NSString stringWithFormat:@"%@ %@ - %@/%@\n\n%@ %@\n%@\n%@, %@ %@\n%@\n%@", self.creditCardTypeDisplayName, self.maskedCreditCardNumber, self.expirationMonth, self.expirationYear, self.billingAddress.firstName, self.billingAddress.lastName, self.billingAddress.address1, self.billingAddress.city, self.billingAddress.state, self.billingAddress.postalCode, self.billingAddress.country, self.billingAddress.phoneNumber];
}

@end