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


#import "ATGInternalProfileManager.h"
#import <iOS-rest-client/ATGInternalProfileLoginHandler.h>
#import "ATGProfileManagerRequest.h"

@implementation ATGInternalProfileManager

@synthesize restManager;

static ATGInternalProfileManager *profileManager;

+ (ATGInternalProfileManager *)profileManager {
  static dispatch_once_t pred_profile_manager;
  dispatch_once(&pred_profile_manager,
    ^{
      profileManager = [[ATGInternalProfileManager alloc] init];
      profileManager.getProfileActorChain = @"/atg/userprofiling/InternalProfileActor/info";
    }
  );
  return profileManager;
}

- (ATGRestManager *) restManager {
  static dispatch_once_t pred_rest_manager;
  dispatch_once(&pred_rest_manager,
    ^{
      restManager = [ATGRestManager restManager];
      [restManager.restSession setLoginHandler:[[ATGInternalProfileLoginHandler alloc] initWithRestSession:restManager.restSession]];
    }
  );
  return restManager;
}

- (ATGProfileManagerRequest *) login:(NSString *)pLogin withPassword:(NSString *)pPassword
                            delegate:(id <ATGProfileManagerDelegate>)pDelegate {
  ATGProfileManagerRequest *profileRequest = [[ATGProfileManagerRequest alloc] initWithProfileManager:self];
  profileRequest.delegate = pDelegate;
  SEL loginErrorSelector = @selector(didErrorLoggingIn:);
  SEL loginSelector = @selector(didLogIn:);

  [self.restManager.restSession setUsername:pLogin];
  [self.restManager.restSession setPassword:pPassword];

  id <ATGRestOperation> operation = [self.restManager.restSession login:nil options:ATGRestRequestOptionNone success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
    NSError *error = [ATGRestManager checkForError:pResponseObject];
    if (![profileRequest sendError:error withSelector:loginErrorSelector]) {

      [profileRequest setRequestResults:pResponseObject];
      [profileRequest sendResponse:loginSelector];

      // pre-cache this user's information.  Don't worry about failures here.
      [self getProfile:nil];
    }
  }
  failure: ^(id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions) {
    DebugLog(@"Login attempt failed");
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

  id <ATGRestOperation> operation = [self.restManager.restSession logout:nil options:(ATGRestRequestOptionNone) success: ^(id < ATGRestOperation > pOperation, id pResponseObject) {
    NSError *error = [ATGRestManager checkForError:pResponseObject];
    if (![profileRequest sendError:error withSelector:logoutErrorSelector]) {
      [self clearAllCache];
      [profileRequest sendResponse:logoutSelector];
    }
  }
  failure: ^(id <ATGRestOperation> pOperation, NSError *pError, NSArray *pFormExceptions) {
    DebugLog(@"Logout attempt failed");
    [profileRequest sendError:pError withSelector:logoutErrorSelector];
  }
  ];

  profileRequest.operation = operation;

  return profileRequest;
}


@end
