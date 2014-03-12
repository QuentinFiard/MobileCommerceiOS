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

#import "ATGOrderPlacedViewController.h"
#import "ATGExpandableTableView.h"
#import "ATGOrdersViewController.h"
#import <ATGMobileClient/ATGKeychainManager.h>
#import "ATGOrderDetailsViewController.h"
#import "ATGSignupTableViewCell.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import "ATGTabBarController.h"
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGProfile.h>

static NSString *const ATGOrderPlacedToPrivacyTermsSegue = @"orderPlacedToMoreDetails";
static NSString *const ATGOrdersToOrderDetailsSegue = @"ordersToOrderDetails";
static NSString *const ATGProfileToOrdersSegue = @"profileToOrders";

#pragma mark - ATGOrderPlacedViewController Private Protocol
#pragma mark -

@interface ATGOrderPlacedViewController () <ATGSignupTableViewCellDelegate, ATGProfileManagerDelegate,
    UITableViewDataSource, UITableViewDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;

#pragma mark - Private Protocol Definition

- (UITableView *)tableView;

@end

#pragma mark - ATGOrderPlacedViewController Implementation
#pragma mark -

@implementation ATGOrderPlacedViewController

#pragma mark - Synthesized Properties

@synthesize email, userAnonymous, orderID;
@synthesize request;

#pragma mark - NSObject

- (void)dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (void)loadView {
  ATGExpandableTableView *tableView = [[ATGExpandableTableView alloc] initWithFrame:CGRectZero
                                                                              style:UITableViewStyleGrouped];
  [tableView setDelegate:self];
  [tableView setDataSource:self];
  [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
  [self setView:tableView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGOrderPlacedViewController.ScreenTitle", nil, [NSBundle mainBundle],
       @"Success!", @"Screen title to be used.");
  [self setTitle:title];
  self.tableView.backgroundColor = [UIColor tableBackgroundColor];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Do not display 'Back' button.
  [[self navigationItem] setLeftBarButtonItem:nil];
  [[self navigationItem] setHidesBackButton:YES];
  // Register self to be notified of keyboard events.
  [self addKeyboardNotificationsObserver];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  // Deregister self to stop receiving keyboard events.
  [self removeKeyboardNotificationsObserver];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:ATGOrdersToOrderDetailsSegue]) {
    ATGOrderDetailsViewController *detailsController = pSegue.destinationViewController;
    detailsController.orderID = [self orderID];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if ([self isUserAnonymous]) {
    return 1;
  } else {
    return 2;
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([self isUserAnonymous]) {
    ATGSignupTableViewCell *cell = [ATGSignupTableViewCell newInstance];
    [cell setDelegate:self];
    [cell setEmail:[self email]];
    NSString *caption = NSLocalizedStringWithDefaultValue
        (@"ATGOrderPlacedViewController.RegisterCellCaption", nil, [NSBundle mainBundle],
         @"Register for an account", @"Cell caption to be used.");
    [cell setCaption:caption];
    return cell;
  } else {
    UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    [[cell textLabel] applyStyleWithName:@"formTitleLabel"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setAccessibilityTraits:UIAccessibilityTraitButton | UIAccessibilityTraitStaticText];
    return cell;
  }
}

- (NSString *)tableView:(UITableView *)pTableView titleForHeaderInSection:(NSInteger)pSection {
  if ([self email]) {
    NSString *titleFormat = NSLocalizedStringWithDefaultValue
        (@"ATGOrderPlacedViewController.SubTitleEmailed", nil, [NSBundle mainBundle],
         @"Confirmation E-mailed to:\n%@",
         @"Subtitle format to be used when email specified.");
    return [NSString stringWithFormat:titleFormat, [self email]];
  } else {
    NSString *titleFormat = NSLocalizedStringWithDefaultValue
        (@"ATGOrderPlacedViewController.SubTitleNotEmailed", nil, [NSBundle mainBundle],
         @"Your order number is:\n%@",
         @"Subtitle format to be used when email is not specified.");
    return [NSString stringWithFormat:titleFormat, [self orderID]];
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (![self isUserAnonymous]) {
    NSString *title = nil;
    switch ([pIndexPath row]) {
      case 0:
        title = NSLocalizedStringWithDefaultValue
            (@"ATGOrderPlacedViewController.ViewOrderTitle", nil, [NSBundle mainBundle],
             @"View Order", @"Title to be used on the View Order cell.");
        break;

      case 1:
        title = NSLocalizedStringWithDefaultValue
            (@"ATGOrderPlacedViewController.AllOrdersTitle", nil, [NSBundle mainBundle],
             @"View All Orders", @"Title to be used on the View All Orders cell.");
    }
    [[pCell textLabel] setText:title];
  }
}

- (NSIndexPath *)tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath isEqual:[[self tableView] indexPathForSelectedRow]]) {
    [[self tableView] deselectRowAtIndexPath:pIndexPath animated:NO];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    return nil;
  }
  return pIndexPath;
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (![self isUserAnonymous]) {
    ATGOrdersViewController *ordersController = [[UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:[[ATGOrdersViewController class] description]];
    if ([pIndexPath row] == 0) {
      ATGOrdersViewController *ordersController = [[UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:[[ATGOrdersViewController class] description]];
      [self.navigationController pushViewController:ordersController animated:NO];
      [ordersController performSegueWithIdentifier:ATGOrdersToOrderDetailsSegue sender:self.orderID];
    } else {
      [self.navigationController pushViewController:ordersController animated:NO];
    }
  } else {
    UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
    UIView *contents = [cell contentView];
    [contents removeFromSuperview];
    [[contents layer] setMask:[cell createMaskForIndexPath:pIndexPath inTableView:pTableView]];
    [cell addSubview:contents];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  }
}

- (UIView *)tableView:(UITableView *)pTableView viewForHeaderInSection:(NSInteger)pSection {
  NSString *title = [self tableView:pTableView titleForHeaderInSection:pSection];
  UILabel *headerLabel = [[UILabel alloc] init];
  [headerLabel applyStyleWithName:@"actionConfirmationLabel"];
  [headerLabel setText:title];
  CGSize headerSize = [title sizeWithFont:[headerLabel font]
                        constrainedToSize:CGSizeMake(1000, 1000)
                            lineBreakMode:NSLineBreakByClipping];

  NSString *pageTitle = NSLocalizedStringWithDefaultValue
      (@"ATGOrderPlacedViewController.TitlePlaced", nil, [NSBundle mainBundle],
       @"Your Order has been Placed!", @"Page title to be used.");
  UILabel *titleLabel = [[UILabel alloc] init];
  [titleLabel applyStyleWithName:@"headerLabel"];
  [titleLabel setText:pageTitle];
  CGSize titleSize = [pageTitle sizeWithFont:[titleLabel font]
                           constrainedToSize:CGSizeMake([self view].bounds.size.width, 1000)
                               lineBreakMode:NSLineBreakByClipping];

  UIView *headerContainer =
    [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100,
                                             headerSize.height + titleSize.height + 30)];
  [headerContainer addSubview:titleLabel];
  [titleLabel setFrame:CGRectMake(0, 10, 100, titleSize.height)];
  [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [headerContainer addSubview:headerLabel];
  [headerLabel setFrame:CGRectMake(0, 20 + titleSize.height, 100, headerSize.height)];
  [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

  return headerContainer;
}

- (CGFloat)tableView:(UITableView *)pTableView heightForHeaderInSection:(NSInteger)pSection {
  UIView *headerView = [self tableView:pTableView viewForHeaderInSection:pSection];
  return [headerView bounds].size.height;
}

#pragma mark - ATGSignupTableViewCellDelegate

- (void)signUpWithEmail:(NSString *)pEmail password:(NSString *)pPassword
              firstName:(NSString *)pFirstName lastName:(NSString *)pLastName {
  [self signUpWithEmail:pEmail password:pPassword firstName:pFirstName lastName:pLastName additionalInfo:nil];
}

- (void)signUpWithEmail:(NSString *)pEmail
               password:(NSString *)pPassword
              firstName:(NSString *)pFirstName
               lastName:(NSString *)pLastName
         additionalInfo:(NSDictionary *)pAdditionalInfo {
  ATGProfile *user = [[ATGProfile alloc] init];
  [user setEmail:pEmail];
  [user setPassword:pPassword];
  [user setFirstName:pFirstName];
  [user setLastName:pLastName];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] createNewUser:user
                                                      additionalInfo:pAdditionalInfo
                                                      duringCheckout:YES
                                                            delegate:self]];
}

