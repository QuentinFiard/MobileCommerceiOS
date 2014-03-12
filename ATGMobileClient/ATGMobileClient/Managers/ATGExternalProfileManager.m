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


#import "ATGExternalProfileManager.h"
#import "ATGGiftListManager.h"
#import "ATGProfileManagerRequest.h"
#import "ATGOrder.h"
#import "ATGProfile.h"

static ATGExternalProfileManager *profileManager;


@implementation ATGExternalProfileManager {

}

+ (ATGExternalProfileManager *)profileManager {
  static dispatch_once_t pred_externalprofile_manager;
  dispatch_once(&pred_externalprofile_manager,
                ^{
                  profileManager = [[ATGExternalProfileManager alloc] init];
                  profileManager.getProfileActorChain = ATG_PROFILE_ACTOR_PATH;
                }
                );
  return profileManager;
}

- (ATGProfileManagerRequest *) updatePersonalInformation:(ATGProfile *)pPersonalInfo
                                            withOldEmail:(NSString *)pEmailAddress
                                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL updateErrorSelector = @selector(didErrorUpdatingPersonalInformation:);
  SEL updateSelector = @selector(didUpdatePersonalInformation:);
  DebugLog(@"Updating personal info...");

  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  if (pPersonalInfo.dateOfBirth != nil) {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:[pPersonalInfo dateOfBirth]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    [params setValue:@([dateComponents day]) forKey:@"date"];
    [params setValue:@([dateComponents month] - 1) forKey:@"month"];
    [params setValue:@([dateComponents year]) forKey:@"year"];
  }
  
  [params setValue:[NSNumber numberWithBool:[pPersonalInfo receivePromoEmail]] forKey:@"emailOptIn"];
  [params setValue:[NSNumber numberWithBool:[pPersonalInfo previousOptInStatus]] forKey:@"previousOptInStatus"];
  [params setValue:[pPersonalInfo email] forKey:@"email"];
  [params setValue:[pPersonalInfo firstName] forKey:@"firstName"];
  [params setValue:[pPersonalInfo lastName] forKey:@"lastName"];
  [params setValue:[pPersonalInfo phoneNumber] forKey:@"phoneNumber"];
  [params setValue:[pPersonalInfo postalCode] forKey:@"postalCode"];
  [params setValue:[pPersonalInfo gender] forKey:@"gender"];

  [self clearCachedProfile];

  id <ATGRestOperation> operation = [self.restManager.restSession
                                     executePostRequestForActorPath:ATG_PROFILE_EDIT_ACTOR_PATH
                                     parameters:params
                                     requestFactory:nil
                                     options:ATGRestRequestOptionNone
                                     success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:updateErrorSelector]) {
                                         DebugLog(@"Personal Information Updated.");
                                         [self clearCachedProfile];
                                         //ATGProfile *personalInfo1 = [self.profileCache getItemFromCacheWithID:ATG_PERSONAL_INFO_OBJECT_CACHE_NAME];
                                         //ATGProfile *profile1 = [self.profileCache getItemFromCacheWithID:ATG_PROFILE_OBJECT_CACHE_NAME];

                                         ATGProfile *profile = (ATGProfile *)[ATGProfile objectFromDictionary:[pResponseObject objectForKey:@"profile"]];
                                         [self.profileCache insertItemIntoCache:profile withID:ATG_PROFILE_OBJECT_CACHE_NAME];
                                         [profileRequest setRequestResults:profile];
                                         [profileRequest sendResponse:updateSelector];
                                       }
                                     }
                                     failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                         DebugLog(@"Error updating personal information: %@", pError);
                                         error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:updateErrorSelector];
                                     }
                                     ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) createNewUser:(ATGProfile *)pPersonalInfo
                              additionalInfo:(NSDictionary *)pAddInfo
                                    delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  return [self createNewUser:pPersonalInfo additionalInfo:pAddInfo duringCheckout:NO delegate:pDelegate];
}

