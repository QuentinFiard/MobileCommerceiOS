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

#import "ATGSitesListViewController.h"
#import <ATGMobileClient/ATGStoreManager.h>
#import <ATGMobileClient/ATGSite.h>
#import <ATGMobileClient/ATGResizingNavigationController.h>
#import <ATGMobileClient/ATGRestManager.h>
#import <ATGMobileClient/ATGAssemblerConnectionManager.h>

#pragma mark - ATGShareOptionsView Definition
#pragma mark -

// Private class which displays a share options to user.
@interface ATGShareOptionsView : UIView <UITableViewDataSource, UITableViewDelegate>
#pragma mark - IB Properties
@property (nonatomic, readwrite, weak) IBOutlet UILabel *subtitleLabel;
@end

#pragma mark - ATGSitesListViewController Private Protocol Definition
#pragma mark -

@interface ATGSitesListViewController () <ATGStoreManagerDelegate>

#pragma mark - IB Properties

@property (nonatomic, readwrite, weak) IBOutlet ATGShareOptionsView *shareMenu;

#pragma mark - Custom Properties

// Activity indicator which is displayed while downloading a list of available sites.
@property (nonatomic, readwrite, weak) UIActivityIndicatorView *spinner;
// List of available sites.
@property (nonatomic, readwrite, strong) NSArray *sites;
// Set of selected site IDs.
@property (nonatomic, readwrite, strong) NSMutableSet *selectedSites;

@end

#pragma mark - ATGSitesListViewController Implementation
#pragma mark -

@implementation ATGSitesListViewController

#pragma mark - Synthesized Properties

@synthesize delegate;
@synthesize spinner;
@synthesize sites;
@synthesize allowsMultipleSelection;
@synthesize shareMenu;
@synthesize selectedSites;

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = NSLocalizedStringWithDefaultValue(@"ATGSitesListViewController.Title", nil, [NSBundle mainBundle], @"Available Sites", @"Controller title, renders in the navigation bar on the site picker view controller");
  
  // Create a default activity indicator and set it to view's background.
  // We're going to present this indicator, while downloading sites list.
  UIActivityIndicatorView *activity =
  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  CGRect bounds = [[self view] bounds];
  CGPoint center = CGPointMake( CGRectGetMidX(bounds), CGRectGetMidY(bounds) );
  [activity setCenter:center];
  [activity setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
   UIViewAutoresizingFlexibleTopMargin |
   UIViewAutoresizingFlexibleRightMargin |
   UIViewAutoresizingFlexibleBottomMargin];
  [activity setHidesWhenStopped:YES];
  [[self tableView] setBackgroundView:activity];
  [[self tableView] setBackgroundColor:[UIColor tableBackgroundColor]];
  [self setSpinner:activity];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // Download the list of available sites.
  [[self spinner] startAnimating];
  [[ATGStoreManager storeManager] getMobileSitesForDelegate:self];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = [self.shareMenu sizeThatFits:CGSizeMake(320, 0)].height + 20;
  if ([self sites]) {
    height += [[self tableView] numberOfRowsInSection:0] * [[self tableView] rowHeight];
  } else {
    // No sites downloaded yet? Just display three rows.
    height += [[self tableView] rowHeight] * 3;
  }
  if ([[self tableView] style] == UITableViewStyleGrouped) {
    // Grouped table views require additional header/footer space.
    height += [[self tableView] sectionHeaderHeight] + [[self tableView] sectionFooterHeight];
  }
  return CGSizeMake(320, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [[self sites] count];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:@"ATGSiteCell"];
  ATGSite *site = (ATGSite *)[[self sites] objectAtIndex:[pIndexPath row]];
  [[cell textLabel] setText:[site name]];
  [[cell imageView] setHidden:![[self selectedSites] containsObject:[site siteID]]];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  
  NSString *siteID = [(ATGSite *)[[self sites] objectAtIndex:[pIndexPath row]] siteID];
  if ([self allowsMultipleSelection]) {
    // When multiple selection is allowed, modify the list of selected sites appropriately.
    if ([[self selectedSites] containsObject:siteID]) {
      [[self selectedSites] removeObject:siteID];
    } else {
      [[self selectedSites] addObject:siteID];
    }
  } else {
    // If multiple selection is not allowed, just replace the list of selected sites with a single object.
    [self setSelectedSites:[NSMutableSet setWithObject:siteID]];
  }
  
  // Now update outfit of all visible cells. All other cells will be updated automatically
  // with tableView:cellForRowAtIndexPath: method.
  for (NSIndexPath *indexPath in[[self tableView] indexPathsForVisibleRows]) {
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    ATGSite *site = (ATGSite *)[[self sites] objectAtIndex:[indexPath row]];
    [[cell imageView] setHidden:![[self selectedSites] containsObject:[site siteID]]];
  }

  if ([[self selectedSites] containsObject:siteID]) {
    EMConnectionManager *manager = [ATGAssemblerConnectionManager sharedManager];
    ATGSite *site = (ATGSite *)[self.sites objectAtIndex:pIndexPath.row];
    manager.connection = [EMAssemblerConnection connectionWithHost:manager.connection.host port:manager.connection.port contextPath:site.productionURL  responseFormat:manager.connection.responseFormat urlBuilder:manager.connection.urlBuilder];
    if ([[self delegate] respondsToSelector:@selector(viewController:didSelectSiteWithId:)]) {
      [[self delegate] viewController:self didSelectSiteWithId:siteID];
    }
  }
}

