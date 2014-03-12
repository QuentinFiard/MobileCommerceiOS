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

#import "ATGLoginViewController.h"
#import "ATGExpandableTableView.h"
#import "ATGSignupTableViewCell.h"
#import "ATGSignupTableViewCell_iPad.h"
#import "ATGForgotPasswordViewController.h"
#import <ATGMobileClient/ATGKeychainManager.h>
#import <ATGMobileClient/ATGProfile.h>
#import "MobileCommerceAppDelegate.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGUIElements/ATGBackButton.h>
#import "ATGLoginTableViewCell.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGRootViewController_iPad.h"

static NSString *const ATGLoginToForgotPasswordSegue = @"loginToForgotPassword";
static NSString *const ATGLoginToPrivacyTermsSegue = @"loginToMoreDetails";
static const CGFloat ATGScreenWidth = 320;

#pragma mark - ATGLoginViewController Private Protocol
#pragma mark -

@interface ATGLoginViewController () <ATGLoginTableViewCellDelegate, ATGSignupTableViewCellDelegate,
                                      ATGProfileManagerDelegate, UITableViewDelegate, UITableViewDataSource>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGLoginTableViewCell *loginCell;
@property (nonatomic, readwrite, strong) id signupCell;
@property (nonatomic, readwrite, assign) BOOL skipsLogin;
@property (nonatomic, readwrite, strong) ATGManagerRequest *request;
@property (nonatomic, readwrite, assign) CGFloat cellHeightDelta;
@property (nonatomic, readwrite, assign, getter = isExpanded) BOOL expanded;
@property (nonatomic, readwrite, weak) UIView *innerInputView;

#pragma mark - Private Protocol Definition

- (UITableView *) tableView;
- (BOOL)          hasSavedUser;
- (void)          cancel;

@end

#pragma mark - ATGLoginViewController Implementation
#pragma mark -

@implementation ATGLoginViewController

#pragma mark - Synthesized Properties

@synthesize displayForgotPassword;
@synthesize allowSkipLogin;
@synthesize delegate;
@synthesize displayPasswordSent;
@synthesize email;
@synthesize loginCell;
@synthesize signupCell;
@synthesize skipsLogin;
@synthesize request;
@synthesize cellHeightDelta;
@synthesize expanded;

#pragma mark - NSObject

- (void) dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (void) loadView {
  // Always create grouped table view. It's frame is of no use, will be stretched
  // automatically.
  ATGExpandableTableView *tableView =
    [[ATGExpandableTableView alloc] initWithFrame:CGRectZero
                                            style:UITableViewStyleGrouped];
  [tableView setDelegate:self];
  [tableView setDataSource:self];
  [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
  // Place TableView into a container view, as we will display inner pickers.
  UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
  [container setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
  [container addSubview:tableView];
  [self setView:container];

  // Create cells to be displayed.
  [self setLoginCell:[ATGLoginTableViewCell newInstance]];
  [[self loginCell] setDelegate:self];
  [[self loginCell] setName:[[ATGKeychainManager instance] stringForKey:ATG_KEYCHAIN_NAME_PROPERTY]];
  [[self loginCell] setEmail:[[ATGKeychainManager instance] stringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY]];
  if ([self isPad]) {
    [self setSignupCell:[ATGSignupTableViewCell_iPad newInstance]];
    [(ATGSignupTableViewCell_iPad *)[self signupCell] setDelegate:self];
  } else {
    [self setSignupCell:[ATGSignupTableViewCell newInstance]];
    [(ATGSignupTableViewCell *)[self signupCell] setDelegate:self];
  }
}

- (void) viewDidLoad {
  [super viewDidLoad];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  [[self tableView] setBackgroundView:nil];
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGLoginViewController.ScreenTitle", nil, [NSBundle mainBundle], @"Login",
                      @"Title to be displayed on the 'Login' screen.");
  [self setTitle:title];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0); // remove extra padding in between header
    // and first cell of table view
  }
}

