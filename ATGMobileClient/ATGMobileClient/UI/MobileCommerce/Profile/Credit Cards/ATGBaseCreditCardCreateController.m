/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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


#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGCreditCard.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import "ATGDataFormatters.h"
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import "ATGCCValidator.h"
#import <ATGUIElements/ATGValidatableDropdown.h>
#import <ATGUIElements/ATGDatePicker.h>
#import "ATGResizingNavigationController.h"
#import "ATGCardTypeViewController.h"
#import "ATGBaseCreditCardCreateController.h"

@interface ATGBaseCreditCardCreateController ()<ATGCardTypeViewControllerDelegate, ATGDatePickerDelegate, UITextFieldDelegate, ATGKeyboardToolbarDelegate, UIPickerViewDelegate,
  UIPickerViewDataSource>
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *cardTypeCell;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) ATGButtonTableViewCell * doneCell;
@property (nonatomic, readwrite, strong) ATGDatePicker *expirationPicker;
@property (nonatomic, readwrite, strong) NSDate *expirationDate;
@property (nonatomic, readwrite, strong) ATGCCValidator *cardValidator;
@property (nonatomic, readwrite, strong) NSArray *cardTypes;

@end

@implementation ATGBaseCreditCardCreateController {
}

static NSUInteger const ATGCCNumberInputLimit = 19;
static NSUInteger const ATGCCDefaultInputLimit = 40;

- (void) dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

- (void) awakeFromNib {
  [super awakeFromNib];
  [self setCreditCard:[[ATGCreditCard alloc] init]];
  [self setExpirationDate:[[NSDate alloc] init]];
}

- (void) viewDidLoad {
  [super viewDidLoad];

  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];

  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGCreditCardCreateController.ControllerTitle.Create", nil, [NSBundle mainBundle],
  @"New Credit Card", @"Title to be displayed on the top of the 'New Card' screen.");
  [self setTitle:title];

  ATGDatePicker *picker = [[ATGDatePicker alloc] initWithFrame:CGRectZero];
  [picker setMDelegate:self];
  [picker setShowsSelectionIndicator:YES];
  [self setExpirationPicker:picker];

  [self setCardValidator:[[ATGCCValidator alloc] init]];
  [[self cardNumberInput] addValidator:[self cardValidator]];

  [[self nicknameInput] setText:[[self creditCard] nickname]];
  [[self cardNumberInput] setText:[[self creditCard] creditCardNumber]];
  [[self expirationDateInput] setText:[[ATGDataFormatters cardExpirationDateFormatter]
    stringFromDate:[self expirationDate]]];

  if (![self isPad]) {
    ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:self];
    [[self nicknameInput] setInputAccessoryView:toolbar];
    [[self cardNumberInput] setInputAccessoryView:toolbar];
    [[self cardTypeInput] setInputAccessoryView:toolbar];
    [[self expirationDateInput] setInputAccessoryView:toolbar];

    NSString *placeholder = NSLocalizedStringWithDefaultValue
                              (@"ATGProfileCreditCardCreateController.iPhone.PlaceholderNickname",
    nil, [NSBundle mainBundle], @"Nickname this card",
    @"Placeholder for the new card nickname on iPhone.");
    [[self nicknameInput] setPlaceholder:placeholder];
    placeholder = NSLocalizedStringWithDefaultValue
                    (@"ATGProfileCreditCardCreateController.iPhone.PlaceholderType",
    nil, [NSBundle mainBundle], @"Type",
    @"Placeholder for the new card type on iPhone.");
    [[self cardTypeInput] setPlaceholder:placeholder];
    placeholder = NSLocalizedStringWithDefaultValue
                    (@"ATGProfileCreditCardCreateController.iPhone.PlaceholderCardNumber",
    nil, [NSBundle mainBundle], @"Card Number",
    @"Placeholder for the new card number on iPhone.");
    [[self cardNumberInput] setPlaceholder:placeholder];

    self.doneCell = [[ATGButtonTableViewCell alloc] initWithReuseIdentifier:@"DoneButton"];
    NSString *title = NSLocalizedStringWithDefaultValue
    (@"ATGCreditCardCreateController.SaveButtonTitle", nil, [NSBundle mainBundle],
    @"Continue", @"Title to be used by the continue button.");
    [[self.doneCell button] setTitle:title forState:UIControlStateNormal];
    [[self.doneCell button] addTarget:self action:@selector(didTouchContinueButton:) forControlEvents:UIControlEventTouchUpInside];

    UIPickerView *typePicker = [[UIPickerView alloc] init];
    [typePicker setDelegate:self];
    [typePicker setDataSource:self];
    [typePicker setShowsSelectionIndicator:YES];
    [[self cardTypeInput] setInputView:typePicker];
    [self setCardTypes:[ATGCreditCard creditCardTypeDisplayNames]];
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGCreditCardCreateController.CardNumber", nil, [NSBundle mainBundle], @"Card Number",
    @"Placeholder for the credit card number input field.");
    [[self cardNumberLabel] setText:title];
    title = NSLocalizedStringWithDefaultValue
              (@"ATGProfileCreditCardCreateController.PlaceholderNickname", nil, [NSBundle mainBundle],
    @"Nickname", @"Placeholder for the new card nickname input field.");
    [[self nicknameLabel] setText:title];
    title = NSLocalizedStringWithDefaultValue
              (@"ATGCreditCardCreateController.SaveButtonAccessoryButton", nil, [NSBundle mainBundle],
    @"Continue", @"Title of the button which saves new credit card data.");
    [[self continueItem] setTitle:title];

    NSString *label = NSLocalizedStringWithDefaultValue
        (@"ATGProfileCreditCardCreateController.Type", nil, [NSBundle mainBundle],
    @"Type", @"Label for the credit card type selection row.");
    [[self cardTypeLabel] setText:label];
  }
  [[self cardTypeInput] setText:nil];
  title = NSLocalizedStringWithDefaultValue
            (@"ATGCreditCardCreateController.ExpiresText", nil, [NSBundle mainBundle], @"Expires",
  @"Placeholder for the credit card expiration date input field.");
  [[self expirationDateLabel] setText:title];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [super viewWillDisappear:pAnimated];
  if ([self isPad]) {
    [[self navigationController] setToolbarHidden:YES animated:pAnimated];
  }
}

