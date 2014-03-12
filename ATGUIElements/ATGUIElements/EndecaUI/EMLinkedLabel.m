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

#import "EMLinkedLabel.h"

@interface EMCollectionViewFlowLayout : UICollectionViewFlowLayout
@end

@implementation EMCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSArray *arr = [super layoutAttributesForElementsInRect:rect];
  NSMutableArray *retVal = [NSMutableArray arrayWithCapacity:0];
  for (int i = 0; i < arr.count; i++) {
    UICollectionViewLayoutAttributes *attr = (UICollectionViewLayoutAttributes *)[arr objectAtIndex:i];
    if (attr.frame.origin.x > 0 && i > 0) {
      UICollectionViewLayoutAttributes *previousLayout = [arr objectAtIndex:(i - 1)];
      attr.frame = CGRectMake(previousLayout.frame.origin.x + previousLayout.frame.size.width, attr.frame.origin.y, attr.frame.size.width, attr.frame.size.height);
    } else if (attr.frame.origin.x > 0 && i == 0) {
      attr.frame = CGRectMake(0, attr.frame.origin.y, attr.frame.size.width, attr.frame.size.height);
    }
    [retVal addObject:attr];
  }
  return retVal;
}

@end

@interface EMLabelCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@end

@implementation EMLabelCell
@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)setLabel:(UILabel *)pLabel {
  _label = pLabel;
  [self.contentView addSubview:pLabel];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.label removeFromSuperview];
}

@end

@interface EMLinkedLabel () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation EMLinkedLabel
@synthesize delegate = _delegate, labels = _labels;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.labels = [NSMutableArray arrayWithCapacity:0];
      
      EMCollectionViewFlowLayout *layout = [[EMCollectionViewFlowLayout alloc] init];
      self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
      self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      self.collectionView.delegate = self;
      self.collectionView.dataSource = self;
      self.collectionView.backgroundColor = [UIColor clearColor];
      self.collectionView.scrollEnabled = NO;
      [self.collectionView registerClass:[EMLabelCell class] forCellWithReuseIdentifier:@"Label"];
      [self addSubview:self.collectionView];
    }
    return self;
}

- (UILabel *)labelAtIndex:(NSInteger)pIndex {
  if (self.labels.count > pIndex) {
    return [self.labels objectAtIndex:pIndex];
  }
  return nil;
}

- (void)addLabel:(UILabel *)pLabel {
  [self.labels addObject:pLabel];
  [self.collectionView reloadData];
}

- (void)addLabel:(UILabel *)pLabel atIndex:(NSInteger)pIndex {
  if (self.labels.count > pIndex) {
    [self.labels insertObject:pLabel atIndex:pIndex];
    [self.collectionView reloadData];
  }
}

- (void)removeLabelAtIndex:(NSInteger)pIndex {
  if (self.labels.count > pIndex) {
    [self.labels removeObjectAtIndex:pIndex];
    [self.collectionView reloadData];
  }
}

- (UILabel *)lastLabel {
  return [self.labels lastObject];
}

- (CGFloat)low {
  UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.labels.count - 1 inSection:0]];
  return attr.frame.size.height + attr.frame.origin.y;
}

- (void)clear {
  [self.labels removeAllObjects];
  [self.collectionView reloadData];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.labels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  EMLabelCell *cell = (EMLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Label" forIndexPath:indexPath];
  [cell setLabel:[self labelAtIndex:indexPath.row]];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self labelAtIndex:indexPath.row].frame.size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  BOOL ret = indexPath.row < (self.labels.count -1);
  if (ret) {
    if ([self.delegate respondsToSelector:@selector(label:willSelectLabelAtIndex:)]) {
      [self.delegate label:self willSelectLabelAtIndex:indexPath.row];
    }
  }
  return ret;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.row < (self.labels.count - 1);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  if ([self.delegate respondsToSelector:@selector(label:didSelectLabelAtIndex:)]) {
    [self.delegate label:self didSelectLabelAtIndex:indexPath.row];
  }
}


@end