- (void) viewDidUnload {
  [[self request] cancelRequest];
  [self setRequest:nil];
  [self setLoginCell:nil];
  [self setSignupCell:nil];
  [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Begin updates. This will recalculate table cell heights.
  // This is essential, because login cell might change.
  [[self tableView] beginUpdates];
  [[self loginCell] setDisplayForgotPassword:[self displayForgotPassword]];
  if ([self displayPasswordSent]) {
    NSString *message = NSLocalizedStringWithDefaultValue
                          (@"ATGLoginViewController.PasswordSentErrorMessage", nil, [NSBundle mainBundle],
                          @"Your new password has been sent", @"Error message to be displayed.");
    [[self loginCell] setError:message];
    [[self loginCell] setDisplayCopyError:YES];
  }
  // Emulate selection message. This is essential for proper height calculation.
  [self tableView:[self tableView] didSelectRowAtIndexPath:[[self tableView] indexPathForSelectedRow]];
  [[self tableView] endUpdates];
  // Do not display 'back' button on this screen.

  UIBarButtonItem *cancelButton = nil;

  if ([self isPad]) {
    if ([self allowSkipLogin]) {
      ATGBackButton *backButton = [ATGBackButton backButton];
      [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
      cancelButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
      [[self navigationItem] setLeftBarButtonItem:cancelButton];
    }
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGLoginViewController.CancelButtonTitle", nil, [NSBundle mainBundle],
                        @"Cancel", @"Title to be used by the Cancel button.");

    cancelButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                    style:UIBarButtonItemStyleBordered
                                                   target:self
                                                   action:@selector(cancel)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    if ([self allowSkipLogin]) {
      [[self navigationItem] setLeftBarButtonItem:nil];
    }

    [self addKeyboardNotificationsObserver];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  NSLog(@"%@", self.navigationItem.leftBarButtonItem);
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [[self view] endEditing:YES];
  [self removeKeyboardNotificationsObserver];
  [super viewWillDisappear:pAnimated];
}

- (void) setToolbarItems:(NSArray *)pToolbarItems animated:(BOOL)pAnimated {
  // Do not accept any toolbar items. Or it will ruin ATG toolbar forever.
  [super setToolbarItems:nil animated:pAnimated];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:ATGLoginToForgotPasswordSegue]) {
    ATGForgotPasswordViewController *controller = segue.destinationViewController;
    [controller setEmail:self.email];
  }
}

- (CGSize) contentSizeForViewInPopover {
  //Todo: This should not need to happen. When we refactor the expanding tableview we should
  //remove manual content size calculations in favor of using the tableViews content size.
  CGFloat defaultHeight = self.tableView.sectionHeaderHeight + self.tableView.sectionFooterHeight;
  defaultHeight += [self tableView:[self tableView] numberOfRowsInSection:0] * [[self tableView] rowHeight];
  if ([self innerInputView]) {
    CGRect inputViewFrame = [[self innerInputView] bounds];
    defaultHeight += inputViewFrame.size.height;
  }
  if ( [self isExpanded] && ([self cellHeightDelta] == 0) ) {
    [self setExpanded:NO];
    return CGSizeMake(ATGScreenWidth, defaultHeight);
  }
  return CGSizeMake(ATGScreenWidth, defaultHeight + [self cellHeightDelta]);
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Display all cells in a single section.
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // How many cells do we have?
  return [self allowSkipLogin] ? 3 : 2;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {

  if ([pIndexPath row] == 0) {
    // First row is Login.
    return [self loginCell];
  } else if ([pIndexPath row] == 1) {
    if ([self hasSavedUser]) {
      UITableViewCell *cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:nil];
      NSString *caption = NSLocalizedStringWithDefaultValue
                            (@"ATGLoginViewController.LogoutCaption", nil, [NSBundle mainBundle],
                            @"Logout", @"Caption to be displayed on the Logout cell.");
      [[cell textLabel] setText:caption];
      [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
      [[cell textLabel] applyStyleWithName:@"formTitleLabel"];
      NSString *hint = NSLocalizedStringWithDefaultValue
                         (@"ATGLoginViewController.LogoutAccessibilityHint", nil, [NSBundle mainBundle],
                         @"Double tap to logout.", @"Accessibility hint to be used by 'Logout' cell.");
      [cell setAccessibilityHint:hint];
      [cell setAccessibilityTraits:UIAccessibilityTraitButton];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      return cell;
    }
    // Second row is SignUp.
    return [self signupCell];
  } else if ([pIndexPath row] == 2) {
    // Last row is SkipLogin, use standard cell.
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"cell"];
    NSString *caption = NSLocalizedStringWithDefaultValue
                          (@"ATGLoginViewController.SkipLoginCaption", nil, [NSBundle mainBundle],
                          @"Skip Login", @"Caption to be displayed on the SkipLogin cell.");
    [[cell textLabel] setText:caption];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] applyStyleWithName:@"formTitleLabel"];
    NSString *hint = NSLocalizedStringWithDefaultValue
                       (@"ATGLoginViewController.SkipLoginAccessibilityHint", nil, [NSBundle mainBundle],
                       @"Double tap to checkout anonymously.", @"Accessibility hint to be used by 'Skip Login' cell.");
    [cell setAccessibilityHint:hint];
    return cell;
  }
  return nil;
}

