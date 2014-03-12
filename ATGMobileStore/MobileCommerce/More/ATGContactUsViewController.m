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

#import "ATGContactUsViewController.h"

static NSString *const ATGEmailIconFileName = @"icon-email.png";
static NSString *const ATGPhoneIconFileName = @"icon-phoneDial.png";

#pragma mark - ATGMockViewAccessibilityElement
#pragma mark -

@interface ATGMockViewAccessibilityElement : UIAccessibilityElement

@property (nonatomic, readwrite, weak) UIView *view;

@end

#pragma mark - ATGContactUsTableViewCell Interface
#pragma mark -

@interface ATGContactUsTableViewCell : UITableViewCell

@end

#pragma mark - ATGContactUsViewController Private Protocol
#pragma mark -

// Private protocol, defines UI events.
@interface ATGContactUsViewController ()

// User has touched the 'Phone' button.
- (void) didTouchPhoneButton:(id)sender;
// User has touched the 'Email' button.
- (void) didTouchEmailButton:(id)sender;

@end

#pragma mark - ATGContactUsViewController Implementation
#pragma mark -

@implementation ATGContactUsViewController

#pragma mark - UIViewController+ATGToolbar Category Implementation

+ (UIImage *) toolbarIcon {
  return [UIImage imageNamed:@"icon-more"];
}

+ (NSString *) toolbarAccessibilityLabel {
  return NSLocalizedStringWithDefaultValue(@"ATGViewController.ContactUsAccessibilityLabel",
                                           nil, [NSBundle mainBundle],
                                           @"Contact Us",
                                           @"More - Contact Us toolbar button accessibility label");
}

#pragma mark - View Management

- (void) viewDidLoad {
  [super viewDidLoad];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  // Set proper screen title.
  NSString *title = NSLocalizedStringWithDefaultValue
                      (@"ATGMoreViewController.ScreenTitle", nil, [NSBundle mainBundle],
                      @"Contact Us", @"Screen title to be displayed on the 'Contact Us' screen.");
  [self setTitle:title];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)pTableView {
  // All cells should be displayed in a single section.
  return 1;
}

- (NSInteger) tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  // How many cells do we have here?
  return 1;
}

