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

#import "ATGCheckoutShippingMethodViewController.h"
#import "ATGCheckoutCreditCardsController.h"
#import <ATGMobileClient/ATGCommerceManagerRequest.h>

static const CGFloat ATGPriceDelimiterWidth = 10;

#pragma mark - ATGCheckoutShippingMethodTableViewCell Private Protocol
#pragma mark -

@interface ATGCheckoutShippingMethodTableViewCell ()

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;

@end

#pragma mark - ATGCheckoutShippingMethodViewController Private Protocol
#pragma mark -

@interface ATGCheckoutShippingMethodViewController ()
    <ATGCheckoutDefaultsShippingMethodDelegate, ATGCommerceManagerDelegate>

#pragma mark - Custom Properties

@property (nonatomic, readwrite, strong) NSMutableArray *shippingPrices;
@property (nonatomic, readwrite, strong) NSNumberFormatter *priceFormatter;
@property (nonatomic, readwrite, strong) ATGCommerceManagerRequest *request;

@end

#pragma mark - ATGCheckoutShippingMethodViewController Implementation
#pragma mark -

@implementation ATGCheckoutShippingMethodViewController

#pragma mark - Synthesized Properties

@synthesize editMethod, currencyCode;
@synthesize shippingPrices;
@synthesize priceFormatter;
@synthesize request;

#pragma mark - Custom Properties Accessor Methods

#pragma mark - Properties Implementation

- (void)setCurrencyCode:(NSString *)pCurrencyCode {
  if (self->currencyCode != pCurrencyCode) {
    self->currencyCode = [pCurrencyCode copy];
    [[self priceFormatter] setCurrencyCode:[self currencyCode]];
  }
}

#pragma mark - NSObject

- (id)initWithCoder:(NSCoder *)pDecoder {
  self = [super initWithCoder:pDecoder];
  if (self) {
    [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
    [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self priceFormatter] setLocale:[NSLocale currentLocale]];
    // Handle 'method selected' messages.
    [self setDelegate:self];
  }
  return self;
}

- (void)dealloc {
  [[self request] cancelRequest];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *title = NSLocalizedStringWithDefaultValue
      (@"ATGCheckoutShippingMethodViewController.ScreenTitle", nil,
       [NSBundle mainBundle], @"Shipping Method", @"Title to be used on the screen.");
  [self setTitle:title];
}

- (void)viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  if ([self clearsSelectionOnViewWillAppear] && [self shippingPrices] != nil) {
    // This will hide checkmarks on all cells. No additional calls to commerce manager
    // will be made, the table will construct its contents on base of shippingMethods
    // property value, which should be set already.
    [[self tableView] reloadData];
  } else if ([self shippingPrices] == nil) {
    [[self request] cancelRequest];

    [self startActivityIndication:NO];
    [self setRequest:[[ATGCommerceManager commerceManager] getAvailableShippingMethods:@"true"
                                                                              delegate:self]];
  }
}

- (void)viewWillDisappear:(BOOL)pAnimated {
  [[self request] cancelRequest];
  [self setRequest:nil];
  [super viewWillDisappear:pAnimated];
}

- (CGSize)contentSizeForViewInPopover {
  CGFloat height = 0;
  for (NSInteger row = 0; row < [self tableView:[self tableView] numberOfRowsInSection:0]; row++) {
    height += [self tableView:[self tableView] heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row
                                                                                          inSection:0]];
  }
  return CGSizeMake(ATGPhoneScreenWidth, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)pTableView numberOfRowsInSection:(NSInteger)pSection {
  return [super tableView:pTableView numberOfRowsInSection:pSection] +
         [self errorNumberOfRowsInSection:pSection];
}

- (UITableViewCell *)tableView:(UITableView *)pTableView cellForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  UITableViewCell *errorCell = [self tableView:pTableView errorCellForRowAtIndexPath:pIndexPath];
  if (errorCell) {
    return errorCell;
  }
  //commented out as not used currently causing 'dead store' warning
  //pIndexPath = [self shiftIndexPath:pIndexPath];
  NSString *cellId = @"MethodCell";
  UITableViewCell *cell = [pTableView dequeueReusableCellWithIdentifier:cellId];
  if (!cell) {
    // Use custom table view cell instances, this will do proper layout.
    cell = [[ATGCheckoutShippingMethodTableViewCell alloc]
              initWithStyle:UITableViewCellStyleValue1
            reuseIdentifier:cellId currencyCode:[self currencyCode]];
    [[cell imageView] setImage:[UIImage imageNamed:@"icon-check.png"]];
    [cell setAccessibilityTraits:UIAccessibilityTraitStaticText | UIAccessibilityTraitButton];
  }
  [[cell imageView] setHidden:YES];
  return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)pTableView heightForRowAtIndexPath:(NSIndexPath *)pIndexPath {
  CGFloat height = [self tableView:pTableView errorHeightForRowAtIndexPath:pIndexPath];
  if (height > 0) {
    return height;
  } else {
    return [pTableView rowHeight];
  }
}

