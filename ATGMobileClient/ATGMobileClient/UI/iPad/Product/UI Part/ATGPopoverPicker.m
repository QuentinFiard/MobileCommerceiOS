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

#import "ATGPopoverPicker.h"
#import <ATGUIElements/ATGButton.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>

@interface ATGPopoverPicker ()
@property (nonatomic, strong) UIViewController<ATGPickerViewController> *pickerViewController;
@property (nonatomic, assign) BOOL needsNavigationController;
@property (nonatomic, strong) ATGButton *pickerButton;
@property (nonatomic, strong) UILabel *rightLabel; // Selected value, e.g. Blue
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSObject<ATGPickerDelegate> *delegate;
@end

@implementation ATGPopoverPicker

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  return self;
}

- (id)initWithFrame:(CGRect)frame pickerViewController:(UITableViewController<ATGPickerViewController> *)pPickerViewController type:(NSString *)pType singleValue:(NSString *)pSingleValue delegate:(NSObject<ATGPickerDelegate> *) pDelegate {
  return [self initWithFrame:frame pickerViewController:pPickerViewController needsNavigationController:NO type:pType singleValue:pSingleValue delegate:pDelegate];
}

- (id)initWithFrame:(CGRect)frame pickerViewController:(UITableViewController<ATGPickerViewController> *)pPickerViewController needsNavigationController:(BOOL)pNavigationController type:(NSString *)pType singleValue:(NSString *)pSingleValue delegate:(NSObject<ATGPickerDelegate> *) pDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    self.needsNavigationController = pNavigationController;
    [self setupWithPickerViewController:pPickerViewController type:pType singleValue:pSingleValue delegate:pDelegate];
  }
  return self;
}

- (void)setupWithPickerViewController:(UITableViewController<ATGPickerViewController> *)pTableViewController type:(NSString *)pType singleValue:(NSString *)pSingleValue delegate:(NSObject<ATGPickerDelegate> *) pDelegate {
  self.delegate = pDelegate;
  pTableViewController.delegate = self;
    
  self.pickerButton = [[ATGButton alloc] initWithFrame:self.bounds];
  
  NSString *buttonTitle = [self getButtonTitleForType:pType];
  self.leftLabel = [[UILabel alloc]init];
  [self.leftLabel setText:buttonTitle];
  [self.pickerButton setAccessibilityLabel:buttonTitle];

  self.rightLabel = [[UILabel alloc] init];
  [self.rightLabel applyStyleWithName:@"skuLabel_iPad"];
  self.rightLabel.textAlignment = NSTextAlignmentRight;
  self.rightLabel.backgroundColor = [UIColor clearColor];
  
  if (pSingleValue) {
    // there's only one value--nothing to pick from, so select this value and disable the button
    self.pickerButton.enabled = NO;
    [self didSelectValue:pSingleValue forType:pType];
  } else {
    self.pickerViewController = pTableViewController;
    [self.pickerButton addTarget:self action:@selector(didPressButton) forControlEvents:UIControlEventTouchUpInside];    
  }
  
  [self.pickerButton applyStyleWithName:@"skuButton"];
  [self.leftLabel applyStyleWithName:@"skuButtonLabel_iPad"];
  self.leftLabel.adjustsFontSizeToFitWidth = YES;
  self.leftLabel.minimumScaleFactor = .4;

  [self.pickerButton setTitleStyleName:@"skuLabel_iPad"];
  self.rightLabel.adjustsFontSizeToFitWidth = YES;
  self.rightLabel.minimumScaleFactor = .45;
    
  [self addSubview:self.pickerButton];
  [self.pickerButton addSubview:self.leftLabel];
  [self.pickerButton addSubview:self.rightLabel];
  
  //Turn off auto constraints on the button
  self.pickerButton.translatesAutoresizingMaskIntoConstraints=NO;
  //set the height of the button to the height of the bounds, centered vertically
  [self.pickerButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickerButton(height)]" options:NSLayoutFormatAlignAllCenterY metrics:@{@"height":[NSNumber numberWithFloat:self.bounds.size.height]} views:@{@"pickerButton":self.pickerButton}]];
  //set the width of the button to the width of the bounds
  [self.pickerButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[pickerButton(width)]" options:NSLayoutFormatAlignAllCenterY metrics:@{@"width":[NSNumber numberWithFloat:self.bounds.size.width]} views:@{@"pickerButton":self.pickerButton}]];
  //Turn off auto constraints on the left label
  self.leftLabel.translatesAutoresizingMaskIntoConstraints=NO;
  //and the right label
  self.rightLabel.translatesAutoresizingMaskIntoConstraints=NO;
  //Add horizontal constraint to have 10pt padding on the left, 2 or more pt padding between the labels, and 45pt padding on the right, centering the Y axis on the 2 labels
  [self.pickerButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[buttonLabel(>=30)]-(>=2)-[pickerLabel(>=30)]-45-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"buttonLabel":self.leftLabel,@"pickerLabel":self.rightLabel}]];
  //Set the compression resistance to high for the left label to force the right label to resize and truncate
  //[buttonLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
  //Add vertical constraint to have 2pt padding on top and bottom. Since the Center Y is aligned in the contraint above, this will set both labels to the same Y.
  [self.pickerButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[buttonLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"buttonLabel":self.leftLabel}]];
  
}

- (NSString *)getButtonTitleForType:(NSString *)pType {
  if ([pType isEqualToString:@"quantity"]) {
    return NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.QuantityLabelTitle", nil, [NSBundle mainBundle], @"Quantity", @"The label for the quantity picker");
  }
  else if ([[pType lowercaseString] isEqualToString:@"displayname"]) {
    return NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.DisplaynameLabelTitle", nil, [NSBundle mainBundle], @"Feature", @"The label for the feature picker");
  }
  else if ([[pType lowercaseString] isEqualToString:@"color"]) {
    return NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.ColorLabelTitle", nil, [NSBundle mainBundle], @"Color", @"The label for the color picker");
  }
  else if ([[pType lowercaseString] isEqualToString:@"size"]) {
    return NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.SizeLabelTitle", nil, [NSBundle mainBundle], @"Size", @"The label for the size picker");
  }
  else if ([[pType lowercaseString] isEqualToString:@"woodfinish"]) {
    return NSLocalizedStringWithDefaultValue(@"ATGProductDetailPage.WoodfinishLabelTitle", nil, [NSBundle mainBundle], @"Finish", @"The label for the finish picker");
  }
  else {
    NSString *resourceKey = [NSString stringWithFormat:@"ATGProductDetailPage.%@LabelTitle", [pType capitalizedString]];
    return NSLocalizedString(resourceKey, nil);
  }
}

- (void)didPressButton {
  UIViewController *viewController = self.pickerViewController;
  if (self.needsNavigationController) {
    viewController = [[ATGResizingNavigationController alloc] initWithRootViewController:viewController];
  }
  self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
  if (self.needsNavigationController) {
    ((ATGResizingNavigationController *)viewController).popoverController = self.popover;
  }
  [self.popover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didSelectValue:(NSString *) pSelected forType:(NSString *) pType {
  if (self.pickerViewController) {
    self.pickerViewController.selectedValue = pSelected;
  }
  self.rightLabel.text = pSelected;
  [self.pickerButton setAccessibilityLabel:[NSString stringWithFormat:@"%@ %@", self.leftLabel.text, self.rightLabel.text]];

  if (self.popover) {
    [self.popover dismissPopoverAnimated:YES];
  }
  [self.delegate didSelectValue:pSelected forType:pType];
}

@end
