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

#import <QuartzCore/QuartzCore.h>
#import "ATGGridView.h"

#pragma mark - ATGGridView Private Protocol Definition
#pragma mark -

@interface ATGGridView () <UIGestureRecognizerDelegate>
{
  CGFloat mRowHeight;
  NSInteger mNumberOfCellsToAdd;
}

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) UIGestureRecognizer *editGestureRecognizer;
@property (nonatomic, strong) NSMutableDictionary *numberOfColumnsCache;
@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableArray *selectedCells;
@property (nonatomic, strong) NSMutableArray *editingCells;
@property (nonatomic, strong) ATGGridViewCell *highlightedCell;
@property (nonatomic, strong) NSMutableArray *viewsToRemove;
@property (nonatomic, strong) NSMutableArray *indexPathsToRemove;

#pragma mark - Initialization

- (void) additionalInit;

#pragma mark - UI Events Handling

- (void) handleLongPress:(UILongPressGestureRecognizer *)recognizer;
- (void) handleTap:(UITapGestureRecognizer *)recognizer;
- (void) handleShortPress:(UILongPressGestureRecognizer *)recognizer;
- (void) handleSwipe:(UISwipeGestureRecognizer *)recognizer;

#pragma mark - Inner Grid Methods

- (NSInteger)     firstVisibleRow;
- (NSInteger)     lastVisibleRow;
- (NSIndexPath *) indexPathOfVisibleCell:(ATGGridViewCell *)cell NS_RETURNS_NOT_RETAINED;

- (void) reloadColumnNumberCache;

- (NSInteger) numberOfIndexPathsInArray:(NSArray *)array
 beforeIndexPath                       :(NSIndexPath *)indexPath;
- (NSIndexPath *) shiftIndexPath:(NSIndexPath *)indexPath
 steps                          :(NSInteger)steps NS_RETURNS_NOT_RETAINED;
- (NSMutableArray *) shiftIndexPathsArray:(NSArray *)array NS_RETURNS_RETAINED;

- (void) checkUpdateValidity;

- (void) repositionCell:(ATGGridViewCell *)cell toIndexPath:(NSIndexPath *)toPath
 fromIndexPath         :(NSIndexPath *)fromPath animated:(BOOL)animated;
- (CGRect)                               frameFromIndexPath:(NSIndexPath *)indexPath;
- (void)                                 innerRemoveCells;
- (NSMutableDictionary *) innerMoveCells NS_RETURNS_RETAINED;
- (void)                                 innerAppendCells:(NSMutableDictionary *)visibleCells;

- (ATGGridViewCell *) cellFromGestureLocation:(UIGestureRecognizer *)recognizer;
- (void)              innerSelectCell:(ATGGridViewCell *)cell;
- (void)              innerEditCell:(ATGGridViewCell *)cell;

@end

#pragma mark - ATGGridView Implementation
#pragma mark -

@implementation ATGGridView

#pragma mark - Synthesized Properties

@synthesize rowHeight = mRowHeight;
@synthesize delegate;
@synthesize dataSource;
@synthesize backgroundView;
@synthesize editingEnabed;
@synthesize editGestureRecognizer;
@synthesize numberOfColumnsCache, visibleCells, selectedCells, editingCells;
@synthesize highlightedCell, viewsToRemove, indexPathsToRemove;

#pragma mark - Custom Properties

- (void) setEditingEnabed:(BOOL)pEditingEnabed {
  editingEnabed = pEditingEnabed;
  [[self editGestureRecognizer] setEnabled:pEditingEnabed];
}

#pragma mark - UIView

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self additionalInit];
  }
  return self;
}

- (id) initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    [self additionalInit];
  }
  return self;
}

