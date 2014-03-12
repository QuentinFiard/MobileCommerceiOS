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

#import "EMAssemblerConnectionTestJSON.h"
#import "EMAssemblerConnection.h"
#import "EMAssemblerRequestOperation.h"
#import "EMAssemblerConnectionURLBuilder.h"

@implementation EMAssemblerConnectionTestJSON

- (NSString *)plistName{
    return @"EMAssemblerConnectionTest";
}

-(void) setUp{
  EMAssemblerConnectionURLBuilder *urlBuilder = [[EMAssemblerConnectionURLBuilder alloc] init];
  self.connection = [EMAssemblerConnection connectionWithHost:@"localhost" port:8006 contextPath:@"assembler" responseFormat:EMAssemblerResponseFormatJSON urlBuilder:urlBuilder];
}
-(void) tearDown{
    self.connection = nil;
}

#pragma mark -
#pragma mark  TEST BROWSE

-(void) testBrowse {    
    
    [self prepare];  
    [self parseTestData:@"testBrowse"];
    
    [self.connection fetchContent:@"browse" 
                  forSiteRootPath:@"pages" 
                     actionString:nil 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self markDoneWithStatus:[self testResponse:responseObject forOperation:operation]];
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
    ];
      
    [self waitForCompletion:10];
}

#pragma mark -
#pragma mark  TEST SEARCH

-(void) testSearch {    
    
    [self prepare];  
    [self parseTestData:@"testSearch"];
    
    [self.connection fetchContent:@"browse" 
                  forSiteRootPath:@"pages" 
                     actionString:@"?Ntt=camera" 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self markDoneWithStatus:[self testResponse:responseObject forOperation:operation]];
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
                  ];
    
    [self waitForCompletion:10];
}

-(void) testSearchWithActionPath {    
    
    [self prepare];  
    [self parseTestData:@"testSearchWithActionPath"];
    
    [self.connection fetchContent:@"browse" 
                  forSiteRootPath:@"pages" 
                     actionString:@"bags-cases/_/N-25xw?Ns=product.price%7C0&Ntt=camera" 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self markDoneWithStatus:[self testResponse:responseObject forOperation:operation]];
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
     ];
    
    [self waitForCompletion:10];
}

#pragma mark -
#pragma mark  TEST BAD ACTION

-(void) testBadAction {    
    
    [self prepare];  
    [self parseTestData:@"testBadAction"];
    
    STAssertThrowsSpecificNamed([self.connection fetchContent:@"browse" 
                  forSiteRootPath:@"pages" 
                     actionString:@"?Ntt=camera?" 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
                    ], NSException, @"NSInvalidArgumentException", @"Should Throw an exception");
    
    [self markDoneWithStatus:ATGPass];
}

#pragma mark -
#pragma mark  TEST TRIM ACTION

-(void) testSearchWithActionPathAndPrecedingSlash {    
    
    [self prepare];  
    [self parseTestData:@"testSearchWithActionPath"];
    
    [self.connection fetchContent:@"/browse" 
                  forSiteRootPath:@"/pages" 
                     actionString:@"/bags-cases/_/N-25xw?Ns=product.price%7C0&Ntt=camera" 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self markDoneWithStatus:[self testResponse:responseObject forOperation:operation]];
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
     ];

    [self waitForCompletion:10];
}

#pragma mark -
#pragma mark  TEST TRIM ACTION

-(void) testComplexAction {    
    
    [self prepare];  
    [self parseTestData:@"testComplexAction"];
    
    [self.connection fetchContent:@"/browse" 
                  forSiteRootPath:@"/pages" 
                     actionString:@"/bags-cases/_/N-25xw?Nrpp=%7BrecordsPerPage%7D&Ntt=camera&Ns=product.price%7C0&No=%7Boffset%7D" 
                          success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self markDoneWithStatus:[self testResponse:responseObject forOperation:operation]];
                          } failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              STFail(@"Failed:%@",error);
                          }
     ];
    
    [self waitForCompletion:10];
}

#pragma mark -
#pragma mark RESPONSE VALIDATION

- (ATGStatus)testResponse:(id)pResponseObject forOperation:(EMAssemblerRequestOperation *)pOperation {
    NSString *name = [pResponseObject valueForKey:@"name"];
    
    STAssertEqualObjects(name, self.pageName, @"Failed: Page names should match");
    STAssertEqualObjects(pOperation.request.URL.absoluteString , self.url, @"Failed: URLs should be equal");

    return ATGPass;
}


@end
