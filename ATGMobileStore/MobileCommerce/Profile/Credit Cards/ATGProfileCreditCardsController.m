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

#import "ATGProfileCreditCardsController.h"
#import <ATGMobileClient/ATGCreditCardTableViewCell.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import "ATGProfileCreditCardEditController.h"
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

static NSString *const ATGCellIdentifierCardInfo = @"ATGCardDetails";
static NSString *const ATGCellIdentifierNewCard = @"ATGNewCard";

#pragma mark - ATGProfileCreditCardsController Private Protocol
#pragma mark -

@interface ATGProfileCreditCardsController ()

#pragma mark - IB Outlets

// Save this IB outlet to a strong property, as it's not a part of controller's view hierarchy by default.
@property (nonatomic, readwrite, strong) IBOutlet UILabel *noCardsLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, readwrite, strong) NSMutableArray *cardCells;

@end

#pragma mark - ATGProfileCreditCardsController Implementation
#pragma mark -

@implementation ATGProfileCreditCardsController

#pragma mark - Synthesized Properties

@synthesize request;
@synthesize spinner;
@synthesize cardsArray;
@synthesize cardCells;
@synthesize noCardsLabel;

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  [[self view] setBackgroundColor:[UIColor tableBackgroundColor]];

  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGCreditCardViewController.CreditCardTitle", nil, [NSBundle mainBundle],
                      @"Credit Cards", @"Title to be displayed on the top of the 'Credit Cards' screen.");
  [self setTitle:title];

  UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [indicator setHidesWhenStopped:YES];
  CGRect bounds = [[self view] bounds];
  CGPoint center = CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) );
  [indicator setCenter:center];
  [indicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
   UIViewAutoresizingFlexibleTopMargin |
   UIViewAutoresizingFlexibleRightMargin |
   UIViewAutoresizingFlexibleBottomMargin];
  [[self tableView] setBackgroundView:indicator];
  [self setSpinner:indicator];

  if ([self isPad]) {
    NSString *label = NSLocalizedStringWithDefaultValue
                        (@"ATGProfileCreditCardsViewController.CreateCreditCardButton", nil, [NSBundle mainBundle], @"Create a New Credit Card",
                        @"Caption to be displayed on the button moving the user to the 'New Credit Card' screen.");
    NSString *hint = NSLocalizedStringWithDefaultValue
                       (@"ATGProfileCreditCardsViewController.CreateCreditCardButtonAccessibilityHint", nil, [NSBundle mainBundle],
                       @"Moves you to the 'New Card' screen.", @"Describes an action performed by the 'New Card' button.");
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:label style:UIBarButtonItemStyleBordered target:self action:@selector(createNewCreditCard)];
    button.accessibilityLabel = label;
    button.accessibilityHint = hint;
    button.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitStaticText;
    button.width = ATGPhoneScreenWidth;
    self.toolbarItems = [NSArray arrayWithObject:button];
  }
  title = NSLocalizedStringWithDefaultValue
      (@"ATGProfileCreditCardsController.NoCardsMessage",
       nil, [NSBundle mainBundle], @"You have no saved credit cards",
       @"Message to be displayed to user on the screen with list of credit cards, if no cards created yet.");
  [[self noCardsLabel] setText:title];
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    // remove extra padding in between header and first cell of table view
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
  }
}