- (void) layoutSubviews {
  [super layoutSubviews];

  if ([[self numberOfColumnsCache] count] == 0) {
    [self reloadColumnNumberCache];
  }

  CGRect bounds = [self bounds];
  CGSize contentSize = CGSizeMake(bounds.size.width,
                                  [self rowHeight] * [[self dataSource]
                                                      numberOfRowsInGridView:self]);
  if (contentSize.height < bounds.size.height) {
    contentSize.height = bounds.size.height + 1;
  }
  if ([self contentSize].height < contentSize.height) {
    [self setContentSize:contentSize];
  }

  [[self backgroundView] setCenter:CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) )];
  [self addSubview:[self backgroundView]];

  NSInteger firstRow = [self firstVisibleRow];
  NSInteger lastRow = [self lastVisibleRow];
  // First of all determine, which cells should be removed from their superview.
  // We're not going to display cells moved out of user's eyes.
  NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
  for (NSIndexPath *indexPath in[[self visibleCells] allKeys]) {
    if ([indexPath row] < firstRow || [indexPath row] > lastRow) {
      [keysToRemove addObject:indexPath];
      ATGGridViewCell *cell = [[self visibleCells] objectForKey:indexPath];
      [cell removeFromSuperview];
    }
  }
  [[self visibleCells] removeObjectsForKeys:keysToRemove];
  for (NSInteger row = firstRow; row <= lastRow; row++) {
    // Read number of columns from cache. It's essential for the cells to be repositioned properly during
    // add/remove cell process.
    // This cache is renewed each time you call the endUpdates method (or at the very first grid presentation).
    NSInteger columnsNumber =
      [(NSNumber *)[[self numberOfColumnsCache]
                    objectForKey:[NSNumber numberWithInteger:row]] integerValue];
    for (NSInteger column = 0; column < columnsNumber; column++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForColumn:column inRow:row];
      ATGGridViewCell *cell = [[self visibleCells] objectForKey:indexPath];
      if (!cell) {
        // No cell in the mVisibleCells? Then it haven't been displayed to user before this method invocation.
        // Create a new instance, add it to grid and send appropriate messages to delegate.
        cell = [[self dataSource] gridView:self cellAtIndexPath:indexPath];
        [cell setEditing:[[self editingCells] containsObject:indexPath]];
        [cell setSelected:[[self selectedCells] containsObject:indexPath]];
        if ([[self delegate]
             respondsToSelector:@selector(gridView:willDisplayCell:atIndexPath:)]) {
          [[self delegate] gridView:self willDisplayCell:cell atIndexPath:indexPath];
        }
        [[self visibleCells] setObject:cell forKey:indexPath];
        [self insertSubview:cell atIndex:0];
      }
      // Always display cells at their proper position.
      [self repositionCell:cell toIndexPath:indexPath fromIndexPath:nil animated:NO];
    }
  }
}

#pragma mark - ATGGridView

- (void) reloadData {
  // Just drop all cached data and layout self. This will actually reload data from data source.
  for (ATGGridViewCell *cell in[[self visibleCells] allValues]) {
    [cell removeFromSuperview];
  }
  [[self visibleCells] removeAllObjects];
  [[self numberOfColumnsCache] removeAllObjects];
  [[self selectedCells] removeAllObjects];
  [[self editingCells] removeAllObjects];
  [self setContentOffset:CGPointZero];
  [self setNeedsLayout];
}

