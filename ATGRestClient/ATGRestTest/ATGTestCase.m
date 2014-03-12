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



#import "ATGTestCase.h"
#import "AFURLConnectionOperation.h"
#import "AFJSONRequestOperation.h"
#import "ATGRest.h"

@interface ATGTestCase(){
  BOOL _done;
}
@end
@implementation ATGTestCase

NSString *const ATG_TEST_STATUS_CODE = @"statusCode";
NSString *const ATG_TEST_RESPONSE = @"response";
NSString *const ATG_TEST_BODY = @"body";
NSString *const ATG_TEST_URL = @"url";

@synthesize mockData = _mockData,statusCode = _statusCode,response = _response,body=_body,url=_url;

- (id) initWithInvocation:(NSInvocation *) anInvocation{
  self = [super initWithInvocation:anInvocation];
  if(self){
    //parse plist
    if([self plistName]){
      NSBundle* bundle = [NSBundle bundleForClass:[self class]];
      NSString* plistPath = [bundle pathForResource:[self plistName] ofType:@"plist"];
      
//      NSString *path = [[NSBundle mainBundle] bundlePath];
//      NSString *finalPath = [path stringByAppendingPathComponent:[self plistName]];
      
      NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
      self.mockData = dict;
    }
  }
  return self;
}
- (NSString *)plistName{
  return nil;
}
-(void)parseTestData:(NSString *)testId{
  NSDictionary *dict = [self.mockData valueForKey:testId];
  
  self.statusCode = [[dict valueForKey:ATG_TEST_STATUS_CODE] intValue];
  self.response = [dict valueForKey:ATG_TEST_RESPONSE];
  self.body = [dict valueForKey:ATG_TEST_BODY];
  self.url = [dict valueForKey:ATG_TEST_URL];
}
-(void)verifyPostBody:(id)pOperation encoding:(NSStringEncoding)pEncoding{
  if ([self.body isNotBlank]) {
    NSString *responseBody = [[NSString alloc] initWithData:((AFJSONRequestOperation *)pOperation).request.HTTPBody encoding:pEncoding];

    NSError *error = nil;
    (id) responseBodyJson =  [NSJSONSerialization JSONObjectWithData:[responseBody dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    (id) bodyJson =          [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error: &error];
    STAssertEqualObjects(responseBodyJson, bodyJson, @"HTTP body doesn't match");
  }
  
}
-(void) prepare{
  _done = NO;
}
-(void) markDoneWithStatus:(ATGStatus) pStatus{
  _done = YES;
  switch (pStatus) {
    case ATGFail:
      STFail(@"Failure executing test case");
      break; 
    case ATGTimeout:
      STFail(@"Timeout waiting to test to execute");
      break;
    case ATGNotPrepared:
      STFail(@"Test not prepared");
      break;
    default:
      break;
  }
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
  if(_done){
    [self markDoneWithStatus:ATGNotPrepared];
  }
  NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
  
  do {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    if([timeoutDate timeIntervalSinceNow] < 0.0){
      [self markDoneWithStatus:ATGTimeout];
      break;
    }
  } while (!_done);
  
  return _done;
}

@end
//Workaround for code coverage
FILE *fopen$UNIX2003(const char *filename, const char *mode) {
  return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void *ptr, size_t size, size_t nitems, FILE *stream) {
  return fwrite(ptr, size, nitems, stream);
}
