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

#import <iOS-rest-client/ATGRest.h>
#import "ATGAccessHandler.h"

@implementation UIViewController (ATGAdditions)

- (void)presentLoginViewControllerAnimated:(BOOL)pAnimated {
  [[ATGAccessHandler accessHandler] presentLoginViewControllerAnimated:pAnimated allowSkipLogin:NO fromViewController:self];
}

- (void)presentLoginViewControllerAnimated:(BOOL)pAnimated
                            allowSkipLogin:(BOOL)pAllowSkipLogin {
  [[ATGAccessHandler accessHandler] presentLoginViewControllerAnimated:pAnimated allowSkipLogin:pAllowSkipLogin fromViewController:self];
}

- (void)dismissLoginViewControllerAnimated:(BOOL)pAnimated {
  [[ATGAccessHandler accessHandler] dismissLoginViewControllerAnimated:pAnimated fromViewController:self];
}

- (void)didLogin {
  [[ATGAccessHandler accessHandler] didLoginFromViewController:self];
}

- (void)didSkipLogin {
  [[ATGAccessHandler accessHandler] didSkipLoginFromViewController:self];
}

- (void)didCancelLogin {
  [[ATGAccessHandler accessHandler] didCancelLoginFromViewController:self];
}

- (void)setErrors:(NSArray *)pErrors inSection:(NSInteger)pSection {
  // No default implementation in this category. Do not allow to use this method.
  [self doesNotRecognizeSelector:_cmd];
}

- (NSArray *)errorsInSection:(NSInteger)pSection {
  // No default implementation in this category. Do not allow to use this method.
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)tableView:(UITableView *)pTableView setErrors:(NSArray *)pErrors
        inSection:(NSInteger)pSection {
  BOOL populated = [pTableView numberOfRowsInSection:pSection] > 0;

  NSInteger previousErrorsCount = [[self errorsInSection:pSection] count];
  NSInteger newErrorsCount = [pErrors count];
  [self setErrors:pErrors inSection:pSection];
  [pTableView beginUpdates];
  if (newErrorsCount >= previousErrorsCount) {
    NSMutableArray *reload = [[NSMutableArray alloc] init];
    NSMutableArray *add = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < previousErrorsCount; i++) {
      [reload addObject:[NSIndexPath indexPathForRow:i inSection:pSection]];
    }
    for (NSInteger i = previousErrorsCount; i < newErrorsCount; i++) {
      [add addObject:[NSIndexPath indexPathForRow:i inSection:pSection]];
    }
    [pTableView reloadRowsAtIndexPaths:reload
                      withRowAnimation:UITableViewRowAnimationRight];
    [pTableView insertRowsAtIndexPaths:add
                      withRowAnimation:UITableViewRowAnimationTop];
  } else {
    NSMutableArray *reload = [[NSMutableArray alloc] init];
    NSMutableArray *remove = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < newErrorsCount; i++) {
      [reload addObject:[NSIndexPath indexPathForRow:i inSection:pSection]];
    }
    for (NSInteger i = newErrorsCount; i < previousErrorsCount; i++) {
      [remove addObject:[NSIndexPath indexPathForRow:i inSection:pSection]];
    }
    [pTableView reloadRowsAtIndexPaths:reload
                      withRowAnimation:UITableViewRowAnimationRight];
    [pTableView deleteRowsAtIndexPaths:remove
                      withRowAnimation:UITableViewRowAnimationTop];
  }
  [pTableView endUpdates];
  if ([pErrors count]) {
    if (populated) {
      [pTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:pSection]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [pTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:pSection]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
}

- (NSIndexPath *)shiftIndexPath:(NSIndexPath *)pIndexPath {
  NSInteger numberOfErrors = [[self errorsInSection:[pIndexPath section]] count];
  return [NSIndexPath indexPathForRow:[pIndexPath row] - numberOfErrors
                            inSection:[pIndexPath section]];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)pIndexPath {
  NSInteger numberOfErrors = [[self errorsInSection:[pIndexPath section]] count];
  return [NSIndexPath indexPathForRow:[pIndexPath row] + numberOfErrors
                            inSection:[pIndexPath section]];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView
    errorCellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSArray *errors = [self errorsInSection:[pIndexPath section]];
  if ([pIndexPath row] < [errors count]) {
    // There are errors in the section and we're retrieving an error cell.
    NSString *reuseId = @"Error Cell";
    NSInteger labelTag = 13;
    UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:reuseId];
      CGRect bounds = [[cell contentView] bounds];
      bounds.origin.x = 12;
      bounds.size.width -= bounds.origin.x * 2;
      bounds.origin.y = bounds.origin.x;
      bounds.size.height -= bounds.origin.y * 2;
      UILabel *label = [[UILabel alloc] initWithFrame:bounds];
      [label applyStyleWithName:@"formTextLabel"];
      [label setTextColor:[UIColor textHighlightedColor]];
      [label setBackgroundColor:[UIColor clearColor]];
      [label setAutoresizingMask:UIViewAutoresizingFlexibleHeight |
       UIViewAutoresizingFlexibleWidth];
      [label setTextAlignment:NSTextAlignmentLeft];
      [label setLineBreakMode:NSLineBreakByWordWrapping];
      [label setNumberOfLines:0];
      [label setTag:labelTag];
      [cell.contentView addSubview:label];
      [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

      // set background color and background view to make sure error cell has the correct color.
      cell.backgroundColor = [UIColor errorColor];
      UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
      backView.backgroundColor = [UIColor errorColor];
      cell.backgroundView = backView;
    }
    UILabel *errorLabel = (UILabel *)[[cell contentView] viewWithTag:labelTag];
    [errorLabel setText:[errors objectAtIndex:[pIndexPath row]]];
    return cell;
  } else {
    return nil;
  }
}

