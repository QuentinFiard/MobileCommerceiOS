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

#import "ATGSignupTableViewCell_iPad.h"
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGMobileCommon/UIImage+ATGAdditions.h>

#pragma mark - ATGSignupTableViewCell_iPad Private Protocol
#pragma mark -

@interface ATGSignupTableViewCell_iPad () <UIPickerViewDelegate, UIPickerViewDataSource,
    UITableViewDelegate, UITableViewDataSource, ATGKeyboardToolbarDelegate, UITextFieldDelegate>

#pragma mark - IB Outlets

@property (strong) IBOutlet UILabel *labelCellCaption;
@property (strong) IBOutlet UITableView *tableSignUpOptions;
@property (strong) IBOutlet UIImageView *imageAccessory;

#pragma mark - Custom Properties

@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSDictionary *availableGenders;
@property (nonatomic, strong) NSArray *genderCodes;
@property (nonatomic, strong) NSDictionary *interviewOptions;
@property (nonatomic, strong) NSArray *interviewCodes;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSString *interviewResult;

@property (nonatomic, readwrite, strong) UIPickerView *genderPicker;
@property (nonatomic, strong) UIPickerView *interviewPicker;
@property (nonatomic, readwrite, strong) UIDatePicker *birthdayPicker;
@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UITableViewCell *observingCell;
@property (nonatomic, strong) ATGValidatableInput *inputEmail;
@property (nonatomic, strong) ATGValidatableInput *inputPassword;
@property (nonatomic, strong) ATGValidatableInput *inputConfirmPassword;
@property (nonatomic, strong) ATGValidatableInput *inputFirstName;
@property (nonatomic, strong) ATGValidatableInput *inputLastName;
@property (nonatomic, strong) ATGValidatableInput *inputZipCode;
@property (nonatomic, strong) ATGValidatableInput *inputGender;
@property (nonatomic, strong) ATGValidatableInput *inputDOB;
@property (nonatomic, strong) ATGValidatableInput *inputHear;
@property (nonatomic, strong) ATGKeyboardToolbar *toolbar;
@property (nonatomic, strong) UITextField *currentInput;

#pragma mark - Private Protocol Definition

- (void)didChangeBirthday:(UIDatePicker *)pPicker;
- (void)didTouchSignUpButton:(id)pSender;

@end

#pragma mark - ATGSignupTableViewCell_iPad Implementation
#pragma mark -

@implementation ATGSignupTableViewCell_iPad

#pragma mark - Synthesized Properties

@synthesize labelCellCaption, observingCell, inputEmail, email, tableSignUpOptions,
    toolbar, imageAccessory, error;
@synthesize inputPassword, inputFirstName, inputLastName, delegate, inputConfirmPassword,
    inputZipCode, inputGender, inputDOB, inputHear;
@synthesize availableGenders, genderCodes, gender, genderPicker, birthdayPicker,
    dateFormatter, dateOfBirth, interviewPicker, interviewResult, interviewOptions, interviewCodes;

#pragma mark - Custom Properties Implementation

- (void)setEmail:(NSString *)pEmail {
  if (pEmail != self->email) {
    self->email = [pEmail copy];
    [self.inputEmail setValue:self.email];
  }
}

- (void)setError:(NSString *)pError {
  BOOL hasError = [self error] != nil;
  if (pError != self->error) {
    self->error = [pError copy];
  }
  CGFloat prevErrorHeight = 0;
  if (hasError) {
    prevErrorHeight = [self tableView:self.tableSignUpOptions
              heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  }
  if (hasError) {
    [self.tableSignUpOptions
     reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                        inSection:0]]
     withRowAnimation:UITableViewRowAnimationRight];
  } else {
    [self.tableSignUpOptions
     insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                        inSection:0]]
     withRowAnimation:UITableViewRowAnimationTop];
  }
  if (pError) {
    CGRect frame = [self.tableSignUpOptions frame];
    frame.size.height += [self tableView:self.tableSignUpOptions
                 heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    frame.size.height -= prevErrorHeight;
    [self.tableSignUpOptions setFrame:frame];
    [self inputEmail].layer.mask = nil;
  }
}

#pragma mark - Public Protocol Implementation

