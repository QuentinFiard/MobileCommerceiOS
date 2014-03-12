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

#import "ATGMoreViewController_iPad.h"
#import <ATGMobileClient/ATGSite.h>
#import "ATGSitesListViewController.h"
#import "ATGMoreDetailsController.h"
#import <ATGMobileClient/ATGStoreManagerRequest.h>
#import <ATGMobileClient/ATGRestManager.h>
#import "ATGRootViewController_iPad.h"

#pragma mark - ATGStoreBadge declaration
#pragma mark -
@interface ATGStoresBadge : UILabel

@end

#pragma mark - ATGStoreBadge implementation
#pragma mark -
@implementation ATGStoresBadge

- (void) setBackgroundColor:(UIColor *)backgroundColor {
  // do not allow to change background color
  [super setBackgroundColor:[UIColor dirtyBlueColor]];
}

@end

#pragma mark - ATGMoreViewController_iPad private protocol declaration
#pragma mark -
@interface ATGMoreViewController_iPad ()

#pragma mark - IB properties
@property (nonatomic, readwrite, weak) IBOutlet UITableViewCell *sitesCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *storesCell;
@property (nonatomic, weak) IBOutlet UILabel *labelSite;
@property (nonatomic, weak) IBOutlet UILabel *labelSiteValue;
@property (nonatomic, weak) IBOutlet UILabel *labelPhone;
@property (nonatomic, weak) IBOutlet UILabel *labelPhoneValue;
@property (nonatomic, weak) IBOutlet UILabel *labelEmail;
@property (nonatomic, weak) IBOutlet UILabel *labelEmailValue;
@property (nonatomic, weak) IBOutlet UILabel *labelStores;
@property (nonatomic, weak) IBOutlet UILabel *labelShipping;
@property (nonatomic, weak) IBOutlet UILabel *labelPrivacy;
@property (nonatomic, weak) IBOutlet UILabel *labelFullSite;
@property (nonatomic, weak) IBOutlet UILabel *labelAbout;
@property (nonatomic, weak) IBOutlet UILabel *labelCopyright;

#pragma mark - Custom properties
@property (nonatomic, strong)  UILabel *badge;
@property (nonatomic)  NSInteger selection;
@property (nonatomic, strong) NSArray *sites;
@property (nonatomic, strong) ATGSite *currentSite;

#pragma mark - Private methods
- (void) dialPhone;
- (void) composeEmail;
- (void) browseFullSite;

@end

#pragma mark - ATGMoreViewController_iPad implementation
#pragma mark -
@implementation ATGMoreViewController_iPad
#pragma mark - Synthesized Properties
@synthesize selection, storesCell, badge, sites, currentSite, labelSite, labelEmail, labelPhone, labelStores,
  labelShipping, labelPrivacy, labelFullSite, labelAbout, labelCopyright, labelSiteValue, labelEmailValue,
  labelPhoneValue, sitesCell;

+ (NSString *)toolbarAccessibilityLabel {
  return NSLocalizedStringWithDefaultValue
  (@"ATGViewController.MoreAccessibilityLabel",
   nil, [NSBundle mainBundle],
   @"More",
   @"More toolbar button accessibility label");
}

