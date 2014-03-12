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

#import "ATGForgotPasswordViewController.h"
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGButton.h>
#import "ATGLoginViewController.h"
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGMobileClient/ATGProfileManagerRequest.h>
#import <ATGMobileClient/ATGProfileManagerDelegate.h>
#import <ATGMobileClient/ATGExternalProfileManager.h>

static const CGFloat ATGSideInsets = 10;
static const CGFloat ATGTopInsets = 10;
static const CGFloat ATGInnerInsets = 10;
static const CGFloat ATGInputHeight = 44;
static const CGFloat ATGInputCornerRadius = 8;
static const CGFloat ATGScreenWidth = 320;

#pragma mark - ATGForgotPasswordViewController Private Protocol
#pragma mark -

@interface ATGForgotPasswordViewController () <UITextFieldDelegate, ATGProfileManagerDelegate>

#pragma mark - UI Elements

@property (nonatomic, readwrite, weak) ATGValidatableInput *inputEmail;
@property (nonatomic, readwrite, weak) UILabel *captionLabel;
@property (nonatomic, readwrite, weak) UIButton *actionButton;
@property (nonatomic, readwrite, weak) UIImageView *underlayImage;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProfileManagerRequest *request;

#pragma mark - UI Event Handlers

- (void)didTouchSendButton:(id)sender;
- (void)didTouchBackButton:(id)sender;

@end

#pragma mark - ATGForgotPasswordViewController Implementation
#pragma mark -

@implementation ATGForgotPasswordViewController

#pragma mark - Synthesized Properties

@synthesize email = mEmail;
@synthesize inputEmail;
@synthesize captionLabel;
@synthesize actionButton;
@synthesize underlayImage;
@synthesize request;

#pragma mark - UIViewController

- (void)loadView {
  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
  CGRect windowBounds = [window bounds];

  // Top-level view.
  UIView *root = [[UIView alloc] initWithFrame:windowBounds];
  [root setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  root.backgroundColor = [UIColor tableCellBackgroundColor];

  // Configure the description label.
  // No need to specify element's frame, as we'll update it later with |viewWillLayoutSubviews| method.
  UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  [descriptionLabel applyStyleWithName:@"actionConfirmationLabel"];
  NSString *description = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.DescriptionText", nil, [NSBundle mainBundle],
       @"No problem. Just enter your email address below, and we'll send you a temporary password instantly.",
       @"Description to be displayed on the screen.");
  [descriptionLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [descriptionLabel setText:description];
  [descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [descriptionLabel setNumberOfLines:0];
  [root addSubview:descriptionLabel];
  [self setCaptionLabel:descriptionLabel];

  // Configure the email input field.
  ATGValidatableInput *input = [[ATGValidatableInput alloc] initWithFrame:CGRectZero];
  [input setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  NSString *placeholder = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.InputPlaceholderText", nil,
       [NSBundle mainBundle], @"Email address",
       @"Placeholder to be displayed inside the email input.");
  [input setPlaceholder:placeholder];
  [input setDelegate:self];
  [input applyStyle:ATGTextFieldFormText];
  [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [input setAutocorrectionType:UITextAutocorrectionTypeNo];
  [input setKeyboardType:UIKeyboardTypeEmailAddress];
  [input setAccessibilityLabel:placeholder];
  [input setReturnKeyType:UIReturnKeyGo];
  [input setErrorWidthFraction:.5];
  ATGEmailValidator *validator = [[ATGEmailValidator alloc] init];
  [input addValidator:validator];
  [[input layer] setCornerRadius:ATGInputCornerRadius];
  [[input layer] setBorderColor:[[UIColor borderColor] CGColor]];
  [[input layer] setBorderWidth:1];
  [root addSubview:input];
  [self setInputEmail:input];

  if (![self isPad]) {
    ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:nil];
    [input setInputAccessoryView:toolbar];
  }

  // Configure the Send button.
  UIButton *button = [[ATGButton alloc] initWithFrame:CGRectZero];
  [button applyStyleWithName:@"blueButton"];
  [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.ButtonTitle", nil, [NSBundle mainBundle],
       @"Send", @"Title to be displayed on the Send button.");
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:@selector(didTouchSendButton:)
   forControlEvents:UIControlEventTouchUpInside];
  NSString *label = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.ButtonAccessibilityLabel", nil,
       [NSBundle mainBundle], @"Send",
       @"Accessibility label to be used by the Send button.");
  [button setAccessibilityLabel:label];
  NSString *hint = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.ButtonAccessibilityHint", nil,
       [NSBundle mainBundle], @"Sends you a new password.",
       @"Accessibility hint to be used by the Send button.");
  [button setAccessibilityHint:hint];
  [root addSubview:button];
  [self setActionButton:button];

  UIImage *underlay = [UIImage imageNamed:@"table-underlay"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:underlay];
  CGRect imageFrame = CGRectMake(0, 0, windowBounds.size.width, [underlay size].height);
  [imageView setFrame:imageFrame];
  [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
  [root insertSubview:imageView belowSubview:button];
  [self setUnderlayImage:imageView];

  [self setView:root];
}

