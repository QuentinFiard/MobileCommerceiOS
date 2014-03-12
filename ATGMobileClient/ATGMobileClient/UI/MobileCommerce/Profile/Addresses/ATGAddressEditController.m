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

#import "ATGAddressEditController.h"
#import <ATGMobileClient/ATGContactInfo.h>

NSUInteger const ATGAddressNickNameInputLimit = 42;
NSUInteger const ATGAddressFirstNameInputLimit = 40;
NSUInteger const ATGAddressLastNameInputLimit = 40;
NSUInteger const ATGAddressStreet1InputLimit = 40;
NSUInteger const ATGAddressStreet2InputLimit = 40;
NSUInteger const ATGAddressCityInputLimit = 30;
NSUInteger const ATGAddressStateInputLimit = 40;
NSUInteger const ATGAddressCountryInputLimit = 40;
NSUInteger const ATGAddressZipInputLimit = 10;
NSUInteger const ATGAddressPhoneInputLimit = 15;
NSUInteger const ATGAddressDefaultInputLimit = 40;

static const CGFloat ATGDefaultScreenWidth = 320;

#pragma mark - ATGAddressEditController Private Protocol
#pragma mark -

@interface ATGAddressEditController ()

#pragma mark - Custom Properties

@property (nonatomic, readwrite, assign) BOOL creating;
@property (nonatomic, readwrite, strong) ATGAddressSection *addressSection;

#pragma mark - Private Protocol Definition

- (void)createAddressSection;
- (void)showContactPicker;

@end

#pragma mark - ATGAddressEditController Implementation
#pragma mark -

@implementation ATGAddressEditController

#pragma mark - Synthesized Properties

@synthesize userAnonymous, defaultAddressSelected, address, creditCard;
@synthesize creating;
@synthesize addressSection;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  if ([self address]) {
    [self setCreating:NO];
  } else {
    [self setCreating:YES];

    //set defaults
    [self setAddress:[[ATGContactInfo alloc] init]];
  }

  [self address].newNickname = [self address].nickname;
  NSString *title;
  if ([self creating]) {
    title = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.ControllerTitle.Create", nil, [NSBundle mainBundle],
         @"New Address", @"Title to be displayed on the top of the screen for new address.");
  } else {
    title = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.ControllerTitle.Edit", nil, [NSBundle mainBundle],
         @"Edit Address", @"Title to be displayed on the top of the screen for editing of an address.");
  }

  [self setTitle:title];
  if ([self isPad]) {
    title = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.ContactsCaption", nil, [NSBundle mainBundle],
         @"Contacts", @"Caption for navigation bar button item, that shows picker view with contacts");

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(showContactPicker)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
  }

  [self createAddressSection];
}

- (void)viewDidUnload {
  [[self addressSection] viewDidUnload];
  [self setAddressSection:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self addressSection] viewWillAppear:pAnimated];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [super viewWillDisappear:pAnimated];
  [[self addressSection] viewWillDisappear:pAnimated];
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  [[self addressSection] prepareForSegue:pSegue sender:pSender];
}

- (CGSize)contentSizeForViewInPopover {
 return self.tableView.contentSize;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return [[self addressSection] numberOfSections];
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [[self addressSection] numberOfRowsInSection:pSection];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  return [[self addressSection] cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  [[self addressSection] willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
}

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  return [[self addressSection] heightForRowAtIndexPath:pIndexPath];
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [[self addressSection] didSelectRowAtIndexPath:pIndexPath];
}

#pragma mark - Private Protocol Implementation

- (void) createAddressSection {
  [self setAddressSection:[[ATGAddressSection alloc] init]];
  [self addressSection].delegate = self;
  [self addressSection].width = ATGPhoneScreenWidth;
  [self addressSection].address = [self address];
  [self addressSection].creditCard = [self creditCard];
  [self addressSection].creating = [self creating];
  [self addressSection].showsContacts = ![self isPad];
  [self addressSection].showsNickname = YES;
  [self addressSection].showsMarkDefault = NO;
  [self addressSection].showsDelete = ![self creating];
  [[self addressSection] viewDidLoad];
}

- (void)showContactPicker {
  [[self addressSection] showContactPicker];
}

@end