#pragma mark - ATGStoreManagerDelegate

- (void)didGetMobileSites:(NSArray *)pSites {
  [[self spinner] stopAnimating];
  [self setSites:pSites];
  // Select current site by default.
  [self setSelectedSites:[NSMutableSet
                          setWithObject:[[[ATGStoreManager storeManager] restManager] currentSite]]];
  // There is an empty table view section defined already, reload it.
  [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
  // Tell the parent navigation controller to change its sizes properly. This will make enough room
  // to display all available options.
  if (IS_IPAD)
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
}

- (void)didErrorGettingMobileSites:(NSError *)pError {
  [[self spinner] stopAnimating];
}

@end

#pragma mark - ATGShareOptionsView Implementation
#pragma mark -

@implementation ATGShareOptionsView

#pragma mark - Synthesized Properties

@synthesize subtitleLabel;

#pragma mark - NSObject

- (void)awakeFromNib {
  [super awakeFromNib];

  // Always use localized strings.
  NSString *title = NSLocalizedStringWithDefaultValue
  (@"ATGSitesListViewController.ScreenSubtitle",
   nil, [NSBundle mainBundle],
   @"Your login, cart and account info are shared between these sites",
   @"Subtitle to be displayed inside the popover with list of available sites.");
  [[self subtitleLabel] setText:title];
  
  // Layout view's subviews properly when loaded.
  // At the very bottom there should be displayed a title label.
  // Just above it there should be placed a delimiter image.
  // And at the top of them there should be located a share options table view.
  // Make enough room to display all the title's content.
  CGRect bounds = [self bounds];
  CGSize maxSize = CGSizeMake(bounds.size.width, 1000);
  CGSize labelSize = [[[self subtitleLabel] text] sizeWithFont:[[self subtitleLabel] font]
                                             constrainedToSize:maxSize
                                                 lineBreakMode:[[self subtitleLabel] lineBreakMode]];
  labelSize.height += 20;
  
  CGRect frame = [[self subtitleLabel] frame];
  frame.origin.y = bounds.size.height - labelSize.height;
  frame.size.height = labelSize.height;
  [[self subtitleLabel] setFrame:frame];
}

#pragma mark - UIView
- (CGSize)sizeThatFits:(CGSize)pSize {
  CGFloat height = [[self subtitleLabel] frame].size.height;
  return CGSizeMake(pSize.width, height);
}

@end