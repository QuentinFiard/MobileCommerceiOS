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

#import "ATGOrderPlacedViewController_iPad.h"
#import "ATGSignupTableViewCell_iPad.h"
#import <ATGMobileClient/ATGKeychainManager.h>
#import "ATGMoreDetailsController.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGRootViewController_iPad.h"
#import <ATGMobileClient/ATGProfile.h>

static NSString *const ATGCellIdOrderNumber = @"ATGCellIdOrderNumber";
static NSString *const ATGCellIdEmail = @"ATGCellIdEmail";
static NSString *const ATGCellIdAllOrders = @"ATGCellIdAllOrders";
static NSString *const ATGSegueIdPrivacyTerms = @"orderPlacedToMoreDetails";

#pragma mark - ATGOrderPlacedViewController_iPad Private Protocol
#pragma mark -

@interface ATGOrderPlacedViewController_iPad () <ATGSignupTableViewCellDelegate, ATGProfileManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;
// Cell is not added to the view hierarchy at the moment of property assignment,
// so this property is required to be strong.
@property (nonatomic, readwrite, strong) ATGSignupTableViewCell_iPad *signupCell;
@property (nonatomic, readwrite, weak) UIView *innerInputView;
@property (nonatomic, readwrite, strong) UIView *viewContainer;
@property (nonatomic, readwrite, strong) UITableView *initialTableView;

@end

#pragma mark - ATGOrderPlacedViewController_iPad Implementation
#pragma mark -

@implementation ATGOrderPlacedViewController_iPad

#pragma mark - Synthesized Properties

@synthesize email;
@synthesize userAnonymous;
@synthesize orderID;
@synthesize request;
@synthesize signupCell;

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

  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.viewContainer.width = ATGPhoneScreenWidth;
    self.viewContainer.height = ATGPhoneScreenHeight;
    self.initialTableView.width = ATGPhoneScreenWidth;
    self.initialTableView.height = ATGPhoneScreenHeight;
  }

  [self setTitle:NSLocalizedStringWithDefaultValue
     (@"ATGOrderPlacedViewController_iPad.ScreenTitle",
     nil, [NSBundle mainBundle], @"Success!",
     @"Title to be displayed at the top of the 'Checkout - Success' screen on iPad.")];
  // Do not clear selection, as it will result in wrong view height calculation.
  [self setClearsSelectionOnViewWillAppear:NO];
  // Do not allow the user to return back to the Order Review screen.
  [[self navigationItem] setHidesBackButton:YES];
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue
     (@"ATGOrderPlacedViewController_iPad.DoneButtonTitle",
  nil, [NSBundle mainBundle], @"Done",
  @"Button title displayed at bottom of 'Checkout - Success' screen on iPad") style:UIBarButtonItemStyleBordered target:self action:@selector(didPressDone)];
  done.width = ATGPhoneScreenWidth;
  self.toolbarItems = [NSArray arrayWithObject:done];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
}

- (void) didPressDone {
  [ATGRootViewController_iPad rootViewController].popover = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueIdPrivacyTerms isEqualToString:[pSegue identifier]]) {
    ATGMoreDetailsController *destination = [pSegue destinationViewController];
    [destination setRequest:[[ATGStoreManager storeManager] getPrivacyPolicy:destination]];
  }
}

- (CGSize) contentSizeForViewInPopover {
  return CGSizeMake(ATGPhoneScreenWidth, self.tableView.contentSize.height);
}

#pragma mark - UITableViewDataSource

