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

#import "ATGEditedOrderItemTableViewCell.h"
#import <ATGMobileClient/ATGCommerceItem.h>

// This typedef defines a number of states in which the cell can exist.
// Each state has its own action assigned to be performed when the user touches the confirmation button.
typedef enum {
  ATGRemoveItemState,
  ATGAddToGiftlistState,
  ATGCompareItemState,
  ATGAddToWishlistState
}
ATGShoppingCartItemCellState;

#pragma mark - ATGEditedOrderItemTableViewCell Private Protocol
#pragma mark -

@interface ATGEditedOrderItemTableViewCell ()

#pragma mark - IB Outlets

@property (nonatomic, readwrite, weak) IBOutlet UIButton *removeButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *giftlistButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *compareButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *wishlistButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *confirmButton;
@property (nonatomic, readwrite, strong)IBOutletCollection(UIImageView) NSArray * delimiterImageViews;

#pragma mark - Custom Properties

// This property holds internal cell state.
@property (nonatomic, readwrite) ATGShoppingCartItemCellState state;

#pragma mark - UI Event Handlers

- (IBAction) didTouchRemoveButton:(UIButton *)sender;
- (IBAction) didTouchGiftlistButton:(UIButton *)sender;
- (IBAction) didTouchCompareButton:(UIButton *)sender;
- (IBAction) didTouchWishlistButton:(UIButton *)sender;
- (IBAction) didTouchConfirmButton:(UIButton *)sender;

#pragma mark - Private Protocol Definition

// This method displays the confirmation button. Button's appearance is animated.
// Button will move and expand from the point specified as input parameter.
- (void) animateConfirmButtonAppearanceFromPoint:(CGPoint)point;

@end

#pragma mark - ATGEditedOrderItemTableViewCell Implementation
#pragma mark -

@implementation ATGEditedOrderItemTableViewCell

#pragma mark - Synthesized Properties

@synthesize removeButton;
@synthesize giftlistButton;
@synthesize compareButton;
@synthesize wishlistButton;
@synthesize confirmButton;
@synthesize showsConfirmButton;
@synthesize state;
@synthesize delegate;
@synthesize delimiterImageViews;

#pragma mark - Custom Properties

- (void) setShowsConfirmButton:(BOOL)pShowsConfirmButton {
  if (pShowsConfirmButton == NO) {
    // We're about to reset cell's contents to their default state.
    // By default, action buttons are visible for navigable products only, confirm button is hidden.
    [[self giftlistButton] setHidden:![[self item] isNavigableProduct]];
    [[self compareButton] setHidden:![[self item] isNavigableProduct]];
    [[self wishlistButton] setHidden:![[self item] isNavigableProduct]];
    for (UIImageView *delimiter in[self delimiterImageViews]) {
      [delimiter setHidden:![[self item] isNavigableProduct]];
    }
    [[self confirmButton] setHidden:YES];
    [self setNeedsLayout];
  }
  showsConfirmButton = pShowsConfirmButton;
}

#pragma mark - NSObject

