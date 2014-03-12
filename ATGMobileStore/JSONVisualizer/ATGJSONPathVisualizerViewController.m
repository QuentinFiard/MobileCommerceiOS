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



#import "ATGJSONPathVisualizerViewController.h"
#import <ATGMobileClient/ATGConfigurationManager.h>
#import "ATGJSONPathVisualizerAssemblerViewController.h"
#import "ATGJSONPathVisualizerJsonViewController.h"
#import <ATGMobileClient/ATGAssemblerConnectionURLBuilder.h>
#import <ATGMobileClient/ATGContentPathLookupManager.h>
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMContentItem.h>
#import <EMMobileClient/EMContentItemList.h>

@interface ATGJSONPathVisualizerViewController () <UITextFieldDelegate, ATGJSONPathVisualizerAssemblerViewControllerDelegate>

@property (nonatomic, strong) UITextField *pathTextField;
@property (nonatomic, strong) UITextField *hostTextField;
@property (nonatomic, strong) UITextField *portTextField;
@property (nonatomic, strong) UIButton *updateServerButton;

@property (nonatomic, strong) ATGJSONPathVisualizerAssemblerViewController *assemblerViewController;
@property (nonatomic, strong) ATGJSONPathVisualizerJsonViewController *jsonViewController;
@property (nonatomic, strong) EMContentItem *contentItem;

@end

static BOOL didRequestContentLoad;

@implementation ATGJSONPathVisualizerViewController

- (void)loadView {
  [super loadView];
  
  self.view.backgroundColor = [UIColor lightGrayColor];
  
  UIFont *textFieldFont = [UIFont fontWithName:@"Verdana" size:14.0f];
  
  self.hostTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.hostTextField.backgroundColor = [UIColor whiteColor];
  self.hostTextField.borderStyle = UITextBorderStyleRoundedRect;
  self.hostTextField.font = textFieldFont;
  self.hostTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  self.hostTextField.placeholder = @"Host";
  [self.view addSubview:self.hostTextField];
  
  self.portTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.portTextField.backgroundColor = [UIColor whiteColor];
  self.portTextField.borderStyle = UITextBorderStyleRoundedRect;
  self.portTextField.font = textFieldFont;
  self.portTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  self.portTextField.placeholder = @"Port";
  [self.view addSubview:self.portTextField];
  
  self.updateServerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.updateServerButton setTitle:@"Update Server" forState:UIControlStateNormal];
  [self.updateServerButton addTarget:self action:@selector(updateHostSettings:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.updateServerButton];
  
  self.pathTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.pathTextField.backgroundColor = [UIColor whiteColor];
  self.pathTextField.borderStyle = UITextBorderStyleRoundedRect;
  self.pathTextField.font = textFieldFont;
  self.pathTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  self.pathTextField.delegate = self;
  self.pathTextField.placeholder = @"JSON Path";
  [self.view addSubview:self.pathTextField];
  
  self.assemblerViewController = [[ATGJSONPathVisualizerAssemblerViewController alloc] init];
  self.assemblerViewController.delegate = self;
  self.assemblerViewController.view.frame = CGRectZero;
  [self.view addSubview:self.assemblerViewController.view];
  
  self.jsonViewController = [[ATGJSONPathVisualizerJsonViewController alloc] init];
  self.jsonViewController.view.frame = CGRectZero;
  [self.view addSubview:self.jsonViewController.view];
  
  self.hostTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.portTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.updateServerButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.pathTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.assemblerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  self.jsonViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  
  UITextField *host = self.hostTextField;
  UITextField *port = self.portTextField;
  UITextField *path = self.pathTextField;
  UIButton *updateBtn = self.updateServerButton;
  UIView *assemblerVCView = self.assemblerViewController.view;
  UIView *jsonVCView = self.jsonViewController.view;
  NSDictionary *views = NSDictionaryOfVariableBindings(host, port, path, updateBtn, assemblerVCView, jsonVCView);
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[path]-20-|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[host]-10-[port(==150)]-15-[updateBtn(==150)]-20-|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[assemblerVCView(==320)]-20-[jsonVCView]-20-|" options:0 metrics:nil views:views]];
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[host(==30)]-10-[path(==30)]-15-[assemblerVCView]-15-|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[host(==30)]-10-[path(==30)]-15-[jsonVCView]-15-|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[port(==30)]" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[updateBtn(==30)]" options:0 metrics:nil views:views]];
  
  didRequestContentLoad = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateHostSettings:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSMutableString *searchString = [NSMutableString stringWithString:textField.text];
  if (string.length > 0) {
    [searchString insertString:string atIndex:range.location];
  } else {
    [searchString replaceCharactersInRange:range withString:@""];
  }
  
  [self submitJSONPath:searchString];
  
  return YES;
}

- (void)didGetRootContentItem:(EMContentItem *)contentItem {
  self.contentItem = contentItem;
}

- (void)didLoadPageForContentItem:(EMContentItem *)contentItem {
  if (self.pathTextField && !didRequestContentLoad) {
    didRequestContentLoad = YES;
    [self submitJSONPath:self.pathTextField.text];
  }
}

- (void)didLoadPageForContents:(EMContentItemList *)contentItemList {
  if (self.pathTextField && self.pathTextField.text.length > 0 && !didRequestContentLoad) {
    didRequestContentLoad = YES;
    [self submitJSONPath:self.pathTextField.text];
  }
}

- (void)submitJSONPath:(NSString *)jsonPath {
  id contentForPath = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:jsonPath inRootContentItem:self.contentItem];
  
  [self.jsonViewController loadJSON:contentForPath];
  didRequestContentLoad = YES;
  if ([contentForPath isKindOfClass:[EMContentItem class]]) {
    [self.assemblerViewController loadPageForContentItem:contentForPath];
    
  } else if ([contentForPath isKindOfClass:[EMContentItemList class]]) {
    [self.assemblerViewController loadPageForContents:contentForPath];
    
  } else {
    NSArray *subviews = [self.assemblerViewController.view subviews];
    for (UIView *subview in subviews) {
      [subview removeFromSuperview];
    }
  }
  didRequestContentLoad = NO;
}

- (void)updateHostSettings:(id)sender {
  NSString *host = self.hostTextField.text;
  NSString *port = self.portTextField.text;
  
  if (host.length < 1 || port.length < 1) {
    host = @"busgt0606.us.oracle.com";
    port = @"7303";
    self.hostTextField.text = host;
    self.portTextField.text = port;
  }
  
  ATGAssemblerConnectionURLBuilder *urlBuilder = [[ATGAssemblerConnectionURLBuilder alloc] init];
  self.assemblerViewController.connectionManager.connection = [[EMAssemblerConnection alloc] initWithHost:host port:port.integerValue contextPath:@"crs" responseFormat:EMAssemblerResponseFormatJSON
                                                                                               urlBuilder:urlBuilder];
  [self.assemblerViewController loadPageForAction:[EMAction actionWithContentPath:@"mobile/browse" siteRootPath:@"" state:@"?format=json"]];
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationMaskLandscape;
}

@end
