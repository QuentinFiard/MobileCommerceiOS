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

#import "ATGShippingAddressesViewController.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGCheckoutShippingMethodViewController.h"

static NSString *const ATGAddressesToShippingMethodsSegue = @"shippingAddressesToShippingMethods";
static NSString *const ATGAddressesToEditAddressSegue = @"shippingAddressesToShippingAddressEdit";

#pragma mark - ATGShippingAddressesViewController Private Protocol
#pragma mark -

@interface ATGShippingAddressesViewController ()

@property (nonatomic, readwrite, assign) BOOL enforcesNewAddressScreen;
@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *commerceRequest;
// No @synthesize for these properties, as we're simulating protected properties.
@property (nonatomic, readwrite, strong) ATGContactInfo *selected;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSMutableArray *addresses;

@end

#pragma mark - ATGShippingAddressesViewController Implementation
#pragma mark -

@implementation ATGShippingAddressesViewController

#pragma mark - Synthesized Properties

@synthesize shippingMethods, currencyCode;
@synthesize enforcesNewAddressScreen;
@synthesize commerceRequest;

#pragma mark - NSObject

- (void) dealloc {
  [[self commerceRequest] cancelRequest];
}

#pragma mark - ATGAddressesViewController

- (BOOL) hidesDefaults {
  return YES;
}

- (void) createNewAddress {
  //will create new address, request user status
  [self setSelected:nil];
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getSecurityStatus:self]];
}

- (void) fetchAddresses {
  [commerceRequest cancelRequest];
  [self startActivityIndication:YES];
  [self setCommerceRequest:[[ATGCommerceManager commerceManager] getAvailableShippingAddress:self]];
}

- (void) didReloadAddresses {
  [super didReloadAddresses];
  if ([[self addresses] count] == 0) {
    [self setEnforcesNewAddressScreen:YES];
    [self createNewAddress];
    self.createCell.hidden = YES;
  }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.ShippingAddressTitle", nil, [NSBundle mainBundle],
       @"Shipping Address", @"Title to be displayed on the top of the screen.");
  NSString *create = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateShippingAddressButton", nil, [NSBundle mainBundle],
       @"Create a Shipping Address", @"Create address button caption.");
  NSString *acclbl = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateShippingAddressButtonAccessibilityLabel", nil, [NSBundle mainBundle],
       @"Create a Shipping Address Button", @"Create shipping address button accessibility label.");
  NSString *acchint = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateShippingAddressButtonAccessibilityHint", nil, [NSBundle mainBundle],
       @"Will create a Shipping Address", @"Create shipping address button accessibility hint.");
  [self setTitle:title];
  UILabel *lbl = (UILabel *)[[self createCell] viewWithTag:1];
  lbl.text = create;
  [lbl applyStyleWithName:@"formTitleLabel"];
  [lbl setAccessibilityLabel:acclbl];
  [lbl setAccessibilityHint:acchint];
  [lbl setAccessibilityTraits:UIAccessibilityTraitButton];
  self.tableView.backgroundColor = [UIColor tableBackgroundColor];
}

- (void)viewDidUnload {
  [[self commerceRequest] cancelRequest];
  [self setCommerceRequest:nil];
  [self setShippingMethods:nil];
  [self setCurrencyCode:nil];

  [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:ATGAddressesToShippingMethodsSegue]) {
    ATGCheckoutShippingMethodViewController *ctrl = pSegue.destinationViewController;
    ctrl.shippingMethods = [self shippingMethods];
    ctrl.currencyCode = [self currencyCode];
  } else {
    UIViewController *destination = [pSegue destinationViewController];
    if ([destination isKindOfClass:[ATGShippingAddressEditController class]]) {
      [(ATGShippingAddressEditController *)destination
          setShouldRemovePreviousController:[self enforcesNewAddressScreen]];
      [(ATGShippingAddressEditController *)destination setUserAnonymous:[self isUserAnonymous]];
    }
    [super prepareForSegue:pSegue sender:pSender];
  }
}

#pragma mark - Address selection

- (void)didSelectAddress {
  [self startActivityIndication:YES];

  [[self commerceRequest] cancelRequest];
  [self setCommerceRequest:[[ATGCommerceManager commerceManager]
                            shipToExistingAddress:[[self selected] nickname] delegate:self]];
}

- (void)editAddressWithUserStatus:(BOOL)pAnonymous {
  [self performSegueWithIdentifier:ATGAddressesToEditAddressSegue sender:self];
}

#pragma mark - Commerce manager delegate

- (void)didShipToExistingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];

  [self setShippingMethods:[pRequest.requestResults objectForKey:@"availableShippingMethods"]];
  [self setCurrencyCode:[pRequest.requestResults objectForKey:@"currencyCode"]];
  [self setCommerceRequest:nil];

  if ([self.delegate respondsToSelector:@selector(navigateOnSelection)]) {
    [self.delegate navigateOnSelection];
  } else {
    [self performSegueWithIdentifier:ATGAddressesToShippingMethodsSegue sender:self];
  }
}

- (void)didErrorShippingToExistingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [self setCommerceRequest:nil];
}

- (void) didGetAvailableShippingAddresses:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSArray *addrs = [pRequest requestResults];
  [self reloadAddresses:addrs];
  [self setCommerceRequest:nil];
}

- (void) didErrorGettingAvailableShippingAddresses:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [self setCommerceRequest:nil];
}

@end