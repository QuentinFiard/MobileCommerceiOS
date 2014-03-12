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

#import "ATGProfileViewController.h"
#import "ATGCheckoutDefaultsViewController.h"
#import <ATGMobileClient/ATGAddressesViewController.h>
#import "MobileCommerceAppDelegate.h"
#import <ATGMobileClient/ATGKeychainManager.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

static NSString *const ATGProfileToPasswordSegue = @"profileToChangePassword";
static NSString *const ATGProfileToEditProfileSegue = @"profileToProfileEdit";
static NSString *const ATGProfileToOrdersSegue = @"profileToOrders";
static NSString *const ATGProfileToAddressesSegue = @"profileToAddresses";
static NSString *const ATGProfileToCardsSegue = @"profileToCreditCards";
static NSString *const ATGProfileToCheckoutDefaultsSegue = @"profileToCheckoutDefaults";

#pragma mark - ATGPersonalInfoTableViewCell
#pragma mark -

@interface ATGPersonalInfoTableViewCell : UITableViewCell

@property (nonatomic, readwrite, weak) UILabel *captionLabel;
@property (nonatomic, readwrite, weak) UILabel *infoLabel;

@end

#pragma mark - ATGPartlySelectableTableViewCell Interface
#pragma mark -

@interface ATGPartlySelectableTableViewCell : UITableViewCell

@property (nonatomic, readwrite, weak) UIButton *innerButton;
@property (nonatomic, readwrite, weak) UILabel *innerLabel;

@end

#pragma mark - ATGProfileViewController Private Protocol
#pragma mark -

@interface ATGProfileViewController () <ATGCommerceManagerDelegate, ATGProfileManagerDelegate,
    ATGAddressesViewControllerDelegate>

#pragma mark - IB Outlests

@property (nonatomic, readwrite, weak) IBOutlet ATGPartlySelectableTableViewCell *cellLogout;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *cellPersonalInfo;
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *cellCheckoutDefaults;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelPersonalInfo;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelShipToCaption;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelShipViaCaption;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelUseCardCaption;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelShipTo;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelShipVia;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelUseCard;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *buttonLogout;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelChangePassword;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelPersonalInfoCaption;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelCheckoutDefaults;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelOrders;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelReturns;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelAddresses;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelCreditCards;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelOrdersCount;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelReturnsCount;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelAddressesCount;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *labelCreditCardsCount;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, readwrite, strong) ATGProfile *profile;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;

#pragma mark UI Event Handlers

- (IBAction)didTouchLogoutButton:(id)sender;

@end

#pragma mark - ATGProfileViewController Implementation
#pragma mark -

@implementation ATGProfileViewController

#pragma mark - Synthesized Properties

@synthesize labelPersonalInfo, labelShipToCaption, labelShipViaCaption,
    labelUseCardCaption, labelShipTo, labelShipVia, labelUseCard,
    buttonLogout, labelChangePassword, labelPersonalInfoCaption, labelCheckoutDefaults,
    cellLogout, cellPersonalInfo, cellCheckoutDefaults, labelAddresses,
    labelAddressesCount, labelOrders, labelOrdersCount, labelReturns, labelReturnsCount, labelCreditCards, labelCreditCardsCount;
@synthesize numberFormatter;
@synthesize profile;
@synthesize request;

#pragma mark - UIViewController+ATGToolbar Category Implementation

+ (UIImage *)toolbarIcon {
  return [UIImage imageNamed:@"icon-profile"];
}

+ (NSString *)toolbarAccessibilityLabel {
  return NSLocalizedStringWithDefaultValue
      (@"ATGViewController.ProfileAccessibilityLabel",
       nil, [NSBundle mainBundle],
       @"My Account",
       @"My Account toolbar button accessibility label");
}

#pragma mark - NSObject