#pragma mark - UITableViewDelegate

- (void)  tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
  forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pCell setBackgroundColor:[UIColor tableCellBackgroundColor]];
  if ([pIndexPath row] == 0) {
    // It's a email cell, set its internal properties.
    ATGLoginTableViewCell *cell = (ATGLoginTableViewCell *)pCell;
    [cell setNeedsLayout];
  } else if ([pIndexPath row] == 1 && ![self allowSkipLogin] && ![self hasSavedUser]) {
    // It's the 'Sign Up' cell, and it's the last cell in the table.
    ATGSignupTableViewCell *cell = (ATGSignupTableViewCell *)pCell;
    [[[cell contentView] layer] setCornerRadius:8.5];
    [[cell contentView] setClipsToBounds:YES];
  }
}

- (NSIndexPath *) tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [[self view] endEditing:YES];
  if ([self isPad]) {
    if ([pIndexPath row] == 1 && ![self hasSavedUser] && [self isExpanded]) {
      ATGSignupTableViewCell_iPad *cell =
        (ATGSignupTableViewCell_iPad *)[pTableView cellForRowAtIndexPath:pIndexPath];
      [cell clearFormFields];
      [self setCellHeightDelta:0];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    } else if ([pIndexPath row] == 0 && [self isExpanded]) {
      ATGLoginTableViewCell *cell = (ATGLoginTableViewCell *)[pTableView cellForRowAtIndexPath:pIndexPath];
      [cell clearFormFields];
      [self setCellHeightDelta:0];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    }
  }
  return pIndexPath;
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([self hasSavedUser] && [pIndexPath row] == 1) {
    [self setSkipsLogin:NO];
    [[self request] cancelRequest];

    [self startActivityIndication:YES];
    if ([self allowSkipLogin]) {
      // It's a 'Checkout Login' screen, we have to become anonymous instead of logging out,
      // as this will save existing shopping cart for us.
      // Logging out would erase all added products from cart.
      [self setRequest:[[ATGExternalProfileManager profileManager] becomeAnonymous:self]];
    } else {
      [self setRequest:[[ATGExternalProfileManager profileManager] logout:self]];
    }
  } else if ([pIndexPath row] == 2) {
    [self setSkipsLogin:YES];
    [[self request] cancelRequest];

    [self startActivityIndication:YES];
    [self setRequest:[[ATGExternalProfileManager profileManager] becomeAnonymous:self]];
  } else {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  }
}

#pragma mark - ATGLoginTableViewCellDelegate

- (void) loginWithEmail:(NSString *)pEmail andPassword:(NSString *)pPassword {
  [[self request] cancelRequest];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] login:pEmail withPassword:pPassword delegate:self]];
  [[self loginCell] setEmail:pEmail];
}

- (void) forgotPasswordForEmail:(NSString *)pEmail {
  self.email = pEmail;
  [self performSegueWithIdentifier:ATGLoginToForgotPasswordSegue sender:self];
}

#pragma mark - ATGSignupTableViewCellDelegate

- (void) signUpWithEmail:(NSString *)pEmail password:(NSString *)pPassword
               firstName:(NSString *)pFirstName lastName:(NSString *)pLastName
          additionalInfo:(NSDictionary *)pAdditionalInfo {
  // Signup the user.
  ATGProfile *info = [[ATGProfile alloc] init];
  [info setEmail:pEmail];
  [info setFirstName:pFirstName];
  [info setLastName:pLastName];
  [info setPassword:pPassword];
  [[self request] cancelRequest];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] createNewUser:info
                                                      additionalInfo:pAdditionalInfo
                                                            delegate:self]];
}

