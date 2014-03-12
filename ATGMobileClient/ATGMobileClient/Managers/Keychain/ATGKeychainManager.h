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
   @abstract Manager for saving things in the keychain

   @copyright Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
   @version $Id: //hosting-blueprint/MobileCommerce/version/11.0/clients/iOS/MobileCommerce/ATGMobileClient/ATGMobileClient/Managers/Keychain/ATGKeychainManager.h#1 $$Change: 848678 $

 */

#import <Security/Security.h>

/*!
   @const
   @abstract User email will be stored with this key.
 */
extern NSString *const ATG_KEYCHAIN_EMAIL_PROPERTY;
/*!
   @const
   @abstract User password will be stored with this key.
 */
extern NSString *const ATG_KEYCHAIN_PASSWORD_PROPERTY;
/*!
   @const
   @abstract User name will be stored with this key.
 */
extern NSString *const ATG_KEYCHAIN_NAME_PROPERTY;
/*!
   @const
   @abstract Current device locale will be stored with this key.
 */
extern NSString *const ATG_KEYCHAIN_LOCALE_PROPERTY;

/*!
   @class ATGKeychainManager
   @abstract This class saves and retrieves data into/from a keychain.
   @discussion Use instance of this class, if you need to save or retrieve
   some private data.

   All data is saved as a generic password, that is all data is stored in an
   encrypted state.
 */
@interface ATGKeychainManager : NSObject

/*!
   @method instance
   @abstract Retrieves an ATGKeychainManager instance.
   @discussion This method returns a singleton ATGKeychainManager instance.
   It creates a new instance on first call only.
   @return Fully initialized ATGKeychainManager instance.
 */
+ (ATGKeychainManager *) instance;

/*!
   @method stringForKey:
   @abstract Retrieves a string from a keychain.
   @param key Key to be used when searching for a string.
   @return String saved in a keychain.
 */
- (NSString *) stringForKey:(NSString *)key;
/*!
   @method setString:forKey:
   @abstract Saves a value into a keychain by the key specified.
   @discussion If no value saved by the key specified, a new keychain item
   will be created to store the value. Otherwise an existing item will be updated.
   @param string String to be saved into keychain.
   @param key Key to be used.
 */
- (void) setString:(NSString *)string forKey:(NSString *)key;
/*!
   @method removeStringForKey:
   @abstract Removes a value from the keychain by the key specified.
   @param key Key to be used to find an item to be removed.
 */
- (void) removeStringForKey:(NSString *)key;

@end