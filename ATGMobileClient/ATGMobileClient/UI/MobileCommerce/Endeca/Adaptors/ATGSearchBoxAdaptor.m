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

#import "ATGSearchBoxAdaptor.h"
#import <EMMobileClient/EMSearchBox.h>
#import <EMMobileClient/EMConnectionManager.h>
#import <EMMobileClient/EMAction.h>
#import "ATGSearchRootViewController.h"
#import "ATGSearchBox.h"

#define KEYBOARD_HEIGHT 217
#define TAB_BAR_HEIGHT 50
#define STATUS_AND_NAVBAR_HEIGHT 64

@interface ATGSearchBoxAdaptor () <EMConnectionManagerDelegate, UITableViewDataSource, UITableViewDelegate, ATGSearchBoxDelegate>
@property (nonatomic, strong) EMSearchBox *contentItem;
@property (nonatomic, strong) UIBarButtonItem *filterBarButton;
@property (nonatomic, strong) UIBarButtonItem *cancelBarButton;
@property (nonatomic, strong) ATGSearchBox *searchBox;
@end

@implementation ATGSearchBoxAdaptor
@synthesize contentItem = _contentItem;

- (void)layoutContents {
  [super layoutContents];
  self.searchBox = [[ATGSearchBox alloc] initWithFrame:CGRectMake(0, 0, 320, 31) searchBox:self.contentItem];
  self.searchBox.delegate = self;
  
  self.controller.navigationItem.titleView = self.searchBox;
  self.filterBarButton = self.controller.navigationItem.rightBarButtonItem;
  self.cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"ATGSearchBoxAdaptor.SearchBox.CancelButton.Title", nil, [NSBundle mainBundle], @"Cancel", @"When Search Box is active this button is visible and when click cancels the search box input")
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self.searchBox
                                                         action:@selector(dismiss)];
  self.cancelBarButton.width = 65;
}

- (void)setSearchTerm:(NSString *)pTerm {
  [self.searchBox setSearchTerm:pTerm];
}

- (void)searchBoxWillBeginEditing:(ATGSearchBox *)pSearchBox withCancelButton:(UIButton *)pCancelButton typeaheadTable:(UITableView *)pTypeaheadTable {
  self.controller.navigationItem.rightBarButtonItem = self.cancelBarButton;
  pCancelButton.alpha = 0.0;
  pCancelButton.frame = CGRectMake(0, 64, self.controller.navigationController.view.frame.size.width, self.controller.navigationController.view.frame.size.height - STATUS_AND_NAVBAR_HEIGHT);
  pTypeaheadTable.frame = CGRectMake(0, STATUS_AND_NAVBAR_HEIGHT, 320, self.controller.navigationController.view.frame.size.height - KEYBOARD_HEIGHT + TAB_BAR_HEIGHT - STATUS_AND_NAVBAR_HEIGHT);
  [UIView animateWithDuration:0.43f animations:^(){
  [self.controller.navigationController.view addSubview:pCancelButton];
    pCancelButton.alpha = 0.7;
  }];
  [self.controller.navigationController.view addSubview:pTypeaheadTable];
}

- (void)searchBoxDidEndEditing:(ATGSearchBox *)pSearchBox withCancelButton:(UIButton *)pCancelButton typeaheadTable:(UITableView *)pTypeaheadTable {
  self.controller.navigationItem.rightBarButtonItem = self.filterBarButton;
  pCancelButton.alpha = 0.7;
  [UIView animateWithDuration:0.33f animations:^(){
    pCancelButton.alpha = 0.0;
  } completion:^(BOOL completion) {
    [pCancelButton removeFromSuperview];
  }
   ];
  pTypeaheadTable.hidden = YES;
  [pTypeaheadTable removeFromSuperview];
  self.controller.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 31);
}

- (void)searchBox:(ATGSearchBox *)pSearchBox didConstructSearchAction:(EMAction *)pSearchAction {
  if ([self.controller isKindOfClass:[ATGSearchRootViewController class]]) {
    [(ATGSearchRootViewController *)self.controller presentSearchViewControllerWithAction:pSearchAction];
    [pSearchBox clear];
  } else {
    [self.controller loadPageForAction:pSearchAction];
  }
}


@end
