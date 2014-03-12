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

#import "ATGProfileCreditCardEditController.h"
#import <ATGMobileClient/ATGAddressSection.h>
#import <ATGMobileClient/ATGCreditCard.h>
#import <ATGUIElements/ATGButton.h>
#import <ATGUIElements/ATGDatePicker.h>
#import <ATGMobileClient/ATGDataFormatters.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

static const CGFloat ATGDeleteTextSidePadding = 7;
static const CGFloat ATGDeleteVerticalPadding = 2;
static const CGFloat ATGDeleteMinimumWidth = 70;

#pragma mark - ATGProfileCreditCardEditController Private Protocol
#pragma mark -

@interface ATGProfileCreditCardEditController () <ATGProfileManagerDelegate, UITextFieldDelegate,
                                                  ATGDatePickerDelegate, ATGKeyboardToolbarDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *cardNicknameInput;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *cardExpirationDateInput;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *cardNicknameLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *cardExpirationDateLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *removeCardLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *cardIdentifierLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *saveButton;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) UIView *viewContainer;
@property (nonatomic, readwrite, strong) UITableView *initialTableView;
@property (nonatomic, readwrite, strong) ATGAddressSection *addressSection;
@property (nonatomic, readwrite, copy) NSArray *countriesOrStates;
@property (nonatomic, readwrite, copy) NSString *currentCountryOrState;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSDate *expirationDate;
@property (nonatomic, readwrite, strong) ATGDatePicker *expirationDatePicker;
@property (nonatomic, readwrite) BOOL useAsDefault;

#pragma mark - UI Event Handlers

- (IBAction) didTouchDeleteButton:(UIButton *)sender;
- (void)     commitDeleteCard:(UIButton *)sender;
- (IBAction) didTouchSaveButton:(UIButton *)sender;

#pragma mark - Private Protocol Definition

- (void) keyboardDidHide:(NSNotification *)notification;
- (void) didSubmitDone;
@end

#pragma mark - ATGProfileCreditCardEditController Implementation
#pragma mark -

@implementation ATGProfileCreditCardEditController

#pragma mark - Synthesized Properties

@synthesize addressSection;
@synthesize creditCard;
@synthesize countriesOrStates;
@synthesize currentCountryOrState;
@synthesize request;
@synthesize viewContainer;
@synthesize cardNicknameInput;
@synthesize initialTableView;
@synthesize expirationDate;
@synthesize cardExpirationDateInput;
@synthesize expirationDatePicker;
@synthesize cardNicknameLabel;
@synthesize cardExpirationDateLabel;
@synthesize removeCardLabel;
@synthesize cardIdentifierLabel;
@synthesize useAsDefault;
@synthesize saveButton;

#pragma mark NSObject