#pragma mark - UIViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = NSLocalizedStringWithDefaultValue(@"ATGMoreViewController.PopoverTitle", nil,
                                                                [NSBundle mainBundle], @"More",
                                                                @"Title for the 'More' popover on iPad");
  
  self.badge = [[ATGStoresBadge alloc] initWithFrame:CGRectZero];
  self.badge.textColor = [UIColor whiteColor];
  self.badge.font = [UIFont boldSystemFontOfSize:15];
  self.badge.textAlignment = NSTextAlignmentCenter;
  self.badge.clipsToBounds = YES;
  self.badge.layer.cornerRadius = 10;
  self.badge.text = @"0";
  self.badge.frame = CGRectMake(254, 12, 35, 20);
  [self.storesCell.contentView addSubview:self.badge];

  labelSite.text = NSLocalizedStringWithDefaultValue(@"ATGMoreViewController.LabelSite", nil,
                                                     [NSBundle mainBundle], @"Site",
                                                     @"Label text for site selection on 'more' screen");
  labelPhone.text =  NSLocalizedStringWithDefaultValue
                      (@"ATGMoreViewController.ContactUsRowTitle", nil, [NSBundle mainBundle],
                      @"Contact Us", @"Title to be displayed on the 'Contact Us' row.");

  labelPhoneValue.text =  NSLocalizedStringWithDefaultValue
                           (@"ATGMoreViewController.PhoneButtonTitle", nil, [NSBundle mainBundle],
                           @"Phone", @"Title to be displayed on the 'Phone' button.");

  labelEmail.text =  NSLocalizedStringWithDefaultValue
                      (@"ATGMoreViewController.ContactUsRowTitle", nil, [NSBundle mainBundle],
                      @"Contact Us", @"Title to be displayed on the 'Contact Us' row.");

  labelEmailValue.text =  NSLocalizedStringWithDefaultValue
                           (@"ATGMoreViewController.EmailButtonTitle", nil, [NSBundle mainBundle],
                           @"Email", @"Title to be displayed on the 'Email' button.");

  labelStores.text = NSLocalizedStringWithDefaultValue(@"ATGMoreViewController.LabelStores", nil,
                                                       [NSBundle mainBundle], @"Store Locations",
                                                       @"Label text for store locations on 'more' screen");
  labelShipping.text = NSLocalizedStringWithDefaultValue
                         (@"ATGMoreViewController.ShippingReturnsRowTitle", nil, [NSBundle mainBundle],
                         @"Shipping + Returns", @"Title to be displayed on the 'Shipping+Returns' row.");

  labelPrivacy.text = NSLocalizedStringWithDefaultValue
                        (@"ATGMoreViewController.PrivacyTermsRowTitle", nil, [NSBundle mainBundle],
                        @"Privacy + Terms", @"Title to be displayed on the 'Privacy+Terms' row.");

  labelFullSite.text = NSLocalizedStringWithDefaultValue(@"ATGMoreViewController.LabelFullSite", nil,
                                                         [NSBundle mainBundle], @"Go to full site",
                                                         @"Label text for full site selection on 'more' screen");

  labelAbout.text = NSLocalizedStringWithDefaultValue
                      (@"ATGMoreViewController.AboutUsRowTitle", nil, [NSBundle mainBundle],
                      @"About Us", @"Title to be displayed on the 'About Us' row.");

  labelCopyright.text = NSLocalizedStringWithDefaultValue
                      (@"ATGMoreViewController.CopyrightFooter", nil, [NSBundle mainBundle],
                      @"Copyright (C) 1994-2013, Oracle and/or its affiliates. All rights reserved.", @"The copyright text.");

  [[ATGStoreManager storeManager] getStores:self];
  [[ATGStoreManager storeManager] getMobileSitesForDelegate:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)pSegue sender:(id)pSender {
  if ([pSegue.identifier isEqualToString:ATGSegueIdMoreToMoreDetails]) {
    ATGMoreDetailsController *ctrl = pSegue.destinationViewController;

    ATGStoreManager *sm = [ATGStoreManager storeManager];
    switch (self.selection) {
    case 4: {
      // Open Shipping/Returns screen.
      ctrl.request = [sm getShippingPolicy:ctrl];
      ctrl.renderWebViews = YES;
    }
    break;

    case 5: {
      // Open Privacy/Terms screen.
      ctrl.request = [sm getPrivacyPolicy:ctrl];
    }
    break;

    case 7: {
      // Open AboutUs screen.
      ctrl.request = [sm getAboutUs:ctrl];
    }
    break;
    }
  } else if (pSender == [self sitesCell]) {
    ATGSitesListViewController *dest = pSegue.destinationViewController;
    dest.delegate = self;
  }
}

#pragma mark - UIPopoverController

- (CGSize) contentSizeForViewInPopover {
  NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
  NSInteger tableHeight = numberOfRows * self.tableView.rowHeight;

  return CGSizeMake(320,  tableHeight + 100);
}

#pragma mark - UITableViewController

