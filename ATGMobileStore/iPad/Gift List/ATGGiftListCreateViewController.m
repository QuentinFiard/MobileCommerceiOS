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
 * </ORACLECOPYRIGHT>*/

#import "ATGGiftListCreateViewController.h"
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGValidatableDropdown.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import "ATGGiftEventTypeViewController.h"
#import "ATGGiftAccessViewController.h"
#import <ATGMobileClient/ATGAddressesViewController.h>
#import <ATGMobileClient/ATGGiftListManager.h>
#import "ATGGiftListItemsViewController.h"
#import <ATGMobileClient/ATGGiftListManagerRequest.h>
#import "ATGRootViewController_iPad.h"

static NSString *const ATGEventTypeSegue = @"ATGCreateToType";
static NSString *const ATGRightsSegue = @"ATGCreateToRights";
static NSString *const ATGAddressSegue = @"ATGCreateToAddress";
static NSString *const ATGViewGiftItemsSegue = @"atgEditGiftListToViewGiftItems";
static NSString *const ATGGiftListStoryboard = @"GiftListStoryboard_iPad";

#pragma mark - ATGGiftListCreateViewController private interface declaration
#pragma mark -
@interface ATGGiftListCreateViewController () <UITableViewDelegate, UITableViewDataSource, ATGGiftlEventTypeViewControllerDelegate, ATGProfileManagerDelegate,
                                               ATGGiftAccessViewControllerDelegate, ATGAddressesViewControllerDelegate, ATGGiftListManagerDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *shipLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (weak, nonatomic) IBOutlet ATGValidatableInput *nameInput;
@property (weak, nonatomic) IBOutlet ATGValidatableDropdown *dateInput;
@property (weak, nonatomic) IBOutlet ATGValidatableInput *shipInput;
@property (weak, nonatomic) IBOutlet ATGValidatableInput *typeInput;
@property (weak, nonatomic) IBOutlet ATGValidatableInput *accessInput;
@property (weak, nonatomic) IBOutlet ATGValidatableInput *desciptionInput;
@property (weak, nonatomic) IBOutlet ATGValidatableInput *instructionsInput;

#pragma mark - Custom properties
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) ATGManagerRequest *request;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) NSString *giftListType;
@property (nonatomic) BOOL giftPublished;
@property (nonatomic, strong) NSString *shippingAddressId;
@property (nonatomic, strong) NSDate *eventDate;

@property (nonatomic, strong) ATGGiftList *giftList;

#pragma mark - Private methods
- (void) willSubmitDone;
- (void) didSelectDisplayItems;
- (void) didChangeDate:(UIDatePicker *)picker;
@end

#pragma mark - ATGGiftListCreateViewController implementation
#pragma mark -
@implementation ATGGiftListCreateViewController

#pragma mark - Lifecycle
- (void) awakeFromNib {
  [super awakeFromNib];
  self.formatter = [[NSDateFormatter alloc] init];
  [self.formatter setDateFormat:@"MMM d, yyyy"];
  self.eventDate = [[NSDate alloc] init];
}