- (void) awakeFromNib {
  [super awakeFromNib];

  NSString *label = NSLocalizedStringWithDefaultValue
                      (@"ATGEditedOrderItemTableViewCell.AccessibilityLabel.RemoveButton",
                       nil, [NSBundle mainBundle], @"Remove",
                      @"Accessibility label to be read by VoiceOver when the user focuses on the Remove button."
                      @"This label is used by the Shopping Cart screen.");
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.RemoveButton",
                      nil, [NSBundle mainBundle], @"Removes an item from the cart.",
                     @"Accessibility hint to be read by VoiceOver when the user focuses on the Remove button."
                     @"This hint is used by the Shopping Cart screen.");
  [[self removeButton] setAccessibilityLabel:label];
  [[self removeButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGEditedOrderItemTableViewCell.AccessibilityLabel.GiftListButton",
             nil, [NSBundle mainBundle], @"Gift list",
            @"Accessibility label to be read by VoiceOver when the user focuses on the Remove button."
            @"This label is used by the Shopping Cart screen.");
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.GiftListButton",
            nil, [NSBundle mainBundle], @"Moves an item from the cart to a gift list.",
           @"Accessibility hint to be read by VoiceOver when the user focuses on the Remove button."
           @"This hint is used by the Shopping Cart screen.");
  [[self giftlistButton] setAccessibilityLabel:label];
  [[self giftlistButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGEditedOrderItemTableViewCell.AccessibilityLabel.WishListButton",
             nil, [NSBundle mainBundle], @"Wish list",
            @"Accessibility label to be read by VoiceOver when the user focuses on the Remove button."
            @"This label is used by the Shopping Cart screen.");
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.WishListButton",
            nil, [NSBundle mainBundle], @"Moves an item from the cart to the wish list.",
           @"Accessibility hint to be read by VoiceOver when the user focuses on the Remove button."
           @"This hint is used by the Shopping Cart screen.");
  [[self wishlistButton] setAccessibilityLabel:label];
  [[self wishlistButton] setAccessibilityHint:hint];
  label = NSLocalizedStringWithDefaultValue
            (@"ATGEditedOrderItemTableViewCell.AccessibilityLabel.CompareButton",
             nil, [NSBundle mainBundle], @"Compare",
            @"Accessibility label to be read by VoiceOver when the user focuses on the Remove button."
            @"This label is used by the Shopping Cart screen.");
  hint = NSLocalizedStringWithDefaultValue
           (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.CompareButton",
            nil, [NSBundle mainBundle], @"Adds an item to the comparisons list.",
           @"Accessibility hint to be read by VoiceOver when the user focuses on the Remove button."
           @"This hint is used by the Shopping Cart screen.");
  [[self compareButton] setAccessibilityLabel:label];
  [[self compareButton] setAccessibilityHint:hint];
}

#pragma mark - UIView

- (void) layoutSubviews {
  [super layoutSubviews];
  [[self confirmButton] setHidden:![self showsConfirmButton]];
}

#pragma mark - UIAccessibility

- (BOOL) isAccessibilityElement {
  // The cell contains a lot of controls, hence it can not be an accessibility element itself.
  return NO;
}

#pragma mark - UIAccessibilityContainer

- (NSInteger) accessibilityElementCount {
  NSInteger result = 2; // Remove button and product details are always displayed.
  if ([self showsConfirmButton]) {
    result += 1; // Confirmation button hides Move to GL/WL & Compare buttons.
  } else {
    // Confirmation button is not displayed, then we're seeing underlay buttons.
    // These buttons are visible for navigable products only.
    result += [[self item] isNavigableProduct] ? 3 : 0;
  }
  return result;
}

- (id) accessibilityElementAtIndex:(NSInteger)pIndex {
  BOOL navigable = [[self item] isNavigableProduct];
  switch (pIndex) {
  case 0: {
    // Read product details first, it's the most important content of the cell.
    UIAccessibilityElement *result = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    NSString *label = [[self nameLabel] text];
    if ([[[self propertiesLabel] text] length]) {
      // Add SKU properties to the output only if there is anything to add, or VoiceOver would read (null).
      label = [label stringByAppendingFormat:@" %@", [[self propertiesLabel] text]];
    }
    [result setAccessibilityLabel:label];
    // VoiceOver frame should be specified in screen coordinates.
    CGRect frame = [self convertRect:[[self contentView] frame] toView:nil];
    [result setAccessibilityFrame:frame];
    return result;
  }

  case 1:
    return [self removeButton];

  case 2:
    return [self showsConfirmButton] ? [self confirmButton] : navigable ? [self giftlistButton] : nil;

  case 3:
    return [self showsConfirmButton] ? nil : navigable ? [self compareButton] : nil;

  case 4:
    return [self showsConfirmButton] ? nil : navigable ? [self wishlistButton] : nil;
  }
  return nil;
}

