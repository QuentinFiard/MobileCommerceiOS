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

#import <ATGUIElements/ATGButton.h>

static const CGFloat ATGMaskCornerRadius = 9;
static const CGFloat ATGDeleteTextSidePadding = 7;
static const CGFloat ATGDeleteTextVerticalPadding = 2;
static const CGFloat ATGDeleteButtonMinWidth = 70;

@implementation UITableViewCell (ATGAdditions)

- (CALayer *)createMaskForIndexPath:(NSIndexPath *)pIndexPath inTableView:(UITableView *)pTableView {
  // Create a mask with proper path.
  CAShapeLayer *mask = [CAShapeLayer layer];

  // Top cell will have rounded top corners.
  BOOL topCell = ([pIndexPath row] == 0);
  // Bottom cell will have rounded bottom corners.
  BOOL bottomCell = ([pIndexPath row] ==
                     [pTableView numberOfRowsInSection:[pIndexPath section]] - 1);

  CGSize size = [[self contentView] bounds].size;

  // Construct the path itself with four arcs.
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, size.height / 2);
  CGPathAddArcToPoint(path, NULL, 0, 0, size.width / 2, 0,
                      topCell ? ATGMaskCornerRadius : 0);
  CGPathAddArcToPoint(path, NULL, size.width, 0, size.width, size.height / 2,
                      topCell ? ATGMaskCornerRadius : 0);
  CGPathAddArcToPoint(path, NULL, size.width, size.height, size.width / 2, size.height,
                      bottomCell ? ATGMaskCornerRadius : 0);
  CGPathAddArcToPoint(path, NULL, 0, size.height, 0, size.height / 2,
                      bottomCell ? ATGMaskCornerRadius : 0);
  CGPathCloseSubpath(path);
  [mask setPath:path];
  // Release the path, because tableView:maskPathForCell:atIndexPath: creates and retains
  // the path.
  CGPathRelease(path);
  // Use some non-transparent color.
  [mask setBackgroundColor:[[UIColor maskBackgroundColor] CGColor]];
  return mask;
}

- (void) showDeleteDiallogForButton:(UIButton *)pDeleteButton
                         withTarget:(id)pTarget
                         withAction:(SEL)pAction
                          withTable:(UITableView *)pTableView {
  ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
  CGRect originFrame = [pTableView convertRect:pDeleteButton.frame fromView:self];

  originFrame.origin.x += self.contentView.frame.origin.x;
  originFrame.origin.y -= pTableView.contentOffset.y;
  if ([self isPhone]) {
    //scroll offset + navigation bar + status bar
    originFrame.origin.y = originFrame.origin.y + 44 + 20;
  }
  NSString *deleteTitle = NSLocalizedStringWithDefaultValue
      (@"ATGAdditions.DeleteButtonTitle", nil, [NSBundle mainBundle],
       @"Delete", @"Title to be displayed on the Delete button.");

  UIFont *font = [UIFont deleteButtonFont];
  CGSize size = [deleteTitle sizeWithFont:font];
  if (size.width < ATGDeleteButtonMinWidth) {
    size.width = ATGDeleteButtonMinWidth;
  }
  CGRect buttonFrame = CGRectMake(originFrame.origin.x - size.width - 2 * ATGDeleteTextSidePadding,
                                  originFrame.origin.y - ATGDeleteTextVerticalPadding,
                                  originFrame.size.width + size.width + 2 * ATGDeleteTextSidePadding,
                                  originFrame.size.height + 2 * ATGDeleteTextVerticalPadding);
  UIButton *button = [[ATGButton alloc] initWithFrame:buttonFrame];
  [button applyStyleWithName:@"deleteButton"];
  UIImageView *icon = [[UIImageView alloc] initWithImage:pDeleteButton.imageView.image];

  icon.frame = CGRectMake(size.width + 2 * ATGDeleteTextSidePadding, ATGDeleteTextVerticalPadding,
                          originFrame.size.width, originFrame.size.height);

  [button addSubview:icon];
  [button setTitle:deleteTitle forState:UIControlStateNormal];

  [button addTarget:pTarget action:pAction forControlEvents:UIControlEventTouchUpInside];

  if ([self isPhone]) {
    [blocker showView:button withTarged:blocker andAction:@selector(dismissBlockView)];
  } else   {
    [blocker showBlockView:button
                 withFrame:pTableView.superview.frame
                withTarget:blocker
                 andAction:@selector(dismissBlockView)
                   forView:pTableView.superview];
  }
}

@end