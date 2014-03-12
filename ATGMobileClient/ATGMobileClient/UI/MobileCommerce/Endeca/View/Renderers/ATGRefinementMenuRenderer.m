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

#import "ATGRefinementMenuRenderer.h"
#import <EMMobileClient/EMRefinement.h>

@interface ATGRefinementMenuRenderer ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;
@end

@implementation ATGRefinementMenuRenderer
@synthesize titleLabel = _titleLabel, countLabel = _countLabel;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 240, 15)];
    self.titleLabel.isAccessibilityElement = NO;
    [[ATGThemeManager themeManager] applyStyle:@"refinementMenuTitleLabel" toObject:self.titleLabel];
    [self.contentView addSubview:self.titleLabel];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 14, 30, 16)];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.isAccessibilityElement = NO;
    [[ATGThemeManager themeManager] applyStyle:@"refinementMenuCountLabel" toObject:self.countLabel];
    self.countLabel.layer.cornerRadius = 8;
    [self.contentView addSubview:self.countLabel];
    
    [[ATGThemeManager themeManager] applyStyle:@"refinementMenu" toObject:self.backgroundView];
    
    [[ATGThemeManager themeManager] applyStyle:@"refinementMenuSelected" toObject:self.selectedBackgroundView];
  }
  return self;
}

- (void)setObject:(id)pObject {
  self.isAccessibilityElement = YES;
  self.accessibilityTraits = UIAccessibilityTraitButton;
  if ([pObject isKindOfClass:[EMRefinement class]]) {
    EMRefinement *refinement = (EMRefinement *)pObject;
    self.countLabel.hidden = NO;
    self.titleLabel.text = [refinement.label capitalizedString];
    self.countLabel.text = [NSString stringWithFormat:@"%i", [refinement.count intValue]];
    NSMutableString *str = [[NSMutableString alloc] initWithString:NSLocalizedStringWithDefaultValue(@"ATGRefinementMenuRenderer.Accessibility.Label", nil, [NSBundle mainBundle], @"Refinement, ", @"Accessibility hint for refinement buttons")];
    [str appendFormat:@"%@, %@ %@", self.titleLabel.text, self.countLabel.text, NSLocalizedStringWithDefaultValue(@"ATGRefinementMenuRenderer.Accessibility.Count.Label", nil, [NSBundle mainBundle], @"items", @"Accessibility hint for refinement count N 'items'")];
    self.accessibilityLabel = str;
  } else {
    //More link text
    self.titleLabel.text = (NSString *)pObject;
    self.countLabel.text = @"";
    self.countLabel.hidden = YES;
    self.accessibilityLabel = (NSString *)pObject;
    self.accessibilityHint = NSLocalizedStringWithDefaultValue(@"ATGRefinementMenuRenderer.Accessibility.Hint", nil, [NSBundle mainBundle], @"double tap to fetch more refinements", @"Hint for see all link on refinements");
  }
}

- (void)accessibilityElementDidBecomeFocused
{
  UICollectionView *collectionView = (UICollectionView *)self.superview;
  [collectionView scrollToItemAtIndexPath:[collectionView indexPathForCell:self] atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredVertically animated:NO];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

@end