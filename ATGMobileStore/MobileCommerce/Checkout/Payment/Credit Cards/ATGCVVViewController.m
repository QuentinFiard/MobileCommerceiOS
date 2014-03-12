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
#import "ATGCVVViewController.h"
#import "ATGOrderReviewViewController.h"
#import "ATGCreditCardInfo.h"
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGUIElements/ATGButton.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import "ATGTabBarController.h"

CGFloat const ATGCVVScreenHeight = 202;
static NSString  *const ATGSessionExpirationError = @"Your session expired since this form was displayed - please try again.";
static NSString *const ATGCVVToOrderReviewSegue = @"cvvToOrderReview";

#pragma mark - ATGCVVViewController Private Protocol
#pragma mark -

@interface ATGCVVViewController () <UITextFieldDelegate, ATGCommerceManagerDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UITextField *cvvField;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *hintLabel;
@property (nonatomic, readwrite, weak) IBOutlet ATGButton *continueButton;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *cardType;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *cardImage;
@property (nonatomic, readwrite, weak) IBOutlet UIScrollView *scrollView;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) UIBarButtonItem *continueBarButton;
@property (nonatomic, readwrite, strong) ATGManagerRequest *request;

#pragma mark - Private Protocol Definition

- (NSString *)lastNumbersOfCardNumber:(NSString *)pNumber;
- (IBAction)buttonPressed;

@end

#pragma mark - ATGCVVViewController Implementation
#pragma mark -

@implementation ATGCVVViewController

#pragma mark - Synthesized Properties

@synthesize type, card, continueBarButton;
@synthesize cvvField;
@synthesize hintLabel;
@synthesize continueButton;
@synthesize cardType;
@synthesize cardImage;
@synthesize scrollView;
@synthesize request;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [[self continueButton] setHidden:YES];
  [[self continueButton] applyStyleWithName:@"blueButton"];
  [self setTitle:NSLocalizedStringWithDefaultValue
      (@"ATGCVVViewController.CSV", nil,
       [NSBundle mainBundle], @"CSV Code",
       @"CSV code of credit card.")];
  [[self cvvField] setPlaceholder:NSLocalizedStringWithDefaultValue
      (@"ATGCVVViewController.CSV", nil,
       [NSBundle mainBundle], @"CSV Code",
       @"CSV code of credit card.")];
  
  [[self cardType] applyStyleWithName:@"headerLabel"];

  if ([[self card].creditCardType isEqualToString:ATGAmexCard]) {
    [self cardImage].image = [UIImage imageNamed:ATGAmexImageName];
  } else {
    [self cardImage].image = [UIImage imageNamed:ATGOtherCardImageName];
  }

  if ([self card].maskedCreditCardNumber != NULL) {
    [self cardType].text = [NSString stringWithFormat:@"%@ ...%@",
                    [self.card creditCardTypeDisplayName], [self card].maskedCreditCardNumber];
  } else if ([self card].creditCardNumber != nil)   {
    [self cardType].text = [NSString stringWithFormat:@"%@ ...%@",
                    [self.card creditCardTypeDisplayName],
                    [self lastNumbersOfCardNumber:[self card].creditCardNumber]];
  }

  [self hintLabel].text = NSLocalizedStringWithDefaultValue
      (@"ATGCVVViewController.CardHintLabel", nil,
       [NSBundle mainBundle], @"Look for last three numbers in the signature panel on the back of your card",
       @"Hint for cvv code of credit card.");
  [[self hintLabel] applyStyleWithName:@"cvvLabel"];
  
  [self cvvField].layer.masksToBounds = NO;
  [self cvvField].layer.shadowColor = [UIColor cvvShadowColor].CGColor;
  [self cvvField].layer.shadowOpacity = 0.9;
  [self cvvField].layer.shadowRadius = 13;
  [[self cvvField] setReturnKeyType:UIReturnKeyGo];
  self.cvvField.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGCVVViewController.Accessibility.Hint.For.CVV.Field", nil,
                                                                      [NSBundle mainBundle], @"Please Enter CVV", @"Accessibility hint for the CVV input field");

  ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:nil];
  [[self cvvField] setInputAccessoryView:toolbar];

  CGRect imageFrame = [[self cardImage] frame];
  CGRect viewFrame = [[self view] frame];
  CGSize content = CGSizeMake(viewFrame.size.width,
                              imageFrame.origin.y + imageFrame.size.height + 10);
  [self scrollView].backgroundColor = [UIColor tableBackgroundColor];
  [[self scrollView] setContentSize:content];


  // Make sure cvv input appears at top of screen and is not covered by keyboard
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && !IS_IPAD){
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.view.frame.origin.y,
        self.scrollView.frame.size.width, self.scrollView.frame.size.height);
  }

  [self startActivityIndication:YES];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  [self addKeyboardNotificationsObserver];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [self removeKeyboardNotificationsObserver];
  [super viewWillDisappear:pAnimated];
}

