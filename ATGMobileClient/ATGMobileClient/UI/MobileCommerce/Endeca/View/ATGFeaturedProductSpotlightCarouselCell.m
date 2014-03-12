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

#import "ATGFeaturedProductSpotlightCarouselCell.h"
#import <ATGUIElements/ATGImageView.h>
#import "ATGRenderableProduct.h"
#import "ATGRestManager.h"

@interface ATGFeaturedProductSpotlightCarouselCell ()

@property (nonatomic, strong) UILabel *siteLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel1;
@property (nonatomic, strong) UILabel *subTitleLabel2;
@property (nonatomic, strong) ATGImageView *imgView;
@property (nonatomic, strong) UIImageView *imgOverlay;

@end

@implementation ATGFeaturedProductSpotlightCarouselCell
@synthesize siteLabel = _siteLabel, titleLabel = _titleLabel, subTitleLabel1 = _subTitleLabel1,
            subTitleLabel2 = _subTitleLabel2, imgView = _imgView;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.imgView = [[ATGImageView alloc]initWithFrame:[self imageViewFrame:frame]];
    self.imgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.imgView];
    
    self.imgOverlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[self overlayImageName]]];
    self.imgOverlay.frame = [self imageOverlayFrame:frame];
    [self.contentView addSubview:self.imgOverlay];

    self.siteLabel = [[UILabel alloc] initWithFrame:[self siteLabelFrame:frame]];
    self.siteLabel.font = [UIFont systemFontOfSize:10];
    self.siteLabel.textColor = [UIColor darkGrayColor];
    self.siteLabel.textAlignment = NSTextAlignmentCenter;
    self.siteLabel.backgroundColor = [UIColor clearColor];
    self.siteLabel.numberOfLines = 0;
    self.siteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.siteLabel];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame:frame]];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
    
    self.subTitleLabel2 = [[UILabel alloc] initWithFrame:[self subTitleLabel2Frame:frame]];
    self.subTitleLabel2.font = [UIFont boldSystemFontOfSize:11];
    self.subTitleLabel2.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel2.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.subTitleLabel2];
  }
  return self;
}

- (void)setRecord:(EMRecord *)pRecord {
  if (!pRecord) {
    // case: page displays fewer items than its itemPerPage capacity
    // since we want paging to work correctly, we keep empty spots for those items
    self.imgView.imageURL = nil;
    self.titleLabel.text = nil;
    self.subTitleLabel2.text = nil;
    self.imgOverlay.hidden = YES;
  } else {
    ATGRenderableProduct *product = (ATGRenderableProduct *)pRecord;
    self.imgView.imageURL = product.imageURL;
    self.titleLabel.text = product.title;
    self.imgOverlay.hidden = NO;

    if (product.isOnSale) {
      self.subTitleLabel2.textColor = [UIColor redColor];
      self.subTitleLabel2.text = [NSString stringWithFormat:@"%@ Sale", product.auxTitle];
    } else {
      self.subTitleLabel2.textColor = [UIColor blackColor];
      self.subTitleLabel2.text = product.auxTitle;
    }

    if (self.showSite && ![[ATGRestManager restManager].currentSite isEqualToString:product.siteId])
      self.siteLabel.text = product.siteName;
    else
      self.siteLabel.text = nil;
  }
}

- (NSString *)overlayImageName {
  return @"product-image-box-for-iphone";
}

- (CGRect)siteLabelFrame:(CGRect)parentFrame {
  return CGRectMake(0, 0, parentFrame.size.width, 15);
}

- (CGRect)imageViewFrame:(CGRect)parentFrame {
  return CGRectMake(5, 5, 90, 60);
}

- (CGRect)imageOverlayFrame:(CGRect)parentFrame {
  return CGRectMake(0, 0, 100, 70);
}

- (CGRect)titleLabelFrame:(CGRect)parentFrame {
  return CGRectMake(0, 70, 100, 15);
}

- (CGRect)subTitleLabel2Frame:(CGRect)parentFrame {
  return CGRectMake(0, 85, 100, 15);
}

@end
