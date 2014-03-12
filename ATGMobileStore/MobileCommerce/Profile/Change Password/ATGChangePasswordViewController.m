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

#import "ATGChangePasswordViewController.h"
#import <ATGUIElements/ATGConfirmationPane.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

#pragma mark - ATGChangePasswordViewController Private Protocol
#pragma mark -

// Private protocol which defines useful methods.
@interface ATGChangePasswordViewController () <ATGProfileManagerDelegate, ATGKeyboardToolbarDelegate,
    UITextFieldDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UIBarButtonItem *saveButton;
// Make this property strong, as this confirmation label is not displayed in view hierarchy by default.
@property (nonatomic, readwrite, strong) IBOutlet UILabel *passwordChangedLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *oldPasswordInput;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *changePasswordInput;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *confirmPasswordInput;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *oldPasswordLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *changePasswordLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *confirmPasswordLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *doneButton;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) ATGKeyboardToolbar *toolbar;

#pragma mark - Private Protocol Definition

// UI Event handler.
- (IBAction)didTouchDoneButton:(id)sender;
// Close current screen handler.
- (void)closeCurrentScreen;
// Shows a confirmation pane.
- (void)showConfirmationPane;

@end

#pragma mark - ATGConfirmPasswordValidator Interface
#pragma mark -

// This validator returns successfully, if input specified will have the same value as
// the value to be validated.
@interface ATGConfirmPasswordValidator : NSObject <ATGInputValidator>

@property (nonatomic, readwrite, strong) ATGValidatableInput *otherInput;

- (id) initWithNewPasswordInput:(ATGValidatableInput *)input;

@end

#pragma mark - ATGNewPasswordValidator Interface
#pragma mark -

// This validator returns successfully, if input specified will have different value
// from the value to be validated.
@interface ATGNewPasswordValidator : NSObject <ATGInputValidator>

@property (nonatomic, readwrite, strong) ATGValidatableInput *otherInput;

- (id) initWithOldPasswordInput:(ATGValidatableInput *)input;

@end

#pragma mark - ATGChangePasswordViewController Implementation
#pragma mark -

@implementation ATGChangePasswordViewController

#pragma mark - Synthesized Properties

@synthesize saveButton;
@synthesize passwordChangedLabel;
@synthesize oldPasswordInput;
@synthesize changePasswordInput;
@synthesize confirmPasswordInput;
@synthesize oldPasswordLabel;
@synthesize changePasswordLabel;
@synthesize confirmPasswordLabel;
@synthesize doneButton;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Set the screen title.
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.ScreenTitle",
       nil, [NSBundle mainBundle], @"Reset Password",
       @"Title to be displayed at the top of the screen changing password.");
  [self setTitle:title];
  
  [[self oldPasswordInput] setLeftView:[self oldPasswordLabel]];
  [[self changePasswordInput] setLeftView:[self changePasswordLabel]];
  [[self confirmPasswordInput] setLeftView:[self confirmPasswordLabel]];
  [[self oldPasswordInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self changePasswordInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self confirmPasswordInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self oldPasswordInput] setBorderWidth:2];
  [[self oldPasswordInput] setErrorWidthFraction:.20];
  [[self changePasswordInput] setBorderWidth:2];
  [[self changePasswordInput] setErrorWidthFraction:.20];
  [[self confirmPasswordInput] setBorderWidth:2];
  [[self confirmPasswordInput] setErrorWidthFraction:.20];

  title = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.OldPasswordPlaceholder",
       nil, [NSBundle mainBundle], @"Old Password",
       @"Placeholder to be used by the input field with old password value.");
  [[self oldPasswordLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.NewPasswordPlaceholder",
       nil, [NSBundle mainBundle], @"New Password",
       @"Placeholder to be used by input field with new password value.");
  [[self changePasswordLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.iPad.ConfirmPasswordPlaceholder",
       nil, [NSBundle mainBundle], @"Confirm Password",
       @"Placeholder to be used by input field with confirmation of the new password.");
  [[self confirmPasswordLabel] setText:title];
  
  title = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.ConfirmPaneCaption",
       nil, [NSBundle mainBundle], @"Your password had been changed.",
       @"Caption to be displayed on the confirmation pane.");
  [[self passwordChangedLabel] setText:title];
  [[self passwordChangedLabel] setHidden:YES];

  [[self changePasswordInput]
   addValidator:[[ATGNewPasswordValidator alloc]
                 initWithOldPasswordInput:[self oldPasswordInput]]];
  [[self confirmPasswordInput]
   addValidator:[[ATGConfirmPasswordValidator alloc]
                 initWithNewPasswordInput:[self changePasswordInput]]];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }
}

