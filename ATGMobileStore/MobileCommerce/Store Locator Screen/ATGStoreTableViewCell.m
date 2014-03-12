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

#import "ATGStoreTableViewCell.h"
#import "ATGStore+Address.h"
#import <ATGMobileCommon/UIImage+ATGAdditions.h>

const CGFloat ATGStoreCellSelectedHeight = 117;
const CGFloat ATGStoreCellDeselectedHeight = 81;

static const CGFloat ATGTwoLinesLabelHeight = 46;

#pragma mark - ATGStoreTableViewCell private protocol declaration
#pragma mark -

@interface ATGStoreTableViewCell ()
#pragma mark - IB Outlets
@property (nonatomic, weak) IBOutlet UILabel *labelStoreName;
@property (nonatomic, weak) IBOutlet UILabel *labelAddress;
@property (nonatomic, weak) IBOutlet UIView *viewDetailsContainer;
@property (nonatomic, weak) IBOutlet UIButton *buttonMap;
@property (nonatomic, weak) IBOutlet UIButton *buttonCall;
@property (nonatomic, weak) IBOutlet UIButton *buttonEmail;
@property (nonatomic, weak) IBOutlet UIView *viewDivider;

#pragma mark - Custom properties
@property (nonatomic, strong) UIImageView *imageAccessory;

#pragma mark - IB Actions
- (IBAction) didTouchMapButton:(id)sender;
- (IBAction) didTouchCallButton:(id)sender;
- (IBAction) didTouchMailButton:(id)sender;
@end

#pragma mark - ATGStoreTableViewCell Implementation
#pragma mark -

@implementation ATGStoreTableViewCell
#pragma mark - Properties

@synthesize delegate = _delegate, store = _store, viewDivider;
@synthesize labelStoreName, labelAddress, viewDetailsContainer, imageAccessory, buttonMap, buttonCall, buttonEmail;

#pragma mark - Instance Management


#pragma mark - UIView

- (void) awakeFromNib {
  // Setup localized visible captions.
  [[self buttonMap] setTitle:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.MapButtonTitle", nil, [NSBundle mainBundle],
     @"Map", @"Map button title.")
                    forState:UIControlStateNormal];
  [[self buttonCall] setTitle:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.CallButtonTitle", nil, [NSBundle mainBundle],
     @"Call", @"Call button title.")
                     forState:UIControlStateNormal];
  [[self buttonEmail] setTitle:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.EmailButtonTitle", nil, [NSBundle mainBundle],
     @"Email", @"Email button title.")
                      forState:UIControlStateNormal];

  // Set localized accessibility values.
  [[self buttonMap] setAccessibilityLabel:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.MapButtonAccessibilityLabel", nil,
     [NSBundle mainBundle], @"Map", @"Accessibility label for Map button.")];
  [[self buttonMap] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.MapButtonAccessibilityHint", nil,
     [NSBundle mainBundle], @"Displays store on map.",
     @"Accessibility hint for Map button.")];
  [[self buttonCall] setAccessibilityLabel:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.CallButtonAccessibilityLabel", nil,
     [NSBundle mainBundle], @"Call", @"Accessibility label for Call button.")];
  [[self buttonCall] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.CallButtonAccessibilityHint", nil,
     [NSBundle mainBundle], @"Initiates phone call to store.",
     @"Accessibility hint for Call button.")];
  [[self buttonEmail] setAccessibilityLabel:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.EmailButtonAccessibilityLabel", nil,
     [NSBundle mainBundle], @"Email", @"Accessibility label for Email button.")];
  [[self buttonEmail] setAccessibilityHint:NSLocalizedStringWithDefaultValue
     (@"ATGStoreTableViewCell.EmailButtonAccessibilityHint", nil,
     [NSBundle mainBundle], @"Composes email to store.",
     @"Accessibility hint for Email button.")];
  self.imageAccessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-storeCell-more"]];
  self.accessoryView = imageAccessory;
  
  // apply the label styles
  [self.labelStoreName applyStyleWithName:@"formTitleLabel"];
  [self.labelAddress applyStyleWithName:@"formFieldLabel"];
}

