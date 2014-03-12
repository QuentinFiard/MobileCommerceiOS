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

#import "ATGReturnSuccessViewController.h"
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGKeychainManager.h>
#import "ATGReturnDetailsViewController.h"
#import "ATGAccountViewController.h"

@interface ATGReturnSuccessViewController ()
@property (nonatomic, readwrite, weak) IBOutlet UILabel *successLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *successDetailsLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *returnNumberCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *returnNumberLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *emailConfirmationCaptionLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *emailConfirmationLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *returnsHistoryHintLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *truckImageView;

@end

@implementation ATGReturnSuccessViewController


- (void)loadView {
  [super loadView];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-profile"] style:UIBarButtonItemStyleBordered target:self action:@selector(didClickMyAccount:)];
  
  self.title = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.Title", nil, [NSBundle mainBundle], @"Return Successful", @"Controller title, explains return success");
  
  NSString *localisedString = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.Success", nil, [NSBundle mainBundle], @"Success!", @"Bold, large text showing the return was placed");
  self.successLabel.text = localisedString;
  
  localisedString = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.SuccessDetails", nil, [NSBundle mainBundle], @"Your order return has been placed", @"The subtext of the success label, it explains the success'ness of the submitted return");
  self.successDetailsLabel.text = localisedString;
  
  localisedString = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.ReturnNumberCaption", nil, [NSBundle mainBundle], @"Your return number is", @"The caption for the return number");
  self.returnNumberCaptionLabel.text = localisedString;
  
  localisedString = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.EmailConfirmationCaption", nil, [NSBundle mainBundle], @"A confirmation email was sent to:", @"Confirmation email caption, describes the location and reason an email way sent to");
  self.emailConfirmationCaptionLabel.text = localisedString;
  
  localisedString = NSLocalizedStringWithDefaultValue(@"ATGReturnSuccessViewController.ReturnHistoryHint", nil, [NSBundle mainBundle], @"You can review your return by clicking on the return number cell above, or going to the Returns History section of your account", @"Hint to inform user that they can view all return history by clicking this cell, or they can click the cell with return number to see the details of this particular return");
  
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:localisedString];
  [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[[attrString string] rangeOfString:localisedString]];
  [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:71.0/255.0 green:106.0/255.0 blue:149.0/255.0 alpha:1.0] range:[[attrString string] rangeOfString:@"Returns History"]]; //this is going to have issues with localization :(
  self.returnsHistoryHintLabel.attributedText = attrString;
  
  self.emailConfirmationLabel.text = [[ATGKeychainManager instance] stringForKey:ATG_KEYCHAIN_EMAIL_PROPERTY];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationItem.hidesBackButton = YES;
  self.returnNumberLabel.text = self.returnRequst.requestId;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileStoryboard_iPad" bundle:[NSBundle mainBundle]];
    ATGReturnDetailsViewController *returnDetailsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ATGReturnDetailsViewController"];
    returnDetailsViewController.returnId = self.returnNumberLabel.text;
    [self.navigationController pushViewController:returnDetailsViewController animated:YES];
  } else if (indexPath.row == 2) {
    [self didClickMyAccount:self];
  }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.row != 1;
}

- (void) didClickMyAccount:(id)pSender {
  [self.navigationController popToViewControllerWithClass:[ATGAccountViewController class] animated:YES];
}

@end
