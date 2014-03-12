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

#import "ATGLoginTableViewCell.h"
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGButton.h>
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>

static NSString *const ATGForgotPasswordAccessoryImageName = @"icon-forgot.png";

#pragma mark - ATGLoginTableViewCell Private Protocol
#pragma mark -

@interface ATGLoginTableViewCell () <ATGKeyboardToolbarDelegate, UITableViewDelegate,
    UITableViewDataSource, UITextFieldDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UILabel *captionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UITableView *loginOptionsTable;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *firstNameLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGValidatableInput *emailInput;
@property (nonatomic, readwrite, strong) ATGValidatableInput *passwordInput;
@property (nonatomic, readwrite, strong) UILabel *emailCaptionLabel;
@property (nonatomic, readwrite, strong) UILabel *passwordCaptionLabel;
@property (nonatomic, readwrite, strong) ATGKeyboardToolbar *toolbar;

#pragma mark - Private Protocol Definition

- (void)updateEmailCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
                  table:(UITableView *)table;
- (void)updatePasswordCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
                     table:(UITableView *)table;
- (void)updateForgotPasswordCell:(UITableViewCell *)cell;
- (void)didTouchLoginButton:(id)sender;

@end

#pragma mark - ATGLoginTableViewCell Implementation
#pragma mark -

@implementation ATGLoginTableViewCell

#pragma mark - Synthesized Properties

@synthesize delegate;
@synthesize error;
@synthesize displayForgotPassword;
@synthesize name, email, password;
@synthesize displayCopyError, emailCaptionLabel, passwordCaptionLabel;
@synthesize captionLabel;
@synthesize loginOptionsTable;
@synthesize firstNameLabel;
@synthesize emailInput;
@synthesize passwordInput;
@synthesize toolbar;

#pragma mark - Custom Properties Accessor Methods

- (void)setError:(NSString *)pError {
  // Add new cells to the internal table only if there was not error displayed before.
  BOOL updateTable = [self error] == nil;
  BOOL dirty = pError != self->error;
  
  if (dirty) {
    self->error = [pError copy];
  }
  
  if (updateTable) {
    // No error has been displayed before, update the table.
    [[self loginOptionsTable] beginUpdates];
    
    // Magic numbers, where should we insert two more cells?
    NSArray *indices = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
    [[self loginOptionsTable] insertRowsAtIndexPaths:indices
                                    withRowAnimation:UITableViewRowAnimationFade];
    
    // Make enough space for the new row inserted.
    CGRect tableFrame = [[self loginOptionsTable] frame];
    tableFrame.size.height += [[self loginOptionsTable] rowHeight];
    [[self loginOptionsTable] setFrame:tableFrame];
    
    [[self loginOptionsTable] endUpdates];
  } else {
    [[[[self loginOptionsTable]
       cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                inSection:0]] textLabel] setText:[self error]];
  }
  
  if (dirty) {
    [[self loginOptionsTable] reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1
                                                                                                  inSection:0],
                                                      [NSIndexPath indexPathForRow:2 inSection:0], nil]
                                    withRowAnimation:UITableViewRowAnimationNone];
  }
}

- (void)setDisplayForgotPassword:(BOOL)pDisplay {
  if (pDisplay == [self displayForgotPassword]) {
    return;
  }
  self->displayForgotPassword = pDisplay;
  [[self loginOptionsTable] beginUpdates];
  NSIndexPath *forgotPasswordPath = [NSIndexPath indexPathForRow:[self error] == nil ? 2 : 3
                                                       inSection:0];
  NSArray *indices = [NSArray arrayWithObject:forgotPasswordPath];
  CGRect tableFrame = [[self loginOptionsTable] frame];
  if (pDisplay) {
    [[self loginOptionsTable] insertRowsAtIndexPaths:indices
                                    withRowAnimation:UITableViewRowAnimationFade];
    tableFrame.size.height += [[self loginOptionsTable] rowHeight];
  } else {
    [[self loginOptionsTable] deleteRowsAtIndexPaths:indices
                                    withRowAnimation:UITableViewRowAnimationFade];
    tableFrame.size.height -= [[self loginOptionsTable] rowHeight];
  }
  [[self loginOptionsTable] setFrame:tableFrame];
  [[self loginOptionsTable] endUpdates];
}

