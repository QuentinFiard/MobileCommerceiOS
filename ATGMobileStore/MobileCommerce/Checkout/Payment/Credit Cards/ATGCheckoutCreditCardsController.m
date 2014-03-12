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

#import "ATGCheckoutCreditCardsController.h"
#import <ATGMobileClient/ATGCreditCardTableViewCell.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>
#import "ATGCVVViewController.h"

static NSString *const ATGSegueMoveToOrderConfirmation = @"ATGCheckoutCreditCardsToOrderConfirmation";
static NSString *const ATGSegueReplaceWithCreateCard = @"ATGReplaceCreditCardsWithCreateCreditCard";

#pragma mark - ATGCheckoutCreditCardsController Private Protocol
#pragma mark -

@interface ATGCheckoutCreditCardsController () <ATGCommerceManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *commerceRequest;
@property (nonatomic, readwrite, assign) BOOL enforcesNewCard;

@end

#pragma mark - ATGCheckoutCreditCardsController Implementation
#pragma mark -

@implementation ATGCheckoutCreditCardsController

#pragma mark - Synthesized Properties

@synthesize userAnonymous, selection;
@synthesize commerceRequest;
@synthesize enforcesNewCard;

#pragma mark - UIViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:ATGSegueReplaceWithCreateCard]) {
    ATGCheckoutCreditCardCreateController *destination = [segue destinationViewController];
    [destination setUserAnonymous:[self userAnonymous]];
  } else if ([segue.identifier isEqualToString:ATGSegueIdCreditCardsToCreditCardCreate]) {
    ATGCheckoutCreditCardCreateController *ctrl = segue.destinationViewController;
    ctrl.userAnonymous = self.userAnonymous;
  } else if ([segue.identifier isEqualToString:ATGSegueIdCreditCardsToCVV]) {
    [[ATGCreditCardInfo cardInfo] setCardName:self.selection.nickname];
    ATGCVVViewController *destination = [segue destinationViewController];
    [destination setCard:[self selection]];
  } else {
    [super prepareForSegue:segue sender:sender];
  }
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self commerceRequest] setDelegate:nil];
  [[self commerceRequest] cancelRequest];
  [super viewWillDisappear:pAnimated];
}

- (void) viewDidAppear:(BOOL)pAnimated {
  [super viewDidAppear:pAnimated];
  [self setCommerceRequest:[[ATGCommerceManager commerceManager] applyStoreCreditsToOrderWithDelegate:self]];
}

#pragma mark - UITableViewController

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (![self isPad] && indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
    [self createNewCreditCard];
  } else {
    ATGCreditCardTableViewCell *cell =
        (ATGCreditCardTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [UIView transitionWithView:cell
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      [cell setCheckMarkHidden:NO];
                    }
                    completion:^(BOOL finished) {
                      [self performSegueWithIdentifier:ATGSegueIdCreditCardsToCVV sender:self];
                    }];
    self.selection = [self.cardsArray objectAtIndex:indexPath.row];
  }
}

- (void)tableView:(UITableView *)pTableView
  willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  if ([pCell isKindOfClass:[ATGCreditCardTableViewCell class]]) {
    [(ATGCreditCardTableViewCell *)pCell setCheckMarkHidden:YES];
  }
}

#pragma mark - Private methods

- (void) createNewCreditCard {
  [self startActivityIndication:YES];
  [self.request cancelRequest];
  self.request = [[ATGExternalProfileManager profileManager] getSecurityStatus:self];
}

#pragma mark - Profile Manager Delegate

- (void) didGetSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  if ([(NSNumber *)[pRequestResults requestResults]
       compare:[NSNumber numberWithInteger:3]] == NSOrderedDescending) {
    // The user is explicitly logged in.
    self.userAnonymous = NO;
  } else {
    // The user is not logged in yet.
    self.userAnonymous = YES;
  }
  if ([self enforcesNewCard]) {
    [self performSegueWithIdentifier:ATGSegueReplaceWithCreateCard sender:self];
  } else {
    [self performSegueWithIdentifier:ATGSegueIdCreditCardsToCreditCardCreate sender:self];
  }
}

- (void) didErrorGettingSecurityStatus:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequestResults.error localizedDescription]];
}

- (void) didGetCreditCards:(ATGProfileManagerRequest *)pRequestResults {
  // Noop, as we're retrieving credit cards with applyStoreCreditsToOrderWithDelegate: method.
  // Do not handle this message, this will prevent credit cards from being displayed until store credits
  // are applied to order.
}

- (void)didAppliedStoreCreditsToOrder:(ATGCommerceManagerRequest *)pRequest {
  if ([[pRequest requestResults] isKindOfClass:[NSNumber class]] &&
      [(NSNumber *)[pRequest requestResults] boolValue]) {
    // The whole order is payed for with store credits, so just move to the confirmation screen.
    [self performSegueWithIdentifier:ATGSegueMoveToOrderConfirmation sender:self];
  } else if ([[pRequest requestResults] count] == 0) {
    // No credit card exists for the current user. Push the 'New Card' screen.
    [self setEnforcesNewCard:YES];
    [self createNewCreditCard];
  } else {
    // There are some cards created. Just display them to the user.
    ATGProfileManagerRequest *request =
        [[ATGProfileManagerRequest alloc] initWithProfileManager:[ATGExternalProfileManager profileManager]];
    [request setRequestResults:[pRequest requestResults]];
    [super didGetCreditCards:request];
  }
}

- (void)didErrorAppliedStoreCreditsToOrder:(ATGCommerceManagerRequest *)pRequest {
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
}

@end