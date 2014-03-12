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

#import "ATGAddressesViewController.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

const CGFloat ATGAddressDefaultCellHeight = 116;
const CGFloat ATGAddressLastCellHeight = 45;
static NSString *const ATGAddressesToEditAddressSegue = @"addressesToAddressEdit";

#pragma mark - ATGAddressesViewController Private Protocol
#pragma mark -

@interface ATGAddressesViewController ()

#pragma mark - IB Outlets

@property (nonatomic, readwrite, strong) IBOutlet UILabel *noAddressesLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSMutableArray *addresses;
@property (nonatomic, readwrite, strong) ATGContactInfo *selected;
@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
@property (nonatomic, readwrite, strong) NSMutableArray *tableUpdateIndexes;
@property (nonatomic, readwrite, assign, getter = isDefaultAddressSelected) BOOL defaultAddressSelected;

#pragma mark - Private Protocol Definition

- (void) checkmarkAnimationDidStop:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context;
- (void) didSelectAddress;
- (void) editAddressWithUserStatus:(BOOL)anonymous;

@end

#pragma mark - ATGAddressesViewController Implementation
#pragma mark -

@implementation ATGAddressesViewController

#pragma mark - Synthesized Properties

@synthesize createCell, delegate, creditCard, showsSelection;
@synthesize userAnonymous;
@synthesize noAddressesLabel;
@synthesize addresses;
@synthesize selected;
@synthesize request;
@synthesize tableUpdateIndexes;
@synthesize defaultAddressSelected;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    [self setAddresses:[[NSMutableArray alloc] init]];
    //user status is unknown, default to anonymous
    self.userAnonymous = YES;
  }
  return self;
}

- (void)dealloc {
  [[self request] cancelRequest];
}

#pragma mark - Public Protocol Implementation

- (BOOL)hidesDefaults {
  return YES;
}

- (void)fetchAddresses {
  [[self request] cancelRequest];
  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getAddresses:self]];
}

- (void)reloadAddresses:(NSArray *)newAddresses {
  [[self addresses] removeAllObjects];
  [[self addresses] addObjectsFromArray:newAddresses];
  [self setDefaultAddressSelected:NO];
  __block ATGContactInfo *defaultAddress;
  [addresses enumerateObjectsUsingBlock:^(id pObject, NSUInteger pIndex, BOOL * pStop) {
    defaultAddress = (ATGContactInfo *)pObject;
    if ([defaultAddress useShippingAddressAsDefault]) {
      *pStop = YES;
      [self setDefaultAddressSelected:YES];
    }
  }];
  if ([self isDefaultAddressSelected]) {
    [[self addresses] removeObject:defaultAddress];
    [[self addresses] insertObject:defaultAddress atIndex:0];
  }

  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:[self tableUpdateIndexes]
                        withRowAnimation:UITableViewRowAnimationFade];

  if (![self tableUpdateIndexes]) {
    [self setTableUpdateIndexes:[[NSMutableArray alloc] init]];
  } else {
    [[self tableUpdateIndexes] removeAllObjects];
  }

  for (NSInteger i = 0, count = [newAddresses count]; i <  count; i++) {
    [[self tableUpdateIndexes] addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }

  [self.tableView insertRowsAtIndexPaths:[self tableUpdateIndexes]
                        withRowAnimation:UITableViewRowAnimationRight];
  [self.tableView endUpdates];
  [self didReloadAddresses];
}

- (void)didReloadAddresses {
  if ([self isPad]) {
    ATGResizingNavigationController *rnc = (ATGResizingNavigationController *)self.navigationController;
    [rnc resizePopoverAnimated:YES];
  }
}

