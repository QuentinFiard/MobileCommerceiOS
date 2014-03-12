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

#import "ATGMoreDetailsController.h"
#import <ATGMobileClient/ATGStoreManagerRequest.h>

#pragma mark - ATGMoreDetailsController private interface declaration
#pragma mark -

@interface ATGMoreDetailsController ()
{
  CGFloat offset;
  BOOL renderWebViews;
}
#pragma mark - Custom properties
@property (nonatomic, strong) NSMutableArray *render;

#pragma mark - IB Outlets
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

#pragma mark - ATGMoreDetailsController implementation
#pragma mark -

@implementation ATGMoreDetailsController

static NSString *const ATGTitleKey = @"title";
static NSString *const ATGContentKey = @"content";
#pragma mark - Synthesized Properties
@synthesize render;
@synthesize request, scrollView, renderWebViews, displayToolbar;

- (id) init {
  self = [super init];
  if (self) {
    render = [[NSMutableArray alloc] init];
    renderWebViews = NO;
    offset = 0;
    displayToolbar = YES;
  }
  return self;
}

- (void) dealloc {
  [request cancelRequest];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)pAnimated {
  [super viewWillAppear:pAnimated];
  // clear the page.
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  render = [[NSMutableArray alloc] init];
  offset = 0;
  [self reloadData];
  if (self.request) {
    [self startActivityIndication:NO];
  }
  else{
    [self stopActivityIndication];
  }
}

- (void) viewDidUnload {
  [request cancelRequest];
  request = nil;
  render = nil;

  [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return (pInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ATGStoreManager delegate callbacks
- (void) didGetShippingPolicy:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSDictionary *dict = (NSDictionary *)[pRequest shippingPolicy];
  [self renderContents:dict];
  request = nil;
}

- (void) didErrorGettingShippingPolicy:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  request = nil;
}

- (void) didGetPrivacyPolicy:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSDictionary *dict = (NSDictionary *)[pRequest privacyPolicy];
  [self renderContents:dict];
  request = nil;
}

- (void) didErrorGettingPrivacyPolicy:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  request = nil;
}

- (void) didGetAboutUs:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  NSDictionary *dict = (NSDictionary *)[pRequest aboutUs];
  [self renderContents:dict];
  request = nil;
}

- (void) didErrorGettingAboutUs:(ATGStoreManagerRequest *)pRequest {
  [self stopActivityIndication];
  [self alertWithTitleOrNil:nil withMessageOrNil:[pRequest.error localizedDescription]];
  request = nil;
}

#pragma mark - Private methods implementation
NSComparisonResult ( ^keysComparator)(id, id) =  ^(id obj1, id obj2) {
  NSString *str1 = (NSString *)obj1;
  NSString *str2 = (NSString *)obj2;

  if ([str1 isEqualToString:ATGTitleKey]) {
    return (NSComparisonResult)NSOrderedAscending;
  }
  if ([str2 isEqualToString:ATGTitleKey]) {
    return (NSComparisonResult)NSOrderedDescending;
  }

  if ([str1 hasPrefix:ATGContentKey] && [str2 hasPrefix:ATGContentKey]) {
    return [str1 compare:str2];
  }

  return (NSComparisonResult)NSOrderedAscending;
};

- (void) renderContents:(NSDictionary *)pContents {
  self.title = [pContents objectForKey:ATGTitleKey];
  [(UILabel *)[[self navigationItem] titleView] setText:[pContents objectForKey:ATGTitleKey]];
  NSArray *keys = [pContents allKeys];

  for (NSString *ckey in[keys sortedArrayUsingComparator : keysComparator]) {
    if ([ckey isEqualToString:ATGTitleKey]) {
      continue;
    }

    id section = (id)[pContents objectForKey : ckey];
    if ([section isKindOfClass:[NSDictionary class]]) {
      [self renderSection:section];
    }
  }
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
  UITextView *calculationView = [[UITextView alloc] init];
  [calculationView setAttributedText:text];
  CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
  return size.height;
}

// in iOS 7, contentSize is not calculated correctly, so this method can be used as a replacement
- (CGFloat) textViewHeightSwitch:(UITextView *)textView
{
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
  {
    return [self textViewHeightForAttributedText:textView.attributedText andWidth:textView.bounds.size.width];
  }
  else
  {
    return textView.contentSize.height;
  }
}