- (ATGProfileManagerRequest *) createNewUser:(ATGProfile *)pPersonalInfo additionalInfo:(NSDictionary *)pAddInfo
                       duringCheckout:(BOOL)pDuringCheckout
                             delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL createErrorSelector = @selector(didErrorCreatingNewUser:);
    SEL createSelector = @selector(didCreateNewUser:);
    DebugLog(@"Creating new User.");

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[NSNumber numberWithBool:false] forKey:@"extractDefaultValuesFromProfile"];
    [params setValue:[NSNumber numberWithBool:false] forKey:@"createNewUser"];
    [params setValue:[NSNumber numberWithBool:true] forKey:@"member"];
    [params setValue:@"promo from registration" forKey:@"sourceCode"];
    [params setValue:[NSNumber numberWithBool:true] forKey:@"autoLogin"];
    [params setValue:[pPersonalInfo email] forKey:@"email"];
    [params setValue:[pPersonalInfo firstName] forKey:@"firstName"];
    [params setValue:[pPersonalInfo lastName] forKey:@"lastName"];
    [params setValue:[pPersonalInfo password] forKey:@"password"];
    [params setValue:[NSNumber numberWithBool:true] forKey:@"isConfirmPassword"];
    [params setValue:[pAddInfo objectForKey:@"confirmPassword"] forKey:@"checkPassword"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"M/d/yyyy"];
      NSDate *birthDate = [dateFormatter dateFromString:[pAddInfo objectForKey:@"dateOfBirth"]];
      if (birthDate != nil) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                       fromDate:birthDate];
        [params setValue:@([dateComponents day]) forKey:@"date"];
        [params setValue:@([dateComponents month] - 1) forKey:@"month"];
        [params setValue:@([dateComponents year]) forKey:@"year"];
      }

      [params setValue:[pAddInfo objectForKey:@"postalCode"]  forKey:@"postalCode"];
      [params setValue:[[pAddInfo objectForKey:@"gender"] lowercaseString] forKey:@"gender"];
      [params setValue:[pAddInfo objectForKey:@"referralSource"] forKey:@"referralSource"];
    }

    [self clearAllCache];

    NSString *actorName = pDuringCheckout ? ATG_CHECKOUT_CREATE_USER_ACTOR_PATH : ATG_CREATE_USER_ACTOR_PATH;

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:actorName
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:createErrorSelector]) {
                                           DebugLog(@"User Registration succeeded.");
                                           [[ATGGiftListManager instance] clearCaches];
                                           [self clearAllCache];
                                           [profileRequest sendResponse:createSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error creating new user: %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:createErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) getOrderDetails:(NSString *)pOrderId
                               delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL getErrorSelector = @selector(didErrorGettingOrderDetails:);
    SEL getSelector = @selector(didGetOrderDetails:);
    DebugLog(@"Requesting order details for order %@.", pOrderId);

    ATGOrder *order = [self.cachedOrders getItemFromCacheWithID:pOrderId];
    if (order != NULL) {
        profileRequest.requestResults = order;
        if ([profileRequest.delegate respondsToSelector:getSelector]) {
            [profileRequest.delegate performSelectorOnMainThread:getSelector withObject:profileRequest waitUntilDone:NO];
        }
        return profileRequest;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pOrderId forKey:@"orderId"];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_ORDER_DETAILS_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:getErrorSelector]) {
                                           DebugLog(@"Got valid order response from server");
                                           ATGOrder *order = (ATGOrder *)[ATGOrder objectFromDictionary:[pResponseObject objectForKey:@"result"]];
                                           [self.cachedOrders insertItemIntoCache:order withID:order.orderId];
                                           [profileRequest setRequestResults:order];
                                           [profileRequest sendResponse:getSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       DebugLog(@"Server returned error when trying to get order details: %@", pError);
                                       [profileRequest sendError:pError withSelector:getErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) getOrdersStartingAt:(NSNumber *)pStart
                                  andReturn:(NSNumber *)pHowMany
                                   delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL getErrorSelector = @selector(didErrorGettingOrdersStartingAt:);
    SEL getSelector = @selector(didGetOrdersStartingAt:);
    DebugLog( @"Requesting orders from %d to %d", [pStart intValue], ([pStart intValue] + [pHowMany intValue]) );

    NSArray *cachedOrders = [self.cachedListofOrders getItemsFromCacheWithStartIndex:[pStart intValue] howMany:[pHowMany intValue]];

    if (cachedOrders) {
        profileRequest.requestResults = cachedOrders;
        [profileRequest sendResponse:getSelector];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@([pStart integerValue] - 1) forKey:@"startIndex"];
        [params setValue:pHowMany forKey:@"howMany"];
        [params setValue:@"true" forKey:@"short"];

        id <ATGRestOperation> operation = [self.restManager.restSession
                executePostRequestForActorPath:ATG_ORDERS_LIST_ACTOR_PATH
                                    parameters:params
                                requestFactory:nil
                                       options:ATGRestRequestOptionNone
                                       success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                           NSError *error = [ATGRestManager checkForError:pResponseObject];
                                           if (![profileRequest sendError:error withSelector:getErrorSelector]) {
                                               DebugLog(@"Got orders response: %@", pResponseObject);
                                               NSArray *receivedOrders = [ATGOrder objectsFromArray:[pResponseObject objectForKey:@"myOrders"]];
                                               [self.cachedListofOrders insertItemsIntoCache:receivedOrders startIndex:[pStart intValue]];
                                               profileRequest.requestResults = receivedOrders;
                                               [profileRequest sendResponse:getSelector];
                                           }
                                       }
                                       failure: ^(id <ATGRestOperation> pRperation, NSError *pError) {
                                           DebugLog(@"Server returned error while trying retrieve list of orders: %@", pError);
                                           [profileRequest sendError:pError withSelector:getErrorSelector];
                                       }
        ];

        profileRequest.operation = operation;
    }

    return profileRequest;
}

