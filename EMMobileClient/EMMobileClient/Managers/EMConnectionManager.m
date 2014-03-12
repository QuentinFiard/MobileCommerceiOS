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

#import "EMConnectionManager.h"
#import "EMAction.h"

static EMConnectionManager *connectionManager;

NSString *const ENDECA_HOST = @"localhost";
NSInteger const ENDECA_PORT = 8006;
NSString *const ENDECA_CONTEXT_PATH = @"assembler";

EMAssemblerResponseFormat const ENDECA_RESPONSE_FORMAT = EMAssemblerResponseFormatJSON;

@interface EMConnectionManager () 
- (void)connection:(EMAssemblerConnection *)pConnection willSubmitAction:(EMAction *)pAction withDelegate:(id<EMConnectionManagerDelegate>)pDelegate;
- (void)connection:(EMAssemblerConnection *)pConnection didSubmitAction:(EMAction *)pAction withDelegate:(id<EMConnectionManagerDelegate>)pDelegate;
- (void)connection:(EMAssemblerConnection *)pConnection didReceiveResponseObject:(id)pResponseObject withDelegate:(id<EMConnectionManagerDelegate>)pDelegate;
- (void)connection:(EMAssemblerConnection *)pConnection didFailWithError:(NSError *)pError andDelegate:(id<EMConnectionManagerDelegate>)pDelegate;
@end

@implementation EMConnectionManager
@synthesize connection = _connection;

- (id)init {
  // This isn't the proper way to construct a new EMConnectionManager.  We'll provide some defaults
  // but a client should be calling initWithHost.
  EMAssemblerConnectionURLBuilder *urlBuilder = [[EMAssemblerConnectionURLBuilder alloc] init];
  return [self initWithHost:ENDECA_HOST port:ENDECA_PORT contextPath:ENDECA_CONTEXT_PATH urlBuilder:urlBuilder];
}

- (id)initWithHost:(NSString*)pHost port:(NSInteger)pPort contextPath:(NSString*)pContextPath urlBuilder:(EMAssemblerConnectionURLBuilder*)pURLBuilder {
  self = [super init];
  if (self) {
    self.connection = [EMAssemblerConnection connectionWithHost:pHost port:pPort contextPath:pContextPath responseFormat:ENDECA_RESPONSE_FORMAT urlBuilder:pURLBuilder];
  }
  return self;
}

+ (EMConnectionManager *)sharedManager {
  static dispatch_once_t pred_connection_manager;
  dispatch_once(&pred_connection_manager,
                ^{
                  EMAssemblerConnectionURLBuilder *urlBuilder = [[EMAssemblerConnectionURLBuilder alloc] init];
                  connectionManager = [[EMConnectionManager alloc] initWithHost:ENDECA_HOST port:ENDECA_PORT contextPath:ENDECA_CONTEXT_PATH urlBuilder: urlBuilder];
                  }
                );
  return connectionManager;
}

- (void)submitAction:(EMAction *)pAction withDelegate:(id<EMConnectionManagerDelegate>)pDelegate {
  DebugLog(@"EMConnectionManager.submitAction: @%", pAction);
  [self connection:self.connection willSubmitAction:pAction withDelegate:pDelegate];
    
  [self.connection fetchContent:pAction.contentPath
                   forSiteRootPath:pAction.siteRootPath
                   actionString:pAction.state
                   success:^(EMAssemblerRequestOperation *operation , id responseObject ){
                              [self connection:self.connection didReceiveResponseObject:responseObject withDelegate:pDelegate];
                            }
                   failure:^(EMAssemblerRequestOperation *operation, NSError *error) {
                              [self connection:self.connection didFailWithError:error andDelegate:pDelegate];
                            } 
  ];
  [self connection:self.connection didSubmitAction:pAction withDelegate:pDelegate];
}

- (void)connection:(EMAssemblerConnection *)pConnection willSubmitAction:(EMAction *)pAction withDelegate:(id<EMConnectionManagerDelegate>)pDelegate {
  if ([pDelegate respondsToSelector:@selector(connection:willSubmitAction:)]) {
    [pDelegate connection:pConnection willSubmitAction:pAction];
  }
}

- (void)connection:(EMAssemblerConnection *)pConnection didSubmitAction:(EMAction *)pAction withDelegate:(id<EMConnectionManagerDelegate>)pDelegate {
  if ([pDelegate respondsToSelector:@selector(connection:didSubmitAction:)]) {
    [pDelegate connection:pConnection didSubmitAction:pAction];
  }
}

- (void)connection:(EMAssemblerConnection *)pConnection didReceiveResponseObject:(id)pResponseObject withDelegate:(id<EMConnectionManagerDelegate>)pDelegate {
  DebugLog(@"EMConnectionManager.didReceiveResponseObject: @%", pResponseObject);
  if ([pDelegate respondsToSelector:@selector(connection:didReceiveResponseObject:)]) {
    [pDelegate connection:pConnection didReceiveResponseObject:pResponseObject];
  }
}

- (void)connection:(EMAssemblerConnection *)pConnection didFailWithError:(NSError *)pError andDelegate:(id<EMConnectionManagerDelegate>)pDelegate {
  if ([pDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
    [pDelegate connection:pConnection didFailWithError:pError];
  }
}

@end