- (void) viewDidLoad {
  [super viewDidLoad];

  self.giftPublished = TRUE;

  UIDatePicker *pickerBirthday = [[UIDatePicker alloc] init];
  [pickerBirthday setDatePickerMode:UIDatePickerModeDate];
  [pickerBirthday setMinimumDate:[NSDate date]];
  [pickerBirthday addTarget:self action:@selector(didChangeDate:)
           forControlEvents:UIControlEventValueChanged];
  [self setDatePicker:pickerBirthday];

  UIBarButtonItem *button;
  NSString *title;
  if ([self listId]) {
    NSString *text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.SaveButton", nil,
                                                       [NSBundle mainBundle], @"Save Changes",
                                                       @"Title for save edited gift list button");

    button = [[UIBarButtonItem alloc] initWithTitle:text
                                              style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(willSubmitDone)];

    title = NSLocalizedStringWithDefaultValue
              (@"ATGGiftListCreateViewController.TitleEdit",
              nil, [NSBundle mainBundle], @"Edit Gift List",
              @"Title to be displayed at the top of the screen which allows to edit gift list.");

    if (![[self delegate] respondsToSelector:@selector(viewControllerShouldDisplayViewItemsButton:)] ||
        [[self delegate] viewControllerShouldDisplayViewItemsButton:self]) {
      UIBarButtonItem *viewItems = [[UIBarButtonItem alloc] initWithTitle:@"View Items" style:UIBarButtonItemStyleBordered target:self action:@selector(didSelectDisplayItems)];
      [self.navigationItem setRightBarButtonItem:viewItems];
    }
  } else   {
    NSString *text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.DoneButton", nil,
                                                       [NSBundle mainBundle], @"Save Gift List",
                                                       @"Title for create gift list button");

    button = [[UIBarButtonItem alloc] initWithTitle:text
                                              style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(willSubmitDone)];

    title = NSLocalizedStringWithDefaultValue
              (@"ATGGiftListCreateViewController.TitleCreate",
              nil, [NSBundle mainBundle], @"Create a Gift List",
              @"Title to be displayed at the top of the screen which allows to create gift list.");
  }

  [self setTitle:title];
  button.width = 320;
  self.toolbarItems = [NSArray arrayWithObject:button];

  [[self nameInput] setLeftView:[self nameLabel]];
  [[self nameInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self nameInput] setBorderWidth:2];
  [[self dateInput] setLeftView:[self dateLabel]];
  [[self dateInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self dateInput] setBorderWidth:2];
  [[self dateInput] setText:[self.formatter stringFromDate:[self eventDate]]];
  [[self shipInput] setLeftView:[self shipLabel]];
  [[self shipInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self shipInput] setBorderWidth:2];
  [[self typeInput] setLeftView:[self typeLabel]];
  [[self typeInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self typeInput] setBorderWidth:2];
  [[self accessInput] setLeftView:[self accessLabel]];
  [[self accessInput] setLeftViewMode:UITextFieldViewModeAlways];
  [[self accessInput] setBorderWidth:2];

  self.accessInput.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.PublicPlaceholder", nil,
                                                            [NSBundle mainBundle], @"Public",
                                                            @"Default value for gift list access rights");
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self navigationController] setToolbarHidden:NO animated:YES];
  [[self tableView] setTableFooterView:nil];

  if ([self listId] && ![self giftList]) {
    [self startActivityIndication:YES];
    self.request = [[ATGGiftListManager instance] getGiftList:[self listId] delegate:self];
  }
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
    rowsHeight += [self          tableView:[self tableView]
                   heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  }
  return CGSizeMake(320, rowsHeight + footerHeight);
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGViewGiftItemsSegue isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGGiftListItemsViewController *itemsController = [pSegue destinationViewController];
    [itemsController setGiftList:[self giftList]];
  } else if ([ATGEventTypeSegue isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGGiftEventTypeViewController *typeController = [pSegue destinationViewController];
    [typeController setDelegate:self];
    [typeController setEventType:[self giftListType]];
  } else if ([ATGRightsSegue isEqualToString:[pSegue identifier]]) {
    [[self view] endEditing:YES];
    ATGGiftAccessViewController *rightsController = [pSegue destinationViewController];
    [rightsController setDelegate:self];
    [rightsController setPublish:self.giftPublished];
  } else {
    [[self view] endEditing:YES];
    ATGAddressesViewController *addressController = [pSegue destinationViewController];
    [addressController setDelegate:self];
  }
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  pCell.backgroundColor = [UIColor whiteColor];
  switch (pIndexPath.row) {
  case 0:
    self.nameLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.ListNameLabel", nil,
                                                            [NSBundle mainBundle], @"Gift List Name",
                                                            @"Label for gift list name cell");
    self.nameInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.ListNamePlaceholder", nil,
                                                                   [NSBundle mainBundle], @"Name your list",
                                                                   @"Placeholder for gift list name input");
    break;

  case 1:
    self.dateLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.EventDateLabel", nil,
                                                            [NSBundle mainBundle], @"Event Date",
                                                            @"Label for gift list event date cell");
    self.dateInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.SelectPlaceholder", nil,
                                                                   [NSBundle mainBundle], @"Select",
                                                                   @"Placeholder for input that needs some select action");
    break;

  case 2:
    self.shipLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.ShipToLabel", nil,
                                                            [NSBundle mainBundle], @"Ship to",
                                                            @"Label for gift list shipping address cell");
    self.shipInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.SelectPlaceholder", nil,
                                                                   [NSBundle mainBundle], @"Select",
                                                                   @"Placeholder for input that needs some select action");
    break;

  case 3:
    self.typeLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.EventTypeLabel", nil,
                                                            [NSBundle mainBundle], @"Event Type",
                                                            @"Label for gift list event type cell");
    self.typeInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.SelectPlaceholder", nil,
                                                                   [NSBundle mainBundle], @"Select",
                                                                   @"Placeholder for input that needs some select action");
    break;

  case 4:
    self.accessLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.AccessLabel", nil,
                                                              [NSBundle mainBundle], @"Who can see this list?",
                                                              @"Label for gift list access rights cell");
    break;

  case 5:
    self.descriptionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.DescriptionLabel", nil,
                                                                   [NSBundle mainBundle], @"Description",
                                                                   @"Label for gift list description cell");
    self.desciptionInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil,
                                                                         [NSBundle mainBundle], @"Optional",
                                                                         @"Phone number text field placeholder");
    [self.desciptionInput removeAllValidators];
    break;

  case 6:
    self.instructionsLabel.text = NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.InstructionsLabel", nil,
                                                                    [NSBundle mainBundle], @"Instructions",
                                                                    @"Label for gift list instructions cell");
    self.instructionsInput.placeholder = NSLocalizedStringWithDefaultValue(@"ATGAddressEditController.PhoneNumberInputPlaceholder", nil,
                                                                           [NSBundle mainBundle], @"Optional",
                                                                           @"Phone number text field placeholder");
    [self.instructionsInput removeAllValidators];
    break;

  default:
    break;
  }

  if ([self giftList]) {
    switch (pIndexPath.row) {
    case 0:
      self.nameInput.text = self.giftList.name;
      break;

    case 1:
      self.dateInput.text = [self.formatter stringFromDate:self.giftList.date];
      break;

    case 2:
      self.shipInput.text = self.giftList.addressName;
      break;

    case 3:
      self.typeInput.text = self.giftList.type;
      break;

    case 4:
      if ([self.giftList isPublic]) {
        [self.accessInput setText:NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.PublicPlaceholder", nil,
                                                                    [NSBundle mainBundle], @"Public",
                                                                    @"Default value for gift list access rights")];
      } else {
        [self.accessInput setText:NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.PrivatePlaceholder", nil,
                                                                    [NSBundle mainBundle], @"Private",
                                                                    @"Indicate private gift list")];
      }
      break;

    case 5:
      self.desciptionInput.text = self.giftList.giftListDescription;
      break;

    case 6:
      self.instructionsInput.text = self.giftList.instructions;
      break;

    default:
      break;
    }
  }
}

