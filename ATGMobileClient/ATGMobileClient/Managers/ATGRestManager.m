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

#import "ATGRestManager.h"
#import <iOS-rest-client/ATGStackedRestRequestFactory.h>

NSString *const ATG_ERROR_DOMAIN = @"com.atg.error";
NSString *const ATG_ERROR_EXCEPTION_KEY = @"com.atg.error.exception";
NSString *const ATG_AUTHENTICATION_DOMAIN = @"USER_NOT_AUTHENTICATED";
NSString *const ATG_REST_SERVER_HOST_KEY = @"ATG_REST_SERVER_HOST";
NSString *const ATG_REST_SERVER_PORT_KEY = @"ATG_REST_SERVER_PORT";
NSString *const ATG_REST_DATE_FORMAT = @"MM/dd/yyyy HH:mm:ss zzz";
NSString *const ATG_REST_DATE_FORMAT_LOCALE = @"en_US";
NSString *const ATG_SITE_ID_KEY = @"ATG_SITE_ID";
NSString *const ATG_CLEAR_PROFILE_ADDRESS_CACHE = @"CLEAR_PROFILE_ADDRESS_CACHE";
NSString *const ATG_CLEAR_PROFILE_CREDIT_CARD_CACHE = @"CLEAR_PROFILE_CREDIT_CARD_CACHE";
NSString *const ATG_CLEAR_PROFILE_CACHE = @"CLEAR_PROFILE_CACHE";
NSString *const ATG_CLEAR_CACHED_ORDERS_NOTIFICATION = @"ATG_CLEAR_CACHED_ORDERS_NOTIFICATION";
NSString *const ATG_CLEAR_PRODUCT_CACHE = @"CLEAR_PRODUCT_CACHE";
NSString *const ATG_RECOMMENDATIONS_RETAILER_ID_KEY = @"ATG_RECOMMENDATIONS_RETAILER_ID";

// ATG_USE_HTTPS_KEY is defined by the iOS-rest-client lib.
extern NSString *const ATG_USE_HTTPS_KEY;

static ATGRestManager *restManager;

#pragma mark - ATGRestManager Private Protocol
#pragma mark -

@interface ATGRestManager ()

// This method will be registered to receive notifications when the defaults have changed.
- (void) defaultsDidChange:(NSNotification *)notification;
// This method updates current session with data read from the defaults database.
- (void) updateSessionFromDefaults:(NSUserDefaults *)defaults;

@end

#pragma mark - ATGRestManager Implementation

@implementation ATGRestManager

@synthesize currentSite = _currentSite;
static ATGRestSession *_restSession = nil;

- (id) init {
  self = [super init];
  if (self) {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // Always register default values into the defaults database. If the user changes
    // something with Settings app, these values will be overridden.
    // Default values are stored in the Info.plist file.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [infoDictionary objectForKey:ATG_REST_SERVER_HOST_KEY], ATG_REST_SERVER_HOST_KEY,
                                [infoDictionary objectForKey:ATG_REST_SERVER_PORT_KEY], ATG_REST_SERVER_PORT_KEY,
                                [infoDictionary objectForKey:ATG_USE_HTTPS_KEY], ATG_USE_HTTPS_KEY,
                                [infoDictionary objectForKey:ATG_SITE_ID_KEY], ATG_SITE_ID_KEY, nil]];
    // Register self to receive notifications when the user has changed something
    // with Settings application. This is essential to allow the user to change settings
    // witout restarting an app.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
  }
  return self;
}

+ (ATGRestManager *) restManager {
  static dispatch_once_t pred_rest_manager;
  dispatch_once(&pred_rest_manager,
                ^{
                  restManager = [[ATGRestManager alloc] init];
                }
                );
  return restManager;
}

+ (id <ATGRestOperation>) requestForImageURL:(NSString *)pURL success:( void ( ^)(id <ATGRestOperation> pOperation, id pResponseObject) )pSuccess failure:( void ( ^)(id <ATGRestOperation> pOperation, NSError * pError) )pFailure {
  return [ATGRestManager requestForAbsoluteImageURL:[[[[ATGRestManager restManager].restSession hostURLWithOptions:ATGRestRequestOptionNone] URLByAppendingPathComponent:pURL] absoluteString] success:pSuccess failure:pFailure];
}

+ (id <ATGRestOperation>) requestForAbsoluteImageURL:(NSString *)pURL success:( void ( ^)(id <ATGRestOperation> pOperation, id pResponseObject) )pSuccess failure:( void ( ^)(id <ATGRestOperation> pOperation, NSError * pError) )pFailure {
  return [[ATGRestManager restManager].restSession executeGetRequestToAbsoluteURL:[NSURL URLWithString:pURL] requestFactory:nil options:(ATGRestRequestOptionIgnoreLocale | ATGRestRequestOptionIgnorePushSite) success: ^(id <ATGRestOperation> pOperation, id pResponseObject) {
    UIImage *image = [UIImage imageWithData:pResponseObject];
    pSuccess (pOperation, image);
  }
                                                                          failure: ^(id <ATGRestOperation> pOperation, NSError * pError) {
                                                                            pFailure (pOperation, pError);
                                                                          }
          ];
}
+ (void) clearImageCache {
  //[[ASIDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
}

