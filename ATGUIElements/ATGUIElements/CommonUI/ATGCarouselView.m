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

#import "ATGCarouselView.h"
#import <ATGMobileCommon/ATGThemeManager.h>

@interface ATGCarouselView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic, assign) NSInteger itemsPerPage;
@end

@implementation ATGCarouselView
@synthesize autoScroll = _autoScroll, showPageControl = _showPageControl, scrollEnabled = _scrollEnabled, scrollToPosition = _scrollToPosition, circularScrollEnabled = _circularScrollEnabled;

- (id)initWithFrame:(CGRect)pFrame layout:(UICollectionViewFlowLayout *)pLayout pageSize:(CGSize)pPageSize itemSize:(CGSize)pSize edgeInsets:(UIEdgeInsets)pInsets {
  self = [super initWithFrame:pFrame];
  if (self) {
    
    //Horizontal Only People!
    pLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:pLayout];
    UICollectionView *pCollectionView = self.collectionView;
    
    self.edgeInsets = pInsets;
    self.itemSize = pSize;
    self.itemSpacing = 5.0;
    self.pageSize = pPageSize;
    self.itemsPerPage = -1;
    self.currentPage = 0;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundView = nil;
    [self addSubview:self.collectionView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    [self.pageControl addTarget:self action:@selector(page:) forControlEvents:UIControlEventTouchUpInside];
    self.pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage = YES;
    self.showPageControl = YES;
    
    UIPageControl *pControl = self.pageControl;
    pControl.translatesAutoresizingMaskIntoConstraints = NO;
    pCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSDictionary *views = NSDictionaryOfVariableBindings(pCollectionView, pControl);
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pCollectionView]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pCollectionView]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pControl]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pControl(==20)]-20-|" options:0 metrics:nil views:views]];
    [self addConstraints:constraints];
    
    self.scrollInterval = 5.0;
    self.autoScrollDisablesOnInteraction = YES;
    self.scrollEnabled = YES;
    self.scrollToPosition = UICollectionViewScrollPositionCenteredHorizontally;
    self.circularScrollEnabled = NO;
    
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  self.collectionView.backgroundColor = backgroundColor;
  [super setBackgroundColor:backgroundColor];
}

- (void)reloadData {
  [self.collectionView reloadData];
}

