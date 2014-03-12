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


#import "ATGCheckoutBillingAddressesViewController.h"
#import "ATGCreditCardInfo.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGCVVViewController.h"

#pragma mark - ATGCheckoutBillingAddressesViewController Private Protocol
#pragma mark -

@interface ATGCheckoutBillingAddressesViewController ()

@property (nonatomic, readwrite, strong) ATGContactInfo *selected;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSMutableArray *addresses;
@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *commerceRequest;

@end

#pragma mark - ATGCheckoutBillingAddressesViewController Implementation
#pragma mark -

@implementation ATGCheckoutBillingAddressesViewController

#pragma mark - Synthesized Properties

@synthesize commerceRequest;
// No @synthesize for selected and request properties, as they're implemented by superclass.

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    self.showsSelection = YES;
  }
  return self;
}

#pragma mark - NSObject

- (void)dealloc {
  [[self commerceRequest] cancelRequest];
}

#pragma mark - ATGAddressesViewController

- (BOOL)hidesDefaults {
  return YES;
}

- (void)createNewAddress {
  //will create new address, request user status
  [self setSelected:nil];
  [[self request] cancelRequest];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getSecurityStatus:self]];
}

- (void) fetchAddresses {
  [commerceRequest cancelRequest];
  [self startActivityIndication:YES];
  commerceRequest = [[ATGCommerceManager commerceManager] getAvailableBillingAddresses:self];
}

- (void)didReloadAddresses {
  [super didReloadAddresses];
  if ([[self addresses] count] == 0) {
    [self createNewAddress];
    self.createCell.hidden = YES;
  }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.BillingAddressTitle", nil, [NSBundle mainBundle],
       @"Billing Addresses", @"Title to be displayed on the top of the screen.");
  NSString *create = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateBillingAddressButton", nil, [NSBundle mainBundle],
       @"Create a New Billing Address", @"Create address button caption.");
  NSString *acclbl = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateBillingAddressButtonAccessibilityLabel", nil, [NSBundle mainBundle],
       @"Create a New Billing Address", @"Create profile address button accessibility label.");
  NSString *acchint = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateBillingAddressButtonAccessibilityHint", nil, [NSBundle mainBundle],
       @"Will create a New Billing Address Button", @"Create profile address button accessibility hint.");

  [self setTitle:title];
  UILabel *lbl = (UILabel *)[[self createCell] viewWithTag:1];
  lbl.text = create;
  [lbl setAccessibilityLabel:acclbl];
  [lbl setAccessibilityHint:acchint];
  [lbl setAccessibilityTraits:UIAccessibilityTraitButton];
  self.tableView.backgroundColor = [UIColor tableBackgroundColor];
}

- (void)viewDidUnload {
  [[self commerceRequest] cancelRequest];
  [self setCommerceRequest:nil];
  [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:ATGSegueIdBillingAddressesToCVV]) {
    ATGCVVViewController *ctrl = pSegue.destinationViewController;
    ctrl.card = self.creditCard;
    ctrl.type = ValidateFromEditAddr;
  } else if ([pSegue.identifier isEqualToString:ATGSegueIdBillingAddressesToCheckoutBillingAddressEdit]) {
    ATGCheckoutBillingAddressEditController *editor = pSegue.destinationViewController;
    editor.address = [[self selected] copy];
    editor.creditCard = self.creditCard;
    editor.defaultAddressSelected = [[self selected] useShippingAddressAsDefault];
    editor.userAnonymous = self.userAnonymous;
  } else if ([pSegue.identifier isEqualToString:ATGSegueIdBillingAddressesToProfileBillingAddressEdit]) {
    ATGProfileBillingAddressEditController *editor = pSegue.destinationViewController;
    editor.address = [[self selected] copy];
    editor.creditCard = self.creditCard;
    editor.defaultAddressSelected = [[self selected] useShippingAddressAsDefault];
    editor.userAnonymous = self.userAnonymous;
  } else {
    [super prepareForSegue:pSegue sender:pSender];
  }
}

#pragma mark - Address selection

- (void)didSelectAddress {
  [[ATGCreditCardInfo cardInfo] setBillAddrName:[[self selected] nickname]];
  [self performSegueWithIdentifier:ATGSegueIdBillingAddressesToCVV sender:self];
}

- (void)editAddressWithUserStatus:(BOOL)pAnonymous {
  self.userAnonymous = pAnonymous;
  [self performSegueWithIdentifier:ATGSegueIdBillingAddressesToCheckoutBillingAddressEdit sender:self];
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didGetAvailableBillingAddresses:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSArray *addrs = [pRequest requestResults];
  [self reloadAddresses:addrs];
  [self setCommerceRequest:nil];
}

- (void) didErrorGettingAvailableBillingAddresses:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [self setCommerceRequest:nil];
}

@end