- (void)createNewAddress {
  //will create new address, request user status
  [self setSelected:nil];
  [[self request] cancelRequest];

  [self startActivityIndication:YES];
  [self setRequest:[[ATGExternalProfileManager profileManager] getSecurityStatus:self]];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.ProfileAddressTitle",
  nil, [NSBundle mainBundle],
  @"Addresses",
  @"Title to be displayed on the top of the screen.");

  [self setTitle:title];
  NSString *create = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateProfileAddressButton",
  nil, [NSBundle mainBundle], @"Create a New Address",
  @"Create address button caption.");
  NSString *acclbl = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateProfileAddressButtonAccessibilityLabel",
  nil, [NSBundle mainBundle],
  @"Create a New Address",
  @"Create profile address button accessibility label.");
  NSString *acchint = NSLocalizedStringWithDefaultValue
      (@"ATGAddressViewController.CreateProfileAddressButtonAccessibilityHint",
  nil, [NSBundle mainBundle], @"Double tap to create profile address",
  @"Create profile address button accessibility hint.");
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:create style:UIBarButtonItemStyleBordered target:self action:@selector(createNewAddress)];
  button.accessibilityLabel = acclbl;
  button.accessibilityHint = acchint;
  button.width = ATGPhoneScreenWidth;
  self.toolbarItems = [NSArray arrayWithObject:button];
  self.tableView.backgroundColor = [UIColor tableBackgroundColor];

  title = NSLocalizedStringWithDefaultValue
      (@"ATGAddressesViewController.NoAddressesMessage",
  nil, [NSBundle mainBundle], @"You have no saved addresses",
  @"Message to be displayed to user on the screen with list of addresses, if no addresses yet.");
  [[self noAddressesLabel] setText:title];
  // check if iOS 7 or greater
  if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }
}

