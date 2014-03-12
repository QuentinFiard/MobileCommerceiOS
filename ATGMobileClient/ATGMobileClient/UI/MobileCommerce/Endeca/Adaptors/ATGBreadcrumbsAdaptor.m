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

#import "ATGBreadcrumbsAdaptor.h"
#import <EMMobileClient/EMBreadcrumbs.h>
#import <EMMobileClient/EMDataObject.h>
#import <EMMobileClient/EMAssemblerViewController.h>
#import <EMMobileClient/EMRefinementBreadcrumb.h>
#import <EMMobileClient/EMSearchBreadcrumb.h>
#import <EMMobileClient/EMRangeFilterBreadcrumb.h>
#import <EMMobileClient/EMAncestor.h>
#import "ATGBreadcrumbsRenderer.h"
#import <ATGUIElements/EMLinkedLabel.h>
#import "ATGBrowseViewController.h"
#import "ATGBrowseViewController_iPad.h"

@interface ATGBreadcrumbsAdaptor () <EMLinkedLabelDelegate>
@property (nonatomic, strong) EMBreadcrumbs *contentItem;
@property (nonatomic, strong) NSArray *breadcrumbs;
@end

@implementation ATGBreadcrumbsAdaptor
@synthesize contentItem = _contentItem, collapsed = _collapsed;

- (id)initWithContentItem:(EMContentItem *)pContentItem controller:(EMAssemblerViewController *)pController {
  if ((self = [super initWithContentItem:pContentItem controller:pController])) {
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:0];
    [tmp addObjectsFromArray:self.contentItem.searchCrumbs];
    [tmp addObjectsFromArray:self.contentItem.refinementCrumbs];
    [tmp addObjectsFromArray:[self filteredRangeFilterCrumbs:self.contentItem.rangeFilterCrumbs ]];
    self.breadcrumbs = [NSArray arrayWithArray:tmp];
  }
  return self;
}

//TODO this can be removed when the breadcrumbs bug is worked out
- (NSArray *)filteredRangeFilterCrumbs:(NSArray *)pRangeFilterCrumbs {
  NSMutableArray *rangeFilterCrumbs = [NSMutableArray arrayWithArray:pRangeFilterCrumbs];
  for (EMRangeFilterBreadcrumb *breadcrumb in pRangeFilterCrumbs) {
    if ([breadcrumb.propertyName isEqualToString:@"product.startDate"] || [breadcrumb.propertyName isEqualToString:@"sku.startDate"] || [breadcrumb.propertyName isEqualToString:@"product.endDate"] || [breadcrumb.propertyName isEqualToString:@"sku.endDate"]) {
      [rangeFilterCrumbs removeObject:breadcrumb];
    }
  }
  return  rangeFilterCrumbs;
}

- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forIndex:(NSInteger)pIndex {
  ATGBreadcrumbsRenderer *rend = (ATGBreadcrumbsRenderer *)pRenderer;
  if ([self.controller isKindOfClass:[ATGBrowseViewController class]]) {
    rend.deleteButton = nil;
  } else {
    rend.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rend.deleteButton setImage:[UIImage imageNamed:@"remove-x-icon"] forState:UIControlStateNormal];
    rend.deleteButton.isAccessibilityElement = YES;
    rend.accessibilityLabel = NSLocalizedStringWithDefaultValue(@"ATGBreadcrumbsAdaptor.Remove.X.Accessibility.Label", nil, [NSBundle mainBundle], @"Remove applied breadcrumb", @"Description of accessibility item, for removing breadcrumbs");
    rend.deleteButton.alpha = 0.8;
    rend.deleteButton.frame = CGRectMake(290, 14, 16, 16);
    rend.deleteButton.tag = pIndex;
    [rend.deleteButton addTarget:self action:@selector(removeCrumb:) forControlEvents:UIControlEventTouchUpInside];
    [rend addSubview:rend.deleteButton];
    rend.label.delegate = self;
    rend.label.tag = pIndex;
  }
}

- (NSInteger)numberOfItemsInContentItem {
  if (!self.collapsed)
    return self.breadcrumbs.count;
  return 0;
}