- (ATGProfileManagerRequest *) getAddresses:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL getErrorSelector = @selector(didErrorGettingAddresses:);
    SEL getSelector = @selector(didGetAddresses:);
    DebugLog(@"Requesting Addresses.");

    NSArray *addresses = [self.profileCache getItemFromCacheWithID: ATG_CACHED_ADDRESS_LIST_OBJECT_CACHE_NAME];
    if (addresses != NULL) {
        profileRequest.requestResults = addresses;
        if ([profileRequest.delegate respondsToSelector:getSelector]) {
            [profileRequest.delegate performSelectorOnMainThread:getSelector withObject:profileRequest waitUntilDone:NO];
        }
        return profileRequest;
    }

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_ADDRESSES_LIST_ACTOR_PATH
                                parameters:nil
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:getErrorSelector]) {
                                           DebugLog(@"Got valid address list response from server.");
                                           NSArray *addresses = [ATGContactInfo namedObjectsFromDictionary:[pResponseObject objectForKey:@"addresses"] defaultObjectID:[pResponseObject objectForKey:@"defaultShippingAddressId"]];
                                           [self.profileCache insertItemIntoCache:addresses withID: ATG_CACHED_ADDRESS_LIST_OBJECT_CACHE_NAME];
                                           [profileRequest setRequestResults:addresses];
                                           [profileRequest sendResponse:getSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       DebugLog(@"Server returned error when trying to get the list of addresses: %@", pError);
                                       [profileRequest sendError:pError withSelector:getErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) updateAddress:(ATGContactInfo *)pAddress
                             delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL updateErrorSelector = @selector(didErrorUpdatingAddress:);
    SEL updateSelector = @selector(didUpdateAddress:);
    DebugLog(@"Updating address with nickname %@.", pAddress.nickname);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:[pAddress dictionaryFromObject]];
    [params setValue:[NSNumber numberWithBool:[pAddress useShippingAddressAsDefault]] forKey:@"useShippingAddressAsDefault"];

    [self clearCachedListofAddresses];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_ADDRESS_EDIT_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:updateErrorSelector]) {
                                           DebugLog(@"Address Updated.");
                                           [self clearCachedListofAddresses];
                                           [profileRequest sendResponse:updateSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error updating address: %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:updateErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) createNewAddress:(ATGContactInfo *)pAddress
                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    pAddress.nickname = pAddress.newNickname;
    pAddress.newNickname = nil;
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL createErrorSelector = @selector(didErrorCreatingNewAddress:);
    SEL createSelector = @selector(didCreateNewAddress:);
    DebugLog(@"Creating a new address with nickname %@", pAddress.nickname);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:[pAddress dictionaryFromObject]];
    [params setValue:[NSNumber numberWithBool:[pAddress useShippingAddressAsDefault]] forKey:@"useShippingAddressAsDefault"];

    [self clearCachedListofAddresses];
    [self clearCachedProfile];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_ADDRESS_CREATE_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:createErrorSelector]) {
                                           DebugLog(@"Address Created.");
                                           [self clearCachedListofAddresses];
                                           [self clearCachedProfile];
                                           [profileRequest sendResponse:createSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error creating address: %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:createErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) removeAddress:(NSString *)pNickName
                             delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL removeErrorSelector = @selector(didErrorCreatingNewAddress:);
    SEL removeSelector = @selector(didCreateNewAddress:);
    DebugLog(@"Removing Address with nickname %@.", pNickName);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pNickName forKey:@"removeAddress"];

    [self clearCachedListofAddresses];
    [self clearCachedProfile];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_ADDRESS_REMOVE_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:removeErrorSelector]) {
                                           DebugLog(@"Address Removed.");
                                           [self clearCachedListofAddresses];
                                           [self clearCachedProfile];
                                           [profileRequest sendResponse:removeSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error removing address: %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:removeErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) getCreditCards:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL getErrorSelector = @selector(didErrorGettingCreditCards:);
    SEL getSelector = @selector(didGetCreditCards:);
    DebugLog(@"Requesting Credit Cards.");

    NSArray *creditCards = [self.profileCache getItemFromCacheWithID:ATG_CACHED_CREDIT_CARD_LIST_OBJECT_CACHE_NAME];
    if (creditCards != NULL) {
        profileRequest.requestResults = creditCards;
        if ([profileRequest.delegate respondsToSelector:getSelector]) {
            [profileRequest.delegate performSelectorOnMainThread:getSelector withObject:profileRequest waitUntilDone:NO];
        }
        return profileRequest;
    }

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_LIST_ACTOR_PATH
                                parameters:nil
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:getErrorSelector]) {
                                           DebugLog(@"Got valid credit card list response from server.");
                                           NSArray *creditCards = [ATGCreditCard namedObjectsFromDictionary:[pResponseObject objectForKey:@"creditCards"]
                                                                                            defaultObjectID:[pResponseObject objectForKey:@"defaultCreditCardId"]];
                                           [self.profileCache insertItemIntoCache:creditCards withID:ATG_CACHED_CREDIT_CARD_LIST_OBJECT_CACHE_NAME];
                                           [profileRequest setRequestResults:creditCards];
                                           [profileRequest sendResponse:getSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       DebugLog(@"Server returned error when trying to get the list of credit cards: %@", pError);
                                       [profileRequest sendError:pError withSelector:getErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) removeCreditCard:(NSString *)pNickName
                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] init];
    profileRequest.delegate = pDelegate;
    SEL removeErrorSelector = @selector(didErrorRemovingCreditCard:);
    SEL removeSelector = @selector(didRemoveCreditCard:);
    DebugLog(@"Removing card with nickname %@.", pNickName);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pNickName forKey:@"removeCard"];

    [self clearCachedListofCreditCards];
    [self clearCachedProfile];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_REMOVE_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:removeErrorSelector]) {
                                           DebugLog(@"Credit Card Removed.");
                                           [self clearCachedListofCreditCards];
                                           [self clearCachedProfile];
                                           [profileRequest sendResponse:removeSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error removing credit card: %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:removeErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) updateCreditCard:(ATGCreditCard *)pCreditCard
                            useAsDefault:(BOOL)pDefault
                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL updateErrorSelector = @selector(didErrorUpdatingCreditCard:);
    SEL updateSelector = @selector(didUpdateCreditCard:);
    DebugLog(@"Updating credit Card with nickname: %@.", [pCreditCard nickname]);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[[pCreditCard billingAddress] dictionaryFromObject]];
    [params setValue:[pCreditCard nickname] forKey:@"nickname"];
    [params setValue:[pCreditCard newNickname] forKey:@"newNickname"];
    [params setValue:[pCreditCard expirationYear] forKey:@"expirationYear"];
    [params setValue:[NSNumber numberWithInteger:[[pCreditCard expirationMonth] integerValue]] forKey:@"expirationMonth"];
    [params setValue:[NSNumber numberWithBool:pDefault] forKey:@"setAsDefault"];
    [self clearCachedListofCreditCards];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_UPDATE_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:updateErrorSelector]) {
                                           DebugLog(@"Credit Card updated.");
                                           [self clearCachedListofCreditCards];
                                           [profileRequest sendResponse:updateSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error updating credit card %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:updateErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) validateNewCreditCard:(ATGCreditCard *)pCreditCard save:(BOOL)pSave useAsDefault:(BOOL)pDefault
                                     delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL validateErrorSelector = @selector(didErrorValidatingNewCreditCard:);
    SEL validateSelector = @selector(didValidateNewCreditCard:);
    DebugLog(@"Requesting Validation of Credit Card.");

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[pCreditCard nickname] forKey:@"creditCardNickname"];
    [params setValue:[pCreditCard creditCardNumber] forKey:@"creditCardNumber"];
    [params setValue:[pCreditCard creditCardType] forKey:@"creditCardType"];
    [params setValue:[pCreditCard expirationYear] forKey:@"expirationYear"];
    [params setValue:[NSNumber numberWithInteger:[[pCreditCard expirationMonth] integerValue]] forKey:@"expirationMonth"];
    [params setValue:[NSNumber numberWithBool:pSave] forKey:@"saveCreditCard"];
    [params setValue:[NSNumber numberWithBool:pDefault] forKey:@"newCreditCard"];

    [self clearCachedListofCreditCards];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_VALIDATE_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:validateErrorSelector]) {
                                           DebugLog(@"Credit Card validated.");
                                           [self clearCachedListofCreditCards];
                                           [profileRequest sendResponse:validateSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error validating credit card %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:validateErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) selectAddressAndCreateCreditCard:(NSString *)pSelectedAddress
                                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL selectErrorSelector = @selector(didErrorSelectingAddressAndCreatingCreditCard:);
    SEL selectSelector = @selector(didSelectAddressAndCreateCreditCard:);
    DebugLog(@"Selecting address %@ to create new card.", pSelectedAddress);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:pSelectedAddress forKey:@"selectedBillingAddress"];

    [self clearCachedListofCreditCards];
    [self clearCachedProfile];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_BILLING_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:selectErrorSelector]) {
                                           DebugLog(@"Address Selected and credit card created.");
                                           [self clearCachedListofCreditCards];
                                           [self clearCachedProfile];
                                           [profileRequest sendResponse:selectSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error selecting address to credit card %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:selectErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) createAddressAndCreateCreditCard:(ATGContactInfo *)pAddress
                                                delegate:(id <ATGProfileManagerDelegate>)pDelegate {
    pAddress.nickname = pAddress.newNickname;
    pAddress.newNickname = nil;
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL createErrorSelector = @selector(didErrorCreatingAddressAndCreatingCreditCard:);
    SEL createSelector = @selector(didCreateAddressAndCreateCreditCard:);
    DebugLog(@"Creating address to create new card.");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[pAddress dictionaryFromObject]];

    [self clearCachedListofCreditCards];
    [self clearCachedProfile];

    id <ATGRestOperation> operation = [self.restManager.restSession
            executePostRequestForActorPath:ATG_CREDIT_CARD_CREATE_BILLING_ACTOR_PATH
                                parameters:params
                            requestFactory:nil
                                   options:ATGRestRequestOptionNone
                                   success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       NSError *error = [ATGRestManager checkForError:pResponseObject];
                                       if (![profileRequest sendError:error withSelector:createErrorSelector]) {
                                           DebugLog(@"Address created and credit card Added.");
                                           [self clearCachedListofCreditCards];
                                           [self clearCachedProfile];
                                           [profileRequest sendResponse:createSelector];
                                       }
                                   }
                                   failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       NSError *error;
                                       if (pError) {
                                           DebugLog(@"Error selecting address to credit card %@", pError);
                                           error = pError;
                                       }
                                       [profileRequest sendError:error withSelector:createErrorSelector];
                                   }
    ];

    profileRequest.operation = operation;

    return profileRequest;
}