- (UITableViewCell *) tableView:(UITableView *)pTableView
          cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 0) {
    ATGContactUsTableViewCell *cell = [[self tableView]
                                       dequeueReusableCellWithIdentifier:@"contactCell"];
    if (!cell) {
      cell = [[ATGContactUsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"contactCell"];
      [cell setAccessibilityTraits:UIAccessibilityTraitStaticText];
      // This cell will not display new screen, do not allow it to have an accessory.
      [cell setAccessoryType:UITableViewCellAccessoryNone];

      CGSize contentSize = [[cell contentView] bounds].size;

      // First, 'Phone' button.
      CGRect phoneFrame = CGRectMake(contentSize.width / 3, -1,
                                     contentSize.width / 3, contentSize.height + 2);
      UIButton *phoneButton = [[UIButton alloc] initWithFrame:phoneFrame];
      [phoneButton setImage:[UIImage imageNamed:ATGPhoneIconFileName]
                   forState:UIControlStateNormal];
      [phoneButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
      [[phoneButton titleLabel] applyStyleWithName:@"formTitleLabel"];
      NSString *phoneTitle = NSLocalizedStringWithDefaultValue
                               (@"ATGMoreViewController.PhoneButtonTitle", nil, [NSBundle mainBundle],
                               @"Phone", @"Title to be displayed on the 'Phone' button.");
      [phoneButton setTitle:phoneTitle forState:UIControlStateNormal];
      NSString *phoneLabel = NSLocalizedStringWithDefaultValue
                               (@"ATGMoreViewController.PhoneButtonAccessibilityLabel", nil, [NSBundle mainBundle],
                               @"Phone", @"Accessibility label to be used by the 'Phone' button.");
      [phoneButton setAccessibilityLabel:phoneLabel];
      NSString *phoneHint = NSLocalizedStringWithDefaultValue
                              (@"ATGMoreViewController.PhoneButtonAccessibilityHint", nil, [NSBundle mainBundle],
                              @"Initiates a call.", @"Accessibility hint to be used by the 'Phone' button.");
      [phoneButton setAccessibilityHint:phoneHint];
      [phoneButton setTitleColor:[UIColor textColor] forState:UIControlStateNormal];
      [phoneButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
       UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
      [[phoneButton layer] setBorderColor:[[UIColor borderColor] CGColor]];
      [[phoneButton layer] setBorderWidth:1];
      [phoneButton addTarget:self action:@selector(didTouchPhoneButton:)
            forControlEvents:UIControlEventTouchUpInside];
      [[cell contentView] addSubview:phoneButton];
      [phoneButton setTag:1];

      // Next, create 'Email' button.
      CGRect emailFrame = CGRectMake(contentSize.width - contentSize.width / 3, -1,
                                     contentSize.width / 3, contentSize.height + 2);
      UIButton *emailButton = [[UIButton alloc] initWithFrame:emailFrame];
      [emailButton setImage:[UIImage imageNamed:ATGEmailIconFileName]
                   forState:UIControlStateNormal];
      [emailButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
      [[emailButton titleLabel] applyStyleWithName:@"formTitleLabel"];

      NSString *emailTitle = NSLocalizedStringWithDefaultValue
                               (@"ATGMoreViewController.EmailButtonTitle", nil, [NSBundle mainBundle],
                               @"Email", @"Title to be displayed on the 'Email' button.");
      [emailButton setTitle:emailTitle forState:UIControlStateNormal];
      NSString *emailLabel = NSLocalizedStringWithDefaultValue
                               (@"ATGMoreViewController.EmailButtonAccessibilityLabel", nil, [NSBundle mainBundle],
                               @"Email", @"Accessibility label to be used by the 'Email' button.");
      [emailButton setAccessibilityLabel:emailLabel];
      NSString *emailHint = NSLocalizedStringWithDefaultValue
                              (@"ATGMoreViewController.EmailButtonAccessibilityHint", nil, [NSBundle mainBundle],
                              @"Composes an email.", @"Accessibility hint to be used by the 'Email' button.");
      [emailButton setAccessibilityHint:emailHint];
      [emailButton setTitleColor:[UIColor textColor] forState:UIControlStateNormal];
      [emailButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
       UIViewAutoresizingFlexibleLeftMargin];
      [emailButton addTarget:self action:@selector(didTouchEmailButton:)
            forControlEvents:UIControlEventTouchUpInside];
      [[cell contentView] addSubview:emailButton];
      [emailButton setTag:2];

      [cell setClipsToBounds:YES];
    }
    return cell;
  }
  return nil;
}

#pragma mark - UITableViewCellDelegate

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
 forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Update cell's caption. Each cell will have a caption based on the index path.
  NSString *rowTitle = nil;
  switch ([pIndexPath row]) {
  case 0:
    rowTitle = NSLocalizedStringWithDefaultValue
                 (@"ATGMoreViewController.ContactUsRowTitle", nil, [NSBundle mainBundle],
                 @"Contact Us", @"Title to be displayed on the 'Contact Us' row.");
    break;  
  }
  
  if ([pIndexPath row] == 0) {
    [[pCell textLabel] applyStyleWithName:@"formTitleLabel"];
  }
  [[pCell textLabel] setText:rowTitle];

  [pCell setBackgroundColor:[UIColor tableCellBackgroundColor]];

  if ([pIndexPath row] == 0) {
    [[pCell textLabel] setBackgroundColor:[UIColor clearColor]];

    [pCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    // It's a buttons row. Create the buttons.
    CGSize contentSize = [[pCell selectedBackgroundView] bounds].size;

    UIGraphicsBeginImageContext(contentSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[[pCell selectedBackgroundView] layer] renderInContext:context];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIButton *phoneButton = (UIButton *)[pCell viewWithTag:1];
    CGRect phoneFrame = [phoneButton frame];
    phoneFrame = [[pCell backgroundView] convertRect:phoneFrame
                                            fromView:[pCell contentView]];
    UIGraphicsBeginImageContext(phoneFrame.size);
    [backgroundImage drawAtPoint:CGPointMake(-phoneFrame.origin.x, -phoneFrame.origin.y)];
    UIImage *phoneBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [phoneButton setBackgroundImage:phoneBackground forState:UIControlStateHighlighted];
    [phoneButton setTitleColor:[UIColor textHighlightedColor] forState:UIControlStateHighlighted];

    UIButton *emailButton = (UIButton *)[pCell viewWithTag:2];
    CGRect emailFrame = [emailButton frame];
    emailFrame = [[pCell backgroundView] convertRect:emailFrame
                                            fromView:[pCell contentView]];
    UIGraphicsBeginImageContext(emailFrame.size);
    [backgroundImage drawAtPoint:CGPointMake(-emailFrame.origin.x, -emailFrame.origin.y)];
    UIImage *emailBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [emailButton setBackgroundImage:emailBackground forState:UIControlStateHighlighted];
    [emailButton setTitleColor:[UIColor textHighlightedColor] forState:UIControlStateHighlighted];

    UIView *contents = [pCell contentView];
    [[contents layer] setMask:[pCell createMaskForIndexPath:pIndexPath
                                                inTableView:pTableView]];
    [pCell addSubview:contents];

    [pCell setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
}

- (NSIndexPath *) tableView:(UITableView *)pTableView
   willSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] == 0) {
    // Do not allow to select first row.
    return nil;
  }
  return pIndexPath;
}

- (CGFloat) tableView:(UITableView *)pTableView heightForFooterInSection:(NSInteger)pSection {
  return [[self         tableView:[self tableView]
           viewForFooterInSection:pSection] bounds].size.height + 50;
}

- (UIView *) tableView:(UITableView *)pTableView viewForFooterInSection:(NSInteger)pSection {
  UILabel *footer = [[UILabel alloc] initWithFrame:CGRectZero];
  [footer applyStyleWithName:@"copyrightLabel"];
  NSString *copyright = NSLocalizedStringWithDefaultValue
                          (@"ATGMoreViewController.CopyrightFooter", nil, [NSBundle mainBundle],
                          @"Copyright © 1994-2013, Oracle and/or its affiliates.All rights reserved.",
                          @"Copyright message to be displayed.");
  footer.text = copyright;
  CGSize size = [[footer text] sizeWithFont:[footer font]
                          constrainedToSize:[[self tableView] bounds].size
                              lineBreakMode:[footer lineBreakMode]];
  [footer setBounds:CGRectMake(0, 0, size.width, size.height)];
  return footer;
}

#pragma mark - UI Event Handlers

- (void) didTouchEmailButton:(id)pSender {
  NSString *to = [[[NSBundle mainBundle] infoDictionary]
                  objectForKey:ATG_CONTACT_US_EMAIL_PROPERTY_NAME];
  NSString *subject = NSLocalizedStringWithDefaultValue
                        (@"ATGMoreViewController.EmailSubject", nil, [NSBundle mainBundle],
                        @"Contact Us",
                        @"Email subject to be used when the 'Contact with email button is touched.");
  // Always encode strings which go to URL parameters.
  subject = [subject stringByAddingPercentEscapes];
  NSURL *mailTo = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@",
                                        to, subject]];
  [[UIApplication sharedApplication] openURL:mailTo];
}

