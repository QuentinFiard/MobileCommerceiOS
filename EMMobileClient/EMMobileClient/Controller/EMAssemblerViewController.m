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

#import "EMAssemblerViewController.h"
#import "EMAdaptorManager.h"
#import "EMContentItemList.h"
#import "EMContentItem.h"
#import "EMContentPathLookupManager.h"
#import "EMJSONParser.h"
#import "EMBlockQueue.h"
#import "EMCollectionViewFlowLayoutPinnedSectionHeaders.h"

@interface EMAssemblerViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation EMAssemblerViewController
@synthesize collectionView = _collectionView, rootContentItem = _rootContentItem, action = _action, reloadContentPath = _reloadContentPath, adaptorManager = _adaptorManager;

- (id)init {
  if ((self = [super init])) {
    self.adaptorManager = [[EMAdaptorManager alloc] init];
    self.dataReadyBlockQueue = [[EMBlockQueue alloc] init];
    self.viewWillAppearBlockQueue = [[EMBlockQueue alloc] init];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.adaptorManager = [[EMAdaptorManager alloc] init];
  self.dataReadyBlockQueue = [[EMBlockQueue alloc] init];
  self.viewWillAppearBlockQueue = [[EMBlockQueue alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  EMBlockQueue *blockQueue = [self.viewWillAppearBlockQueue copy];
  for (void (^viewWillAppearBlock)(void) in blockQueue) {
    viewWillAppearBlock();
    [self.viewWillAppearBlockQueue removeBlock:viewWillAppearBlock];
  }
}

- (void)loadView {
  [super loadView];
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self collectionViewLayout]];
  self.collectionView.autoresizingMask = self.view.autoresizingMask;
  self.collectionView.delegate = self.adaptorManager;
  self.collectionView.dataSource = self.adaptorManager;
  self.collectionView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
  [self.collectionView addSubview:self.refreshControl];
  
  self.view = self.collectionView;
}

- (void)handleRefresh {
  if (self.action)
    [self reloadPageForAction:self.action];
  else
    [self.refreshControl endRefreshing];
}

- (void)loadPageForAction:(EMAction *)pAction {
  [self loadPageForAction:pAction withAttributes:self.adaptorManager.adaptorAttributes isReload:NO];
}

- (void)loadPageForAction:(EMAction *)pAction withAttributes:(NSDictionary *)pAttributes {
  [self loadPageForAction:pAction withAttributes:pAttributes isReload:NO];
}

- (void)loadPageForAction:(EMAction *)pAction withAttributes:(NSDictionary *)pAttributes isReload:(BOOL)pReload {
  if (!pReload) {
    self.reloadContentPath = nil;
  }
  self.adaptorManager.adaptorAttributes = pAttributes;
  self.action = pAction;
  [[self connectionManager] submitAction:pAction withDelegate:self];
}

- (void)loadPageForContents:(EMContentItemList *)pContentItemList {
  [self.adaptorManager constructAdaptorForContentItemList:pContentItemList withController:self];
  [self.collectionView reloadData];
  [self dataReady];
}

- (void)loadPageForContentItem:(EMContentItem *)pContentItem {
  [self.adaptorManager constructAdaptorForContentItem:pContentItem withController:self];
  [self.collectionView reloadData];
  [self dataReady];
}

- (void)reloadPageForAction:(EMAction *)pAction contentsAtPath:(NSString *)pContentPath {
  self.reloadContentPath = pContentPath;
  [self loadPageForAction:pAction withAttributes:self.adaptorManager.adaptorAttributes isReload:YES];
}

- (void)reloadPageForAction:(EMAction *)pAction contentsAtPath:(NSString *)pContentPath attributes:(NSDictionary *)pAttributes {
  self.reloadContentPath = pContentPath;
  [self loadPageForAction:pAction withAttributes:pAttributes isReload:YES];
}

- (void)reloadPageForAction:(EMAction *)pAction {
  if (self.reloadContentPath)
    [self loadPageForAction:pAction withAttributes:self.adaptorManager.adaptorAttributes isReload:YES];
  else
    [self loadPageForAction:pAction withAttributes:self.adaptorManager.adaptorAttributes isReload:NO];
}

- (void)reloadPageForAction:(EMAction *)pAction withAttributes:(NSDictionary *)pAttributes {
  if (self.reloadContentPath)
    [self loadPageForAction:pAction withAttributes:pAttributes isReload:YES];
  else
    [self loadPageForAction:pAction withAttributes:pAttributes isReload:NO];
}

- (void) dataReady {
  [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
  EMBlockQueue *tempBlockQueue = [self.dataReadyBlockQueue copy];
  for (void (^dataReadyBlock)(void) in tempBlockQueue) {
    dataReadyBlock();
    [self.dataReadyBlockQueue removeBlock:dataReadyBlock];
  }
}

- (void)connection:(EMAssemblerConnection *)pConnection didReceiveResponseObject:(id)pResponseObject {
  [self.refreshControl endRefreshing];
  [self loadPageForParsedContentItem:[self parseResponseObject:pResponseObject]];
}

- (void)connection:(EMAssemblerConnection *)pConnection didFailWithError:(NSError *)pError {
  [self.refreshControl endRefreshing];
  NSLog(@"%@", pError.description);
}

- (EMContentItem *)parseResponseObject:(id)pResponseObject {
  EMContentItem *contentItem = [[[EMJSONParser alloc] init] parseDictionary:(NSDictionary *)pResponseObject];
  return contentItem;
}

- (UICollectionViewLayout *)collectionViewLayout {
  return [[EMCollectionViewFlowLayoutPinnedSectionHeaders alloc] init];
}

- (void)loadPageForParsedContentItem:(EMContentItem *)pContentItem {
  self.rootContentItem = pContentItem;
  
  if (self.reloadContentPath) {
    id obj = [[self contentPathLookupManager] contentForPath:self.reloadContentPath inRootContentItem:pContentItem];
    if ([obj isKindOfClass:[EMContentItem class]]) {
      [self loadPageForContentItem:(EMContentItem *)obj];
    } else if ([obj isKindOfClass:[EMContentItemList class]]) {
      [self loadPageForContents:(EMContentItemList *)obj];
    }
  } else {
    [self loadPageForContentItem:pContentItem];
  }
}

-(EMConnectionManager*) connectionManager {
  return [EMConnectionManager sharedManager];
}

- (EMContentPathLookupManager *) contentPathLookupManager {
  return [EMContentPathLookupManager contentPathLookupManager];
}

#pragma mark -
#pragma EMConnectionManagerDelegate

- (void)connection:(EMAssemblerConnection *)pConnection willSubmitAction:(EMAction *)pAction {
}

- (void)connection:(EMAssemblerConnection *)pConnection didSubmitAction:(EMAction *)pAction {
  
}

@end
