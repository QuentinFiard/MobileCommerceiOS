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

#import "ATGKeyboardToolbar.h"

#pragma mark - ATGKeyboardToolbar Private Protocol Definition
#pragma mark -

@interface ATGKeyboardToolbar ()

#pragma mark - Custom properties
@property (nonatomic, weak) id <ATGKeyboardToolbarDelegate> kbDelegate;
@property (nonatomic, strong) UISegmentedControl *navigationControl;
@property (nonatomic, strong) UITextField *currentField;

// This callback will be called when the user touches Previous/Next button.
- (void) didTouchNavigateButton:(UISegmentedControl *)sender;
// This callback will be called when the user touches Done button.
- (void) didTouchDoneButton;
// This callback will be called when the user begins editing some text field.
- (void) didBeginEditingTextField:(NSNotification *)notification;

@end

#pragma mark - ATGKeyboardToolbar Implementation
#pragma mark -

@implementation ATGKeyboardToolbar

#pragma mark - Instance Management

- (id) initWithDelegate:(id <ATGKeyboardToolbarDelegate>)pDelegate {
  self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
  if (self) {
    [self setBarStyle:UIBarStyleBlack];
    [self setTranslucent:YES];

    self.kbDelegate = pDelegate;

    UIBarButtonItem *space =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil action:NULL];
    NSString *next = NSLocalizedStringWithDefaultValue
        (@"ATGKeyboardToolbar.NextButtonTitle",
         nil, [NSBundle mainBundle], @"Next",
         @"Title to be used by the Next button.");
    NSString *previous = NSLocalizedStringWithDefaultValue
        (@"ATGKeyboardToolbar.PreviousButtonTitle",
         nil, [NSBundle mainBundle], @"Previous",
         @"Title to be used by the Previous button.");
    // Implement Previous/Next buttons as a segmented control to make them look like a single control.
    self.navigationControl =
      [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:previous, next, nil]];
    [[self navigationControl] setSegmentedControlStyle:UISegmentedControlStyleBar];
    [[self navigationControl] setMomentary:YES];
    [[self navigationControl] addTarget:self action:@selector(didTouchNavigateButton:)
                 forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *navigationItem =
      [[UIBarButtonItem alloc] initWithCustomView:[self navigationControl]];
    UIBarButtonItem *doneItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                    target:self action:@selector(didTouchDoneButton)];
    [self setItems:[NSArray arrayWithObjects:navigationItem, space, doneItem, nil]];
    // Listen for the DidBeginEditing notification, it's important for the toolbar to know
    // which input field is active now.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBeginEditingTextField:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];
  // No need to check, if delegate implements these methods as they are required.
  [[self navigationControl] setEnabled:[[self kbDelegate] hasPreviousInputForTextField:self.currentField]
               forSegmentAtIndex:0];
  [[self navigationControl] setEnabled:[[self kbDelegate] hasNextInputForTextField:self.currentField]
               forSegmentAtIndex:1];
}

#pragma mark - ATGKeyboardToolbar Private Protocol Implementation

- (void) didTouchNavigateButton:(UISegmentedControl *)pSender {
  switch ([pSender selectedSegmentIndex]) {
  case 0:
    // No need to check if delegate implements methods, as they are required.
    [[self kbDelegate] activatePreviousInputForTextField:self.currentField];
    break;

  default:
    [[self kbDelegate] activateNextInputForTextField:self.currentField];
    break;
  }
}

- (void) didTouchDoneButton {
  // Done button just hides the keyboard.
  if ([self.currentField isFirstResponder] && [self.currentField canResignFirstResponder]) {
    [self.currentField resignFirstResponder];
  }
}

- (void) didBeginEditingTextField:(NSNotification *)pNotification {
  // Notification object is a text field sent the notification.
  UITextField *sender = (UITextField *)[pNotification object];
  if ([sender inputAccessoryView] == self) {
    // Input field's accessory view is current toolbar instance;
    // hence input field's form is managed by the current toolbar instance.
    // Remember currently active text field.
    self.currentField = sender;
    [self setNeedsLayout];
  } else {
    // Currently editing input field is managed by another toolbar instance.
    self.currentField = nil;
  }
}

@end