- (void) layoutSubviews {
  [super layoutSubviews];

  [[[self buttonMap] titleLabel] applyStyleWithName:@"formFieldLabel"];
  [[[self buttonCall] titleLabel] applyStyleWithName:@"formFieldLabel"];
  [[[self buttonEmail] titleLabel] applyStyleWithName:@"formFieldLabel"];

  [[self buttonMap] applyStyleWithName:@"storeButton"];
  [[self buttonCall] applyStyleWithName:@"storeButton"];
  [[self buttonEmail] applyStyleWithName:@"storeButton"];

  [self buttonEmail].hidden = [self.store.email length] == 0;

  [[self labelStoreName] setText:[self.store name]];
  [[self labelAddress] setText:[self.store address]];

  // Support double and single-lined address/working hours labels.
  // Double and single-lined labels should have different height,
  // because we can't align text vertically (position it on the top).
  // The only way to place the text on top is to minimize label's height.

  // Allow maximum of two lines per label.
  CGSize maxSize = CGSizeMake([[self labelAddress] frame].size.width,
                              ATGTwoLinesLabelHeight);
  UIFont *font = [[self labelAddress] font];
  // Calculate actual text size with font selected.
  CGSize actualSize = [[[self labelAddress] text] sizeWithFont:font
                                             constrainedToSize:maxSize];
  // And update label size.
  CGRect labelRect = [[self labelAddress] frame];
  labelRect.size.height = actualSize.height;
  [[self labelAddress] setFrame:labelRect];

  // need to loop through superviews b/c of iOS 7's TableView vs iOS 6's
  id view = [self superview];
  while (view != nil && [view isKindOfClass:[UITableView class]] == NO){
    view = [view superview];
  }
  UITableView *table = (UITableView *)view;
  NSIndexPath *indexPath = [table indexPathForCell:self];
  if (table && indexPath &&
      [table numberOfRowsInSection:[indexPath section]] == [indexPath row] + 1) {
    [[self viewDivider] setClipsToBounds:YES];
    [[[self viewDivider] layer] setCornerRadius:10];
  }
}

#pragma mark - UITableViewCell

- (void) setSelected:(BOOL)pSelected animated:(BOOL)pAnimated {
  [super setSelected:pSelected animated:pAnimated];
  // We are about to change cell's selection mode.
  // Different accessory images should be used by different selections.
  // Load proper image from the bundle and display it within the accessory.
  if (pSelected) {
    [[self imageAccessory] setImage:[UIImage locateImageNamed:@"icon-storeCell-less.png"]];
  } else {
    [[self imageAccessory] setImage:[UIImage locateImageNamed:@"icon-storeCell-more.png"]];
  }
}

#pragma mark - UI Event Handlers

- (IBAction) didTouchMapButton:(id)pSender {
  // Do nothing by itself, just notify the delegate.
  [[self delegate] didTouchMapButton:self];
}

- (IBAction) didTouchCallButton:(id)pSender {
  // Do nothing by itself, just notify the delegate.
  [[self delegate] didTouchCallButton:self];
}

- (IBAction) didTouchMailButton:(id)pSender {
  // Do nothing by itself, just notify the delegate.
  [[self delegate] didTouchMailButton:self];
}

#pragma mark - UIAccessibilityContainer

- (NSInteger) accessibilityElementCount {
  if ([self isSelected]) {
    return 5;
  } else {
    return 2;
  }
}

- (NSInteger) indexOfAccessibilityElement:(id)pElement {
  if (pElement == [self labelStoreName]) {
    return 0;
  } else if (pElement == [self labelAddress]) {
    return 1;
  } else if (pElement == [self buttonMap] && [self isSelected]) {
    return 2;
  } else if (pElement == [self buttonCall] && [self isSelected]) {
    return 3;
  } else if (pElement == [self buttonEmail] && [self isSelected]) {
    return 4;
  }
  return NSNotFound;
}

- (id) accessibilityElementAtIndex:(NSInteger)pIndex {
  switch (pIndex) {
  case 0:
    return [self labelStoreName];
    break;

  case 1:
    return [self labelAddress];
    break;

  case 2:
    return [self isSelected] ? [self buttonMap] : nil;
    break;

  case 3:
    return [self isSelected] ? [self buttonCall] : nil;
    break;

  case 4:
    return [self isSelected] ? [self buttonEmail] : nil;
    break;

  default:
    return nil;
  }
}

@end