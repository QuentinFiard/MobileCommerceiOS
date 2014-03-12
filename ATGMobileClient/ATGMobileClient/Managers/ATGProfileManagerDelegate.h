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
 
 @copyright Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
 @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGProfileManagerDelegate.h#1 $$Change: 848678 $
 
 */
@class ATGProfileManagerRequest;
/*!
 @protocol
 @abstract Callback methods for @link ATGProfileManager @/link
 */
@protocol ATGProfileManagerDelegate <NSObject>
@optional
/*!
 @method
 @abstract Delegate call back when logging in
 */
- (void) didLogIn:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when logging in
 */
- (void) didErrorLoggingIn:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when logging out
 */
- (void) didLogOut:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when logging out
 */
- (void) didErrorLoggingOut:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting the profile
 */
- (void) didGetProfile:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting the profile
 */
- (void) didErrorGettingProfile:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when updating personal information
 */
- (void) didUpdatePersonalInformation:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when updating personal information
 */
- (void) didErrorUpdatingPersonalInformation:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when creating a new user
 */
- (void) didCreateNewUser:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when creating a new user
 */
- (void) didErrorCreatingNewUser:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting details on an order
 */
- (void) didGetOrderDetails:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting details on an order
 */
- (void) didErrorGettingOrderDetails:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting a list of order summaries
 */
- (void) didGetOrdersStartingAt:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting a list of order summaries
 */
- (void) didErrorGettingOrdersStartingAt:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting the user's addresses
 */
- (void) didGetAddresses:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting the user's addresses
 */
- (void) didErrorGettingAddresses:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when updating an address
 */
- (void) didUpdateAddress:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when updating an address
 */
- (void) didErrorUpdatingAddress:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when creating a new user
 */
- (void) didCreateNewAddress:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when creating a new user
 */
- (void) didErrorCreatingNewAddress:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when removing an address
 */
- (void) didRemoveAddress:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when removing an address
 */
- (void) didErrorRemovingAddress:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting the credit cards
 */
- (void) didGetCreditCards:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting the credit cards
 */
- (void) didErrorGettingCreditCards:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when removing a credit card
 */
- (void) didRemoveCreditCard:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when removing a credit card
 */
- (void) didErrorRemovingCreditCard:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when updating a credit card
 */
- (void) didUpdateCreditCard:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when updating a credit card
 */
- (void) didErrorUpdatingCreditCard:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when trying to create an address while updating a credit card
 */
- (void) didUpdateCreditCardAndCreatingAddress:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when trying to create an address while updating a credit card
 */
- (void) didErrorUpdatingCreditCardAndCreatingAddress:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when you want to validate the credit card
 */
- (void) didValidateNewCreditCard:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when you want to validate the credit card
 */
- (void) didErrorValidatingNewCreditCard:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when you want to select an existing address to create a card
 */
- (void) didSelectAddressAndCreateCreditCard:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate call error back when you want to select an existing address to create a card
 */
- (void) didErrorSelectingAddressAndCreatingCreditCard:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when you want to create an address to create a credit card
 */
- (void) didCreateAddressAndCreateCreditCard:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when you want to create an address to create a credit card
 */
- (void) didErrorCreatingAddressAndCreatingCreditCard:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when changing the password
 */
- (void) didChangePassword:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when changing the password
 */
- (void) didErrorChangingPassword:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when reseting the password
 */
- (void) didResetPassword:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when reseting the password
 */
- (void) didErrorResettingPassword:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when getting security status
 */
- (void) didGetSecurityStatus:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when getting security status
 */
- (void) didErrorGettingSecurityStatus:(ATGProfileManagerRequest *)pRequestResults;

/*!
 @method
 @abstract Delegate call back when becoming anonymous
 */
- (void) didBecomeAnonymous:(ATGProfileManagerRequest *)pRequestResults;
/*!
 @method
 @abstract Delegate error call back when becoming anonymous
 */
- (void) didErrorBecomingAnonymous:(ATGProfileManagerRequest *)pRequestResults;
@end