- (void) beginUpdates {
  [[self indexPathsToRemove] removeAllObjects];
  mNumberOfCellsToAdd = 0;

  [CATransaction begin];
  [CATransaction setAnimationDuration:.7];
  [CATransaction
   setAnimationTimingFunction:[CAMediaTimingFunction
                               functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [CATransaction setCompletionBlock:
   ^{
     // When all animations are done, we have to remove views that were parts of 'remove cell' animation.
     for (UIView * view in [self viewsToRemove]) {
       [view removeFromSuperview];
     }
     [[self viewsToRemove] removeAllObjects];
     // Actualize content size when animations are done. This is essential for cases when the hole row
     // is removed/added.
     CGRect bounds = [self bounds];
     CGSize contentSize = CGSizeMake (bounds.size.width,
                                      [self rowHeight] * [[self numberOfColumnsCache] count]);
     if (contentSize.height < bounds.size.height) {
       contentSize.height = bounds.size.height + 1;
     }
     [self setContentSize:contentSize];
     [self flashScrollIndicators];
   }
  ];
}

- (void) endUpdates {
  [self checkUpdateValidity];

  // First remove all cells marked for removal.
  [self innerRemoveCells];
  // Then reposition existing cells with regard to their new grid positions (due to cells removal).
  NSMutableDictionary *newVisibleCells = [self innerMoveCells];
  // And the very last operation is to append new cells to the end of the grid.
  [self innerAppendCells:newVisibleCells];
  // Now switch mVisisbleCells map, layoutSubviews method relies on it.
  self.visibleCells = newVisibleCells;

  NSInteger rowsNumber = [[self dataSource] numberOfRowsInGridView:self];
  if ([self rowHeight] * rowsNumber < [self contentOffset].y + [self bounds].size.height) {
    // We're displaying the very last row and we're about to remove it.
    // Gracefully change grid position to hide the row to be removed.
    CGPoint offset = CGPointMake( [self contentOffset].x,
                                  MAX([self rowHeight] * rowsNumber - [self bounds].size.height, 0) );
    [self setContentOffset:offset animated:YES];
  }

  [CATransaction commit];
  // Some updates are made to the grid. Reload rows-columns from data source.
  [self reloadColumnNumberCache];
}

- (void) appendCells:(NSInteger)pNumberOfCells {
  // Just save the number. It will be used during endUpdates method invocation.
  mNumberOfCellsToAdd += pNumberOfCells;
}

- (void) deleteCellAtIndexPath:(NSIndexPath *)pIndexPath {
  // Just save the index. It will be used during endUpdates method invocation.
  if ([[self indexPathsToRemove] containsObject:pIndexPath]) {
    [NSException raise:@"InvalidGridViewUpdate"
                format:@"Invalid GridView update operation. Can't delete the same cell twice: (%@).", pIndexPath];
  }
  [[self indexPathsToRemove] addObject:pIndexPath];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)                          gestureRecognizer:(UIGestureRecognizer *)pGestureRecognizer
 shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)pOtherGestureRecognizer {
  // Grid view utilizes 4 different gesture recognizers, all these recognizers should work simultaneously.
  return YES;
}

#pragma mark - Private Protocol Implementation

- (void) additionalInit {
  self.visibleCells = [[NSMutableDictionary alloc] init];
  self.selectedCells = [[NSMutableArray alloc] init];
  self.editingCells = [[NSMutableArray alloc] init];

  self.numberOfColumnsCache = [[NSMutableDictionary alloc] init];

  self.viewsToRemove = [[NSMutableArray alloc] init];
  self.indexPathsToRemove = [[NSMutableArray alloc] init];

  [self setBackgroundColor:[UIColor whiteColor]];

  UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
  [longPressRecognizer setMinimumPressDuration:1];
  [self addGestureRecognizer:longPressRecognizer];
  [self setEditGestureRecognizer:longPressRecognizer];
  UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
  [self addGestureRecognizer:tapRecognizer];
  // If the user has been touching the screen for 1 second, do not handle 'touch up' event as tap.
  // requireGestureRecognizerToFail: method will cancel tap recognizer, if long press is occured.
  [tapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
  UILongPressGestureRecognizer *shortPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleShortPress:)];
  [shortPressRecognizer setMinimumPressDuration:.1];
  [self addGestureRecognizer:shortPressRecognizer];
  [shortPressRecognizer setDelegate:self];
  UISwipeGestureRecognizer *swipeRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
  [self addGestureRecognizer:swipeRecognizer];
}

- (void) handleLongPress:(UILongPressGestureRecognizer *)pRecognizer {
  if ([pRecognizer state] == UIGestureRecognizerStateBegan) {
    ATGGridViewCell *activeCell = [self cellFromGestureLocation:pRecognizer];
    [self innerEditCell:activeCell];
  }
}

- (void) handleTap:(UITapGestureRecognizer *)pRecognizer {
  if ([pRecognizer state] == UIGestureRecognizerStateEnded) {
    ATGGridViewCell *activeCell = [self cellFromGestureLocation:pRecognizer];
    [self innerSelectCell:activeCell];
  }
}

