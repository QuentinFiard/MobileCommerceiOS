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

/*!
 @header
 @abstract EMContentItemAdaptor class is used to manage @link EMContentItem /@link objects. The adaptor 
  serves as a translator from an @link EMContentItem /@link object model to @link UICollectionViewDataSource /@link
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class EMContentItem, EMContentItemCollectionReusableView, EMContentItemRenderer, EMAssemblerViewController;

@interface EMContentItemAdaptor : NSObject

/*!
 @property
 @abstract the content item
 */
@property (nonatomic, strong) EMContentItem *contentItem;

/*!
 @property
 @abstract the controller which controls the renderer constructed by this class
 */
@property (nonatomic, weak) EMAssemblerViewController *controller;

/*!
 @property
 @abstract the list of sub-adaptors which this adaptor has as children
 */
@property (nonatomic, strong) NSMutableArray *adaptors;

/*!
 @method
 @abstract subclasses should override this method if their renderers class names are prefixed
 @return the renderers' class name prefix
 */
- (NSString *)getClassPrefix;

/*!
 @method
 @abstract constructor
 @param pContentItem the @link EMContentItem /@link which is managed by this adaptor
 @param pController the @link EMAssemblerViewController /@link that manages a the @link EMContentItemRenderer /@link
  constructed by this class.
 @return an instance of @link EMContentItemAdaptor /@link
 */
- (id)initWithContentItem:(EMContentItem *)pContentItem controller:(EMAssemblerViewController *)pController;

/*!
 @method
 @abstract layout the contents for a specified key, this method is used to parse the content items subcontent into
  @link EMContentItemAdaptor /@link objects
 @param pKey @link NSString /@link key used to access subcontent.
 @return void
 */
- (void)layoutContentsForKey:(NSString *)pKey;

/*!
 @method
 @abstract layout the contents for a default key ("contents"), this method is used to parse the content items subcontent into
 @link EMContentItemAdaptor /@link objects
 @return nothing
 */
- (void)layoutContents;

/*!
 @method
 @abstract interface which is used to determine how many items are in the EMContentItem
 @return the number of items in the @link EMContentItem /@link to be renderered default is 0
 */
- (NSInteger)numberOfItemsInContentItem;

/*!
 @method
 @abstract interface for defining a renderer class for a given index
 @param pIndex index of object in content item
 @return the renderer class for a given index default is self.contentItem.typ + 'Renderer' class
 */
- (Class)rendererClassForIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface which is used to determine what item to render for a given index
 @param pIndex index of object in content item
 @return the object to be rendered for a given index default is self.contentItem
 */
- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface which is used to get the size of a render for a given index
 @param pIndex index of object in content item
 @return the size of the object to be rendered for a given index default is (0, 0)
 */
- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface which is called within the collectionView:cellForItemAtIndexPath: 
  @link UICollectionViewDataSource /@link called before setObject: (@link EMContentItemRenderer /@link)
 @param pRenderer the renderer which will be displayed. 
 @param pIndex the index of the object item being rendered. 
 @return void
 */
- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface for defining a renderer class for the section header
 @return the renderer class for the section header self.contentItem.type + 'SectionHeaderRenderer' class
 */
- (Class)headerRendererClass;

/*!
 @method
 @abstract interface which is used to determine what item to render for the section header
 @return the object to be rendered for the section header default is self.contentItem
 */
- (id)objectToBeRenderedForHeader;

/*!
 @method
 @abstract interface which is used to get the size of a render for the section header
 @return the size of the object to be rendered for the section header default is (0, 0)
 */
- (CGSize)referenceSizeForHeader;

/*!
 @method
 @abstract interface for defining a renderer class for the section footer
 @return the renderer class for the section footer default is self.contentItem.type + 'SectionFooterRenderer' class
 */
- (Class)footerRendererClass;

/*!
 @method
 @abstract interface which is used to determine what item to render for the section footer
 @return the object to be rendered for the section footer default is self.contentItem
 */
- (id)objectToBeRenderedForFooter;

/*!
 @method
 @abstract interface which is used to get the size of a render for the section footer
 @return the size of the object to be rendered for the section footer default is (0, 0)
 */
- (CGSize)referenceSizeForFooter;

/*!
 @method
 @abstract interface which is called within the collectionView:cellForItemAtIndexPath:
 @link UICollectionViewDataSource /@link called before setObject: (@link EMContentItemRenderer /@link)
 @param pRenderer the renderer which will be displayed.
 @param pIndex the index of the object item being rendered.
 @return void
 */
- (void)usingRenderer:(EMContentItemCollectionReusableView *)pRenderer forSupplementaryElementOfKind:(NSString *)pKind;

/*!
 @method
 @abstract interface for providing float to the collectionView:layout:minimumLineSpacingForSectionAtIndex:
  @link UICollectionViewDelegateFlow /@link delegate
 @return the desired spacing between lines default is 0
 */
- (CGFloat)minimumLineSpacing;

/*!
 @method
 @abstract interface for providing float to the collectionView:layout:minimumInteritemSpacingForSectionAtIndex:
  @link UICollectionViewDelegateFlow /@link delegate
 @return the desired spacing between items on a line default is 0
 */
- (CGFloat)minimumInteritemSpacing;

/*!
 @method
 @abstract interface for providing @link UIEdgeInsets /@link to the collectionView:layout:insetForSectionAtIndex:
  @link UICollectionViewDelegateFlow /@link delegate
 @return the desired edge insets default is (0, 0, 0, 0)
 */
- (UIEdgeInsets)edgeInsets;

/*!
 @method
 @abstract interface for providing boolean to the collectionView:layout:shouldHighlightItemAtIndexPath:
  @link UICollectionViewDelegateFlow /@link delegate
 @return the desired highlight behaviour default is NO
 */
- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface for collectionView:layout:didHighlightItemAtIndexPath:
 @link UICollectionViewDelegateFlow /@link delegate
 */
- (void)didHighlightItemAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface for collectionView:layout:didUnhighlightItemAtIndexPath:
 @link UICollectionViewDelegateFlow /@link delegate
 */
- (void)didUnhighlightItemAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface for providing boolean to the collectionView:layout:shouldSelectItemAtIndexPath:
 @link UICollectionViewDelegateFlow /@link delegate
 @return the desired select behaviour default is NO
 */
- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex;

/*!
 @method
 @abstract interface for collectionView:layout:didSelectItemAtIndexPath:
 @link UICollectionViewDelegateFlow /@link delegate
 */
- (void)didSelectItemAtIndex:(NSInteger)pIndex;

@end
