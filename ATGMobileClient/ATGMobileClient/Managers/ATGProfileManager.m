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

#import "ATGProfileManager.h"
#import <ATGMobileCommon/ATGMemoryCache.h>
#import "ATGGiftListManager.h"
#import "ATGCommerceManager.h"
#import "ATGProfileManagerRequest.h"
#import "ATGProfile.h"

@interface ATGProfileManager ()

@end

@implementation ATGProfileManager

static NSTimeInterval const ATG_PROFILE_CACHE_TIME_OUT_SEC = 120;
static NSUInteger const ATG_PROFILE_CACHE_SIZE_LIMIT = 50;
NSUInteger const ATG_ORDER_PAGE_SIZE = 10;
static NSString *const ATG_PROFILE_CACHE_NAME = @"profileCache";
NSString *const ATG_PROFILE_OBJECT_CACHE_NAME = @"profile";
static NSString *const ATG_CACHED_ORDER_OBJECT_CACHE_NAME = @"cachedOrders";
static NSString *const ATG_CACHED_ORDER_LIST_OBJECT_CACHE_NAME = @"cachedListofOrders";
NSString *const ATG_CACHED_ADDRESS_LIST_OBJECT_CACHE_NAME = @"cachedListofAddresses";
NSString *const ATG_CACHED_CREDIT_CARD_LIST_OBJECT_CACHE_NAME = @"cachedListofCreditCards";
NSString *const ATGProfileManagerErrorDomain = @"com.atg.ATGProfileManager";

#pragma mark - Actor consts
NSString *const ATG_PROFILE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/summary";
NSString *const ATG_ADDRESSES_LIST_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/addresses";
NSString *const ATG_ORDERS_LIST_ACTOR_PATH = @"/atg/commerce/order/OrderLookupActor/orderHistory";
NSString *const ATG_ORDER_DETAILS_ACTOR_PATH = @"/atg/commerce/order/OrderLookupActor/orderLookup";
NSString *const ATG_CREDIT_CARD_REMOVE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/removeCreditCard";
NSString *const ATG_CREDIT_CARD_LIST_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/creditCards";
NSString *const ATG_ADDRESS_EDIT_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/updateAddress";
NSString *const ATG_ADDRESS_REMOVE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/removeAddress";
NSString *const ATG_ADDRESS_CREATE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/newAddress";
NSString *const ATG_PROFILE_EDIT_ACTOR_PATH = @"/atg/store/profile/RegistrationActor/updateUser";
NSString *const ATG_RESET_PASSWORD_ACTOR_PATH = @"/atg/userprofiling/ForgotPasswordActor/resetPassword";
NSString *const ATG_SKIP_LOGIN_ACTOR_PATH = @"/atg/store/profile/CheckoutProfileActor/skipLogin";
NSString *const ATG_CHANGE_PASSWORD_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/changePassword";
NSString *const ATG_SECURITY_STATUS_ACTOR_PATH = @"/atg/userprofiling/SecurityStatusActor/status";
NSString *const ATG_CHECKOUT_CREATE_USER_ACTOR_PATH = @"/atg/store/profile/RegistrationActor/createUser";
NSString *const ATG_CREATE_USER_ACTOR_PATH = @"/atg/store/profile/RegistrationActor/createUser";
NSString *const ATG_CREDIT_CARD_UPDATE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/updateCreditCard";
NSString *const ATG_CREDIT_CARD_VALIDATE_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/createNewCreditCard";
NSString *const ATG_CREDIT_CARD_BILLING_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/selectBillingAddress";
NSString *const ATG_CREDIT_CARD_CREATE_BILLING_ACTOR_PATH = @"/atg/userprofiling/ProfileActor/createCardAndAddress";

@synthesize restManager = _restManager;

//Private variables
@synthesize profileCache = _profileCache,
cachedOrders = _cachedOrders,
cachedListofOrders = _cachedListofOrders;

- (id) init {
  self = [super init];
  if (self) {
    //In case actions in other managers need us to clear this stuff out
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCachedListofCreditCards) name:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCachedListofAddresses) name:ATG_CLEAR_PROFILE_ADDRESS_CACHE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCachedProfile) name:ATG_CLEAR_PROFILE_CACHE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearCachedListofOrders)
                                                 name:ATG_CLEAR_CACHED_ORDERS_NOTIFICATION
                                               object:nil];

    //Cache Initialization
    _profileCache = [[ATGMemoryCache alloc] initWithCacheName:ATG_PROFILE_CACHE_NAME sizeLimit:ATG_PROFILE_CACHE_SIZE_LIMIT expiryTime:ATG_PROFILE_CACHE_TIME_OUT_SEC];
    _cachedOrders = [[ATGMemoryCache alloc] initWithCacheName:ATG_CACHED_ORDER_OBJECT_CACHE_NAME sizeLimit:ATG_PROFILE_CACHE_SIZE_LIMIT expiryTime:ATG_PROFILE_CACHE_TIME_OUT_SEC];
    _cachedListofOrders = [[ATGPagingMemoryCache alloc] initWithCacheName:ATG_CACHED_ORDER_LIST_OBJECT_CACHE_NAME sizeLimit:ATG_ORDER_PAGE_SIZE expiryTime:ATG_PROFILE_CACHE_TIME_OUT_SEC];
  }

  return self;
}

