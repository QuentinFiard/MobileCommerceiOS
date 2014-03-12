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



#import "ATGRestSessionTest.h"

#import "ATGDefaultRestRequestFactory.h"
#import "ATGRestJSONOperation.h"
#import "ATGStackedRestRequestFactory.h"
#import "ATGMultisiteRestRequestFactory.h"

@interface ATGMockURLResponse : NSURLResponse{
 NSInteger _statusCode;
}
-(id) initWithStatusCode:(NSInteger)pStatusCode;
@end

@implementation ATGMockURLResponse

-(id) initWithStatusCode:(NSInteger)pStatusCode{
  self = [super init];
  if(self){
    _statusCode = pStatusCode;
  }
  return self;
}
-(NSInteger) statusCode{
  return _statusCode;
}

@end

@interface ATGMockOperation : ATGRestJSONOperation
@property (copy, nonatomic) NSString *mockJSON;
@property (nonatomic) NSInteger statusCode;
@end

@implementation ATGMockOperation
@synthesize mockJSON = _mockJSON, statusCode=_statusCode;
- (id)responseJSON {
  NSError *error = nil;
  return [NSJSONSerialization JSONObjectWithData:[self.mockJSON dataUsingEncoding:NSUTF8StringEncoding]
                                         options:NSJSONReadingMutableContainers
                                           error:&error];
}
-(NSURLResponse *)response{
  return [[ATGMockURLResponse alloc] initWithStatusCode:self.statusCode];
}
-(NSError *)error{
  if(self.statusCode != 200){
    return [NSError errorWithDomain:ATGRestClientException code:0 userInfo:nil];
  }
return nil;
}

@end

@interface ATGMockRequestFactory : ATGParentFirstRestRequestFactory {
@private
  
}
+ (ATGMockRequestFactory *)factoryWithEncoding:(NSStringEncoding)pEncoding parent:(id<ATGRestRequestFactory>)pParent ;
@property (copy, nonatomic) NSString *mockResponse;
@property (nonatomic) NSInteger mockStatusCode;
@end

@implementation ATGMockRequestFactory
@synthesize mockResponse = _mockResponse,mockStatusCode=_mockStatusCode;
+ (ATGMockRequestFactory *)factoryWithEncoding:(NSStringEncoding)pEncoding parent:(id<ATGRestRequestFactory>)pParent {
  return [[self alloc] initWithStringEncoding:pEncoding parent:pParent];
}

-(NSURL *)modifyRequestURL:(NSURL *)pURL options:(ATGRestRequestOptions) pOptions{
  
  //NSURL *url = [super modifyRequestURL:pURL options:pOptions];
  
  return pURL;
}

- (id <ATGRestOperation>)JSONRequestOperationWithRequest:(NSURLRequest *)pRequest success:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , id responseObject ))pSuccess failure:(void ( ^ ) ( NSObject <ATGRestOperation> *operation , NSError *error ))pFailure{
#ifdef ATG_MOCK
  ATGMockOperation *requestOperation = [[ATGMockOperation alloc] initWithRequest:pRequest];
  
  requestOperation.mockJSON = self.mockResponse;
  requestOperation.statusCode = self.mockStatusCode;
  [requestOperation setCompletionBlockWithSuccess:pSuccess failure:pFailure];
  return requestOperation;
#else
  return [super JSONRequestOperationWithRequest:pRequest success:pSuccess failure:pFailure];
#endif
  
}


- (void)enqueueRestOperation:(NSObject <ATGRestOperation> *)operation{
#ifdef ATG_MOCK
  ((AFJSONRequestOperation *)operation).completionBlock();
  
#else
  [super enqueueRestOperation:operation];
#endif
}

@end

@interface ATGRestSessionTest(){ 
  
}
@end

@implementation ATGRestSessionTest
@synthesize session = _session;
- (NSString *)plistName{
  return @"ATGRestSessionTest";
}

-(void) setUp{
  self.session = [ATGRestSession newSessionForHost:@"localhost" port:7003 username:nil password:nil];
}
-(void) tearDown{
  self.session = nil;
}

-(ATGStackedRestRequestFactory *)buildFactory{
  id<ATGRestRequestFactory> defaultFactory = self.session.requestFactory;
  
  ATGMultisiteRestRequestFactory *multiSiteFactory = [ATGMultisiteRestRequestFactory factoryWithStringEncoding:self.session.characterEncoding parentFactory:defaultFactory];
  multiSiteFactory.currentSite = @"storeSiteUS";
  
  ATGMockRequestFactory *mockfactory = [ATGMockRequestFactory factoryWithEncoding:self.session.characterEncoding parent:multiSiteFactory];
  mockfactory.mockResponse = self.response;
  mockfactory.mockStatusCode = self.statusCode;
  
  ATGStackedRestRequestFactory *orderedFactory = [ATGStackedRestRequestFactory factoryWithFactories:[NSArray arrayWithObjects:defaultFactory,multiSiteFactory,mockfactory,nil]];
  
  return orderedFactory;
}