- (CGSize)contentSizeForViewInPopover {
  return CGSizeMake(ATGPhoneScreenWidth,  ATGCVVScreenHeight);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [pTextField resignFirstResponder];
  [self buttonPressed];
  return YES;
}

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  NSUInteger currentLength = [[pTextField text] length];
  NSUInteger newLength = currentLength + [pString length] - pRange.length;
  [[self continueButton] setHidden:newLength == 0];
  self.continueBarButton.enabled = newLength > 0;
  CGRect buttonFrame = [[self continueButton] frame];
  CGRect imageFrame = [[self cardImage] frame];
  CGFloat heightDelta = buttonFrame.origin.y + buttonFrame.size.height -
                        imageFrame.origin.y - imageFrame.size.height;
  CGSize content = [[self scrollView] contentSize];
  if (newLength == 0) {
    content.height -= heightDelta;
  } else if (currentLength == 0) {
    content.height += heightDelta;
  }
  [[self scrollView] setContentSize:content];
  if (newLength > 4) {
    return NO;
  } else {
    return YES;
  }
}

- (NSString *)lastNumbersOfCardNumber:(NSString *)pNumber {
  return [pNumber substringFromIndex:[pNumber length] - 4];
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didBillToSavedCard:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self performSegueWithIdentifier:ATGCVVToOrderReviewSegue sender:self];
  [self setRequest:nil];
}

- (void)didErrorBillingToSavedCard:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  id pException = [[pRequest.error userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY];
  NSString *message = [pException objectAtIndex:0];
  if ([message isEqualToString:ATGSessionExpirationError]) {
    message = NSLocalizedStringWithDefaultValue(@"ATGCVVViewController.SessionExpiredErrorMessare",
    nil, [NSBundle mainBundle], @"Your session expired since this form was displayed - Please try Again",
    @"Message is shown to the user when their session has expired while viewing the CVV page");
    [(ATGTabBarController *)self.tabBarController switchToCartScreen];
  }

  [self alertWithTitleOrNil:nil withMessageOrNil:message];
  [self setRequest:nil];
}

- (void)didBillToSavedAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self performSegueWithIdentifier:ATGCVVToOrderReviewSegue sender:self];
  [self setRequest:nil];
}

- (void)didErrorBillingToSavedAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  id pException = [[pRequest.error userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY];
  NSString *message = [pException objectAtIndex:0];
  if ([message isEqualToString:ATGSessionExpirationError]) {
    [(ATGTabBarController *)self.tabBarController switchToCartScreen];
  }

  message = NSLocalizedStringWithDefaultValue(@"ATGCVVViewController.SessionExpiredErrorMessare",
    nil, [NSBundle mainBundle], @"Your session expired since this form was displayed - Please try Again",
    @"Message is shown to the user when their session has expired while viewing the CVV page");

  [self alertWithTitleOrNil:nil withMessageOrNil:message];
  [self setRequest:nil];
}

- (void)didBillToNewAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self performSegueWithIdentifier:ATGCVVToOrderReviewSegue sender:self];
  [self setRequest:nil];
}

- (void)didErrorCreateBillingAddress:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  id pException = [[pRequest.error userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY];
  NSString *message = [pException objectAtIndex:0];
  if ([message isEqualToString:ATGSessionExpirationError]) {
    [(ATGTabBarController *)self.tabBarController switchToCartScreen];
  }

  message = NSLocalizedStringWithDefaultValue(@"ATGCVVViewController.SessionExpiredErrorMessare",
    nil, [NSBundle mainBundle], @"Your session expired since this form was displayed - Please try Again",
    @"Message is shown to the user when their session has expired while viewing the CVV page");

  [self alertWithTitleOrNil:nil withMessageOrNil:message];
  [self setRequest:nil];
}

#pragma mark - Private Protocol Implementation

- (IBAction)buttonPressed {
  [request cancelRequest];
  [self startActivityIndication:YES];
  
  if ([self type] == ValidateFromSelectCard) {
    [self setRequest:[[ATGCommerceManager commerceManager]
                      billToSavedCard:[[ATGCreditCardInfo cardInfo] cardName]
                      verificationNumber:[self cvvField].text delegate:self]];
  } else if ([self type] == ValidateFromEditAddr)   {
    [self setRequest:[[ATGCommerceManager commerceManager]
                      billToSavedAddress:[[ATGCreditCardInfo cardInfo] billAddrName]
                      verificationNumber:[self cvvField].text delegate:self]];
  } else if ([self type] == ValidateFromCreateAddr)   {
    [self setRequest:[[ATGCommerceManager commerceManager]
                      billToNewAddressWithVerificationNumber:[self cvvField].text delegate:self]];
  }
}

- (void)keyboardWillShow:(NSNotification *)pNotification {
  [super keyboardWillShow:pNotification];

  NSValue *rectValue = [[pNotification userInfo]
                        objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect keyboardFrame = [rectValue CGRectValue];
  keyboardFrame = [[self view] convertRect:keyboardFrame fromView:nil];
  NSNumber *duration = [[pNotification userInfo]
                        objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue]
                   animations:^{
     CGRect frame = [[self scrollView] frame];
     frame.size.height = keyboardFrame.origin.y;
     [[self scrollView] setFrame:frame];
  }];
}

- (void)keyboardWillHide:(NSNotification *)pNotification {
  [super keyboardWillHide:pNotification];
  NSNumber *duration = [[pNotification userInfo]
                        objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  [UIView animateWithDuration:[duration doubleValue]
                   animations:^{
     [[self scrollView] setFrame:[[self view] frame]];
  }];
}

@end