- (void)setDisplayCopyError:(BOOL)pDisplayCopyError {
  if (pDisplayCopyError) {
    NSString *message = NSLocalizedStringWithDefaultValue
        (@"ATGLoginTableViewCell.CopyPassErrorMessage", nil, [NSBundle mainBundle],
         @"Paste password from email", @"Error message to be displayed when password sent");
    [[self passwordInput] invalidate:message];
    [[self passwordInput] setNeedsLayout];
  }
}

#pragma mark - Public Protocol Implementation

+ (ATGLoginTableViewCell *)newInstance {
  // Load an instance from the NIB file.
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ATGLoginTableViewCell"
                                                   owner:nil options:nil];
  for (id object in objects) {
    // Search for a proper object.
    if ([object isKindOfClass:[ATGLoginTableViewCell class]]) {
      return object;
    }
  }
  return nil;
}

- (void)clearFormFields {
  [[self passwordInput] setText:nil];
  [[self passwordInput] invalidate:nil];
}

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  
  [self setToolbar:[[ATGKeyboardToolbar alloc] initWithDelegate:self]];

  [[self loginOptionsTable] setBackgroundColor:[UIColor subTableBackgroundColor]];

  // Setup localized contend on the screen.
  NSString *caption = NSLocalizedStringWithDefaultValue
      (@"ATGLoginTableViewCell.CellMainTitle", nil, [NSBundle mainBundle], @"Login",
       @"Title to be displayed at the top of the cell.");
  [[self captionLabel] setText:caption];
  [[self captionLabel] applyStyleWithName:@"formTitleLabel"];

  [self setDisplayForgotPassword:NO];

  [self setAccessibilityTraits:UIAccessibilityTraitStaticText | UIAccessibilityTraitButton];
}