- (void) viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  if ([self isPad]) {
    // On iPad we're going to display a 'Continue' button within a toolbar, so make sure it's displayed.
    [[self navigationController] setToolbarHidden:NO];
  }
}

- (CGSize) contentSizeForViewInPopover {
  NSInteger numberOfRows = [[self tableView] numberOfRowsInSection:0];
  CGFloat footerHeight = 0;
  UIView *footerView = [[self tableView] tableFooterView];
  if (footerView) {
    footerHeight = [footerView bounds].size.height;
  }
  CGFloat rowsHeight = 0;
  for (NSInteger row = 0; row < numberOfRows; row++) {
    rowsHeight += [self tableView:[self tableView]
          heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  }
  return CGSizeMake(320, rowsHeight + footerHeight);
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueIdCreditCardCreateToCreditCardTypes isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGCardTypeViewController *typeController = [pSegue destinationViewController];
    [typeController setDelegate:self];
    [typeController setCardType:[self.creditCard creditCardTypeDisplayName]];
  }
}

- (void) didSelectCardType:(NSString *)pType {
  [self.creditCard setCreditCardTypeFromDisplayName:pType];
  [[self cardValidator] setCardType:pType];
  [[self cardTypeInput] setText:pType];
  [[self cardTypeInput] validate];
}


- (void) didTouchContinueButton:(id)pSender {
  [[self view] endEditing:YES];
  BOOL correct= [self validate];
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];
  if ([self isPad] && self.isPresentedInPopover) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
  if (!correct) {
    return;
  } else {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy"];
    [[self creditCard] setExpirationYear:[outputFormatter stringFromDate:[self expirationDate]]];
    [outputFormatter setDateFormat:@"MM"];
    [[self creditCard] setExpirationMonth:[outputFormatter stringFromDate:[self expirationDate]]];
    [self.creditCard setCreditCardType:self.cardValidator.cardType];
    [[self request] setDelegate:nil];
    [[self request] cancelRequest];
    [self startActivityIndication:YES];
    [self didSubmitContinue];
  }
}

- (BOOL)validate {
  BOOL correct = [[self nicknameInput] validate];
  correct = [[self cardNumberInput] validate] && correct;
  correct = [[self cardTypeInput] validate] && correct;
  return correct;
}

- (void) didSubmitContinue {
  [NSException raise:NSInternalInconsistencyException
              format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void) didValidateNewCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self performSegueWithIdentifier:ATGSegueIdCreditCardCreateToBillingAddresses sender:self];
}

- (void) didErrorValidatingNewCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequestResults error] inSection:0];
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}


