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

#import "ATGNavigationBar.h"
#import "ATGBarButtonItem.h"

#pragma mark - UINavigationBar Private Protocol Definition
#pragma mark -

@interface UINavigationBar ()

// Define an existing method to avoid warnings.
- (void) pushNavigationItem:(UINavigationItem *)item;

@end

#pragma mark - ATGNavigationBar Private Protocol Definition
#pragma mark -

@interface ATGNavigationBar ()

// Callback method to be called when 'Back' button is touched.
- (void) navigateBack;
// Initializes a navigation item with default 'Back' button and title view.
- (void) updateNavigationItem:(UINavigationItem *)item;

@end

#pragma mark - ATGNavigationBar Implementation
#pragma mark -

@implementation ATGNavigationBar

#pragma mark - Instance Management

#pragma mark - UIView


- (void) layoutSubviews {
  [super layoutSubviews];
  UIView *customView = [[[self topItem] leftBarButtonItem] customView];
  CGFloat leftWidth = 0;
  if (customView) {
    CGSize size = [customView sizeThatFits:[self bounds].size];
    [customView setFrame:CGRectMake(0, 0, size.width, size.height)];
    leftWidth = size.width;
  }
  UIBarButtonItem *rightBarButtonItem = self.topItem.rightBarButtonItem;
  customView = [[[self topItem] rightBarButtonItem] customView];
  CGFloat rightWidth = rightBarButtonItem.width;
  if (customView) {
    CGSize size = [customView sizeThatFits:[self bounds].size];
    [customView setFrame:CGRectMake([self bounds].size.width - size.width, 0,
                                    size.width, size.height)];
    rightWidth = size.width;
  }
  [[[self topItem] titleView] setFrame:CGRectMake(leftWidth, 0,
                                                  [self bounds].size.width - leftWidth - rightWidth,
                                                  [self bounds].size.height)];
  if ([[[self topItem] titleView] isKindOfClass:[UILabel class]])
    [(UILabel *)[[self topItem] titleView] setText:[[self topItem] title]];
}

#pragma mark - UINavigationBar

- (void) pushNavigationItem:(UINavigationItem *)pItem {
  // Always update the item to perform all necessary tweaks before actually pushing it.
  [self updateNavigationItem:pItem];
  [super pushNavigationItem:pItem];
}

- (void) setItems:(NSArray *)pItems animated:(BOOL)pAnimated {
  [super setItems:[NSArray array] animated:NO];
  [pItems enumerateObjectsUsingBlock: ^(id pItem, NSUInteger pIndex, BOOL * pStop)
   {
     [self pushNavigationItem:pItem animated:pAnimated];
   }
  ];
}

- (void) setItems:(NSArray *)pItems {
  [self setItems:pItems animated:NO];
}

#pragma mark - ATGNavigationBar Private Protocol Implementation

- (void) updateNavigationItem:(UINavigationItem *)pItem {
  // If the item has left button already, just leave it alone.
  if (![pItem leftBarButtonItem] && ![pItem hidesBackButton]) {
    // Otherwise create and assign default 'Back' button.
    UIBarButtonItem *backItem = [ATGBarButtonItem backButtonItemForTarget:self
                                                                   action:@selector(navigateBack)];
    [pItem setLeftBarButtonItem:backItem];
  }
  // Use proper title view.
  UIView *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
  [titleView applyStyleWithName:@"whitePageHeaderLabel"];
  [pItem setTitleView:titleView];
}

- (void) navigateBack {
  // This class is always used in conjunction with navigation controller,
  // i.e. its delegate is always a UINavigationController.
  [[self delegate] popViewControllerAnimated:YES];
}

@end