#pragma mark - UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  // User properties to be displayed.
  [[self firstNameLabel] setText:[self name]];
  [[self firstNameLabel] applyStyleWithName:@"formFieldLabel"];
  CGPoint accessoryCenter = [[self accessoryView] center];
  CGPoint titleCenter = [[self captionLabel] center];
  accessoryCenter.y = titleCenter.y;
  [[self accessoryView] setCenter:accessoryCenter];

  CGAffineTransform transform;
  if ([self isSelected]) {
    // The cell is selected, rotate the accessory arrow.
    transform = CGAffineTransformMakeRotation(-M_PI);
  } else {
    transform = CGAffineTransformIdentity;
  }
  [[self accessoryView] setTransform:transform];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  // One section for input options, and another section for Done button.
  return 2;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // Login options section, it should have 2 options.
    NSInteger result = 2;
    // If there is an error to be displayed, we need one more cell.
    if ([self error] != nil) {
      result += 1;
    }
    // If there is a 'Forgot password' message to be displayed, one more cell.
    if ([self displayForgotPassword]) {
      result += 1;
    }
    return result;
  } else {
    // One cell for the button.
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    // Default cells for all rows.
    UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    return cell;
  } else {
    ATGButtonTableViewCell *cell =
      [[ATGButtonTableViewCell alloc] initWithReuseIdentifier:nil showUnderlay:NO];
    // Use localized strings only.
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGLoginTableViewCell.LoginButtonTitle", nil, [NSBundle mainBundle],
         @"Login", @"Title to be displayed on the login button.");
    [[cell button] setTitle:title forState:UIControlStateNormal];
    NSString *label = NSLocalizedStringWithDefaultValue
        (@"ATGLoginTableViewCell.LoginButtonAccessibilityLabel", nil,
         [NSBundle mainBundle], @"Login",
         @"Accessibility label to be used by the login button.");
    [[cell button] setAccessibilityLabel:label];
    NSString *hint = NSLocalizedStringWithDefaultValue
        (@"ATGLoginTableViewCell.LoginButtonAccessibilityHint", nil,
         [NSBundle mainBundle], @"Logs you in.",
         @"Accessibility hint to be used by the login button.");
    [[cell button] setAccessibilityHint:hint];
    [[cell button] addTarget:self action:@selector(didTouchLoginButton:)
            forControlEvents:UIControlEventTouchUpInside];
    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Dont set background color of button cell b/c we want the background to stay transparent here
  if (![pCell isKindOfClass:[ATGButtonTableViewCell class]]){
  [pCell setBackgroundColor:[UIColor tableCellBackgroundColor]];
  }
  if ([pIndexPath section] == 0) {
    // Login options section.
    switch ([pIndexPath row]) {
      case 0 :
        if ([self error] == nil) {
          // No error => it's an email cell.
          [self updateEmailCell:pCell indexPath:pIndexPath table:pTableView];
        } else {
          // There is an error => it's an error cell.
          [[pCell textLabel] setText:[self error]];
          [[pCell textLabel] applyStyleWithName:@"loginLabel"];

          // Add highlighted background to the cell.
          [pCell setBackgroundColor:[UIColor errorColor]];
        }
        break;
      case 1:
        if ([self error] == nil) {
          // No error => it's password cell.
          [self updatePasswordCell:pCell indexPath:pIndexPath table:pTableView];
        } else {
          // Error => it's email cell.
          [self updateEmailCell:pCell indexPath:pIndexPath table:pTableView];
        }
        break;

      case 2:
        if ([self error] != nil) {
          // Error => it's password.
          [self updatePasswordCell:pCell indexPath:pIndexPath table:pTableView];
        } else {
          // There is no error, but ForgotPassword should be displayed.
          [self updateForgotPasswordCell:pCell];
        }
        break;
      case 3:
        if ([self error] != nil && [self displayForgotPassword]) {
          [self updateForgotPasswordCell:pCell];
        }
        break;
    }
  }
  [pCell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSIndexPath *forgotPasswordPath = [NSIndexPath indexPathForRow:[self error] == nil ? 2 : 3
                                                       inSection:0];
  if ([forgotPasswordPath isEqual:pIndexPath]) {
    [[self delegate] forgotPasswordForEmail:[[self emailInput] text]];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  if (pTextField == [self emailInput]) {
    return finalLength <= 40;
  } else {
    return finalLength <= 35;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [self didTouchLoginButton:nil];
  return YES;
}

#pragma mark - ATGExpandableTableViewCell

- (CGFloat)expandedHeight {
  // Make enough room to hold the whole table.
  CGRect tableFrame = [[self loginOptionsTable] frame];

  [self.delegate resizePopover:tableFrame.size.height];

  // Add one extra pixel for a border.
  return tableFrame.origin.y + tableFrame.size.height + 1;
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL)hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self emailInput];
}

- (BOOL)hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != [self passwordInput];
}

- (void)activatePreviousInputForTextField:(UITextField *)pTextField {
  UITableView *parent = (UITableView *)[self superview];
  [parent scrollRectToVisible:[parent convertRect:[[self emailInput] bounds]
                                         fromView:[self emailInput]]
                     animated:YES];
  [[self emailInput] becomeFirstResponder];
}

- (void)activateNextInputForTextField:(UITextField *)pTextField {
  UITableView *parent = (UITableView *)[self superview];
  [parent scrollRectToVisible:[parent convertRect:[[self passwordInput] bounds]
                                         fromView:[self passwordInput]]
                     animated:YES];
  [[self passwordInput] becomeFirstResponder];
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
  } else if (pElement == [self loginOptionsTable] && [self isSelected]) {
    return 1;
  }
  return NSNotFound;
}