- (void) displayPrivacyTerms {
  // Display 'Receive Emails' info.
  [self performSegueWithIdentifier:ATGLoginToPrivacyTermsSegue sender:self];
}

- (void) resizePopover:(CGFloat)pNewHeight {
  [self setCellHeightDelta:pNewHeight];
  [self setExpanded:YES];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void)presentInputView:(UIView *)pView forTextField:(UITextField *)pTextField {
  // Place newcomer input view onto the screen.
  UIView *container = [self view];
  [container addSubview:pView];
  // Set the autoresizing mask, so that the InputView would take proper place when device's orientation
  // is changed.
  [pView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  UITableView *tableView = [self tableView];
  if ([self innerInputView]) {
    // There is an inner input view onscreen already, just replace it with the new one; no animations.
    [[self innerInputView] removeFromSuperview];
    [self setInnerInputView:pView];
    CGRect inputViewFrame = [pView frame];
    inputViewFrame.origin.y = [tableView frame].size.height;
    [pView setFrame:inputViewFrame];
  } else {
    // Otherwise we should do some animations. First, set an innerInputView reference,
    // it's required by the contentSizeForViewInPopover method.
    [self setInnerInputView:pView];
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    // Now we're ready to setup some animations on TableView and InputView.
    CGRect viewBounds = [container bounds];
    CGRect inputViewFrame = [pView frame];
    inputViewFrame.origin.y = viewBounds.size.height;
    [pView setFrame:inputViewFrame];
    [UIView animateWithDuration:.3
                     animations:^{
                       CGRect inputViewBounds = [pView bounds];
                       CGRect tableViewFrame = [tableView frame];
                       tableViewFrame.size.height = viewBounds.size.height - inputViewBounds.size.height;
                       [tableView setFrame:tableViewFrame];
                       
                       CGRect inputViewFrame = [pView frame];
                       inputViewFrame.origin.y = tableViewFrame.size.height;
                       [pView setFrame:inputViewFrame];
                     }
                     completion:^(BOOL pFinished) {
                       // When everything is set, just scroll the TableView to display
                       // the TextField being edited.
                       [tableView scrollRectToVisible:[tableView convertRect:[pTextField bounds]
                                                                    fromView:pTextField]
                                             animated:YES];
                     }];
  }
}

- (void)dismissInputView {
  // Preserve inner input view for future use, we're going to nil-out the reference.
  UIView *innerInputView = [self innerInputView];
  // Nil-out the reference. This is required, as ViewController's content size is calculated based
  // on this innerInputView reference.
  [self setInnerInputView:nil];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  // Now we're ready to resize the TableView, it should take all the space available.
  UIView *container = [self view];
  UITableView *tableView = [self tableView];
  CGRect viewBounds = [container bounds];
  CGRect tableViewFrame = [tableView frame];
  tableViewFrame.size.height = viewBounds.size.height;
  [tableView setFrame:tableViewFrame];
  // Gracefully fade the inner input view.
  [UIView transitionWithView:container
                    duration:.3
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:^{
                    [innerInputView removeFromSuperview];
                  }
                  completion:NULL];
}

#pragma mark - ATGProfileManagerDelegate

- (void) didLogIn:(ATGProfileManagerRequest *)pRequestResults {
  // Now we're logged in, get profile info to save it into keychain.
  // Load data to be stored only if it is needed.
  [[self request] cancelRequest];
  //loading indication should be already started
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];

  if ([self isPad]) {
    [[ATGRootViewController_iPad rootViewController] reloadHomepage];
  } else {
    [[(MobileCommerceAppDelegate *) [[UIApplication sharedApplication]
            delegate] tabBarController] reloadHomeScreen];
  }
}