- (void) tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
  switch (pIndexPath.row) {
  case 0:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  [NSString stringWithFormat:@"%@, %@", self.labelSite.text, self.labelSiteValue.text];
    break;

  case 1:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  [NSString stringWithFormat:@"%@, %@", self.labelPhone.text, self.labelPhoneValue.text];
    break;

  case 2:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  [NSString stringWithFormat:@"%@, %@", self.labelEmail.text, self.labelEmailValue.text];
    break;

  case 3:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    if ([self.badge.text length] > 0) {
      pCell.accessibilityLabel =  [NSString stringWithFormat:@"%@, %@", self.labelStores.text, self.badge.text];
    } else {
      pCell.accessibilityLabel = self.labelStores.text;
    }
    break;

  case 4:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel = self.labelShipping.text;
    break;

  case 5:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  self.labelPrivacy.text;
    break;

  case 6:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  self.labelFullSite.text;
    break;

  case 7:
    pCell.isAccessibilityElement = YES;
    pCell.accessibilityTraits = UIAccessibilityTraitButton;
    pCell.accessibilityLabel =  self.labelAbout.text;
    break;
  }
}

- (void) tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  self.selection = pIndexPath.row;
  switch (self.selection) {
  case 1:
    [self dialPhone];
    break;

  case 2:
    [self composeEmail];
    break;

  case 6:
    [self browseFullSite];
    break;

  case 4:
  case 5:
  case 7:
    [self performSegueWithIdentifier:ATGSegueIdMoreToMoreDetails sender:self];
    break;
  }
}

#pragma mark - ATGStoreManagerDelegate

- (void) didGetStores:(ATGStoreManagerRequest *)pResults {
  self.badge.text = [NSString stringWithFormat:@"%d", [[pResults stores] count]];
  NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:0];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
  [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:path];
}

- (void) didGetMobileSites:(NSArray *)pSites {
  self.sites = pSites;
  //sender is nil to update UI only
  [self viewController:nil didSelectSiteWithId:[[[ATGStoreManager storeManager] restManager] currentSite]];
}

#pragma mark - Private methods

- (void) dialPhone {
  NSString *phone = [[[NSBundle mainBundle] infoDictionary]
                     objectForKey:ATG_CONTACT_US_PHONE_PROPERTY_NAME];
  NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
  if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
    [[UIApplication sharedApplication] openURL:phoneUrl];
  } else {
    NSString *title = NSLocalizedStringWithDefaultValue
                        (@"ATGMoreViewController.ContactUsRowTitle",
                        nil, [NSBundle mainBundle],
                        @"Contact Us",
                        @"Title of alert popup containing phone number on devices without phone.");
    [self alertWithTitleOrNil:title withMessageOrNil:phone];
  }
}

- (void) composeEmail {
  NSString *to = [[[NSBundle mainBundle] infoDictionary]
                  objectForKey:ATG_CONTACT_US_EMAIL_PROPERTY_NAME];
  NSString *subject = NSLocalizedStringWithDefaultValue
                        (@"ATGMoreViewController.EmailSubject", nil, [NSBundle mainBundle],
                        @"Contact Us",
                        @"Email subject to be used when the 'Contact with email button is touched.");
  // Always encode strings which go to URL parameters.
  subject = [subject stringByAddingPercentEscapes];
  NSURL *mailTo = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@",
                                        to, subject]];
  [[UIApplication sharedApplication] openURL:mailTo];
}

- (void) browseFullSite {
  if (currentSite) {
    [[UIApplication sharedApplication] openURL:currentSite.URL];
  }
}

#pragma mark - ATGSitesListViewControllerDelegate

- (void) viewController:(ATGSitesListViewController *)pController didSelectSiteWithId:(NSString *)pSiteId {
  if (self.sites) {
    for (ATGSite *site in self.sites) {
      if ([site.siteID isEqualToString:pSiteId]) {
        self.currentSite = site;
        labelSiteValue.text = site.name;
        break;
      }
    }
  }
  if (pController) {
    //sender is not nil - so it's a delegate callback. update REST with selected site id
    [[ATGStoreManager storeManager] restManager].currentSite = self.currentSite.siteID;
    [[ATGRootViewController_iPad rootViewController] reloadHomepage];
    [[ATGRootViewController_iPad rootViewController] reloadBrowse];
    [[self navigationController] popToViewController:self animated:YES];
    [[ATGRootViewController_iPad rootViewController] displayHomepage];
    [[ATGStoreManager storeManager] clearCache];
  }
}

- (void) viewController:(ATGSitesListViewController *)pController didDeselectSiteWithId:(NSString *)pSiteId {
  //what are we to do here?
}

@end