- (id)accessibilityElementAtIndex:(NSInteger)pIndex {
  UIAccessibilityElement *accessibility;
  switch (pIndex) {
    case 0 : {
        accessibility = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        NSString *label = [[self captionLabel] text];
        if ([[[self firstNameLabel] text] length]) {
          label = [label stringByAppendingFormat:@", %@", [[self firstNameLabel] text]];
        }
        label = [label stringByAppendingFormat:@". %@.", NSLocalizedStringWithDefaultValue
                 (@"ATGLoginTableViewCell.Accessibility.Trait.MenuItem",
                  nil, [NSBundle mainBundle], @"Menu item",
                  @"Accessibility trait to be read by VoiceOver for the Login cell.")];
        [accessibility setAccessibilityLabel:label];
        NSString *hint = nil;
        if ([self isSelected]) {
          hint = NSLocalizedStringWithDefaultValue
              (@"ATGLoginTableViewCell.AccessibilityHintSelected", nil, [NSBundle mainBundle],
               @"Double tap to minimize.", @"Accessibility hint to be used if cell is selected.");
        } else {
          hint = NSLocalizedStringWithDefaultValue
              (@"ATGLoginTableViewCell.AccessibilityHintDeselected", nil, [NSBundle mainBundle],
               @"Double tap to unfold.", @"Accessibility hint to be used if cell is not selected.");
        }
        [accessibility setAccessibilityHint:hint];
        CGRect frame = [self bounds];
        frame.size.height = [[self loginOptionsTable] frame].origin.y;
        frame = [self convertRect:frame toView:nil];
        [accessibility setAccessibilityFrame:frame];
        return accessibility;
    }
    break;
    case 1: {
      return [self isSelected] ? [self loginOptionsTable] : nil;
    }
    break;
    default: {
      return nil;
    }
  }
}

#pragma mark - Private Protocol Implementation

// Create inner contents for the cell with Email input.
- (void)updateEmailCell:(UITableViewCell *)pCell indexPath:(NSIndexPath *)pIndexPath
                  table:(UITableView *)pTable {
  CGSize contentSize = [[pCell contentView] bounds].size;

  // if ipad and iOS 7 or greater, shrink the input to account for table cells spanning the entire screen and some text getting cut off.
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && [self isPad]){
    [self setEmailInput:[[ATGValidatableInput alloc]
                       initWithFrame:CGRectMake(0, 0, contentSize.width - 16,
                                                [[self loginOptionsTable] rowHeight] - 1)]];
  } else{
    [self setEmailInput:[[ATGValidatableInput alloc]
        initWithFrame:CGRectMake(0, 0, contentSize.width - 2,
            [[self loginOptionsTable] rowHeight] - 1)]];
  }
  
  [[pCell contentView] addSubview:[self emailInput]];
  NSString *placeholder = NSLocalizedStringWithDefaultValue
      (@"ATGLoginTableViewCell.EmailTextPlaceholder", nil, [NSBundle mainBundle],
       @"Email", @"Placeholder to be used by the email text field.");
  if ([self isPad]) {
    self.emailCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 80, 21)];
    self.emailCaptionLabel.text = placeholder;
    [self.emailCaptionLabel applyStyleWithName:@"formCaptionLabel"];
    [[self emailInput] setLeftView:self.emailCaptionLabel];
    [[self emailInput] setLeftViewMode:UITextFieldViewModeAlways];
    [[self emailInput] setBorderWidth:2];
    [[self emailInput] setErrorWidthFraction:.25];
    [[self emailInput] applyStyle:ATGTextFieldFormText_iPad];
  } else {
    [[self emailInput] setPlaceholder:placeholder];
    [[self emailInput] applyStyle:ATGTextFieldFormText];
  }
  [[self emailInput] setDelegate:self];
  [[self emailInput] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [[self emailInput] setAutocorrectionType:UITextAutocorrectionTypeNo];
  [[self emailInput] setKeyboardType:UIKeyboardTypeEmailAddress];
  [[self emailInput] setReturnKeyType:UIReturnKeyGo];
  [[self emailInput] setAccessibilityLabel:[[self emailInput] placeholder]];
  [[self emailInput] setText:[self email]];
  ATGEmailValidator *validator = [[ATGEmailValidator alloc] init];
  [[self emailInput] addValidator:validator];
  
  [[self emailInput] setInputAccessoryView:[self toolbar]];
  
  if (![self error]) {
    [self emailInput].layer.mask = [pCell createMaskForIndexPath:pIndexPath inTableView:pTable];
  }
}