- (void) dealloc {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (UIView *) view {
  // We're going to wrap initial table view into a container. This is essential to
  // emulate iPhone-style behavior of the view when displaying a picker within the popover
  // on iPad.
  return [self viewContainer] ? [self viewContainer] : [super view];
}

- (UITableView *) tableView {
  return [self initialTableView] ? [self initialTableView] : [super tableView];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return NO;
}

- (void) viewDidLoad {
  [super viewDidLoad];

  // Wrap initial table view into a container view. We will shrink table view's frame when the picker
  // is on the display.
  UIView *container = [[UIView alloc] initWithFrame:[[self tableView] frame]];
  [container setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
  [container addSubview:[self tableView]];
  [[self tableView] setFrame:[container bounds]];
  UITableView *tableView = [super tableView];
  [self setViewContainer:container];
  [self setInitialTableView:tableView];

  // Bill To section is managed by the address section.
  self.addressSection = [[ATGAddressSection alloc] init];
  [self.addressSection setDelegate:self];
  [self.addressSection setWidth:ATGPhoneScreenWidth];
  [self.addressSection setAddress:[[self creditCard] billingAddress]];
  [self.addressSection setCreditCard:[self creditCard]];
  [self.addressSection setCreating:NO];
  [self.addressSection setShowsContacts:NO];
  [self.addressSection setShowsNickname:NO];
  [self.addressSection setShowsMarkDefault:NO];
  [self.addressSection setShowsDelete:NO];
  [self.addressSection setStartSection:1];
  [self.addressSection viewDidLoad];

  ATGDatePicker *picker = [[ATGDatePicker alloc] initWithFrame:CGRectZero];
  [picker setMDelegate:self];
  [picker setShowsSelectionIndicator:YES];
  [picker setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  [self setExpirationDatePicker:picker];

  // Credit card data should be available already. Just update input fields with it.
  [[self cardNicknameInput] setDelegate:self];
  [[self cardNicknameInput] setText:[[self creditCard] nickname]];
  [self didSelectDate:[[ATGDataFormatters cardExpirationDateFormatter]
                       dateFromString:[NSString stringWithFormat:@"%@ / %@",
                                       [[self creditCard] expirationMonth],
                                       [[self creditCard] expirationYear]]]];
  [self setUseAsDefault:[[[self creditCard] repositoryId]
                         isEqualToString:[[self creditCard] defaultCreditCardId]]];

  // Now update loaded view with localized contents.
  NSString *titleFormat = NSLocalizedStringWithDefaultValue
                            (@"ATGProfileCreditCardEditViewController.ScreenTitleFormat",
                             nil, [NSBundle mainBundle], @"%1$@ ... %2$@",
                            @"Format to be used to construct screen title of the 'Credit Card - Edit' screen. "
                            @"First parameter is credit card's type; second parameter are last four digits of credit card number.");
  if ([self isPad]) {
    [self setTitle:[NSString stringWithFormat:titleFormat,
                    [self.creditCard creditCardTypeDisplayName], [[self creditCard] maskedCreditCardNumber]]];

    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGProfileCreditCardEditViewController.NicknamePlaceholder",
                         nil, [NSBundle mainBundle], @"Nickname",
                        @"Placeholder to be used by the input field for the card's nickname on the "
                        @"'Credit Card - Edit' screen.");
    [[self cardNicknameLabel] setText:title];
    title = NSLocalizedStringWithDefaultValue
              (@"ATGProfileCreditCardEditViewcontroller.ExpirationDatePlaceholder",
               nil, [NSBundle mainBundle], @"Expires",
              @"Placeholder to be dislpayed within the input field for the card expiration date on the "
              @"'Credit Card - Edit' screen.");
    [[self cardExpirationDateLabel] setText:title];
  } else {
    [[self cardIdentifierLabel] setText:[NSString stringWithFormat:titleFormat,
                                         [self.creditCard creditCardTypeDisplayName],
                                         [[self creditCard] maskedCreditCardNumber]]];
    [self setTitle:NSLocalizedStringWithDefaultValue
       (@"ATGCreditCardEditController.ControllerTitle.Edit",
        nil, [NSBundle mainBundle], @"Edit Credit card",
       @"Title to be displayed on the top of the screen for edition of credit card.")];

    ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:self];
    [[self cardNicknameInput] setInputAccessoryView:toolbar];
    [[self cardExpirationDateInput] setInputAccessoryView:toolbar];

    NSString *placeholder = NSLocalizedStringWithDefaultValue
                              (@"ATGProfileCreditCardEditViewController.NicknamePlaceholder",
                               nil, [NSBundle mainBundle], @"Nickname",
                              @"Placeholder to be used by the input field for the card's nickname on the "
                              @"'Credit Card - Edit' screen.");
    [[self cardNicknameInput] setPlaceholder:placeholder];
    placeholder = NSLocalizedStringWithDefaultValue
                    (@"ATGProfileCreditCardEditViewcontroller.ExpirationDatePlaceholder",
                     nil, [NSBundle mainBundle], @"Expires",
                    @"Placeholder to be dislpayed within the input field for the card expiration date on the "
                    @"'Credit Card - Edit' screen.");
    [[self cardExpirationDateInput] setPlaceholder:placeholder];

    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGCreditCardEditController.SaveButtonTitle",
                         nil, [NSBundle mainBundle], @"Save",
                        @"Title to be used by the save button.");
    [[self saveButton] setTitle:title forState:UIControlStateNormal];
  }
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGProfileCreditCardEditViewController.RemoveCardLabel",
                       nil, [NSBundle mainBundle], @"Remove this card",
                      @"Label to be displayed on the cell removing currently edited card.");
  [[self removeCardLabel] setText:title];
}

