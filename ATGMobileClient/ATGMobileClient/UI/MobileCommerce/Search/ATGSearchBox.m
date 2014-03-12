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

#import "ATGSearchBox.h"
#import <EMMobileClient/EMAction.h>
#import <EMMobileClient/EMDimensionSearchValue.h>
#import <EMMobileClient/EMDimensionSearchGroup.h>
#import <EMMobileClient/EMDimensionSearchAutoSuggestItem.h>
#import <EMMobileClient/EMAncestor.h>
#import <EMMobileClient/EMSearchBox.h>
#import "ATGContentPathLookupManager.h"
#import "ATGJSONParser.h"
#import "ATGAssemblerConnectionManager.h"
#import "ATGConfigurationManager.h"

@interface ATGSearchBox() <EMConnectionManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UITableView *typeAheadTable;
@property (nonatomic, strong) NSString *previousTerm;
@property (nonatomic, strong) UIPopoverController *typeAheadPopover;
@property (nonatomic, strong) EMDimensionSearchAutoSuggestItem *dimensionAutoSuggest;
@end

@implementation ATGSearchBox

- (void)dealloc {
  [self.cancelButton removeFromSuperview];
  [self.typeAheadTable removeFromSuperview];
}

- (id)initWithFrame:(CGRect)pFrame searchBox:(EMSearchBox *)pSearchBox {
  self = [self initWithFrame:pFrame];
  if (self) {
    self.minAutoSuggestInputLength = [pSearchBox.minAutoSuggestInputLength integerValue];
    self.searchParam = pSearchBox.searchParam;
    self.baseAction = pSearchBox.baseAction;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      self.minAutoSuggestInputLength = [[ATGConfigurationManager sharedManager] minimumAutoSuggestInputLength];
      self.searchParam = [[ATGConfigurationManager sharedManager] searchParameter];
      self.baseAction = [[ATGConfigurationManager sharedManager] searchBaseAction];
      self.previousTerm = @"";
      
      self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
      
      UIImage *image = [UIImage imageNamed:@"searchbox"];
      UIImageView *searchBox = [[UIImageView alloc] initWithImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 31)]];
      searchBox.userInteractionEnabled = YES;
      searchBox.frame = CGRectMake(0, frame.origin.y, frame.size.width, 31);
      searchBox.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
      
      [self addSubview:searchBox];
      
      UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mag-glass"]];
      searchIcon.frame = CGRectMake(8, 6, 20, 20);
      [searchBox addSubview:searchIcon];
      
      self.textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 6, frame.size.width - 30, 21)];
      self.textField.delegate = self;
      self.textField.returnKeyType = UIReturnKeySearch;
      self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
      self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
      // don't enable 'return' key when no text has been entered
      self.textField.enablesReturnKeyAutomatically = YES;

      self.textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
      self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
      self.textField.placeholder = NSLocalizedStringWithDefaultValue(@"mobile.searchBox.cartridge.placholder", nil, [NSBundle mainBundle], @"Search", @"Search Box Placeholder text");
      [searchBox addSubview:self.textField];
                 
      self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
      self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
      self.cancelButton.backgroundColor = [UIColor blackColor];
      self.cancelButton.alpha = .3;
      [self.cancelButton addTarget:self.textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
      
      self.typeAheadTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
      self.typeAheadTable.dataSource = self;
      self.typeAheadTable.backgroundView = nil;
      self.typeAheadTable.delegate = self;
      self.typeAheadTable.layer.zPosition = 2;
      [self.typeAheadTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
      self.typeAheadTable.hidden = YES;

    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.previousTerm = textField.text;
  if ([self.delegate respondsToSelector:@selector(searchBoxWillBeginEditing:withCancelButton:typeaheadTable:)]) {
    [self.delegate searchBoxWillBeginEditing:self withCancelButton:self.cancelButton typeaheadTable:self.typeAheadTable];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if ((string.length == 0 && textField.text.length > self.minAutoSuggestInputLength) || (string.length > 0 && textField.text.length + string.length >= self.minAutoSuggestInputLength)) {
    NSMutableString *searchString = [NSMutableString stringWithString:textField.text];
    if (string.length > 0) {
      [searchString insertString:string atIndex:range.location];
    } else {
      [searchString replaceCharactersInRange:range withString:@""];
    }
    if ([string isEqualToString:@" "]) {
      return YES; // don't submit if the search string ends in a space
    }
    [[ATGAssemblerConnectionManager sharedManager] submitAction:[[ATGConfigurationManager sharedManager] autoSuggestActionForTerm:searchString baseAction:self.baseAction.siteRootPath] withDelegate:self];
  } else if (textField.text.length == 0 || (textField.text.length == 1 && string.length == 0)) {
    self.typeAheadTable.hidden = YES;
  } else {
    [self.typeAheadTable reloadData];
  }
  return YES;
}

- (void)connection:(EMAssemblerConnection *)pConnection didReceiveResponseObject:(id)pResponseObject {
  if (self.textField.text.length > 0) {
    EMContentItem *contentItem = [self parseResponseObject:pResponseObject];
    
    EMContentItem *ci = [[ATGContentPathLookupManager contentPathLookupManager] contentForPath:@"$.contents.autoSuggest" inRootContentItem:contentItem];
    
    self.dimensionAutoSuggest = (EMDimensionSearchAutoSuggestItem *)ci;
    [self.typeAheadTable reloadData];
    self.typeAheadTable.hidden = NO;
  }
}

- (EMContentItem *)parseResponseObject:(id)pResponseObject {
  if ([pResponseObject isKindOfClass:[NSData class]]) {
    NSError *error = nil;
    pResponseObject = [NSJSONSerialization JSONObjectWithData:pResponseObject options:NSJSONReadingAllowFragments error:&error];
  }
  EMContentItem *contentItem = [[[ATGJSONParser alloc] init] parseDictionary:(NSDictionary *)pResponseObject];
  return contentItem;
}

- (void)dismiss {
  //Should we clear also?
  self.textField.text = self.previousTerm;
  [self.textField resignFirstResponder];
}

- (void)clear {
  self.textField.text = @"";
  self.dimensionAutoSuggest = nil;
}

- (void) focus {
  [self.textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField  {
  if ([self.delegate respondsToSelector:@selector(searchBoxDidEndEditing:withCancelButton:typeaheadTable:)]) {
    [self.delegate searchBoxDidEndEditing:self withCancelButton:self.cancelButton typeaheadTable:self.typeAheadTable];
  }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  [self clear];
  [self.typeAheadTable reloadData];
  return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self search];
  return YES;
}

- (void)search {
  [self.textField resignFirstResponder];
  [self submitSearchTerm:self.textField.text];
  if (IS_IPAD) {
    self.textField.text = @"";
  }
}

- (NSString *)searchTerm {
  return self.textField.text;
}

- (void)setSearchTerm:(NSString *)pSearchTerm {
  self.textField.text = pSearchTerm;
}

- (void)submitSearchTerm:(NSString *)pTerm {
  NSString *state = [NSString stringWithFormat:@"?%@=%@&format=json", self.searchParam, pTerm];
  if ([self.delegate respondsToSelector:@selector(searchBox:didConstructSearchAction:)]) {
    [self.delegate searchBox:self didConstructSearchAction:[EMAction actionWithContentPath:self.baseAction.contentPath siteRootPath:self.baseAction.siteRootPath state:state]];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ((EMDimensionSearchGroup *)[self.dimensionAutoSuggest.dimensionSearchGroups objectAtIndex:section]).dimensionSearchValues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.dimensionAutoSuggest.dimensionSearchGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //The new dequeueReusableCellWithIdentifier:forIndexPath: crashes with VoiceOver enabled. :(
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
  }
  
  EMDimensionSearchGroup *searchGroup = (EMDimensionSearchGroup *)[self.dimensionAutoSuggest.dimensionSearchGroups objectAtIndex:indexPath.section];
  EMDimensionSearchValue *searchValue = (EMDimensionSearchValue *)[searchGroup.dimensionSearchValues objectAtIndex:indexPath.row];
  NSString *str = @"";
  for (EMAncestor *ancestor in searchValue.ancestors) {
    str = [NSString stringWithFormat:@"%@%@ > ", (str ? str : @"" ), ancestor.label];
  }
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str, searchValue.label]];
  
  NSError  *error  = NULL;
  
  NSRegularExpression *regex = [NSRegularExpression
                                regularExpressionWithPattern:[NSString stringWithFormat:@"\\b%@", [self.textField.text lowercaseString]]
                                options:0
                                error:&error];
  
  NSRange range   = [regex rangeOfFirstMatchInString:[[attrString string] lowercaseString]
                                             options:0
                                               range:NSMakeRange(0, [[[attrString string] lowercaseString] length])];
  
  UIColor *textColor = (UIColor *)[[ATGThemeManager themeManager] findResourceById:@"tertiaryColor"];
  [attrString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
  cell.textLabel.attributedText = attrString;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  EMDimensionSearchGroup *searchGroup = (EMDimensionSearchGroup *)[self.dimensionAutoSuggest.dimensionSearchGroups objectAtIndex:indexPath.section];
  EMDimensionSearchValue *searchValue = (EMDimensionSearchValue *)[searchGroup.dimensionSearchValues objectAtIndex:indexPath.row];
  
  NSString *foo = @"";
  for (EMAncestor *ancestor in searchValue.ancestors) {
    foo = [foo stringByAppendingFormat:@"%@>", ancestor.label];
  }
  foo = [foo stringByAppendingFormat:@" %@" ,searchValue.label];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.text = foo;
  label.font = [UIFont boldSystemFontOfSize:16];
  
  CGRect rect = [label textRectForBounds:CGRectMake(0, 0, 320, 1000) limitedToNumberOfLines:0];
  return MAX(rect.size.height + 15, 44);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self.textField resignFirstResponder];
  EMDimensionSearchGroup *searchGroup = (EMDimensionSearchGroup *)[self.dimensionAutoSuggest.dimensionSearchGroups objectAtIndex:indexPath.section];
  EMDimensionSearchValue *searchValue = (EMDimensionSearchValue *)[searchGroup.dimensionSearchValues objectAtIndex:indexPath.row];
  
  if ([self.delegate respondsToSelector:@selector(searchBox:didConstructSearchAction:)]) {
    [self.delegate searchBox:self didConstructSearchAction:searchValue];
  }
}

@end