- (void) renderSection:(NSDictionary *)pSection {
  NSString *title, *text;
  CGRect frame;
  CGFloat headerOffset;

  UIView *sectionView = [[UIView alloc] init];
  sectionView.frame = CGRectMake(0, offset, 320, 0);
  [self.scrollView addSubview:sectionView];
  //keep reference
  [render addObject:sectionView];

  title = [pSection objectForKey:ATGTitleKey];

  if ([title length] == 0) {
    headerOffset = 0;
  } else {
    UILabel *headerLabel = [[UILabel alloc] init];
    [sectionView addSubview:headerLabel];
    //keep reference
    [render addObject:headerLabel];

    //unescape special symbols
    headerLabel.text = [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    [headerLabel applyStyleWithName:@"pageHeaderMoreLabel"];
    CGSize maxSize = CGSizeMake(320, 1000);
    CGSize actualSize = [[headerLabel text] sizeWithFont:[headerLabel font]
                                       constrainedToSize:maxSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = [sectionView bounds];
    frame.size.height = actualSize.height;
    frame.origin.x = 7;
    frame.origin.y = 7 + (offset == 0 ? 7 : 0);
    [headerLabel setFrame:frame];
    headerOffset = frame.size.height + frame.origin.y;
  }


  text = nil;

  NSArray *keys = [[pSection allKeys] sortedArrayUsingComparator:keysComparator];
  NSInteger left = [keys count];
  for (NSString *skey in keys) {
    left--;

    if ([skey isEqualToString:ATGTitleKey]) {
      continue;
    }

    id value = (id)[pSection objectForKey : skey];
    BOOL isSection = NO;
    if ([value isKindOfClass:[NSDictionary class]]) {
      NSDictionary *dict = (NSDictionary *)value;
      if ([dict objectForKey:ATGTitleKey]) {
        isSection = YES;
      }
    }

    if (!isSection) {
      text = [self concatContents:value withBuffer:text];
    }

    if (isSection || left == 0) {
      CGFloat textContent = 0;

      if (text) {
        if (self.renderWebViews) {
          UIWebView *textView = [[UIWebView alloc] initWithFrame:CGRectMake(0, headerOffset, 320, 1)];
          [sectionView addSubview:textView];
          //keep reference
          [render addObject:textView];
          [textView setDelegate:self];
          [textView loadHTMLString:text baseURL:nil];
          [textView setUserInteractionEnabled:NO];
          textContent = 1;
        } else {
          UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, headerOffset, 320, 0)];
          [sectionView addSubview:textView];
          //keep reference
          [render addObject:textView];

          textView.font = [UIFont moreDetailsFont];
          textView.text = text;
          textView.editable = NO;

          //textContent = textView.contentSize.height;
          // workaround contentSize being incorrectly caluculated in iOS 7
          textContent  =   [self textViewHeightSwitch:textView];
          frame = textView.frame;
          frame.size.height = textContent;
          textView.frame = frame;
        }
      }
      //increment general content offset
      offset += textContent + headerOffset;

      frame = sectionView.frame;
      frame.size.height += textContent + headerOffset;
      sectionView.frame = frame;
      self.scrollView.contentSize = CGSizeMake(320, offset);
      //reset offset to skip in next iterations
      headerOffset = 0;
    }

    if (isSection) {
      [self renderSection:value];
    }
  }
}

- (NSString *) concatContents:(id)pContents withBuffer:(NSString *)pBuffer {
  if ([pContents isKindOfClass:[NSString class]]) {
    if ([pBuffer length] > 0) {
      return [NSString stringWithFormat:@"%@\n%@", pBuffer, (NSString *)pContents];
    } else {
      return [NSString stringWithString:(NSString *)pContents];
    }
  }
  for (NSString *key in pContents) {
    pBuffer = [self concatContents:[(NSDictionary *) pContents objectForKey:key] withBuffer:pBuffer];
  }
  return pBuffer;
}

#pragma mark - UIWebView delegate callbacks
- (void) webViewDidFinishLoad:(UIWebView *)pWebView {
  NSString *eval = [pWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
  CGFloat height = [eval floatValue];

  CGRect frame = pWebView.frame;
  CGFloat diff = height - frame.size.height;
  frame.size.height = height;
  pWebView.frame = frame;


  NSArray *subviews = [self.scrollView subviews];
  BOOL shift = NO;
  for (UIView *view in subviews) {
    if (!shift) {
      if (view == [pWebView superview]) {
        shift = YES;
        frame = view.frame;
        frame.size.height += diff;
        view.frame = frame;
      }
    } else {
      frame = view.frame;
      frame.origin.y += diff;
      frame.size.height += diff;
      view.frame = frame;
    }
  }

  CGSize content = self.scrollView.contentSize;
  content.height += diff;
  self.scrollView.contentSize = content;
}

#pragma - UI Actions
- (void) didTouchBackButton {
  [[self navigationController] popViewControllerAnimated:YES];
}

@end