- (void)viewDidUnload {
  [[self request] cancelRequest];
  [self setRequest:nil];
  [self setAddresses:nil];
  [self setCreditCard:nil];
  [self setTableUpdateIndexes:nil];
  [self setDelegate:nil];
  [self setSelected:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  if ([self isPad]) {
    self.navigationController.toolbarHidden = NO;
  }
}

- (void)viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  //refresh addresses
  [self fetchAddresses];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [super viewWillDisappear:pAnimated];
  if ([self isPad]) {
    self.navigationController.toolbarHidden = YES;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  ATGAddressEditController *editor = pSegue.destinationViewController;
  editor.address = [[self selected] copy];
  editor.creditCard = [self creditCard];
  editor.userAnonymous = self.userAnonymous;
  editor.defaultAddressSelected = [self isDefaultAddressSelected];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = 15;
  for (NSInteger row = 0; row < [[self tableView] numberOfRowsInSection:0]; row++) {
    height += [self tableView:[self tableView]
      heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
  }
  return CGSizeMake(ATGPhoneScreenWidth, MAX(ATGPopoverMinHeight, height));
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)pTableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [[self addresses] count] + (IS_IPAD ? 0 : 1) + [self errorNumberOfRowsInSection:pSection];
}

- (void)accessoryButtonTapped:(id)pSender event:(id)pEvent {
  NSSet *touches = [pEvent allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
  if (indexPath != nil) {
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  //error handling
  UITableViewCell *errorCell = [self tableView:pTableView
                    errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];

  //regular table rendering
  if (pIndexPath.row == [[self addresses] count]) {
    static NSString *createCellId = @"CreateCell";
    [self setCreateCell:[pTableView dequeueReusableCellWithIdentifier:createCellId]];
    UILabel *lbl = (UILabel *)[[self createCell] viewWithTag:1];

    if (!lbl.accessibilityLabel) {
      NSString *create = NSLocalizedStringWithDefaultValue
          (@"ATGAddressViewController.CreateProfileAddressButton",
      nil, [NSBundle mainBundle], @"Create a New Address",
      @"Create address button caption.");
      NSString *acclbl = NSLocalizedStringWithDefaultValue
          (@"ATGAddressViewController.CreateProfileAddressButtonAccessibilityLabel",
      nil, [NSBundle mainBundle],
      @"Create a New Address",
      @"Create profile address button accessibility label.");
      NSString *acchint = NSLocalizedStringWithDefaultValue
          (@"ATGAddressViewController.CreateProfileAddressButtonAccessibilityHint",
      nil, [NSBundle mainBundle], @"Double tap to create profile address",
      @"Create profile address button accessibility hint.");

      lbl.text = create;
      [lbl setAccessibilityLabel:acclbl];
      [lbl setAccessibilityHint:acchint];
      [lbl setAccessibilityTraits:UIAccessibilityTraitButton];

      if ([self isPad]) {
        UIView *background = [[UIView alloc] init];
        background.backgroundColor = [UIColor tableCellBackgroundColor];
        [self createCell].backgroundView = background;
      }
    }
    return createCell;
  }

  static NSString *cellIdentifier = @"AddressCell";

  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];
  cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
  if (!cell.accessoryView) {
    CGRect frame = CGRectMake(0.0, 0.0, 0.0, cell.frame.size.height);

    ATGTableAccessoryButton *button = [[ATGTableAccessoryButton alloc] initWithFrame:frame];
    [button addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;

    if ([self isPad]) {
      UIView *background = [[UIView alloc] init];
      background.backgroundColor = [UIColor tableCellBackgroundColor];
      cell.backgroundView = background;
    }
  }

  return cell;
}

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  pIndexPath = [self shiftIndexPath:pIndexPath];
  //cell at shifted row with -1 will be error cell
  if (pIndexPath.row < 0 || pIndexPath.row == [[self addresses] count]) {
    return;
  }

  ATGContactInfo *address = [[self addresses] objectAtIndex:pIndexPath.row];

  BOOL hide = ([self hidesDefaults] || !address.useShippingAddressAsDefault);
  UILabel *lblDefault = (UILabel *)[pCell viewWithTag:2];
  lblDefault.hidden = hide;

  // if visible, set the localized text.  
  if (!hide) {
    lblDefault.text = NSLocalizedStringWithDefaultValue
        (@"ATGAddressViewController.DefaultAddressLabel",
    nil,[NSBundle mainBundle],
    @"Default Address",
    @"Default address label.");
    [lblDefault applyStyleWithName:@"formTitleDisabledRightLabel"];
  }

  UILabel *lblNick = (UILabel *)[pCell viewWithTag:3];
  lblNick.text = [address nickname];
  [lblNick applyStyleWithName:@"formTitleLabel"];
  UILabel *lblName = (UILabel *)[pCell viewWithTag:4];
  lblName.text = [NSString stringWithFormat:@"%@ %@", [address firstName], [address lastName]];
  [lblName applyStyleWithName:@"formFieldLabel"];
  UILabel *lblAddr = (UILabel *)[pCell viewWithTag:5];
  lblAddr.text = [NSString stringWithCommaSeparatedStrings:address.address1, address.address2, nil];
  [lblAddr applyStyleWithName:@"formFieldLabel"];
  UILabel *lblCity = (UILabel *)[pCell viewWithTag:6];
  lblCity.text = [NSString stringWithCommaSeparatedStrings:address.city,
                                                           address.state,
                                                           address.postalCode,
                                                           nil];
  [lblCity applyStyleWithName:@"formFieldLabel"];
  UILabel *lblCntr = (UILabel *)[pCell viewWithTag:7];
  lblCntr.text = address.country;
  [lblCntr applyStyleWithName:@"formFieldLabel"];
  UILabel *lblPhone = (UILabel *)[pCell viewWithTag:8];
  lblPhone.text = [address phoneNumber];
  [lblPhone applyStyleWithName:@"formFieldLabel"];
  pCell.accessoryView.accessibilityLabel =
    [NSString stringWithFormat:@"%@ %@", NSLocalizedStringWithDefaultValue
          (@"ATGAddressesViewController.ControllerTitle.Edit", nil, [NSBundle mainBundle],
    @"Edit Address", @"Edit address with nickname table accessory view accessibility label"),
                               address.nickname];
  [[pCell viewWithTag:1] setHidden:YES];
}

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if (pIndexPath.row == [[self addresses] count]) {
    return ATGAddressLastCellHeight;
  }
  return ATGAddressDefaultCellHeight;
}

- (void)tableView:(UITableView *)pTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)pIndexPath {
  NSInteger addressIndex = [self shiftIndexPath:pIndexPath].row; // stops from accessing out of bounds row in addresses when there are error cells
                                                                 // by decrementing count by the number of error cells
  pIndexPath = [self convertIndexPath:pIndexPath];
  [self setSelected:[[self addresses] objectAtIndex:addressIndex]];
  if ([[self delegate] respondsToSelector:@selector(didSelectAddress:)]) {
    [[self delegate] didSelectAddress:[self selected]];
  }
  else{
    [[self request] cancelRequest];
    [self startActivityIndication:YES];
    [self setRequest:[[ATGExternalProfileManager profileManager] getSecurityStatus:self]];
  }
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:NO];

  pIndexPath = [self shiftIndexPath:pIndexPath];
  // establish the address index by using the shiftIndexPath
  // this allows us to thake into account row index being out
  // of range if there are errors
  NSInteger addressIndex = pIndexPath.row;

  if (pIndexPath.row == [[self addresses] count]) {
    [self createNewAddress];
  } else if (addressIndex >= 0) {
    pIndexPath = [self convertIndexPath:pIndexPath];

    [self setSelected:[[self addresses] objectAtIndex:addressIndex]];
    if ([[self delegate] respondsToSelector:@selector(didSelectAddress:)]) {
      [[self delegate] didSelectAddress:[self selected]];
    }
    if (self.showsSelection) {
      //reset selection
      for (UITableViewCell *cell in[pTableView visibleCells]) {
        if (cell != [self createCell]) {
          [[cell viewWithTag:1] setHidden:YES];
        }
      }

      UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
      UIView *view = [cell viewWithTag:1];
      view.alpha = 0;
      view.hidden = NO;

      //animate new selection
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.5];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(checkmarkAnimationDidStop:finished:context:)];

      view.alpha = 1;

      [UIView commitAnimations];
    }
  }
}

