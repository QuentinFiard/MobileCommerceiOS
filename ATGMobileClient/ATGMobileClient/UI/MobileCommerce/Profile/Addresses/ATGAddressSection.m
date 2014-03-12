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

#import "ATGAddressSection.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGStoreManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import <ATGMobileClient/ATGContactInfo.h>

NSString *const ATGPickerSelectionTypeStates = @"statesSelection";
NSString *const ATGPickerSelectionTypeCountries = @"countriesSelection";
static NSString *const ATGDefaultCountryCode = @"US";

#pragma mark - ATGAddressSection Private Protocol
#pragma mark -

@interface  ATGAddressSection ()

#pragma mark - IB Outlets

@property (nonatomic, strong) IBOutlet UITableViewCell *contactsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *defaultCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *deleteCell;

#pragma mark - Custom Properties

@property (nonatomic, strong) UITableViewCell *doneCell;
@property (nonatomic, strong) UIPickerView *statePicker;
@property (nonatomic, strong) UIPickerView *countryPicker;
@property (nonatomic, readwrite, assign, getter = isDefaultAddressSelected) BOOL defaultAddressSelected;
@property (nonatomic, strong, readwrite) ATGKeyboardToolbar *keyboardToolbar;
@property (nonatomic) CGRect keyboardFrame;
@property (nonatomic, readwrite, strong) NSMutableDictionary *inputCells;
@property (nonatomic, readwrite, strong) NSMutableArray *countries;
@property (nonatomic, readwrite, strong) NSMutableArray *states;
@property (nonatomic, readwrite, strong) NSMutableDictionary *stateCodes;
@property (nonatomic, readwrite, strong) NSMutableDictionary *countryCodes;
@property (nonatomic, readwrite, strong) NSString *cntCountryCode;
@property (nonatomic, readwrite, strong) NSString *cntStateValue;

#pragma mark - Private Protocol Definition

- (void)invalidate;
- (void)fetchCountries;
- (void)fetchStates;
- (void)reloadStates;
- (void)applyStates;
- (void)submitDelete;
- (void)keyboardWillShow:(NSNotification *)pNotification;
- (void)keyboardDidHide:(NSNotification *)pNotification;
- (UITableViewCell *)validateCells;
- (void)updateDefaultMarkAndSwitch:(BOOL)change;
- (IBAction)showDeleteAddress;
- (void)deleteAddress;
- (NSString *)countryCodeForName:(NSString *)name;
- (NSString *)countryNameForCode:(NSString *)code;
- (NSString *)stateCodeForName:(NSString *)name;
- (NSString *)stateNameForCode:(NSString *)code;

@end

#pragma mark - ATGAddressSection Implementation
#pragma mark -

@implementation ATGAddressSection

#pragma mark - Synthesized Properties

@synthesize keyboardToolbar, keyboardFrame, contactsCell, countryPicker, statePicker,
    defaultCell, deleteCell, address, creditCard, delegate, creating, showsContacts,
    showsNickname, showsDelete, showsMarkDefault, startSection, errorsSection, doneCell;
@synthesize defaultAddressSelected;
@synthesize calculatedErrorsSection;
@synthesize shouldUpdateProfile;
@synthesize countries;
@synthesize states;
@synthesize stateCodes;
@synthesize countryCodes;
@synthesize cntCountryCode;
@synthesize cntStateValue;
@synthesize request;
@synthesize storeRequest;
@synthesize inputCells;

#pragma mark - NSObject

- (id)init;
{
  self = [super init];
  if (self) {
    // Update profile by default.
    [self setShouldUpdateProfile:YES];
    self.showsContacts = YES;
    self.showsNickname = YES;
    self.showsMarkDefault = YES;
    self.showsDelete = YES;
    self.startSection = 0;
    self.errorsSection = 1;

    [self setInputCells:[[NSMutableDictionary alloc] init]];
    [self setStateCodes:[[NSMutableDictionary alloc] init]];
    [self setCountryCodes:[[NSMutableDictionary alloc] init]];
    [self setCountries:[[NSMutableArray alloc] init]];
    [self setStates:[[NSMutableArray alloc] init]];
  }
  return self;
}

- (void)dealloc {
  [[self request] cancelRequest];
  [[self storeRequest] cancelRequest];
}

#pragma mark - Public Protocol Implementation

