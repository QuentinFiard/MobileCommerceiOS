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

#import "ATGProfileManager.h"

@class ATGProfile;
@class ATGContactInfo;
@class ATGCreditCard;
@protocol ATGExternalProfileManagerDelegate;


@interface ATGExternalProfileManager : ATGProfileManager

+(ATGExternalProfileManager *) profileManager;

/*!
   @method
   @abstract Updates the personal info on the server
   @param pPersonalInfo new personal info of the user
   @param pEmail the old email address of the user, or current if unchanged
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)updatePersonalInformation:(ATGProfile *)pPersonalInfo withOldEmail:(NSString *)pEmailAddress delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Creates a new user
   @param pPersonalInfo info object of the user
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) createNewUser:(ATGProfile *)pPersonalInfo additionalInfo:(NSDictionary *)pAddInfo
                             delegate:(id <ATGProfileManagerDelegate>)pDelegate;
/*!
   @method createNewUser:duringCheckout:delegate
   @abstract Registers a new user.
   @param personalInfo Aggregates necessary user info to be set on new user.
   @param pAddInfo Additional info for user (date of birth, gender & etc).
   @param duringCheckout Pass YES if this call is made from the checkout process screen.
   @param delegate Delegate to be notified about request events.
   @return Instance of request passed to server.
 */
- (ATGProfileManagerRequest *) createNewUser:(ATGProfile *)personalInfo additionalInfo:(NSDictionary *)pAddInfo
                       duringCheckout:(BOOL)duringCheckout
                             delegate:(id <ATGProfileManagerDelegate>)delegate;

/*!
   @method
   @abstract Places a @link ATGOrder @/link object in the request results
   @param pOrderId the order id of the order that is requested
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) getOrderDetails:(NSString *)pOrderId
                               delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Places an @link NSArray @/link of @link ATGOrder @/link objects in the request results
   @param pStart the start index to request orders from (MUST START > 0)
   @param pHowMany how many orders should be returned
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)getOrdersStartingAt:(NSNumber *)pStart andReturn:(NSNumber *)pHowMany delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Places an @link NSArray @/link of @link ATGContactInfo @/link objects in the request results
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)getAddresses:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Updates the address
   @param pAddress the new address to send to the server
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)updateAddress:(ATGContactInfo *)pAddress delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Creates a new address on the server
   @param pAddress the new address to create
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)createNewAddress:(ATGContactInfo *)pAddress delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Removes the specified address from the server
   @param pNickName nickname of the address to move
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)removeAddress:(NSString *)pNickName delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Places an NSArray of @link ATGCreditCard @/link objects into the request results
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)getCreditCards:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Removes the credit card from the server
   @param pNickName the nickname of the credit card to remove
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)removeCreditCard:(NSString *)pNickName delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Updates the credit card.  If you are changing the nickname, the nickname property
   should be the old nickname.  newNickname is the for the new nickname value.  You can only
   edit the nickname, expiration Year, expiration Month, and the selectedBillingAddress.
   @param pDefault sets credit card as the default credit card
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)updateCreditCard:(ATGCreditCard *)pCreditCard useAsDefault:(BOOL)pDefault delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Places a new credit card in the session.  This credit card is validated,
   and only becomes submitted once you call the corresponding method to add billing address
   to a new credit card
   @param pCreditCard the credit card to create
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)validateNewCreditCard:(ATGCreditCard *)pCreditCard save:(BOOL)pSave useAsDefault:(BOOL)pDefault delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Attaches an address to a credit card and submits the credit card to the repository
   @param pSelectedAddress nickname of the address you want to use for the creditCard
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)selectAddressAndCreateCreditCard:(NSString *)pSelectedAddress delegate:(id <ATGProfileManagerDelegate>)pDelegate;

/*!
   @method
   @abstract Creates the address and creates the credit card that was in the session.  nickname
   should not be used on the contactInfo but newNickname should be used
   @param pAddress new address to add to card
   @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *)createAddressAndCreateCreditCard:(ATGContactInfo *)pAddress delegate:(id <ATGProfileManagerDelegate>)pDelegate;


/*!
 @method
 @abstract Makes sure the current user is anonymous.
 @param pDelegate the requests delegate
 */
- (ATGProfileManagerRequest *) becomeAnonymous:(id <ATGProfileManagerDelegate>)pDelegate;


@end