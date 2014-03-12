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
   @class
   @abstract Defines class for UI Blocker.
   @discussion Block UI components. Can have configured action on tap in blocked area.
   For hiding block view use method dismissBlockView or set target and action.
 */

@interface ATGActionBlocker : NSObject <UIGestureRecognizerDelegate> {
  UIColor *mBGColor;
  float mBGAlpha;
}

/*!
   @property
   @abstract Actual background color of blocker view.
 */
@property (nonatomic, strong, setter = setBGColor :) UIColor *bgColor;
/*!
   @property
   @abstract Actual transparency of blocker view.
 */
@property (nonatomic, assign, setter = setBGAlpha :) float bgAlpha;

/*!
   @property
   @abstract Base frame of this blocker view
 */
@property (nonatomic, assign) CGRect frame;

/*!
   @method
   @abstract Singleton method for ATGActionBlocker.
   @discussion When block view wasn't created - create block view, or return existing view.
   @return New or current instance of the ATGActionBlocker
 */
+ (id) sharedModalBlocker;

/*!
   @method
   @abstract This method is called for display block view with configured action on tap.
   @discussion If target and action nil, block view can be hide with method dismissBlockView.
   @param view View, that will be displayed over block view.
   @param target Target for action.
   @param action Action on tap in blocked area.
 */
- (void) showView:(UIView *)view withTarged:(id)target andAction:(SEL)action;

/*!
   @method
   @abstract This method is called for display block view with configured action on tap, frame and which view must be blocked.
   @discussion If target and action nil, block view can be hide with method dismissBlockView.
   @param view View, that will be displayed over block view.
   @param frame Frame size for block view.
   @param target Target for action.
   @param action Action on tap in blocked area.
   @param baseView View that will be blocked.
 */
- (void) showBlockView:(UIView *)view withFrame:(CGRect)frame withTarget:(id)target andAction:(SEL)action forView:(UIView *)baseView;
/*!
   showBlockView:withFrame:actionBlock:forView:
   @abstract This method displays a block view with configured action, frame and
   view to be blocked.
   @discussion This method copies the action block specified and calls the
   showBlockView:withFrame:withTarget:andAction:forView: method with null
   target and action parameters.
   @param view View to be displayed over the block view.
   @param frame Frame to be used by the block view.
   @param actionBlock Action to be performed when the block view is touched.
   @param baseView View that should be blocked.
 */
- (void) showBlockView:(UIView *)view withFrame:(CGRect)frame
 actionBlock          :( void ( ^)(void) )block forView:(UIView *)baseView;

/*!
   @method
   @abstract This method hide block view.
   @discussion Hide block view and view on this view.
 */
- (void) dismissBlockView;

@end