- (void)viewDidLoad {
  UILabel *lbl;
  NSString *text, *acclbl, *acchint;

  [[NSBundle mainBundle] loadNibNamed:@"ATGAddressSection" owner:self options:nil];
  text = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.Billing", nil, [NSBundle mainBundle],
       @"Make this my default address", @"Use this as my billing address button caption.");
  acclbl = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.BillingAccessibilityLabel", nil, [NSBundle mainBundle],
       @"Default address", @"Use this as my billing address button accessibility label.");
  acchint = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.BillingAccessibilityHint", nil, [NSBundle mainBundle],
       @"Marks address as default.", @"Use this as my billing address button accessibility hint.");

  lbl = (UILabel *)[[self defaultCell] viewWithTag:2];
  lbl.text = text;
  [lbl setAccessibilityHint:acchint];
  [lbl setAccessibilityLabel:acclbl];
  [self defaultCell].accessibilityTraits = UIAccessibilityTraitButton;
  if ([self address].useShippingAddressAsDefault) {
    [self defaultCell].accessibilityTraits |= UIAccessibilityTraitSelected;
  }

  lbl = (UILabel *)[[self deleteCell] viewWithTag:1];
  lbl.text = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.Delete", nil, [NSBundle mainBundle],
       @"Delete this address", @"Delete address label text");

  [self deleteCell].accessibilityLabel = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.DeleteAccessibilityLabel", nil, [NSBundle mainBundle],
       @"Delete address button", @"Delete address accessibility label");
  [self deleteCell].accessibilityHint = NSLocalizedStringWithDefaultValue
      (@"ATGAddressEditController.DeleteAccessibilityHint", nil, [NSBundle mainBundle],
       @"This button delete address", @"Delete address accessibility hint");
  [self deleteCell].accessibilityTraits = UIAccessibilityTraitButton;

  if ([self isPad]) {
    text = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.Done", nil, [NSBundle mainBundle],
         @"Done", @"Done button caption.");
    acclbl = NSLocalizedStringWithDefaultValue(@"ATGAddressEditController.DoneAccessibilityLabel", nil, [NSBundle mainBundle],
    @"Done", @"Done button accessibility label.");
    acchint = NSLocalizedStringWithDefaultValue(@"ATGAddressEditController.DoneAccessibilityHint", nil, [NSBundle mainBundle],
    @"Complete editing of the address.", @"Done button accessibility hint.");

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:text
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(willSubmitDone)];

    button.accessibilityLabel = acclbl;
    button.accessibilityHint = acchint;
    button.width = self.width;

    if ([self isInModal])
      [self delegate].navigationItem.rightBarButtonItem = button;
    else
      [self delegate].toolbarItems = [NSArray arrayWithObject:button];

  } else {
    text = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.Contacts", nil, [NSBundle mainBundle],
         @"Get Address from Contacts", @"Get address from contacts button caption.");
    acclbl = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.ContactsAccessibilityLabel", nil, [NSBundle mainBundle],
         @"Get Address from Contacts Button", @"Get address from contacts button accessibility label.");
    acchint = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.ContactsAccessibilityHint", nil, [NSBundle mainBundle],
         @"Gets Address from Contacts Button", @"Get address from contacts button accessibility hint.");

    lbl = (UILabel *)[[self contactsCell] viewWithTag:1];
    lbl.text = text;
    [lbl setAccessibilityTraits:UIAccessibilityTraitButton];
    [lbl setAccessibilityHint:acchint];
    [lbl setAccessibilityLabel:acclbl];


    [self setDoneCell:[[ATGButtonTableViewCell alloc] initWithReuseIdentifier:@"DoneButton"]];
    NSString *done = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.Done", nil, [NSBundle mainBundle],
         @"Done", @"Done button caption.");
    [[(ATGButtonTableViewCell *)self.doneCell button] setTitle:done forState:UIControlStateNormal];
    [[(ATGButtonTableViewCell *)self.doneCell button] addTarget:self
                                                         action:@selector(willSubmitDone)
                                               forControlEvents:UIControlEventTouchUpInside];
  }

  if (![self isPad]) {
    [self setKeyboardToolbar:[[ATGKeyboardToolbar alloc] initWithDelegate:self]];
  }

  [self setStatePicker:[[UIPickerView alloc] init]];
  [self statePicker].dataSource = self;
  [self statePicker].delegate = self;
  [[self statePicker] setShowsSelectionIndicator:YES];

  [self setCountryPicker:[[UIPickerView alloc] init]];
  [self countryPicker].dataSource = self;
  [self countryPicker].delegate = self;
  [[self countryPicker] setShowsSelectionIndicator:YES];

  [self delegate].tableView.backgroundColor = [UIColor tableBackgroundColor];

  // Update contact info before it will be displayed to user.
  if ([self creating]) {
    [[self address] setUseShippingAddressAsDefault:![self isDefaultAddressSelected]];
  }
  [self fetchCountries];
}

- (void)viewDidUnload {
  [[self request] cancelRequest];
  [self setRequest:nil];
  [[self storeRequest] cancelRequest];
  [self setStoreRequest:nil];
  [self setAddress:nil];
  [self setCreditCard:nil];
  [self setCountries:nil];
  [self setStates:nil];
  [self setCountryPicker:nil];
  [self setStatePicker:nil];
  [self setContactsCell:nil];
  [self setDefaultCell:nil];
  [self setDoneCell:nil];
  [self setKeyboardToolbar:nil];
  [[self inputCells] removeAllObjects];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidHide:)
                                               name:UIKeyboardDidHideNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  if ([self isPad]) {
    [self delegate].navigationController.toolbarHidden = NO;
  }
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidHideNotification
                                                object:nil];
  if ([self isPad]) {
    [self delegate].navigationController.toolbarHidden = YES;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueIdAddressEditToPicker isEqualToString:pSegue.identifier]) {
    ATGPickerViewController *controller = pSegue.destinationViewController;
    if ([pSender isEqualToString:ATGPickerSelectionTypeCountries]) {
      controller.type = ATGPickerSelectionTypeCountries;
      controller.strings = [self countries];
      controller.selected = [self countryNameForCode:[self address].country];
      controller.delegate = self;
      controller.title = NSLocalizedStringWithDefaultValue
          (@"ATGProfileCreditCardEditViewController.ChooseCountry.ScreenTitle",
           nil, [NSBundle mainBundle], @"Select Country",
           @"Screen title to be displayed while choosing an address country.");
    } else {
      controller.type = ATGPickerSelectionTypeStates;
      controller.strings = [self states];
      controller.selected = [self stateNameForCode:[self address].state];
      controller.delegate = self;
      controller.title = NSLocalizedStringWithDefaultValue
          (@"ATGProfileCreditCardEditViewController.ChooseState.ScreenTitle",
           nil, [NSBundle mainBundle], @"Select State",
           @"Screen title to be displayed while choosing an address state.");
    }
  }
}

#pragma mark - Private Protocol Implementation

- (UITableViewCell *)renderOffsceenCells:(NSIndexPath *)pIndexPath {
  UITableViewCell *cell = [[self delegate] tableView:[self delegate].tableView
                               cellForRowAtIndexPath:pIndexPath];
  [[self delegate] tableView:[self delegate].tableView willDisplayCell:cell forRowAtIndexPath:pIndexPath];
  return cell;
}

- (UITableViewCell *)renderOffsceenCells:(NSInteger)pRow section:(NSInteger)pSection {
  NSIndexPath *indexPath = [[self delegate] convertIndexPath:[NSIndexPath indexPathForRow:pRow
                                                                                inSection:pSection]];
  return [self renderOffsceenCells:indexPath];
}

- (void)willSubmitDone {
  UITableViewCell *invalidCell = [self validateCells];
  if (invalidCell) {
    CGRect frame = invalidCell.frame;
    CGSize kbSize = self.keyboardFrame.size;
    if (kbSize.height > 0) {
      frame.origin.y += kbSize.height - self.keyboardToolbar.frame.size.height;
    }
    if (frame.origin.y < 0) {
      frame.origin.y = 0;
    }
    if (frame.origin.y + frame.size.height > delegate.tableView.contentSize.height) {
      frame.origin.y = [self delegate].tableView.contentSize.height - frame.size.height -
          kbSize.height + self.keyboardToolbar.frame.size.height;
    }
    [self.delegate.tableView scrollRectToVisible:frame animated:YES];
  } else {
    if ([[self delegate] respondsToSelector:@selector(didSubmitDone)]) {
      [[self delegate] performSelector:@selector(didSubmitDone) withObject:nil];
    } else {
      [self didSubmitDone];
    }
  }
}