#pragma mark - UITableViewDatasource delegate methods
- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    return [super tableView:pTableView numberOfRowsInSection:pSection] +
      [self errorNumberOfRowsInSection:pSection];
  }
  return 1;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }

  if (pIndexPath.section == 1) {
    return self.doneCell;
  }

  pIndexPath = [self shiftIndexPath:pIndexPath];

  return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  } else {
    CGFloat defaultHeight = [super tableView:pTableView
                     heightForRowAtIndexPath:[self shiftIndexPath:pIndexPath]];
    UITableViewCell *cell = [self tableView:pTableView cellForRowAtIndexPath:pIndexPath];
    NSUInteger index = [[[cell contentView] subviews]
      indexOfObjectPassingTest:^BOOL(id pObject, NSUInteger pIndex, BOOL *pStop) {
        if ([pObject isKindOfClass:[ATGValidatableInput class]]) {
          *pStop = YES;
          return YES;
        }
        return NO;
      }];
    if (index == NSNotFound) {
      return defaultHeight;
    } else {
      ATGValidatableInput *input = [[[cell contentView] subviews] objectAtIndex:index];
      CGSize requredSize = [input sizeThatFits:CGSizeMake([input bounds].size.width, defaultHeight)];
      return requredSize.height;
    }
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
  NSUInteger index = [[[cell contentView] subviews] indexOfObjectPassingTest:
    ^BOOL (id pObject, NSUInteger pIndex, BOOL * pStop)
    {
      if ([pObject isKindOfClass:[UITextField class]]) {
        *pStop = YES;
        return YES;
      }
      return NO;
    }
  ];
  if (index != NSNotFound) {
    [(UITextField *)[[[cell contentView] subviews] objectAtIndex:index] becomeFirstResponder];
  }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldBeginEditing:(UITextField *)pTextField {
  [[self tableView] setTableFooterView:nil];
  if ([self isPad]){
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
  if (pTextField == [self expirationDateInput]) {
    [[self expirationPicker] setDate:[self expirationDate]];
    if ([self isPad]) {
      [[self view] endEditing:YES];
      [[self tableView] setTableFooterView:[self expirationPicker]];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
      return NO;
    } else {
      [pTextField setInputView:[self expirationPicker]];
    }
  } else if (pTextField == [self cardTypeInput] && ![self isPad]) {
    NSInteger index = [[self cardTypes] indexOfObject:[pTextField text]];
    if (index == NSNotFound) {
      [pTextField setText:[[self cardTypes] objectAtIndex:0]];
    } else {
      [(UIPickerView *)[pTextField inputView] selectRow:index inComponent:0 animated:YES];
    }
  } else if (pTextField == [self cardTypeInput] && [self isPad]) {
    [self performSegueWithIdentifier:ATGSegueIdCreditCardCreateToCreditCardTypes sender:self];
    return NO;
  }
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)pTextField {
  if (pTextField == [self nicknameInput]) {
    [[self creditCard] setNickname:[pTextField text]];
    [[self creditCard] setNewNickname:[pTextField text]];
  } else if (pTextField == [self cardNumberInput]) {
    [[self creditCard] setCreditCardNumber:[pTextField text]];
  }
  if ([self isPad]) {
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    if ([self isPresentedInPopover])
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (BOOL) textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange replacementString:(NSString *)pString {
  NSUInteger newLength = [[pTextField text] length] + [pString length] - pRange.length;
  if (pTextField == [self cardNumberInput]) {
    return newLength <= ATGCCNumberInputLimit;
  } else if (pTextField == [self nicknameInput]) {
    return newLength <= CCNicknameMaxLength;
  }
  return NO;
}

#pragma mark - UIPickerViewDatasource methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pPickerView {
  return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pPickerView numberOfRowsInComponent:(NSInteger)pComponent {
  return [[self cardTypes] count];
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *) pickerView:(UIPickerView *)pPickerView titleForRow:(NSInteger)pRow forComponent:(NSInteger)pComponent {
  return [[self cardTypes] objectAtIndex:pRow];
}

- (void) pickerView:(UIPickerView *)pPickerView didSelectRow:(NSInteger)pRow inComponent:(NSInteger)pComponent {
  [self.creditCard setCreditCardTypeFromDisplayName:[self.cardTypes objectAtIndex:pRow]];
  [[self cardValidator] setCardType:[[self cardTypes] objectAtIndex:pRow]];
  [[self cardTypeInput] setText:[[self cardTypes] objectAtIndex:pRow]];
}

#pragma mark - ATGDatePickerDelegate methods

- (void) didSelectDate:(NSDate *)pDate {
  [self setExpirationDate:pDate];
  [[self expirationDateInput] setText:[[ATGDataFormatters cardExpirationDateFormatter]
    stringFromDate:[self expirationDate]]];
}

#pragma mark - ATGKeyboardToolbarDelegate methods

- (BOOL) hasNextInputForTextField:(UITextField *)pTextField {
  return pTextField != [self expirationDateInput];
}

- (BOOL) hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self nicknameInput];
}

- (void) activateNextInputForTextField:(UITextField *)pTextField {
  NSInteger row = 0;
  UITextField *input = nil;
  if (pTextField == [self nicknameInput]) {
    input = [self cardTypeInput];
    row = 1;
  } else if (pTextField == [self cardTypeInput]) {
    input = [self cardNumberInput];
    row = 2;
  } else {
    input = [self expirationDateInput];
    row = 3;
  }
  NSIndexPath *path = [self convertIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  [input becomeFirstResponder];
}

- (void) activatePreviousInputForTextField:(UITextField *)pTextField {
  NSInteger row = 0;
  UITextField *input = nil;
  if (pTextField == [self expirationDateInput]) {
    row = 2;
    input = [self cardNumberInput];
  } else if (pTextField == [self cardNumberInput]) {
    row = 1;
    input = [self cardTypeInput];
  } else {
    row = 0;
    input = [self nicknameInput];
  }
  NSIndexPath *path = [self convertIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  [input becomeFirstResponder];
}

@end