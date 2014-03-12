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



#import "ATGJSONPathTokenizer.h"

@implementation ATGJSONPathTokenizer

- (NSArray *)tokenizeJSONPath:(NSString *)path {
  NSMutableArray *tokens = [[NSMutableArray alloc] init];
  
  NSInteger position = 0;
  NSString *currToken = nil;
  
  while (position < path.length) {    
    currToken = [path substringWithRange:NSMakeRange(position, MIN(1, path.length - position))];
    
    if (currToken == nil || [currToken isEqualToString:@" "]) {
      position++; // ignore extra spaces
      
    } else if ([@"$" isEqualToString:currToken]) {
      [tokens addObject:currToken];
      position++;
      
    } else if ([@"[" isEqualToString:currToken]) {
      NSInteger nextCloseBracket = [path rangeOfString:@"]" options:0 range:NSMakeRange(position, path.length - position)].location;
      NSInteger currentCloseBracket = path.length - 1;
      
      if (nextCloseBracket != NSNotFound) {
        NSInteger nextOpenBracket = position + 1;
        currentCloseBracket = nextCloseBracket;
        
        do {    // handle nested brackets, e.g. $[..node[*].something, ..somethingElse]
          nextOpenBracket = [path rangeOfString:@"[" options:0 range:NSMakeRange(nextOpenBracket, path.length - nextOpenBracket)].location;
          if (nextOpenBracket != NSNotFound && nextOpenBracket < nextCloseBracket) {
            currentCloseBracket =  nextCloseBracket;
            nextCloseBracket = [path rangeOfString:@"]" options:0 range:NSMakeRange(nextCloseBracket + 1, path.length - nextCloseBracket - 1)].location;
            if (nextCloseBracket == NSNotFound) {
              currentCloseBracket = path.length - 1;
              break;
            }
          } else if (nextOpenBracket != NSNotFound && nextOpenBracket > nextCloseBracket) {
            break;
          }
        } while (nextOpenBracket != NSNotFound);
        
        currToken = [path substringWithRange:NSMakeRange(position, currentCloseBracket - position + 1)];
      } else {
        currToken = [path substringWithRange:NSMakeRange(position, path.length - position)];
      }
      
      [tokens addObject:currToken];
      position += currentCloseBracket - position + 1;
      
    } else if ([@"." isEqualToString:currToken]) {
      NSString *nextChar = [path substringWithRange:NSMakeRange(position + 1, MIN(1, path.length - position - 1))];
      
      if (nextChar != nil && nextChar.length > 0 && [@"." isEqualToString:nextChar]) {
        [tokens addObject:@".."];
        position += 2;
      } else {
        position++;
      }
      
    } else {
      NSInteger dot = [path rangeOfString:@"." options:0 range:NSMakeRange(position, path.length - position)].location;
      
      // ignore this previously found dot if it is escaped or if it is preceeded by @
      do {
        if (dot != NSNotFound && [[path substringWithRange:NSMakeRange(dot - 1, 1)] isEqualToString:@"\\"]) {
          NSString *oldPath = path;
          path = [NSString stringWithFormat:@"%@%@", [oldPath substringToIndex:dot-1], [oldPath substringFromIndex:dot]];
          dot = [path rangeOfString:@"." options:0 range:NSMakeRange(dot + 1, path.length - dot - 1)].location;
        } else if (dot != NSNotFound && [[path substringWithRange:NSMakeRange(dot - 1, 1)] isEqualToString:@"@"]) {
          dot = [path rangeOfString:@"." options:0 range:NSMakeRange(dot + 1, path.length - dot - 1)].location;
        }
      } while (dot != NSNotFound && ([[path substringWithRange:NSMakeRange(dot - 1, 1)] isEqualToString:@"\\"] || [[path substringWithRange:NSMakeRange(dot - 1, 1)] isEqualToString:@"@"]));
      
      NSInteger bracket = [path rangeOfString:@"[" options:0 range:NSMakeRange(position, path.length - position)].location;
      NSInteger openQuotation = [path rangeOfString:@"'" options:0 range:NSMakeRange(position, path.length - position)].location;
      NSInteger closeQuotation = NSNotFound;
      
      if (openQuotation != NSNotFound) {
        closeQuotation = [path rangeOfString:@"'" options:0 range:NSMakeRange(openQuotation + 1, path.length - openQuotation - 1)].location;
      }
      
      if (dot == NSNotFound && bracket == NSNotFound && closeQuotation == NSNotFound) {
        currToken = [path substringWithRange:NSMakeRange(position, path.length - position)];
        position += path.length - position;
        
      } else if (closeQuotation != NSNotFound &&
                 (dot == NSNotFound || (openQuotation < dot && closeQuotation > dot))) {
        currToken = [path substringWithRange:NSMakeRange(position, closeQuotation - position + 1)];
        position += closeQuotation - position + 1;
        
      } else if ((dot != NSNotFound && bracket == NSNotFound) || (closeQuotation == NSNotFound && dot < bracket)) {
        currToken = [path substringWithRange:NSMakeRange(position, dot - position)];
        position += dot - position;
        
      } else {
        currToken = [path substringWithRange:NSMakeRange(position, bracket - position)];
        position += bracket - position;
      }
      
      [tokens addObject:currToken];
    }
  }
  return tokens;
}

- (NSArray *)splitExpression:(NSString *)expr usingDelimiter:(NSString *)delimiter {
  NSMutableArray *tokens = [[NSMutableArray alloc] init];
  NSInteger index = 0;
  NSInteger delimLocation = NSNotFound;
  
  while (index < expr.length) {
    while([[expr substringWithRange:NSMakeRange(index, MIN(1, expr.length - index))] isEqualToString:@" "]) {
      index++;    // ignore extra whitespace
    }
    
    delimLocation = [expr rangeOfString:delimiter options:0 range:NSMakeRange(index, expr.length - index)].location;
    
    if (delimLocation == NSNotFound) {
      [tokens addObject:[expr substringWithRange:NSMakeRange(index, expr.length - index)]];
      index += expr.length - index;
    } else {
      [tokens addObject:[expr substringWithRange:NSMakeRange(index, delimLocation - index)]];
      index += delimLocation - index + 1;
    }
  }
  
  return tokens;
}

@end
