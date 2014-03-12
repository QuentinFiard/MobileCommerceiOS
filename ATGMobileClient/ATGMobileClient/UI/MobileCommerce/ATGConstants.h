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
   @const
   @abstract Height of the screen for devices with phone idiom user interface.
 */
extern CGFloat const ATGPhoneScreenHeight;

/*!
   @const
   @abstract Width of the screen for devices with phone idiom user interface.
 */
extern CGFloat const ATGPhoneScreenWidth;

/*!
   @const
   @abstract Max height available for popover.
 */
extern CGFloat const ATGPopoverMaxHeight;

/*!
   @const
   @abstract Min starting height for popover.
 */
extern CGFloat const ATGPopoverMinHeight;

/*!
   @const CONTACT_US_EMAIL_PROPERTY_NAME
   @abstract Specifies a property name in the Info.plist file to be used as email address.
 */
extern NSString *const ATG_CONTACT_US_EMAIL_PROPERTY_NAME;

/*!
   @const CONTACT_US_PHONE_PROPERTY_NAME
   @abstract Specifies a property name in the Info.plist file to be used as phone number.
 */
extern NSString *const ATG_CONTACT_US_PHONE_PROPERTY_NAME;

/*!
   @const
   @abstract Segue id. Source controller is more view controller. Destination controller is more details controller.
 */
extern NSString *const ATGSegueIdMoreToMoreDetails;

/*!
   @const
   @abstract Segue id. Source controller is shopping cart controller. Destination controller is shipping addresses view controller.
 */
extern NSString *const ATGSegueIdCartToShippingAddresses;

/*!
   @const
   @abstract Segue id. Source controller is credit cards view controller. Destination controller is credit card create view controller.
 */
extern NSString *const ATGSegueIdCreditCardsToCreditCardCreate;

/*!
   @const
   @abstract Segue id. Source controller is credit cards view controller. Destination controller is credit card edit view controller.
 */
extern NSString *const ATGSegueIdCreditCardsToCreditCardEdit;

/*!
   @const
   @abstract Segue id. Source controller is shipping methods view controller. Destination controller is credit cards view controller.
 */
extern NSString *const ATGSegueIdShippingMethodsToCreditCards;

/*!
   @const
   @abstract Segue id. Source controller is credit cards view controller. Destination controller is CVV controller.
 */
extern NSString *const ATGSegueIdCreditCardsToCVV;

/*!
   @const
   @abstract Segue id. Source controller is credit card create view controller. Destination controller is billing addresses view controller.
 */
extern NSString *const ATGSegueIdCreditCardCreateToBillingAddresses;

/*!
   @const
   @abstract Segue id. Source controller is profile credit card create view controller. Destination controller is credit card type select view controller.
 */
extern NSString *const ATGSegueIdCreditCardCreateToCreditCardTypes;

/*!
   @const
   @abstract Segue id. Source controller is the one embedding address section. Destination controller is picker view controller.
 */
extern NSString *const ATGSegueIdAddressEditToPicker;

/*!
   @const
   @abstract Segue id. Source controller is billing addresses controller. Destination controller is profile billing address edit controller.
 */
extern NSString *const ATGSegueIdBillingAddressesToProfileBillingAddressEdit;

/*!
   @const
   @abstract Segue id. Source controller is billing addresses controller. Destination controller is checkout billing address edit controller.
 */
extern NSString *const ATGSegueIdBillingAddressesToCheckoutBillingAddressEdit;

/*!
   @const
   @abstract Segue id. Source controller is order review view controller. Destination controller is shipping addresses view controller.
 */
extern NSString *const ATGSegueIdOrderReviewToShippingAddresses;

/*!
   @const
   @abstract Segue id. Source controller is order review view controller. Destination controller is shipping methods view controller.
 */
extern NSString *const ATGSegueIdOrderReviewToShippingMethods;

/*!
   @const
   @abstract Segue id. Source controller is order review view controller. Destination controller is more details view controller.
 */
extern NSString *const ATGSegueIdOrderReviewToMoreDetails;

/*!
   @const
   @abstract Segue id. Source controller is order review view controller. Destination controller is order placed view controller.
 */
extern NSString *const ATGSegueIdOrderReviewToOrderPlaced;

/*!
   @const
   @abstract Segue id. Source controller is order review view controller. Destination controller is credit cards view controller.
 */
extern NSString *const ATGSegueIdOrderReviewToCreditCards;

/*!
 @const
 @abstract Segue id. Source controller is shipping address edit view controller. Destination controller is shipping methods view controller.
 */
extern NSString *const ATGSegueIdShippingAddressEditToShippingMethods;

/*!
 @const
 @abstract Segue id. Source controller is billing addresses view controller. Destination controller is CVV view controller.
 */
extern NSString *const ATGSegueIdBillingAddressesToCVV;

/*!
 @const
 @abstract Segue id. Source controller is product details view controller. Destination controller is more details view controller.
 */
extern NSString *const ATGSegueIdProductToMoreDetails;

/*!
   @const
   @abstract Login url from main site. Used for full site navigation.
 */
extern NSString *const ATGUrlLogin;

/*!
   @const
   @abstract Order details navigation redirect url.
 */
extern NSString *const ATGUrlOrderDetail;

/*!
 @constant
 @abstract default prefix for EM constructed objects.
 */
extern NSString *const EM_CLASS_PREFIX;

/*!
 @constant
 @abstract default prefix for ATG constructed objects.
 */
extern NSString *const ATG_CLASS_PREFIX;


@interface ATGConstants : NSObject

@end