- (void)displayPrivacyTerms {
  // Display 'Receive Emails' info.
  [self performSegueWithIdentifier:ATGOrderPlacedToPrivacyTermsSegue sender:self];
}

#pragma mark - ATGProfileManagerDelegate

- (void)didCreateNewUser:(ATGProfileManagerRequest *)pRequestResults {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
}

- (void)didErrorCreatingNewUser:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  // SignUp is an only cell in the current table view.
  NSIndexPath *signUpIndex = [NSIndexPath indexPathForRow:0 inSection:0];
  ATGSignupTableViewCell *cell =
    (ATGSignupTableViewCell *)[[self tableView] cellForRowAtIndexPath:signUpIndex];
  // Make it display error message received from form handler.
  [cell setError:[[[[pRequestResults error] userInfo]
                   objectForKey:ATG_FORM_EXCEPTION_KEY] firstObject]];
  // Make the table view to recalculate cell's height.
  [self tableView:[self tableView] didSelectRowAtIndexPath:signUpIndex];
  // And update the view to reflect this new height.
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];
}

- (void)didGetProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [[ATGKeychainManager instance]
   setString:[(ATGProfile *)[pRequestResults requestResults] email]
      forKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance]
   setString:[(ATGProfile *)[pRequestResults requestResults] firstName]
      forKey:ATG_KEYCHAIN_NAME_PROPERTY];
  [(ATGTabBarController *)self.tabBarController switchToProfileScreen];
}

- (void)didErrorGettingProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self setRequest:nil];
}

#pragma mark - ATGViewController

- (void)keyboardWillShow:(NSNotification *)pNotification {
  [super keyboardWillHide:pNotification];
  NSValue *frame = [[pNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect endFrame = [[self view] convertRect:[frame CGRectValue] fromView:nil];
  CGRect intersection = CGRectIntersection(endFrame, [[self view] bounds]);
  NSNumber *duration = [[pNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue] delay:0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     UIView *responder = [[self view] firstResponder];
                     UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
                     [[self tableView] setContentInset:insets];
                     [[self tableView] setScrollIndicatorInsets:insets];
                     CGRect responderFrame = [responder bounds];
                     responderFrame = [[self view] convertRect:responderFrame fromView:responder];
                     [[self tableView] scrollRectToVisible:responderFrame animated:YES];
                   }
                   completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)pNotification {
  [super keyboardWillHide:pNotification];
  NSNumber *duration = [[pNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue] animations:^{
    [[self tableView] setContentInset:UIEdgeInsetsZero];
    [[self tableView] setScrollIndicatorInsets:UIEdgeInsetsZero];
  }];
}

#pragma mark - Private Protocol Implementation

- (UITableView *)tableView {
  return (UITableView *)[self view];
}

@end
