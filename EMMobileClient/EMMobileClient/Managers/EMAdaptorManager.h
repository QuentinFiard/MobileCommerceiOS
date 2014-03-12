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
 @abstract EMAdaptorManager class used to manage display/communication of an @link EMContentItem /@link and
  a @link EMAssemblerViewController /@link
 @discussion Each @link EMAssemblerViewController /@link maintains its own instance of an EMAdaptorManager. The
  constructAdaptorForContentItem: interface exposes an entry point for initiating the construction of a flattened content
  hierarchy which then serves as a datasource for the @link UICollectionView /@link managed by @link EMAssemblerViewController /@link.
  Each @link EMContentItem /@link is managed by a single @link EMContentItemAdaptor /@link and represents a single section of the 
  @link UICollectionView /@link, depending on the @link EMContentItemAdaptor /@link implementation the @link EMContentItem /@link may be
  rendered as zero or more items in its given section. Adaptors which return 0 to numberOfItemsInContentItem are not rendered. The 
  EMAdpatorManager is responsible for brokering between an array of EMContentItemAdaptors and the EMAssemblerViewController.
  
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 */

#import "EMContentItemAdaptor.h"

@class EMContentItem, EMContentItemList, EMAssemblerViewController, EMContentItemAdaptor;
@interface EMAdaptorManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/*!
 @method
 @abstract method should be called everytime a new @link EMContentItem /@link is to be rendered. This method
  initiates a traversal of the @link EMContentItem /@link argument and builds an array of @link EMContentItemAdaptor /@link
  objects used to inform a collection view datasource/delegate.
 @param pContentItem the @link EMContentItem /@link which is to be rendered
 @param pController the @link EMAssemblerViewController /@link which is used to manage the eventual view.
 */
- (void)constructAdaptorForContentItem:(EMContentItem *)pContentItem withController:(EMAssemblerViewController *)pController;

/*!
 @method
 @abstract method should be called everytime a new @link EMContentItemList /@link is to be rendered. This method
 initiates a traversal of the @link EMContentItemList /@link argument and builds an array of @link EMContentItemAdaptor /@link
 objects used to inform a collection view datasource/delegate.
 @param pContentItemList the @link EMContentItemList /@link which is to be rendered
 @param pController the @link EMAssemblerViewController /@link which is used to manage the eventual view.
 */
- (void)constructAdaptorForContentItemList:(EMContentItemList *)pContentItemList withController:(EMAssemblerViewController *)pController;

/*!
 @method
 @abstract extension point to override the default @link EMContentItemAdaptor /@link that is constructed via factory
 @param pContentItem the @link EMContentItem /@link which is to be rendered
 @param pController the @link EMAssemblerViewController /@link which is used to manage the eventual view.
 */
- (EMContentItemAdaptor *)adaptorForContentItem:(EMContentItem *)pContentItem controller:(EMAssemblerViewController *)pController;


- (NSInteger)indexOfContentItem:(EMContentItem *)pContentItem;

/*!
 @property
 @abstract a shared @link NSDictionary /@link of adaptor attributes. Adaptors place things in the adaptor attributes dictionary
  before submitting actions. Values can be retrieved on subsequent loads.
 */
@property (nonatomic, strong) NSDictionary *adaptorAttributes;

@end