- (NSInteger) indexOfAccessibilityElement:(id)pElement {
  // We use inner contents as accessibility elements in most of the cases, so we can just compare instances.
  if (pElement == [self confirmButton]) {
    return [self showsConfirmButton] ? 2 : NSNotFound;
  } else if (pElement == [self giftlistButton]) {
    return [self showsConfirmButton] ? NSNotFound : 2;
  } else if (pElement == [self compareButton]) {
    return [self showsConfirmButton] ? NSNotFound : 3;
  } else if (pElement == [self wishlistButton]) {
    return [self showsConfirmButton] ? NSNotFound : 4;
  } else if (pElement == [self removeButton]) {
    return 1;
  } else {
    // By default, focus on product details.
    return 0;
  }
}

#pragma mark - UI Event Handlers

- (void) didTouchRemoveButton:(UIButton *)pSender {
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGEditedOrderItemTableViewCell.TitleRemoveButton",
                       nil, [NSBundle mainBundle], @"Delete Item",
                      @"Title for the Remove Item button. This title will be displayed on the confirmation button"
                      @" presented on the shopping cart item cell in edit mode.");
  [[self confirmButton] setTitle:title forState:UIControlStateNormal];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.ConfirmRemoveButton",
                      nil, [NSBundle mainBundle], @"Confirm removal of the item.",
                     @"Accessibility hint to be read when user focuses on the Confirm Remove button."
                     @"This hint is used by the Shopping Cart screen.");
  [[self confirmButton] setAccessibilityHint:hint];
  [self setState:ATGRemoveItemState];
  [self animateConfirmButtonAppearanceFromPoint:[pSender center]];
}

- (void) didTouchGiftlistButton:(UIButton *)pSender {
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGEditedOrderItemTableViewCell.TitleGiftListButton",
                       nil, [NSBundle mainBundle], @"Move to Gift List",
                      @"Title for the Move to Gift List button. This title will be displayed on the confirmation button"
                      @" presented on the shopping cart item cell in edit mode.");
  [[self confirmButton] setTitle:title forState:UIControlStateNormal];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.ConfirmGiftListButton",
                      nil, [NSBundle mainBundle], @"Confirm movement of the item to a gift list.",
                     @"Accessibility hint to be read when user focuses on the Confirm Gift List button."
                     @"This hint is used by the Shopping Cart screen.");
  [[self confirmButton] setAccessibilityHint:hint];
  [self setState:ATGAddToGiftlistState];
  [self animateConfirmButtonAppearanceFromPoint:[pSender center]];
}

- (void) didTouchCompareButton:(UIButton *)pSender {
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGEditedOrderItemTableViewCell.TitleCompareButton",
                       nil, [NSBundle mainBundle], @"Compare Item",
                      @"Title for the Compare Item button. This title will be displayed on the confirmation button"
                      @" presented on the shopping cart item cell in edit mode.");
  [[self confirmButton] setTitle:title forState:UIControlStateNormal];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.ConfirmCompareButton",
                      nil, [NSBundle mainBundle], @"Confirm addition of the item to the comparisons list.",
                     @"Accessibility hint to be read when user focuses on the Confirm Compare button."
                     @"This hint is used by the Shopping Cart screen.");
  [[self confirmButton] setAccessibilityHint:hint];
  [self setState:ATGCompareItemState];
  [self animateConfirmButtonAppearanceFromPoint:[pSender center]];
}

- (void) didTouchWishlistButton:(UIButton *)pSender {
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGEditedOrderItemTableViewCell.TitleWishListButton",
                       nil, [NSBundle mainBundle], @"Move to Wish List",
                      @"Title for the Move to Wish List button. This title will be displayed on the confirmation button"
                      @" presented on the shopping cart item cell in edit mode.");
  [[self confirmButton] setTitle:title forState:UIControlStateNormal];
  NSString *hint = NSLocalizedStringWithDefaultValue
                     (@"ATGEditedOrderItemTableViewCell.AccessibilityHint.ConfirmWishListButton",
                      nil, [NSBundle mainBundle], @"Confirm movement of the item to the wish list.",
                     @"Accessibility hint to be read when user focuses on the Confirm Wish List button."
                     @"This hint is used by the Shopping Cart screen.");
  [[self confirmButton] setAccessibilityHint:hint];
  [self setState:ATGAddToWishlistState];
  [self animateConfirmButtonAppearanceFromPoint:[pSender center]];
}

