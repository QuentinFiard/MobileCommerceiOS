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

#import "ATGSignupTableViewCell.h"
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>

#pragma mark - ATGSignupTableViewCell Private Protocol
#pragma mark -

@interface ATGSignupTableViewCell () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,
                                      ATGKeyboardToolbarDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UILabel *cellCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UITableView *signUpOptionsTable;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *accessoryImage;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGValidatableInput *emailInput;
@property (nonatomic, readwrite, strong) ATGValidatableInput *passwordInput;
@property (nonatomic, readwrite, strong) ATGValidatableInput *passwordConfirmInput;
@property (nonatomic, readwrite, strong) ATGValidatableInput *firstNameInput;
@property (nonatomic, readwrite, strong) ATGValidatableInput *lastNameInput;
@property (nonatomic, readwrite, strong) UITableViewCell *observingCell;
@property (nonatomic, readwrite, strong) ATGKeyboardToolbar *toolbar;
@property (nonatomic, readwrite, strong) NSString *error;

#pragma mark - Private Protocol Definition

- (void) didTouchSignUpButton:(id)sender;

@end

#pragma mark - ATGSignupTableViewCell Implementation
#pragma mark -

@implementation ATGSignupTableViewCell

#pragma mark - Synthesized Properties

@synthesize delegate, email;
@synthesize cellCaptionLabel;
@synthesize signUpOptionsTable;
@synthesize accessoryImage;
@synthesize emailInput;
@synthesize passwordInput;
@synthesize passwordConfirmInput;
@synthesize firstNameInput;
@synthesize lastNameInput;
@synthesize observingCell;
@synthesize toolbar;
@synthesize error;

#pragma mark - Custom Properties Accessor Methods

- (void) setCaption:(NSString *)pCaption {
  [[self cellCaptionLabel] setText:pCaption];
}

- (NSString *) caption {
  return [[self cellCaptionLabel] text];
}

- (void) setEmail:(NSString *)pEmail {
  if (pEmail != self->email) {
    self->email = [pEmail copy];
    [[self emailInput] setValue:[self email]];
  }
}

- (void) setError:(NSString *)pError {
  if (!pError) return;
  BOOL hasError = [self error] != nil;
  if (pError != self->error) {
    self->error = [pError copy];
  }
  CGFloat prevErrorHeight = 0;
  if (hasError) {
    prevErrorHeight = [self          tableView:[self signUpOptionsTable]
                       heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  }
  if (hasError) {
    [[self signUpOptionsTable]
     reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                        inSection:0]]
           withRowAnimation:UITableViewRowAnimationRight];
  } else {
    [[self signUpOptionsTable]
     insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                        inSection:0]]
           withRowAnimation:UITableViewRowAnimationTop];
  }
  if (pError) {
    CGRect frame = [[self signUpOptionsTable] frame];
    frame.size.height += [self          tableView:[self signUpOptionsTable]
                          heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    frame.size.height -= prevErrorHeight;
    [[self signUpOptionsTable] setFrame:frame];
    [self emailInput].layer.mask = nil;
  }
}

#pragma mark - Public Protocol Implementation

+ (ATGSignupTableViewCell *) newInstance {
  // Load new instance from a NIB file.
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ATGSignupTableViewCell"
                                                   owner:nil options:nil];
  for (id object in objects) {
    // Return object of a proper class only.
    if ([object isKindOfClass:[ATGSignupTableViewCell class]]) {
      return object;
    }
  }
  return nil;
}

#pragma mark - NSObject

- (void) dealloc {
  [[self observingCell] removeObserver:self forKeyPath:@"frame"];
}

