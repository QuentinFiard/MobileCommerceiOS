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
#import "ATGCreditCardValidator.h"
#import <ATGUIElements/ATGInputValidator.h>

#pragma mark - ATGCreditCardValidator implementation
#pragma mark -

@implementation ATGCreditCardValidator
@synthesize cardInformation;

+ (id) sharedCardValidator {
  static ATGCreditCardValidator *sharedCardValidator = nil;
  static dispatch_once_t pred_card_validator;

  if (sharedCardValidator) {
    return sharedCardValidator;
  }

  dispatch_once(&pred_card_validator, ^{
                  sharedCardValidator = [[ATGCreditCardValidator alloc] init];

                  NSPropertyListFormat format;
                  NSString *errorDesc = nil;

                  //serialize data dictionary from plist
                  NSString *plistPath = [[NSBundle atgResourceBundle] pathForResource:@"ValidationCardInfo" ofType:@"plist"];
                  NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
                  NSDictionary *cardInfoDict = (NSDictionary *)[NSPropertyListSerialization
                                                                propertyListFromData:plistXML
                                                                    mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                              format:&format
                                                                    errorDescription:&errorDesc];

                  NSArray *cardInfoArray = [cardInfoDict objectForKey:@"Root"];

                  NSMutableDictionary *cardDictionary = [[NSMutableDictionary alloc] init];

                  //create and populate ATGModelCard classes with data from dictionary
                  for (int i = 0; i < [cardInfoArray count]; i++) {
                    NSDictionary *cardInfo = [cardInfoArray objectAtIndex:i];

                    BOOL checkdigit = [[cardInfo objectForKey:@"checkdigit"] boolValue];
                    NSArray *length = [cardInfo objectForKey:@"length"];
                    NSArray *prefixes = [cardInfo objectForKey:@"prefixes"];

                    ATGModelCard *card = [[ATGModelCard alloc] initWithLength:length prefixes:prefixes checkdigit:checkdigit];

                    NSString *type = [cardInfo objectForKey:@"type"];

                    [cardDictionary setObject:card forKey:type];
                  }
                  //and card to card's dictionary
                  sharedCardValidator.cardInformation = [NSDictionary dictionaryWithDictionary:cardDictionary];
                }
                );

  return sharedCardValidator;
}

- (NSError *) validateCreditCard:(NSString *)pCard number:(NSString *)pCardNumber {
  if ([pCardNumber length] == 0) {
    NSString *errorMessage = NSLocalizedStringWithDefaultValue(
      @"ATGCreditCardValidator.ErrorMessageEmptyCreditCardNumber", nil, [NSBundle mainBundle],
      @"Needed",
      @"Error message to be returned if no credit card number is provided.");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                         forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:ATGInputValidatorErrorDomain
                                         code:-1 userInfo:userInfo];
    return error;
  }

  ATGModelCard *creditCard = [self.cardInformation objectForKey:pCard];

  if (creditCard.checkdigit) {
    int sum = 0;
    int j = 1;
    int calc;

    // Now check the modulus 10 check digit - if required
    for (int i = [pCardNumber length] - 1; i >= 0; i--) {
      NSString *cardChar = [NSString stringWithFormat:@"%C", [pCardNumber characterAtIndex:i]];

      calc = [cardChar intValue] * j;
      if (calc > 9) {
        sum = sum + 1;
        calc = calc - 10;
      }
      sum = sum + calc;
      if (j == 1) {
        j = 2;
      } else {
        j = 1;
      }
    }
    if (sum % 10 != 0) {
      NSString *errorMessage = NSLocalizedStringWithDefaultValue(
        @"ATGCreditCardValidator.ErrorMessageWrongNumber", nil, [NSBundle mainBundle],
        @"Invalid card number",
        @"Error message to be returned, if credit card number is wrong.");
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:ATGInputValidatorErrorDomain
                                           code:-1 userInfo:userInfo];
      return error;
    }

    //validate prefix for this card
    BOOL PrefixValid = NO;

    for (int i = 0; i < [creditCard.prefixes count]; i++) {
      NSString *prefix = [creditCard.prefixes objectAtIndex:i];

      NSRange range = {
        0, [prefix length]
      };
      NSString *beginOfNumber = [pCardNumber substringWithRange:range];

      if ([beginOfNumber isEqualToString:prefix]) {
        PrefixValid = YES;
      }
    }

    if (!PrefixValid) {
      NSString *errorMessage = NSLocalizedStringWithDefaultValue(
        @"ATGCreditCardValidator.InvalidType", nil, [NSBundle mainBundle],
        @"Number does not match type",
        @"Error message to be returned, if number does not match type.");
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:ATGInputValidatorErrorDomain
                                           code:-1 userInfo:userInfo];
      return error;
    }

    //validate length card number for this card
    BOOL LengthValid = NO;

    for (int i = 0; i < [creditCard.length count]; i++) {
      NSNumber *validLength = [creditCard.length objectAtIndex:i];
      if ([pCardNumber length] == [validLength intValue]) {
        LengthValid = YES;
      }
    }

    if (!LengthValid) {
      NSString *errorMessage = NSLocalizedStringWithDefaultValue(
        @"ATGCreditCardValidator.InvalidLength", nil, [NSBundle mainBundle],
        @"Incorrect number length",
        @"Error message to be returned, if number length does not match type.");
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:ATGInputValidatorErrorDomain
                                           code:-1 userInfo:userInfo];
      return error;
    }
  }
  return nil;
}

@end