- (void) handleShortPress:(UILongPressGestureRecognizer *)pRecognizer {
  if ([pRecognizer state] == UIGestureRecognizerStateBegan) {
    ATGGridViewCell *activeCell = [self cellFromGestureLocation:pRecognizer];
    if (!activeCell) {
      return;
    }
    [activeCell setHighlighted:YES];
    self.highlightedCell = activeCell;
  } else {
    [[self highlightedCell] setHighlighted:NO];
    self.highlightedCell = nil;
  }
}

- (void) handleSwipe:(UISwipeGestureRecognizer *)pRecognizer {
  [self innerEditCell:[self cellFromGestureLocation:pRecognizer]];
}

- (ATGGridViewCell *) cellFromGestureLocation:(UIGestureRecognizer *)pRecognizer {
  // All user events are come from visible views. So it's Ok to check visible cells only.
  for (ATGGridViewCell *cell in[[self visibleCells] allValues]) {
    if ([cell pointInside:[pRecognizer locationInView:cell] withEvent:nil]) {
      return cell;
    }
  }
  return nil;
}

- (void) innerSelectCell:(ATGGridViewCell *)pCell {
  if (!pCell) {
    return;
  }
  if ([pCell isEditing]) {
    [pCell setEditing:NO];
    [[self editingCells] removeObject:[self indexPathOfVisibleCell:pCell]];
  } else {
    // Deselect visible cell. This will update its outfit.
    // If selected cell is invisible, it will be presented to user with proper outfit while user is scrolling.
    [(ATGGridViewCell *)[[self visibleCells]
                         objectForKey:[[self selectedCells] lastObject]] setSelected:NO];
    [[self selectedCells] removeAllObjects];
    // Select new cell and send proper messages to delegate.
    [pCell setSelected:YES];
    [[self selectedCells] addObject:[self indexPathOfVisibleCell:pCell]];
    if ([[self delegate]
         respondsToSelector:@selector(gridView:didSelectCellAtIndexPath:)]) {
      [[self delegate] gridView:self
       didSelectCellAtIndexPath:[self indexPathOfVisibleCell:pCell]];
    }
  }
}

- (void) innerEditCell:(ATGGridViewCell *)pCell {
  if (!pCell) {
    return;
  }
  // Set cell's editing mode.
  [pCell setEditing:YES];
  [self bringSubviewToFront:pCell];
  [[self editingCells] addObject:[self indexPathOfVisibleCell:pCell]];

  // And animate entering to editing mode.
  [self beginUpdates];

  // Bounce the cell to be edited.
  CATransform3D zoomed = CATransform3DMakeScale(1.2, 1.2, 1);
  CATransform3D panned = CATransform3DMakeScale(.95, .95, 1);
  CAKeyframeAnimation *animation =
    [CAKeyframeAnimation animationWithKeyPath:@"transform"];
  [animation
   setValues:[NSArray
              arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DIdentity],
              [NSValue valueWithCATransform3D:zoomed],
              [NSValue valueWithCATransform3D:panned],
              [NSValue valueWithCATransform3D:CATransform3DIdentity], nil]];
  [[pCell layer] addAnimation:animation forKey:@"transform"];
  // And change its outfit gracefully.
  CATransition *fade = [CATransition animation];
  [fade setType:kCATransitionFade];
  [[pCell layer] addAnimation:fade forKey:@"fade"];

  [self endUpdates];
}

- (NSIndexPath *) indexPathOfVisibleCell:(ATGGridViewCell *)pCell {
  NSSet *result = [[self visibleCells]
                   keysOfEntriesPassingTest:
                   ^BOOL (id pKey, id pObject, BOOL * pStop)
                   {
                     return *pStop = (pObject == pCell);
                   }
                  ];
  return [result anyObject];
}