- (void) awakeFromNib {
  [super awakeFromNib];
  [self setToolbar:[[ATGKeyboardToolbar alloc] initWithDelegate:self]];

  NSString *caption = NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.CellCaption", nil, [NSBundle mainBundle],
                        @"Sign Up", @"Caption to be displayed on the SignUp cell.");
  [[self cellCaptionLabel] setText:caption];
  [[self cellCaptionLabel] applyStyleWithName:@"formTitleLabel"];
  [[self signUpOptionsTable] setBackgroundColor:[UIColor subTableBackgroundColor]];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];

  CGAffineTransform transform;
  if ([self isSelected]) {
    // The cell is selected, rotate the accessory arrow.
    transform = CGAffineTransformMakeRotation(-M_PI);
  } else {
    transform = CGAffineTransformIdentity;
  }
  [[self accessoryImage] setTransform:transform];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // One section will hold sign up options while the other will hold a button.
  return 2;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // 5 sign up options
    return 5 + ([self error] != nil ? 1 : 0);
  } else {
    // And one button.
    return 1;
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
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
    [label setText:[self error]];
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

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([self error] && [pIndexPath section] == 0 && [pIndexPath row] == 0) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label applyStyleWithName:@"formTextLabel"];
    CGSize maxSize = CGSizeMake([pTableView bounds].size.width - 48, 1000);
    CGSize size = [[self error] sizeWithFont:[label font] constrainedToSize:maxSize
                               lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height + 24 > [pTableView rowHeight]) {
      return size.height + 24;
    } else {
      return [pTableView rowHeight];
    }
  } else {
    return [[self signUpOptionsTable] rowHeight];
  }
}

- (void)  tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
  forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    if ([pIndexPath row] == 0 && [self error] != nil) {
      return;
    } else if ([self error]) {
      pIndexPath = [NSIndexPath indexPathForRow:[pIndexPath row] - 1 inSection:0];
    }
    // Sign up options.
    if ([pIndexPath row] < 5) {
      // All options should contain a validatable input field.
      CGRect cellBounds = [[pCell contentView] bounds];
      cellBounds.size.width -= 2;
      cellBounds.size.height = [pTableView rowHeight] - 1;
      ATGValidatableInput *input = [[ATGValidatableInput alloc] initWithFrame:cellBounds];
      [[pCell contentView] addSubview:input];
      [input setTag:15];
      NSString *placeholder = nil;
      // Choose placeholder based on field position.
      // Also save input view created into proper instance variable.
      switch ([pIndexPath row]) {
      case 0: {
        placeholder = NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.EmailInputPlaceholder", nil,
                        [NSBundle mainBundle], @"Email",
                        @"Placeholder to be used by the Email text field.");
        [self setEmailInput:input];
        [[self emailInput] setKeyboardType:UIKeyboardTypeEmailAddress];
        // Add email validator to the input.
        ATGEmailValidator *validator = [[ATGEmailValidator alloc] init];
        [[self emailInput] addValidator:validator];
        [[self emailInput] setValue:[self email]];
      }
      break;

      case 1: {
        placeholder = NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.PasswordInputPlaceholder", nil,
                        [NSBundle mainBundle], @"Password",
                        @"Placeholder to be used by the Password text field.");
        // Password input should be secured.
        [input setSecureTextEntry:YES];
        [self setPasswordInput:input];
        [[self passwordInput] setClearsOnBeginEditing:YES];
      }
      break;

      case 2: {
        placeholder =  NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.PasswordConfirmInputPlaceholder", nil,
                        [NSBundle mainBundle], @"Confirm Password",
                        @"Placeholder to be used by the Confirm Password text field.");
        // Password input should be secured.
        [input setSecureTextEntry:YES];
        [self setPasswordConfirmInput:input];
        [[self passwordConfirmInput] setClearsOnBeginEditing:YES];
      }
      break;

      case 3: {
        placeholder = NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.FirstNameInputPlaceholder", nil,
                        [NSBundle mainBundle], @"First Name",
                        @"Placeholder to be used by the FirstName text field.");
        [self setFirstNameInput:input];
      }
      break;

      default: {
        placeholder = NSLocalizedStringWithDefaultValue
                        (@"ATGSignupTableViewCell.LastNameInputPlaceholder", nil,
                        [NSBundle mainBundle], @"Last Name",
                        @"Placeholder to be used by the LastName text field.");
        [self setLastNameInput:input];
        [self lastNameInput].layer.mask = [pCell createMaskForIndexPath:pIndexPath inTableView:pTableView];
      }
      break;
      }
      [input setPlaceholder:placeholder];
      [input setDelegate:self];
      [input applyStyle:ATGTextFieldFormText];
      [input setAccessibilityLabel:[(UITextField *)[input inputView] placeholder]];
      if ([pIndexPath row] < 2) {
        [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [input setAutocorrectionType:UITextAutocorrectionTypeNo];
      }
      [input setReturnKeyType:UIReturnKeyGo];

      [input setInputAccessoryView:[self toolbar]];
    }
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)  textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
  replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  if ( (pTextField == [self passwordInput]) || (pTextField == [self passwordConfirmInput]) ) {
    return finalLength <= 35;
  } else {
    return finalLength <= 40;
  }
}