#pragma mark - ATGProfileManagerDelegate

- (void)didGetSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];

  //we did check for status before editing address
  if ([(NSNumber *)[pRequestResults requestResults]
    compare:[NSNumber numberWithInteger:3]] == NSOrderedDescending) {
    // The user is explicitly logged in.
    self.userAnonymous = NO;
  } else {
    // The user is not logged in yet.
    self.userAnonymous = YES;
  }

  [self setRequest:nil];

  [self editAddressWithUserStatus:self.userAnonymous];
}

- (void)didErrorGettingSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
  [self setRequest:nil];
}

- (void)didGetAddresses:(ATGProfileManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSArray *addrs = [pRequest requestResults];
  if ([addrs count] > 0) {
    // There are some addresses got from server, then we're going to display them to the user,
    // return back all the cell separators removed with fetchAddress method.
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  } else if ([self isPad]) {
    // On iPad we should display a note to the user than (s)he has no addresses yet.
    [[self noAddressesLabel] setFrame:[[self tableView] bounds]];
    [[self tableView] setBackgroundView:[self noAddressesLabel]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  }
  [self reloadAddresses:addrs];
  [self setRequest:nil];
}

- (void) didErrorGettingAddresses:(ATGProfileManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [self setRequest:nil];
}

#pragma mark - AddressSelection

- (void)checkmarkAnimationDidStop:(NSString *)pAnimationID
                         finished:(NSNumber *)pFinished
                          context:(void *)pContext {
  [self didSelectAddress];
}

- (void)didSelectAddress {
  if ([self.delegate respondsToSelector:@selector(navigateOnSelection)]) {
    [self.delegate navigateOnSelection];
  }
}

- (void)editAddressWithUserStatus:(BOOL)pAnonymous {
  [self performSegueWithIdentifier:ATGAddressesToEditAddressSegue sender:self];
}

@end