- (void) didLogOut:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];

  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_NAME_PROPERTY];

  // Go to Home screen first, or MyAccount screen would try to present Login screen back.
  [[(MobileCommerceAppDelegate *)[[UIApplication sharedApplication]
                                  delegate] tabBarController] switchToHomeScreen];
  [self dismissLoginViewControllerAnimated:YES];

  if ([self isPad]) {
    [[ATGRootViewController_iPad rootViewController] reloadHomepage];
    [[self tableView] beginUpdates];
    [self setLoginCell:[ATGLoginTableViewCell newInstance]];
    [[self loginCell] setDelegate:self];
    NSArray *indices = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],
                        [NSIndexPath indexPathForRow:1 inSection:0], nil];
    [[self tableView] reloadRowsAtIndexPaths:indices
                            withRowAnimation:UITableViewRowAnimationRight];
    [[self tableView] endUpdates];
  }
}

- (void) didErrorLoggingIn:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [[self tableView] beginUpdates];
  NSString *error = NSLocalizedStringWithDefaultValue
                      (@"ATGLoginViewController.WrongLoginErrorMessage", nil, [NSBundle mainBundle],
                      @"Sorry, that login is not valid.",
                      @"Error message to be displayed when unable to login.");
  [[self loginCell] setError:error];
  [[self loginCell] setDisplayForgotPassword:YES];
  [self setDisplayForgotPassword:YES];
  // Emulate row selection. This will recalculate cell height.
  [self tableView:[self tableView] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                              inSection:0]];
  [[self tableView] endUpdates];
  UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void) didGetProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  // Did get profile, save it for future use.
  [[ATGKeychainManager instance] setString:[(ATGProfile *)[pRequestResults requestResults] email]
                                    forKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance] setString:[(ATGProfile *)[pRequestResults requestResults] firstName]
                                    forKey:ATG_KEYCHAIN_NAME_PROPERTY];

  [[self delegate] didLogin];
}

- (void) didBecomeAnonymous:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];

  if ([self skipsLogin]) {
    [[self delegate] didSkipLogin];
  } else {
    // Drop saved login/password.
    [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
    [[ATGKeychainManager instance] removeStringForKey:ATG_KEYCHAIN_NAME_PROPERTY];

    // Reload data, this will display new cells (without predefined user name).
    [[self tableView] beginUpdates];
    [self setLoginCell:[ATGLoginTableViewCell newInstance]];
    [[self loginCell] setDelegate:self];
    NSArray *indices = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],
                        [NSIndexPath indexPathForRow:1 inSection:0], nil];
    [[self tableView] reloadRowsAtIndexPaths:indices
                            withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
  }
}

- (void) didCreateNewUser:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  // Same as login action.
  [[self request] cancelRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
}

- (void) didErrorCreatingNewUser:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];

  id formException = [[[[pRequestResults error] userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY] firstObject];
  if (formException) {
    [[self signupCell] setError:formException];

    [self tableView:[self tableView] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                inSection:0]];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
  } else {
    [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
  }
}

#pragma mark - Private Protocol Implementation

- (BOOL) hasSavedUser {
  return [[ATGKeychainManager instance] stringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY] != nil;
}

- (void) cancel {
  [[self delegate] didCancelLogin];
}

- (UITableView *) tableView {
  // ViewController's view is a container view, so drill into view hierarchy to find an actual TableView;
  for (UIView *view in [[self view] subviews]) {
    if ([view isKindOfClass:[UITableView class]]) {
      return (UITableView *)view;
    }
  }
  return nil;
}

#pragma mark - ATGViewController

- (void) keyboardWillShow:(NSNotification *)pNotification {
  [super keyboardWillHide:pNotification];
  NSValue *frame = [[pNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect endFrame = [[self view] convertRect:[frame CGRectValue] fromView:nil];
  CGRect intersection = CGRectIntersection(endFrame, [[self view] bounds]);
  NSNumber *duration = [[pNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue] delay:0
                      options:UIViewAnimationOptionBeginFromCurrentState
                   animations: ^{
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

- (void) keyboardWillHide:(NSNotification *)pNotification {
  [super keyboardWillHide:pNotification];
  NSNumber *duration = [[pNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue] animations: ^{
     [[self tableView] setContentInset:UIEdgeInsetsZero];
     [[self tableView] setScrollIndicatorInsets:UIEdgeInsetsZero];
   }
  ];
}

@end