- (void)dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // apply styles
  [labelPersonalInfo applyStyleWithName:@"formFieldLabel"];
  [labelChangePassword applyStyleWithName:@"formTitleLabel"];
  [labelPersonalInfoCaption applyStyleWithName:@"formTitleLabel"];
  [labelCreditCards applyStyleWithName:@"formTitleLabel"];
  [labelAddresses applyStyleWithName:@"formTitleLabel"];
  [labelOrders applyStyleWithName:@"formTitleLabel"];
  [labelReturns applyStyleWithName:@"formTitleLabel"];
  [labelCheckoutDefaults applyStyleWithName:@"formTitleLabel"];
  [labelShipToCaption applyStyleWithName:@"formFieldLabel"];
  [labelShipTo applyStyleWithName:@"formFieldBlackLabel"];
  [labelShipViaCaption applyStyleWithName:@"formFieldLabel"];
  [labelShipVia applyStyleWithName:@"formFieldBlackLabel"];
  [labelUseCardCaption applyStyleWithName:@"formFieldLabel"];
  [labelUseCard applyStyleWithName:@"formFieldBlackLabel"];
  [buttonLogout applyStyleWithName:@"logoutButton"];
  
  [self.tableView setBackgroundColor:[UIColor tableBackgroundColor]];
  // Load the number formatter once per view.
  [self setNumberFormatter:[[NSNumberFormatter alloc] init]];
  [[self numberFormatter] setNumberStyle:NSNumberFormatterDecimalStyle];
  // Use system-wide user locale to represent numbers.
  [[self numberFormatter] setLocale:[NSLocale currentLocale]];
  [[self cellLogout] setInnerButton:[self buttonLogout]];
  [[self cellLogout] setInnerLabel:[self labelChangePassword]];
  [[self cellLogout] viewWithTag:3].backgroundColor = [UIColor borderColor];
  [(ATGPersonalInfoTableViewCell *)[self cellPersonalInfo] setCaptionLabel:[self labelPersonalInfoCaption]];
  [(ATGPersonalInfoTableViewCell *)[self cellPersonalInfo] setInfoLabel:[self labelPersonalInfo]];

  [[self labelChangePassword] setAccessibilityTraits:UIAccessibilityTraitLink |
      [[self labelChangePassword] accessibilityTraits]];
  [self setTitle:[[self class] toolbarAccessibilityLabel]];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
  [self reloadData];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ATGProfileToAddressesSegue]) {
    ATGAddressesViewController *controller = segue.destinationViewController;
    controller.delegate = self;
  } else if ([segue.identifier isEqualToString:ATGProfileToCheckoutDefaultsSegue]) {
    ATGCheckoutDefaultsViewController *controller = segue.destinationViewController;
    controller.profile = [self profile];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // We do know exact number of rows to be displayed.
  // Change this value to 7 to display additional 'Checkout defaults' cell.
  return [self profile] ? 6 : 0;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 1) {
    // Make enough room to contain all the info displayed.
    CGRect personalInfoFrame = [[self labelPersonalInfo] frame];
    return personalInfoFrame.origin.y + personalInfoFrame.size.height + 10;
  } else if ([pIndexPath row] == 6) {
    // Make enough room to display checkout defaults.
    return [[self cellCheckoutDefaults] bounds].size.height;
  } else {
    return [pTableView rowHeight];
  }
}

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pCell setBackgroundColor:[UIColor tableCellBackgroundColor]];
  if ([pIndexPath row] == 0) {
    // We're going to display Logout cell. Update accessibility labels/hints,
    // Set localized value to all captions.
    NSString *logout = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.LogoutCaption", nil, [NSBundle mainBundle],
         @"Logout", @"Caption to be displayed on the logout button.");
    [[self buttonLogout] setTitle:logout forState:UIControlStateNormal];
    NSString *logoutLabel = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.LogoutAccessibilityLabel", nil,
         [NSBundle mainBundle], @"Logout",
         @"Accessibility label to be used by the logout button.");
    [[self buttonLogout] setAccessibilityLabel:logoutLabel];
    NSString *logoutHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.LogoutAccessibilityHint", nil, [NSBundle mainBundle],
         @"Logs you out.", @"Accessibility hint to be used by the logout button.");
    [[self buttonLogout] setAccessibilityHint:logoutHint];

    NSString *changePassword = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.ChangePasswordCaption", nil, [NSBundle mainBundle],
         @"Change Password", @"Caption to be displayed on the change password cell.");
    [[self labelChangePassword] setText:changePassword];

    CGSize contentSize = [[pCell selectedBackgroundView] bounds].size;
    UIGraphicsBeginImageContext(contentSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[[pCell selectedBackgroundView] layer] renderInContext:context];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[[pCell selectedBackgroundView] layer] setNeedsDisplay];
    CGRect buttonFrame = [[self buttonLogout] frame];
    UIGraphicsBeginImageContext(buttonFrame.size);
    [backgroundImage drawAtPoint:CGPointMake(-buttonFrame.origin.x, -buttonFrame.origin.y)];
    UIImage *background = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[self buttonLogout] setBackgroundImage:background forState:UIControlStateHighlighted];

    // Save logout button into local _strong_ variable, this will prevent the button
    // from being deallocated when removed from its superview.
    UIButton *button = [self buttonLogout];
    [button removeFromSuperview];
    [[[self buttonLogout] layer]
     setMask:[pCell createMaskForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                               inTableView:pTableView]];
    [[pCell contentView] addSubview:button];

    // Get the frame of the 'Change Password' cell part.
    CGFloat leftPartWidth = [[self buttonLogout] bounds].size.width;
    CGFloat backgroundWidth = [[pCell selectedBackgroundView] bounds].size.width;
    CGFloat backgroundHeight = [[pCell selectedBackgroundView] bounds].size.height;
    CGRect cellFrame = CGRectMake(leftPartWidth, 0, backgroundWidth - leftPartWidth,
                                  backgroundHeight);
    [pCell setAccessibilityFrame:cellFrame];

    // We're going to add a mask to cell's selectedBackgroundView. This mask
    // will allow to highlight only 'Change Password' part of the cell.
    // In order to do mask we must remove its layer from super-layer first.
    UIView *selectedBackground = [pCell selectedBackgroundView];
    [[pCell selectedBackgroundView] removeFromSuperview];
    // Create mask layer itself.
    CALayer *mask = [CALayer layer];
    // It will cover the whole 'Change Password' part.
    [mask setFrame:cellFrame];
    // And it will be completely opaque. This will hide highlighted view under the
    // 'Logout' part of the cell.
    CGColorRef backColor = CGColorCreateCopyWithAlpha([[UIColor maskBackgroundColor] CGColor], 1);
    [mask setBackgroundColor:backColor];
    CGColorRelease(backColor);
    // Apply the mask.
    [[[pCell selectedBackgroundView] layer] setMask:mask];
    // And place the background back to cell.
    [pCell setSelectedBackgroundView:selectedBackground];
  } else if ([pIndexPath row] == 1) {
    // Update accessibility properties for the Personal Info cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.PersonalInfoAccessibilityHint", nil,
         [NSBundle mainBundle], @"Changes your personal information.",
         @"Accessibility hint to be used by the personal info cell.");
    [pCell setAccessibilityHint:accHint];

    // Set proper captions to cell elements.
    NSString *personalInfo = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.PersonalInformationCaption", nil, [NSBundle mainBundle],
         @"Personal Information",
         @"Caption to be displayed inside the Personal Information cell.");
    [[self labelPersonalInfoCaption] setText:personalInfo];
  } else if ([pIndexPath row] == 2)
  {
    // Update accessibility properties for the Orders cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewControoler.OrdersAccessibilityHint", nil, [NSBundle mainBundle],
         @"Shows your orders.", @"Accessibility hint to be used by the orders cell.");
    [pCell setAccessibilityHint:accHint];
    [pCell setAccessibilityTraits:UIAccessibilityTraitLink | [pCell accessibilityTraits]];

    // Set proper captions to cell elements.
    NSString *orders = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.OrdersCaption", nil, [NSBundle mainBundle], @"Orders:",
         @"Caption to be displayed inside the Orders cell.");
    [[self labelOrders] setText:orders];
    [[self labelOrdersCount] setText:[[self numberFormatter]
                                      stringFromNumber:[[self profile] numberOfOrders]]];
  } else if ([pIndexPath row] == 3)
  {
    // Update accessibility properties for the Returns cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
    (@"ATGProfileViewController.ReturnsAccessibilityHint", nil, [NSBundle mainBundle],
     @"See your returned order history.", @"Accessibility hint to be used by the returns cell.");
    [pCell setAccessibilityHint:accHint];
    [pCell setAccessibilityTraits:UIAccessibilityTraitLink | [pCell accessibilityTraits]];
    
    // Set proper captions to cell elements.
    NSString *returns = NSLocalizedStringWithDefaultValue
    (@"ATGProfileViewController.ReturnsCaption", nil, [NSBundle mainBundle], @"Returns History:",
     @"Caption to be displayed inside the Returns cell.");
    [[self labelReturns] setText:returns];
    [[self labelReturnsCount] setText:[[self numberFormatter]
                                      stringFromNumber:[[self profile] numberOfOrders]]];
  } else if ([pIndexPath row] == 4) {
    // Update accessibility properties for the Addresses cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.AddressesAccessibilityHint", nil, [NSBundle mainBundle],
         @"Shows your addresses.", @"Accessibility hint to be used by the addresses cell.");
    [pCell setAccessibilityHint:accHint];
    [pCell setAccessibilityTraits:UIAccessibilityTraitLink | [pCell accessibilityTraits]];

    // Set proper captions to cell elements.
    NSString *addresses = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.AddressesCaption", nil, [NSBundle mainBundle],
         @"Addresses:", @"Caption to be displayed inside the Addresses cell.");
    [[self labelAddresses] setText:addresses];
    [[self labelAddressesCount] setText:[[self numberFormatter]
                                         stringFromNumber:[[self profile] numberOfAddresses]]];
  } else if ([pIndexPath row] == 5) {
    // Update accessibility properties for the Cards cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.CardsAccessibilityHint", nil, [NSBundle mainBundle],
         @"Shows your credit cards.", @"Accessibility hint to be used by the cards cell.");
    [pCell setAccessibilityHint:accHint];
    [pCell setAccessibilityTraits:UIAccessibilityTraitLink | [pCell accessibilityTraits]];

    // Set proper captions to cell elements.
    NSString *cards = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.CreditCardsCaption", nil, [NSBundle mainBundle],
         @"Credit Cards:", @"Caption to be displayed inside the Credit Cards cell.");
    [[self labelCreditCards] setText:cards];
    [[self labelCreditCardsCount] setText:[[self numberFormatter]
                                           stringFromNumber:[[self profile] numberOfCreditCards]]];
  } else if ([pIndexPath row] == 6) {
    // Update accessibility properties for the Checkout Defaults cell.
    NSString *accHint = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.CheckoutDefaultAccessibilityHint", nil,
         [NSBundle mainBundle], @"Changes your checkout defaults.",
         @"Accessibility hint to be used by the checkout defaults cell.");
    [pCell setAccessibilityHint:accHint];

    // Set proper captions to cell elements from the profile specified.
    NSString *empty = NSLocalizedStringWithDefaultValue
        (@"ATGProfileViewController.NotSpecifiedText", nil, [NSBundle mainBundle],
         @"Not Specified",
         @"Value to be displayed, if checkout defaults property is not specified.");
    NSString *defaultShippingAddress = [[self profile] defaultShippingAddressNickname];
    NSString *defaultShippingMethod = [[self profile] defaultCarrier];
    NSString *defaultCreditCard = [[self profile] defaultCreditCardNickname];
    [labelShipTo setText:defaultShippingAddress ? defaultShippingAddress:empty];
    [labelShipVia setText:defaultShippingMethod ? defaultShippingMethod:empty];
    [labelUseCard setText:defaultCreditCard ? defaultCreditCard:empty];
  }
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  // Change the view, when the row is selected.
  NSString *segueId;
  switch ([pIndexPath row]) {
    case 0: {
      segueId = ATGProfileToPasswordSegue;
      break;
    }
    case 1: {
      segueId = ATGProfileToEditProfileSegue;
      break;
    }
    case 2: {
      segueId = ATGProfileToOrdersSegue;
      break;
    }
    case 3: {
      segueId = ATGProfileToOrdersSegue;
      break;
    }
    case 4: {
      segueId = ATGProfileToAddressesSegue;
    }
    break;
    case 5:
      segueId = ATGProfileToCardsSegue;
      break;
    case 6:
      segueId = ATGProfileToCheckoutDefaultsSegue;
      break;
    default:
      break;
  }
  [self performSegueWithIdentifier:segueId sender:self];
}

