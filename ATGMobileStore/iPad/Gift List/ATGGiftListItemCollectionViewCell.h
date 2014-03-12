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

#import <ATGMobileClient/ATGGridCollectionViewCell.h>

@class ATGGiftItem;
@class ATGGiftListItemCollectionViewCell;

/*!
 @protocol ATGGiftListItemCollectionViewCellDelegate
 @abstract Adopt this protocol to receive messages from ATGGiftListItemCollectionViewCell instances.
 */
@protocol ATGGiftListItemCollectionViewCellDelegate <NSObject>

@optional

/*!
 @method removeGiftItem:forCell:
 @abstract This method is called when the user has touched the 'Remove' button.
 @param giftItem Gift item represented by the touched cell.
 @param cell Cell which has been touched.
 */
- (void)removeGiftItem:(ATGGiftItem *)giftItem forCell:(ATGGiftListItemCollectionViewCell *)cell;
/*!
 @method moveGiftItemToGiftList:forCell:
 @abstract This method is called when the user has touched the 'Add to Gift List' button.
 @param giftItem Gift item represented by the touched cell.
 @param cell Cell which has been touched.
 */
- (void)moveGiftItemToGiftList:(ATGGiftItem *)giftItem forCell:(ATGGiftListItemCollectionViewCell *)cell;
/*!
 @method moveGiftItemToWishList:forCell:
 @abstract This method is called when the user has touched the 'Add to Wish List' button.
 @param giftItem Gift item represented by the touched cell.
 @param cell Cell which has been touched.
 */
- (void)moveGiftItemToWishList:(ATGGiftItem *)giftItem forCell:(ATGGiftListItemCollectionViewCell *)cell;
/*!
 @method compareGiftItem:forCell:
 @abstract This method is called when the user has touched the 'Add to Comparisons' button.
 @param giftItem Gift item represented by the touched cell.
 @param cell Cell which has been touched.
 */
- (void)compareGiftItem:(ATGGiftItem *)giftItem forCell:(ATGGiftListItemCollectionViewCell *)cell;
/*!
 @method addGiftItemToCart:forCell:
 @abstract This method is called when the user has touched the 'Add to Cart' button.
 @param giftItem Gift item represented by the touched cell.
 @param cell Cell which has been touched.
 */
- (void)addGiftItemToCart:(ATGGiftItem *)giftItem forCell:(ATGGiftListItemCollectionViewCell *)cell;

@end

/*!
 @class ATGGiftListItemCollectionViewCell
 @abstract This grid cell represents a gift item.
 */
@interface ATGGiftListItemCollectionViewCell : ATGGridCollectionViewCell

/*!
 @property delegate
 @abstract This object will receive messages from current cell.
 */
@property (nonatomic, readwrite, weak) id<ATGGiftListItemCollectionViewCellDelegate> delegate;


/*!
 @property Exposed so we could reference for accessibility purposes
 @abstract This object will be used to target the editing cell for accessibility
 */
@property (nonatomic, readwrite, weak) IBOutlet UIButton *deleteButton;

@end