- (void) repositionCell:(ATGGridViewCell *)pCell toIndexPath:(NSIndexPath *)pToPath
          fromIndexPath:(NSIndexPath *)pFromPath animated:(BOOL)pAnimated {
  CGRect frame = [self frameFromIndexPath:pToPath];
  CGPoint center = CGPointMake( CGRectGetMidX(frame), CGRectGetMidY(frame) );
  CGRect bounds = CGRectMake( 0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) );
  if ( pAnimated && ([pToPath row] == [pFromPath row]) ) {
    // Move the cell within the same row. Just reposition it to a new location.
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setFromValue:[NSValue valueWithCGPoint:[pCell center]]];
    [move setToValue:[NSValue valueWithCGPoint:center]];
    [[pCell layer] addAnimation:move forKey:@"move"];
  } else if (pAnimated) {
    // Move the cell and change its row. We're going to slide cell twin out of the grid
    // and slide the cell in at proper row.
    CGRect frameFakeFrom = [self frameFromIndexPath:pFromPath];
    // Create cell twin. It will be an image with the very same outfit.
    UIGraphicsBeginImageContext(frameFakeFrom.size);
    ATGGridViewCell *cell = pCell;
    // Remove the cell from its superview, or renderInContext: method will re-layout the whole grid.
    // This will ruin movement animations.
    [cell removeFromSuperview];
    [[pCell layer] renderInContext:UIGraphicsGetCurrentContext()];
    // When everything is rendered, just add the cell back to grid.
    [self addSubview:cell];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Here is cell's twin.
    UIImageView *fakeCell = [[UIImageView alloc] initWithImage:cellImage];
    [self addSubview:fakeCell];
    // Don't forget to remove it from grid when animations are done.
    [[self viewsToRemove] addObject:fakeCell];
    // Slide it out.
    CGRect frameFakeTo = [self frameFromIndexPath:[NSIndexPath indexPathForColumn:-1
                                                                            inRow:[pFromPath row]]];
    CABasicAnimation *moveFake = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveFake setFromValue:[NSValue valueWithCGPoint:CGPointMake( CGRectGetMidX(frameFakeFrom),
                                                                  CGRectGetMidY(frameFakeFrom) )]];
    [moveFake setToValue:[NSValue valueWithCGPoint:CGPointMake( CGRectGetMidX(frameFakeTo),
                                                                CGRectGetMidY(frameFakeTo) )]];
    [[fakeCell layer] addAnimation:moveFake forKey:@"move"];

    // Move the cell in at proper row position.
    NSInteger rowsNumber =
      [(NSNumber *)[[self numberOfColumnsCache]
                    objectForKey:[NSNumber numberWithInteger:[pToPath row]]] integerValue];
    CGRect frameFrom = [self frameFromIndexPath:[NSIndexPath indexPathForColumn:rowsNumber
                                                                          inRow:[pToPath row]]];
    CGRect frameTo = [self frameFromIndexPath:pToPath];
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setFromValue:[NSValue valueWithCGPoint:CGPointMake( CGRectGetMidX(frameFrom),
                                                              CGRectGetMidY(frameFrom) )]];
    [move setToValue:[NSValue valueWithCGPoint:CGPointMake( CGRectGetMidX(frameTo),
                                                            CGRectGetMidY(frameTo) )]];
    [[pCell layer] addAnimation:move forKey:@"move"];
  }
  // Don't forget to update cell location. This should happen for both animated and instant move.
  [pCell setCenter:center];
  [pCell setBounds:bounds];
}

- (CGRect) frameFromIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat columnWidth = 0;
  if ([[self delegate] respondsToSelector:@selector(gridView:widthForColumnsInRow:)]) {
    columnWidth = [[self delegate] gridView:self widthForColumnsInRow:[pIndexPath row]];
  } else {
    // Delegate doesn't implement this method? Just stretch cells in the row to occupy all available width.
    columnWidth = [self bounds].size.width /
                  [(NSNumber *)[[self numberOfColumnsCache]
                                objectForKey:[NSNumber numberWithInteger:[pIndexPath row]]] integerValue];
  }
  return CGRectMake(columnWidth * [pIndexPath column], [self rowHeight] * [pIndexPath row],
                    columnWidth, [self rowHeight]);
}