+ (ATGSignupTableViewCell_iPad *)newInstance {
  // Load new instance from a NIB file.
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ATGSignupTableViewCell_iPad"
                                                   owner:nil options:nil];
  for (id object in objects) {
    // Return object of a proper class only.
    if ([object isKindOfClass:[ATGSignupTableViewCell_iPad class]]) {
      return object;
    }
  }
  return nil;
}

#pragma mark - NSObject

- (void)dealloc {
  [self.observingCell removeObserver:self forKeyPath:@"frame"];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidShowNotification
                                                object:nil];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:self];

  NSString *caption = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.CellCaption", nil, [NSBundle mainBundle],
       @"Sign Up", @"Caption to be displayed on the SignUp cell.");
  [[self labelCellCaption] setText:caption];
  [[self labelCellCaption] applyStyleWithName:@"formTitleLabel"];
  [self.tableSignUpOptions setBackgroundColor:[UIColor subTableBackgroundColor]];

  NSString *undefined = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderUnknown", nil, [NSBundle mainBundle],
       @"Select Gender", @"Unknown gender.");
  NSString *male = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderMale", nil, [NSBundle mainBundle],
       @"Male", @"Male gender.");
  NSString *female = NSLocalizedStringWithDefaultValue
      (@"ATGProfileEditViewController.genderFemale", nil, [NSBundle mainBundle],
       @"Female", @"Female gender.");

  self.availableGenders = [[NSDictionary alloc] initWithObjectsAndKeys:undefined, @"unknown",
                           male, @"male", female, @"female", nil];
  self.genderCodes = [[NSArray alloc] initWithObjects:@"unknown", @"male", @"female", nil];

  NSString *unknown = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.Unknown", nil, [NSBundle mainBundle],
       @"Unknown", @"Unknown referral source. Used by referral picker");
  NSString *friend = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.Friend", nil, [NSBundle mainBundle],
       @"Friend", @"Referral friend. Used by referral picker.");
  NSString *url = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.URL", nil, [NSBundle mainBundle],
       @"Just typed in your URL", @"Just typed in your URL referral source. Used by referral picker.");
  NSString *Ad = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.OnlineAd", nil, [NSBundle mainBundle],
       @"Online Ad or Link", @"Online Ad referral source. Used by referral picker.");
  NSString *press = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.PressArticle", nil, [NSBundle mainBundle],
       @"Press Article", @"Press referral source. Used by referral picker.");
  NSString *radio = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.Radio", nil, [NSBundle mainBundle],
       @"Radio", @"Radio referral source. Used by referral picker.");
  NSString *tv = NSLocalizedStringWithDefaultValue
      (@"ATGSignupTableViewCell.TV", nil, [NSBundle mainBundle],
       @"TV", @"TV referral source. Used by referral picker.");

  self.interviewCodes = [NSArray arrayWithObjects:@"unknown", @"friend", @"justTypedURL", @"onlineAdLink", @"pressArticle", @"radio", @"tv", nil];
  self.interviewOptions = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:unknown, friend, url, Ad, press, radio, tv, nil] forKeys:self.interviewCodes];

  UIPickerView *interview = [[UIPickerView alloc] init];
  [interview setDataSource:self];
  [interview setDelegate:self];
  [interview setShowsSelectionIndicator:YES];
  [self setInterviewPicker:interview];

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
  [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"Mdyyyy"
                                                           options:0
                                                            locale:[NSLocale currentLocale]]];
  [formatter setLocale:[NSLocale currentLocale]];
  [self setDateFormatter:formatter];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification object:nil];
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGAffineTransform transform;
  if ([self isSelected]) {
    // The cell is selected, rotate the accessory arrow.
    transform = CGAffineTransformMakeRotation(-M_PI);
  } else {
    transform = CGAffineTransformIdentity;
  }
  [self.imageAccessory setTransform:transform];
}

