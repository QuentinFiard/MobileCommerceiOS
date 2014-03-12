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

#import "ATGResultsListRenderer.h"
#import <ATGUIElements/ATGImageView.h>
#import "RenderableProduct.h"

@interface ATGResultsListRenderer ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel1;
@property (nonatomic, strong) UILabel *subTitleLabel2;
@property (nonatomic, strong) UILabel *auxTitleLabel;
@property (nonatomic, strong) ATGImageView *imgView;
- (void)setObject:(id<RenderableProduct>)pObject;
@end

@implementation ATGResultsListRenderer
@synthesize titleLabel = _titleLabel, subTitleLabel1 = _subTitleLabel1, subTitleLabel2 = _subTitleLabel2, auxTitleLabel = _auxTitleLabel, imgView = _imgView;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
        
    self.imgView = [[ATGImageView alloc] initWithFrame:CGRectMake(14, 5, 70, 70)];
    self.imgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.imgView];
    
    UIImageView *imageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product-image-box-for-iphone"]];
    imageOverlay.frame = CGRectMake(5, 2, 87, 75);
    [self.contentView addSubview:imageOverlay];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 155, 15)];
    self.titleLabel.isAccessibilityElement = NO;  
    [[ATGThemeManager themeManager] applyStyle:@"resultsListTitleLabel" toObject:self.titleLabel];
    [self.contentView addSubview:self.titleLabel];
    
    self.subTitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 22, 165, 15)];
    self.subTitleLabel1.isAccessibilityElement = NO;  
    [[ATGThemeManager themeManager] applyStyle:@"resultsListSubTitleLabel" toObject:self.subTitleLabel1];
    [self.contentView addSubview:self.subTitleLabel1];
    
    self.subTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 39, 165, 30)];
    self.subTitleLabel2.numberOfLines = 2;
    self.subTitleLabel2.isAccessibilityElement = NO;  
    self.subTitleLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    self.subTitleLabel2.minimumScaleFactor = 1;
    [[ATGThemeManager themeManager] applyStyle:@"resultsListSubTitleLabel2" toObject:self.subTitleLabel2];
    [self.contentView addSubview:self.subTitleLabel2];
    
    self.auxTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(265, 5, 50, 15)];
    self.auxTitleLabel.isAccessibilityElement = NO;  
    [[ATGThemeManager themeManager] applyStyle:@"resultsListAuxTitleLabel" toObject:self.auxTitleLabel];
    [self.contentView addSubview:self.auxTitleLabel];
    self.layer.zPosition = -0.1;
    
    UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-more-arrow"]];
    disclosure.frame = CGRectMake(280, 28, 10, 18);
    [self.contentView addSubview:disclosure];
  }
  return self;
}

- (void)setObject:(id<RenderableProduct>)pObject {
  self.imgView.imageURL = pObject.imageURL;
  self.titleLabel.text = pObject.title;
  self.subTitleLabel1.text = pObject.subTitle1;
  self.subTitleLabel2.text = pObject.auxTitle;
  self.auxTitleLabel.text = @"";
  
  self.subTitleLabel2.frame = [self.subTitleLabel2 textRectForBounds:CGRectMake(0, 0, 210, 30) limitedToNumberOfLines:2];
  self.subTitleLabel2.top = self.subTitleLabel1.bottom + 2;
  self.subTitleLabel2.left = self.subTitleLabel1.left;
 
  self.isAccessibilityElement = YES;
  self.accessibilityLabel = pObject.accessibilityLabel;
  self.accessibilityTraits = UIAccessibilityTraitButton;
}

- (void)accessibilityElementDidBecomeFocused
{
  UICollectionView *collectionView = (UICollectionView *)self.superview;
  [collectionView scrollToItemAtIndexPath:[collectionView indexPathForCell:self] atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredVertically animated:NO];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

@end
