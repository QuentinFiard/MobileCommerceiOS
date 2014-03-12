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

#import "ATGPrefixLabel.h"

#pragma mark - ATGPrefixLabel private interface declaration
#pragma mark -

@interface ATGPrefixLabel ()

@end

#pragma mark - ATGPrefixLabel implementation
#pragma mark -

@implementation ATGPrefixLabel
#pragma mark - Synthesized properties
@synthesize prefix;
@synthesize textStrikeThrough;

#pragma mark - Getter
- (UIColor *) prefixColor {
  if (self->_prefixColor) {
    return self->_prefixColor;
  }
  return [self textColor];
}

#pragma mark - UIView methods
- (void) drawRect:(CGRect)pRect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  // Always use all available space, this will separate prefix and main text
  // as far as it can.
  CGRect bounds = [self bounds];
  // Draw the main text with proper color.
  CGContextSetFillColorWithColor(context, [[self textColor] CGColor]);
  // Display the main text. Do not add line breaks, align the text by the right side.
  CGSize textSize = [[self text] sizeWithFont:[self font] constrainedToSize:bounds.size
                                lineBreakMode:NSLineBreakByTruncatingTail];
  CGRect textBounds =
    CGRectMake( 0, (MAX(textSize.height, bounds.size.height) - textSize.height) / 2,
                bounds.size.width, MIN(textSize.height, bounds.size.height) );
  textSize = [[self text] drawInRect:textBounds withFont:[self font]
                       lineBreakMode:NSLineBreakByTruncatingTail
                           alignment:NSTextAlignmentRight];
  // Draw the prefix with proper color.
  CGContextSetFillColorWithColor(context, [[self prefixColor] CGColor]);
  // Display the prefix. Do it with a single line, alight the text by the left side.
  CGSize prefixSize = [[self prefix] sizeWithFont:[self font] constrainedToSize:bounds.size
                                    lineBreakMode:NSLineBreakByTruncatingTail];
  CGRect prefixBounds =
    CGRectMake( 0, (MAX(prefixSize.height, bounds.size.height) - prefixSize.height) / 2,
                bounds.size.width, MIN(prefixSize.height, bounds.size.height) );
  [[self prefix] drawInRect:prefixBounds withFont:[self font]
              lineBreakMode:NSLineBreakByTruncatingTail
                  alignment:NSTextAlignmentLeft];
  // Do we want to add a strike-through decoration to main text?
  if ([self textStrikeThrough]) {
    // Use black color for this purpose.
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    // Draw a line itself.
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, bounds.size.width - textSize.width,
                         textBounds.origin.y + textBounds.size.height / 2);
    CGContextAddLineToPoint(context, bounds.size.width,
                            textBounds.origin.y + textBounds.size.height / 2);
    CGContextStrokePath(context);
  }
}

- (CGSize) sizeThatFits:(CGSize)pSize {
  // Return enough space to hold main text, prefix and a small delimiter.
  CGSize prefixSize = [[self prefix] sizeWithFont:[self font]];
  CGSize textSize = [[self text] sizeWithFont:[self font]];
  return CGSizeMake(prefixSize.width + textSize.width + 5, textSize.height);
}

#pragma mark - UIAccessibility

- (NSString *) accessibilityLabel {
  return [NSString stringWithFormat:@"%@ %@", [self prefix], [self text]];
}

@end