- (UITableViewCell *)validateCells {
  [[self delegate].view endEditing:NO];

  UITableViewCell *invalidCell = nil;

  //allow delegate to validate first
  if ([[self delegate] respondsToSelector:@selector(validateCells)]) {
    invalidCell = [[self delegate] performSelector:@selector(validateCells) withObject:nil];
  }

  NSInteger section = 1 + self.startSection;
  NSInteger skipRows = 0;

  if (!self.showsContacts) {
    section--;
  }
  if (!self.showsNickname) {
    skipRows++;
  }
  NSInteger validatableCells = 10 - skipRows;
  //credit cards edit controller, state cell
  NSInteger minOffscreenRow = 5;
  BOOL correct = invalidCell == nil;

  //render all cells explicitly
  //currently only few cells appear offscreen and need to be rendered
  if ([[self inputCells] count] < validatableCells) {
    for (int i = minOffscreenRow; i < validatableCells; i++) {
      [self renderOffsceenCells:i section:section];
    }
  }

  UITableViewCell *cell;
  NSIndexPath *path;
  for (int i = 0; i < validatableCells; i++) {
    path = [NSIndexPath indexPathForRow:i + skipRows inSection:1];
    cell = [[self inputCells] objectForKey:path];
    correct = [(ATGValidatableInput *)[cell.contentView.subviews objectAtIndex:0] validate] && correct;
    if (!correct && !invalidCell) {
      invalidCell = cell;
    }
  }

  return invalidCell;
}

- (void)didSubmitDone {
  [[self delegate] startActivityIndication:YES];
  [[self request] cancelRequest];
  ATGExternalProfileManager *pm = [ATGExternalProfileManager profileManager];
  if (self.creating) {
    [self setRequest:[pm createNewAddress:[[self address] copy] delegate:self]];
  } else {
    [self setRequest:[pm updateAddress:[[self address] copy] delegate:self]];
  }
}

- (void)deleteAddress {
  if ([[self delegate] respondsToSelector:@selector(submitDelete)]) {
    [[self delegate] performSelector:@selector(submitDelete) withObject:nil];
  } else {
    [self submitDelete];
  }
}

- (void)submitDelete {
  [[self delegate] startActivityIndication:YES];
  [[self request] cancelRequest];
  [self setRequest:[[ATGExternalProfileManager profileManager] removeAddress:[self address].nickname delegate:self]];
}

- (void)showDeleteAddress {
  UIButton *deleteButton = (UIButton *)[[self deleteCell] viewWithTag:2];
  [[self deleteCell] showDeleteDiallogForButton:deleteButton
                                     withTarget:self
                                     withAction:@selector(deleteAddress)
                                      withTable:[self delegate].tableView];
}

- (void)updateDefaultMarkAndSwitch:(BOOL)pChange {
  if (pChange) {
    [self address].useShippingAddressAsDefault = ![self address].useShippingAddressAsDefault;
  }
  [[[self defaultCell] viewWithTag:1] setHidden:![self address].useShippingAddressAsDefault];
  [self defaultCell].accessibilityTraits = UIAccessibilityTraitButton;
  if ([self address].useShippingAddressAsDefault) {
    [self defaultCell].accessibilityTraits |= UIAccessibilityTraitSelected;
  }
}

- (void)fetchCountries {
  //for profile and shipping addresses shipping country list is used
  [[self storeRequest] cancelRequest];
  [self setStoreRequest:[[ATGStoreManager storeManager] getShippingCountryList:self]];
}

- (void)fetchStates {
  if (![[self stateCodes] objectForKey:address.country]) {
    [self setStoreRequest:[[ATGStoreManager storeManager] getStatesList:[self address].country delegate:self]];
  } else {
    [self performSelectorOnMainThread:@selector(reloadStates) withObject:nil waitUntilDone:NO];
  }
}

- (void)reloadStates {
  [[self states] removeAllObjects];
  NSDictionary *countryStates = [[self stateCodes] objectForKey:[self address].country];
  [[self states] addObjectsFromArray:[[countryStates allValues] sortedArrayUsingSelector:@selector(compare:)]];
  [[self statePicker] reloadAllComponents];

  [self applyStates];
}

- (UITextField *)stateView {
  NSIndexPath *path = [[self delegate] convertIndexPath:[NSIndexPath indexPathForRow:6 inSection:1]];
  UITableViewCell *cell = [[self inputCells] objectForKey:path];
  if (!cell) {
    cell = [self renderOffsceenCells:path];
  }
  return (UITextField *)[cell viewWithTag:ATGAddressStateInput];
}

- (UITextField *)countryView {
  NSIndexPath *path = [[self delegate] convertIndexPath:[NSIndexPath indexPathForRow:7 inSection:1]];
  UITableViewCell *cell = [[self inputCells] objectForKey:path];
  if (!cell) {
    cell = [self renderOffsceenCells:path];
  }
  return (UITextField *)[cell viewWithTag:ATGAddressCountryInput];
}

- (void)applyStates {
  NSDictionary *countryStates = [stateCodes objectForKey:address.country];
  UITextField *stateView = [self stateView];

  if ([self cntStateValue]) {
    if ([countryStates objectForKey:[self cntStateValue]]) {
      [self address].state = [self cntStateValue];
      stateView.text = [self stateNameForCode:[self address].state];
      [self setCntStateValue:nil];
    }
  } else if (![countryStates objectForKey:[self address].state]) {
    //invalid state code, drop it
    [self address].state = nil;
    stateView.text = nil;
  } else {
    stateView.text = [self stateNameForCode:[self address].state];
  }
}

- (void)presentStatesPickerController {
  [self.delegate performSegueWithIdentifier:ATGSegueIdAddressEditToPicker
                                     sender:ATGPickerSelectionTypeStates];
}

- (void)presentCountriesPickerController {
  [self.delegate performSegueWithIdentifier:ATGSegueIdAddressEditToPicker
                                     sender:ATGPickerSelectionTypeCountries];
}

- (void)setShowsContacts:(BOOL)pShows {
  self->showsContacts = pShows;
  [self invalidate];
}

- (void)setErrorsSection:(NSInteger)pSection {
  self->errorsSection = pSection;
  [self invalidate];
}

- (void)invalidate {
  if (!self.showsContacts) {
    [self setCalculatedErrorsSection:self.errorsSection - 1];
  }
}

#pragma mark - Address book