- (void) viewDidUnload {
  [[self cardCells] removeAllObjects];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [[self spinner] startAnimating];
  [self setCardsArray:nil];
  [[self cardCells] removeAllObjects];
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [[self tableView] reloadData];
  [self setRequest:[[ATGExternalProfileManager profileManager] getCreditCards:self]];
  if ([self isPad]) {
    self.navigationController.toolbarHidden = NO;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([self isPad]) {
    self.navigationController.toolbarHidden = YES;
  }
}

- (CGSize) contentSizeForViewInPopover {
  return self.tableView.contentSize;
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([ATGSegueIdCreditCardsToCreditCardEdit isEqualToString:[pSegue identifier]]) {
    // We're about to present an Edit Card screen. So update it with a credit card to be edited.
    UIButton *button = (UIButton *)pSender;
    CGPoint location = [[self tableView] convertPoint:CGPointZero fromView:button];
    NSIndexPath *path = [[self tableView] indexPathForRowAtPoint:location];
    ATGCreditCard *card = [[self cardsArray] objectAtIndex:[path row]];
    ATGProfileCreditCardEditController *controller =
      (ATGProfileCreditCardEditController *)[pSegue destinationViewController];
    [controller setCreditCard:card];
  }
}

#pragma mark - Table view section

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // We're configuring UI with an IB, so don't forget to call super.
  if (pSection == 0) {
    if ([self cardsArray]) {
      return [self.cardsArray count] + ([self isPad] ? 0 : 1);
    } else {
      return 0;
    }
  } else {
    return [super tableView:pTableView numberOfRowsInSection:pSection];
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (![self isPad] && [pIndexPath row] == [[self cardsArray] count]) {
    UITableViewCell *newCardCell = [pTableView dequeueReusableCellWithIdentifier:ATGCellIdentifierNewCard];

    NSString *label = NSLocalizedStringWithDefaultValue
                        (@"ATGProfileCreditCardsViewController.CreateCreditCardButton", nil, [NSBundle mainBundle], @"Create a New Credit Card",
                        @"Caption to be displayed on the button moving the user to the 'New Credit Card' screen.");
    NSString *hint = NSLocalizedStringWithDefaultValue
                       (@"ATGProfileCreditCardsViewController.CreateCreditCardButtonAccessibilityHint", nil, [NSBundle mainBundle],
                       @"Moves you to the 'New Card' screen.", @"Describes an action performed by the 'New Card' button.");
    [newCardCell setAccessibilityHint:hint];
    newCardCell.accessibilityTraits = UIAccessibilityTraitStaticText | UIAccessibilityTraitButton;
    [[newCardCell textLabel] setText:label];
    return newCardCell;
  }

  ATGCreditCardTableViewCell *cell = [[self cardCells] objectAtIndex:[pIndexPath row]];
  ATGCreditCard *card = [[self cardsArray] objectAtIndex:[pIndexPath row]];
  [cell setCreditCard:card];

  return cell;
}

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (![self isPad] && [pIndexPath row] == [[self cardsArray] count]) {
    return 45;
  } else {
    CGSize size = [[self        tableView:pTableView
                    cellForRowAtIndexPath:pIndexPath] sizeThatFits:[pTableView bounds].size];
    return size.height;
  }
}

#pragma mark - Private methods

- (void) createNewCreditCard {
  [self performSegueWithIdentifier:ATGSegueIdCreditCardsToCreditCardCreate sender:self];
}

#pragma mark - Profile Manager Delegate

- (void) didGetCreditCards:(ATGProfileManagerRequest *)pRequestResults {
  [[self spinner] stopAnimating];
  [self setCardsArray:[pRequestResults requestResults]];
  if ([[self cardsArray] count] > 0) {
    // Display cell borders only if there are some cells to be displayed.
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  }
  [self setCardCells:[[NSMutableArray alloc] initWithCapacity:[[self cardsArray] count]]];
  for (NSInteger row = 0; row < [[self cardsArray] count]; row++) {
    [[self cardCells] addObject:[[self tableView]
                                 dequeueReusableCellWithIdentifier:ATGCellIdentifierCardInfo]];
  }
  [CATransaction begin];
  [self.tableView beginUpdates];
  [CATransaction setCompletionBlock: ^{
    // Code to be executed upon completion
    if ([self isPad]) {
      NSLog(@"Completion");
      [self.tableView reloadData];
      [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
      NSLog(@"Completion");
    }
  }];
  [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationRight];
  [self.tableView endUpdates];
  [CATransaction commit];
  
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
    // On iPad we should display a note to the user, if there are no credit cards saved.
    if ([[self cardsArray] count] == 0) {
      [[self noCardsLabel] setFrame:[[self tableView] bounds]];
      [[self tableView] setBackgroundView:[self noCardsLabel]];
    }
  }
}

- (void) didErrorGettingCreditCards:(ATGProfileManagerRequest *)pRequestResults {
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  [[self spinner] stopAnimating];
}

@end