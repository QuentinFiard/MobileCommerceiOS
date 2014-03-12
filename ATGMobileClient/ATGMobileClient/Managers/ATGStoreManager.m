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

#import "ATGStoreManager.h"
#import "ATGStore+Additions.h"
#import "ATGKeyValuePair+Additions.h"
#import <ATGMobileCommon/ATGRepositoryCoreDataCache.h>
#import <ATGMobileCommon/ATGMemoryCache.h>
#import "ATGSite.h"
#import "ATGStoreManagerRequest.h"
#import "ATGRestManager.h"

const int ATG_STORE_CACHE_TIME_OUT_SEC = 600;
const int ATG_COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC = 1800;

static const NSInteger ATG_SITES_CACHE_TIME_OUT_SEC = 1800;
static NSString *const ATG_SITES_CACHE_NAME = @"SitesCache";
static NSString *const ATG_SITES_CACHE_ID = @"AllMobileSites";

static ATGStoreManager *storeManager;

static NSString *const ATGActorPrivacyTerms = @"/atg/store/droplet/StoreTextActor/privacyAndTerms";
static NSString *const ATGActorAboutUs = @"/atg/store/droplet/StoreTextActor/aboutUs";
static NSString *const ATGActorShippingReturns =
    @"/atg/store/droplet/StoreTextActor/shippingAndReturns";
static NSString *const ATGActorStores = @"/atg/store/droplet/StoreLookupActor/stores";
static NSString *const ATGActorShippingCountries = @"/atg/store/droplet/ShippingRestrictionsActor";
static NSString *const ATGActorBillingCountries = @"/atg/store/droplet/BillingRestrictionsActor";
static NSString *const ATGActorStates = @"/atg/commerce/util/StateListActor/states";
static NSString *const ATGActorMobileSites =
    @"/atg/dynamo/droplet/multisite/SharingSitesActor/mobileSites";
static NSString *const ATGPropertyCode = @"code";
static NSString *const ATGPropertyName = @"displayName";

@interface ATGStoreManager ()

@property (nonatomic, strong) id <ATGCache> storeCache;
@property (nonatomic, strong) id <ATGCache> keyValueCache;
@property (nonatomic, readwrite, strong) id <ATGCache> sitesCache;

- (void) insertStoresIntoCache:(NSArray *)pStores;
- (void) insertAboutUsIntoCache:(id)pAboutUs;
- (void) insertPrivacyPolicyIntoCache:(id)pPrivacyPolicy;
- (void) insertShippingPolicyIntoCache:(id)pShippingPolicy;
- (void) insertBillingCountryListIntoCache:(id)pCountryList;
- (void) insertShippingCountryListIntoCache:(id)pCountryList;
- (void) insertStatesListIntoCache:(id)pStateList withKey:(NSString *)pKey;

@end

@implementation ATGStoreManager

@synthesize restManager = _restManager, storeCache = _storeCache, keyValueCache = _keyValueCache;
@synthesize sitesCache;

- (id) init {
  self = [super init];
  if (self) {
    self.storeCache = [[ATGRepositoryCoreDataCache alloc] initWithEntityDescriptionName:[ATGStore entityDescriptorName] expiryTime:ATG_STORE_CACHE_TIME_OUT_SEC];
    self.keyValueCache = [[ATGCoreDataCache alloc] initWithEntityDescriptionName:[ATGKeyValuePair entityDescriptorName] idPropertyName:ATG_KEY_VALUE_ID_PROPERTY_NAME expiryTime:ATG_COUNTRY_STATE_CACHED_LIST_TIME_OUT_SEC];
    [self setSitesCache:[[ATGMemoryCache alloc] initWithCacheName:ATG_SITES_CACHE_NAME
                                                        sizeLimit:0
                                                       expiryTime:ATG_SITES_CACHE_TIME_OUT_SEC]];
  }
  return self;
}

+ (ATGStoreManager *) storeManager {
  static dispatch_once_t pred_store_manager;
  dispatch_once(&pred_store_manager,
                ^{
                  storeManager = [[ATGStoreManager alloc] init];
                }
                );
  return storeManager;
}

- (ATGRestManager *) restManager {
  if (_restManager == nil) {
    _restManager = [ATGRestManager restManager];
  }
  return _restManager;
}

- (NSArray *) getStoresFromCache {
  if ([self.storeCache respondsToSelector:@selector(getAllWithSortDescriptors:)]) {
    DebugLog(@"Getting stores from cache");
    NSArray *results = [self.storeCache getAllWithSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES]]];
    return results;
  }
  DebugLog(@"The store cache (of type %@) doesn't implement \"getAllWithSortDescriptors:\" method of ATGCache protocol", [self.storeCache class]);
  return nil;
}