- (void)showContactPicker {
  ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
  picker.peoplePickerDelegate = self;
  picker.modalPresentationStyle = UIModalPresentationFormSheet;

  [[self delegate] presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)pPeoplePicker {
  [[self delegate] dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)pPeoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)pPerson {
  NSString *name = (__bridge_transfer NSString *)ABRecordCopyValue(pPerson, kABPersonFirstNameProperty);
  [self address].firstName = name;

  name = (__bridge_transfer NSString *)ABRecordCopyValue(pPerson, kABPersonLastNameProperty);
  [self address].lastName = name;
  return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)pPeoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)pPerson
                                property:(ABPropertyID)pProperty
                              identifier:(ABMultiValueIdentifier)pIdentifier {
  NSUInteger index;
  ABMultiValueRef abAddress = ABRecordCopyValue(pPerson, kABPersonAddressProperty);
  NSArray *abValues = (__bridge_transfer id)ABMultiValueCopyArrayOfAllValues(abAddress);

  if ([abValues count] > 0) {
    NSDictionary *content = nil;

    if (pProperty == kABPersonAddressProperty) {
      index = ABMultiValueGetIndexForIdentifier(abAddress, pIdentifier);
      content = [abValues objectAtIndex:index];
    } else if ([abValues count] == 1) {
      content = [abValues objectAtIndex:0];
    }

    if (content) {
      NSString *street = [content objectForKey:(NSString *)kABPersonAddressStreetKey];
      NSArray *components = [street componentsSeparatedByString:@"\n"];
      NSInteger half = [components count] / 2;
      NSInteger mod = [components count] % 2;
      NSMutableString *buff = [NSMutableString stringWithString:[components objectAtIndex:0]];
      for (int i = 1; i < half + mod; i++) {
        [buff appendFormat:@", %@", [components objectAtIndex:i]];
      }
      [self address].address1 = [NSString stringWithString:buff];
      if (half > 0) {
        buff = [NSMutableString stringWithString:[components objectAtIndex:half + mod]];
        for (int i = half + mod + 1; i < [components count]; i++) {
          [buff appendFormat:@", %@", [components objectAtIndex:i]];
        }
        [self address].address2 = (NSString *)buff;
      } else {
        [self address].address2 = nil;
      }
      [self address].city = [content objectForKey:(NSString *)kABPersonAddressCityKey];

      cntCountryCode = [[content objectForKey:(NSString *)kABPersonAddressCountryCodeKey] uppercaseString];


      BOOL updateStates = YES;
      if (![[self cntCountryCode] isEqualToString:[[self address].country uppercaseString]]) {
        if ([[self countryCodes] count] > 0) {
          //we already fetched countries, lookup for the code
          if ([[self countryCodes] objectForKey:[self cntCountryCode]]) {
            [self address].country = [self cntCountryCode];
            [self fetchStates];
            [self setCntCountryCode:nil];
            updateStates = NO;
          }
        }
      }

      [self setCntStateValue:[content objectForKey:(NSString *)kABPersonAddressStateKey]];
      if (updateStates) {
        [self applyStates];
      }
      [self address].postalCode = [content objectForKey:(NSString *)kABPersonAddressZIPKey];
    }
  }

  CFRelease(abAddress);

  ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(pPerson, kABPersonPhoneProperty);
  NSArray *phoneNumbers = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
  if (pProperty == kABPersonPhoneProperty) {
    index = ABMultiValueGetIndexForIdentifier(phoneNumberProperty, pIdentifier);
    [self address].phoneNumber = [phoneNumbers objectAtIndex:index];
  } else if ([phoneNumbers count] == 1 || [[self address].phoneNumber length] == 0) {
    [self address].phoneNumber = [phoneNumbers objectAtIndex:0];
  }

  CFRelease(phoneNumberProperty);

  [[self delegate] dismissViewControllerAnimated:YES completion:nil];
  [[self delegate].tableView reloadData];

  return NO;
}

#pragma mark - Table lifecycle

