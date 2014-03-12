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

/*!
   @class ATGExpandableTableView
   @abstract Extends an UITableView to support expandable UITableViewCell objects.
   @discussion The ATGExpandableTableView extends the UITableView and adds specific
   selection behavior. When the user selects one of view cells, the
   ATGExpandableTableView changes cell's height (expands it).

   Please note, that you must assign a delegate to ATGExpandableTableView if you want
   your cells to be expanded in response to user selection events.

   Only cells that adopt the ATGExpandableTableViewCell protocol will be expanded
   when selected. All other cells will have static height calculated by table view's
   delegate (if it implelemts the tableView:heightForRowAtIndexPath: method) or
   defined with the rowHeight property.

   Please note that ATGExpandableTableView doesn't handle the deselection events.
   You have to trigger table view update manually, if you want to deselect table cells.

   Important behavior explanation!

   When you set table view delegate, the ATGExpandableTableView instruments delegate's
   class behavior!

   It changes its tableView:heightForRowAtIndexPath: method to operate as follows:
   1. If we're calculating height of the selected row, get the height from the
   mSelectedExpandedHeight table view's instance variable.
   2. Otherwise let the original implementation of the method to define the heigh.
   3. If no original implementation was defined, return table view's rowHeight
   property value.

   It also changes the tableView:didSelectRowAtIndexPath: method to operate as follows:
   1. If selected row adopts ATGExpandableTableViewCell protocol, save cell's
   expandedHeight property value into table view's mSelectedExpandedHeight.
   2. Otherwise save table view's rowHeight property value.
   3. Trigger table animations to display new heights with beginUpdates/endUpdates
   method pair.
   4. Call original tableView:didSelectRowAtIndexPath: method (if any).

   It also updates the tableView:willSelectRowAtIndexPath: method to operate as follows:
   1. If we're going to select row from the same section as currently selected row,
   deselect currently selected row and update table view.
   2. Call original tableView:willSelectRowAtIndexPath: method (if any).
   3. Do not allow selection (return nil) if re-selecting the same cell.
 */
@interface ATGExpandableTableView : UITableView
{
  // This variable will contain heigh of the selected cell.
  CGFloat mSelectedExpandedHeigh;
}

@end