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

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ATGMobileClient/ATGCommerceManager.h>
#import <ATGMobileClient/ATGStoreManager.h>
#import <ATGUIElements/ATGTextField.h>
#import <ATGUIElements/ATGButtonTableViewCell.h>
#import <ATGUIElements/ATGKeyboardToolbar.h>
#import <ATGUIElements/ATGValidatableInput.h>
#import <ATGUIElements/ATGValidatableDropdown.h>
#import "ATGResizingNavigationController.h"
#import "ATGPickerViewController.h"
#import <ATGMobileClient/ATGProfileManagerDelegate.h>

@class ATGManagerRequest;
@class ATGContactInfo;

/*!
   @class
   @abstract Phone number input validator
 */
@interface ATGPhoneValidator : NSObject <ATGInputValidator>
@end

/*!
   @const
   @abstract Type indicating states value selection
 */
extern NSString * const ATGPickerSelectionTypeStates;
/*!
   @const
   @abstract Type indicating countries value selection
 */
extern NSString *const ATGPickerSelectionTypeCountries;

/*!
   @typedef
   @abstract Type definition enumeration for input field tags
 */
typedef enum {
  ATGAddressNickNameInput = 100,
  ATGAddressFirstNameInput,
  ATGAddressLastNameInput,
  ATGAddressStreet1Input,
  ATGAddressStreet2Input,
  ATGAddressCityInput,
  ATGAddressStateInput,
  ATGAddressCountryInput,
  ATGAddressZipInput,
  ATGAddressPhoneInput,
}
ATGAddressInputTag;

extern NSUInteger const ATGAddressNickNameInputLimit;
extern NSUInteger const ATGAddressFirstNameInputLimit;
extern NSUInteger const ATGAddressLastNameInputLimit;
extern NSUInteger const ATGAddressStreet1InputLimit;
extern NSUInteger const ATGAddressStreet2InputLimit;
extern NSUInteger const ATGAddressCityInputLimit;
extern NSUInteger const ATGAddressStateInputLimit;
extern NSUInteger const ATGAddressCountryInputLimit;
extern NSUInteger const ATGAddressZipInputLimit;
extern NSUInteger const ATGAddressPhoneInputLimit;
extern NSUInteger const ATGAddressDefaultInputLimit;

@interface ATGAddressSection : NSObject <UIPickerViewDelegate, UIPickerViewDataSource,
    UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate,
    ATGProfileManagerDelegate, ATGStoreManagerDelegate, ATGKeyboardToolbarDelegate,
    ATGPickerViewControllerDelegate>

/*!
 @property shouldUpdateProfile
 @abstract Set this property to YES, if newly created address should be added to user profile.
 @discussion Default value is YES.
 */
@property (nonatomic, readwrite, assign) BOOL shouldUpdateProfile;
/*!
 @property request
 @abstract Currently running REST request.
 */
@property (nonatomic, readwrite, strong) ATGManagerRequest *request;
/*!
 @property storeRequest
 @abstract Currently running store REST request.
 */
@property (nonatomic, readwrite, strong) ATGStoreManagerRequest *storeRequest;
/*!
 @property delegate
 @abstract Section's delegate to be used.
 */
@property (nonatomic, weak) ATGTableViewController *delegate;
/*!
   @property address
   @abstract contact info properties container
 */
@property (nonatomic, strong) ATGContactInfo *address;
/*!
   @property creditCard
   @abstract credit card properties container
 */
@property (nonatomic, strong) ATGCreditCard *creditCard;
/*!
   @property isCreating
   @abstract flag indicating cases when address is being created or updated
 */
@property (nonatomic, readwrite) BOOL creating;
/*!
   @property showsContacts
   @abstract flag indicating whether 'contacts' button will be rendered
 */
@property (nonatomic, readwrite) BOOL showsContacts;
/*!
   @property showsNickname
   @abstract flag indicating whether 'contacts' button will be rendered
 */
@property (nonatomic, readwrite) BOOL showsNickname;
/*!
   @property showsDelete
   @abstract flag indicating whether 'delete' button will be rendered
 */
@property (nonatomic, readwrite) BOOL showsDelete;
/*!
   @property
   @abstract flag indicating whether 'use as default' button will be rendered
 */
@property (nonatomic, readwrite) BOOL showsMarkDefault;
/*!
   @property
   @abstract table section index, at which address content is rendered
 */
@property (nonatomic, readwrite) NSInteger startSection;
/*!
   @property
   @abstract table section index, error cells will be potentially attached to
 */
@property (nonatomic, readwrite) NSInteger errorsSection;
/*!
 @property
 @abstract calculated table section index, error cells will be really attached to
 */
@property (nonatomic, readwrite) NSUInteger calculatedErrorsSection;
/*!
   @property width
   @abstract width of the control
 */
@property (nonatomic, readwrite) NSInteger width;
/*!
 @property
 @abstract is this address section contained within a modal?  Note that this property must be explicitly set to YES.
 */
@property(nonatomic) BOOL isInModal;

/*!
 @method
 @abstract Shows contact picker
 */
- (void) showContactPicker;
/*!
   @method
   @abstract Called after controller's viewDidLoad
 */
- (void) viewDidLoad;
/*!
   @method
   @abstract Called before controller's viewDidUnload
 */
- (void) viewDidUnload;
/*!
   @method
   @abstract Called after controller's viewWillAppear:
 */
- (void) viewWillAppear:(BOOL)animated;
/*!
   @method
   @abstract Called after controller's viewWillDisappear:
 */
- (void) viewWillDisappear:(BOOL)animated;
/*!
   @method
   @abstract Called after controller's prepareForSegue::
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
/*!
   @method
   @abstract Returns number of sections in this address widget
 */
- (NSInteger) numberOfSections;
/*!
   @method
   @abstract Returns number of rows in section in this address widget
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section;
/*!
   @method
   @abstract Renders cell for index path in this address widget
 */
- (UITableViewCell *) cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method
   @abstract Updates cell data in this address widget
 */
- (void) willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method
   @abstract Returns cell height in this address widget
 */
- (CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method
   @abstract Cell selection callback in this address widget
 */
- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/*!
   @method
   @abstract Called after submitting changes
 */
- (void) didSubmitDone;
/*!
   @method
   @abstract Called before submitting changes
 */
- (void) willSubmitDone;
/*!
   @method
   @abstract Presents country picker view
 */
- (void) presentCountriesPickerController;
/*!
   @method
   @abstract Presents state picker view
 */
- (void) presentStatesPickerController;

@end