- (NSInteger) numberOfIndexPathsInArray:(NSArray *)pArray
                        beforeIndexPath:(NSIndexPath *)pIndexPath {
  NSInteger result = 0;
  for (NSIndexPath *indexPath in pArray) {
    if ( ([indexPath row] < [pIndexPath row]) ||
         ([indexPath row] == [pIndexPath row] && [indexPath column] <= [pIndexPath column]) ) {
      result++;
    }
  }
  return result;
}

- (NSIndexPath *) shiftIndexPath:(NSIndexPath *)pIndexPath steps:(NSInteger)pSteps {
  if (pSteps == 0) {
    return pIndexPath;
  } else if (pSteps > 0) {
    NSInteger row = [pIndexPath row];
    NSInteger column = [pIndexPath column];
    for (NSInteger counter = 0; counter < pSteps; counter++) {
      if (++column >= [(NSNumber *)[[self numberOfColumnsCache]
                                    objectForKey:[NSNumber numberWithInteger:row]] integerValue]) {
        column = 0;
        row++;
      }
    }
    return [NSIndexPath indexPathForColumn:column inRow:row];
  } else {
    NSInteger row = [pIndexPath row];
    NSInteger column = [pIndexPath column];
    for (NSInteger counter = 0; counter > pSteps; counter--) {
      if (--column < 0) {
        column = [(NSNumber *)[[self numberOfColumnsCache]
                               objectForKey:[NSNumber numberWithInteger:--row]] integerValue] - 1;
      }
    }
    return [NSIndexPath indexPathForColumn:column inRow:row];
  }
}

- (NSInteger) firstVisibleRow {
  CGPoint contentOffset = [self contentOffset];
  return MAX(floor(contentOffset.y / [self rowHeight]), 0);
}

- (NSInteger) lastVisibleRow {
  CGPoint contentOffset = [self contentOffset];
  CGRect bounds = [self bounds];
  return MIN(floor( (contentOffset.y + bounds.size.height) / [self rowHeight] ),
             [[self dataSource] numberOfRowsInGridView:self] - 1);
}

- (void) checkUpdateValidity {
  NSInteger initialCellsCount = 0;
  for (NSNumber *value in[[self numberOfColumnsCache] allValues]) {
    initialCellsCount += [value integerValue];
  }
  NSInteger resultingCellsCount = 0;
  for (NSInteger row = 0; row < [[self dataSource] numberOfRowsInGridView:self]; row++) {
    resultingCellsCount += [[self dataSource] gridView:self numberOfColumnsInRow:row];
  }
  if (initialCellsCount + mNumberOfCellsToAdd - [[self indexPathsToRemove] count] != resultingCellsCount) {
    [NSException raise:@"InvalidGridViewUpdate"
                format:@"Invalid GridView update operation. Initial number of cells (%d), "
     @"adding (%d), removing (%d) cells. Resulting number of cells (%d).",
     initialCellsCount, mNumberOfCellsToAdd, [[self indexPathsToRemove] count],
     resultingCellsCount];
  }
}

- (void) innerRemoveCells {
  for (NSIndexPath *removePath in [self indexPathsToRemove]) {
    ATGGridViewCell *removeCell = [[self visibleCells] objectForKey:removePath];
    if (removeCell) {
      CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
      [fade setFromValue:[NSNumber numberWithInteger:1]];
      [fade setToValue:[NSNumber numberWithInteger:0]];
      [[removeCell layer] addAnimation:fade forKey:@"fade"];
      CABasicAnimation *recede = [CABasicAnimation animationWithKeyPath:@"transform"];
      [recede setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)]];
      [[removeCell layer] addAnimation:recede forKey:@"recede"];
      [self sendSubviewToBack:removeCell];
      [[self viewsToRemove] addObject:removeCell];
    }
  }

  [[self selectedCells] removeObjectsInArray:[self indexPathsToRemove]];
  [[self editingCells] removeObjectsInArray:[self indexPathsToRemove]];
  [[self visibleCells] removeObjectsForKeys:[self indexPathsToRemove]];
  self.selectedCells = [self shiftIndexPathsArray:[self selectedCells]];
  self.editingCells = [self shiftIndexPathsArray:[self editingCells]];
}

