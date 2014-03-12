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

#import "ATGResultsListGridRenderer.h"
#import <ATGUIElements/ATGImageView.h>
#import "RenderableProduct.h"

@interface ATGResultsListGridRenderer ()
@property (nonatomic, strong) ATGImageView *imgView;
- (void)setObject:(id<RenderableProduct>)pObject;
@end

@implementation ATGResultsListGridRenderer
@synthesize imgView = _imgView;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.imgView = [[ATGImageView alloc] initWithFrame:CGRectMake(27, 27, 105, 105)];
    [self.contentView addSubview:self.imgView];
    UIImageView *imageOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product-image-box-for-iphone"]];
    imageOverlay.frame = CGRectMake(12, 21, 135, 117);
    [self.contentView addSubview:imageOverlay];
    self.layer.zPosition = -0.1;
  }
  return self;
}

- (void)setObject:(id<RenderableProduct>)pObject {
  self.imgView.imageURL = pObject.imageURL;
  self.isAccessibilityElement = YES;
  self.accessibilityHint = pObject.accessibilityLabel;
  self.accessibilityTraits = UIAccessibilityTraitButton;
}

- (void)accessibilityElementDidBecomeFocused
{
  UICollectionView *collectionView = (UICollectionView *)self.superview;
  [collectionView scrollToItemAtIndexPath:[collectionView indexPathForCell:self] atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredVertically animated:NO];
  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

@end