#pragma mark - UI Event Handlers

- (IBAction)didTouchLogoutButton:(id)pSender {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] logout:self]];
}

#pragma mark - ATGTableViewController

- (void)reloadData {
  [self startActivityIndication:![self profile]];
  [[self request] cancelRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
}

#pragma mark - ATGProfileManagerDelegate

- (void)didGetProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self setProfile:[pRequestResults requestResults]];

  // Set personal info text from the profile specified.
  [[self labelPersonalInfo] setText:[NSString stringWithFormat:@"%@ %@\n%@",
                                     [[self profile] firstName], [[self profile] lastName],
                                     [[self profile] email]]];
  if ([[[self profile] postalCode] length]) {
    [[self labelPersonalInfo] setText:[NSString stringWithFormat:@"%@\n%@",
                                       [labelPersonalInfo text], [[self profile] postalCode]]];
  }
  // And recalculate label's size to contain all the data.
  CGSize maxSize = CGSizeMake([[self labelPersonalInfo] bounds].size.width, CGFLOAT_MAX);
  CGSize textSize = [[[self labelPersonalInfo] text] sizeWithFont:[labelPersonalInfo font]
                                                constrainedToSize:maxSize];
  CGRect labelFrame = [[self labelPersonalInfo] frame];
  labelFrame.size.height = textSize.height;
  [[self labelPersonalInfo] setFrame:labelFrame];

  // Update table to make enough room to hold new data.
  [(UITableView *)[self view] reloadData];
}