- (CGFloat) tableView:(UITableView *)pTableView errorHeightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSArray *errors = [self errorsInSection:[pIndexPath section]];
  if ([pIndexPath row] < [errors count]) {
    CGRect bounds = [pTableView bounds];
    CGSize maxSize = CGSizeMake(bounds.size.width - 48, 1000);
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:bounds];
    [errorLabel applyStyleWithName:@"formTextLabel"];
    NSString *error = [errors objectAtIndex:[pIndexPath row]];
    CGSize actualSize = [error sizeWithFont:[errorLabel font] constrainedToSize:maxSize
                              lineBreakMode:NSLineBreakByWordWrapping];
    actualSize.height += 24;
    if (actualSize.height > [pTableView rowHeight]) {
      return actualSize.height;
    } else {
      return [pTableView rowHeight];
    }
  } else {
    return -1;
  }
}

- (NSInteger)errorNumberOfRowsInSection:(NSInteger)pSection {
  return [[self errorsInSection:pSection] count];
}

- (void)tableView:(UITableView *)pTableView setError:(NSError *)pError
        inSection:(NSInteger)pSection {
  id formExceptions = [[pError userInfo] objectForKey:ATG_FORM_EXCEPTION_KEY];
  if (formExceptions) {
    NSArray *errors = formExceptions;
    if ([errors count] == 0) {
      errors = [NSArray arrayWithObject:[pError localizedDescription]];
    }
    [self tableView:pTableView setErrors:errors inSection:pSection];
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
        (@"ATGProfileEditViewController.NetworkError.Title",
         nil, [NSBundle mainBundle], @"Can't perform your request.",
         @"Alert title to be displayed if network error occurred.");
    [self alertWithTitleOrNil:title withMessageOrNil:[pError localizedDescription]];
  }
}

- (void)addKeyboardNotificationsObserver {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)removeKeyboardNotificationsObserver {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

- (void)keyboardWillShow:(NSNotification *)pNotification {
  
}

- (void)keyboardWillHide:(NSNotification *)pNotification {
  
}

- (BOOL)hidesNavigationBar {
  return [[[self navigationController] viewControllers] count] < 2;
}

- (void)alertWithTitleOrNil:(NSString *)title withMessageOrNil:(NSString *)message {
  if (title == nil) {
    title = NSLocalizedStringWithDefaultValue
        (@"ATGUIUtil.AlertDefaultTitle", nil, [NSBundle mainBundle],
         @"Error", @"Alert default title");
  }
  if (message == nil) {
    message = NSLocalizedStringWithDefaultValue
        (@"ATGUIUtil.AlertDefaultMessage", nil, [NSBundle mainBundle],
         @"Some error occurred ", @"Alert default message");
  }
  NSString *ok = NSLocalizedStringWithDefaultValue
      (@"ATGUIUtil.OkButtonCaption", nil, [NSBundle mainBundle],
       @"Ok", @"OK button caption");
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:ok
                                        otherButtonTitles:nil];
  [alert show];
}

@end