- (NSInteger)numberOfSections {
  //contacts, address, done
  NSInteger sections = self.showsContacts ? 3 : 2;

  //no 'done' for iPad
  if ([self isPad]) {
    sections--;
  }

  return sections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)pSection {
  NSInteger errors = 0;
  if (pSection == self.calculatedErrorsSection) {
    errors = [[self delegate] errorNumberOfRowsInSection:pSection];
  }
  pSection = pSection - self.startSection;
  //contacts section is skipped, apply offset
  if (!self.showsContacts) {
    pSection++;
  }

  if (pSection == 0 || pSection == 2) {
    return (IS_IPAD ? 0 : 1) + errors;
  }

  // We have 9 common input field cells
  NSInteger cellsNumber = 9;
  //Nickname cell
  if (self.showsNickname) {
    cellsNumber++;
  }
  //'Make default' cell
  if (self.showsMarkDefault) {
    cellsNumber++;
  }
  //'Delete' cell in Edit mode.
  if (self.showsDelete) {
    cellsNumber++;
  }

  return cellsNumber + errors;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSIndexPath *originalPath = [NSIndexPath indexPathForRow:pIndexPath.row
                                                 inSection:pIndexPath.section - self.startSection];
  //error handling
  UITableViewCell *errorCell = [[self delegate] tableView:[self delegate].tableView
                               errorCellForRowAtIndexPath:originalPath];
  if (errorCell) {
    return errorCell;
  }

  pIndexPath = [[self delegate] shiftIndexPath:originalPath];

  //if contacts section is skipped - offset applied
  if (!self.showsContacts) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row inSection:pIndexPath.section + 1];
  }

  //regular table rendering
  if (pIndexPath.section == 0) {
    NSLog(@"%@\n", [(UILabel *)[[self contactsCell] viewWithTag:1] font]);
    return [self contactsCell];
  }
  if (pIndexPath.section == 2) {
    return doneCell;
  }

  if (!self.showsNickname) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row + 1 inSection:pIndexPath.section];
  }

  if (pIndexPath.row == 10) {
    if (self.showsMarkDefault) {
      return defaultCell;
    } else {
      return deleteCell;
    }
  }

  if (pIndexPath.row == 11) {
    return deleteCell;
  }

  ATGValidatableInput *input = nil;
  UILabel *label = nil;

  static NSString *cellIdentifier = @"AddressEditCell";
  UITableViewCell *cell = [[self inputCells] objectForKey:pIndexPath];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.isAccessibilityElement = NO;
    CGRect bounds = [[cell contentView] bounds];
    if (pIndexPath.row == 6 || pIndexPath.row == 7) {
      input = [[ATGValidatableDropdown alloc] initWithFrame:CGRectMake(0, 0,
                                                                       bounds.size.width,
                                                                       bounds.size.height)];
    } else {
      input = [[ATGValidatableInput alloc] initWithFrame:CGRectMake(0, 0,
                                                                    bounds.size.width,
                                                                    bounds.size.height)];
    }
    [input setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [input setAutocorrectionType:UITextAutocorrectionTypeNo];
    if ([self isPad]) {
      [input applyStyle:ATGTextFieldAddress];
      label = [[UILabel alloc] init];
      [label applyStyleWithName:@"addressLabel"];
      [input setLeftView:label];
      [input setLeftViewMode:UITextFieldViewModeAlways];
      [input setBorderWidth:2];
      [input setErrorWidthFraction:.25];
    } else {
      [input applyStyle:ATGTextFieldFormText];
      [input setInputAccessoryView:keyboardToolbar];
    }
    [input setDelegate:self];
    input.returnKeyType = UIReturnKeyGo;
    [cell.contentView addSubview:input];

    [[self inputCells] setObject:cell forKey:pIndexPath];
  }


  NSString *text = nil, *acclbl = nil, *acchint = nil;
  NSInteger tag = 0;

  switch (pIndexPath.row) {
    case 0: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.NicknameLabel", nil, [NSBundle mainBundle],
           @"Nickname", @"Nickname label text, appears next to address nickname input");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.NicknameAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Address nickname input field", @"Nickname address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.NicknameAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for address nickname", @"Nickname address text field accessibility hint");
      input.placeholder = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.NicknameInputPlaceholder", nil, [NSBundle mainBundle],
           @"for this address", @"Nickname address text field placeholder");
      tag = ATGAddressNickNameInput;
    }
    break;

    case 1: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.FirstName", nil, [NSBundle mainBundle],
           @"First Name", @"First Name text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.FirstNameAccessibilityLabel", nil, [NSBundle mainBundle],
           @"First name input field", @"First name address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.FirstNameAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for First name", @"First name text field accessibility hint");
      tag = ATGAddressFirstNameInput;
    }
    break;

    case 2: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.LastName", nil, [NSBundle mainBundle],
           @"Last Name", @"Last Name text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.LastNameAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Last name input field", @"Last name address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.LastNameAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for Last name", @"Last name text field accessibility hint");
      tag = ATGAddressLastNameInput;
    }
    break;

    case 3: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.Street", nil, [NSBundle mainBundle],
           @"Street", @"Street text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StreetAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Street input field", @"Street text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StreetAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for Street", @"Street text field accessibility hint");
      tag = ATGAddressStreet1Input;
    }
    break;

    case 4: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.Street", nil, [NSBundle mainBundle],
           @"Street", @"Street text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StreetAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Street input field", @"Street text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StreetAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for Street", @"Street text field accessibility hint");
      [input removeAllValidators];

      tag = ATGAddressStreet2Input;
    }
    break;

    case 5: {
      text = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.City", nil, [NSBundle mainBundle],
         @"City", @"City address text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.CityAccessibilityLabel", nil, [NSBundle mainBundle],
         @"City input field", @"City address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
        (@"ATGAddressEditController.CityAccessibilityHint", nil, [NSBundle mainBundle],
         @"Input for city value", @"City address text field accessibility hint");

      tag = ATGAddressCityInput;
    }
    break;

    case 6: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.State", nil, [NSBundle mainBundle],
           @"State", @"State address text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StateAccessibilityLabel", nil, [NSBundle mainBundle],
           @"State input field", @"State address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.StateAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for state value", @"State address text field accessibility hint");
      tag = ATGAddressStateInput;
      if (![self isPad]) {
        [input setInputView:[self statePicker]];
      }
    }
    break;

    case 7: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.Country", nil, [NSBundle mainBundle],
           @"Country", @"Country address text field placeholder");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.CountryAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Country input field", @"Country address text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.CountryAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for Country value", @"Country address text field accessibility hint");

      tag = ATGAddressCountryInput;
      if (![self isPad]) {
        [input setInputView:[self countryPicker]];
      }
    }
    break;

    case 8: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.ZipLabel", nil, [NSBundle mainBundle],
           @"Zip / Postal Code", @"Zip label text, appears next to address zip input");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.ZipAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Zip or Postal code  input field", @"Zip text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.ZipAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for zip or postal code value", @"Zip address text field accessibility hint");

      tag = ATGAddressZipInput;

      input.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    break;

    case 9: {
      text = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.PhoneLabel", nil, [NSBundle mainBundle],
           @"Phone", @"Phone label text, appears next to phone number input");
      acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.PhoneNumberAccessibilityLabel", nil, [NSBundle mainBundle],
           @"Phone Number input field", @"Phone Number text field accessibility label");
      acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressEditController.PhoneNumberAccessibilityHint", nil, [NSBundle mainBundle],
           @"Input for Phone Number", @"Phone Number text field accessibility hint");

      [input setKeyboardType:UIKeyboardTypePhonePad];

      tag = ATGAddressPhoneInput;
    }
    break;
  }

  if ([self isPad]) {
    label.text = text;
    label.frame = CGRectMake(0, 0, [text sizeWithFont:[label font]].width, 21);
  } else {
    [input setPlaceholder:text];
  }
  [input setAccessibilityLabel:acclbl];
  [input setAccessibilityHint:acchint];
  input.tag = tag;

  return cell;
}

