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

#import "ATGShippingAddressSection.h"
#import "ATGShippingAddressesViewController.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

#pragma mark - ATGShippingAddressSection Implementation
#pragma mark -

@implementation ATGShippingAddressSection

#pragma mark - ATGAddressSection

- (void)viewDidLoad {
  [super viewDidLoad];
  if ([self isPad] && [self creating]) {
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGShippingAddressSection.DoneButtonTitle",
         nil, [NSBundle mainBundle], @"Deliver to this Address",
         @"Title to be used for the form dispatching button on the 'Create Shipping Address' screen.");
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(willSubmitDone)];
    [button setWidth:ATGPhoneScreenWidth];
    [[self delegate] setToolbarItems:[NSArray arrayWithObject:button]];
  }
}

- (void)didSubmitDone {
  [self.delegate startActivityIndication:YES];
  [[self request] cancelRequest];
  if (self.creating) {
    [self setRequest:[[ATGCommerceManager commerceManager] shipToNewAddress:[self.address copy]
                                                           andSaveToProfile:[self shouldUpdateProfile]
                                                                   delegate:self]];
  } else {
    [self setRequest:[[ATGCommerceManager commerceManager] editShippingAddress:[self.address copy]
                                                           withCurrentNickname:[self.address nickname]
                                                                      delegate:self]];
  }
}

- (void)submitDelete {
  [self.delegate startActivityIndication:YES];
  [[self request] cancelRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] removeAddress:self.address.nickname delegate:self]];
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didShipToNewAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  if ([self.delegate respondsToSelector:@selector(updateShippingMethods:currencyCode:)]) {
    NSArray *shippingMethods = [pRequest.requestResults objectForKey:@"availableShippingMethods"];
    NSString *currencyCode = [pRequest.requestResults objectForKey:@"currencyCode"];
    [self.delegate performSelector:@selector(updateShippingMethods:currencyCode:)
                        withObject:shippingMethods
                        withObject:currencyCode];
  }
  [self setRequest:nil];
}

- (void)didErrorShippingToNewAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  [self.delegate tableView:self.delegate.tableView
                  setError:[pRequest error]
                 inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void)didEditShippingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  [self.delegate.navigationController popViewControllerAnimated:YES];
  [self setRequest:nil];
}

- (void)didErrorEditingShippingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  [self.delegate tableView:self.delegate.tableView
                  setError:[pRequest error]
                 inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void)didRemoveShippingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  [self.delegate.navigationController popViewControllerAnimated:YES];
  [self setRequest:nil];
}

- (void)didErrorRemovingShippingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self.delegate stopActivityIndication];
  [self.delegate tableView:self.delegate.tableView
                  setError:[pRequest error]
                 inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void)didRemoveAddress:(ATGProfileManagerRequest *)pRequestResults {
  [self.delegate stopActivityIndication];
  [self.delegate.navigationController popViewControllerAnimated:YES];
  [self setRequest:nil];
}

- (void)didErrorRemovingAddress:(ATGProfileManagerRequest *)pRequestResults {
  [self.delegate stopActivityIndication];
  [self.delegate tableView:self.delegate.tableView
                  setError:[pRequestResults error]
                 inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

@end