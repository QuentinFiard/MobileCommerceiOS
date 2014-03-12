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

#import "ATGGridViewCell.h"

@class ATGGridView;

/*!
   @protocol ATGGridViewDelegate
   @abstract Adopt this protocol, if you want to receive messages
    from @link //apple_ref/occ/cl/ATGGridView @/link
   @discussion Protocol methods are similar to methods defined with
    @link //apple_ref/occ/intf/UITableViewDelegate @/link
 */
@protocol ATGGridViewDelegate <UIScrollViewDelegate>

@optional
/*!
   @method gridView:willDisplayCell:atIndexPath:
   @abstract Notifies the delegate that cell is about to be displayed to user.
   @param gridView ATGGridView object sent a message.
   @param cell ATGGridViewCell to be dislpayed to user.
   @param indexPath Specifies cell position inside of a grid.
 */
- (void) gridView:(ATGGridView *)gridView willDisplayCell:(ATGGridViewCell *)cell
 atIndexPath     :(NSIndexPath *)indexPath;
/*!
   @method gridView:didSelectCellAtIndexPath:
   @abstract Notifies the delegate that some cell has been selected by user.
   @param gridView ATGGridView object sent a message.
   @param indexPath Specifies cell position inside of a grid.
 */
- (void) gridView:(ATGGridView *)gridView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method gridView:widthForColumnsInRow:
   @abstract Implement this method to define custom column width for the specified row.
   @discussion If you don't implement this method, cells in the row specified will be
   stretched to occupy all awailable row width.
   @param gridView ATGGridView object sent a message.
   @param row A zero-based number of row in the grid.
   @return Width of column in the row specified.
 */
- (CGFloat) gridView:(ATGGridView *)gridView widthForColumnsInRow:(NSInteger)row;

@end

/*!
   @protocol ATGGridViewDataSource
   @abstract Adopt this protocol to define inner contents of the
    @link //apple_ref/occ/cl/ATGGridView @/link
   @discussion Protocol methods are similar to methods defined with
    @link //apple_ref/occ/intf/UITableViewDataSource @/link
 */
@protocol ATGGridViewDataSource <NSObject>

/*!
   @method numberOfRowsInGridView:
   @abstract Calculates number of rows in the grid view specified.
   @param gridView Calculate number of rows for this instance of grid.
   @return Number of rows in the grid view.
 */
- (NSInteger) numberOfRowsInGridView:(ATGGridView *)gridView;
/*!
   @method gridView:numberOfColumnsInRow:
   @abstract Calculates number of cells in the grid view at row specified.
   @param gridView Calculate number of cells for this instance of grid.
   @param row Specifies a zero-based number of row to be examined.
   @return Number of cells in the row specified.
 */
- (NSInteger) gridView:(ATGGridView *)gridView numberOfColumnsInRow:(NSInteger)row;
/*!
   @method gridView:cellAtIndexPath:
   @abstract Creates an instance of cell to be displayed inside a grid view at the position
   specified.
   @param gridView Grid view instance to hold the cell.
   @param indexPath Specifies cell location inside the grid.
   @return An instance of ATGGridViewCell to be displayed within a grid view.
 */
- (ATGGridViewCell *) gridView:(ATGGridView *)gridView
 cellAtIndexPath              :(NSIndexPath *)indexPath NS_RETURNS_RETAINED;

@end

/*!
   @class ATGGridView
   @abstract Grid view presents information to user split into rows and columns.
   @discussion Grid view consists of a number of rows, each with its own columns.
   You should provide proper instances for the <code>delegate</code> and
   <code>dataSource</code> properties to define grid contents and get notifications
   from the grid view.
 */
@interface ATGGridView : UIScrollView

/*!
   @property rowHeight
   @abstract Defines height of grid view rows.
 */
@property CGFloat rowHeight;
/*!

 */
@property (nonatomic, readwrite, getter = isEditingEnabled) BOOL editingEnabed;
/*!
   @property delegate
   @abstract Specify delegate to handle grid notifications.
 */
@property (nonatomic, readwrite, weak) id <ATGGridViewDelegate> delegate;
/*!
   @property dataSource
   @abstract Specify data source to define grid contents.
 */
@property (nonatomic, readwrite, weak) id <ATGGridViewDataSource> dataSource;
/*!
   @property backgroundView
   @abstract This view will be dislpayed as a background for the grid.
 */
@property (nonatomic, readwrite, strong) UIView *backgroundView;

/*!
   @method reloadData
   @abstract Reloads grid contents without animations.
 */
- (void) reloadData;
/*!
   @method beginUpdates
   @abstract Begins an updates session for the grid view.
   @discussion Call this method before making calls to <code>deleteCellAtIndexPath:</code>
   or <code>appendCells:</code> methods.
 */
- (void) beginUpdates;
/*!
   @method deleteCellAtIndexPath:
   @abstract Removes a cell in a current update session.
   @param indexPath Defines cell to be removed by its position in the grid.
 */
- (void) deleteCellAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method appendCells:
   @abstract Appends specified number of cells at the end of grid.
   @param numberOfCells How many cells to add.
 */
- (void) appendCells:(NSInteger)numberOfCells;
/*!
   @method endUpdates
   @abstract Commits current updates session.
 */
- (void) endUpdates;

@end

/*!
   @category NSIndexPath (ATGGridView)
   @abstract This category defines additional convenience methods to work
   in conjunction with ATGGridView.
 */
@interface NSIndexPath (ATGGridView)

/*!
   @method indexPathForColumn:inRow:
   @abstract Creates an index path instance for the row and column specified.
   @param column Zero-based index identifying a column in the ATGGridView.
   @param row Zero-based index identifying a row in the ATGGridView.
   @return An NSIndexPath instance.
 */
+ (NSIndexPath *) indexPathForColumn:(NSInteger)column
 inRow                              :(NSInteger)row NS_RETURNS_NOT_RETAINED;

/*!
   @method column
   @abstract Accessor method for the <code>column</code> proeprty.
   @return Zero-based number of column in the ATGGridView.
 */
- (NSInteger) column;

@end