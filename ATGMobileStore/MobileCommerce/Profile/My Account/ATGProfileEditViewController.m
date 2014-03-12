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

#import "ATGProfileEditViewController.h"
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGProfile.h>

NSString *const ATGProfileEditToPrivacyTermsSegue = @"profileEditToMoreDetails";

// We have 8 rows in the edit profile screen: First name, last name, email, zip, phone, gender, birthday, and
// email preference
const NSInteger ATGProfileEditRowsCount = 8;

#pragma mark - ATGProfileEditViewController Private Protocol
#pragma mark -

@interface ATGProfileEditViewController () <ATGKeyboardToolbarDelegate, UITextFieldDelegate,
    UIPickerViewDelegate, UIPickerViewDataSource, ATGProfileManagerDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *postalCodeLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *genderlabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *birthdayLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *sendPromotionsLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *firstNameInput;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *lastNameInput;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *emailInput;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *postalCodeInput;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *phoneInput;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *genderInput;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *birthdayInput;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *checkMarkImage;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *doneButton;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) UIPickerView *genderPicker;
@property (nonatomic, readwrite, strong) UIDatePicker *birthdayPicker;
@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readwrite, assign) BOOL receiveEmailsOldFlag;
@property (nonatomic, readwrite, assign) BOOL receiveEmailsFlag;
@property (nonatomic, readwrite, strong) NSString *oldEmail;
@property (nonatomic, readwrite, strong) NSDate *dateOfBirth;
@property (nonatomic, readwrite, strong) NSString *gender;
@property (nonatomic, readwrite, strong) NSDictionary *availableGenders;
@property (nonatomic, readwrite, strong) NSArray *genderCodes;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) ATGKeyboardToolbar *toolbar;
@property (nonatomic, readwrite, strong) ATGProfile *personalInfo;

#pragma mark - Private Protocol Definition

- (void)didChangeBirthday:(UIDatePicker *)picker;
- (IBAction)didDoneEditing:(id)sender;
- (NSIndexPath *)indexPathFromTextField:(UITextField *)textField;

@end

#pragma mark - ATGProfileEditViewController Implementation
#pragma mark -

@implementation ATGProfileEditViewController

#pragma mark - Synthesized Properties

