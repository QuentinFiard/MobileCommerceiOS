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
 @abstract EMAssemblerViewController class acts as a base controller for assembler pages.
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "EMConnectionManager.h"

@class EMAction, EMContentItem, EMContentItemList, EMAdaptorManager, EMBlockQueue, EMContentPathLookupManager;

@interface EMAssemblerViewController : UIViewController <EMConnectionManagerDelegate>

/*!
 @property
 @abstract the manager which constructs adaptors to manage collection view layout.
 */
@property (nonatomic, strong) EMAdaptorManager *adaptorManager;

/*!
 @property
 @abstract the view of which the content is displayed, this is self.view;
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/*!
 @property
 @abstract the root object received from the Assembler for a given @link EMAction /@link
 default is nil
 */
@property (nonatomic, strong) EMContentItem *rootContentItem;

/*!
 @property
 @abstract when submitting a reload action, use this content path to inform the
 view controller of what content should be displayed.
 default is nil;
 */
@property (nonatomic, strong) NSString *reloadContentPath;

/*!
 @property
 @abstract the most recently performed @link EMAction /@link
 default is nil
 */
@property (nonatomic, strong) EMAction *action;

@property (nonatomic, strong) EMBlockQueue *viewWillAppearBlockQueue;

@property (nonatomic, strong) EMBlockQueue *dataReadyBlockQueue;

/*!
 @method
 @abstract submit @link EMAction /@link and render response
 @param pAction the @link EMAction @/link to submit to the assembler
 @return void
 */
- (void)loadPageForAction:(EMAction *)pAction;

/*!
 @method
 @abstract submit @link EMAction /@link and render response
 @param pAction the @link EMAction @/link to submit to the assembler
 @param pAttributes an @link NSDictionary @/link of attributes which 
  should be persisted across queries
 @return void
 */
- (void)loadPageForAction:(EMAction *)pAction withAttributes:(NSDictionary *)pAttributes;

/*!
 @method
 @abstract submit @link EMAction /@link and render specific content
 from the response
 @param pAction the @link EMAction @/link to submit to the assembler
 @param pContentPath the specific content which is to be renedered from
 the response. @link EMContentPathLookupManager /@link has more info on
 accesing specific content within a response via a content path.
 @return void
 */
- (void)reloadPageForAction:(EMAction *)pAction contentsAtPath:(NSString *)pContentPath;

/*!
 @method
 @abstract submit @link EMAction /@link and render specific content
 from the response
 @param pAction the @link EMAction @/link to submit to the assembler
 @param pContentPath the specific content which is to be renedered from
 the response. @link EMContentPathLookupManager /@link has more info on
 accesing specific content within a response via a content path.
 @param pAttributes an @link NSDictionary @/link of attributes which
 can be persisted across queries.
 @return void
 */
- (void)reloadPageForAction:(EMAction *)pAction contentsAtPath:(NSString *)pContentPath attributes:(NSDictionary *)pAttributes;

/*!
 @method
 @abstract submit @link EMAction /@link if reloadContentPath is set
 it will reload contents at reloadContentPath, otherwise it will reload
 the root content item.
 @param pAction the @link EMAction @/link to submit to the assembler
 @return void
 */
- (void)reloadPageForAction:(EMAction *)pAction;

/*!
 @method
 @abstract submit @link EMAction /@link if reloadContentPath is set
 it will reload contents at reloadContentPath, otherwise it will reload
 the root content item.
 @param pAction the @link EMAction @/link to submit to the assembler
 @param pAttributes an @link NSDictionary @/link of attributes which
 can be persisted across queries.
 @return void
 */
- (void)reloadPageForAction:(EMAction *)pAction withAttributes:(NSDictionary *)pAttributes;

/*!
 @method
 @abstract renderer @link EMContentItem /@link objects within an
 @link EMContentItemList /@link
 @param pContentItemList the @link EMContentItemList /@link which contains
 @link EMContentItem /@link objects to be renderered
 @return void
 */
- (void)loadPageForContents:(EMContentItemList *)pContentItemList;

/*!
 @method
 @abstract renderer @link EMContentItem /@link object
 @param pContentItem the @link EMContentItem /@link which is to
 be renderered
 @return void
 */
- (void)loadPageForContentItem:(EMContentItem *)pContentItem;

/*!
 @method
 @abstract subclassing hook called when data is ready to be displayed
 @discussion this should not be called programatically, call reloadData on 
  the collectionView to programatically re-draw data.
 */
- (void)dataReady;

/*!
 @method
 @abstract subclassing hook called after response received
 @discussion default implementation uses @link EMJSONParser /@link
 @param pResponseObject the response object
 @return a content item constructed via the response object
 */
- (EMContentItem *)parseResponseObject:(id)pResponseObject;

/*!
 @method
 @abstract the connection manager to be used by this view.  Subclasses
 may wish to return an EMConnectionManager instance configured against
 a different host.
 */
- (EMConnectionManager*) connectionManager;

/*!
 @method
 @abstract the content path lookup manager to be used by this controller.  Subclasses
 may wish to return an EMContentPathLookupManager instance specific to their needs.
 */
- (EMContentPathLookupManager *) contentPathLookupManager;

/*!
 @method
 @abstract subclassing hook for configuring a custom Layout
 @discussion default implementation uses EMCollectionViewLayoutPinnedSectionHeaders
 @return void
 */
- (UICollectionViewLayout *)collectionViewLayout;

@end