- (void) didTouchConfirmButton:(UIButton *)pSender {
  // Just switch proper action to be performed on the item.
  switch ([self state]) {
  case ATGRemoveItemState:
    [[self delegate] itemCellRequestedRemove:self];
    break;

  case ATGCompareItemState:
    [[self delegate] itemCellRequestedCompare:self];
    break;

  case ATGAddToGiftlistState:
    [[self delegate] itemCellRequestedMoveToGiftlist:self];
    break;

  case ATGAddToWishlistState:
    [[self delegate] itemCellRequestedMoveToWishlist:self];
  }
}

#pragma mark - Private Protocol Implementation

- (void) animateConfirmButtonAppearanceFromPoint:(CGPoint)pPoint {
  // The user has touched one of the action buttons. Display the confirmation button.
  [self setShowsConfirmButton:YES];
  [[self confirmButton] setHidden:NO];

  [CATransaction begin];
  [CATransaction setAnimationDuration:.3];
  [CATransaction setCompletionBlock: ^{
     // When everything is set, hide the underlying buttons with their |hidden| property,
     // not with layer's opacity.
     [[self giftlistButton] setHidden:YES];
     [[self compareButton] setHidden:YES];
     [[self wishlistButton] setHidden:YES];
     [[[self giftlistButton] layer] setOpacity:1];
     [[[self compareButton] layer] setOpacity:1];
     [[[self wishlistButton] layer] setOpacity:1];
     for (UIImageView * delimiter in[self delimiterImageViews]) {
       [delimiter setHidden:YES];
       [[delimiter layer] setOpacity:1];
     }
     // Notify VoiceOver that something has changed.
     UIAccessibilityPostNotification (UIAccessibilityLayoutChangedNotification, nil);
   }
  ];

  // Fade animation for the confirmation button.
  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
  [fade setDuration:.3];
  [fade setFromValue:[NSNumber numberWithInteger:0]];
  [fade setToValue:[NSNumber numberWithInteger:1]];
  [[[self confirmButton] layer] addAnimation:fade forKey:@"fade"];

  // And move the confirmation button from the point specified into its proper place.
  CGRect finalFrame = [[self confirmButton] frame];
  CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
  [move setDuration:.3];
  [move setFromValue:[NSValue valueWithCGPoint:pPoint]];
  [move setToValue:[NSValue valueWithCGPoint:CGPointMake( CGRectGetMidX(finalFrame),
                                                          CGRectGetMidY(finalFrame) )]];
  [[[self confirmButton] layer] addAnimation:move forKey:@"move"];

  // Resize the confirmation button to grow from a single point.
  CABasicAnimation *resize = [CABasicAnimation animationWithKeyPath:@"bounds"];
  [resize setDuration:.3];
  [resize setFromValue:[NSValue valueWithCGRect:CGRectZero]];
  [resize setToValue:[NSValue valueWithCGRect:CGRectMake(0, 0,
                                                         finalFrame.size.width,
                                                         finalFrame.size.height)]];
  [[[self confirmButton] layer] addAnimation:resize forKey:@"resize"];

  // Fade animation for three underlaying buttons.
  fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
  [fade setDuration:.3];
  [fade setFromValue:[NSNumber numberWithInteger:1]];
  [fade setToValue:[NSNumber numberWithInteger:0]];
  [[[self giftlistButton] layer] addAnimation:fade forKey:@"fade"];
  [[[self compareButton] layer] addAnimation:fade forKey:@"fade"];
  [[[self wishlistButton] layer] addAnimation:fade forKey:@"fade"];
  for (UIImageView *delimiter in[self delimiterImageViews]) {
    [[delimiter layer] addAnimation:fade forKey:@"fade"];
  }
  // Set layer's opacity to 0 to prevent buttons from blinking at the very end of the animation.
  // We'll set opacity to its default value with animation's completion block.
  [[[self giftlistButton] layer] setOpacity:0];
  [[[self compareButton] layer] setOpacity:0];
  [[[self wishlistButton] layer] setOpacity:0];
  for (UIImageView *delimiter in[self delimiterImageViews]) {
    [[delimiter layer] setOpacity:0];
  }

  [CATransaction commit];
}

@end