+ (ATGProfileManager *) profileManager {
  NSAssert(NO, @"Subclass Hook, implement your own singleton accessor");
  return nil;
}

- (ATGRestManager *) restManager {
  if (!_restManager) {
    _restManager = [ATGRestManager restManager];
  }
  return _restManager;
}

- (ATGProfileManagerRequest *) login:(NSString *)pLogin withPassword:(NSString *)pPassword
                            delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL loginErrorSelector = @selector(didErrorLoggingIn:);
  SEL loginSelector = @selector(didLogIn:);
  DebugLog(@"Logging In as %@.", pLogin);

  [self.restManager.restSession setUsername:pLogin];
  [self.restManager.restSession setPassword:pPassword];

  [self clearAllCache];

  id <ATGRestOperation> operation = [self.restManager.restSession login:nil options:ATGRestRequestOptionNone success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
    NSError *error = [ATGRestManager checkForError:pResponseObject];
    if (![profileRequest sendError:error withSelector:loginErrorSelector]) {
      DebugLog(@"Login Success");
      [[ATGGiftListManager instance] clearCaches];
      [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:nil];
      [profileRequest setRequestResults:pResponseObject];
      [profileRequest sendResponse:loginSelector];
    }
  }
                                                                failure: ^(id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions) {
                                                                  DebugLog(@"Server returned error when trying to login %@", pError);
                                                                  [profileRequest sendError:pError withSelector:loginErrorSelector];
                                                                }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (ATGProfileManagerRequest *) logout:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL logoutErrorSelector = @selector(didErrorLoggingOut:);
  SEL logoutSelector = @selector(didLogOut:);
  DebugLog(@"Logging Out");

  [self clearAllCache];

  id <ATGRestOperation> operation = [self.restManager.restSession logout:nil options:(ATGRestRequestOptionNone) success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
    NSError *error = [ATGRestManager checkForError:pResponseObject];
    if (![profileRequest sendError:error withSelector:logoutErrorSelector]) {
      DebugLog(@"Logout Success");
      [[ATGGiftListManager instance] clearCaches];
      [[NSNotificationCenter defaultCenter] postNotificationName:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:nil];
      [[NSNotificationCenter defaultCenter]
              postNotificationName:ATG_SHOPPING_CART_ITEMS_CHANGED_NOTIFICATION
                            object:self
                          userInfo:@{ATG_SHOPPING_CART_ITEMS_NUMBER_KEY: @0}];
      [profileRequest sendResponse:logoutSelector];
    }
  }
                                                                 failure: ^(id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions) {
                                                                   DebugLog(@"Server returned error when trying to logout %@", pError);
                                                                   [profileRequest sendError:pError withSelector:logoutErrorSelector];
                                                                 }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (ATGProfileManagerRequest *) getProfile:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL getProfileErrorSelector = @selector(didErrorGettingProfile:);
  SEL getProfileSelector = @selector(didGetProfile:);
  DebugLog(@"Requesting Profile.");

  ATGProfile *profile = [self.profileCache getItemFromCacheWithID:ATG_PROFILE_OBJECT_CACHE_NAME];
  if (profile != NULL) {
    profileRequest.requestResults = profile;
    if ([profileRequest.delegate respondsToSelector:getProfileSelector]) {
      [profileRequest.delegate performSelectorOnMainThread:getProfileSelector withObject:profileRequest waitUntilDone:NO];
    }
    return profileRequest;
  }

  id <ATGRestOperation> operation = [self.restManager.restSession
          executePostRequestForActorPath:self.getProfileActorChain
                              parameters:nil
                          requestFactory:nil
                                 options:ATGRestRequestOptionNone
                                 success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                   NSError *error = [ATGRestManager checkForError:pResponseObject];
                                   if (![profileRequest sendError:error withSelector:getProfileErrorSelector]) {
                                     DebugLog(@"Got valid profile response from server");
                                     ATGProfile *profile = (ATGProfile *)[ATGProfile objectFromDictionary:[pResponseObject objectForKey:@"profile"]];
                                     [self.profileCache insertItemIntoCache:profile withID:ATG_PROFILE_OBJECT_CACHE_NAME];
                                     [profileRequest setRequestResults:profile];
                                     [profileRequest sendResponse:getProfileSelector];
                                   }
                                 }
                                 failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                   DebugLog(@"Server returned error when trying to get the Profile: %@", pError);
                                   [profileRequest sendError:pError withSelector:getProfileErrorSelector];
                                 }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (ATGProfileManagerRequest *) changePassword:(NSString *)pOldPassword
                          withConfirmPassword:(NSString *)pConfirmPassword
                              withNewPassword:(NSString *)pNewPassword
                                     delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL changeErrorSelector = @selector(didErrorChangingPassword:);
  SEL changeSelector = @selector(didChangePassword:);
  DebugLog(@"Requesting Password change.");

  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:[NSNumber numberWithBool:true] forKey:@"isConfirmPassword"];
  [params setValue:pConfirmPassword forKey:@"confirmPassword"];
  [params setValue:pOldPassword forKey:@"oldPassword"];
  [params setValue:pNewPassword forKey:@"password"];

  id <ATGRestOperation> operation = [self.restManager.restSession
          executePostRequestForActorPath:ATG_CHANGE_PASSWORD_ACTOR_PATH
                              parameters:params
                          requestFactory:nil
                                 options:ATGRestRequestOptionNone
                                 success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                   NSError *error = [ATGRestManager checkForError:pResponseObject];
                                   if (![profileRequest sendError:error withSelector:changeErrorSelector]) {
                                     DebugLog(@"Password Changed.");
                                     [profileRequest sendResponse:changeSelector];
                                   }
                                 }
                                 failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                   NSError *error;
                                   if (pError) {
                                     DebugLog(@"Server returned error while trying to change password: %@", pError);
                                     error = pError;
                                   }
                                   [profileRequest sendError:error withSelector:changeErrorSelector];
                                 }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (ATGProfileManagerRequest *) resetPassword:(NSString *)pEmailAddress
                                    delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL resetErrorSelector = @selector(didErrorResettingPassword:);
  SEL resetSelector = @selector(didResetPassword:);
  DebugLog(@"Resetting Password.");

  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:pEmailAddress forKey:@"email"];

  id <ATGRestOperation> operation = [self.restManager.restSession
          executePostRequestForActorPath:ATG_RESET_PASSWORD_ACTOR_PATH
                              parameters:params
                          requestFactory:nil
                                 options:ATGRestRequestOptionNone
                                 success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                   NSError *error = [ATGRestManager checkForError:pResponseObject];
                                   if (![profileRequest sendError:error withSelector:resetErrorSelector]) {
                                     DebugLog(@"Password Reset.");
                                     [profileRequest sendResponse:resetSelector];
                                   }
                                 }
                                 failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                   NSError *error;
                                   if (pError) {
                                     DebugLog(@"Server returned error while trying to reset password: %@", pError);
                                     error = pError;
                                   }
                                   [profileRequest sendError:error withSelector:resetErrorSelector];
                                 }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (ATGProfileManagerRequest *) getSecurityStatus:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL getErrorSelector = @selector(didErrorGettingSecurityStatus:);
  SEL getSelector = @selector(didGetSecurityStatus:);
  DebugLog(@"Requesting security status.");

  id <ATGRestOperation> operation = [self.restManager.restSession
          executePostRequestForActorPath:ATG_SECURITY_STATUS_ACTOR_PATH
                              parameters:nil
                          requestFactory:nil
                                 options:ATGRestRequestOptionNone
                                 success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                   NSError *error = [ATGRestManager checkForError:pResponseObject];
                                   if (![profileRequest sendError:error withSelector:getErrorSelector]) {
                                     DebugLog(@"Got valid profile security status response from server");
                                     profileRequest.requestResults = [pResponseObject valueForKey:@"securityStatus"];
                                     [profileRequest sendResponse:getSelector];
                                   }
                                 }
                                 failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                   DebugLog(@"Server returned error when trying to get the profile security status: %@", pError);
                                   [profileRequest sendError:pError withSelector:getErrorSelector];
                                 }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}