- (CGSize)sizeForRendererAtIndex:(NSInteger)pIndex {
  EMDataObject *obj = [self.breadcrumbs objectAtIndex:pIndex];
  if ([obj isKindOfClass:[EMRefinementBreadcrumb class]]) {
    EMRefinementBreadcrumb *bc = (EMRefinementBreadcrumb *)obj;
    NSString *foo = @"";
    for (EMAncestor *ancestor in bc.ancestors) {
      foo = [foo stringByAppendingFormat:@"%@>", ancestor.label];
    }
    foo = [foo stringByAppendingFormat:@" %@" ,bc.label];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = foo;
    CGRect rect = [label textRectForBounds:CGRectMake(0, 0, 265, 1000) limitedToNumberOfLines:0];
    return CGSizeMake(320, MAX(rect.size.height + 15, 44));
  } else if ([obj isKindOfClass:[EMSearchBreadcrumb class]]) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    EMSearchBreadcrumb *searchBreadcrumb = (EMSearchBreadcrumb *)obj;
    if (searchBreadcrumb.correctedTerms) {
      NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\"%@\" %@: \"%@\"", searchBreadcrumb.terms, NSLocalizedStringWithDefaultValue(@"Breadcrumbs.SearchCrumb.Was.Corrected.To", nil, [NSBundle mainBundle], @"was corrected to", @"This text renderers between the entered term and the corrected term, ie foo was corrected to food"), searchBreadcrumb.correctedTerms]];
      label.text = [str string];
    } else {
      label.text = [NSString stringWithFormat:@"\"%@\"", searchBreadcrumb.terms];
    }
    CGRect rect = [label textRectForBounds:CGRectMake(0, 0, 265, 1000) limitedToNumberOfLines:0];
    return CGSizeMake(320, MAX(rect.size.height + 10, 44));   //The label is inset with 5px padding on top and bottom thus + 10
  }
  
  return CGSizeMake(320,44);
}

- (CGSize)referenceSizeForHeader {
  if (self.breadcrumbs.count > 0)
    return CGSizeMake(320, 30);
  else
    return CGSizeMake(0, 0);
}

- (id)objectToBeRenderedAtIndex:(NSInteger)pIndex {
  EMDataObject *obj = [self.breadcrumbs objectAtIndex:pIndex];
  return obj;
}

- (id)objectToBeRenderedForHeader {
  NSString *headerString = NSLocalizedStringWithDefaultValue(@"mobile.refinementsController.breadcrumbsDescription", nil, [NSBundle mainBundle], @"Applied Filters", @"Text in Breadcrumbs section header");
  return (self.collapsed ?  [NSString stringWithFormat:@"\u25B2 %@", headerString] : [NSString stringWithFormat:@"\u25BC %@", headerString]);
}

- (void)usingRenderer:(EMContentItemRenderer *)pRenderer forSupplementaryElementOfKind:(NSString *)pKind {
  [super usingRenderer:(EMContentItemCollectionReusableView *)pRenderer forSupplementaryElementOfKind:pKind];
  UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [clearButton addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
  [clearButton setTitle:NSLocalizedStringWithDefaultValue(@"BreadCrumbs.Clear.All.Breadcrumbs.Text", nil, [NSBundle mainBundle], @"Clear", @"Clear All Text") forState:UIControlStateNormal];
  clearButton.accessibilityLabel = NSLocalizedStringWithDefaultValue(@"BreadCrumbs.Clear.All.Breadcrumbs.Accessibility.Label", nil, [NSBundle mainBundle], @"Clear all breadcrumbs", @"Description of accessibility item, for clearing all breadcrumbs");
  [clearButton applyStyleWithName:@"breadcrumbsSectionHeaderClearButton"];
  [clearButton.titleLabel applyStyleWithName:@"breadcrumbsSectionHeaderClearButtonLabel"];
  clearButton.frame = CGRectMake(260, 0, 60, 30);
  clearButton.backgroundColor = [UIColor clearColor];
  [pRenderer addSubview:clearButton];
}

- (CGFloat)minimumLineSpacing {
  return 1;
}

- (UIEdgeInsets)edgeInsets {
  return UIEdgeInsetsMake(1.0, 0.0, self.collapsed ? 0.0 : 1.0, 0.0);
}

- (void)label:(EMLinkedLabel *)pLabel didSelectLabelAtIndex:(NSInteger)pIndex {
  
  EMRefinementBreadcrumb *bc = [self.breadcrumbs objectAtIndex:pLabel.tag];
  [self.controller reloadPageForAction:(EMAction *)[bc.ancestors objectAtIndex:pIndex]];
}

- (void)removeCrumb:(id)sender {
  [self.controller reloadPageForAction:(EMAction *)((EMRefinementBreadcrumb *)[self.breadcrumbs objectAtIndex:((UIButton *)sender).tag]).removeAction];
}

- (void)clearAll:(id)sender {
  if ([self.controller isKindOfClass:[ATGBrowseViewController class]] || [self.controller isKindOfClass:[ATGBrowseViewController_iPad class]]) {
    [self.controller.navigationController popToRootViewControllerAnimated:YES];
  } else {
    [self.controller reloadPageForAction:(EMAction *)(self.contentItem.removeAllAction)];
  }
}

- (BOOL)shouldHighlightItemAtIndex:(NSInteger)pIndex {
  return YES;
}

- (void)didSelectItemAtIndex:(NSInteger)pIndex {
  [self.controller reloadPageForAction:(EMAction *)((EMRefinementBreadcrumb *)[self.breadcrumbs objectAtIndex:pIndex]).removeAction];
}

- (BOOL)shouldSelectItemAtIndex:(NSInteger)pIndex {
  return [self.controller isKindOfClass:[ATGBrowseViewController class]] ? NO : YES;
}

@end

