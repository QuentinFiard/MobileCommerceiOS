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

#import "ATGCheckoutDefaultsViewController.h"
#import "ATGCheckoutDefaultsTableViewCell.h"

#pragma mark - ATGCheckoutDefaultsViewController Private Protocol Definition
#pragma mark -

@interface ATGCheckoutDefaultsViewController ()

@property (nonatomic, readwrite, strong) NSArray *tableViewCells;
@property (nonatomic, readwrite, copy) NSString *selectedShippingMethod;

@end

#pragma mark - ATGCheckoutDefaultsViewController Implementation
#pragma mark -

@implementation ATGCheckoutDefaultsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  // Create cell instances for all checkout defaults options.
  [self setTableViewCells:[[NSArray alloc] initWithObjects:
                     [ATGCheckoutDefaultsTableViewCell newInstance],
                     [ATGCheckoutDefaultsTableViewCell newInstance],
                     [ATGCheckoutDefaultsTableViewCell newInstance], nil]];
  NSString *title = NSLocalizedStringWithDefaultValue(
    @"ATGCheckoutDefaultsViewController.Title", nil, [NSBundle mainBundle],
    @"Checkout Defaults", @"Screen title to be used.");
  [self setTitle:title];
}

- (void) viewDidUnload {
  [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Temp code, just to display the cells.
  [(ATGCheckoutDefaultsTableViewCell *)[[self tableViewCells] objectAtIndex:0] setOptionText:@"Max Murphey"];
  [(ATGCheckoutDefaultsTableViewCell *)[[self tableViewCells] objectAtIndex:0] setDetailsText:@"1 Main St., Cambridge"];
  [(ATGCheckoutDefaultsTableViewCell *)[[self tableViewCells] objectAtIndex:1]
      setOptionText:[self selectedShippingMethod] ? [self selectedShippingMethod] : NSLocalizedStringWithDefaultValue(@"ATGCheckoutDefaulsViewController.DefaultShippingExample.UPS", nil, [NSBundle mainBundle], @"UPS Overnight", @"This is displayed as the default shipping option")];

  // Re-load cells, this will cause the table to recalculate heights.
  [[self tableView] reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  ATGCheckoutDefaultsShippingMethodViewController *mMethodController = segue.destinationViewController;
  mMethodController.delegate = self;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // One section for checkout defaults and one section for action button.
  return 2;
}

- (NSInteger) tableView:(UITableView *)pTableView
  numberOfRowsInSection:(NSInteger)pSection {
  if (pSection == 0) {
    // We have 3 checkout options.
    return 3;
  } else {
    // Only one action button is available.
    return 1;
  }
}

- (UITableViewCell *) tableView:(UITableView *)pTableView
          cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    // All cells already created and stored inside of an array.
    return [[self tableViewCells] objectAtIndex:[pIndexPath row]];
  } else {
    // Button cell will use separate simple instance.
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:@"cell"];
  }
}

- (CGFloat) tableView:(UITableView *)pTableView heightForRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    // Checkout option cells can calculated their heights.
    // All cells already created at this point.
    return [(ATGCheckoutDefaultsTableViewCell *)[[self tableViewCells]
                                                 objectAtIndex:[pIndexPath row]] height];
  } else {
    // Standard height for button cell.
    return [pTableView rowHeight];
  }
}

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
 forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath section] == 0) {
    // Update checkout options captions.
    NSString *caption = nil;
    switch ([pIndexPath row]) {
    case 0 :
      caption = NSLocalizedStringWithDefaultValue(
        @"ATGCheckoutDefaultsViewController.ShipToCaption", nil,
        [NSBundle mainBundle], @"Ship to",
        @"Caption to be displayed before default shipping address. This string is used as a label for the address the order will be shipped to.");
      break;

    case 1:
      caption = NSLocalizedStringWithDefaultValue(
        @"ATGCheckoutDefaultsViewController.ShipViaCaption", nil,
        [NSBundle mainBundle], @"Ship via",
        @"Caption to be displayed before default shipping method.  This string is used as a label for the shipping method to be used");
      break;

    case 2:
      caption = NSLocalizedStringWithDefaultValue(
        @"ATGCheckoutDefaulsViewController.UseCardCaption", nil,
        [NSBundle mainBundle], @"Use card",
        @"Caption to be displayed before default credit card.");
    }
    [(ATGCheckoutDefaultsTableViewCell *) pCell setCaption:caption];
  } else {
    // It's a button cell. Make it transparent.
    UIView *background = [[UIView alloc] init];
    [background setBackgroundColor:[UIColor clearColor]];
    [pCell setBackgroundView:background];
    // Do not allow selection of this row.
    [pCell setSelectionStyle:UITableViewCellSelectionStyleNone];

    // Create a button to be displayed inside this cell.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // Update it with localized title.
    NSString *title = NSLocalizedStringWithDefaultValue(
      @"ATGCheckoutDefaultsViewController.DoneButtonTitle", nil,
      [NSBundle mainBundle], @"Done", @"Title to be displayed on the 'Done' button.");
    [button setTitle:title forState:UIControlStateNormal];
    // And localized accessibility values.
    NSString *label = NSLocalizedStringWithDefaultValue(
      @"ATGCheckoutDefaultsViewController.DoneButtonAccessibilityLabel", nil,
      [NSBundle mainBundle], @"Done",
      @"Accessibility label to be used by the 'Done' button.");
    [button setAccessibilityLabel:label];
    NSString *hint = NSLocalizedStringWithDefaultValue(
      @"ATGCheckoutDefaultsViewController.DoneButtonAccessibilityHint", nil,
      [NSBundle mainBundle], @"Saves your changes.",
      @"Accessibility hint to be used by the 'Done' button");
    [button setAccessibilityHint:hint];
    // Position the button properly inside the cell.
    CGRect contentBounds = [[pCell contentView] bounds];
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 41;
    CGRect buttonFrame = CGRectMake( (contentBounds.size.width - buttonWidth) / 2,
                                     (contentBounds.size.height - buttonHeight) / 2,
                                     buttonWidth, buttonHeight );
    [button setFrame:buttonFrame];
    // And insert the button into the cell.
    [[pCell contentView] addSubview:button];
    // What should we do, when the user taps the button?
    [button addTarget:self action:@selector(didTouchDoneButton:)
     forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  switch ([pIndexPath row]) {
  case 1:
    // We want to change the shipping method. Display proper controller.
    [self performSegueWithIdentifier:@"checkoutDefaultsToCheckoutDefaultsShippingMethods" sender:self];
    break;
  }
}

- (void) didSelectShippingMethod:(NSString *)pMethod {
  // New method just selected, update it.
  [self setSelectedShippingMethod:pMethod];
  // And pop the shipping method screen out.
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) didTouchDoneButton:(id)pSender {
}

@end