- (void)viewWillLayoutSubviews {
  CGSize maxSize = CGSizeMake([[self view] bounds].size.width - ATGSideInsets * 2, CGFLOAT_MAX);
  NSString *description = [[self captionLabel] text];
  CGSize descriptionSize = [description sizeWithFont:[[self captionLabel] font]
                                   constrainedToSize:maxSize
                                       lineBreakMode:NSLineBreakByWordWrapping];
  CGRect descriptionFrame = CGRectMake(ATGSideInsets, ATGTopInsets,
                                       maxSize.width, descriptionSize.height);
  [[self captionLabel] setFrame:descriptionFrame];

  CGRect inputFrame = CGRectMake(ATGSideInsets, descriptionFrame.origin.y +
                                 descriptionFrame.size.height + ATGInnerInsets,
                                 maxSize.width, ATGInputHeight);
  [[self inputEmail] setFrame:inputFrame];

  CGPoint center = CGPointMake(ATGSideInsets + maxSize.width / 2,
                               inputFrame.origin.y + inputFrame.size.height +
                               ATGInnerInsets + [[self actionButton] bounds].size.height / 2);
  [[self actionButton] setCenter:center];

  center = CGPointMake(center.x, center.y - 10);
  [[self underlayImage] setCenter:center];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Fill input field with default value.
  [[self inputEmail] setText:mEmail];
  // Set proper screen title.
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.ScreenTitle", nil, [NSBundle mainBundle],
       @"Forgot Password?", @"Screen title to be used.");
  [self setTitle:title];
  // Update 'back' button, it should pop a controller from current navigation controller,
  // not from shared instance created by ATGViewController.
  [(UIButton *)[[[self navigationItem] leftBarButtonItem] customView]
       removeTarget:nil action:NULL
   forControlEvents:UIControlEventTouchUpInside];
  [(UIButton *)[[[self navigationItem] leftBarButtonItem] customView]
          addTarget:self action:@selector(didTouchBackButton:)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [super viewWillDisappear:pAnimated];
  [[self request] setDelegate:nil];
  [[self request] cancelRequest];
  [self setRequest:nil];
}

- (CGSize)contentSizeForViewInPopover {
  CGRect buttonFrame = [[self actionButton] frame];
  return CGSizeMake(ATGScreenWidth, buttonFrame.origin.y + buttonFrame.size.height + ATGTopInsets);
}

#pragma mark - UIViewController

- (void) setToolbarItems:(NSArray *)pToolbarItems animated:(BOOL)pAnimated {
  // Do not accept any toolbar items. Or it will ruin ATG toolbar forever.
  [super setToolbarItems:nil animated:pAnimated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)pTextField shouldChangeCharactersInRange:(NSRange)pRange
replacementString:(NSString *)pString {
  NSUInteger finalLength = [[pTextField text] length];
  finalLength += [pString length];
  finalLength -= pRange.length;
  return finalLength <= 40;
}

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  // This method is called from validatable input only.
  [self didTouchSendButton:nil];
  return YES;
}

#pragma mark - ATGProfileManagerDelegate

- (void)didResetPassword:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  // Do not display 'Forgot Password?' message on the Login screen anymore.
  NSArray *controllers = [[self navigationController] viewControllers];
  ATGLoginViewController *prevController = [controllers objectAtIndex:[controllers count] - 2];
  [prevController setDisplayForgotPassword:NO];
  [prevController setDisplayPasswordSent:YES];
  // Drop self from navigation stack.
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didErrorResettingPassword:(ATGProfileManagerRequest *)pRequestResults {
  [self stopActivityIndication];
  NSString *error = NSLocalizedStringWithDefaultValue
      (@"ATGForgotPasswordViewController.ErrorResettingPassword.Message", nil,
       [NSBundle mainBundle], @"Unknown email\n Try again",
       @"Error message to be displayed when unable to reset password.");
  [[self inputEmail] invalidate:error];
  [[self inputEmail] setNeedsLayout];
}

#pragma mark - UI Events Handling

- (void)didTouchSendButton:(id)pSender {
  if ([[self inputEmail] validate]) {
    [self startActivityIndication:YES];
    // Send new password only if correct email specified.
    [[self request] setDelegate:nil];
    [[self request] cancelRequest];
    [self setRequest:[[ATGExternalProfileManager profileManager] resetPassword:[[self inputEmail] text]
                                                              delegate:self]];
  }
}

- (void)didTouchBackButton:(id)pSender {
  [[self navigationController] popViewControllerAnimated:YES];
}

@end
