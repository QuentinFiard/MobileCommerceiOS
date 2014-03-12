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

#import "ATGExpandableTableViewCell.h"

/*!
   @protocol ATGSignupTableViewCellDelegate
   @abstract Object which wants to receive notifications from ATGSignupTableViewCell
   must adopt this protocol.
 */
@protocol ATGSignupTableViewCellDelegate <NSObject>

/*!
   @method signUpWithEmail:password:firstName:lastName:additionalInfo:
   @abstract Notifies that the user requested a sign up process.
   @discussion It is iPad specific method, provides additional info (ex. date of birth, gender and etc.). Delegate should actually create a new user inside this method.
   @param email Email to be used.
   @param password User password to be used.
   @param firstName User first name.
   @param lastName User last name.
   @param additionalInfo Additional info.
   @remember If YES, the user should be remembered on the device.
 */
- (void) signUpWithEmail:(NSString *)email password:(NSString *)password
               firstName:(NSString *)firstName lastName:(NSString *)lastName
          additionalInfo:(NSDictionary *)additionalInfo;
/*!
   @method displayPrivacyTerms
   @abstract Notifies that the user requests a privacy terms screen.
 */
- (void) displayPrivacyTerms;
/*!
   @method resizePopover:
   @abstract Notifies that cell was expanded and popover have to be resized. iPad only.
   @param newHeight Height that will be added to popover.
 */
- (void) resizePopover:(CGFloat)newHeight;

@optional

/*!
 @method presentInputView:forTextField:
 @abstract This method is called when the cell tries to present custom input view for a text field.
 @discussion Implement this method to present custom input view within a popover.
 @param view Input view to be displayed.
 @param textField Text field requested the input view to be displayed.
 */
- (void)presentInputView:(UIView *)view forTextField:(UITextField *)textField;
/*
 @method dismissInputView
 @abstract This method is called when a custom input view should be dismissed from the screen.
 */
- (void)dismissInputView;

@end

/*!
   @class ATGSignupTableViewCell
   @abstract Represents a 'Sign Up' cell on the 'Login' screen.
 */
@interface ATGSignupTableViewCell : UITableViewCell <ATGExpandableTableViewCell>

/*!
   @property delegate
   @abstract This object will receive all cell's notifications.
 */
@property (nonatomic, readwrite, weak) id <ATGSignupTableViewCellDelegate> delegate;
/*!
   @property email
   @abstract Email input will be pre-populated with this value.
 */
@property (nonatomic, readwrite, copy) NSString *email;
/*!
   @property caption
   @abstract Caption to be displayed on the cell.
 */
@property (nonatomic, readwrite, copy) NSString *caption;

/*!
   @method newInstance
   @abstract Creates a new instance of the cell.
   @discussion This method loads the cell instance from a NIB file.
   @return Fully configured and ready to use cell.
 */
+ (ATGSignupTableViewCell *) newInstance;

/*!
   @method didTouchSignUpButton:
   @abstract This method is called when the user touches the 'Done' button.
   @param sender The button itself.
 */
- (void) didTouchSignUpButton:(id)sender;

- (void) setError:(NSString *)error;

@end