-(void) testComponentValue{    
  
  [self prepare];  
  
  [self parseTestData:@"testComponentValue"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];

  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  id operation = [self.session getComponent:@"/atg/commerce/ShoppingCart" parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionNone
                success:^( NSObject <ATGRestOperation>  *operation , id responseObject ){
                  id cart = [responseObject objectForKey:@"cart"];
                  STAssertNotNil(cart, @"Cart is nil");
                  [self markDoneWithStatus:ATGPass];
                } 
                failure:^(NSObject <ATGRestOperation>  *operation, NSError *error) {
                  STFail(@"Getting shopping cart failed:%@",error);
                
                }
   ];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self waitForCompletion:10];
}
-(void) testComponentValueInvalid{
//  //testing invalid component
  [self prepare];
  [self parseTestData:@"testComponentValueInvalid"];
  
   ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  id operation = [self.session getComponent:@"/atg/commerce/ShoppingCart1" parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionNone
                success:^(NSObject <ATGRestOperation>  *operation , id responseObject ){
                  STFail(@"Getting invalid component should fail");
                } 
                failure:^(NSObject <ATGRestOperation> *operation, NSError *error) {
                  STAssertEquals(404, operation.response.statusCode, @"Error code should be 404"); 
                  [self markDoneWithStatus:ATGPass];
                }
   ];  
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self waitForCompletion:10];
}
#ifdef ATG_MOCK
-(void) testComponentSSLValue{    
  
  [self prepare];  
  
  [self parseTestData:@"testComponentSSLValue"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  id operation = [self.session getComponent:@"/atg/commerce/ShoppingCart" parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionUseHTTPS
                                    success:^( NSObject <ATGRestOperation>  *operation , id responseObject ){
                                      id cart = [responseObject objectForKey:@"cart"];
                                      STAssertNotNil(cart, @"Cart is nil");
                                      [self markDoneWithStatus:ATGPass];
                                    } 
                                    failure:^(NSObject <ATGRestOperation>  *operation, NSError *error) {
                                      STFail(@"Getting shopping cart failed:%@",error);
                                      
                                    }
                  ];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self waitForCompletion:10];
}
#endif

-(void) testComponentPostValue{
  [self prepare];  
  
  [self parseTestData:@"testComponentPostValue"];

  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  id operation = [self.session getComponentAsPost:@"/atg/commerce/ShoppingCart" parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionNone
                      success:^( NSObject <ATGRestOperation> *operation , id responseObject ){
                        id cart = [responseObject objectForKey:@"cart"];
                        STAssertNotNil(cart, @"Cart is nil");
                        [self markDoneWithStatus:ATGPass];
                      } 
                      failure:^(NSObject <ATGRestOperation> *operation, NSError *error) {
                        STFail(@"Getting shopping cart failed:%@",error);
                      }
   ];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}