- (void) didTouchPhoneButton:(id)pSender {
  NSString *phone = [[[NSBundle mainBundle] infoDictionary]
                     objectForKey:ATG_CONTACT_US_PHONE_PROPERTY_NAME];
  NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
  if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
    [[UIApplication sharedApplication] openURL:phoneUrl];
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGMoreViewController.ContactUsRowTitle",
                        nil, [NSBundle mainBundle],
                        @"Contact Us",
                        @"Title of alert popup containing phone number on devices without phone.");
    [self alertWithTitleOrNil:title withMessageOrNil:phone];
  }
}

@end

#pragma mark - ATGContactUsTableViewCell Implementation
#pragma mark -

@implementation ATGContactUsTableViewCell

- (NSInteger) accessibilityElementCount {
  return 3;
}

- (id) accessibilityElementAtIndex:(NSInteger)pIndex {
  UIView *view = pIndex > 0 ? [[self contentView] viewWithTag:pIndex] : [self textLabel];
  ATGMockViewAccessibilityElement *element = [[ATGMockViewAccessibilityElement alloc]
                                              initWithAccessibilityContainer:self];
  [element setAccessibilityLabel:[view accessibilityLabel]];
  [element setAccessibilityHint:[view accessibilityHint]];
  [element setAccessibilityTraits:[view accessibilityTraits]];
  [element setAccessibilityFrame:[view convertRect:[view bounds] toView:nil]];
  if (pIndex == 0) {
    CGRect contentFrame = [[self contentView] convertRect:[[self contentView] bounds]
                                                   toView:nil];
    contentFrame.size.width /= 3;
    [element setAccessibilityFrame:contentFrame];
  }
  [element setView:view];
  return element;
}

- (NSInteger) indexOfAccessibilityElement:(id)pElement {
  return [[(ATGMockViewAccessibilityElement *) pElement view] tag];
}

@end

#pragma mark - ATGMockViewAccessibilityElement
#pragma mark

@implementation ATGMockViewAccessibilityElement

@end