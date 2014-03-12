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
   @abstract The base class used for orders

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Model/ATGOrder.h#1 $$Change: 848678 $

 */

#import "ATGRestEntity.h"
#import "ATGContactInfo.h"
#import "ATGCreditCard.h"
#import "ATGOrderPriceInfo.h"

@class ATGOrderPriceInfo;

/*!
   @class ATGGiftMessage
   @abstract This class represents a gift message applied to order.
 */
@interface ATGGiftMessage : NSObject

/*!
   @property from
   @abstract Defines gift message's author.
 */
@property (nonatomic, readwrite, strong) NSString *from;
/*!
   @property to
   @abstract Defines gift message's recipient.
 */
@property (nonatomic, readwrite, strong) NSString *to;
/*!
   @property text
   @abstract Defines gift message's text.
 */
@property (nonatomic, readwrite, strong) NSString *text;

@end

/*!
   @class
   @abstract The interface for orders
 */
@interface ATGOrder : ATGRestEntity

@property (nonatomic, strong) NSArray *shippingGroups;
@property (nonatomic, strong) NSDecimalNumber *storeCreditsAppliedTotal;
@property (nonatomic, strong) NSDecimalNumber *storeCreditsAvailable;
@property (nonatomic, strong) ATGOrderPriceInfo *priceInfo;
@property (nonatomic, copy) NSArray *commerceItems;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *orderDescription;
@property (nonatomic, strong) NSNumber *totalItems;
@property (nonatomic, strong) NSDate *submittedDate;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) ATGContactInfo *shippingAddress;
@property (nonatomic, strong) ATGCreditCard *creditCard;
@property (nonatomic, copy) NSString *shippingMethod;
@property (nonatomic, copy) NSArray *appliedPromotions;
@property (nonatomic, readonly) int index;
@property (nonatomic) BOOL containsGiftWrap;
@property (nonatomic, strong) NSNumber *shippingGroupCount;
@property (nonatomic, copy, readwrite) NSString *couponCode;
@property (nonatomic, strong) NSNumber *totalCommerceItemCount;
@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, strong) NSNumber *securityStatus;
@property (nonatomic, readwrite, strong) ATGGiftMessage *giftMessage;
@property (nonatomic, strong) NSString *thumbnailImageUrl;
@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSString *parentOrderId;
@property (nonatomic, strong) NSArray *returnRequests;
@property (nonatomic, assign) BOOL returnable;
@property (nonatomic, strong) NSString *originOfOrder;
@property (nonatomic, strong) NSString *profileId;
@property (nonatomic, strong) NSDate *lastModifiedTime;
@property (nonatomic, strong) NSArray *relationships;
@property (nonatomic, strong) NSArray *paymentGroupRelationships;
@property (nonatomic) BOOL transient;

- (id) initWithIndex:(int)pIndex;

@end