- (void)clearFormFields {
  self.inputPassword.text = nil;
  [self.inputPassword invalidate:nil];
  self.inputConfirmPassword.text = nil;
  [self.inputConfirmPassword invalidate:nil];
  self.inputFirstName.text = nil;
  [self.inputFirstName invalidate:nil];
  self.inputLastName.text = nil;
  [self.inputLastName invalidate:nil];
  self.inputZipCode.text = nil;
  self.inputGender.text = nil;
  self.inputDOB.text = nil;
  self.inputHear.text = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  // One section will hold sign up options while the other will hold a button.
  return 2;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // 9 sign up options
    return 9 + ([self error] != nil ? 1 : 0);
  } else {
    // And one button.
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([self error] != nil && [pIndexPath section] == 0 && [pIndexPath row] == 0) {
    UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    [cell setBackgroundColor:[UIColor errorColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label applyStyleWithName:@"formTextLabel"];
    [label setTextColor:[UIColor textHighlightedColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    CGRect bounds = [[cell contentView] bounds];
    bounds.origin.x = 12;
    bounds.size.width -= bounds.origin.x * 2;
    bounds.origin.y = bounds.origin.x;
    bounds.size.height -= bounds.origin.y * 2;
    [label setFrame:bounds];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleHeight];
    [label setText:error];
    [[cell contentView] addSubview:label];
    return cell;
  }
  if ([pIndexPath section] == 0) {
    // Use standard cells when filling in the inner table.
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:reuseIdentifier];
      [cell setBackgroundColor:[UIColor tableCellBackgroundColor]];
    }

    //display icon for cell with pickers
    if ([pIndexPath row] > 5) {
      UIImageView *accessoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 9)];
      [accessoryImage setContentMode:UIViewContentModeCenter];
      [accessoryImage setImage:[UIImage locateImageNamed:@"icon-storeCell-more.png"]];
      [cell setAccessoryView:accessoryImage];
    }

    // Do not allow the user to select the cells.
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
  } else {
    ATGButtonTableViewCell *cell =
      [[ATGButtonTableViewCell alloc] initWithReuseIdentifier:nil showUnderlay:NO];
    // Fill the button with localized content.
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGSignupTableViewCell.DoneButtonTitle", nil, [NSBundle mainBundle],
         @"Sign Up", @"Title to be displayed on the Done button.");
    [[cell button] setTitle:title forState:UIControlStateNormal];
    NSString *label = NSLocalizedStringWithDefaultValue
        (@"ATGSignupTableViewCell.DoneButtonAccessibilityLabel", nil,
         [NSBundle mainBundle], @"Sign up",
         @"Accessibility label to be used by the sign up button.  This button is used to submit "
         @"your account information to sign up with an account.");
    [[cell button] setAccessibilityLabel:label];
    NSString *hint = NSLocalizedStringWithDefaultValue
        (@"ATGSignupTableViewCell.DoneButtonAccessibilityHint", nil,
         [NSBundle mainBundle], @"Signs you up.",
         @"Accessibility hint to be used by the Done button.");
    [[cell button] setAccessibilityHint:hint];
    // What action to do on click?
    [[cell button] addTarget:self action:@selector(didTouchSignUpButton:)
            forControlEvents:UIControlEventTouchUpInside];
    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([self error] && [pIndexPath section] == 0 && [pIndexPath row] == 0) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label applyStyleWithName:@"formTextLabel"];
    CGSize maxSize = CGSizeMake([pTableView bounds].size.width - 48, 1000);
    CGSize size = [[self error] sizeWithFont:[label font]
                           constrainedToSize:maxSize
                               lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height + 24 > [pTableView rowHeight]) {
      return size.height + 24;
    } else {
      return [pTableView rowHeight];
    }
  } else {
    return [self.tableSignUpOptions rowHeight];
  }
}

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    if ([pIndexPath row] == 0 && [self error] != nil) {
      return;
    } else if ([self error]) {
      pIndexPath = [NSIndexPath indexPathForRow:[pIndexPath row] - 1 inSection:0];
    }
    // Sign up options.
    if ([pIndexPath row] < 9) {
      // All options should contain a validatable input field.
      CGRect cellBounds = [[pCell contentView] bounds];
      // if ipad and iOS 7 or greater, shrink the input to account for table cells spanning the entire screen and some text getting cut off.
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        cellBounds.size.width -= 18;
      } else{
        cellBounds.size.width -= 2;
      }
      cellBounds.size.height = [pTableView rowHeight] - 1;
      ATGValidatableInput *input = [[ATGValidatableInput alloc] initWithFrame:cellBounds];
      [[pCell contentView] addSubview:input];
      [input setTag:15];
      [input setDelegate:self];
      NSString *placeholder = nil;
      // Choose placeholder based on field position.
      // Also save input view created into proper instance variable.

      UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 120, 21)];
      switch ([pIndexPath row]) {
        case 0: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.EmailInputPlaceholder", nil,
               [NSBundle mainBundle], @"Email",
               @"Placeholder to be used by the Email text field.");
          self.inputEmail = input;
          [self.inputEmail setKeyboardType:UIKeyboardTypeEmailAddress];
          // Add email validator to the input.
          ATGEmailValidator *validator = [[ATGEmailValidator alloc] init];
          [self.inputEmail addValidator:validator];
          [self.inputEmail setValue:self.email];
        }
        break;

        case 1: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.PasswordInputPlaceholder", nil,
               [NSBundle mainBundle], @"Password",
               @"Placeholder to be used by the Password text field.");
          // Password input should be secured.
          [input setSecureTextEntry:YES];
          self.inputPassword = input;
        }
        break;

        case 2: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.PasswordConfirmInputPlaceholder", nil,
               [NSBundle mainBundle], @"Confirm Password",
               @"Placeholder to be used by the Confirm Password text field.");
          // Confirm Password input should be secured.
          [input setSecureTextEntry:YES];
          self.inputConfirmPassword = input;
          break;
        }

        case 3: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.FirstNameInputPlaceholder", nil,
               [NSBundle mainBundle], @"First Name",
               @"Placeholder to be used by the FirstName text field.");
          self.inputFirstName = input;
        }
        break;

        case 4: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.LastNameInputPlaceholder", nil,
               [NSBundle mainBundle], @"Last Name",
               @"Placeholder to be used by the LastName text field.");
          self.inputLastName = input;
          break;
        }

        case 5: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.ZipCodeInputPlaceholder", nil,
               [NSBundle mainBundle], @"Zip / Postal Code",
               @"Placeholder to be used by the Postal Code text field.");
          [input setPlaceholder:NSLocalizedStringWithDefaultValue
              (@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil, [NSBundle mainBundle],
               @"Optional", @"Phone number text field placeholder")];
          input.keyboardType = UIKeyboardTypeNumberPad;
          [input removeAllValidators];
          self.inputZipCode = input;
          break;
        }

        case 6: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.GenderInputPlaceholder", nil,
               [NSBundle mainBundle], @"Gender",
               @"Placeholder to be used by the Gender text field.");
          [input removeAllValidators];
          [input setPlaceholder:NSLocalizedStringWithDefaultValue
              (@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil, [NSBundle mainBundle],
               @"Optional", @"Phone number text field placeholder")];
          [input setInputView:self.genderPicker];
          self.inputGender = input;
          break;
        }

        case 7: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.DateofBirthInputPlaceholder", nil,
               [NSBundle mainBundle], @"Date of Birth",
               @"Placeholder to be used by the Date of Birth text field on registration form.");
          [input removeAllValidators];
          [input setPlaceholder:NSLocalizedStringWithDefaultValue
              (@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil, [NSBundle mainBundle],
               @"Optional", @"Phone number text field placeholder")];
          [input setInputView:self.birthdayPicker];
          self.inputDOB = input;
          break;
        }

        case 8: {
          placeholder = NSLocalizedStringWithDefaultValue
              (@"ATGSignupTableViewCell.HowDidYouHearInputPlaceholder", nil,
               [NSBundle mainBundle], @"How did you hear about us",
               @"Placeholder to be used by the Advert text field.");
          [input removeAllValidators];
          [input setPlaceholder:NSLocalizedStringWithDefaultValue
              (@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil, [NSBundle mainBundle],
               @"Optional", @"Phone number text field placeholder")];
          [input setInputView:self.interviewPicker];
          self.inputHear = input;
          self.inputHear.layer.mask = [pCell createMaskForIndexPath:pIndexPath inTableView:pTableView];
          CGRect frame = captionLabel.frame;
          frame.size.width = 165;
          [captionLabel setFrame:frame];
          break;
        }

        default:
          break;
      }
      captionLabel.text = placeholder;
      [captionLabel applyStyleWithName:@"formCaptionLabel"];
      [input setLeftView:captionLabel];
      [input setLeftViewMode:UITextFieldViewModeAlways];
      [input setBorderWidth:2];
      [input setErrorWidthFraction:.25];
      [input applyStyle:ATGTextFieldFormText_iPad];
      [input setDelegate:self];
      if ([pIndexPath row] < 2) {
        [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [input setAutocorrectionType:UITextAutocorrectionTypeNo];
      }
      [input setReturnKeyType:UIReturnKeyGo];

      [input setInputAccessoryView:self.toolbar];
    }
  }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pPickerView {
  // Configuring a Gender picker. It should have only one component.
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pPickerView numberOfRowsInComponent:(NSInteger)pComponent {
  if (pPickerView == self.genderPicker) {
    // How much genders do we have?
    return [self.genderCodes count];
  } else {
    // How much referral options do we have?
    return [self.interviewCodes count];
  }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pPickerView titleForRow:(NSInteger)pRow
            forComponent:(NSInteger)pComponent {
  if (pPickerView == self.genderPicker) {
    // Return gender name.
    return [self.availableGenders objectForKey:[self.genderCodes objectAtIndex:pRow]];
  } else {
    // Return referral option name
    return [self.interviewOptions objectForKey:[self.interviewCodes objectAtIndex:pRow]];
  }
}

- (void)pickerView:(UIPickerView *)pPickerView didSelectRow:(NSInteger)pRow
       inComponent:(NSInteger)pComponent {
  if (pPickerView == self.genderPicker) {
    self.gender = [self.genderCodes objectAtIndex:pRow];
    [self.inputGender setText:[self.availableGenders objectForKey:self.gender]];
    if (pRow == 0) {
      [self.inputGender setText:nil];
    }
  } else {
    self.interviewResult = [self.interviewCodes objectAtIndex:pRow];
    [self.inputHear setText:[self.interviewOptions objectForKey:self.interviewResult]];
    if (pRow == 0) {
      [self.inputHear setText:nil];
    }
  }
}

- (void)didChangeBirthday:(UIDatePicker *)pPicker {
  self.dateOfBirth = [pPicker date];
  [self.inputDOB setText:[[self dateFormatter] stringFromDate:self.dateOfBirth]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  if (pTextField == self.inputPassword) {
    return finalLength <= 35;
  } else if (pTextField == self.inputZipCode) {
    return finalLength <= 10;
  } else {
    return finalLength <= 40;
  }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)pTextField {
  if (pTextField == self.inputHear) {
    CGRect rect = pTextField.leftView.frame;
    rect.size.width = 120;
    [pTextField.leftView setFrame:rect];
  }
  if ([pTextField inputView]) {
    [self endEditing:YES];
    if ([[self delegate] respondsToSelector:@selector(presentInputView:forTextField:)]) {
      [[self delegate] presentInputView:[pTextField inputView] forTextField:pTextField];
    }
    return NO;
  } else if ([[self delegate] respondsToSelector:@selector(dismissInputView)]) {
    [[self delegate] dismissInputView];
  }
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)pTextField {
  self.currentInput = pTextField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [self didTouchSignUpButton:nil];
  return YES;
}

#pragma mark - ATGExpandableTableViewCell

- (CGFloat)expandedHeight {
  // Make enough room to hold the whole table.
  CGRect tableFrame = [self.tableSignUpOptions frame];

  [self.delegate resizePopover:tableFrame.size.height];

  // Add one extra pixel to display the border.
  return tableFrame.origin.y + tableFrame.size.height + 1;
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL)hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != self.inputEmail;
}

- (BOOL)hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != self.inputHear;
}

- (void)activatePreviousInputForTextField:(UITextField *)pTextField {
  UITextField *previousField = nil;
  if (pTextField == self.inputPassword) {
    previousField = self.inputEmail;
  } else if (pTextField == self.inputConfirmPassword) {
    previousField = self.inputPassword;
  } else if (pTextField == self.inputFirstName) {
    previousField = self.inputConfirmPassword;
  } else if (pTextField == self.inputLastName) {
    previousField = self.inputFirstName;
  } else if (pTextField == self.inputZipCode) {
    previousField = self.inputLastName;
  } else if (pTextField == self.inputGender) {
    previousField = self.inputZipCode;
  } else if (pTextField == self.inputDOB) {
    previousField = self.inputGender;
  } else {
    previousField = self.inputDOB;
  }

  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }

  UITableView *parent = (UITableView *)view;
  [parent scrollRectToVisible:[parent convertRect:[previousField bounds]
                                         fromView:previousField]
                     animated:YES];
  [previousField becomeFirstResponder];
}