- (void) viewDidUnload {
  [[self addressSection] viewDidUnload];
  [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self addressSection] viewWillAppear:pAnimated];
}

- (void) viewWillDisappear:(BOOL)pAnimated {
  [[self addressSection] viewWillDisappear:pAnimated];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [super viewWillDisappear:pAnimated];
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  [self.addressSection prepareForSegue:pSegue sender:pSender];
}

- (CGSize) contentSizeForViewInPopover {
  CGFloat height = 0;
  for (NSInteger section = 0; section < [[self tableView] numberOfSections]; section++) {
    for (NSInteger row = 0; row < [[self tableView] numberOfRowsInSection:section]; row++) {
      height += [self          tableView:[self tableView]
                 heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    }
  }
  height += [[self tableView] sectionHeaderHeight];
  return CGSizeMake(320, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // First section is defined with storyboard static cells, so don't forget to call super.
    return [super tableView:pTableView numberOfRowsInSection:pSection] +
           [self errorNumberOfRowsInSection:pSection];
  } else {
    return [[self addressSection] numberOfRowsInSection:pSection];
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView
          cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
    if (errorCell) {
      return errorCell;
    }
    pIndexPath = [self shiftIndexPath:pIndexPath];
    // First section is defined with storyboard static cells, so don't forget to call super.
    return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
  } else {
    return [[self addressSection] cellForRowAtIndexPath:pIndexPath];
  }
}

- (NSString *) tableView:(UITableView *)pTableView titleForHeaderInSection:(NSInteger)pSection {
  if (pSection == 1) {
    return NSLocalizedStringWithDefaultValue
             (@"ATGProfileCreditCardEditViewController.BillingAddressSubtitle",
              nil, [NSBundle mainBundle], @"Bill To",
             @"Subtitle to be displayed before the billing address on the 'Credit Card - Edit' screen.");
  }
  return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
    if (height > 0) {
      return height;
    }
    pIndexPath = [self shiftIndexPath:pIndexPath];
    return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
  } else {
    return [[self addressSection] heightForRowAtIndexPath:pIndexPath];
  }
}

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
 forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  if ([pIndexPath section] > 0) {
    // It's an address-related cell. It should be managed by address section component.
    [[self addressSection] willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  } else if (![self isPad] && [[self shiftIndexPath:pIndexPath] row] == 2) {
    [[pCell imageView] setHidden:![self useAsDefault]];
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] > 0) {
    [[self addressSection] didSelectRowAtIndexPath:pIndexPath];
  } else if (![self isPad] && [[self shiftIndexPath:pIndexPath] row] == 2) {
    // On iPhone we have the 'Set as default' row, so handle it.
    [self setUseAsDefault:![self useAsDefault]];
    [[[pTableView cellForRowAtIndexPath:pIndexPath] imageView] setHidden:![self useAsDefault]];
    [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  } else {
    // Otherwise it's a card-related cell with input field. Find the field and focus on it.
    [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
    UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
    NSInteger index = [[[cell contentView] subviews] indexOfObjectPassingTest:
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
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)pTextField {
  if (pTextField == [self cardExpirationDateInput]) {
    // We're about to begin choosing credit card expiration date. Set current date to the picker.
    [[self expirationDatePicker] setDate:[self expirationDate]];
    if ([self isPad]) {
      // On iPad simulate iPhone-specific behavior within a popover. I.e. display the picker
      // at the bottom of the popover and shrink the table view frame not to overlap with picker.
      CGFloat heightDelta = [[self expirationDatePicker] frame].size.height;
      CGRect frame = [[self view] bounds];
      frame.origin.y = frame.size.height;
      [[self view] addSubview:[self expirationDatePicker]];
      [[self expirationDatePicker] setFrame:frame];
      // Animate this transition.
      [UIView animateWithDuration:.3 animations:
       ^{
         CGRect tableFrame = [[self tableView] frame];
         tableFrame.size.height -= heightDelta;
         [[self tableView] setFrame:tableFrame];

         CGRect pickerFrame = frame;
         pickerFrame.origin.y -= heightDelta;
         [[self expirationDatePicker] setFrame:pickerFrame];
       }
                       completion:
       ^(BOOL finished)
       {
         [[self tableView] flashScrollIndicators];
       }
      ];
      [[self cardExpirationDateInput] setInputView:[[UIView alloc] initWithFrame:CGRectZero]];
    } else {
      // On iPhone just display the picker instead of the standard keyboard.
      [pTextField setInputView:[self expirationDatePicker]];
    }
  }
}

- (void) textFieldDidEndEditing:(UITextField *)pTextField {
  if (pTextField == [self cardExpirationDateInput] && [self isPad]) {
    // On iPad we have to return table view to its initial state.
    CGFloat heightDelta = [[self expirationDatePicker] frame].size.height;
    [UIView animateWithDuration:.3 animations:
     ^{
       CGRect tableFrame = [[self tableView] frame];
       tableFrame.size.height += heightDelta;
       [[self tableView] setFrame:tableFrame];

       CGRect pickerFrame = [[self expirationDatePicker] frame];
       pickerFrame.origin.y += heightDelta;
       [[self expirationDatePicker] setFrame:pickerFrame];
     }
                     completion:
     ^(BOOL finished)
     {
       [[self tableView] flashScrollIndicators];
     }
    ];
  }
}

- (BOOL) textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
 replacementString:(NSString *)pString {
  if (pTextField == [self cardNicknameInput]) {
    return [[pTextField text] length] - pRange.length + [pString length] <= CCNicknameMaxLength;
  }
  return YES;
}

#pragma mark - ATGDatePickerDelegate

- (void) didSelectDate:(NSDate *)pDate {
  [self setExpirationDate:pDate];
  [[self cardExpirationDateInput] setText:[[ATGDataFormatters cardExpirationDateFormatter]
                                           stringFromDate:pDate]];
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL) hasPreviousInputForTextField:(UITextField *)pTextField {
  return pTextField != [self cardNicknameInput];
}

- (BOOL) hasNextInputForTextField:(UITextField *)pTextField {
  if (pTextField == [self cardNicknameInput] || pTextField == [self cardExpirationDateInput]) {
    return YES;
  }
  // Address section first tries to get next input from its delegate. Because of that we're going to
  // get an infinite recursion. To avoid this effect, we're setting the delegate to nil first and asking
  // the address section to get its next input field.
  [[self addressSection] setDelegate:nil];
  BOOL result = [[self addressSection] hasNextInputForTextField:pTextField];
  // When everything is set, just return delegate to its place.
  [[self addressSection] setDelegate:self];
  return result;
}

- (void) activatePreviousInputForTextField:(UITextField *)pTextField {
  NSIndexPath *path = nil;
  UITextField *input = nil;
  if (pTextField == [self cardExpirationDateInput]) {
    path = [NSIndexPath indexPathForRow:0 inSection:0];
    input = [self cardNicknameInput];
  } else {
    path = [NSIndexPath indexPathForRow:1 inSection:0];
    input = [self cardExpirationDateInput];
  }
  path = [self convertIndexPath:path];
  [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  [input becomeFirstResponder];
}

- (void) activateNextInputForTextField:(UITextField *)pTextField {
  if (pTextField == [self cardNicknameInput]) {
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    path = [self convertIndexPath:path];
    [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom
                                    animated:YES];
    [[self cardExpirationDateInput] becomeFirstResponder];
  } else {
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
    [[self tableView] scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom
                                    animated:YES];
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
    [[[cell contentView] subviews] enumerateObjectsUsingBlock:
     ^(id pObject, NSUInteger pIndex, BOOL * pStop)
     {
       if ([pObject isKindOfClass:[UITextField class]]) {
         *pStop = YES;
         [(UITextField *) pObject becomeFirstResponder];
       }
     }
    ];
  }
}

#pragma mark - ATGProfileManagerDelegate

- (void) didUpdateCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void) didErrorUpdatingCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequestResults error] inSection:0];
}

