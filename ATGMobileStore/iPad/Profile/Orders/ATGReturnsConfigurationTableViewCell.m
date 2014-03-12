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

#import "ATGReturnsConfigurationTableViewCell.h"
#import <ATGMobileClient/ATGReturnRequest.h>
#import <ATGMobileClient/ATGReturnManager.h>


@interface ATGReturnsConfigurationTableViewCell () <UIActionSheetDelegate>
@property (nonatomic, strong) UIActionSheet *reasonActionSheet;
@property (nonatomic, weak) ATGReturnRequest *returnRequest;
@end

@implementation ATGReturnsConfigurationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark -
#pragma mark RETURNS REASON TABLE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ([self.returnRequest.universalReturn boolValue] ? 2 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    ATGReturnsConfigurationTableViewCell *cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsAllOn"];
    cell.returnAllSwitch.on = [self.returnRequest.universalReturn boolValue];
    [cell.returnAllSwitch addTarget:self action:@selector(returnAllChange:) forControlEvents:UIControlEventValueChanged];
    return cell;
  } else {
    ATGReturnsConfigurationTableViewCell *cell = (ATGReturnsConfigurationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReturnsCellUniversal"];
    cell.captionLabel.text = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalCaption", nil, [NSBundle mainBundle], @"Universal Reason", @"When in return mode, show this as the caption for prefacing return reason");
    cell.detailLabel.text = (self.returnRequest.universalReturnReason.length > 0 ? self.returnRequest.universalReturnReason : NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalPlaceholder", nil, [NSBundle mainBundle], @"Select Reason", @"When in return mode, show this as the placeholder for return reason"));
    return cell;
  }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.row > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row > 0) {
    self.reasonActionSheet = [[UIActionSheet alloc] init];
    self.reasonActionSheet.title = NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalSelectPrompt", nil, [NSBundle mainBundle], @"Select Reason", @"When in return mode, show this as the prompt for selecting return reason");
    self.reasonActionSheet.delegate = self;
    for (NSString *reason in [[ATGReturnManager instance].returnReasons allValues]) {
      [self.reasonActionSheet addButtonWithTitle:reason];
    }
    [self.reasonActionSheet addButtonWithTitle:NSLocalizedStringWithDefaultValue(@"ATGOrderItemTableViewCell.ReturnReasonUniversalCancelButtonTitle", nil, [NSBundle mainBundle], @"Cancel", @"When in return mode, show this as the title for cancel selection of return reason")];
    self.reasonActionSheet.cancelButtonIndex = [[ATGReturnManager instance].returnReasons allValues].count;
    ATGReturnsConfigurationTableViewCell *cell = (ATGReturnsConfigurationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.reasonActionSheet showInView:cell];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex != actionSheet.cancelButtonIndex) {
    self.returnRequest.universalReturnReason = [actionSheet buttonTitleAtIndex:buttonIndex];
    // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
    id view = [self superview];
    while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
      view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    [self.innerTable reloadData];
    [tableView reloadData];
  }
}

- (void)setObject:(id)object {
  self.returnRequest = (ATGReturnRequest *)object;
  [self.innerTable reloadData];

  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }
  [(UITableView *)view reloadData];
}

- (void)returnAllChange:(id)sender {
  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }
  UITableView *tableView = (UITableView *)view;
  self.returnRequest.universalReturn = [NSNumber numberWithBool:((UISwitch *)sender).on];
  [self.innerTable reloadData];
  [tableView reloadData];
}

@end