@synthesize genderPicker;
@synthesize birthdayPicker;
@synthesize dateFormatter;
@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize emailLabel;
@synthesize postalCodeLabel;
@synthesize phoneLabel;
@synthesize genderlabel;
@synthesize birthdayLabel;
@synthesize sendPromotionsLabel;
@synthesize firstNameInput;
@synthesize lastNameInput;
@synthesize emailInput;
@synthesize postalCodeInput;
@synthesize phoneInput;
@synthesize genderInput;
@synthesize birthdayInput;
@synthesize checkMarkImage;
@synthesize doneButton;
@synthesize personalInfo;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *undefined = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderUnknown", nil, [NSBundle mainBundle],
       @"Select Gender", @"Unknown gender.");
  NSString *male = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderMale", nil, [NSBundle mainBundle],
       @"Male", @"Male gender.");
  NSString *female = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderFemale", nil, [NSBundle mainBundle],
       @"Female", @"Female gender.");
  [self setAvailableGenders:[[NSDictionary alloc] initWithObjectsAndKeys:undefined, @"unknown",
                             male, @"male", female, @"female", nil]];
  [self setGenderCodes:[[NSArray alloc] initWithObjects:@"unknown", @"male", @"female", nil]];
  // Init value for 'receive emails' property.
  [self setReceiveEmailsFlag:YES];
  [(UITableView *)[self view] setBackgroundColor:[UIColor tableBackgroundColor]];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.Title",
       nil, [NSBundle mainBundle], @"Edit My Profile",
       @"Title to be displayed at the top of the screen which allows to edit user profile details.");
  if ([self isPad]) {
    title = NSLocalizedStringWithDefaultValue
        (@"ATGProfileEditViewController.iPad.Title",
         nil, [NSBundle mainBundle], @"Personal Info",
         @"Title to be displayed at the top of the screen which allows to edit user profile details.");
  }
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

  [[self firstNameInput] setLeftView:[self firstNameLabel]];
  [[self firstNameInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self firstNameInput] setBorderWidth:2];
  [[self firstNameInput] setErrorWidthFraction:.25];
  [[self lastNameInput] setLeftView:[self lastNameLabel]];
  [[self lastNameInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self lastNameInput] setBorderWidth:2];
  [[self lastNameInput] setErrorWidthFraction:.25];
  [[self emailInput] setLeftView:[self emailLabel]];
  [[self emailInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self emailInput] setBorderWidth:2];
  [[self emailInput] setErrorWidthFraction:.25];
  [[self birthdayInput] setLeftView:[self birthdayLabel]];
  [[self birthdayInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self genderInput] setLeftView:[self genderlabel]];
  [[self genderInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self phoneInput] setLeftView:[self phoneLabel]];
  [[self phoneInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self postalCodeInput] setLeftView:[self postalCodeLabel]];
  [[self postalCodeInput] setLeftViewMode:UITextFieldViewModeAlways];

  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.FirstNamePlaceholer",
       nil, [NSBundle mainBundle], @"First Name",
       @"Placeholder to be used by input field with first name.");
  [[self firstNameLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.LastNamePlaceholer",
       nil, [NSBundle mainBundle], @"Last Name",
       @"Placeholder to be used by input field with last name.");
  [[self lastNameLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.EmailPlaceholer",
       nil, [NSBundle mainBundle], @"Email",
       @"Placeholder to be used by input field with email.");
  [[self emailLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.iPad.ZipPlaceholder",
       nil, [NSBundle mainBundle], @"Zip / Postal Code",
       @"Placeholder to be used by input field with postal code on iPad.");
  [[self postalCodeLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.iPad.PhonePlaceholder",
       nil, [NSBundle mainBundle], @"Phone",
       @"Placeholder to be used by input field with phone number on iPad.");
  [[self phoneLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.GenderPlaceholer",
       nil, [NSBundle mainBundle], @"Gender",
       @"Placeholder to be used by input field with gender.");
  [[self genderlabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.iPad.BirthdayPlaceholder",
       nil, [NSBundle mainBundle], @"Birthday",
       @"Placeholder to be used by input field with date of birthday on iPad.");
  [[self birthdayLabel] setText:title];
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.iPad.EmailMeTitle",
       nil, [NSBundle mainBundle], @"Email me about promotions / sales",
       @"Title of the checkbox defining whether to subscribe the user onto promotion emails on iPad.");
  [[self sendPromotionsLabel] setText:title];
  
  if ([[self birthdayInput] isKindOfClass:[ATGValidatableInput class]]) {
    [(ATGValidatableInput *)[self birthdayInput] removeAllValidators];
  }
  if ([[self genderInput] isKindOfClass:[ATGValidatableInput class]]) {
    [(ATGValidatableInput *)[self genderInput] removeAllValidators];
  }
  if ([[self phoneInput] isKindOfClass:[ATGValidatableInput class]]) {
    [(ATGValidatableInput *)[self phoneInput] removeAllValidators];
  }
  if ([[self postalCodeInput] isKindOfClass:[ATGValidatableInput class]]) {
    [(ATGValidatableInput *)[self postalCodeInput] removeAllValidators];
  }

  [[self emailInput] addValidator:[[ATGEmailValidator alloc] init]];

  UIPickerView *pickerGender = [[UIPickerView alloc] init];
  [pickerGender setDataSource:self];
  [pickerGender setDelegate:self];
  [pickerGender setShowsSelectionIndicator:YES];
  [self setGenderPicker:pickerGender];

  UIDatePicker *pickerBirthday = [[UIDatePicker alloc] init];
  [pickerBirthday setDatePickerMode:UIDatePickerModeDate];
  [pickerBirthday setMaximumDate:[NSDate date]];
  [pickerBirthday addTarget:self action:@selector(didChangeBirthday:)
           forControlEvents:UIControlEventValueChanged];
  [self setBirthdayPicker:pickerBirthday];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  // Use a specific template for the DoB formatting.
  [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMMdd"
                                                           options:0
                                                            locale:[NSLocale currentLocale]]];
  [self setDateFormatter:formatter];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }
}

- (void)viewDidUnload {
  [self setGenderPicker:nil];
  [self setDateFormatter:nil];
  [self setBirthdayPicker:nil];
  [self setToolbar:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  if (![self personalInfo]) {
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self activityIndicator] startAnimating];
    [[self request] setDelegate:nil];
    [[self request] cancelRequest];
    [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
  }
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (CGSize)contentSizeForViewInPopover {
//  NSInteger numberOfRows = [[self tableView] numberOfRowsInSection:0];
//  CGFloat footerHeight = 0;
//  UIView *footerView = [[self tableView] tableFooterView];
//  if (footerView) {
//    footerHeight = [footerView bounds].size.height;
//  }
//  return CGSizeMake(ATGDefaultScreenWidth, numberOfRows * [[self tableView] rowHeight] + footerHeight);
  return self.tableView.contentSize;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection > 0) {
    return [self personalInfo] ? [super tableView:pTableView numberOfRowsInSection:pSection] : 0;
  } else if ([self personalInfo]) {
    return ATGProfileEditRowsCount + [self errorNumberOfRowsInSection:pSection];
  }
  return 0;
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

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  } else {
    return [pTableView rowHeight];
  }
}

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ( [pIndexPath row] == ([self isPad] ? 7 : 5) ) {
    [[self checkMarkImage] setHidden:![self receiveEmailsFlag]];
    if ([self receiveEmailsFlag]) {
      [pCell setAccessibilityTraits:UIAccessibilityTraitSelected];
    } else {
      [pCell setAccessibilityTraits:UIAccessibilityTraitStaticText];
    }
    [pCell setAccessibilityHint:NSLocalizedStringWithDefaultValue
       (@"ATGProfileEditViewController.Accessibility.Hint.PromotionsCell",
        nil, [NSBundle mainBundle], @"Double tap to change selection.",
        @"Accessibility hint to be used by the EmailMe cell on the Edit Account screen.")];
  }
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  if ([[self shiftIndexPath:pIndexPath] row] ==
          ([self isPad] ? 7 : 5)) {
    [self setReceiveEmailsFlag:![self receiveEmailsFlag]];
    [[self checkMarkImage] setHidden:![self receiveEmailsFlag]];
    if ([self receiveEmailsFlag]) {
      [[pTableView cellForRowAtIndexPath:pIndexPath] setAccessibilityTraits:UIAccessibilityTraitSelected];
    } else {
      [[pTableView cellForRowAtIndexPath:pIndexPath] setAccessibilityTraits:UIAccessibilityTraitStaticText];
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
  } else {
    [[[[pTableView cellForRowAtIndexPath:pIndexPath] contentView] subviews]
     enumerateObjectsUsingBlock: ^(id pObject, NSUInteger pIndex, BOOL * pStop) {
       if ([pObject canBecomeFirstResponder]) {
         [pObject becomeFirstResponder];
         *pStop = YES;
       }
     }];
  }
}

- (NSInteger)tableView:(UITableView *)pTableView indentationLevelForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] < [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    return 0;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView indentationLevelForRowAtIndexPath:pIndexPath];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pPickerView {
  // Configuring a Gender picker. It should have only one component.
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pPickerView numberOfRowsInComponent:(NSInteger)pComponent {
  // How many genders do we have?
  return [[self genderCodes] count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pPickerView titleForRow:(NSInteger)pRow
            forComponent:(NSInteger)pComponent {
  // Return gender name.
  return [[self availableGenders] objectForKey:[[self genderCodes] objectAtIndex:pRow]];
}

- (void)pickerView:(UIPickerView *)pPickerView didSelectRow:(NSInteger)pRow
       inComponent:(NSInteger)pComponent {
  [self setGender:[[self genderCodes] objectAtIndex:pRow]];
  [[self genderInput] setText:[[self availableGenders] objectForKey:[self gender]]];
  if (pRow == 0) {
    [[self genderInput] setText:nil];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)pTextField {
  if (pTextField == [self genderInput]) {
    if ([self isPad]) {
      [[self view] endEditing:YES];
      [[self genderPicker] selectRow:[[self genderCodes] indexOfObject:[self gender]] inComponent:0
                            animated:YES];
      [[self tableView] setTableFooterView:[self genderPicker]];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
      return NO;
    } else {
      [pTextField setInputView:[self genderPicker]];
      [[self genderPicker] selectRow:[[self genderCodes] indexOfObject:[self gender]]
                         inComponent:0
                            animated:YES];
    }
  } else if (pTextField == [self birthdayInput]) {
    if ([self isPad]) {
      [[self view] endEditing:YES];
      [[self birthdayPicker] setDate:[self dateOfBirth] ? [self dateOfBirth] : [NSDate date]
                            animated:YES];
      [[self tableView] setTableFooterView:[self birthdayPicker]];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
      return NO;
    } else {
      [pTextField setInputView:[self birthdayPicker]];
      [[self birthdayPicker] setDate:[self dateOfBirth] ? [self dateOfBirth] : [NSDate date]
                            animated:YES];
    }
  } else if ([self isPad]) {
    [[self tableView] setTableFooterView:nil];
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
  return YES;
}

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  if (pTextField == [self postalCodeInput]) {
    return finalLength <= 10;
  } else if (pTextField == [self phoneInput]) {
    return finalLength <= 15;
  } else {
    return finalLength <= 40;
  }
  return YES;
}

#pragma mark - UI Event Handlers

- (void)didDoneEditing:(id)pSender {
  BOOL valid = [[self emailInput] validate];
  valid = [[self firstNameInput] validate] && valid;
  valid = [[self lastNameInput] validate] && valid;
  if (!valid) {
    return;
  }
  // Save changes on server.
  ATGProfile *newInfo = [[ATGProfile alloc] init];
  [newInfo setEmail:[[self emailInput] text]];
  [newInfo setFirstName:[[self firstNameInput] text]];
  [newInfo setLastName:[[self lastNameInput] text]];
  [newInfo setPostalCode:[[self postalCodeInput] text]];
  [newInfo setPhoneNumber:[[self phoneInput] text]];
  [newInfo setGender:[self gender]];
  [newInfo setDateOfBirth:[self dateOfBirth]];
  [newInfo setReceivePromoEmail:[self receiveEmailsFlag]];
  [newInfo setPreviousOptInStatus:[self receiveEmailsOldFlag]];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] updatePersonalInformation:newInfo
                                                                    withOldEmail:[self oldEmail]
                                                                        delegate:self]];
}

- (void)didChangeBirthday:(UIDatePicker *)pPicker {
  [self setDateOfBirth:[pPicker date]];
  [[self birthdayInput] setText:[[self dateFormatter] stringFromDate:[self dateOfBirth]]];
  if (UIAccessibilityIsVoiceOverRunning()) {
    NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
    [fullDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [fullDateFormatter setLocale:[NSLocale currentLocale]];
    [[self birthdayInput] setAccessibilityValue:[fullDateFormatter stringFromDate:[pPicker date]]];
  }
}

#pragma mark - Private Protocol Implementation

- (NSIndexPath *)indexPathFromTextField:(UITextField *)pTextField {
  if (pTextField == [self firstNameInput]) {
    return [NSIndexPath indexPathForRow:0 inSection:0];
  } else if (pTextField == [self lastNameInput]) {
    return [NSIndexPath indexPathForRow:1 inSection:0];
  } else if (pTextField == [self emailInput]) {
    return [NSIndexPath indexPathForRow:2 inSection:0];
  } else if (pTextField == [self postalCodeInput] || pTextField == [self phoneInput]) {
    return [NSIndexPath indexPathForRow:3 inSection:0];
  } else {
    return [NSIndexPath indexPathForRow:4 inSection:0];
  }
  return nil;
}

#pragma mark - ATGProfileManagerDelegate

- (void)didGetProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self setPersonalInfo:[pRequestResults requestResults]];
  [self setOldEmail:[[self personalInfo] email]];
  [[self emailInput] setValue:[[self personalInfo] email]];
  [[self firstNameInput] setValue:[[self personalInfo] firstName]];
  [[self lastNameInput] setValue:[[self personalInfo] lastName]];
  [[self postalCodeInput] setText:[[self personalInfo] postalCode]];
  [[self phoneInput] setText:[[self personalInfo] phoneNumber]];
  [[self genderInput] setText:[[self availableGenders] objectForKey:[[self personalInfo] gender]]];
  if ([[self genderCodes] indexOfObject:[[self personalInfo] gender]] == 0) {
    // User has unknown gender, display placeholder instead of this value.
    [[self genderInput] setText:nil];
  }
  [[self birthdayInput] setText:[[self dateFormatter] stringFromDate:[[self personalInfo] dateOfBirth]]];
  if (UIAccessibilityIsVoiceOverRunning()) {
    NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
    [fullDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [fullDateFormatter setLocale:[NSLocale currentLocale]];
    [[self birthdayInput] setAccessibilityValue:[fullDateFormatter
                                                 stringFromDate:[[self personalInfo] dateOfBirth]]];
  }
  [self setGender:[[self personalInfo] gender]];
  [self setDateOfBirth:[[self personalInfo] dateOfBirth]];
  [self setReceiveEmailsOldFlag:[[self personalInfo] receivePromoEmail]];
  [self setReceiveEmailsFlag:[self receiveEmailsOldFlag]];

  [[self activityIndicator] stopAnimating];
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

  [[self tableView] beginUpdates];
  [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
  [[self tableView] endUpdates];

  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (void)didErrorGettingProfile:(ATGProfileManagerRequest *)pRequestResults {
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequestResults error] localizedDescription]];
}