-(void)testComponentPostValueInvalid{
  //testing invalid component
  [self prepare];  
  
  [self parseTestData:@"testComponentPostValueInvalid"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  
  id operation = [self.session getComponentAsPost:@"/atg/commerce/ShoppingCart1" parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionNone
                      success:^(NSObject <ATGRestOperation>  *operation , id responseObject ){
                        STFail(@"Getting invalid component should fail");
                      } 
                      failure:^(NSObject <ATGRestOperation> *operation, NSError *error) {
                        STAssertEquals(404, operation.response.statusCode, @"Error code should be 404");
                        [self markDoneWithStatus:ATGPass];
                      }
   ];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}

-(void) testServiceRequest{
  [self prepare];  
  
  [self parseTestData:@"testServiceRequest"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"4" forKey:@"atg-rest-depth"];
  [params setObject:@"cartRepriceSubtotal" forKey:ATG_REST_PROPERTY_FILTER_TEMPLATES];
  
  id operation = [self.session executeServiceRequestForComponent:@"/atg/commerce/catalog/ProductCatalog" withArguments:[NSArray arrayWithObjects:@"product",@"xprod2050", nil] requestFactory:orderedFactory options:ATGRestRequestOptionNone
       success:^(NSObject <ATGRestOperation>  *operation , id responseObject ){
         STAssertNotNil(responseObject,@"Products shouldn't be null");
         [self markDoneWithStatus:ATGPass];
    
        } 
        failure:^(NSObject <ATGRestOperation> *operation, NSError *error) {
          STFail(@"Request failed");
        }];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}

-(void) testGetPropertyValue{
  //@"/atg/userprofiling/B2CProfileFormHandler"
  //@"useShippingAddressAsDefault"
  
  [self prepare];  
  
  [self parseTestData:@"testGetPropertyValue"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  id operation = [self.session getPropertyValue:@"useShippingAddressAsDefault" component:@"/atg/userprofiling/B2CProfileFormHandler" parameters:nil requestFactory:orderedFactory options:ATGRestRequestOptionNone success:^(id<ATGRestOperation> operation, id responseObject) {
    NSLog(@"%@", responseObject);
    STAssertNotNil(responseObject,@"Response is null");
    [self markDoneWithStatus:ATGPass];
  } failure:^(id<ATGRestOperation> operation, NSError *error) {
    STFail(@"Request failed");
  }];
  

  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}

-(void) testFormHandler{
//  @"/atg/store/order/purchase/CartFormHandler"
//  @"addItemToOrder"
  
  //http://localhost:7003/rest/bean/atg/store/order/purchase/CartFormHandler/addItemToOrder?locale=en_US&pushSite=storeSiteUS
  //{"atg-rest-return-form-handler-exceptions":true,"_dynSessConf":"-8491561290276411451","atg-rest-return-form-handler-properties":true,"items[0].catalogRefId":"xsku2050","originOfOrder":"mobile","atg-rest-form-tag-priorities":"{addItemCount:10}","addItemCount":"1","items[0].productId":"xprod2050","items[0].quantity":"1","atg-rest-depth":"4","_dyncharset":"utf-8"}
  /*
   {
   "class": "class atg.rest.processor.BeanProcessor$FormHandlerPropertiesAndExceptions",
   "component": {"cart": {
   "appliedPromotions": [],
   "commerceItems": [{
   "appliedPromotions": [],
   "commerceItemId": "ci9000002",
   "listPrice": 29,
   "onSale": false,
   "price": 29,
   "prodId": "xprod2050",
   "qty": 1,
   "salePrice": 0,
   "sku": {
   "displayName": "Gumdrop Lamp",
   "repositoryId": "xsku2050"
   },
   "thumbnailImage": "/crsdocroot/content/images/products/thumb/HOME_GumdropLamp_thumb.jpg",
   "unitPrices": [{
   "quantity": 1,
   "unitPrice": 29
   }]
   }],
   "containsGiftWrap": false,
   "couponCode": null,
   "currencyCode": "USD",
   "discount": 0,
   "shipping": 0,
   "shippingGroupCount": 1,
   "storeCredit": 0,
   "subtotal": 29,
   "tax": 0,
   "total": 29,
   "totalCommerceItemCount": 1
   }},
   "result": true
   }
   */
  [self prepare];
  self.session.sessionConfirmationNumber = @"-8491561290276411451";
  
  [self parseTestData:@"testFormHandler"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
  
  [params setObject:@"4" forKey:ATG_REST_DEPTH];
  [params setObject:@"{addItemCount:10}" forKey:ATG_REST_FORM_TAG_PRIORITIES];
  
  [params setObject:@"1" forKey:@"addItemCount"]; 
  [params setObject:@"xsku2050" forKey:@"items[0].catalogRefId"];
  [params setObject:@"xprod2050" forKey:@"items[0].productId"];
  [params setObject:@"1" forKey:@"items[0].quantity"];
  //this will set the originOfOrder on the cart to mobile, which will qualify the user for mobile promotions
  [params setObject:@"mobile" forKey:@"originOfOrder"];
  
  id operation = [self.session executeFormHandler:@"addItemToOrder" component:@"/atg/store/order/purchase/CartFormHandler" parameters:params requestFactory:orderedFactory options:(ATGRestRequestOptionReturnFormExceptions|ATGRestRequestOptionReturnFormProperties) success:^(id<ATGRestOperation> operation, id responseObject) {
    STAssertNotNil(responseObject,@"Response is null");
    [self markDoneWithStatus:ATGPass];
  } failure:^(id<ATGRestOperation> operation, NSError *error, NSArray *pFormExceptions) {
    STFail(@"Request failed");
  }];  
  
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}

-(void) testFormHandlerError{
  //  @"/atg/store/order/purchase/CartFormHandler"
  //  @"addItemToOrder"
  
  //http://localhost:7003/rest/bean/atg/store/order/purchase/CartFormHandler/addItemToOrder?locale=en_US&pushSite=storeSiteUS
  //{"atg-rest-return-form-handler-exceptions":true,"_dynSessConf":"-8491561290276411451","atg-rest-return-form-handler-properties":true,"items[0].catalogRefId":"xsku2050","originOfOrder":"mobile","atg-rest-form-tag-priorities":"{addItemCount:10}","addItemCount":"1","items[0].productId":"xprod2050","items[0].quantity":"1","atg-rest-depth":"4","_dyncharset":"utf-8"}
  /*
   {
   "class": "class atg.rest.processor.BeanProcessor$FormHandlerPropertiesAndExceptions",
   "component": {"cart": {
   "appliedPromotions": [],
   "commerceItems": [{
   "appliedPromotions": [],
   "commerceItemId": "ci9000002",
   "listPrice": 29,
   "onSale": false,
   "price": 29,
   "prodId": "xprod2050",
   "qty": 1,
   "salePrice": 0,
   "sku": {
   "displayName": "Gumdrop Lamp",
   "repositoryId": "xsku2050"
   },
   "thumbnailImage": "/crsdocroot/content/images/products/thumb/HOME_GumdropLamp_thumb.jpg",
   "unitPrices": [{
   "quantity": 1,
   "unitPrice": 29
   }]
   }],
   "containsGiftWrap": false,
   "couponCode": null,
   "currencyCode": "USD",
   "discount": 0,
   "shipping": 0,
   "shippingGroupCount": 1,
   "storeCredit": 0,
   "subtotal": 29,
   "tax": 0,
   "total": 29,
   "totalCommerceItemCount": 1
   }},
   "result": true
   }
   */
  [self prepare];
  self.session.sessionConfirmationNumber = @"-8491561290276411451";
  
  [self parseTestData:@"testFormHandlerError"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
  
  [params setObject:@"4" forKey:ATG_REST_DEPTH];
  [params setObject:@"{addItemCount:10}" forKey:ATG_REST_FORM_TAG_PRIORITIES];
  
  [params setObject:@"1" forKey:@"addItemCount"]; 
  [params setObject:@"xsku2050x" forKey:@"items[0].catalogRefId"];
  [params setObject:@"xprod2050x" forKey:@"items[0].productId"];
  [params setObject:@"1" forKey:@"items[0].quantity"];
  //this will set the originOfOrder on the cart to mobile, which will qualify the user for mobile promotions
  [params setObject:@"mobile" forKey:@"originOfOrder"];
  
  id operation = [self.session executeFormHandler:@"addItemToOrder" component:@"/atg/store/order/purchase/CartFormHandler" parameters:params requestFactory:orderedFactory options:(ATGRestRequestOptionReturnFormExceptions|ATGRestRequestOptionReturnFormProperties) success:^(id<ATGRestOperation> operation, id responseObject) {    
    STFail(@"Request should have error");    
  } failure:^(id<ATGRestOperation> operation, NSError *error, NSArray *pFormExceptions) {
    STAssertNotNil(pFormExceptions,@"Form exception is null");
    [self markDoneWithStatus:ATGPass];
  }];  
  
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  [self verifyPostBody:operation encoding:self.session.characterEncoding];
  [self waitForCompletion:10];
}

-(void)testGetStateList{
  
  [self prepare];  
  
  [self parseTestData:@"testGetStateListRequest"];
  
  ATGStackedRestRequestFactory *orderedFactory = [self buildFactory];
  
  NSDictionary *params  = [NSDictionary dictionaryWithObject:@"US" forKey:@"countryCode"];
  
  id operation = [self.session executeServiceRequestPostForComponent:@"/atg/commerce/util/StateListDroplet" withArguments:nil parameters:params requestFactory:orderedFactory options:ATGRestRequestOptionNone success:^(id<ATGRestOperation> operation, id pResponseObject) {
      id states = [pResponseObject objectForKey:@"states"];
      STAssertNotNil(states,@"States shouldn't be null");
    [self markDoneWithStatus:ATGPass];
    
  } failure:^(id<ATGRestOperation> pOperation, NSError *pError) {
    STFail(@"Request failed");
  }];
  
  [self waitForCompletion:10];
  STAssertEqualObjects(((AFJSONRequestOperation *)operation).request.URL.absoluteString, self.url,@"URLs should be equal");
  if ([self.body isNotBlank]) {
    NSString *responseBody = [[NSString alloc] initWithData:((AFJSONRequestOperation *)operation).request.HTTPBody encoding:self.session.characterEncoding];  
    STAssertEqualObjects(responseBody,self.body, @"HTTP body doesn't match");
  }

}

@end