- (void)activateNextInputForTextField:(UITextField *)pTextField {
  UITextField *nextField = nil;
  if (pTextField == self.inputEmail) {
    nextField = self.inputPassword;
  } else if (pTextField == self.inputPassword) {
    nextField = self.inputConfirmPassword;
  } else if (pTextField == self.inputConfirmPassword) {
    nextField = self.inputFirstName;
  } else if (pTextField == self.inputFirstName) {
    nextField = self.inputLastName;
  } else if (pTextField == self.inputLastName) {
    nextField = self.inputZipCode;
  } else if (pTextField == self.inputZipCode) {
    nextField = self.inputGender;
  } else if (pTextField == self.inputGender) {
    nextField = self.inputDOB;
  } else {
    nextField = self.inputHear;
  }

  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }

  UITableView *parent = (UITableView *)view;
  [parent scrollRectToVisible:[parent convertRect:[nextField bounds]
                                         fromView:nextField]
                     animated:YES];
  [nextField becomeFirstResponder];
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement {
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger)accessibilityElementCount {
  if ([self isSelected]) {
    return 2;
  } else {
    return 1;
  }
}

- (NSInteger)indexOfAccessibilityElement:(id)pElement {
  if ([pElement isKindOfClass:[UIAccessibilityElement class]]) {
    return 0;
  } else if (pElement == self.tableSignUpOptions && [self isSelected]) {
    return 1;
  }
  return NSNotFound;
}