- (void)didErrorGettingProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

- (void)didLogOut:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_NAME_PROPERTY];
  [self.navigationController popToRootViewControllerAnimated:YES];

  if ([self isPhone]) {
    [[(MobileCommerceAppDelegate *) [[UIApplication sharedApplication]
    delegate] tabBarController] reloadHomeScreen];
  }
}

- (void)didErrorLoggingOut:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

#pragma mark - ATGLoginViewControllerDelegate

- (void) didLogin {
  [super didLogin];
  [[ATGCommerceManager commerceManager] getCartItemCount:self];
}

@end

#pragma mark - ATGPartlySelectableTableViewCell Implementation
#pragma mark -

@implementation ATGPartlySelectableTableViewCell

@synthesize innerButton, innerLabel;

#pragma mark - UITableViewCell

- (void)setHighlighted:(BOOL)pHighlighted animated:(BOOL)pAnimated {
  [super setHighlighted:pHighlighted animated:pAnimated];
  [[[self backgroundView] layer] setOpacity:1];
  [[self innerButton] setHighlighted:NO];
}

- (void) setSelected:(BOOL)pSelected animated:(BOOL)pAnimated {
  [super setSelected:pSelected animated:pAnimated];
  [[[self backgroundView] layer] setOpacity:1];
  [[self innerButton] setHighlighted:NO];
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement {
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger)accessibilityElementCount {
  return 2;
}

- (NSInteger)indexOfAccessibilityElement:(id)pElement {
  if (pElement == [self innerButton]) {
    return 0;
  } else if (pElement == [self innerLabel]) {
    return 1;
  }
  return NSNotFound;
}

- (id)accessibilityElementAtIndex:(NSInteger)pIndex {
  switch (pIndex) {
    case 0:
      return [self innerButton];
      break;
    case 1:
      return [self innerLabel];
      break;
    default:
      return nil;
  }
}

@end

#pragma mark - ATGPersonalInfoTableViewCell Implementation
#pragma mark -

@implementation ATGPersonalInfoTableViewCell

#pragma mark - Properties

@synthesize captionLabel, infoLabel;

#pragma mark - Instance Management


#pragma mark - UIAccessibility

- (NSString *)accessibilityLabel {
  return [NSString stringWithFormat:@"%@\n%@", [[self captionLabel] text], [[self infoLabel] text]];
}

@end