- (void)didUpdatePersonalInformation:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [[self navigationController] popViewControllerAnimated:YES];
  if ([self isPad]) {
    [[ATGRootViewController_iPad rootViewController] reloadHomepage];
  }
}

- (void)didErrorUpdatingPersonalInformation:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequestResults error] inSection:0];
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL)hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self firstNameInput];
}

- (BOOL)hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != [self birthdayInput];
}

- (void)activatePreviousInputForTextField:(UITextField *)pTextField {
  UITextField *previousField = nil;
  if (pTextField == [self birthdayInput]) {
    previousField = [self genderInput];
  } else if (pTextField == [self genderInput]) {
    previousField = [self phoneInput];
  } else if (pTextField == [self phoneInput]) {
    previousField = [self postalCodeInput];
  } else if (pTextField == [self postalCodeInput]) {
    previousField = [self emailInput];
  } else if (pTextField == [self emailInput]) {
    previousField = [self lastNameInput];
  } else {
    previousField = [self firstNameInput];
  }
  [[self tableView] scrollToRowAtIndexPath:[self indexPathFromTextField:previousField]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  [previousField becomeFirstResponder];
}

- (void)activateNextInputForTextField:(UITextField *)pTextField {
  UITextField *nextField = nil;
  if (pTextField == [self firstNameInput]) {
    nextField = [self lastNameInput];
  } else if (pTextField == [self lastNameInput]) {
    nextField = [self emailInput];
  } else if (pTextField == [self emailInput]) {
    nextField = [self postalCodeInput];
  } else if (pTextField == [self postalCodeInput]) {
    nextField = [self phoneInput];
  } else if (pTextField == [self phoneInput]) {
    nextField = [self genderInput];
  } else if (pTextField == [self genderInput]) {
    nextField = [self birthdayInput];
  }
  [[self tableView] scrollToRowAtIndexPath:[self indexPathFromTextField:nextField]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  [nextField becomeFirstResponder];
}

@end