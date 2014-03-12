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

#import "ATGAccountViewController.h"
#import <ATGMobileClient/ATGProfile.h>
#import <ATGMobileClient/ATGKeychainManager.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGExternalProfileManager.h>

static const CGFloat ATGDefaultScreenWidth = 320;
static const CGFloat ATGDefaultScreenHeight = 270;

#pragma mark - ATGAccountViewController Private Protocol
#pragma mark -

@interface ATGAccountViewController () <ATGProfileManagerDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *logoutCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *changePasswordCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *personalInfoCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *creditCardsCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *addressesCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *ordersCell;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *returnsCell;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfile *profile;
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSNumberFormatter *numberFormatter;

@end

#pragma mark - ATGAccountViewController Implementation
#pragma mark -

@implementation ATGAccountViewController

#pragma mark - Synthesized Properties

@synthesize logoutCell;
@synthesize changePasswordCell;
@synthesize personalInfoCell;
@synthesize creditCardsCell;
@synthesize addressesCell;
@synthesize ordersCell;
@synthesize returnsCell;
@synthesize profile;
@synthesize activityIndicator;
@synthesize request;
@synthesize numberFormatter;

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setNumberFormatter:[[NSNumberFormatter alloc] init]];
  [[self numberFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileViewController.ControllerTitle",
       nil, [NSBundle mainBundle], @"My Account",
       @"Title to be displayed at the top of the 'My Account' screen.");
  [self setTitle:title];

  UIActivityIndicatorView *spinner =
      [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [spinner setHidesWhenStopped:YES];
  CGRect bounds = [[self view] bounds];
  CGPoint center = CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) );
  [spinner setCenter:center];
  [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleTopMargin |
                               UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleBottomMargin];
  [[self tableView] setBackgroundView:spinner];
  [self setActivityIndicator:spinner];

  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileViewController.LogoutCaption",
       nil, [NSBundle mainBundle], @"Logout",
       @"Caption to be used by the button which logs user out.");
  [[[self logoutCell] textLabel] setText:title];
  [[self logoutCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewController.Accessibility.Hint.Logout",
      nil, [NSBundle mainBundle], @"Double tap to logout.",
      @"Accessibility hint to be used by Logout button on MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileViewController.ChangePasswordCaption",
       nil, [NSBundle mainBundle], @"Change Password",
       @"Caption to be used by the button starting a change password process.");
  [[[self changePasswordCell] textLabel] setText:title];
  [[self changePasswordCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewController.Accessibility.Hint.ChangePassword",
      nil, [NSBundle mainBundle], @"Double tap to change your password.",
      @"Accessibility hint to be used by the ChangePassword button on MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGAccountViewController.PersonalInformationCaption",
       nil, [NSBundle mainBundle], @"Personal Info",
       @"Caption to be used by the button starting an edit profile process.");
  [[[self personalInfoCell] textLabel] setText:title];
  [[self personalInfoCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewController.Accessibility.Hint.EditProfile",
      nil, [NSBundle mainBundle], @"Double tap to edit your personal data.",
      @"Accessibility hint to be used by the EditProfile button on the MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGAccountViewController.CreditCardsCaption",
       nil, [NSBundle mainBundle], @"Credit Cards",
       @"Caption to be used by the button opening a list of credit cards.");
  [[[self creditCardsCell] textLabel] setText:title];
  [[self creditCardsCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewController.Accessibility.Hint.CreditCards",
      nil, [NSBundle mainBundle], @"Double tap to explore saved credit cards.",
      @"Accessibility hint to be used by the CreditCards button on the MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGAccountViewController.AddressesCaption",
       nil, [NSBundle mainBundle], @"Addresses",
       @"Caption to be used by the button opening a list of addresses.");
  [[[self addressesCell] textLabel] setText:title];
  [[self addressesCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewController.Accessibility.Hint.Addresses",
      nil, [NSBundle mainBundle], @"Double tap to explore saved addresses.",
      @"Accessibility hint to be used by the Addresses button on the MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGAccountViewController.OrdersCaption",
       nil, [NSBundle mainBundle], @"Orders",
       @"Caption to be used by the button opening a list of submitted orders.");
  [[[self ordersCell] textLabel] setText:title];
  [[self ordersCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGAccountViewcontroller.Accessibility.Hint.Orders",
      nil, [NSBundle mainBundle], @"Double tap to explore previously placed orders.",
      @"Accessibility hint to be used by the Orders button on the MyAccount screen.")];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGAccountViewController.ReturnssCaption",
       nil, [NSBundle mainBundle], @"Returns History",
       @"Caption to be used by the button opening a list of submitted returns.");
  [[[self returnsCell] textLabel] setText:title];
  [[self returnsCell] setAccessibilityHint:NSLocalizedStringWithDefaultValue
    (@"ATGAccountViewcontroller.Accessibility.Hint.Returns",
     nil, [NSBundle mainBundle], @"Double tap to explore previously submitted returns.",
     @"Accessibility hint to be used by the Returns button on the MyAccount screen.")];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
  }
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self activityIndicator] startAnimating];
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (CGSize)contentSizeForViewInPopover {
  return self.tableView.contentSize;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [self profile] ? [super tableView:pTableView numberOfRowsInSection:pSection] : 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  switch ([pIndexPath row]) {
    case 0:
      [[pCell detailTextLabel] setText:[[self profile] firstName]];
      break;
    default:
      break;
  }
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 0) {
    [self setRequest:[[ATGExternalProfileManager profileManager] logout:self]];
  }
}

#pragma mark - ATGProfileManagerDelegate

- (void)didGetProfile:(ATGProfileManagerRequest *)pRequest {
  [[self activityIndicator] stopAnimating];
  [self setProfile:[pRequest requestResults]];
  [[self tableView] reloadData];
  [[ATGKeychainManager instance] setString:[[self profile] firstName] forKey:ATG_KEYCHAIN_NAME_PROPERTY];
  
  if (IS_IPAD) {
   [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (void)didErrorGettingProfile:(ATGProfileManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

- (void)didLogOut:(ATGProfileManagerRequest *)pRequest {
  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_NAME_PROPERTY];

  if (IS_IPAD) {
    [[ATGRootViewController_iPad rootViewController] reloadHomepage];
    [self presentLoginViewControllerAnimated:YES];
  } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

- (void)didErrorLoggingOut:(ATGProfileManagerRequest *)pRequest {
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
}

- (void)requiresLogin {
  [self presentLoginViewControllerAnimated:YES];
}

@end