- (void)registerClass:(Class)pClass forCellWithReuseIdentifier:(NSString *)pIdentifier {
  [self.collectionView registerClass:pClass forCellWithReuseIdentifier:pIdentifier];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  //Delegate the datasource
  NSInteger pIndex = indexPath.row;
  if (self.circularScrollEnabled) {
    if (pIndex == 0) {
      pIndex = [self.dataSource numberOfItemsInCarousel:self] - 1;
    } else if (pIndex == [self.dataSource numberOfItemsInCarousel:self] + 1) {
      pIndex = 0;
    } else {
      pIndex = pIndex - 1;
    }
  }
  return [self.dataSource carousel:self cellForItemAtIndex:pIndex];
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)pIdentifier forIndex:(NSInteger)pIndex {
  return [self.collectionView dequeueReusableCellWithReuseIdentifier:pIdentifier forIndexPath:[NSIndexPath indexPathForItem:pIndex inSection:0]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  [self updatePagingInformation];
  
  // This carousel is used only with paging enabled.
  // In this case we want the total number of items to be evenly divisible by the number of itemsPerPage
  // so that on the last/first pages, we correctly scroll to that page, and render invisible placeholder cells if necessary.
  // If we do not do this, then when we scroll to the last page (for example), the items we see are those that belong on the
  // second last page as well as the last because we only need to move forward by x items and not a whole page. Now if we try to
  // scroll further forward in this state, we will end up back at the previous page due to the horizontal position we are given
  // by the scrollView delegate. This is undesireable behavior and is quite confusing to encounter as a user, as such we
  // make the total number of items evenly divisible by the number of pages we have so that we can move forward/backward accurately.
  NSInteger items = self.pageControl.numberOfPages * self.itemsPerPage;
  
  return items;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return self.edgeInsets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return self.itemSpacing;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self stopAutoScrolling];
  
  if (indexPath.row < [self.dataSource numberOfItemsInCarousel:self]) {
    return YES;
  }
  
  return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < [self.dataSource numberOfItemsInCarousel:self]) {
    return YES;
  }
  
  return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  [cell setBackgroundColor:(UIColor *)[[ATGThemeManager themeManager] findResourceById:@"quaternaryColor"]];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  [cell setBackgroundColor:[UIColor clearColor]];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  BOOL isActive = NO;
  if (indexPath.row == self.currentPage) {
    isActive = YES;
  } else {
    [self scrollToPageAtIndex:indexPath.row/self.itemsPerPage animated:YES];
    [self setAutoScroll:self.autoScroll];
  }
  
  if ([self.delegate respondsToSelector:@selector(carousel:didSelectItemAtIndex:isActiveItem:)])
    [self.delegate carousel:self didSelectItemAtIndex:indexPath.row isActiveItem:isActive];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  scrollView.scrollEnabled = self.scrollEnabled;
  if (self.scrollEnabled) {
    [self stopAutoScrolling];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [self setAutoScroll:(self.autoScroll && !self.autoScrollDisablesOnInteraction)];
  if (decelerate)
    return; //If we are going to decelerate let the scrollViewWillBeginDeceletating: delegate handle the paging.
  if (self.scrollEnabled) {
    [self scrollToPageAtIndex:[self pageAtOffset:scrollView.contentOffset] animated:YES];
  }
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  if (self.scrollEnabled) {
    [self scrollToPageAtIndex:[self pageAtOffset:scrollView.contentOffset] animated:YES];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if (self.circularScrollEnabled) {
    CGFloat x;
    CGRect actualItemRect;
    if (self.currentPage == 0) {
      x  = ([self.dataSource numberOfItemsInCarousel:self])*self.pageSize.width;
      actualItemRect = CGRectMake(x, 0, self.pageSize.width, self.pageSize.height);
      self.currentPage = [self.dataSource numberOfItemsInCarousel:self];
      self.pageControl.currentPage = [self.dataSource numberOfItemsInCarousel:self];
      [scrollView scrollRectToVisible:actualItemRect animated:NO];
      [self updateView];
    } else if (self.currentPage == [self.dataSource numberOfItemsInCarousel:self] + 1) {
      x  = self.pageSize.width;
      actualItemRect = CGRectMake(x, 0, self.pageSize.width, self.pageSize.height);
      self.currentPage = 1;
      self.pageControl.currentPage = 1;
      [scrollView scrollRectToVisible:actualItemRect animated:NO];
      [self updateView];
    }
  }
}

- (void)setPageSize:(CGSize)pageSize {
  _pageSize = pageSize;
  
  [self updatePagingInformation];
}

- (void)setShowPageControl:(BOOL)pShowPageControl {
  _showPageControl = pShowPageControl;
  if (!pShowPageControl)
    [self.pageControl removeFromSuperview];
  else
    [self addSubview:self.pageControl];
}

- (void) setScrollEnabled:(BOOL)pScrollEnabled {
  _scrollEnabled = pScrollEnabled;
}

- (void) setScrollToPosition:(UICollectionViewScrollPosition)pScrollToPosition{
  _scrollToPosition = pScrollToPosition;
}

- (void)setCircularScrollEnabled:(BOOL)circularScrollEnabled {
  _circularScrollEnabled = circularScrollEnabled;
}

- (void)setAutoScroll:(BOOL)pAutoScroll {
  _autoScroll = pAutoScroll;
  if (_autoScroll)
    [self startAutoScrolling];
  else
    [self stopAutoScrolling];
}

- (void)startAutoScrolling {
  if (self.autoScrollTimer)
    [self stopAutoScrolling];
  self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval
                                                          target:self
                                                        selector:@selector(scrollToNextPage:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)stopAutoScrolling {
  [self.autoScrollTimer invalidate];
  self.autoScrollTimer = nil;
}

- (void)scrollToNextPage:(id)sender {
  // for autoscrolling, once we reach the end, we want to restart
  // but behavior is slightly different than the exposed scrollToNextPage
  if (self.currentPage < self.pageControl.numberOfPages - 1)
    [self scrollToNextPage];
  else
    [self scrollToFirstPage];
}

- (void)scrollToNextPage {
  if (self.currentPage < self.pageControl.numberOfPages - 1) {
    [self scrollToPageAtIndex:self.currentPage + 1 animated:YES];
  }
}

- (void)scrollToPreviousPage {
  if (self.currentPage > 0) {
    [self scrollToPageAtIndex:self.currentPage - 1 animated:YES];
  }
}

- (void)scrollToFirstPage {
  [self scrollToPageAtIndex:0 animated:YES];
}

- (void)scrollToLastPage {
  [self scrollToPageAtIndex:self.pageControl.numberOfPages - 1 animated:YES];
}

- (BOOL)isOnFirstPage {
  return self.currentPage == 0;
}

- (BOOL)isOnLastPage {
  NSInteger numPages = [self.dataSource numberOfItemsInCarousel:self] / self.itemsPerPage;
  if ([self.dataSource numberOfItemsInCarousel:self] % self.itemsPerPage > 0) {
    numPages++;
  }
  return self.currentPage == numPages - 1;
}

- (void)page:(id)sender {
  [self scrollToPageAtIndex:self.pageControl.currentPage animated:YES];
}

- (NSInteger)pageAtOffset:(CGPoint)pPoint {
  CGFloat insetPxsExposed = (self.edgeInsets.left + self.edgeInsets.right)*(self.currentPage);
  CGFloat page = ((pPoint.x + insetPxsExposed)/self.pageSize.width);
  if (fabs(page - self.currentPage) > 0.05) {
    if (page > self.currentPage && page < self.pageControl.numberOfPages && self.currentPage != self.pageControl.numberOfPages - 1) {
      return self.currentPage + 1;
    } else if (page > 0 && page < self.currentPage && self.currentPage != 0) {
      return self.currentPage - 1;
    }
  }
  return self.currentPage;
  
}

- (void)scrollToPageAtIndex:(NSInteger)pIndex animated:(BOOL)animated {
  if (pIndex < 0 || pIndex > self.pageControl.numberOfPages - 1)
    return;
  
  self.currentPage = pIndex;
  self.pageControl.currentPage = pIndex;
  
  if (self.currentPage*self.itemsPerPage < [self.collectionView numberOfItemsInSection:0] ) {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage*self.itemsPerPage inSection:0] atScrollPosition:self.scrollToPosition animated:animated];
  }
  
  if ([self.delegate respondsToSelector:@selector(carousel:didScrollToItemAtIndex:)]) {
    [self.delegate carousel:self didScrollToItemAtIndex:pIndex];
  }
  
  [self updateView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self updateView];
}