#pragma mark - Private method

- (void) didChangeDate:(UIDatePicker *)pPicker {
  [self setEventDate:[pPicker date]];
  [[self dateInput] setText:[self.formatter stringFromDate:[self eventDate]]];
  [[self dateInput] validate];
  if ([self giftList]) {
    [[self giftList] setDate:[self eventDate]];
  }
}

- (void) willSubmitDone {
  [[self view] endEditing:YES];
  BOOL correct = [[self nameInput] validate];
  correct = [[self dateInput] validate] && correct;
  correct = [[self shipInput] validate] && correct;
  correct = [[self typeInput] validate] && correct;
  correct = [[self accessInput] validate] && correct;
  [[self tableView] beginUpdates];
  [[self tableView] endUpdates];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];

  if (!correct) {
    return;
  } else {
    [self startActivityIndication:YES];
    if (![self giftList]) {
      if (![[self delegate]
            respondsToSelector:@selector(viewController:shouldCreateGiftListWithName:
                                         type:addressId:date:publish:description:instructions:)] ||
          [[self delegate] viewController:self
             shouldCreateGiftListWithName:[[self nameInput] text]
                                     type:[self giftListType]
                                addressId:[self shippingAddressId]
                                     date:[self eventDate]
                                  publish:[self giftPublished]
                              description:[[self desciptionInput] text]
                             instructions:[[self instructionsInput] text]]) {
        [self setRequest:[[ATGGiftListManager instance] createGiftListWithName:self.nameInput.text type:[self giftListType] addressId:[self shippingAddressId] date:[self eventDate] publish:[self giftPublished] description:[self.desciptionInput text] instructions:[self.instructionsInput text] delegate:self]];
      } else {
        // Do nothing, delegate has taken care of the new gift list.
      }
    } else {
      [self setRequest:[[ATGGiftListManager instance] updateGiftList:[self giftList] delegate:self]];
    }
  }
}

