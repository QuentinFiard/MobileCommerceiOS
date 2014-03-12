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

#import "ATGJSONPathManager.h"

@interface ATGJSONPathManager()
- (NSInteger)unclosedSquareBracketCount:(NSString *)sourceString;
@end

@implementation ATGJSONPathManager

- (id)getContentForPath:(NSString *)path fromContent:(id)contentJSON {
  id retVal = contentJSON;
  NSArray *tokens = [[self getTokenizer] tokenizeJSONPath:path];
  NSUInteger index = 0;
  NSString *currToken = nil;
  ATGJSONPathParser *parser = [self getParser];
  
  for (index = 0; index < tokens.count; index++) {
    currToken = [tokens objectAtIndex:index];
    
    if ([currToken isEqualToString:@"$"]) {
      retVal = [parser getContentFromRoot:retVal];
      
    } else if ([@".." isEqualToString:currToken]) {
      NSString *nextToken = nil;
      if (index + 1 < tokens.count) {
        nextToken = tokens[index + 1];
      }
      
      NSString *filterToken = nil;
      if (nextToken != nil && index + 2 < tokens.count) {
        filterToken = tokens[index + 2];
        if ([@"[" isEqualToString:[filterToken substringToIndex:1]]) {
          if ([self unclosedSquareBracketCount:filterToken] > 0) {
            return nil;
          } else {
            filterToken = [filterToken substringWithRange:NSMakeRange(1, filterToken.length - 2)];
            index++;
          }
        } else {
          filterToken = nil;
        }
      } else if (nextToken != nil && [[nextToken substringToIndex:1] isEqualToString:@"["]) {
        if ([self unclosedSquareBracketCount:nextToken] > 0) {
          return nil;
        } else {
          filterToken = [nextToken substringWithRange:NSMakeRange(1, nextToken.length - 2)];
          nextToken = nil;
        }
      } else {
        //return nil; //THIS IS GOING TO BREAK THE JSONVISUALIZER. THE RECURSIVE DECENT DOES NOT WORK IN STREAMING FASHION. //TODO: Figure this out
      }
      
      retVal = [parser getDescendantsRecursively:retVal withNodename:nextToken forNodeFilter:filterToken pathManager:self];
      index++;
      
    } else if ([@"[" isEqualToString:[currToken substringToIndex:1]]) {
      NSRange closeBracket = [currToken rangeOfString:@"]"];
      if (closeBracket.location == NSNotFound || [self unclosedSquareBracketCount:currToken] > 0) {
        return  nil;
      }
      
      NSInteger nextCloseBracket;
      do { // find the location of the last close bracket
        nextCloseBracket = [currToken rangeOfString:@"]" options:0 range:NSMakeRange(closeBracket.location + 1, currToken.length - closeBracket.location - 1)].location;
        if (nextCloseBracket != NSNotFound) {
          closeBracket.location = nextCloseBracket;
        }
      } while (nextCloseBracket != NSNotFound);
      
      currToken = [currToken substringWithRange:NSMakeRange(1, closeBracket.location - 1)];
      retVal = [parser getContentFromCurrent:retVal forNodeFilter:currToken pathManager:self];
      
    } else if ([@"?" isEqualToString:[currToken substringToIndex:1]]) {
      retVal = [parser getContentFromCurrent:retVal forNodeFilter:currToken pathManager:self];
    } else {   // node name
      retVal = [parser getChild:retVal withNodename:currToken];
    }
  }
  return retVal;
}

- (ATGJSONPathTokenizer *)getTokenizer {
  if (self.jsonPathTokenizer == nil) {
    self.jsonPathTokenizer = [[ATGJSONPathTokenizer alloc]init];
  }
  return self.jsonPathTokenizer;
}

- (ATGJSONPathParser *)getParser {
  if (self.jsonPathParser == nil) {
    self.jsonPathParser = [[ATGJSONPathParser alloc]init];
  }
  return self.jsonPathParser;
}

- (NSInteger)unclosedSquareBracketCount:(NSString *)sourceString {
  NSInteger unclosedBrackets = 0;  
  NSInteger nextOpenBracket = 0;
  NSInteger nextCloseBracket = 0;
  
  do {
    nextOpenBracket = [sourceString rangeOfString:@"[" options:0 range:NSMakeRange(nextOpenBracket, sourceString.length - nextOpenBracket)].location;
    if (nextCloseBracket < sourceString.length) {
      nextCloseBracket = [sourceString rangeOfString:@"]" options:0 range:NSMakeRange(nextCloseBracket, sourceString.length - nextCloseBracket)].location;
    } else {
      nextCloseBracket = NSNotFound;
    }
    if (nextOpenBracket != NSNotFound && nextCloseBracket == NSNotFound) {
      unclosedBrackets++;
    }
    nextOpenBracket++;
    nextCloseBracket++;
  } while (nextOpenBracket < sourceString.length);
  
  return unclosedBrackets;
}

@end
