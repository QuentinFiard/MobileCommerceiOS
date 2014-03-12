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

#import "ATGProductList_ATGCategoryChildrenRenderer_iPad.h"
#import <ATGUIElements/ATGImageView.h>
#import "RenderableProduct.h"

@interface ATGProductList_ATGCategoryChildrenRenderer_iPad ()
@property (nonatomic, strong) ATGImageView *imgView;
@property (nonatomic, strong) UILabel *subTitleLabel1;
@property (nonatomic, strong) UILabel *subTitleLabel2;

- (CGRect)imageViewFrame:(CGRect)parentFrame;
- (CGRect)imageOverlayFrame:(CGRect)parentFrame;
- (CGRect)subTitleLabel1Frame:(CGRect)parentFrame;
- (CGRect)subTitleLabel2Frame:(CGRect)parentFrame;
@end

@implementation ATGProductList_ATGCategoryChildrenRenderer_iPad

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  if (self) {
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;

    self.imgView = [[ATGImageView alloc] initWithFrame:[self imageViewFrame:frame]];
    [self.contentView addSubview:self.imgView];
    
    UIImageView *imageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product-image-box-for-iphone@2x"]];
    imageOverlay.frame = [self imageOverlayFrame:frame];
    [self.contentView addSubview:imageOverlay];
    
    self.subTitleLabel1 = [[UILabel alloc] initWithFrame:[self subTitleLabel1Frame:frame]];
    [[ATGThemeManager themeManager] applyStyle:@"resultsListSubTitleLabel" toObject:self.subTitleLabel1];
    self.subTitleLabel1.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.subTitleLabel1];
    
    self.subTitleLabel2 = [[UILabel alloc] initWithFrame:[self subTitleLabel2Frame:frame]];
    self.subTitleLabel2.textAlignment = NSTextAlignmentCenter;
    [[ATGThemeManager themeManager] applyStyle:@"resultsListSubTitleLabel2" toObject:self.subTitleLabel2];
    [self.contentView addSubview:self.subTitleLabel2];
  }
  
  return self;
}

- (void)setObject:(id<RenderableProduct>)pObject {
  self.imgView.imageURL = pObject.imageURL;
  self.subTitleLabel1.text = pObject.title;
  self.subTitleLabel2.text = pObject.auxTitle;
}

- (CGRect)imageViewFrame:(CGRect)parentFrame {
  NSInteger width = parentFrame.size.width * 0.82;
  NSInteger height = parentFrame.size.height - 30;
  return CGRectMake(25, 10, width - 10, height - 20);
}

- (CGRect)imageOverlayFrame:(CGRect)parentFrame {
  NSInteger width = parentFrame.size.width * 0.82;
  NSInteger height = parentFrame.size.height - 30;
  return CGRectMake(20, 0, width, height);
}

- (CGRect)subTitleLabel1Frame:(CGRect)parentFrame {
  NSInteger width = parentFrame.size.width * 0.82;
  NSInteger verticalPadding = parentFrame.size.height - 30;
  return CGRectMake(20, verticalPadding, width, 15);
}

- (CGRect)subTitleLabel2Frame:(CGRect)parentFrame {
  NSInteger width = parentFrame.size.width * 0.82;
  NSInteger verticalPadding = parentFrame.size.height - 15;
  return CGRectMake(20, verticalPadding, width, 15);
}

@end
