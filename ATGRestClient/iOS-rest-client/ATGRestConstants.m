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

@implementation ATGRestConstants

NSString *const ATG_REST_INPUT = @"atg-rest-input";
NSString *const ATG_REST_OUTPUT = @"atg-rest-output";
NSString *const ATG_REST_FORMAT_JSON = @"json";
//NSString *const REST_FORMAT_XML = @"xml";

NSString *const ATG_DYN_SESS_CONF = @"_dynSessConf";

NSString *const ATG_REST_ARG = @"arg";

NSString *const ATG_REST_INPUT_JSON = @"atg-rest-json-input";
NSString *const ATG_REST_DEPTH = @"atg-rest-depth";
NSString *const ATG_REST_NULL = @"atg-rest-null";
NSString *const ATG_REST_RQL = @"atg-rest-rql";
NSString *const ATG_REST_USER_INPUT = @"atg-rest-user-input";
NSString *const ATG_REST_PROPERTY_FILTERS = @"atg-rest-property-filters";
NSString *const ATG_REST_PROPERTY_FILTER_TEMPLATES = @"atg-rest-property-filter-templates";
NSString *const ATG_REST_VIEW = @"atg-rest-view";

NSString *const ATG_REST_FORM_HANDLER_EXCEPTIONS = @"atg-rest-return-form-handler-exceptions";
NSString *const ATG_REST_FORM_HANDLER_PROPERTIES = @"atg-rest-return-form-handler-properties";
NSString *const ATG_REST_FORM_TAG_PRIORITIES = @"atg-rest-form-tag-priorities";

NSString *const ATG_REST_RESPONSE = @"atgResponse";
NSString *const ATG_REST_FORM_EXCEPTIONS = @"formExceptions";
NSString *const ATG_REST_FORM_COMPONENT = @"component";

NSString *const ATG_REST_BEAN = @"/bean";
NSString *const ATG_REST_REPOSITORY = @"/repository";
NSString *const ATG_REST_SERVICE = @"/service";
NSString *const ATG_REST_MODELACTOR = @"/model";

NSString *const ATG_CHARSET = @"_dyncharset";

NSStringEncoding const ATG_DEFAULT_STRING_ENCODING = NSUTF8StringEncoding;
NSString *const ATG_DEFAULT_STRING_ENCODING_KEY = @"ATG_CHARACTER_ENCODING";

BOOL const ATG_USE_HTTPS = NO;
NSString *const ATG_USE_HTTPS_KEY = @"ATG_USE_HTTPS";

NSString *const ATGNetworkingReachabilityDidChangeNotification = @"com.atg.networking.reachability.change";

#pragma mark -
#pragma mark REST Exceptions

NSString *const ATGRestClientException = @"RestClientException";
NSString *const ATGRestClientExceptionCodeKey = @"RestClientExceptionCode";
NSString *const ATGRestClientExceptionDataKey = @"RestClientExceptionData";
NSString *const ATGRestClientExceptionErrorKey = @"RestClientExceptionError";
NSString *const ATGRestClientExceptionURLKey = @"RestClientExceptionURL";
NSString *const ATGRestClientExceptionParamsKey = @"RestClientExceptionParams";
NSString *const ATGRestClientExceptionArgumentsKey = @"RestClientExceptionArguments";
NSString *const ATGRestClientExceptionHTTPMethodKey = @"RestClientExceptionHTTPMethod";
NSString *const ATG_FORM_EXCEPTION_KEY = @"com.atg.error.formexception";

NSString *const ATG_RETINA_USER_AGENT_STRING = @"HiRes";
NSString *const ATG_NON_RETINA_USER_AGENT_STRING = @"LowRes";

NSString *const ATGMethodNotImplmentedException = @"ATGMethodNotImplmentedException";

+ (NSString *) getHTTPMethodString:(ATGHTTPMethod) pMethod{
  switch (pMethod) {
    case ATGHTTPMethodGet:
      return @"GET";
    case ATGHTTPMethodPost:
      return @"POST";
    case ATGHTTPMethodPut:
      return @"PUT";
    case ATGHTTPMethodDelete:
      return @"DELETE";
    default:
      [NSException raise:NSInvalidArgumentException format:@"Unexpected HTTPMethod"];
      return nil;
  }
}

+ (NSStringEncoding) getEncodingFromString:(NSString *) pEncoding{
  CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef) pEncoding);
  
  return CFStringConvertEncodingToNSStringEncoding(cfEncoding);
}

+ (NSString *) getStringFromEncoding:(NSStringEncoding)pEncoding{
  CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding((unsigned long)pEncoding);
  
  return (__bridge NSString*)CFStringConvertEncodingToIANACharSetName(cfEncoding);
}

+ (BOOL) isRetinaDisplay {
  //First we check to see if the device responds to selector displayLinkWithTarget.  It it does
  //then we know this is a iOS 4+ device.  Then we check if the scale is 2.0, if it is we know its
  //Retina
  if ( [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
      ([UIScreen mainScreen].scale == 2.0) ) {
    return YES;
  } else {
    return NO;
  }
}

+ (NSString *) formatUserAgentPropertyString:(NSArray *)pProperties {
  if (pProperties != nil && pProperties.count > 0) {
    NSString *components = [pProperties componentsJoinedByString:@"; "];
    return [NSString stringWithFormat:@"(%@)", components];
  }
  
  return nil;
}

+ (NSArray *) getUserAgentProperties {
  UIDevice *device = [UIDevice currentDevice];
  
  NSMutableArray *props = [NSMutableArray array];
  [props addObject:[device model]];
  [props addObject:[NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion]];
  [props addObject:[[NSLocale currentLocale] localeIdentifier]];
  
  if ([ATGRestConstants isRetinaDisplay]) {
    [props addObject:ATG_RETINA_USER_AGENT_STRING];
  } else {
    [props addObject:ATG_NON_RETINA_USER_AGENT_STRING];
  }
  
  return [props copy];
}

+ (NSString *) getUserAgent {
  //First we get the application name
  NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
  
  //Then we get the bundle version
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  
  //Then we get the bundle build number
  NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  
  return [NSString stringWithFormat:@"%@ %@b%@ %@", appName, appVersion, appBuild, [ATGRestConstants formatUserAgentPropertyString:[self getUserAgentProperties]]];
}


@end