- (void) clearCachedProfile {
  DebugLog(@"Profile cache cletabared.");
  [self.profileCache removeItemFromCacheWithID:ATG_PROFILE_OBJECT_CACHE_NAME];
}

- (void) clearCachedOrders {
  DebugLog(@"Orders cache cleared.");
  [self.cachedOrders clearCache];
}

- (void) clearCachedListofOrders {
  DebugLog(@"Orders List cache cleared.");
  [self.cachedListofOrders clearCache];
}

- (void) clearCachedListofAddresses {
  DebugLog(@"Address Cache cleared");
  [self.profileCache removeItemFromCacheWithID:ATG_CACHED_ADDRESS_LIST_OBJECT_CACHE_NAME];
}

- (void) clearCachedListofCreditCards {
  DebugLog(@"CreditCard List cache cleared.");
  [self.profileCache removeItemFromCacheWithID:ATG_CACHED_CREDIT_CARD_LIST_OBJECT_CACHE_NAME];
}

- (void) clearAllCache {
  [self clearCachedProfile];
  [self clearCachedOrders];
  [self clearCachedListofAddresses];
  [self clearCachedListofOrders];
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ATG_CLEAR_PROFILE_ADDRESS_CACHE object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:ATG_CLEAR_PROFILE_CACHE object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:ATG_CLEAR_CACHED_ORDERS_NOTIFICATION
                                                object:nil];
}

@end

