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
 </ORACLECOPYRIGHT>*/

#import "ATGEmailMeViewController_iPad.h"
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGEmailValidator.h>
#import <ATGMobileClient/ATGProductManager.h>
#import <ATGMobileClient/ATGProductManagerRequest.h>

typedef enum {
  ATGEmailMeStateInitial,
  ATGEmailMeStateQuerying,
  ATGEmailMeStateError,
  ATGEmailMeStateSuccess
} ATGEmailMeState;

#pragma mark - ATGEmailMeViewController Private Protocol
#pragma mark -

@interface ATGEmailMeViewController_iPad () <ATGProductManagerDelegate, UITextFieldDelegate>

#pragma mark - IBOutlets

@property (nonatomic, readwrite, weak) IBOutlet ATGValidatableInput *emailInput;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *placeholderLabel;

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) ATGProductManagerRequest *request;
@property (nonatomic, readwrite, assign) ATGEmailMeState state;

@end

#pragma mark - ATGEmailMeViewController Implementation
#pragma mark -

@implementation ATGEmailMeViewController_iPad

#pragma mark - Synthesized Properties

@synthesize productID;
@synthesize skuID;
@synthesize popover;
@synthesize emailInput;
@synthesize subtitleLabel;
@synthesize placeholderLabel;
@synthesize request;
@synthesize state;

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setState:ATGEmailMeStateInitial];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	[[self emailInput] addValidator:[[ATGEmailValidator alloc] init]];
  [[self emailInput] setDelegate:self];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = 0;
  for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:0]; row++) {
    height += [self tableView:[self tableView] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row
                                                                                          inSection:0]];
  }
  return CGSizeMake([[[self subtitleLabel] text] sizeWithFont:[[self subtitleLabel] font]].width + 20, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  switch ([self state]) {
    case ATGEmailMeStateInitial:
      return 2;
    case ATGEmailMeStateQuerying:
      return 0;
    case ATGEmailMeStateError:
      return 2 + [self errorNumberOfRowsInSection:pSection];
    case ATGEmailMeStateSuccess:
      return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView cellForRowAtIndexPath:pIndexPath];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  return [super tableView:pTableView heightForRowAtIndexPath:pIndexPath];
}

- (void)tableView:(UITableView *)pTableView
  willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  if ([self state] == ATGEmailMeStateSuccess) {
    [[self subtitleLabel] setText:NSLocalizedStringWithDefaultValue
     (@"ATGEmailMeViewController_iPad.ScreenSubtitleSuccess",
      nil, [NSBundle mainBundle], @"We'll let you know as soon as this item becomes available",
      @"Screen subtitle to be displayed on the EmailMe screen when successfuly registered a request.")];
  } else {
    [[self subtitleLabel] setText:NSLocalizedStringWithDefaultValue
     (@"ATGEmailMeViewController_iPad.ScreenSubtitle",
      nil, [NSBundle mainBundle], @"When it's in stock, please let me know",
      @"Subtitle to be displayed on the EmailMe screen.")];
    [[self placeholderLabel] setText:NSLocalizedStringWithDefaultValue
     (@"ATGEmailMeViewController_iPad.EmailPlaceholder", nil, [NSBundle mainBundle], @"Email",
      @"Placeholder to be used by the email input field.")];
    [self setTitle:NSLocalizedStringWithDefaultValue
     (@"ATGEmailMeViewController_iPad.ScreenTitle", nil, [NSBundle mainBundle], @"Email Me",
      @"Title to be displayed at the top of the EmailMe screen.")];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)pTextField {
  if ([[self emailInput] validate]) {
    UIActivityIndicatorView *spinner =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner setCenter:CGPointMake(CGRectGetMidX([[self tableView] bounds]),
                                   CGRectGetMidY([[self tableView] bounds]))];
    [spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin];
    [[self tableView] setBackgroundView:spinner];
    [spinner startAnimating];
    [[self tableView] beginUpdates];
    for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:0]; row++) {
      [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row
                                                                                           inSection:0]]
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    [self setState:ATGEmailMeStateQuerying];
    [[self tableView] endUpdates];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setRequest:[[ATGProductManager productManager]
                      registerBackInStockNotificationsForProduct:[self productID]
                      sku:[self skuID]
                      emailAddress:[[self emailInput] text]
                      delegate:self]];
  }
  return YES;
}

#pragma mark - ATGProductManagerDelegate

- (void)didRegisterBackInStockNotification:(ATGProductManagerRequest *)pRequst {
  [self setState:ATGEmailMeStateSuccess];
  [[self tableView] setBackgroundView:nil];
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  [[self tableView] beginUpdates];
  [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0
                                                                                       inSection:0]]
                          withRowAnimation:UITableViewRowAnimationRight];
  [self tableView:[self tableView] setErrors:nil inSection:0];
  [[self tableView] endUpdates];
  [[self popover] setPopoverContentSize:[self contentSizeForViewInPopover] animated:YES];
}

- (void)didErrorRegisteringBackInStockNotification:(ATGProductManagerRequest *)pRequest {
  [self setState:ATGEmailMeStateError];
  [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  [[self tableView] setBackgroundView:nil];
  [[self tableView] beginUpdates];
  [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0
                                                                                        inSection:0],
                                                                     [NSIndexPath indexPathForRow:1
                                                                                        inSection:0], nil]
                          withRowAnimation:UITableViewRowAnimationRight];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [[self tableView] endUpdates];
  [[self popover] setPopoverContentSize:[self contentSizeForViewInPopover] animated:YES];
}

@end