- (NSString *) tableView:(UITableView *)pTableView titleForHeaderInSection:(NSInteger)pSection {
  return NSLocalizedStringWithDefaultValue
           (@"ATGOrderPlacedViewController_iPad.OrderConfirmationSubtitle",
           nil, [NSBundle mainBundle], @"Order Confirmation",
           @"Subtitle to be displayed before order-related information on the 'Checkout - Success' screen.");
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // At least two cells are always visible, disregard of the user status.
  return 2 + ([[self email] length] > 0 ? 1 : 0);
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 0) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdOrderNumber];
    [[cell textLabel] setText:NSLocalizedStringWithDefaultValue
       (@"ATGOrderPlacedViewController_iPad.OrderNumberCellTitle",
       nil, [NSBundle mainBundle], @"Your order number is:",
       @"Title to be displayed on the cell with order number on the 'Checkout - Success' screen.")];
    [[cell detailTextLabel] setText:[self orderID]];
    if ([self isUserAnonymous]) {
      [cell setAccessoryType:UITableViewCellAccessoryNone];
      [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    }
    return cell;
  } else if ([pIndexPath row] == 1 && [[self email] length] > 0) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdEmail];
    [[cell textLabel] setText:NSLocalizedStringWithDefaultValue
       (@"ATGOrderPlacedViewController_iPad.EmailCellTitle",
       nil, [NSBundle mainBundle], @"Receipt sent to:",
       @"Title to be displayed on the cell with user email on the 'Checkout - Success' screen.")];
    [[cell detailTextLabel] setText:[self email]];
    return cell;
  } else if ([pIndexPath row] == 2 && ![self isUserAnonymous]) {
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdAllOrders];
    [[cell textLabel] setText:NSLocalizedStringWithDefaultValue
       (@"ATGOrderPlacedViewController_iPad.AllOrdersCellTitle",
       nil, [NSBundle mainBundle], @"View all your orders",
       @"Title to be displayed on the cell navigating user to a list of his orders "
       @"on the 'Checkout - Success' screen.")];
    cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
    return cell;
  } else {
    if ([self signupCell] == nil) {
      ATGSignupTableViewCell_iPad *cell = [ATGSignupTableViewCell_iPad newInstance];
      [cell setEmail:[self email]];
      [cell setDelegate:self];
      cell.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
      [self setSignupCell:cell];
    }
    return [self signupCell];
  }
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)pTableView heightForHeaderInSection:(NSInteger)pSection {
  return 50;
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 0 && ![self isUserAnonymous]) {
    [[self iPadRootController] displayDetailsForOrderId:self.orderID];
  } else if ([pIndexPath row] == 2 && ![self isUserAnonymous]) {
    [[self iPadRootController] displayProfileOrders];
  } else {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

- (NSIndexPath *) tableView:(UITableView *)pTableView willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([[[self tableView] cellForRowAtIndexPath:pIndexPath]
       conformsToProtocol:@protocol(ATGExpandableTableViewCell)]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
  return pIndexPath;
}

#pragma mark - ATGSignupTableViewCellDelegate

- (void) signUpWithEmail:(NSString *)pEmail
                password:(NSString *)pPassword
               firstName:(NSString *)pFirstName
                lastName:(NSString *)pLastName {
  // Do nothing, this method would not be called on iPad.
}

- (void) signUpWithEmail:(NSString *)pEmail
                password:(NSString *)pPassword
               firstName:(NSString *)pFirstName
                lastName:(NSString *)pLastName
          additionalInfo:(NSDictionary *)pAdditionalInfo {
  [self startActivityIndication:YES];
  ATGProfile *user = [[ATGProfile alloc] init];
  [user setEmail:pEmail];
  [user setPassword:pPassword];
  [user setFirstName:pFirstName];
  [user setLastName:pLastName];
  [self setRequest:[[ATGExternalProfileManager profileManager] createNewUser:user
                                                      additionalInfo:pAdditionalInfo
                                                      duringCheckout:YES
                                                            delegate:self]];
}

- (void) resizePopover:(CGFloat)pNewHeight {
  // Do nothing, we're resizing the popover in other places.
}

- (void) displayPrivacyTerms {
  [self performSegueWithIdentifier:ATGSegueIdPrivacyTerms sender:self];
}

- (void)presentInputView:(UIView *)pView forTextField:(UITextField *)pTextField {
  // Place newcomer input view onto the screen.
  UIView *container = [self view];
  [container addSubview:pView];
  // Set the autoresizing mask, so that the InputView would take proper place when device's orientation
  // is changed.
  [pView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
  UITableView *tableView = [self tableView];
  if ([self innerInputView]) {
    // There is an inner input view onscreen already, just replace it with the new one; no animations.
    [[self innerInputView] removeFromSuperview];
    [self setInnerInputView:pView];
    CGRect inputViewFrame = [pView frame];
    inputViewFrame.origin.y = [tableView frame].size.height;
    [pView setFrame:inputViewFrame];
  } else {
    // Otherwise we should do some animations. First, set an innerInputView reference,
    // it's required by the contentSizeForViewInPopover method.
    [self setInnerInputView:pView];
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    // Now we're ready to setup some animations on TableView and InputView.
    CGRect viewBounds = [container bounds];
    CGRect inputViewFrame = [pView frame];
    inputViewFrame.origin.y = viewBounds.size.height;
    [pView setFrame:inputViewFrame];
    [UIView animateWithDuration:.3
                     animations:^{
                       CGRect inputViewBounds = [pView bounds];
                       CGRect tableViewFrame = [tableView frame];
                       tableViewFrame.size.height = viewBounds.size.height - inputViewBounds.size.height;
                       [tableView setFrame:tableViewFrame];
                       
                       CGRect inputViewFrame = [pView frame];
                       inputViewFrame.origin.y = tableViewFrame.size.height;
                       [pView setFrame:inputViewFrame];
                     }
                     completion:^(BOOL pFinished) {
                       // When everything is set, just scroll the TableView to display
                       // the TextField being edited.
                       [tableView scrollRectToVisible:[tableView convertRect:[pTextField bounds]
                                                                    fromView:pTextField]
                                             animated:YES];
                     }];
  }
}

- (void)dismissInputView {
  // Preserve inner input view for future use, we're going to nil-out the reference.
  UIView *innerInputView = [self innerInputView];
  // Nil-out the reference. This is required, as ViewController's content size is calculated based
  // on this innerInputView reference.
  [self setInnerInputView:nil];
  [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  // Now we're ready to resize the TableView, it should take all the space available.
  UIView *container = [self view];
  UITableView *tableView = [self tableView];
  CGRect viewBounds = [container bounds];
  CGRect tableViewFrame = [tableView frame];
  tableViewFrame.size.height = viewBounds.size.height;
  [tableView setFrame:tableViewFrame];
  // Gracefully fade the inner input view.
  [UIView transitionWithView:container
                    duration:.3
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:^{
                    [innerInputView removeFromSuperview];
                  }
                  completion:NULL];
}

#pragma mark - ATGProfileManagerDelegate

- (void) didCreateNewUser:(ATGProfileManagerRequest *)pRequest {
  [self setRequest:[[ATGExternalProfileManager profileManager] getProfile:self]];
}

- (void) didErrorCreatingNewUser:(ATGProfileManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSString *errorText = [[[[pRequest error] userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY] firstObject];
  if ([errorText length] > 0) {
    [[self signupCell] setError:errorText];
    [self tableView:[self tableView] didSelectRowAtIndexPath:[[self tableView]
                                                              indexPathForCell:[self signupCell]]];
    [[self tableView] beginUpdates];
    [[self tableView] endUpdates];
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  } else {
    [self alertWithTitleOrNil:nil withMessageOrNil:[[pRequest error] localizedDescription]];
  }
}

- (void) didGetProfile:(ATGProfileManagerRequest *)pRequest {
  [self stopActivityIndication];
  [[ATGKeychainManager instance] setString:[(ATGProfile *)[pRequest requestResults] email]
                                    forKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
  [[ATGKeychainManager instance] setString:[(ATGProfile *)[pRequest requestResults] firstName]
                                    forKey:ATG_KEYCHAIN_NAME_PROPERTY];
  [[self iPadRootController] displayProfile];
}

- (void) didErrorGettingProfile:(ATGProfileManagerRequest *)pRequest {
  [self stopActivityIndication];
  [[self iPadRootController] displayProfile];
}

#pragma mark - Private Protocol Implementation

- (ATGRootViewController_iPad *) iPadRootController {
  return [ATGRootViewController_iPad rootViewController];
}

@end