- (id)accessibilityElementAtIndex:(NSInteger)pIndex {
  UIAccessibilityElement *accessibility;
  switch (pIndex) {
    case 0: {
      accessibility = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
      NSString *label = [labelCellCaption text];
      label = [label stringByAppendingFormat:@". %@.", NSLocalizedStringWithDefaultValue
               (@"ATGSignupTableViewCell_iPad.Accessibility.Trait.MenuItem",
                nil, [NSBundle mainBundle], @"Menu item",
                @"Accessibility trait to be read by VoiceOver for the SignUp cell.")];
      [accessibility setAccessibilityLabel:label];
      NSString *hint = nil;
      if ([self isSelected]) {
        hint = NSLocalizedStringWithDefaultValue
            (@"ATGSignupTableViewCell.AccessibilityHintSelected", nil, [NSBundle mainBundle],
             @"Double tap to minimize.", @"Accessibility hint to be used if cell is selected.");
      } else {
        hint = NSLocalizedStringWithDefaultValue
          (@"ATGSignupTableViewCell.AccessibilityHintDeselected", nil, [NSBundle mainBundle],
           @"Double tap to unfold.", @"Accessibility hint to be used if cell is not selected.");
      }
      [accessibility setAccessibilityHint:hint];
      CGRect frame = [self bounds];
      frame.size.height = [self.tableSignUpOptions frame].origin.y;
      frame = [self convertRect:frame toView:nil];
      [accessibility setAccessibilityFrame:frame];
      return accessibility;
    }
    break;
    case 1: {
      return [self isSelected] ? self.tableSignUpOptions : nil;
    }
    break;
    default: {
      return nil;
    }
  }
}