- (void)updateView {
  [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)updatePagingInformation {
  // cache information of the current page/items being displayed
  NSInteger oldItemsPerPage = self.itemsPerPage;
  NSInteger oldCurrentPage = self.currentPage;
  NSInteger oldFirstVisibleItemIndex = oldCurrentPage*oldItemsPerPage;
  
  // recalculate number of pages in the carousel and itemsPerPage based on current view bounds
  NSInteger  items = [self.dataSource numberOfItemsInCarousel:self];
  if (self.circularScrollEnabled && items > 0) {
    items += 2;
  }
  
  if (items > 0) {
    // number of items per page with 0 spacing between them
    NSInteger tempItemsPerPage = self.pageSize.width/self.itemSize.width;
    // size of page required to fit tempItemsPerPage
    CGFloat tempPageSize = (tempItemsPerPage*self.itemSize.width) + ((tempItemsPerPage - 1)*self.itemSpacing);
    
    while (tempPageSize > self.pageSize.width) {
      tempItemsPerPage--;
      tempPageSize = (tempItemsPerPage*self.itemSize.width) + ((tempItemsPerPage - 1)*self.itemSpacing);
    }
    self.itemsPerPage = tempItemsPerPage;
    self.pageControl.numberOfPages = (items/self.itemsPerPage);
    if (items % self.itemsPerPage > 0) {
      self.pageControl.numberOfPages++;
    }
  }
  
  // Adjust which page is being displayed based on cached information.
  // This is an attempt to show the same page in the scroll view despite orientation
  // changes and any other factors that would affect the bounds of the carousel
  // NOTE: Since we are using the index of the left-most visible cell in the carousel,
  // upon recalculation, we only approximately end up displaying the same page.
  // We essentially display the page, within the new settings, that contains the left-most
  // visible item we cached earlier. This is not the best solution, because after multiple bound
  // changes, it appears as though we are on a completely different page.
  // Given the current implementation of the carousel, this is the best that can be done.
  // Ideally, we would want to maintain the left-most item to remain in the left-most position
  // regardless of the how or how many times the bounds change!
  NSInteger newItemsPerPage = self.itemsPerPage;
  if (self.itemsPerPage > 0 && newItemsPerPage != oldItemsPerPage) {
    NSInteger shiftToPageIndex = oldFirstVisibleItemIndex/newItemsPerPage;
    self.currentPage = shiftToPageIndex;
    self.pageControl.currentPage = shiftToPageIndex;
  }
}

@end
