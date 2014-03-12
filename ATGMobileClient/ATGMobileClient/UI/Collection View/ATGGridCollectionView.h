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

@class ATGGridCollectionView;
@class ATGGridCollectionViewCell;

@protocol ATGGridCollectionViewDelegate <NSObject>

@required

- (void)gridCollectionView:(ATGGridCollectionView *)gridView
           didSelectObject:(id)object;
@optional

- (void)gridCollectionView:(ATGGridCollectionView *)gridView
           willDisplayCell:(ATGGridCollectionViewCell *)cell;
- (void)gridCollectionView:(ATGGridCollectionView *)gridView
           didChooseObject:(id)object;
- (void)gridCollectionView:(ATGGridCollectionView *)gridView
         didDechooseObject:(id)object;
- (void)gridCollectionViewWillAdjustContentOffset:(ATGGridCollectionView *)gridView;
- (void)gridCollectionViewDidAdjustContentOffset:(ATGGridCollectionView *)gridView;

@end

/*!
 @class ATGGridCollectionView
 @abstract Use this impmlementation of the collection view to present grids to user.
 @discussion This class adopts both UICollectionViewDelegate and UICollectionViewDataSource protocols,
 so you should not update its delegate and dataSource properties.
 You should pass objects to be presented by grid cells into the <code>objectsToDisplay</code> property,
 and the grid view would do all the necessary work to display those objects to user.
 This class also adds an ability to choose inner cells with swipe gesture.
 */
@interface ATGGridCollectionView : UICollectionView

/*!
 @property allowsChoosing
 @abstract Defines whether grid view allows to choose items with swipe gesture or not.
 */
@property (nonatomic, readwrite, assign) BOOL allowsChoosing;
/*!
 @property scrollDirection
 @abstract Defines grid scroll direction (horizontal or vertical).
 */
@property (nonatomic, readwrite, assign) UICollectionViewScrollDirection scrollDirection;
/*!
 @property gridViewDelegate
 @abstract Provide an object to this property to receive messages from the grid view.
 */
@property (nonatomic, readwrite, weak) id<ATGGridCollectionViewDelegate> gridViewDelegate;
/*!
 @property objectsToDisplay
 @abstract Defines a set of objects to be presented by inner grid cells.
 */
@property (nonatomic, readwrite, copy) NSArray *objectsToDisplay;

+ (Class)gridCollectionViewLayoutClass;

/*!
 @method initWithFrame:cellsNibName:
 @abstract It's a designated initializer method for this class.
 @discussion Use this method to create grid views. NIB file specified by its name must define a single
 object which is subclass of the <code>ATGGridCollectionViewCell</code>. If you decode a grid view from
 a NIB file, provide NIB file name with a <code>cellsNibName</code> runtime attribute.
 @param frame Initial view frame.
 @param nibName NIB file name which defines inner cells contents.
 */
- (id)initWithFrame:(CGRect)frame cellsNibName:(NSString *)nibName;

/*!
 @method indexPathsForChosenItems
 @abstract Returns index paths of chosen items (if any).
 */
- (NSArray *)indexPathsForChosenItems;
/*!
 @method chooseItemAtIndexPath:animated:
 @abstract Chooses an item at the specified index path.
 @param indexPath Defines an item to be chosen.
 @param animated Defines whether UI updates should be animated.
 */
- (void)chooseItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
/*!
 @method dechooseItemAtIndexPath:animated:
 @abstract Makes an item at the specified index path not chosen.
 @param indexPath Defines an item to be updated.
 @param animated Defines whether UI updates should be animated.
 */
- (void)dechooseItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/*!
 @method addObjectToDisplay:
 @abstract Adds an object to be displayed to the end of the <code>objectsToDisplay</code> array.
 @param object Object to be added.
 */
- (void)addObjectToDisplay:(id)object;
/*!
 @method removeObjectToDisplay:
 @abstract Removes an object from the <code>objectsToDisplay</code> array.
 @param object Object to be removed.
 */
- (void)removeObjectToDisplay:(id)object;

@end