- (void) didSelectDisplayItems {
  [[ATGRootViewController_iPad rootViewController] displayGiftlistControllerForGiftList:[self giftList] allowsEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)pTextField {
  [[self tableView] setTableFooterView:nil];
  if (pTextField == [self dateInput]) {
    [[self view] endEditing:YES];
    [[self tableView] setTableFooterView:[self datePicker]];
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.datePicker);
    return NO;
  }
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)pTextField {
  if ( (pTextField == self.nameInput) && ([self giftList]) ) {
    [self.giftList setName:pTextField.text];
  }
  if ( (pTextField == self.desciptionInput) && ([self giftList]) ) {
    [self.giftList setGiftListDescription:pTextField.text];
  }
  if ( (pTextField == self.instructionsInput) && ([self giftList]) ) {
    [self.giftList setInstructions:pTextField.text];
  }
}

- (UITableView *) tableView {
  UIView *view = [self view];
  if ([view isKindOfClass:[UITableView class]]) {
    return (UITableView *)view;
  }
  return nil;
}

#pragma mark - View picker delegate

- (void) didSelectEventType:(ATGGiftListType *)pEventType {
  self.giftListType = [pEventType settableValue];
  [self.typeInput setText:[pEventType localizedLabel]];
  [[self typeInput] validate];
  if ([self giftList]) {
    [[self giftList] setType:[self giftListType]];
  }
}

- (void) didSelectAccessRights:(BOOL)publish {
  self.giftPublished = publish;
  if ([self giftPublished]) {
    [self.accessInput setText:NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.PublicPlaceholder", nil,
                                                                [NSBundle mainBundle], @"Public",
                                                                @"Default value for gift list access rights")];
  } else {
    [self.accessInput setText:NSLocalizedStringWithDefaultValue(@"ATGGiftListCreateController.PrivatePlaceholder", nil,
                                                                [NSBundle mainBundle], @"Private",
                                                                @"Indicate private gift list")];
  }
  [[self accessInput] validate];
  if ([self giftList]) {
    [[self giftList] setPublicFlag:self.giftPublished];
  }
}

- (void) didSelectAddress:(ATGContactInfo *)address {
  [self.navigationController popViewControllerAnimated:YES];
  [self setShippingAddressId:[address repositoryId]];
  [self.shipInput setText:[address nickname]];
  [[self shipInput] validate];
  if ([self giftList]) {
    [[self giftList] setAddressId:[self shippingAddressId]];
  }
}

#pragma mark - ATGGiftListManager delegate

- (void) giftListManagerDidGetGiftList:(ATGGiftList *)pGiftList {
  [self stopActivityIndication];
  [self setGiftList:pGiftList];
  [self.tableView reloadData];
}

- (void) giftListManagerDidUpdateGiftList:(ATGGiftList *)pGiftList {
  [self stopActivityIndication];
  [self.navigationController popViewControllerAnimated:YES];
  if ([[self delegate] respondsToSelector:@selector(viewController:didUpdateGiftList:)]) {
    [[self delegate] viewController:self didUpdateGiftList:pGiftList];
  }
}

- (void) giftListManagerDidCreateGiftList:(ATGGiftList *)pGiftList {
  [self stopActivityIndication];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) giftListManagerDidFailWithError:(NSError *)pError {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[[self.request error] localizedDescription]];
}

@end