- (BOOL) textFieldShouldReturn:(UITextField *)pTextField {
  [self didTouchSignUpButton:nil];
  return YES;
}

#pragma mark - ATGExpandedTableViewCell

- (CGFloat) expandedHeight {
  // Make enough room to hold the whole table.
  CGRect tableFrame = [[self signUpOptionsTable] frame];
  // Add one extra pixel to display the border.
  return tableFrame.origin.y + tableFrame.size.height + 1;
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL) hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self emailInput];
}

- (BOOL) hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != [self lastNameInput];
}

- (void) activatePreviousInputForTextField:(UITextField *)pTextField {
  UITextField *previousField = nil;
  if (pTextField == [self passwordInput]) {
    previousField = [self emailInput];
  } else if (pTextField == passwordConfirmInput) {
    previousField = [self passwordInput];
  } else if (pTextField == [self firstNameInput])  {
    previousField = [self passwordConfirmInput];
  } else {
    previousField = [self firstNameInput];
  }

  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
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

- (void) activateNextInputForTextField:(UITextField *)pTextField {
  UITextField *nextField = nil;
  if (pTextField == [self emailInput]) {
    nextField = [self passwordInput];
  } else if (pTextField == [self passwordInput]) {
    nextField = [self passwordConfirmInput];
  } else if (pTextField == [self passwordConfirmInput]) {
    nextField = [self firstNameInput];
  } else {
    nextField = [self lastNameInput];
  }

  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
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

- (BOOL) isAccessibilityElement {
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger) accessibilityElementCount {
  if ([self isSelected]) {
    return 2;
  } else {
    return 1;
  }
}

- (NSInteger) indexOfAccessibilityElement:(id)pElement {
  if ([pElement isKindOfClass:[UIAccessibilityElement class]]) {
    return 0;
  } else if (pElement == [self signUpOptionsTable] && [self isSelected]) {
    return 1;
  }
  return NSNotFound;
}

- (id) accessibilityElementAtIndex:(NSInteger)pIndex {
  UIAccessibilityElement *accessibility;
  switch (pIndex) {
  case 0: {
    accessibility = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    NSString *label = [[self cellCaptionLabel] text];
    label = [label stringByAppendingFormat:@". %@.", NSLocalizedStringWithDefaultValue
               (@"ATGSignupTableViewCell.Accessibility.Trait.MenuItem",
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
    frame.size.height = [[self signUpOptionsTable] frame].origin.y;
    frame = [self convertRect:frame toView:nil];
    [accessibility setAccessibilityFrame:frame];
    return accessibility;
  }
  break;

  case 1: {
    return [self isSelected] ? [self signUpOptionsTable] : nil;
  }
  break;

  default: {
    return nil;
  }
  }
}

#pragma mark - Private Protocol Implementation

- (void) didTouchSignUpButton:(id)pSender {
  if ([[self emailInput] validate] &[[self passwordInput] validate] &
      [[self firstNameInput] validate] &[[self lastNameInput] validate] &[[self passwordConfirmInput] validate]) {
    // Validate all input fields and notify the delegate.
    NSMutableDictionary *additionalInfo = [[NSMutableDictionary alloc] init];
    [additionalInfo setValue:[[self passwordConfirmInput] text] forKey:@"confirmPassword"];

    [[self delegate] signUpWithEmail:[[self emailInput] text] password:[[self passwordInput] text]
                           firstName:[[self firstNameInput] text] lastName:[[self lastNameInput] text] additionalInfo:additionalInfo];
  } else {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  }
}

@end