- (NSMutableDictionary *) innerMoveCells {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[[self visibleCells] count]];
  // First, calculate cells movement map. Some cells should be repositioned due to removal of cells
  // located before them. Save this map in form of 'old position -> new position'.
  NSMutableDictionary *cellsMovementMap = [[NSMutableDictionary alloc] initWithCapacity:[[self visibleCells] count]];
  for (NSIndexPath *oldPath in[[self visibleCells] allKeys]) {
    NSIndexPath *newPath = [self shiftIndexPath:oldPath
                                          steps:-[self numberOfIndexPathsInArray:[self indexPathsToRemove]
                                                                 beforeIndexPath:oldPath]];
    [cellsMovementMap setObject:newPath forKey:oldPath];
  }
  // Now we're ready to perform an actual movement.
  for (NSIndexPath *oldPath in[cellsMovementMap allKeys]) {
    NSIndexPath *newPath = [cellsMovementMap objectForKey:oldPath];
    ATGGridViewCell *cell = [[self visibleCells] objectForKey:oldPath];
    [self repositionCell:cell toIndexPath:newPath fromIndexPath:oldPath animated:YES];
    if ([newPath row] >= [self firstVisibleRow] && [newPath row] <= [self lastVisibleRow]) {
      [result setObject:[[self visibleCells] objectForKey:oldPath] forKey:newPath];
    } else {
      [[self viewsToRemove] addObject:cell];
    }
    if ([newPath row] != [oldPath row]) {
      [self sendSubviewToBack:cell];
    }
  }
  return result;
}

- (void) innerAppendCells:(NSMutableDictionary *)pVisibleCells {
  for (NSInteger row = [self firstVisibleRow]; row <= [self lastVisibleRow]; row++) {
    for (NSInteger column = 0; column < [[self dataSource] gridView:self
                                               numberOfColumnsInRow:row]; column++) {
      NSIndexPath *path = [NSIndexPath indexPathForColumn:column inRow:row];
      if (![[pVisibleCells allKeys] containsObject:path]) {
        ATGGridViewCell *cell = [[self dataSource] gridView:self cellAtIndexPath:path];
        if ([[self delegate]
             respondsToSelector:@selector(gridView:willDisplayCell:atIndexPath:)]) {
          [[self delegate] gridView:self willDisplayCell:cell atIndexPath:path];
        }
        [self repositionCell:cell toIndexPath:path fromIndexPath:nil animated:NO];
        [self insertSubview:cell atIndex:0];
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fade setFromValue:[NSNumber numberWithInteger:0]];
        [fade setToValue:[NSNumber numberWithInteger:1]];
        [[cell layer] addAnimation:fade forKey:@"fade"];
        [pVisibleCells setObject:cell forKey:path];
      }
    }
  }
}

- (NSMutableArray *) shiftIndexPathsArray:(NSArray *)pArray {
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[pArray count]];
  for (NSIndexPath *indexPath in pArray) {
    [result addObject:[self shiftIndexPath:indexPath
                                     steps:-[self numberOfIndexPathsInArray:[self indexPathsToRemove]
                                                            beforeIndexPath:indexPath]]];
  }
  return result;
}

- (void) reloadColumnNumberCache {
  [[self numberOfColumnsCache] removeAllObjects];
  for (NSInteger row = 0; row < [[self dataSource] numberOfRowsInGridView:self]; row++) {
    [[self numberOfColumnsCache] setObject:[NSNumber numberWithInteger:[[self dataSource] gridView:self
                                                                        numberOfColumnsInRow:row]]
                              forKey:[NSNumber numberWithInteger:row]];
  }
}

@end

#pragma mark - NSIndexPath (ATGGridView) Category Implementation
#pragma mark -

@implementation NSIndexPath (ATGGridView)

+ (NSIndexPath *) indexPathForColumn:(NSInteger)pColumn inRow:(NSInteger)pRow {
  return [self indexPathForRow:pRow inSection:pColumn];
}

- (NSInteger) column {
  return [self section];
}

@end