+ (NSError *) checkForError:(id)pResponse {
  if ([pResponse isKindOfClass:[NSDictionary class]] && [pResponse valueForKey:@"error"]) {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSObject *error = [pResponse valueForKey:@"error"];
    if ([error isKindOfClass:[NSString class]]) {
      NSString *errorMsg = (NSString *)error;
      if ([errorMsg isEqualToString:ATG_AUTHENTICATION_DOMAIN]) {
        [userInfo setValue:NSLocalizedStringWithDefaultValue(@"moible.authentication.loginRequired", nil, [NSBundle mainBundle], @"Login required", @"Loging required") forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:ATG_AUTHENTICATION_DOMAIN code:403 userInfo:userInfo];
      } else {
        [userInfo setValue:errorMsg forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:ATG_ERROR_DOMAIN code:1 userInfo:userInfo];
      }
    } else if ([error isKindOfClass:[NSDictionary class]]) {
      if ([[error valueForKey:@"messageCode"] isEqualToString:ATG_AUTHENTICATION_DOMAIN]) {
        [userInfo setValue:NSLocalizedStringWithDefaultValue(@"moible.authentication.loginRequired", nil, [NSBundle mainBundle], @"Login required", @"Loging required") forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:ATG_AUTHENTICATION_DOMAIN code:403 userInfo:userInfo];
      }
      NSDictionary *errorDict = (NSDictionary *)error;
      [userInfo setValue:[errorDict valueForKey:@"localizedMessage"] forKey:NSLocalizedDescriptionKey];
      return [NSError errorWithDomain:ATG_ERROR_DOMAIN code:1 userInfo:userInfo];
    }
  } else if ([pResponse isKindOfClass:[NSDictionary class]] && [pResponse objectForKey:@"formExceptions"]) {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSMutableArray *exceptions = [[NSMutableArray alloc] init];
    for (id exception in [pResponse objectForKey:@"formExceptions"]) {
      if ([exception isKindOfClass:[NSDictionary class]]) {
        [exceptions addObject:[exception objectForKey:@"localizedMessage"]];
      } else if ([exception isKindOfClass:[NSString class]]) {
        [exceptions addObject:exception];
      }
    }
    if ([exceptions count] > 0) {
      [userInfo setObject:exceptions forKey:ATG_FORM_EXCEPTION_KEY];
    }
    return [NSError errorWithDomain:ATG_ERROR_EXCEPTION_KEY code:-1 userInfo:userInfo];
  }
  return nil;
}

+ (NSDateFormatter *) dateFormatter {
  static dispatch_once_t predicate_date_formatter;
  static NSDateFormatter *dateFormatter = nil;
  
  if (dateFormatter) {
    return dateFormatter;
  }
  
  dispatch_once(&predicate_date_formatter, ^{
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:ATG_REST_DATE_FORMAT_LOCALE];
    [dateFormatter setDateFormat:ATG_REST_DATE_FORMAT];
  }
                );
  
  return dateFormatter;
}

+ (NSString *) prefixString:(NSString *)pString withPrefix:(NSString *)pPrefix {
  return [NSString stringWithFormat:@"%@.%@", pPrefix, pString];
}

- (ATGRestSession *) restSession {
  static dispatch_once_t predicate_rest_session;
  
  if (_restSession) {
    return _restSession;
  }
  
  dispatch_once(&predicate_rest_session, ^{
    // Create a dummy session, we will update it with proper host and port later.
    _restSession = [ATGRestSession newSessionForHost:nil port:0 username:nil password:nil];
    // Now this new session should be updated with proper values from the defaults database.
    [self updateSessionFromDefaults:[NSUserDefaults standardUserDefaults]];
    self.currentSite =  [[[NSBundle mainBundle] infoDictionary] objectForKey:ATG_SITE_ID_KEY];
    NSString *userAgentString = [ATGRestConstants getUserAgent];
    if ([userAgentString isNotBlank]) {
      [_restSession.requestFactory setUserAgentString:userAgentString];
    }
    ATGStackedRestRequestFactory *orderedFactory = [ATGStackedRestRequestFactory factoryWithFactories:[NSArray arrayWithObjects:_restSession.requestFactory, [[ATGMultisiteRestRequestFactory alloc] initWithStringEncoding:_restSession.characterEncoding parent:_restSession.requestFactory], nil]];
    _restSession.requestFactory = orderedFactory;
  }
                );
  
  return _restSession;
}

- (NSString *) currentLocale {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
  NSString *localeString = [languages objectAtIndex:0];
  return localeString;
}




#pragma mark - Private Protocol Implementation

- (void) defaultsDidChange:(NSNotification *)pNotification {
  [self updateSessionFromDefaults:[pNotification object]];
}

- (void) updateSessionFromDefaults:(NSUserDefaults *)pDefaults {
  NSString *host = [pDefaults stringForKey:ATG_REST_SERVER_HOST_KEY];
  NSInteger port = [pDefaults integerForKey:ATG_REST_SERVER_PORT_KEY];
  BOOL useHTTPS = [pDefaults boolForKey:ATG_USE_HTTPS_KEY];
  
  // Initialize the session with proper values from the Settings app.
  [_restSession setHost:host];
  [_restSession setPort:port];
  [_restSession setUseHttps:useHTTPS];
}

+ (NSString *) getAbsoluteImageString:(NSString *)pImageURL{
  if(pImageURL && (id)pImageURL != [NSNull null]){
    return [[[[ATGRestManager restManager].restSession hostURLWithOptions:ATGRestRequestOptionNone] URLByAppendingPathComponent:pImageURL] absoluteString];
  }
  return nil;
}

@end
@implementation ATGMultisiteRestRequestFactory

- (NSDictionary *) parametersWithOptions:(ATGRestRequestOptions)pOptions {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  if ( !(pOptions & ATGRestRequestOptionIgnorePushSite) ) {
    [params setValue:[ATGRestManager restManager].currentSite forKey:@"pushSite"];
  }
  if ( !(pOptions & ATGRestRequestOptionIgnoreLocale) ) {
    [params setValue:[ATGRestManager restManager].currentLocale forKey:@"locale"];
  }
  return params;
}

@end