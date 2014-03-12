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

#import "ATGRecommendationsManager.h"
#import "ATGBaseProduct+Additions.h"
#import "ATGRecommendationsManagerRequest.h"
#import "ATGRestManager.h"

NSString *const ATG_RECOMMENDATIONS = @"view/recommendations";
NSString *const ATG_RECOMMENDATIONS_URL_KEY = @"ATG_RECOMMENDATIONS_URL";
NSString *const ATG_RECOMMENDATIONS_URL_PATH_PREFIX_KEY = @"ATG_RECOMMENDATIONS_URL_PATH_PREFIX";
NSString *const ATG_RECOMMENDATIONS_VERSION_KEY = @"ATG_RECOMMENDATIONS_VERSION";
NSString *const ATG_RECOMMENDATIONS_RESPONSE_FORMAT_JSON = @"json";

static ATGRecommendationsManager *recommendationsManager;

@class ATGRecommendationsASIDelegate;
@class ATGRecommendationsManager;

@interface ATGRecommendationsASIDelegate : NSObject {
  @private
}
@property (weak, nonatomic) NSObject <ATGRecommendationsManagerDelegate> *delegate;
@property (nonatomic, strong) ATGRecommendationsManager *manager;
@property (nonatomic, copy) NSString *slotName;
@end

@interface ATGRecommendationsManager ()

@property (nonatomic, copy, readonly) NSString *recsBaseUrlSuffix;
@property (nonatomic, copy, readonly) NSString *recsBaseUrlPrefix;
@end

@implementation ATGRecommendationsManager

@synthesize recsBaseUrlPrefix = _recsBaseUrlPrefix,
recsBaseUrlSuffix = _recsBaseUrlSuffix,
restManager = _restManager;

- (id) init {
  self = [super init];
  if (self) {
    _recsBaseUrlSuffix = [NSString pathWithComponents:[NSArray arrayWithObjects:
                                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:ATG_RECOMMENDATIONS_VERSION_KEY],
                                                       ATG_RECOMMENDATIONS_RESPONSE_FORMAT_JSON,
                                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:ATG_RECOMMENDATIONS_RETAILER_ID_KEY], nil]];
    _recsBaseUrlPrefix = [NSString pathWithComponents:[NSArray arrayWithObjects:
                                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:ATG_RECOMMENDATIONS_URL_KEY],
                                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:ATG_RECOMMENDATIONS_URL_PATH_PREFIX_KEY], nil]];
  }
  return self;
}

- (ATGRestManager *) restManager {
  if (_restManager == nil) {
    _restManager = [ATGRestManager restManager];
  }
  return _restManager;
}

+ (ATGRecommendationsManager *) recommendationsManager {
  static dispatch_once_t pred_recommendations_manager;
  dispatch_once(&pred_recommendations_manager,
                ^{
                  recommendationsManager = [[ATGRecommendationsManager alloc] init];
                }
                );
  return recommendationsManager;
}

- (NSString *) buildRequestParamString:(NSDictionary *)params {
  if (params != nil && [params count] < 1) {
    return nil;
  }

  NSMutableString *paramString = [NSMutableString stringWithString:@"?"];

  NSEnumerator *paramEnum = [params keyEnumerator];
  id key;
  while (key = [paramEnum nextObject]) {
    if (![paramString hasSuffix:@"?"]) {
      [paramString appendString:@"&"];
    }
    [paramString appendString:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
  }

  return paramString;
}

- (NSURL *) buildRecomendationBaseURL:(NSString *)requestType withRequestParams:(NSDictionary *)requestParams {
  NSString *urlString = [NSString pathWithComponents:[NSArray arrayWithObjects:
                                                      self.recsBaseUrlPrefix,
                                                      requestType,
                                                      self.recsBaseUrlSuffix, nil]];

  NSString *paramString = nil;

  if (requestParams != nil && [requestParams count] > 0) {
    paramString = [self buildRequestParamString:requestParams];
  }

  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlString, paramString]];
  return url;
}

- (ATGRecommendationManagerRequest *) getRecommendationsForSlotName:(NSString *)pSlotName howMany:(NSNumber *)pHowMany delegate:pDelegate {
  ATGRecommendationManagerRequest *request = [[ATGRecommendationManagerRequest alloc] init];
  request.delegate = pDelegate;
  request.manager = self;
  request.slotName = pSlotName;

  NSMutableDictionary *params  = [NSMutableDictionary dictionary];
  [params setValue:[pHowMany stringValue] forKey:[NSString stringWithFormat:@"slots.%@.numRecs", pSlotName]];

  if ([[self.restManager currentSite] isNotBlank]) {
    [params setValue:[self.restManager currentSite] forKey:@"view.storeId"];
    [params setValue:@"true" forKey:@"view.excludeDefaultStore"];
  }

  NSURL *requestUrl = [self buildRecomendationBaseURL:ATG_RECOMMENDATIONS withRequestParams:params];

  NSLog(@"START setting responseAsJSON");
  (id) responseAsJson = [NSJSONSerialization JSONObjectWithData:[pResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
  NSLog(@"END setting responseAsJSON");

  id <ATGRestOperation> operation = [self.restManager.restSession executeGetRequestToAbsoluteURL:requestUrl requestFactory:nil options:(ATGRestRequestOptionIgnorePushSite | ATGRestRequestOptionIgnoreLocale) success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
                                       if (request.delegate && [request.delegate respondsToSelector:@selector(didGetRecommendationsForSlotName:)]) {
                                         id recs = responseAsJson;
                                         DebugLog (@"Response is %@", recs);
                                         NSArray *products = [ATGBaseProduct objectsFromArray:[[[recs valueForKey:@"slots"] valueForKey:[request slotName]] valueForKey:@"recs"]];
                                         request.recommendations = products;
                                         [request.delegate performSelectorOnMainThread:@selector(didGetRecommendationsForSlotName:) withObject:request waitUntilDone:NO];
                                       }
                                     }
                                     failure: ^(id <ATGRestOperation> pOperation, NSError *pError) {
                                       DebugLog (@"Server returned error requesting recommendations %@", pError);
                                       NSString *errorMessage = NSLocalizedStringWithDefaultValue (@"ATGRecommendationsManager.BadStatusCodeError", nil,
                                                                                                   [NSBundle mainBundle], @"There was an issue requesting recommendations.",
                                                                                                   @"There was an issue requesting recommendations.");
                                       NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey, pError, ATG_ERROR_EXCEPTION_KEY, nil];
                                       NSError *error = [NSError errorWithDomain:ATGRecommendationsManagerErrorDomain code:-1 userInfo:userInfo];
                                       request.error = error;
                                       if (request.delegate && [request.delegate respondsToSelector:@selector(didErrorGettingRecommendations:)]) {
                                         [request.delegate performSelectorOnMainThread:@selector(didErrorGettingRecommendationsForSlot:) withObject:request waitUntilDone:NO];
                                       }
                                     }
                                    ];

  request.operation = operation;
  return request;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

@end

