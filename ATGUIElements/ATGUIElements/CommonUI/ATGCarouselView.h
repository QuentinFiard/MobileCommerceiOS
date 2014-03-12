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

@class ATGCarouselView;
@protocol ATGCarouselDelegate <NSObject>
@optional
- (void)carousel:(ATGCarouselView *)pCarousel didSelectItemAtIndex:(NSInteger)pIndex isActiveItem:(BOOL)pActiveItem;
- (void)carousel:(ATGCarouselView *)pCarousel didScrollToItemAtIndex:(NSInteger)pIndex;
@end

@protocol ATGCarouselDataSource <NSObject>
- (UICollectionViewCell *)carousel:(ATGCarouselView *)pCarousel cellForItemAtIndex:(NSInteger)pIndex;
- (NSInteger)numberOfItemsInCarousel:(ATGCarouselView *)pCarousel;
@end

@interface ATGCarouselView : UIView

/* 
   - pPageSize and pItemSize may be the same, but not necessarily. In the case that the two vaues are different, pItemSize must be the smaller one between the two.
   - The edge inset is the padding between pFrame and the page itself, in the case that the frame is larger than the pPageSize. If edge insets are being set, it should be noted that pFrame does NOT need to take the insets into account by making the frame size smaller. This is handled by the carousel on its own.
   - On the other hand, if a margin is desired around the page, then pFrame should account for this by setting a non-zero value for the x and y starting positions of the rectangle, as well as adjesting its dimensions accordingly. 
 */
- (id)initWithFrame:(CGRect)pFrame layout:(UICollectionViewFlowLayout *)pLayout pageSize:(CGSize)pPageSize itemSize:(CGSize)pItemSize edgeInsets:(UIEdgeInsets)pInsets;

/* Basic scrolling method */
- (void)scrollToPageAtIndex:(NSInteger)pIndex animated:(BOOL)animated;

/* Convenience methods for paged scrolling */
- (void)scrollToNextPage;
- (void)scrollToPreviousPage;
- (void)scrollToFirstPage;
- (void)scrollToLastPage;

- (void)reloadData;

/* Convenience methods to check if carousel is on first or last page, if carousel is paging. */
- (BOOL)isOnFirstPage;
- (BOOL)isOnLastPage;

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)pIdentifier forIndex:(NSInteger)pIndex;
- (void)registerClass:(Class)pClass forCellWithReuseIdentifier:(NSString *)pIdentifier;

//Page Control
@property (nonatomic, strong) UIPageControl *pageControl;

//default is YES
@property (nonatomic, assign) BOOL showPageControl;

//AutoScroll
//Default is NO
@property (nonatomic, assign) BOOL autoScroll;
//When the user interacts with carousel stop autoscrolling
//Default is YES;
@property (nonatomic, assign) BOOL autoScrollDisablesOnInteraction;

//Scroll on user interaction
//Default is YES
@property (nonatomic, assign) BOOL scrollEnabled;

//Default is NO
// When this property is enabled, the renderer must set the initial object displayed to index 1 itself, as this is not handled by the carousel.
// It is recommended that the pageControl be not displayed when in circular scroll mode.
@property (nonatomic, assign) BOOL circularScrollEnabled;

//Default autoscroll interval is 5.0 seconds
@property (nonatomic, assign) CGFloat scrollInterval;

//Position to scroll the acitve item to (left/right/center/etc)
//Default is UICollectionViewScrollPositionCenteredHorizontally
@property (nonatomic, assign) UICollectionViewScrollPosition scrollToPosition;

//Size of the active (centered) item
@property (nonatomic, assign) CGSize itemSize;

//Size of the active (centered) page
@property (nonatomic, assign) CGSize pageSize;

//Page Inset
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) CGFloat itemSpacing;

//Click delegate
//Datasource
@property (nonatomic, weak) id<ATGCarouselDelegate> delegate;
@property (nonatomic, weak) id<ATGCarouselDataSource> dataSource;
@end