// Create inner contents for the cell with Password input.
- (void) updatePasswordCell:(UITableViewCell *)pCell indexPath:(NSIndexPath *)pIndexPath
                      table:(UITableView *)pTable {
  CGSize contentSize = [[pCell contentView] bounds].size;

  // if ipad and iOS 7 or greater, shrink the input to account for table cells spanning the entire screen and some text getting cut off.
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && [self isPad]){
    [self setPasswordInput:[[ATGValidatableInput alloc]
        initWithFrame:CGRectMake(0, 0, contentSize.width - 16,
            [[self loginOptionsTable] rowHeight] - 1)]];
  } else{
    [self setPasswordInput:[[ATGValidatableInput alloc]
        initWithFrame:CGRectMake(0, 0, contentSize.width - 2,
            [[self loginOptionsTable] rowHeight] - 1)]];
  }
  [[pCell contentView] addSubview:[self passwordInput]];
  NSString *placeholder = NSLocalizedStringWithDefaultValue
      (@"ATGLoginTableViewCell.PasswordTextPlaceholder", nil, [NSBundle mainBundle],
       @"Password", @"Placeholder to be used by the password text field.");
  if ([self isPad]) {
    self.passwordCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 80, 21)];
    self.passwordCaptionLabel.text = placeholder;
    [self.passwordCaptionLabel applyStyleWithName:@"formCaptionLabel"];
    [[self passwordInput] setLeftView:self.passwordCaptionLabel];
    [[self passwordInput] setLeftViewMode:UITextFieldViewModeAlways];
    [[self passwordInput] setBorderWidth:2];
    [[self passwordInput] setErrorWidthFraction:.25];
    [[self passwordInput] applyStyle:ATGTextFieldFormText_iPad];
  } else {
    [[self passwordInput] setPlaceholder:placeholder];
    [[self passwordInput] applyStyle:ATGTextFieldFormText];
  }
  [[self passwordInput] setDelegate:self];
  [[self passwordInput] setSecureTextEntry:YES];
  [[self passwordInput] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [[self passwordInput] setAutocorrectionType:UITextAutocorrectionTypeNo];
  [[self passwordInput] setReturnKeyType:UIReturnKeyGo];
  [[self passwordInput] setAccessibilityLabel:[[self passwordInput] placeholder]];
  [[self passwordInput] setText:[self password]];
  [[self passwordInput] setInputAccessoryView:[self toolbar]];
  [[self passwordInput] setClearsOnBeginEditing:YES];
  
  if (![self error]) {
    [self passwordInput].layer.mask = [pCell createMaskForIndexPath:pIndexPath inTableView:pTable];
  }
}

// Create inner contents for the 'Forgot Password?' cell.
- (void)updateForgotPasswordCell:(UITableViewCell *)pCell {
  [[pCell textLabel] applyStyleWithName:@"loginLabel"];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGLoginTableViewCell.ForgotPasswordCellTitle", nil,
       [NSBundle mainBundle], @"Forgot login or password?",
       @"Caption to be displayed on the forgot password cell.");
  [[pCell textLabel] setText:title];
  
  // Add highlighted background to the cell.
  [pCell setBackgroundColor:[UIColor errorColor]];
  
  UIImageView *accessory = [[UIImageView alloc]
                            initWithImage:[UIImage
                                           imageNamed:ATGForgotPasswordAccessoryImageName]];
  [pCell setAccessoryView:accessory];
  
  [pCell setAccessibilityTraits:UIAccessibilityTraitButton | UIAccessibilityTraitStaticText];
  NSString *hint = NSLocalizedStringWithDefaultValue
      (@"ATGLoginTableViewCell.AccessibilityHintForgotPassword", nil, [NSBundle mainBundle],
       @"Resets your password.",
       @"Accessibility hint to be sued by the 'Forgot Password' cell.");
  [pCell setAccessibilityHint:hint];
}

- (void)didTouchLoginButton:(id)pSender {
  // Login the user only if email an password are valid.
  if ([[self passwordInput] validate] &[[self emailInput] validate]) {
    [[self delegate] loginWithEmail:[[self emailInput] text] andPassword:[[self passwordInput] text]];
  } else {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
  }
}


@end
