/*<ORACLECOPYRIGHT>
 * Copyright </A> &copy; 1994-2013 Oracle and/or its affiliates. All rights reserved.
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

#import "ATGGridCollectionView.h"
#import "ATGGridCollectionViewCell.h"
#import "ATGGridCollectionViewLayout.h"

#pragma mark - ATGGridCollectionView Private Protocol Definition
#pragma mark -

@interface ATGGridCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource,
    ATGGridCollectionViewLayoutDelegate> {
  UICollectionViewScrollDirection mScrollDirection;
  BOOL mAllowsChoosing;
  NSArray *mObjectsToDisplay;
}

@property (nonatomic, readwrite, strong) NSMutableSet *innerPathsForChosenItems;
@property (nonatomic, readwrite, strong) NSString *cellsNibName;
@property (nonatomic, readwrite, strong) UISwipeGestureRecognizer *swipeRecognizer;

- (void)initWithNibName:(NSString *)nibName;

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer;

@end

#pragma mark - ATGGridCollectionView Implementation
#pragma mark -

@implementation ATGGridCollectionView

- (void)setScrollDirection:(UICollectionViewScrollDirection)pScrollDirection {
  self->mScrollDirection = pScrollDirection;
  [[self swipeRecognizer] setEnabled:pScrollDirection == UICollectionViewScrollDirectionVertical];
  [(ATGGridCollectionViewLayout *)[self collectionViewLayout] setScrollDirection:pScrollDirection];
}

- (UICollectionViewScrollDirection)scrollDirection {
  return self->mScrollDirection;
}

- (void)setAllowsChoosing:(BOOL)pAllowsChoosing {
  self->mAllowsChoosing = pAllowsChoosing;
  [[self swipeRecognizer] setEnabled:pAllowsChoosing];
}

- (BOOL)allowsChoosing {
  return self->mAllowsChoosing;
}

- (void)setObjectsToDisplay:(NSArray *)pObjectsToDisplay {
  self->mObjectsToDisplay = [pObjectsToDisplay copy];
  [self reloadData];
}

- (NSArray *)objectsToDisplay {
  return self->mObjectsToDisplay;
}

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];
  [self initWithNibName:[self cellsNibName]];
}

#pragma mark - UICollectionView

- (void)reloadData {
  [[self innerPathsForChosenItems] removeAllObjects];
  [super reloadData];
}

- (void)reloadSections:(NSIndexSet *)pSections {
  [pSections enumerateIndexesUsingBlock:^(NSUInteger pIndex, BOOL *pStop) {
    NSPredicate *filter = [NSPredicate
                           predicateWithBlock:^BOOL(id pEvaluatedObject, NSDictionary *pBindings) {
                             NSIndexPath *path = (NSIndexPath *)pEvaluatedObject;
                             return pIndex != [path section];
                           }];
    [[self innerPathsForChosenItems] filterUsingPredicate:filter];
  }];
  [super reloadSections:pSections];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)pIndexPaths {
  for (NSIndexPath *indexPath in pIndexPaths) {
    [[self innerPathsForChosenItems] removeObject:indexPath];
  }
  [super reloadItemsAtIndexPaths:pIndexPaths];
}

- (void)insertItemsAtIndexPaths:(NSArray *)pIndexPaths {
  NSArray *sortedPaths = [pIndexPaths sortedArrayUsingSelector:@selector(compare:)];
  for (NSIndexPath *insertedPath in sortedPaths) {
    NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
    for (NSIndexPath *path in [self innerPathsForChosenItems]) {
      if ([path section] != [insertedPath section] || [path compare:insertedPath] == NSOrderedAscending) {
        [updatedChoosenPaths addObject:path];
      } else if ([path compare:insertedPath] == NSOrderedDescending) {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] + 1
                                                           inSection:[path section]]];
      }
    }
    [self setInnerPathsForChosenItems:updatedChoosenPaths];
  }
  [super insertItemsAtIndexPaths:pIndexPaths];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)pIndexPath toIndexPath:(NSIndexPath *)pNewIndexPath {
  NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
  if ([[self innerPathsForChosenItems] containsObject:pIndexPath]) {
    [updatedChoosenPaths addObject:pNewIndexPath];
    [[self innerPathsForChosenItems] removeObject:pIndexPath];
  }
  for (NSIndexPath *path in [self innerPathsForChosenItems]) {
    if ([path section] != [pIndexPath section] && [path section] != [pNewIndexPath section]) {
      [updatedChoosenPaths addObject:path];
    } else if ([pIndexPath section] != [pNewIndexPath section]) {
      if ([path section] == [pIndexPath section]) {
        if ([path item] < [pIndexPath item]) {
          [updatedChoosenPaths addObject:path];
        } else {
          [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] - 1
                                                             inSection:[path section]]];
        }
      } else {
        if ([path item] < [pNewIndexPath item]) {
          [updatedChoosenPaths addObject:path];
        } else {
          [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] + 1
                                                             inSection:[path section]]];
        }
      }
    } else {
      if ([path item] < MIN([pIndexPath item], [pNewIndexPath item]) ||
          [path item] >= MAX([pIndexPath item], [pNewIndexPath item])) {
        [updatedChoosenPaths addObject:path];
      } else if ([pNewIndexPath item] > [pIndexPath item]) {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] - 1
                                                           inSection:[path section]]];
      } else {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] + 1
                                                           inSection:[path section]]];
      }
    }
  }
  [self setInnerPathsForChosenItems:updatedChoosenPaths];
  [super moveItemAtIndexPath:pIndexPath toIndexPath:pNewIndexPath];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)pIndexPaths {
  NSArray *sortedPaths = [pIndexPaths
                          sortedArrayUsingComparator:^NSComparisonResult(id pObject1, id pObject2) {
                            NSIndexPath *path1 = (NSIndexPath *)pObject1;
                            NSIndexPath *path2 = (NSIndexPath *)pObject2;
                            if ([path1 compare:path2] == NSOrderedAscending) {
                              return NSOrderedDescending;
                            } else if ([path1 compare:path2] == NSOrderedDescending) {
                              return NSOrderedDescending;
                            } else {
                              return NSOrderedSame;
                            }
                          }];
  for (NSIndexPath *deletedPath in sortedPaths) {
    NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
    for (NSIndexPath *path in [self innerPathsForChosenItems]) {
      if ([path section] != [deletedPath section] || [path compare:deletedPath] == NSOrderedAscending) {
        [updatedChoosenPaths addObject:path];
      } else if ([path compare:deletedPath] == NSOrderedDescending) {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] - 1
                                                           inSection:[path section]]];
      }
    }
    [self setInnerPathsForChosenItems:updatedChoosenPaths];
  }
  [super deleteItemsAtIndexPaths:pIndexPaths];
}

- (void)insertSections:(NSIndexSet *)pSections {
  for (NSUInteger index = [pSections firstIndex];
       index != NSNotFound;
       index = [pSections indexGreaterThanIndex:index]) {
    NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
    for (NSIndexPath *path in [self innerPathsForChosenItems]) {
      if ([path section] < index) {
        [updatedChoosenPaths addObject:path];
      } else {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item]
                                                           inSection:[path section] + 1]];
      }
    }
    [self setInnerPathsForChosenItems:updatedChoosenPaths];
  }
  [super insertSections:pSections];
}

- (void)moveSection:(NSInteger)pSection toSection:(NSInteger)pNewSection {
  NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
  for (NSIndexPath *path in [self innerPathsForChosenItems]) {
    NSRange affectedRange = NSMakeRange(MIN(pSection, pNewSection), ABS(pNewSection - pSection) + 1);
    if (NSLocationInRange([path section], affectedRange)) {
      if ([path section] == pSection) {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item] inSection:pNewSection]];
      } else {
        NSInteger shift = pNewSection > pSection ? -1 : +1;
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item]
                                                           inSection:[path section] + shift]];
      }
    } else {
      [updatedChoosenPaths addObject:path];
    }
  }
  [self setInnerPathsForChosenItems:updatedChoosenPaths];
  [super moveSection:pSection toSection:pNewSection];
}

- (void)deleteSections:(NSIndexSet *)pSections {
  for (NSUInteger index = [pSections lastIndex];
       index != NSNotFound;
       index = [pSections indexLessThanIndex:index]) {
    NSMutableSet *updatedChoosenPaths = [[NSMutableSet alloc] init];
    for (NSIndexPath *path in [self innerPathsForChosenItems]) {
      if ([path section] < index) {
        [updatedChoosenPaths addObject:path];
      } else if ([path section] > index) {
        [updatedChoosenPaths addObject:[NSIndexPath indexPathForItem:[path item]
                                                           inSection:[path section] - 1]];
      }
    }
    [self setInnerPathsForChosenItems:updatedChoosenPaths];
  }
  [super deleteSections:pSections];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)pCollectionView
    didSelectItemAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([[self innerPathsForChosenItems] containsObject:pIndexPath]) {
    [self dechooseItemAtIndexPath:pIndexPath animated:YES];
    if ([[self gridViewDelegate] respondsToSelector:@selector(gridCollectionView:didDechooseObject:)]) {
      [[self gridViewDelegate] gridCollectionView:self
                                didDechooseObject:[[self objectsToDisplay] objectAtIndex:[pIndexPath item]]];
    }
  } else {
    [[self gridViewDelegate] gridCollectionView:self
                                didSelectObject:[[self objectsToDisplay] objectAtIndex:[pIndexPath item]]];
  }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)pCollectionView numberOfItemsInSection:(NSInteger)pSection {
  return [[self objectsToDisplay] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)pCollectionView
                  cellForItemAtIndexPath:(NSIndexPath *)pIndexPath {
  ATGGridCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:[self cellsNibName]
                                                                    forIndexPath:pIndexPath];
  [cell setObjectToDisplay:[[self objectsToDisplay] objectAtIndex:[pIndexPath item]]];
  if ([[self gridViewDelegate] respondsToSelector:@selector(gridCollectionView:willDisplayCell:)]) {
    [[self gridViewDelegate] gridCollectionView:self willDisplayCell:cell];
  }
  return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if ([[self gridViewDelegate] respondsToSelector:@selector(gridCollectionViewWillAdjustContentOffset:)]) {
    [[self gridViewDelegate] gridCollectionViewWillAdjustContentOffset:self];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if ([[self gridViewDelegate] respondsToSelector:@selector(gridCollectionViewDidAdjustContentOffset:)]) {
    [[self gridViewDelegate] gridCollectionViewDidAdjustContentOffset:self];
  }
}

#pragma mark - ATGGridCollectionViewLayoutDelegate

- (BOOL)collectionView:(UICollectionView *)pGridView
    layout:(ATGGridCollectionViewLayout *)pLayout
    isItemChosenAtIndexPath:(NSIndexPath *)pIndexPath {
  return [[self innerPathsForChosenItems] containsObject:pIndexPath];
}

#pragma mark - Public Protocol Implementation

+ (Class)gridCollectionViewLayoutClass {
  return [ATGGridCollectionViewLayout class];
}

- (id)initWithFrame:(CGRect)pFrame cellsNibName:(NSString *)pNibName {
  self = [super initWithFrame:pFrame collectionViewLayout:[[[ATGGridCollectionView gridCollectionViewLayoutClass] alloc] init]];
  if (self) {
    [self initWithNibName:pNibName];
  }
  return self;
}

- (NSArray *)indexPathsForChosenItems {
  return [[[self innerPathsForChosenItems] allObjects] sortedArrayUsingComparator:
          ^NSComparisonResult(id pObject1, id pObject2) {
            NSIndexPath *path1 = (NSIndexPath *)pObject1;
            NSIndexPath *path2 = (NSIndexPath *)pObject2;
            return [path1 compare:path2];
          }];
}

- (void)chooseItemAtIndexPath:(NSIndexPath *)pIndexPath animated:(BOOL)pAnimated {
  if ([pIndexPath section] < [self numberOfSections] &&
      [pIndexPath item] < [self numberOfItemsInSection:[pIndexPath section]]) {
    [[self innerPathsForChosenItems] addObject:pIndexPath];
    [(ATGGridCollectionViewCell *)[self cellForItemAtIndexPath:pIndexPath] setChosen:YES animated:pAnimated];
  }
}

- (void)dechooseItemAtIndexPath:(NSIndexPath *)pIndexPath animated:(BOOL)pAnimated {
  [[self innerPathsForChosenItems] removeObject:pIndexPath];
  [(ATGGridCollectionViewCell *)[self cellForItemAtIndexPath:pIndexPath] setChosen:NO animated:pAnimated];
}

- (void)addObjectToDisplay:(id)pObject {
  NSArray *objects = [self objectsToDisplay];
  objects = [objects arrayByAddingObject:pObject];
  self->mObjectsToDisplay = objects;
  [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[objects count] - 1 inSection:0]]];
}

- (void)removeObjectToDisplay:(id)pObject {
  NSUInteger index = [self->mObjectsToDisplay indexOfObject:pObject];
  if (index != NSNotFound) {
    NSMutableArray *result = [self->mObjectsToDisplay mutableCopy];
    [result removeObjectAtIndex:index];
    self->mObjectsToDisplay = [result copy];
    [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
  }
}

#pragma mark - Private Protocol Implementation

- (void)initWithNibName:(NSString *)pNibName {
  UINib *nib = [UINib nibWithNibName:pNibName bundle:[NSBundle mainBundle]];
  NSArray *nibContents = [nib instantiateWithOwner:self options:nil];
  if ([nibContents count] == 1 &&
      [[nibContents objectAtIndex:0] isKindOfClass:[ATGGridCollectionViewCell class]]) {
    [self setInnerPathsForChosenItems:[[NSMutableSet alloc] init]];
    [self setCellsNibName:pNibName];
    ATGGridCollectionViewCell *cell = (ATGGridCollectionViewCell *)[nibContents objectAtIndex:0];
    UICollectionViewFlowLayout *layout = [[[[self class] gridCollectionViewLayoutClass] alloc] init];
    if (![layout isKindOfClass:[ATGGridCollectionViewLayout class]]) {
      [NSException raise:@"Can't load ATGGridCollectionViewLayout class specified."
                  format:@"Layout class returned by grid collection view (%@) "
                         @"is not a subclass of ATGGridCollectionViewLayout.", [layout class]];
    }
    [layout setItemSize:[cell bounds].size];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [self setCollectionViewLayout:layout];
    [self setDelegate:self];
    [self setDataSource:self];
    UISwipeGestureRecognizer *recognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSwipeGestureRecognizer:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:recognizer];
    [self setSwipeRecognizer:recognizer];
    [self registerNib:nib forCellWithReuseIdentifier:pNibName];
  } else {
    [NSException raise:@"Can't load ATGGridCollectionViewCell from the NIB file specified."
                format:@"NIB file specified (%@) doesn't contain a valid cell instance "
                       @"or contains more than one object.", pNibName];
  }
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer *)pRecognizer {
  CGPoint location = [pRecognizer locationInView:self];
  NSIndexPath *path = [self indexPathForItemAtPoint:location];
  if (path) {
    [self chooseItemAtIndexPath:path animated:YES];
    if ([[self gridViewDelegate] respondsToSelector:@selector(gridCollectionView:didChooseObject:)]) {
      [[self gridViewDelegate] gridCollectionView:self
                                  didChooseObject:[[self objectsToDisplay] objectAtIndex:[path item]]];
    }
  }
}

@end