- (id) getShippingPolicyFromCache {
  DebugLog(@"Getting shipping policy from cache");
  ATGKeyValuePair *policy = [self.keyValueCache getItemFromCacheWithID:ATG_SHIPPING_POLICY_KEY];

  return [policy getValueAsJSON];
}

- (id) getPrivacyPolicyFromCache {
  DebugLog(@"Getting privacy policy from cache");
  ATGKeyValuePair *policy = [self.keyValueCache getItemFromCacheWithID:ATG_PRIVACY_POLICY_KEY];

  return [policy getValueAsJSON];
}

- (id) getAboutUsFromCache {
  DebugLog(@"Getting About Us from cache");
  ATGKeyValuePair *policy = [self.keyValueCache getItemFromCacheWithID:ATG_ABOUT_US_KEY];

  return [policy getValueAsJSON];
}

- (id) getBillingCountryListFromCache {
  DebugLog(@"Getting the Billing Country List from Cache");
  ATGKeyValuePair *list = [self.keyValueCache getItemFromCacheWithID:ATG_COUNTRY_BILLING_LIST_KEY];

  return [list getValueAsJSON];
}

- (id) getShippingCountryListFromCache {
  DebugLog(@"Getting the Shipping Country List from Cache");
  ATGKeyValuePair *list = [self.keyValueCache getItemFromCacheWithID:ATG_COUNTRY_SHIPPING_LIST_KEY];

  return [list getValueAsJSON];
}

- (id) getStatesListFromCache:(NSString *)pCountryCode {
  DebugLog(@"Getting the States List from Cache");
  ATGKeyValuePair *list = [self.keyValueCache getItemFromCacheWithID:[NSString stringWithFormat:@"%@_%@", ATG_STATES_LIST_KEY, pCountryCode]];
  return [list getValueAsJSON];
}

