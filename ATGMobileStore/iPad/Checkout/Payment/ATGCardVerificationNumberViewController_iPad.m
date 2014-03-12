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

#import "ATGCardVerificationNumberViewController_iPad.h"
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGMobileClient/ATGCommerceManager.h>
#import <ATGMobileClient/ATGCreditCard.h>
#import <ATGMobileClient/ATGCommerceManagerRequest.h>
#import "ATGCreditCardInfo.h"

static NSString *const ATGSegueIdConfirmationNumberToOrderReivew = @"cvvToOrderReview";

#pragma mark - ATGCardVerificationNumberViewController_iPad Private Protocol
#pragma mark -

@interface ATGCardVerificationNumberViewController_iPad () <ATGCommerceManagerDelegate, UITextFieldDelegate>

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UIImageView *underlayImageView;
@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *cvvInputField;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *confirmButton;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *hintLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIView *inputContainer;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *request;

#pragma mark - UI Event Handlers

- (IBAction)didTouchConfirmButton:(UIButton *)button;

#pragma mark - Private Protocol Definition

- (void)handleSuccessfulRequest:(ATGCommerceManagerRequest *)request;
- (void)handleFailedRequest:(ATGCommerceManagerRequest *)request;

@end

#pragma mark - ATGCardVerificationNumberViewController_iPad Implementation
#pragma mark -

@implementation ATGCardVerificationNumberViewController_iPad

#pragma mark - Synthesized Properties

@synthesize card;
@synthesize type;
@synthesize underlayImageView;
@synthesize cvvInputField;
@synthesize confirmButton;
@synthesize hintLabel;
@synthesize placeholderLabel;
@synthesize request;
@synthesize inputContainer;

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *placeholder = NSLocalizedStringWithDefaultValue
      (@"ATGCardVerificationNumberViewController_iPad.SecurityCodePlaceholder",
       nil, [NSBundle mainBundle], @"Security Code",
       @"Placeholder to be displayed within the security code input field "
       @"on the CVV checkout screen on iPad.");
  [[self placeholderLabel] setText:placeholder];
  NSString *hint = NSLocalizedStringWithDefaultValue
      (@"ATGCardVerificationNumberViewController_iPad.ScreenBottomHint",
       nil, [NSBundle mainBundle],
       @"The security code should be on the back of your card, at the end of the signature strip.",
       @"Hint to be displayed at the bottom of the CVV checkout screen on iPad.");
  [[self hintLabel] setText:hint];
  [[self cvvInputField] setLeftView:[self placeholderLabel]];
  [[self cvvInputField] setLeftViewMode:UITextFieldViewModeAlways];
  [[[self inputContainer] layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
  [[[self inputContainer] layer] setBorderWidth:1];
  [[[self inputContainer] layer] setCornerRadius:8];
  [[self inputContainer] setClipsToBounds:YES];
  [[self confirmButton] setAccessibilityLabel:NSLocalizedStringWithDefaultValue
      (@"ATGCardVerificationNumberViewController_iPad.Accessibility.Label.ConfirmationButton",
       nil, [NSBundle mainBundle], @"Confirm",
       @"Accessibility label to be applied to the action button on the CVV checkout screen on iPad.")];
  [[self confirmButton] setAccessibilityHint:NSLocalizedStringWithDefaultValue
      (@"ATGCardVerificationNumberViewController_iPad.Accessibility.Hint.ConfirmationButton",
       nil, [NSBundle mainBundle],
       @"Double tap to confirm the verification number and proceed to order review.",
       @"Accessibility hint to be applied to the action button on the CVV checkout screen on iPad.")];
  [[self inputContainer] setAccessibilityLabel:NSLocalizedStringWithDefaultValue(@"ATGCardVerificationNumberViewController_iPad.Accessibility.Hint.For.CVV.Field", nil,
                                                                                [NSBundle mainBundle], @"Please Enter CVV", @"Accessibility hint for the CVV input field")];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  NSString *lastDigits = [[self card] maskedCreditCardNumber];
  if (lastDigits == nil) {
    lastDigits = [[self card] creditCardNumber];
    lastDigits = [lastDigits substringFromIndex:[lastDigits length] - 4];
  }
  [self setTitle:[NSString stringWithFormat:@"%@ ...%@", [self.card creditCardTypeDisplayName], lastDigits]];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat margin = [[self underlayImageView] frame].origin.y;
  CGSize maxSize = [[self hintLabel] bounds].size;
  maxSize.height = CGFLOAT_MAX;
  CGSize hintSize = [[[self hintLabel] text] sizeWithFont:[[self hintLabel] font]
                                        constrainedToSize:maxSize
                                            lineBreakMode:[[self hintLabel] lineBreakMode]];
  return CGSizeMake([[self hintLabel] bounds].size.width + 2 *margin,
                    [[self hintLabel] frame].origin.y + hintSize.height + margin);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  [pTextField resignFirstResponder];
  [self didTouchConfirmButton:nil];
  return YES;
}

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  return [[pTextField text] length] + [pString length] - pRange.length <= 4;
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didBillToSavedCard:(ATGCommerceManagerRequest *)pRequest {
  [self handleSuccessfulRequest:pRequest];
}

- (void)didErrorBillingToSavedCard:(ATGCommerceManagerRequest *)pRequest {
  [self handleFailedRequest:pRequest];
}

- (void)didBillToSavedAddress:(ATGCommerceManagerRequest *)pRequest {
  [self handleSuccessfulRequest:pRequest];
}

- (void)didErrorBillingToSavedAddress:(ATGCommerceManagerRequest *)pRequest {
  [self handleFailedRequest:pRequest];
}

- (void)didBillToNewAddress:(ATGCommerceManagerRequest *)pRequest {
  [self handleSuccessfulRequest:pRequest];
}

- (void)didErrorBillingToNewAddress:(ATGCommerceManagerRequest *)pRequest {
  [self handleFailedRequest:request];
}

#pragma mark - Private Protocol Implementation

- (void)didTouchConfirmButton:(UIButton *)pButton {
  if ([[self cvvInputField] validate]) {
    [[self request] setDelegate:nil];
    [[self request] cancelRequest];
    [self startActivityIndication:YES];
    switch ([self type]) {
      case ValidateFromSelectCard:
        [self setRequest:[[ATGCommerceManager commerceManager]
                          billToSavedCard:[[ATGCreditCardInfo cardInfo] cardName]
                          verificationNumber:[[self cvvInputField] text]
                          delegate:self]];
        break;
      case ValidateFromEditAddr:
        [self setRequest:[[ATGCommerceManager commerceManager]
                          billToSavedAddress:[[ATGCreditCardInfo cardInfo] billAddrName]
                          verificationNumber:[[self cvvInputField] text]
                          delegate:self]];
        break;
      case ValidateFromCreateAddr:
        [self setRequest:[[ATGCommerceManager commerceManager]
                          billToNewAddressWithVerificationNumber:[[self cvvInputField] text]
                          delegate:self]];
    }
  }
}

- (void)handleSuccessfulRequest:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self performSegueWithIdentifier:ATGSegueIdConfirmationNumberToOrderReivew sender:self];
}

- (void)handleFailedRequest:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSString *message = [[[[pRequest error] userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY] lastObject];
  [self alertWithTitleOrNil:nil withMessageOrNil:message];
}

@end