- (void)tableView:(UITableView *)pTableView willDisplayCell:(UITableViewCell *)pCell
forRowAtIndexPath:(NSIndexPath *)pIndexPath {
  if ([pIndexPath row] < [self errorNumberOfRowsInSection:[pIndexPath section]]) {
    [pCell setBackgroundColor:[UIColor errorColor]];
  }
  pIndexPath = [self shiftIndexPath:pIndexPath];
  if ([pIndexPath row] >= 0 && [pIndexPath row] < [self.shippingMethods count]) {
    // Allow superclass to set shipping method name.
    [super tableView:pTableView willDisplayCell:pCell forRowAtIndexPath:pIndexPath];
    [(ATGCheckoutShippingMethodTableViewCell *) pCell
     setPrice:[[self shippingPrices] objectAtIndex:[pIndexPath row]]];
  }
}

- (void)tableView:(UITableView *)pTableView didSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  NSIndexPath *shiftedPath = [self shiftIndexPath:pIndexPath];
  if ([shiftedPath row] >= 0 && [shiftedPath row] < [self.shippingMethods count]) {
    UITableViewCell *cell = [pTableView cellForRowAtIndexPath:pIndexPath];
    for (UITableViewCell *visibleCell in[pTableView visibleCells]) {
      [[visibleCell imageView] setHidden:YES];
    }
    [[cell imageView] setHidden:NO];
    // Allow superclass to send messages to its delegate.
    [super tableView:pTableView didSelectRowAtIndexPath:shiftedPath];
    [pTableView deselectRowAtIndexPath:pIndexPath animated:YES];
  }
}

#pragma mark - ATGCheckoutDefaultsShippingMethodViewController

- (void)setShippingMethods:(NSArray *)pShippingMethods {
  NSMutableArray *methodNames =
    [NSMutableArray arrayWithCapacity:[pShippingMethods count]];
  [self setShippingPrices:[[NSMutableArray alloc] initWithCapacity:[pShippingMethods count]]];
  for (NSDictionary *method in pShippingMethods) {
    NSString *name = [method objectForKey:@"name"];
    NSNumber *price = [method objectForKey:@"price"];
    [methodNames addObject:name];
    [[self shippingPrices] addObject:price];
  }
  [super setShippingMethods:methodNames];
}

#pragma mark - ATGCheckoutDefaultsShippingMethodDelegate

- (void)didSelectShippingMethod:(NSString *)pMethod {
  [[self request] cancelRequest];
  [self startActivityIndication:YES];

  [self setRequest:[[ATGCommerceManager commerceManager] updateShippingMethod:pMethod delegate:self]];
}

#pragma mark - ATGCommerceManagerDelegate

- (void)didGetAvailableShippingMethods:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self setShippingMethods:[[pRequest requestResults] objectForKey:@"shippingMethods"]];
  [self setCurrencyCode:[[pRequest requestResults] objectForKey:@"currencyCode"]];
  NSMutableArray *indexPathes = [[NSMutableArray alloc]
                                 initWithCapacity:[[self shippingPrices] count]];
  for (NSInteger i = 0; i < [[self shippingPrices] count]; i++) {
    [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }
  [[self tableView] insertRowsAtIndexPaths:indexPathes
                          withRowAnimation:UITableViewRowAnimationRight];
  [[self request] cancelRequest];
  [self setRequest:nil];
}

- (void)didErrorGettingAvailableShippingMethods:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [[self request] cancelRequest];
  [self setRequest:nil];
}

- (void) didUpdateShippingMethod:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  if ([self editMethod]) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self performSegueWithIdentifier:ATGSegueIdShippingMethodsToCreditCards sender:self];
  }
  [[self request] cancelRequest];
  [self setRequest:nil];
}

- (void) didErrorUpdatingShippingMethod:(ATGCommerceManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self tableView:[self tableView] setError:[pRequest error] inSection:0];
  [[self request] cancelRequest];
  [self setRequest:nil];
  if ([self isPad]) {
    [(ATGResizingNavigationController *)[self navigationController] resizePopoverAnimated:YES];
  }
}

@end

#pragma mark - ATGCheckoutShippingMethodTableViewCell Implementation
#pragma mark -

@implementation ATGCheckoutShippingMethodTableViewCell

#pragma mark - Synthesized Properties

@synthesize priceFormatter;

#pragma mark - Public Protocol Implementation

- (id)initWithStyle:(UITableViewCellStyle)pStyle
    reuseIdentifier:(NSString *)pReuseIdentifier currencyCode:(NSString *)pCurrencyCode {
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:pReuseIdentifier];
  if (self) {
    [self setPriceFormatter:[[NSNumberFormatter alloc] init]];
    [[self priceFormatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self priceFormatter] setLocale:[NSLocale currentLocale]];
    [[self priceFormatter] setCurrencyCode:pCurrencyCode];

    [[self detailTextLabel] applyStyleWithName:@"formFieldLabel"];
    [[self detailTextLabel] setFont:[[self textLabel] font]];
    [[self detailTextLabel] setTextAlignment:NSTextAlignmentLeft];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect detailFrame = [[self detailTextLabel] frame];
  CGRect textFrame = [[self textLabel] frame];
  detailFrame.origin.x = textFrame.origin.x + textFrame.size.width + ATGPriceDelimiterWidth;
  [[self detailTextLabel] setFrame:detailFrame];
}

- (void)setShippingMethod:(NSString *)pShippingMethod {
  [super setShippingMethod:pShippingMethod];
  [[self textLabel] setText:[[[self textLabel] text] stringByAppendingString:@":"]];
}

- (void)setPrice:(NSNumber *)pPrice {
  [[self detailTextLabel] setText:[[self priceFormatter] stringFromNumber:pPrice]];
}

@end