#pragma mark - Private Protocol Implementation

- (void)didTouchSignUpButton:(id)pSender {
  if ([self.inputEmail validate] & [self.inputPassword validate] & [self.inputConfirmPassword validate] &
      [self.inputFirstName validate] &[self.inputLastName validate]) {
    // Validate all input fields and notify the delegate.
    
    NSMutableDictionary *additionalInfo = [[NSMutableDictionary alloc] init];
    [additionalInfo setValue:[inputConfirmPassword text] forKey:@"confirmPassword"];
    [additionalInfo setValue:[inputZipCode text] forKey:@"postalCode"];
    [additionalInfo setValue:[inputGender text] forKey:@"gender"];
    [additionalInfo setValue:[inputDOB text] forKey:@"dateOfBirth"];
    [additionalInfo setValue:self.interviewResult forKey:@"referralSource"];
    
    [self.delegate signUpWithEmail:[self.inputEmail text] password:[self.inputPassword text]
                         firstName:[self.inputFirstName text] lastName:[self.inputLastName text]
                    additionalInfo:additionalInfo];
  } else {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  }
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{

  // Iterate through parents to avoid iOS version checks
  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }
  
  UITableView *parent = (UITableView *)view;
  [parent scrollRectToVisible:[parent convertRect:[self.currentInput bounds]
                                         fromView:self.currentInput]
                     animated:YES];
}

@end