- (ATGStoreManagerRequest *)loadStores:(ATGStoreManagerRequest *)pRequest
                       delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingStores:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorStores
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           NSArray *stores = [ATGStore objectsFromArray:[pResponseObject objectForKey:@"stores"]];
           [self insertStoresIntoCache:stores];
           pRequest.stores = stores;
           [pRequest sendResponse:@selector(didGetStores:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve stores: %@", pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadShippingPolicy:(ATGStoreManagerRequest *)pRequest
                               delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingShippingPolicy:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorShippingReturns
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           id shipping = [ATGKeyValuePair objectWithKey:ATG_SHIPPING_POLICY_KEY andValue:pResponseObject];
           [self insertShippingPolicyIntoCache:shipping];
           pRequest.shippingPolicy = [( (ATGKeyValuePair *)shipping ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetShippingPolicy:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve the shipping info: %@", pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadPrivacyPolicy:(ATGStoreManagerRequest *)pRequest
                              delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingPrivacyPolicy:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorPrivacyTerms
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           id privacy = [ATGKeyValuePair objectWithKey:ATG_PRIVACY_POLICY_KEY andValue:pResponseObject];
           [self insertPrivacyPolicyIntoCache:privacy];
           pRequest.privacyPolicy = [( (ATGKeyValuePair *)privacy ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetPrivacyPolicy:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve policy policy: %@", pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadAboutUs:(ATGStoreManagerRequest *)pRequest
                        delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingAboutUs:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorAboutUs
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           id about = [ATGKeyValuePair objectWithKey:ATG_ABOUT_US_KEY andValue:pResponseObject];
           [self insertAboutUsIntoCache:about];
           pRequest.aboutUs = [( (ATGKeyValuePair *)about ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetAboutUs:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve about us: %@", pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadShippingCountryList:(ATGStoreManagerRequest *)pRequest
                                    delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingShippingCountryList:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorShippingCountries
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           NSMutableDictionary *shippingCountries = [[NSMutableDictionary alloc] init];
           for (NSDictionary *country in [pResponseObject objectForKey:@"countries"]) {
             NSString *name = [country objectForKey:ATGPropertyName];
             NSString *code = [country objectForKey:ATGPropertyCode];
             [shippingCountries setObject:code forKey:name];
           }
           id shipping = [ATGKeyValuePair objectWithKey:ATG_COUNTRY_SHIPPING_LIST_KEY
                                               andValue:shippingCountries];
           [pRequest.storeManager insertShippingCountryListIntoCache:shipping];
           pRequest.countryList = [( (ATGKeyValuePair *)shipping ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetShippingCountryList:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve list of countries a user can ship to: %@",
                   pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadBillingCountryList:(ATGStoreManagerRequest *)pRequest
                                   delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingBillingCountryList:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorBillingCountries
       parameters:nil
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           NSMutableDictionary *billingCountries = [[NSMutableDictionary alloc] init];
           for (NSDictionary *country in [pResponseObject objectForKey:@"countries"]) {
             NSString *name = [country objectForKey:ATGPropertyName];
             NSString *code = [country objectForKey:ATGPropertyCode];
             [billingCountries setObject:code forKey:name];
           }
           id billing = [ATGKeyValuePair objectWithKey:ATG_COUNTRY_BILLING_LIST_KEY
                                              andValue:billingCountries];
           [pRequest.storeManager insertBillingCountryListIntoCache:billing];
           pRequest.countryList = [( (ATGKeyValuePair *)billing ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetBillingCountryList:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve list of countries a user can bill to: %@",
                   pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *)loadStateList:(NSString *)pCountryCode
                           request:(ATGStoreManagerRequest *)pRequest
                          delegate:(id<ATGStoreManagerDelegate>)pDelegate {
  SEL errorSelector = @selector(didErrorGettingStatesList:);
  id<ATGRestOperation> operation =
      [[[self restManager] restSession]
       executePostRequestForActorPath:ATGActorStates
       parameters:@{@"countryCode": pCountryCode}
       requestFactory:nil
       options:ATGRestRequestOptionNone
       success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
         NSError *error = [ATGRestManager checkForError:pResponseObject];
         if (![pRequest sendError:error withSelector:errorSelector]) {
           NSMutableDictionary *statesValue = [[NSMutableDictionary alloc] init];
           for (NSDictionary *state in [pResponseObject objectForKey:@"states"]) {
             NSString *name = [state objectForKey:ATGPropertyName];
             NSString *code = [state objectForKey:ATGPropertyCode];
             [statesValue setObject:code forKey:name];
           }
           NSString *key = [NSString stringWithFormat:@"%@_%@", ATG_STATES_LIST_KEY, pCountryCode];
           id states = [ATGKeyValuePair objectWithKey:key andValue:statesValue];
           [pRequest.storeManager insertStatesListIntoCache:states withKey:key];
           pRequest.stateList = [( (ATGKeyValuePair *)states ) getValueAsJSON];
           [pRequest sendResponse:@selector(didGetStatesList:)];
         }
       }
       failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
         DebugLog (@"Server returned error while trying retrieve list of states: %@", pError);
         [pRequest sendError:pError withSelector:errorSelector];
       }];
  pRequest.operation = operation;
  return pRequest;
}

- (ATGStoreManagerRequest *) getStores:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting stores");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  NSArray *stores = [self getStoresFromCache];
  if (stores == nil) {
    DebugLog(@"Stores not found in cache, loading from server");
    return [self loadStores:request delegate:pDelegate];
  }
  request.stores = stores;
  if ([pDelegate respondsToSelector:@selector(didGetStores:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetStores:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getShippingPolicy:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting shipping policy");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  id policy = [self getShippingPolicyFromCache];
  if (policy == nil) {
    DebugLog(@"Shipping policy not found in cache, loading from server");
    return [self loadShippingPolicy:request delegate:pDelegate];
  }
  request.shippingPolicy = policy;
  if ([pDelegate respondsToSelector:@selector(didGetShippingPolicy:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetShippingPolicy:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getPrivacyPolicy:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting privacy policy");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  id policy = [self getPrivacyPolicyFromCache];
  if (policy == nil) {
    DebugLog(@"Privacy policy not found in cache, loading from server");
    return [self loadPrivacyPolicy:request delegate:pDelegate];
  }
  request.privacyPolicy = policy;
  if ([pDelegate respondsToSelector:@selector(didGetPrivacyPolicy:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetPrivacyPolicy:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getAboutUs:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting stores");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  id about = [self getAboutUsFromCache];
  if (about == nil) {
    DebugLog(@"About us not found in cache, loading from server");
    return [self loadAboutUs:request delegate:pDelegate];
  }
  request.aboutUs = about;
  if ([pDelegate respondsToSelector:@selector(didGetAboutUs:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetAboutUs:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getBillingCountryList:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting Billing Country List");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  id billingCountryList = [self getBillingCountryListFromCache];
  if (billingCountryList == nil) {
    DebugLog(@"Country billing list not found in cache, loading from server");
    return [self loadBillingCountryList:request delegate:pDelegate];
  }
  request.countryList = billingCountryList;
  if ([pDelegate respondsToSelector:@selector(didGetBillingCountryList:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetBillingCountryList:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getShippingCountryList:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting Shipping Country List");
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  id shippingCountryList = [self getShippingCountryListFromCache];
  if (shippingCountryList == nil) {
    DebugLog(@"Country billing list not found in cache, loading from server");
    return [self loadShippingCountryList:request delegate:pDelegate];
  }
  request.countryList = shippingCountryList;
  if ([pDelegate respondsToSelector:@selector(didGetShippingCountryList:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetShippingCountryList:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (ATGStoreManagerRequest *) getStatesList:(NSString *)pCountryCode delegate:(NSObject <ATGStoreManagerDelegate> *)pDelegate {
  DebugLog(@"Getting States List for %@", pCountryCode);
  ATGStoreManagerRequest *request = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  request.delegate = pDelegate;
  request.countryCode = pCountryCode;
  id statesList = [self getStatesListFromCache:pCountryCode];
  if (statesList == nil) {
    DebugLog(@"States list for country %@ is not in the cache, loading from server", pCountryCode);
    return [self loadStateList:pCountryCode request:request delegate:pDelegate];
  }
  request.stateList = statesList;
  if ([pDelegate respondsToSelector:@selector(didGetStatesList:)]) {
    [pDelegate performSelectorOnMainThread:@selector(didGetStatesList:) withObject:request waitUntilDone:NO];
  }
  return request;
}

- (void) insertStoresIntoCache:(NSArray *)pStores {
  DebugLog(@"Adding Stores into cache");
  for (ATGStore *store in pStores) {
    [self.storeCache insertItemIntoCache:store withID:store.repositoryId];
  }
}

- (void) insertAboutUsIntoCache:(id)pAboutUs {
  DebugLog(@"Adding AboutUs into cache");
  [self.keyValueCache insertItemIntoCache:pAboutUs withID:ATG_ABOUT_US_KEY];
}

- (void) insertPrivacyPolicyIntoCache:(id)pPrivacyPolicy {
  DebugLog(@"Adding Privacy Policy into cache");
  [self.keyValueCache insertItemIntoCache:pPrivacyPolicy withID:ATG_PRIVACY_POLICY_KEY];
}

- (void) insertShippingPolicyIntoCache:(id)pShippingPolicy {
  DebugLog(@"Adding Shipping Policy into cache");
  [self.keyValueCache insertItemIntoCache:pShippingPolicy withID:ATG_SHIPPING_POLICY_KEY];
}

- (void) insertBillingCountryListIntoCache:(id)pCountryList {
  DebugLog(@"Adding Billing Country List into cache");
  [self.keyValueCache insertItemIntoCache:pCountryList withID:ATG_COUNTRY_BILLING_LIST_KEY];
}

- (void) insertShippingCountryListIntoCache:(id)pCountryList {
  DebugLog(@"Adding Shipping Country List into cache");
  [self.keyValueCache insertItemIntoCache:pCountryList withID:ATG_COUNTRY_SHIPPING_LIST_KEY];
}

- (void) insertStatesListIntoCache:(id)pStateList withKey:(NSString *)pKey {
  DebugLog(@"Adding States List for into cache");
  [self.keyValueCache insertItemIntoCache:pStateList withID:pKey];
}

- (ATGStoreManagerRequest *)getMobileSitesForDelegate:(NSObject<ATGStoreManagerDelegate> *)pDelegate {
  SEL success = @selector(didGetMobileSites:);
  SEL failure = @selector(didErrorGettingStores:);

  ATGStoreManagerRequest *storeRequest = [[ATGStoreManagerRequest alloc] initWithStoreManager:self];
  [storeRequest setDelegate:pDelegate];
  NSArray *cachedSites = [[self sitesCache] getItemFromCacheWithID:ATG_SITES_CACHE_ID];
  if (cachedSites) {
    [storeRequest setSites:cachedSites];
    if ([pDelegate respondsToSelector:success]) {
      [pDelegate performSelectorOnMainThread:success
                                  withObject:cachedSites
                               waitUntilDone:NO];
    }
  } else {
    id<ATGRestOperation> operation =
        [[[self restManager] restSession]
         executePostRequestForActorPath:ATGActorMobileSites
         parameters:nil
         requestFactory:nil
         options:ATGRestRequestOptionNone
         success:^(id<ATGRestOperation> pOperation, id pResponseObject) {
           NSError *error = [ATGRestManager checkForError:pResponseObject];
           if (![storeRequest sendError:error withSelector:failure]) {
             NSArray *sites = [ATGSite objectsFromArray:[pResponseObject allValues]];
             [[self sitesCache] insertItemIntoCache:sites withID:ATG_SITES_CACHE_ID];
             [storeRequest setSites:sites];
             if ([pDelegate respondsToSelector:success]) {
               [pDelegate performSelectorOnMainThread:success
                                           withObject:sites
                                        waitUntilDone:NO];
             }
           }
         }
         failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
           [storeRequest sendError:pError withSelector:failure];
         }];
    [storeRequest setOperation:operation];
  }
  return storeRequest;
}

- (void)clearStoresCache {
  [((ATGRepositoryCoreDataCache *) _storeCache) clearCache];
}

- (void)clearCache {
  [self clearStoresCache];
  [self.keyValueCache clearCache];
}

@end
