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
   @category UIColor(ATGAdditions)
   @abstract Defines ATG additions to the @link UIColor @/link class.
 */
@interface UIColor (ATGAdditions)

/*!
   @method tableBackgroundColor
   @abstract Creates a color to be used as background color of UITableView.
   @return UIColor instance to be used as background.
 */
+ (UIColor *) tableBackgroundColor;
/*!
   @method
   @return Starting color for tables background gradient
 */
+ (UIColor *) tableGradientBackgroundStartColor;
/*!
   @method
   @return Ending color for tables background gradient
 */
+ (UIColor *) tableGradientBackgroundEndColor;
/*!
   @method
   @return Default background color for UITableViewCell instances.
 */
+ (UIColor *) tableCellBackgroundColor;
/*!
   @method
   @return Background color for selected UITableViewCell instance in shopping cart table.
 */
+ (UIColor *) cartTableCellSelectedBackgroundColor;
/*!
   @method
   @return Background color for share button in shopping cart
 */
+ (UIColor *) cartShareButtonBackgroundColor;
/*!
   @method
   @return Background color for remove button in shopping cart
 */
+ (UIColor *) cartRemoveButtonBackgroundColor;
/*!
   @method
   @return Background color for messages container
 */
+ (UIColor *) messageBackgroundColor;
/*!
   @method subTableBackgroundColor
   @abstract Creates a color to be used as background color of child UITableView.
   @return UIColor instance to be used as background.
 */
+ (UIColor *) subTableBackgroundColor;

+ (UIColor *) descriptionBackgroundColor;

/*!
   @method errorColor
   @abstract Creates a validateable input background color in error state.
   @return An UIColor instance.
 */
+ (UIColor *) errorColor;
/*!
   @method
   @return Default color for borders
 */
+ (UIColor *) borderColor;
/*!
   @method
   @return Dark color for borders
 */
+ (UIColor *) borderDarkColor;
/*!
   @method
   @return Light color for borders
 */
+ (UIColor *) borderLightColor;
/*!
   @method
   @return Color for 'email me' view text
 */
+ (UIColor *) emailMeTextColor;
/*!
   @method
   @return Color for 'email me' view background
 */
+ (UIColor *) emailMeBackgroundColor;
/*!
   @method
   @return Color for featured items carousel view background
 */
+ (UIColor *) featuredItemsBackgroundColor;
/*!
   @method
   @return Default color for text data
 */
+ (UIColor *) textColor;
/*!
   @method
   @return Default color for highlighted text data
 */
+ (UIColor *) textHighlightedColor;
/*!
   @method
   @return Button light background color
 */
+ (UIColor *) buttonLightBackgroundColor;
/*!
   @method
   @return Background color used for masking out
 */
+ (UIColor *) maskBackgroundColor;
/*!
   @method
   @return Default activity indicator color
 */
+ (UIColor *) activityIndicatorColor;
/*!
   @method
   @return Dark activity indicator color
 */
+ (UIColor *) activityIndicatorDarkColor;
/*!
   @method
   @return CVV input shadow color
 */
+ (UIColor *) cvvShadowColor;
/*!
   @method
   @return Dirty blue color, used in 'More...' section
 */
+ (UIColor *) dirtyBlueColor;

@end