- (void)willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row
                                  inSection:pIndexPath.section - self.startSection];
  if (pIndexPath.row == 0 && [self delegate].tableView.style == UITableViewStyleGrouped) {
    UIView *input = [[[pCell contentView] subviews] objectAtIndex:0];
    if ([[self delegate] errorNumberOfRowsInSection:pIndexPath.section] == 0) {
      [input.layer setMask:[pCell createMaskForIndexPath:pIndexPath
                                            inTableView:[[self delegate] tableView]]];
    } else {
      [input.layer setMask:nil];
    }
  }
  //contacts section is skipped, apply offset
  if (!self.showsContacts) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row
                                    inSection:pIndexPath.section + 1];
  }
  //nickname is skipped, apply offset
  if (pIndexPath.section == 1 && !self.showsNickname) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row + 1
                                    inSection:pIndexPath.section];
  }

  pIndexPath = [[self delegate] shiftIndexPath:pIndexPath];

  switch (pIndexPath.row) {
    case 0: {
      [(UITextField *)[pCell viewWithTag:ATGAddressNickNameInput] setText:[self address].newNickname];
    }
    break;

    case 1: {
      [(UITextField *)[pCell viewWithTag:ATGAddressFirstNameInput] setText:[self address].firstName];
    }
    break;

    case 2: {
      [(UITextField *)[pCell viewWithTag:ATGAddressLastNameInput] setText:[self address].lastName];
    }
    break;

    case 3: {
      [(UITextField *)[pCell viewWithTag:ATGAddressStreet1Input] setText:[self address].address1];
    }
    break;

    case 4: {
      [(UITextField *)[pCell viewWithTag:ATGAddressStreet2Input] setText:[self address].address2];
    }
    break;

    case 5: {
      [(UITextField *)[pCell viewWithTag:ATGAddressCityInput] setText:[self address].city];
    }
    break;

    case 6: {
      [(UITextField *)[pCell viewWithTag:ATGAddressStateInput]
          setText:[self stateNameForCode:[self address].state]];
    }
    break;

    case 7: {
      [(UITextField *)[pCell viewWithTag:ATGAddressCountryInput]
          setText:[self countryNameForCode:[self address].country]];
    }
    break;

    case 8: {
      [(UITextField *)[pCell viewWithTag:ATGAddressZipInput] setText:[self address].postalCode];
    }
    break;

    case 9: {
      [(UITextField *)[pCell viewWithTag:ATGAddressPhoneInput] setText:[self address].phoneNumber];
    }
    break;

    default: {
      if (pCell == [self defaultCell]) {
        [self updateDefaultMarkAndSwitch:NO];
      }
    }
    break;
  }
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row
                                  inSection:pIndexPath.section - self.startSection];
  CGFloat height = [[self delegate] tableView:[self delegate].tableView
                 errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  //contacts section is skipped, apply offset
  if (!self.showsContacts) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row inSection:pIndexPath.section + 1];
  }
  if (!self.showsNickname) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row + 1 inSection:pIndexPath.section];
  }

  // indexPath = [delegate shiftIndexPath:indexPath];

  return 45;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [delegate.tableView deselectRowAtIndexPath:pIndexPath animated:NO];
  NSIndexPath *originalPath = pIndexPath;
  pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row
                                  inSection:pIndexPath.section - self.startSection];

  //contacts section is skipped, apply offset
  if (!self.showsContacts) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row inSection:pIndexPath.section + 1];
  }
  if (!self.showsNickname) {
    pIndexPath = [NSIndexPath indexPathForRow:pIndexPath.row + 1 inSection:pIndexPath.section];
  }


  pIndexPath = [[self delegate] shiftIndexPath:pIndexPath];

  if (pIndexPath.section == 0) {
    [self showContactPicker];
  }
  if (pIndexPath.section == 1 && pIndexPath.row > 9) {
    UITableViewCell *cell = [[self delegate].tableView cellForRowAtIndexPath:originalPath];
    if (cell == [self defaultCell]) {
      [self updateDefaultMarkAndSwitch:YES];
    } else if (cell == [self deleteCell]) {
      [self showDeleteAddress];
    }
  }
}

#pragma mark - Picker lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pPickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pPickerView numberOfRowsInComponent:(NSInteger)pComponent {
  if (pPickerView == [self countryPicker]) {
    return [[self countries] count];
  }
  if (pPickerView == [self statePicker]) {
    return [[self states] count];
  }
  return 0;
}

- (NSString *)pickerView:(UIPickerView *)pPickerView titleForRow:(NSInteger)pRow
            forComponent:(NSInteger)pComponent {
  if (pPickerView == [self countryPicker]) {
    return [[self countries] objectAtIndex:pRow];
  }
  if (pPickerView == [self statePicker]) {
    return [[self states] objectAtIndex:pRow];
  }
  return nil;
}

- (void)pickerView:(UIPickerView *)pPickerView didSelectRow:(NSInteger)pRow
       inComponent:(NSInteger)pComponent {
  if (pPickerView == [self countryPicker]) {
    self.countryView.text =  [[self countries] objectAtIndex:pRow];
    NSString *selection = [self countryCodeForName:self.countryView.text];
    if (![selection isEqualToString:[self address].country]) {
      [self address].country = selection;
      [self setCntCountryCode:nil];
      [self fetchStates];
    }
  }
  if (pPickerView == [self statePicker]) {
    UITextField *stateView = [self stateView];
    stateView.text =  [[self states] objectAtIndex:pRow];
    [self address].state = [self stateCodeForName:stateView.text];
    [self setCntStateValue:nil];
  }
}

#pragma mark - Picker Delegate

- (void)didSelectValue:(NSString *)pValue ofType:(NSString *)pType {
  if ([pType isEqualToString:ATGPickerSelectionTypeStates]) {
    [self pickerView:self.statePicker didSelectRow:[[self states] indexOfObject:pValue] inComponent:0];
  } else {
    [self pickerView:self.countryPicker didSelectRow:[[self countries] indexOfObject:pValue] inComponent:0];
  }
  [self.delegate.navigationController popToViewController:self.delegate animated:YES];
}

#pragma mark - Text fields delegate lifecycle

