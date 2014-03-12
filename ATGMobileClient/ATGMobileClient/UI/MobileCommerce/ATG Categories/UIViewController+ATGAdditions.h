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

#import <ATGUIElements/ATGActionBlocker.h>

/*!
   @protocol ATGLoginViewControllerDelegate
   @abstract This protocol defines special callbacks to be called in response to
   user login actions.
   @discussion Every UIViewController adopts this protocol
   (see @link UIViewController(ATGAdditions) @/link for details). Default implementation
   of methods defined by this protocol dismisses the @link ATGLoginViewController @/link
   presented on the screen. You are free to redefine these methods implementation
   just don't forget to dismiss the Login screen at some point.
 */
@protocol ATGLoginViewControllerDelegate

/*!
   @method didLogin
   @abstract This method is called when the user has logged in.
 */
- (void)didLogin;
/*!
   @method didSkipLogin
   @abstract This method is called when the user has chosen 'Skip Login' option.
 */
- (void)didSkipLogin;
/*!
   @method didCancelLogin
   @abstract This method is called when the user has chosen to cancel login.
 */
- (void)didCancelLogin;

@end

/*!
   @protocol ATGTableViewErrorsHolder
   @abstract Defines methods to store and retrieve error messages.
 */
@protocol ATGTableViewErrorsHolder

/*!
   @method setErrors:inSection:
   @abstract This method should update error messages at the specified section.
   @param errors New set of errors.
   @param section Section to be updated.
 */
- (void)setErrors:(NSArray *)errors inSection:(NSInteger)section;
/*!
   @method errorsInSection:
   @abstract Returns all error messages displayed at the specified section.
   @param section Section to be inspected.
   @return Error messages currently displayed.
 */
- (NSArray *)errorsInSection:(NSInteger)section;

@end

/*!
   @category UIViewController(ATGAdditions)
   @abstract ATG additions to the @link UIViewController @/link class.
   @discussion This category defines useful extensions to the UIViewController class.
 */
@interface UIViewController (ATGAdditions) <ATGLoginViewControllerDelegate,
                                            ATGTableViewErrorsHolder>

/*!
 @property hidesNavigationBar
 @abstract Defines whether current view controller should hide the navigation bar or not.
 */
@property (nonatomic, readonly) BOOL hidesNavigationBar;

/*!
   @method presentLoginViewControllerAnimated:
   @abstract Displays an @link ATGLoginViewController @/link controller as modal view.
   @discussion This method presents an ATGLoginViewController to user, this controller
   is presented as a modal view. Login controller is displayed within a separated
   @link UINavigationController @/link instance (i.e. not in the same navigation controller
   defined by the @link ATGViewController @/link class).
   @param animated Defines whether the modal view should be presented with animation or not.
 */
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
/*!
   @method presentLoginViewControllerAnimated:allowSkipLogin:
   @abstract Displays an @link ATGLoginViewController @/link controller as modal view.
   @discussion This method presents an ATGLoginViewController to user, this controller
   is presented as a modal view. Login controller is displayed within a separated
   @link UINavigationController @/link instance (i.e. not in the same navigation controller
   defined by the @link ATGViewController @/link class). This method has one additional option
   and allows to just skip login step.
   @param animated Defines whether the modal view should be presented with animation or not.
   @param allowSkipLogin Defines whether the user is allowed to skip login step or not.
 */
- (void)presentLoginViewControllerAnimated:(BOOL)animated allowSkipLogin:(BOOL)allowSkipLogin;
/*!
   @method dismissLoginViewControllerAnimated:
   @abstract Removes an @link ATGLoginViewController @/link from the screen.
   @param animated Defines whether the Login screen should be dismissed with animation.
 */
- (void)dismissLoginViewControllerAnimated:(BOOL)animated;
/*!
   @method tableView:setErrors:inSection:
   @abstract Updates table view, thus making it display list of errors.
   @discussion This method updates list of errors to be displayed in the specified section
   with @link //apple-ref/occ/instm/UIViewController/setErrors:inSection: @/link method.
   Then it calls appropriate methods to add or remove cells to display new set of errors.
   @param tableView Table view to be updated.
   @param errors Array of error messages to be displayed.
   @param section Specifies table's section which should hold errors.
 */
- (void)tableView:(UITableView *)tableView setErrors:(NSArray *)errors inSection:(NSInteger)section;
/*!
   @method shiftIndexPath:
   @abstract Returns an index path as if no errors are displayed.
   @param indexPath Index path to be updated.
   @return New index path instance.
 */
- (NSIndexPath *)shiftIndexPath:(NSIndexPath *)indexPath;
/*!
   @method convertIndexPath:
   @abstract Calculates actual index path for path implemented for table with no errors displayed.
   @param indexPath Index path to be updated.
   @return New index path instance.
 */
- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath;
/*!
   @method tableView:errorCellForRowAtIndexPath:
   @abstract Creates an error cell to be displayed at the path specified.
   @discussion If there should be displayed an error at the position specified,
   an instance of @link //apple-ref/occ/cl/UITableViewCell @/link is returned.
   Otherwise this method returns nil.
   @param tableView Table view which should hold an error.
   @param indexPath Current index path.
   @return Error cell instance.
 */
- (UITableViewCell *) tableView:(UITableView *)tableView errorCellForRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method tableView:errorHeightForRowAtIndexPath:
   @abstract Calculates cell height to be used by error cell.
   @param tableView Table view instance which should hold an error.
   @param indexPath Current cell index path.
   @return Cell height to be used, or -1 if it's not an error cell.
 */
- (CGFloat)tableView:(UITableView *)tableView errorHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method errorNumberOfRowsInSection:
   @abstract Returns number of rows to be filled with errors.
   @return Additional number of rows to be added to a table view.
 */
- (NSInteger)errorNumberOfRowsInSection:(NSInteger)section;
/*!
   @method tableView:setError:inSection:
   @abstract Displays an error properly.
   @discussion This method first checks, if an error specified is a generic network error;
   if this is the case this method will present an alert view with localized error message.
   Otherwise this method will update the table view specified, thus making it display
   a list of form exceptions stored within the error specified.
   @param tableView Table view to be updated.
   @param error An error to be displayed.
   @param section Specifies table's section to hold form exceptions (if any).
 */
- (void)tableView:(UITableView *)tableView setError:(NSError *)error inSection:(NSInteger)section;
/*!
   @method
   @abstract Adds this controller to observers of keyboard notifications
 */
- (void)addKeyboardNotificationsObserver;
/*!
   @method
   @abstract Removes this controller from observers of keyboard notifications
 */
- (void)removeKeyboardNotificationsObserver;
/*!
   @method
   @abstract 'Keyboard will show' callback handler
   @param pNotification keyboard notification message
 */
- (void)keyboardWillShow:(NSNotification *)pNotification;
/*!
   @method
   @abstract 'Keyboard will hide' callback handler
   @param pNotification keyboard notification message
 */
- (void)keyboardWillHide:(NSNotification *)pNotification;

/*!
   @method alertWithTitleOrNil:withMessageOrNil:
   @abstract Display a simple UIAlertView with the given title and message
   @param title the alert title. Defaults to the resource ATGUIUtil.AlertDefaultTitle
   @param message the alert message. Defaults to the resource ATGUIUtil.AlertDefaultMessage
 */
- (void)alertWithTitleOrNil:(NSString *)title withMessageOrNil:(NSString *)message;

@end
