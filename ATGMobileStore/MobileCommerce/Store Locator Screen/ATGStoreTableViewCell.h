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

#import <QuartzCore/QuartzCore.h>

@class ATGStore;

/*!
   @const ATG_STORE_CELL_HEIGHT_SELECTED
   @abstract Defines selected store row height. Used by the ATGStoreTableController.
 */
extern const CGFloat ATGStoreCellSelectedHeight;
/*!
   @const ATG_STORE_CELL_HEIGHT_DESELECTED
   @abstract Defines deselected store row height. Used by the ATGStoreTableController.
 */
extern const CGFloat ATGStoreCellDeselectedHeight;

@class ATGStoreTableViewCell;

/*!
   @protocol ATGStoreTableViewCellDelegate
   @abstract ATGStoreTableViewCellDelegate delegates are used by the
   ATGStoreTableViewCell instances.
   @discussion The ATGStoreTableViewCellDelegate protocol defines several required
   methods. These methods are utilized by the ATGStoreTableViewCell instances
   to communicate with view controllers they are displayed within. Each time the user
   taps some button on the cell, appropriate delegate method will be invoked.
 */
@protocol ATGStoreTableViewCellDelegate

/*!
   @method didTouchMapButton:
   @abstract Tells the delegate that 'Map' button is tapped on the specified cell.
   @discussion Delegate should display a map to the user in this method.
   @param cell The 'Map' button has been tapped in this cell.
 */
- (void) didTouchMapButton:(ATGStoreTableViewCell *)cell;
/*!
   @method didTouchCallButton:
   @abstract Tells the delegate that 'Call' button is tapped on the specified cell.
   @discussion Delegate should make a call to some phone in this method.
   @param cell The 'Call' button has been tapped in this cell.
 */
- (void) didTouchCallButton:(ATGStoreTableViewCell *)cell;
/*!
   @method didTouchMailButton:
   @abstract Tells the delegate that 'Email' button is tapped on the specified cell.
   @discussion Delegate should compose an e-mail in this method.
   @param cell The 'EMail' button has been tapped in this cell.
 */
- (void) didTouchMailButton:(ATGStoreTableViewCell *)cell;

@end

/*!
   @class ATGStoreTableViewCell
   @abstract Represents a single row in the ATGStoreTableController.
   @discussion Instances of the ATGStoreTableViewCell are utilized by the
   ATGStoreTableController to display its rows.

   ATGStoreTableViewCell loads it view from the StoreTableViewCell nib-file.

   It presents an ATGStore details to the user. If selected, this cell also displays
   three buttons, 'Map', 'Email' and 'Call'. When one of these buttons is tapped,
   appropriate delegate method is invoked.
 */
@interface ATGStoreTableViewCell : UITableViewCell

/*!
   @property delegate
   @abstract The object that acts as the delegate of the receiving cell.
   @discussion The delegate must adopt the ATGStoreTableViewCellDelegate protocol.
   The delegate is not retained.
 */
@property (nonatomic, weak) id <ATGStoreTableViewCellDelegate> delegate;
/*!
   @property store
   @abstract An ATGStore object to be presented by the cell.
   @discussion The cell will display properties of an ATGStore specified through
   this property. Store is retained.
 */
@property (nonatomic, strong) ATGStore *store;

@end