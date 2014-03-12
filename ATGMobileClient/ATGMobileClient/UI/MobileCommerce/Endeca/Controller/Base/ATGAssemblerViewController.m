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

#import <EMMobileClient/EMContentItem.h>
#import "ATGAssemblerViewController.h"
#import "ATGAssemblerConnectionManager.h"
#import "ATGContentPathLookupManager.h"
#import "ATGAdaptorManager.h"
#import "ATGJSONParser.h"
#import "UIDevice+ATGAdditions.h"
#import "ATGAdaptorManager_iPad.h"

NSString *const ATG_SITE_CONTEXT_KEY = @"atg:currentSiteProductionURL";

@implementation ATGAssemblerViewController

-(EMConnectionManager*) connectionManager {
  return [ATGAssemblerConnectionManager sharedManager];
}

- (EMContentPathLookupManager *)contentPathLookupManager {
  return [ATGContentPathLookupManager contentPathLookupManager];
}

- (id)init {
  if ((self = [super init])) {
    [self setup];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setup];
}

- (void)setup {
  if ([UIDevice isPhone])
    self.adaptorManager = [[ATGAdaptorManager alloc] init];
  else
    self.adaptorManager = [[ATGAdaptorManager_iPad alloc] init];
}

- (void)connection:(EMAssemblerConnection *)pConnection didSubmitAction:(EMAction *)pAction {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(EMAssemblerConnection *)pConnection didReceiveResponseObject:(id)pResponseObject {
  [super connection:pConnection didReceiveResponseObject:pResponseObject];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(EMAssemblerConnection *)pConnection didFailWithError:(NSError *)pError {
  [super connection:pConnection didFailWithError:pError];

  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                      message:[pError localizedDescription]
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
  [alertView show];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (EMContentItem *)parseResponseObject:(id)pResponseObject {
  if ([pResponseObject isKindOfClass:[NSData class]]) {
    NSError *error = nil;
    pResponseObject = [NSJSONSerialization JSONObjectWithData:pResponseObject options:kNilOptions error:&error];
  }
  EMContentItem *contentItem = [[[ATGJSONParser alloc] init] parseDictionary:(NSDictionary *)pResponseObject];
  [self updateContextPathWithContentItem:contentItem];
  return contentItem;
}

- (void)updateContextPathWithContentItem:(EMContentItem *)pContentItem {
  NSString *contextPath = [pContentItem.attributes valueForKey:ATG_SITE_CONTEXT_KEY];
  ATGAssemblerConnectionManager *manager = (ATGAssemblerConnectionManager *)[self connectionManager];
  if (contextPath && ![contextPath isEqualToString:manager.connection.contextPath])
    manager.connection = [EMAssemblerConnection connectionWithHost:manager.connection.host port:manager.connection.port contextPath:contextPath responseFormat:manager.connection.responseFormat urlBuilder:manager.connection.urlBuilder];
}

//TODO: UIAlertView has a unsafe assign delegate, in the event that we are
//being destructed while an alertview is being shown we need to make sure we
//nil out its delegate or the app will crash. We are already adding the alertview
//to this map to handle the case of a adaptor being destroyed (it is the actual delegate)
//while the alertview is visible. The adaptorAttributes dictionary holds a temporary references
//until the adaptor can finish performing the call back duties. However if the
//controller and thus, adaptorAttributes die we have no choice but to do this ugly delegate clearing
//The Todo should be a reminder to keep an eye out for a better solution
- (void)dealloc {
  for (id obj in [self.adaptorManager.adaptorAttributes allKeys]) {
    if ([obj isKindOfClass:[NSValue class]]) {
      NSValue *val = (NSValue *)obj;
      id valOfVal = [val nonretainedObjectValue];
      if ([valOfVal isKindOfClass:[UIAlertView class]]) {
        UIAlertView *av = (UIAlertView *)valOfVal;
        av.delegate = nil;
      }
    }
  }
}

@end
