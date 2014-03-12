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
 * </ORACLECOPYRIGHT>*/

#import "ATGGiftSearchResultCell.h"

#pragma mark - ATGGiftSearchResultCell private interface declaration
#pragma mark -
@interface ATGGiftSearchResultCell ()
#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *eventNameView;
@property (weak, nonatomic) IBOutlet UIView *eventTypeView;
@property (weak, nonatomic) IBOutlet UIView *eventDateView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

#pragma mark - Custom properties
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

#pragma mark - ATGGiftSearchResultCell implementation
#pragma mark -
@implementation ATGGiftSearchResultCell

#pragma mark - Lifecucle
- (void) awakeFromNib {
  [super awakeFromNib];
  self.formatter = [[NSDateFormatter alloc] init];
  [self.formatter setDateFormat:@"MMM d, yyyy"];
}

- (void) setGiftList:(ATGGiftList *)pGiftList {
  _giftList = pGiftList;
  self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", pGiftList.firstName, pGiftList.lastName];
  self.eventNameLabel.text = pGiftList.name;
  self.eventTypeLabel.text = pGiftList.type;
  self.eventDateLabel.text = [self.formatter stringFromDate:pGiftList.date];
}

#pragma mark - Public methods
- (void) setSelectedView:(ATGSearchResultCellViewType)pType {
  [self.nameView setBackgroundColor:[UIColor clearColor]];
  [self.eventNameView setBackgroundColor:[UIColor clearColor]];
  [self.eventTypeView setBackgroundColor:[UIColor clearColor]];
  [self.eventDateView setBackgroundColor:[UIColor clearColor]];
  switch (pType) {
  case ATGNameView:
    [self.nameView setBackgroundColor:RGB(202, 205, 211)];
    break;

  case ATGEventDateView:
    [self.eventDateView setBackgroundColor:RGB(202, 205, 211)];
    break;

  case ATGEventNameView:
    [self.eventNameView setBackgroundColor:RGB(202, 205, 211)];
    break;

  case ATGEventTypeView:
    [self.eventTypeView setBackgroundColor:RGB(202, 205, 211)];
    break;

  default:
    break;
  }
}

@end