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

#import "ATGSearchAdjustmentsAdaptor.h"
#import <EMMobileClient/EMSearchAdjustments.h>
#import <EMMobileClient/EMAssemblerViewController.h>
#import <EMMobileClient/EMAdjustedSearch.h>
#import <EMMobileClient/EMSuggestedSearch.h>

@interface ATGSearchAdjustmentsAdaptor ()
@property (nonatomic, strong) EMSearchAdjustments *contentItem;
@end

@implementation ATGSearchAdjustmentsAdaptor
@synthesize contentItem = _contentItem;

- (void)layoutContents {
  if ([self.contentItem.suggestedSearches allKeys].count > 0) {
    NSString *originalTerm = [self.contentItem.originalTerms objectAtIndex:0];
    NSArray *suggestedSearches = [[self.contentItem.suggestedSearches allValues] objectAtIndex:0];
    UIAlertView *alertView;
    if ([self.contentItem.adjustedSearches allKeys].count < 1) {
      alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Did.You.Mean.Title", nil, [NSBundle mainBundle], @"Did You Mean", @"Did you mean title text") message:NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Did.You.Mean.Explanation", nil, [NSBundle mainBundle], @"We found a number of similar search terms with more results", @"Text is displayed to explain what the suggestions the user is being offered represent") delegate:self cancelButtonTitle:originalTerm otherButtonTitles:nil];
    } else {
      NSArray *adjustedSearches = [self.contentItem.adjustedSearches allValues];
      EMAdjustedSearch *adjustedSearch = [(NSArray *)[adjustedSearches objectAtIndex:0] objectAtIndex:0];
      alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", originalTerm, NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Was.Corrected.To", nil, [NSBundle mainBundle], @"was corrected to", @"This text renderers between the entered term and the corrected term, ie foo was corrected to food"), adjustedSearch.adjustedTerms] message:NSLocalizedStringWithDefaultValue(@"Search.Adjustments.Did.You.Mean.Explanation", nil, [NSBundle mainBundle], @"We found a number of similar search terms with more results", @"Text is displayed to explain what the suggestions the user is being offered represent") delegate:self cancelButtonTitle:adjustedSearch.adjustedTerms otherButtonTitles:nil];
    }
    for (EMSuggestedSearch *suggestedSearch in suggestedSearches) {
      [alertView addButtonWithTitle:suggestedSearch.label];
    }
    [alertView show];
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSInteger offset = (alertView.cancelButtonIndex == -1 ? 0 : 1); //if there is a cancel button it throws off the other buttons indicies by 1.
  if (buttonIndex == alertView.cancelButtonIndex) {
    //Cancel No-Op
  } else {
    NSArray *suggestedSearches = [[self.contentItem.suggestedSearches allValues] objectAtIndex:0];
    if (suggestedSearches.count >= buttonIndex) {
      EMSuggestedSearch *suggestedSearch = [suggestedSearches objectAtIndex:buttonIndex - offset];
      [self.controller loadPageForAction:(EMAction *)suggestedSearch];
    }
  }
}

- (NSInteger)numberOfItemsInContentItem {
  return [self.contentItem.adjustedSearches allKeys].count > 0 ? 1 : 0;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  return CGSizeMake(320, 30);
}

@end
