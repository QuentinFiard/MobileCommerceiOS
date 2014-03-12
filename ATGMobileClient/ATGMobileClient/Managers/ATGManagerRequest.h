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

   @header
   @abstract Base class for all manager requests.

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/ATGManagerRequest.h#1 $$Change: 848678 $

 */

@protocol ATGRestOperation;

/*!
   @class
   @abstract The base class for manager requests.
 */
@interface ATGManagerRequest : NSObject
/*!
   @property
   @abstract The error returned from request
 */
@property (nonatomic, strong) NSError *error;
/*!
   @property
   @abstract The delegate
 */
@property (nonatomic, weak) id delegate;
/*!
   @property
   @abstract The underlying http request
 */
@property (nonatomic, weak) id <ATGRestOperation> operation;
/*!
   @property
   @abstract The whether or not the request has finished
 */
@property (readonly) BOOL done;

/*!
   @method
   @abstract Cancels the request.
   @discussion Canceling the request will result in the error delegate method to
   be called. Clear the delegate before you cancel if you don't want to receive the call-back.
 */
- (void) cancelRequest;

/*!
   @method
   @abstract Executes the selector and passes itself to the selector
   @discussion This method checks to see if the selector exists on the @link ATGManagerRequest ATGManagerRequest's @/link
   @link //apple_ref/occ/instp/ATGManagerRequest/delegate delegate@/link and execute's it
   @param pResponseSelector selector to execute
 */
- (void) sendResponse:(SEL)pResponseSelector;

/*!
   @method
   @abstract Checks to make sure the request hasn't failed authentification
   @discussion This checks the passed in error object and see's if it belongs to the @link ATG_AUTHENTICATION_DOMAIN @/link.
   If it does, it checks to see if the  @link ATGManagerRequest ATGManagerRequest's @/link
   @link //apple_ref/occ/instp/ATGManagerRequest/delegate delegate@/link responds to
   @link //apple_ref/occ/intfm/ATGLoginDelegate/requiresLogin [ATGLoginDelegate requiresLogin]@/link and execute's it
 */
- (BOOL) sendError:(NSError *)pError withSelector:(SEL)pErrorSelector;
@end