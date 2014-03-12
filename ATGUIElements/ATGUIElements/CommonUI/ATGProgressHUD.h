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

@class ATGProgressHUD;

typedef enum {
  //Progress is shown using an UIActivityIndicatorView. This is the default.
  ATGProgressHUDModeIndeterminate,
  //Progress is shown using a round, pie-chart like, progress view.
  ATGProgressHUDModeDeterminate,
  //Shows a custom view
  ATGProgressHUDModeCustomView,
  // Shows only labels
  ATGProgressHUDModeText
}
ATGProgressHUDMode;

/*!
   @protocol Call back method for HUD
 */
@protocol ATGProgressHUDDelegate <NSObject>

@optional
/*!
   @method hudWasHidden:
   @abstract Called after the HUD was fully hidden from the screen.
   @param hud HUD object
 */
- (void) hudWasHidden:(ATGProgressHUD *)hud;

@end

/*!
   @class
   @abstract Semi-transparent view for displaying work progress
 */

@interface ATGProgressHUD : UIView

/*!
   @method showHUDAddedTo:animated:
   @abstract Creates a new HUD, adds it to provided view and shows it.
   @param view View which bounds will be used for HUD
   @param animated Display with animation or not
   @return HUD object
 */
+ (ATGProgressHUD *) showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

/*!
   @method initWithWindow:
   @abstract Constructor that initializes the HUD with the window's bounds.
   @param window The window instance that will provide the bounds for the HUD.
 */
- (id) initWithWindow:(UIWindow *)window;
/*!
   @method initWithView:
   @abstract Constructor that initializes the HUD with the view's bounds.
   @param view The view instance that will provide the bounds for the HUD.
 */
- (id) initWithView:(UIView *)view;
/*!
   @method show:
   @abstract Display the HUD.
   @param animated If set to YES the HUD will appear using 'fade in' animation.
 */
- (void) show:(BOOL)animated;
/*!
   @method hide:
   @abstract Hide the HUD.
   @param animated If set to YES the HUD will disappear using 'fade out' animation.
 */
- (void) hide:(BOOL)animated;
/*!
   @method hide:
   @abstract Hide the HUD after a delay.
   @param animated If set to YES the HUD will disappear using 'fade out' animation.
   @param delay Delay in seconds until the HUD is hidden.
 */
- (void) hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

/*!
   @property
   @abstract ATGProgressHUD operation mode. The default is ATGProgressHUDModeIndeterminate.
 */
@property (nonatomic, assign) ATGProgressHUDMode mode;
/*!
   @property
   @abstract The UIView (e.g., a UIImageView) to be shown when the HUD is in ATGProgressHUDModeCustomView.
 */
@property (nonatomic, strong) UIView *customView;

/*!
   @property
   @abstract The HUD delegate object.
 */
@property (nonatomic, weak) id <ATGProgressHUDDelegate> delegate;
/*!
   @property
   @abstract An optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit the entire text.
 */
@property (nonatomic, copy) NSString *labelText;

/*!
   @property
   @abstract The opacity of the HUD window. Defaults to 0.8 (80% opacity).
 */
@property (nonatomic, assign) float opacity;
/*!
   @property
   @abstract The color of the HUD window. Defaults to black.
 */
@property (nonatomic, strong) UIColor *color;
/*!
   @property
   @abstract Font to be used for the main label.
 */
@property (nonatomic, strong) UIFont *labelFont;
/*!
   @property
   @abstract The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
 */
@property (nonatomic, assign) float progress;

/*!
   @property
   @abstract The x-axis offset of the HUD relative to the centre of the superview.
 */
@property (nonatomic, assign) float xOffset;
/*!
   @property
   @abstract The y-axis offset of the HUD relative to the centre of the superview.
 */
@property (nonatomic, assign) float yOffset;
/*!
   @property
   @abstract The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views). Defaults to 20.0
 */
@property (nonatomic, assign) float margin;

/*!
   @property
   @abstract Cover the HUD background view with a radial gradient.
 */
@property (nonatomic, assign) BOOL dimBackground;
@end

/*!
   @class
   @abstract Round progress indicator.
 */
@interface ATGRoundProgressView : UIView

/*!
   @property
   @abstract Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float progress;

@end