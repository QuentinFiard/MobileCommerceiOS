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

#import "ATGEmailMeView.h"
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>

#pragma mark - ATGEmailMeView private interface declaration
#pragma mark -
@interface ATGEmailMeView ()

#pragma mark - Custom properties
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ATGProductManagerRequest *request;

#pragma mark - IB Outlets
@property (nonatomic, weak) IBOutlet UIButton *helpButton;
@property (nonatomic, strong) IBOutlet UITableViewCell *mailCell;
@property (nonatomic, weak) IBOutlet ATGValidatableInput *email;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *confirmationLabel;
@end

#pragma mark - ATGEmailMeView implementation
#pragma mark -

@implementation ATGEmailMeView
#pragma mark - Synthesized Properties
@synthesize mailCell, productId, skuId, delegate, helpButton;
@synthesize table, request, email, emailLabel, confirmationLabel;

#pragma mark - UIView
- (id) initWithFrame:(CGRect)pFrame {
  self = [super initWithFrame:pFrame];
  if (self) {
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, pFrame.size.width, pFrame.size.height) style:UITableViewStylePlain];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.scrollEnabled = NO;
    self.table.layer.cornerRadius = 10;
    self.table.layer.borderWidth = 1.0f;
    self.table.layer.shadowOpacity = 0.5;
    self.table.backgroundColor = [UIColor tableBackgroundColor];
    [self addSubview:self.table];
  }
  return self;
}

- (IBAction) didTouchHelpButton:(id)pSender {
  [self.delegate didSelectHelp];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // Return the number of rows in the section.
  return 2;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if (pIndexPath.row == 0) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.contentView.backgroundColor = [UIColor emailMeBackgroundColor];
    cell.textLabel.backgroundColor = [UIColor emailMeBackgroundColor];
    cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGEmailMeView.Message", nil, [NSBundle mainBundle], @"When it's in stock, please let me know", @"Email me message");
    cell.textLabel.textColor = [UIColor emailMeTextColor];
    cell.textLabel.font = [UIFont emailMeFont];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
  }

  NSString *cellIdentifier = @"EmailCell";

  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:cellIdentifier];

  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ATGEmailCell" owner:self options:nil];
    cell = self.mailCell;
    //add cell background view to get validatable view working on plain style table cell
    cell.backgroundView = [[UIView alloc] init];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    ATGEmailValidator *validator = [[ATGEmailValidator alloc] init];
    [self.email addValidator:validator];
    [self.email setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.email setReturnKeyType:UIReturnKeyGo];
    [self.email setDelegate:self];
    [self.email applyStyle:ATGTextFieldFormText];
    [self.email becomeFirstResponder];
    self.emailLabel.text = NSLocalizedStringWithDefaultValue(@"ATGEmailMeView.Label", nil, [NSBundle mainBundle], @"email", @"email message for prefix");
    self.mailCell = nil;

    ATGKeyboardToolbar *toolbar = [[ATGKeyboardToolbar alloc] initWithDelegate:nil];
    [self.email setInputAccessoryView:toolbar];
  }

  return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:NO];
}

- (BOOL) textFieldShouldReturn:(UITextField *)pTextField {
  [pTextField resignFirstResponder];
  if ([self.email validate]) {
    self.request = [[ATGProductManager productManager] registerBackInStockNotificationsForProduct:productId sku:skuId emailAddress:pTextField.text delegate:self];
  }
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)pTextField {
  if ([self.email validate]) {
    self.request = [[ATGProductManager productManager] registerBackInStockNotificationsForProduct:productId sku:skuId emailAddress:pTextField.text delegate:self];
  }
}

#pragma mark - Product Manager delegate

- (void) didRegisterBackInStockNotification:(ATGProductManagerRequest *)pRequest {
  UITableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  cell.textLabel.text = NSLocalizedStringWithDefaultValue(@"ATGEmailMeView.MessageConfirm", nil, [NSBundle mainBundle], @"Thanks for your interest", @"Email me confirm message");
  self.emailLabel.hidden = YES;
  self.email.hidden = YES;
  self.helpButton.hidden = YES;

  self.confirmationLabel.text = NSLocalizedStringWithDefaultValue(@"ATGEmailMeView.MessageConfirmText", nil, [NSBundle mainBundle], @"We'll let you know as soon as this item becomes available", @"Email me confirm sub message");
  [self.confirmationLabel setHidden:NO];
  self.request = nil;
}

- (void) didErrorRegisteringBackInStockNotification:(ATGProductManagerRequest *)pRequest {
  [self.delegate didErrorRegisteringBackInStockNotification:pRequest.error];
  self.request = nil;
}

- (void) dealloc {
  [self.request cancelRequest];
  self.request = nil;
}

@end