- (void)viewDidUnload {
  [self setToolbar:nil];
  [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (CGSize)contentSizeForViewInPopover {
  return self.tableView.contentSize;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [self errorNumberOfRowsInSection:pSection] +
         [super tableView:pTableView numberOfRowsInSection:pSection];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
 replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  return finalLength <= 35;
}

#pragma mark - UI Events Handling

- (void)didTouchDoneButton:(id)pSender {
  if ([[self oldPasswordInput] validate] &[[self changePasswordInput] validate] &
      [[self confirmPasswordInput] validate]) {
    [self startActivityIndication:YES];
    // Submit new password.
    [self setRequest:[[ATGExternalProfileManager profileManager] changePassword:[[self oldPasswordInput] value]
                                                    withConfirmPassword:[[self confirmPasswordInput] value]
                                                        withNewPassword:[[self changePasswordInput] value]
                                                               delegate:self]];
  }
}

#pragma mark - Private Protocol Implementation

- (void)closeCurrentScreen {
  // Just close self.
  [[self navigationController] popViewControllerAnimated:YES];
  // Hide the blocker to allow user interactions.
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
}

- (void)showConfirmationPane {
  ATGConfirmationPane *container = [[ATGConfirmationPane alloc] initWithFrame:CGRectMake(0, 0, 280, 90)];
  container.center = self.view.center;
  NSString *action = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.ConfirmPaneAction",
       nil, [NSBundle mainBundle], @"Done",
       @"Title to be displayed as action on the confirmation pane.");
  [container setButtonText:action];
  NSString *caption = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.ConfirmPaneCaption",
       nil, [NSBundle mainBundle], @"Your password had been changed.",
       @"Caption to be displayed on the confirmation pane.");
  [container setHeaderText:caption];
  // Display the pane.
  ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
  [container setAlpha:0];
  [blocker showBlockView:container withFrame:[[self view] bounds] withTarget:self
               andAction:@selector(closeCurrentScreen) forView:[self view]];
  // And display it smoothly.
  [UIView animateWithDuration:.3 animations:^{
    [container setAlpha:1];
  }];
}

#pragma mark - ATGProfileManagerDelegate

- (void)didChangePassword:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  // Successfully changed password, show confirmation pane.
  [self showConfirmationPane];
  [self.saveButton setEnabled:NO];
}

- (void)didErrorChangingPassword:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequestResults error] inSection:0];
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL)hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self oldPasswordInput];
}

- (BOOL) hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != [self confirmPasswordInput];
}

- (void) activatePreviousInputForTextField:(UITextField *)pTextField {
  UITextField *previousField = nil;
  NSIndexPath *path = nil;
  if (pTextField == [self confirmPasswordInput]) {
    previousField = [self changePasswordInput];
    path = [NSIndexPath indexPathForRow:1 inSection:0];
  } else {
    previousField = [self oldPasswordInput];
    path = [NSIndexPath indexPathForRow:0 inSection:0];
  }
  [[self tableView] scrollToRowAtIndexPath:path
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
  [previousField becomeFirstResponder];
}

- (void)activateNextInputForTextField:(UITextField *)pTextField {
  UITextField *nextField = nil;
  NSIndexPath *path = nil;
  if (pTextField == [self oldPasswordInput]) {
    path = [NSIndexPath indexPathForRow:1 inSection:0];
    nextField = [self changePasswordInput];
  } else {
    path = [NSIndexPath indexPathForRow:2 inSection:0];
    nextField = [self confirmPasswordInput];
  }
  [[self tableView] scrollToRowAtIndexPath:path
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
  [nextField becomeFirstResponder];
}

@end

#pragma mark - ATGConfirmPasswordValidator Implementation
#pragma mark -

@implementation ATGConfirmPasswordValidator

@synthesize otherInput;

- (id)initWithNewPasswordInput:(ATGValidatableInput *)pInput {
  self = [super init];
  if (self) {
    [self setOtherInput:pInput];
  }
  return self;
}

#pragma mark - ATGInputValidator

- (NSError *)validateValue:(id)pValue {
  id newPassword = [[self otherInput] value];
  if ([newPassword isEqual:pValue]) {
    // User successfully confirmed a new password.
    return nil;
  }
  // There is a typo, report the user.
  NSString *errorMessage = NSLocalizedStringWithDefaultValue
      (@"ATGChangePasswordViewController.ConfirmPasswordErrorMessage", nil,
       [NSBundle mainBundle], @"Must match",
       @"Error message to be displayed when confirm password not matches new password.");
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                       forKey:NSLocalizedDescriptionKey];
  return [NSError errorWithDomain:ATGInputValidatorErrorDomain code:-1 userInfo:userInfo];
}

@end

#pragma mark - ATGNewPasswordValidator Implementation
#pragma mark -

@implementation ATGNewPasswordValidator

@synthesize otherInput;

- (id)initWithOldPasswordInput:(ATGValidatableInput *)pInput {
  self = [super init];
  if (self) {
    [self setOtherInput:pInput];
  }
  return self;
}

#pragma mark - ATGInputValidator

- (NSError *)validateValue:(id)pValue {
  id oldPassword = [[self otherInput] value];
  if ([oldPassword isEqual:pValue]) {
    // User uses old password. Tell him that this is wrong.
    NSString *errorMessage = NSLocalizedStringWithDefaultValue
        (@"ATGChangePasswordViewController.NewPasswordErrorMessage", nil,
         [NSBundle mainBundle], @"Can't reuse old password",
         @"Error message to be displayed when new password matches old password.");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                         forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:ATGInputValidatorErrorDomain code:-1 userInfo:userInfo];
  }
  return nil;
}

@end