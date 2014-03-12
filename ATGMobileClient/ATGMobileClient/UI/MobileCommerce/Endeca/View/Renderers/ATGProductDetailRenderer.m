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

#import "ATGProductDetailRenderer.h"
#import <ATGUIElements/ATGImageView.h>
#import "ATGStyleManager.h"
#import "RenderableProduct.h"

@interface ATGProductDetailRenderer ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel1;
@property (nonatomic, strong) UILabel *subTitleLabel2;
@property (nonatomic, strong) UILabel *auxTitleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) ATGImageView *imgView;
- (void)setObject:(id<RenderableProduct>)pObject;
@end

@implementation ATGProductDetailRenderer
@synthesize titleLabel = _titleLabel, subTitleLabel1 = _subTitleLabel1, subTitleLabel2 = _subTitleLabel2, auxTitleLabel = _auxTitleLabel, imgView = _imgView, bodyLabel = _bodyLabel;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.imgView = [[ATGImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    self.imgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imgView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 190, 15)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    
    self.subTitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 25, 190, 15)];
    self.subTitleLabel1.font = [UIFont boldSystemFontOfSize:14];
    self.subTitleLabel1.textColor = [[ATGStyleManager sharedManager] secondaryColor];
    self.subTitleLabel1.backgroundColor = [UIColor clearColor];
    [self addSubview:self.subTitleLabel1];
    
    self.subTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 40, 190, 30)];
    self.subTitleLabel2.numberOfLines = 2;
    self.subTitleLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    self.subTitleLabel2.font = [UIFont systemFontOfSize:12];
    self.subTitleLabel2.backgroundColor = [UIColor clearColor];
    [self addSubview:self.subTitleLabel2];
    
    self.auxTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 75, 55, 20)];
    self.auxTitleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.auxTitleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.auxTitleLabel];
    
    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, 300, 10000)];
    self.bodyLabel.font = [UIFont boldSystemFontOfSize:12];
    self.bodyLabel.backgroundColor = [UIColor clearColor];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.bodyLabel];
    
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)setObject:(id<RenderableProduct>)pObject {
  self.imgView.imageURL = pObject.imageURL;
  self.titleLabel.text = pObject.title;
  self.subTitleLabel1.text = pObject.subTitle1;
  self.subTitleLabel2.text = pObject.subTitle2;
  self.auxTitleLabel.text = pObject.auxTitle;
  self.bodyLabel.text = pObject.description;
  [self.bodyLabel sizeToFit];
}
@end