- (BOOL)textFieldShouldBeginEditing:(UITextField *)pTextField {
  if ([self.delegate isPad]) {
    if ([pTextField tag] == ATGAddressCountryInput) {
      [self presentCountriesPickerController];
      return NO;
    } else if ([pTextField tag] == ATGAddressStateInput) {
      [self presentStatesPickerController];
      return NO;
    }
  } else {
    if (pTextField.tag == ATGAddressCountryInput) {
      UITextField *countryView = [self countryView];
      if (![self address].country && [[self countries] count] > 0) {
        self.countryView.text = [[self countries] objectAtIndex:0];
        [self address].country = [self countryCodeForName:countryView.text];
      }
      NSUInteger index = [[self countries] indexOfObject:self.countryView.text];

      if (index != NSNotFound) {
        [[self countryPicker] selectRow:index inComponent:0 animated:YES];
      }
    } else if (pTextField.tag == ATGAddressStateInput) {
      UITextField *stateView = [self stateView];
      if (![self address].state  && [[self states] count] > 0) {
        stateView.text = [[self states] objectAtIndex:0];
        [self address].state = [self stateCodeForName:stateView.text];
      }
      NSUInteger index = [[self states] indexOfObject:stateView.text];

      if (index != NSNotFound) {
        [[self statePicker] selectRow:index inComponent:0 animated:YES];
      }
    }
  }
  return YES;
}

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  // Trim white spaces
  pString = [pString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  NSUInteger newLength = pTextField.text.length + pString.length - pRange.length;
  NSUInteger limit;
  switch (pTextField.tag) {
    case ATGAddressNickNameInput:
      limit = ATGAddressNickNameInputLimit;
      break;

    case ATGAddressFirstNameInput:
      limit = ATGAddressFirstNameInputLimit;
      break;

    case ATGAddressLastNameInput:
      limit = ATGAddressLastNameInputLimit;
      break;

    case ATGAddressStreet1Input:
      limit = ATGAddressStreet1InputLimit;
      break;

    case ATGAddressStreet2Input:
      limit = ATGAddressStreet2InputLimit;
      break;

    case ATGAddressCityInput:
      limit = ATGAddressCityInputLimit;
      break;

    case ATGAddressStateInput:
      limit = 0;
      break;

    case ATGAddressCountryInput:
      limit = 0;
      break;

    case ATGAddressZipInput:
      limit = ATGAddressZipInputLimit;
      break;

    case ATGAddressPhoneInput:
      limit = ATGAddressPhoneInputLimit;
      break;

    default:
      limit = ATGAddressDefaultInputLimit;
      break;
  }
  return newLength <= limit && newLength >= 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [self willSubmitDone];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)pTextField {
  switch (pTextField.tag) {
    case ATGAddressNickNameInput: {
      // set newNickname rather than nickname so that the nickname field can be retained
      // and sent to the server to be replaced with the newNickname
      [self address].newNickname = pTextField.text;
    }
    break;

    case ATGAddressFirstNameInput: {
      [self address].firstName = pTextField.text;
    }
    break;

    case ATGAddressLastNameInput: {
      [self address].lastName = pTextField.text;
    }
    break;

    case ATGAddressStreet1Input: {
      [self address].address1 = pTextField.text;
    }
    break;

    case ATGAddressStreet2Input: {
      [self address].address2 = pTextField.text;
    }
    break;

    case ATGAddressCityInput: {
      [self address].city = pTextField.text;
    }
    break;

    case ATGAddressStateInput: {
      [self address].state = [self stateCodeForName:pTextField.text];
    }
    break;

    case ATGAddressCountryInput: {
      [self address].country = [self countryCodeForName:pTextField.text];
    }
    break;

    case ATGAddressZipInput: {
      [self address].postalCode = pTextField.text;
    }
    break;

    case ATGAddressPhoneInput: {
      [self address].phoneNumber = pTextField.text;
    }
    break;

    default:
      break;
  }
}

#pragma mark - Countries and states

- (NSString *)countryCodeForName:(NSString *)pName {
  for (NSString *code in [self countryCodes]) {
    if ([[[[self countryCodes] objectForKey:code] uppercaseString] isEqualToString:[pName uppercaseString]]) {
      return code;
    }
  }
  return nil;
}

- (NSString *)countryNameForCode:(NSString *)pCode {
  return [[self countryCodes] objectForKey:[pCode uppercaseString]];
}

- (NSString *)stateCodeForName:(NSString *)pName {
  NSDictionary *countryStates;
  countryStates = [[self stateCodes] objectForKey:[self address].country];
  for (NSString *code in countryStates) {
    if ([[[countryStates objectForKey:code] uppercaseString] isEqualToString:[pName uppercaseString]]) {
      return code;
    }
  }
  return nil;
}

- (NSString *)stateNameForCode:(NSString *)pCode {
  NSDictionary *countryStates = [[self stateCodes] objectForKey:[self address].country];
  return [countryStates objectForKey:[pCode uppercaseString]];
}

#pragma mark - Profile manager delegate

- (void)didGetAddressForEdit:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [self setAddress:[pRequestResults requestResults]];
  [[self delegate].tableView reloadData];
  [self setRequest:nil];
}

- (void) didErrorGettingAddressForEdit:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequestResults error]
                   inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void) didCreateNewAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate].navigationController popViewControllerAnimated:YES];
  [self setRequest:nil];
}

- (void) didErrorCreatingNewAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequestResults error]
                   inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void) didUpdateAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate].navigationController popViewControllerAnimated:YES];
  [self setRequest:nil];
}

- (void) didErrorUpdatingAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequestResults error]
                   inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

- (void) didRemoveAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate].navigationController popViewControllerAnimated:YES];
  request = nil;
}

- (void) didErrorRemovingAddress:(ATGProfileManagerRequest *)pRequestResults {
  [[self delegate] stopActivityIndication];
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequestResults error]
                   inSection:self.calculatedErrorsSection];
  [self setRequest:nil];
}

#pragma mark - Store manager delegate

- (void)didGetShippingCountryList:(ATGStoreManagerRequest *)pRequest {
  NSDictionary *ctr = pRequest.countryList;

  for (NSString *name in ctr) {
    [[self countryCodes] setObject:name forKey:[ctr objectForKey:name]];
    [[self countries] addObject:name];
  }

  if ([self cntCountryCode] && [[self countryCodes] objectForKey:[self cntCountryCode]]) {
    [self address].country = [self cntCountryCode];
    [self setCntCountryCode:nil];
  }
  if (![self address].country) {
    [self address].country = ATGDefaultCountryCode;
  }

  self.countryView.text = [self countryNameForCode:address.country];
  [self fetchStates];
}

- (void)didErrorGettingShippingCountryList:(ATGStoreManagerRequest *)pRequest {
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequest error]
                   inSection:self.calculatedErrorsSection];
  [self setStoreRequest:nil];
}

- (void)didGetBillingCountryList:(ATGStoreManagerRequest *)pRequest {
  NSDictionary *ctr = pRequest.countryList;

  for (NSString *name in ctr) {
    [[self countryCodes] setObject:name forKey:[ctr objectForKey:name]];
    [[self countries] addObject:name];
  }

  if ([self cntCountryCode] && [[self countryCodes] objectForKey:[self cntCountryCode]]) {
    [self address].country = [self cntCountryCode];
    [self setCntCountryCode:nil];
  }
  if (![self address].country) {
    [self address].country = ATGDefaultCountryCode;
  }

  self.countryView.text = [self countryNameForCode:[self address].country];
  [self fetchStates];
}

- (void) didErrorGettingBillingCountryList:(ATGStoreManagerRequest *)pRequest {
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequest error]
                   inSection:self.calculatedErrorsSection];
  [self setStoreRequest:nil];
}

