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

#import "ATGBreadcrumbsRenderer.h"
#import <EMMobileClient/EMRefinementBreadcrumb.h>
#import <EMMobileClient/EMRangeFilterBreadcrumb.h>
#import <EMMobileClient/EMSearchBreadcrumb.h>
#import <EMMobileClient/EMAncestor.h>
#import <ATGUIElements/EMLinkedLabel.h>


@interface ATGBreadcrumbsRenderer ()
- (void)constructHierarchicalBreadcrumbForRefinement:(EMRefinementBreadcrumb *)pBreadcrumb;
@end

@implementation ATGBreadcrumbsRenderer
@synthesize label = _label;
- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.label = [[EMLinkedLabel alloc] initWithFrame:CGRectMake(10, 5, 265, frame.size.height - 10)];
    self.label.isAccessibilityElement = YES;
    [self.contentView addSubview:self.label];
    self.layer.zPosition = -0.1; //This allows the shadow of the GuidedNavigationHeader to render above the breadcrumbs
    //when scrolling in both directions. (Otherwise, when the header is displayed first the
    //breadcrumb will render on top of the shadow.
    [[ATGThemeManager themeManager] applyStyle:@"breadcrumb" toObject:self.backgroundView];
    
    [[ATGThemeManager themeManager] applyStyle:@"breadcrumbSelected" toObject:self.selectedBackgroundView];
    [self.contentView addSubview:self.deleteButton];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.label clear];
  [self.deleteButton removeFromSuperview];
}

- (void)setObject:(id)pObject {
  NSMutableString *accessibilityString = [[NSMutableString alloc] initWithString:NSLocalizedStringWithDefaultValue(@"ATGBreadcrumbsRenderer.Accessibility.Label", nil, [NSBundle mainBundle], @"Breadcrumb, ", @"Accessibility label for breadcrumbs")];
  if ([pObject isKindOfClass:[EMRefinementBreadcrumb class]]) {
    EMRefinementBreadcrumb *refinementCrumb = (EMRefinementBreadcrumb *)pObject;
    [self constructHierarchicalBreadcrumbForRefinement:refinementCrumb];
    [self.label addLabel:[self labelWithText:refinementCrumb.label]];
    [accessibilityString appendFormat:@"%@", refinementCrumb.label];
  } else if ([pObject isKindOfClass:[EMSearchBreadcrumb class]]) {
    EMSearchBreadcrumb *searchBreadcrumb = (EMSearchBreadcrumb *)pObject;
    if (searchBreadcrumb.correctedTerms) {
      NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\" %@: \"%@\"", searchBreadcrumb.terms, NSLocalizedStringWithDefaultValue(@"Breadcrumbs.SearchCrumb.Was.Corrected.To", nil, [NSBundle mainBundle], @"was corrected to", @"This text renderers between the entered term and the corrected term, ie foo was corrected to food"), searchBreadcrumb.correctedTerms]];
      [self.label addLabel:[self labelWithAttributedText:str]];
      [accessibilityString appendFormat:@"%@", str];
    } else {
      [self.label addLabel:[self labelWithText:[NSString stringWithFormat:@"\"%@\"", searchBreadcrumb.terms]]];
      [accessibilityString appendFormat:@"\"%@\"", searchBreadcrumb.terms];
    }
  } else {
    EMRangeFilterBreadcrumb *rangeCrumb = (EMRangeFilterBreadcrumb *)pObject;
    
    [self.label addLabel:[self labelWithText:[NSString stringWithFormat:@"$%i - $%i", [rangeCrumb.lowerBound intValue], [rangeCrumb.upperBound intValue]]]];
    [accessibilityString appendFormat:@"$%i - $%i", [rangeCrumb.lowerBound intValue], [rangeCrumb.upperBound intValue]];
  }
  self.label.accessibilityLabel = accessibilityString;
  self.label.frame = CGRectMake(10, roundf((self.bounds.size.height - [self.label low]) / 2), 265, self.frame.size.height - 10);
  [self.label layoutSubviews];
}

- (void)constructHierarchicalBreadcrumbForRefinement:(EMRefinementBreadcrumb *)pBreadcrumb {
  for (EMAncestor *ancestor in pBreadcrumb.ancestors) {
    [self.label addLabel:[self labelWithText:[NSString stringWithFormat:@"%@ : ", ancestor.label]]];
  }
}

- (UILabel *)labelWithText:(NSString *)pText {
  UILabel *label = [self emptyLabel];
  label.text = pText;
  label.frame = [label textRectForBounds:CGRectMake(0, 0, 265, 1000) limitedToNumberOfLines:0];
  
  return label;
}

- (UILabel *)labelWithAttributedText:(NSAttributedString *)pAttributedString {
  UILabel *label = [self emptyLabel];
  label.attributedText = pAttributedString;
  label.frame = [label textRectForBounds:CGRectMake(0, 0, 265, 1000) limitedToNumberOfLines:0];
  
  return label;
}

- (UILabel *)emptyLabel {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.numberOfLines = 0;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.textAlignment = NSTextAlignmentLeft;
  [[ATGThemeManager themeManager] applyStyle:@"breadcrumbLabel" toObject:label];
  return label;
}


@end