- (ATGProfileManagerRequest *) becomeAnonymous:(id <ATGProfileManagerDelegate>)pDelegate {
    ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
    profileRequest.delegate = pDelegate;
    SEL becomeErrorSelector = @selector(didErrorBecomingAnonymous:);
    SEL becomeSelector = @selector(didBecomeAnonymous:);
    DebugLog(@"Requesting to become an Anonymous user");
    
    id <ATGRestOperation> operation = [self.restManager.restSession
                                       executePostRequestForActorPath:ATG_SKIP_LOGIN_ACTOR_PATH
                                       parameters:nil
                                       requestFactory:nil
                                       options:ATGRestRequestOptionNone
                                       success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                           NSError *error = [ATGRestManager checkForError:pResponseObject];
                                           if (![profileRequest sendError:error withSelector:becomeErrorSelector]) {
                                               DebugLog(@"Got valid order response from server");
                                               [ATGRestManager restManager].restSession.userId = nil;
                                               [profileRequest sendResponse:becomeSelector];
                                           }
                                       }
                                       failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                           DebugLog(@"Server returned error while trying to become anonymous: %@", pError);
                                           [profileRequest sendError:pError withSelector:becomeErrorSelector];
                                       }
                                       ];
    
    profileRequest.operation = operation;
    
    return profileRequest;
}

@end