- (void)didGetStatesList:(ATGStoreManagerRequest *)pRequest {
  if (![[self stateCodes] objectForKey:pRequest.countryCode]) {
    NSDictionary *sts = pRequest.stateList;
    NSMutableDictionary *codes = [[NSMutableDictionary alloc] init];
    for (NSString *name in sts) {
      [codes setObject:name forKey:[sts objectForKey:name]];
    }
    [[self stateCodes] setObject:codes forKey:pRequest.countryCode];
  }

  [self performSelectorOnMainThread:@selector(reloadStates) withObject:nil waitUntilDone:NO];

  [self setStoreRequest:nil];
}

- (void)didErrorGettingStatesList:(ATGStoreManagerRequest *)pRequest {
  [[self delegate] tableView:[self delegate].tableView
                    setError:[pRequest error]
                   inSection:self.calculatedErrorsSection];
  [self setStoreRequest:nil];
}

#pragma mark - ATGKeyboardToolbarDelegate

- (BOOL)hasPreviousInputForTextField:(UITextField *)pTextField {
  SEL selector = @selector(hasPreviousInputForTextField:);
  if ([[self delegate] respondsToSelector:selector]) {
    NSMethodSignature *sign = [[self delegate] methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    [invocation setSelector:selector];
    [invocation setTarget:[self delegate]];
    [invocation setArgument:&pTextField atIndex:2];
    BOOL result;
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
  }

  return [pTextField tag] != ATGAddressNickNameInput;
}

- (BOOL)hasNextInputForTextField:(UITextField *)pTextField {
  SEL selector = @selector(hasNextInputForTextField:);
  if ([[self delegate] respondsToSelector:selector]) {
    NSMethodSignature *sign = [[self delegate] methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    [invocation setSelector:selector];
    [invocation setTarget:[self delegate]];
    [invocation setArgument:&pTextField atIndex:2];
    BOOL result;
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
  }
  return [pTextField tag] != ATGAddressPhoneInput;
}

- (void)activatePreviousInputForTextField:(UITextField *)pTextField {
  NSInteger rowNumber = 0;
  NSInteger inputTag = -1;
  NSInteger section = 1 + self.startSection;
  if (!self.showsContacts) {
    section--;
  }
  if (!self.showsNickname) {
    rowNumber--;
  }
  switch ([pTextField tag]) {
    case ATGAddressFirstNameInput:
      if (self.showsNickname) {
        rowNumber += 0;
        inputTag = ATGAddressNickNameInput;
      }
      break;

    case ATGAddressLastNameInput:
      rowNumber += 1;
      inputTag = ATGAddressFirstNameInput;
      break;

    case ATGAddressStreet1Input:
      rowNumber += 2;
      inputTag = ATGAddressLastNameInput;
      break;

    case ATGAddressStreet2Input:
      rowNumber += 3;
      inputTag = ATGAddressStreet1Input;
      break;

    case ATGAddressCityInput:
      rowNumber += 4;
      inputTag = ATGAddressStreet2Input;
      break;

    case ATGAddressStateInput:
      rowNumber += 5;
      inputTag = ATGAddressCityInput;
      break;

    case ATGAddressCountryInput:
      rowNumber += 6;
      inputTag = ATGAddressStateInput;
      break;

    case ATGAddressZipInput:
      rowNumber += 7;
      inputTag = ATGAddressCountryInput;
      break;

    case ATGAddressPhoneInput:
      rowNumber += 8;
      inputTag = ATGAddressZipInput;
      break;
  }

  //no responder found. might be in delegate
  if (inputTag == -1) {
    if ([[self delegate] respondsToSelector:@selector(activatePreviousInputForTextField:)]) {
      [[self delegate] performSelector:@selector(activatePreviousInputForTextField:)
                            withObject:pTextField];
    }
    return;
  }

  NSIndexPath *path = [[self delegate] convertIndexPath:[NSIndexPath indexPathForRow:rowNumber
                                                                           inSection:section]];
  UITableViewCell *inputCell = [[self delegate] tableView:[self delegate].tableView
                                    cellForRowAtIndexPath:path];
  [[self delegate].tableView scrollToRowAtIndexPath:path
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
  [[inputCell viewWithTag:inputTag] becomeFirstResponder];
}

- (void)activateNextInputForTextField:(UITextField *)pTextField {
  NSInteger rowNumber = 0;
  NSInteger inputTag = -1;
  NSInteger section = 1 + self.startSection;
  if (!self.showsContacts) {
    section--;
  }
  if (!self.showsNickname) {
    rowNumber--;
  }
  switch ([pTextField tag]) {
    case ATGAddressNickNameInput:
      rowNumber += 1;
      inputTag = ATGAddressFirstNameInput;
      break;

    case ATGAddressFirstNameInput:
      rowNumber += 2;
      inputTag = ATGAddressLastNameInput;
      break;

    case ATGAddressLastNameInput:
      rowNumber += 3;
      inputTag = ATGAddressStreet1Input;
      break;

    case ATGAddressStreet1Input:
      rowNumber += 4;
      inputTag = ATGAddressStreet2Input;
      break;

    case ATGAddressStreet2Input:
      rowNumber += 5;
      inputTag = ATGAddressCityInput;
      break;

    case ATGAddressCityInput:
      rowNumber += 6;
      inputTag = ATGAddressStateInput;
      break;

    case ATGAddressStateInput:
      rowNumber += 7;
      inputTag = ATGAddressCountryInput;
      break;

    case ATGAddressCountryInput:
      rowNumber += 8;
      inputTag = ATGAddressZipInput;
      break;

    case ATGAddressZipInput:
      rowNumber += 9;
      inputTag = ATGAddressPhoneInput;
      break;

    default:
      if ([[self delegate] respondsToSelector:@selector(activateNextInputForTextField:)]) {
        [[self delegate] performSelector:@selector(activateNextInputForTextField:)
                              withObject:pTextField];
      }
      break;
  }

  if (inputTag == -1) {
    return;
  }

  NSIndexPath *path = [[self delegate] convertIndexPath:[NSIndexPath indexPathForRow:rowNumber
                                                                           inSection:section]];
  UITableViewCell *inputCell = [[self delegate] tableView:[self delegate].tableView
                                    cellForRowAtIndexPath:path];
  [[self delegate].tableView scrollToRowAtIndexPath:path
                                   atScrollPosition:UITableViewScrollPositionMiddle
                                           animated:YES];
  [[inputCell viewWithTag:inputTag] becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)pNotification {
  NSValue *rectValue = [[pNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
  self.keyboardFrame = [self.delegate.view convertRect:[rectValue CGRectValue] fromView:nil];
}

- (void)keyboardDidHide:(NSNotification *)pNotification {
  self.keyboardFrame = CGRectZero;
}

@end