- (void) didRemoveCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void) didErrorRemovingCreditCard:(ATGProfileManagerRequest *)pRequestResults {
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequestResults error] localizedDescription]];
}

#pragma mark - UI Event Handlers

- (void) didTouchDeleteButton:(UIButton *)pSender {
  // Display a confirmation delete button. Its frame should overlap with initial 'Delete' button
  // to display the button image at the same screen position.
  CGRect originFrame = [[self view] convertRect:[pSender bounds] fromView:pSender];

  NSString *deleteTitle = NSLocalizedStringWithDefaultValue
                            (@"ATGAdditions.DeleteButtonTitle", nil, [NSBundle mainBundle],
                            @"Delete", @"Title to be displayed on the Delete button.");

  UIFont *font = [UIFont deleteButtonFont];
  CGSize size = [deleteTitle sizeWithFont:font];
  size.width = MAX(ATGDeleteMinimumWidth, size.width);

  CGRect buttonFrame = CGRectMake
                         (originFrame.origin.x - size.width - ATGDeleteTextSidePadding,
                         originFrame.origin.y - ATGDeleteVerticalPadding,
                         originFrame.size.width + size.width + 2 * ATGDeleteTextSidePadding,
                         originFrame.size.height + 2 * ATGDeleteVerticalPadding);
  UIButton *button = [[ATGButton alloc] initWithFrame:buttonFrame];
  [button applyStyleWithName:@"deleteButton"];
  [button setTitle:deleteTitle forState:UIControlStateNormal];
  [button setImage:[pSender imageForState:UIControlStateNormal] forState:UIControlStateNormal];
  [button setImageEdgeInsets:UIEdgeInsetsMake
     (0, ATGDeleteMinimumWidth, 0, 0)];
  [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -originFrame.size.width + ATGDeleteTextSidePadding, 0, 0)];
  [button addTarget:self action:@selector(commitDeleteCard:) forControlEvents:UIControlEventTouchUpInside];

  ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
  [blocker showBlockView:button
               withFrame:[[self view] bounds]
             actionBlock:
   ^{
     [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
   }
                 forView:[self view]];
}

- (void) commitDeleteCard:(UIButton *)pSender {
  [pSender setEnabled:NO];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] removeCreditCard:[[self creditCard] nickname]
                                                               delegate:self]];
}

- (void) didTouchSaveButton:(UIButton *)pSender {
  [self didSubmitDone];
}

#pragma mark - Private Protocol Implementation

- (void) didSubmitDone {
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];

  if (![[self cardNicknameInput] validate]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    return;
  }

  [[self creditCard] setNewNickname:[[self cardNicknameInput] text]];
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy"];
  [[self creditCard] setExpirationYear:[outputFormatter stringFromDate:[self expirationDate]]];
  [outputFormatter setDateFormat:@"MM"];
  [[self creditCard] setExpirationMonth:[outputFormatter stringFromDate:[self expirationDate]]];
  [[self creditCard] setBillingAddress:[addressSection address]];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager]
                    updateCreditCard:[self creditCard]
                        useAsDefault:[self useAsDefault]
                            delegate:self]];
}

- (void) keyboardDidHide:(NSNotification *)pNotification {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
  [[self tableView] scrollToRowAtIndexPath:[self convertIndexPath:[NSIndexPath indexPathForRow:0
                                                                                     inSection:0]]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

@end