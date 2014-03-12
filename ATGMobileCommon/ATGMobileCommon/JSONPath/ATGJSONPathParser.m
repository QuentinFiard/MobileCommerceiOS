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

#import "ATGJSONPathParser.h"
#import "ATGDefaultJSONPathRegex.h"

@implementation ATGJSONPathParser

- (id)getContentFromRoot:(id)contentJSON {
  return contentJSON;
}

- (id)getDescendantsRecursively:(id)contentJSON withNodename:(NSString *)nodename forNodeFilter:(NSString *)nodeFilter pathManager:(ATGJSONPathManager *)manager {
  if (contentJSON == nil) {
    return nil;
  }
  
  JSONObjectClassType ct = [ATGJSONPathParser getKindOfClass:contentJSON];
  NSMutableArray *retVal = [[NSMutableArray alloc] initWithCapacity:0];
  
  switch(ct) {
    case DICTIONARY:
    {
      NSDictionary *d = (NSDictionary *) contentJSON;
      NSArray *keys = [d allKeys];
      NSString *currKey = nil;
      id currNode = 0;
      id result = 0;
      
      for (NSUInteger index = 0; index < keys.count; index++) {
        currKey = [keys objectAtIndex:index];
        currNode = [d objectForKey:currKey];
        
        if ([ATGJSONPathParser getKindOfClass:currNode] == OTHER) {
          currNode = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:currNode]];
        }
        
        if (nodename == nil || [@"*" isEqualToString:nodename] || [currKey isEqualToString:nodename]) {
          if (nodeFilter != nil) {
            result = [self getContentFromCurrent:currNode forNodeFilter:nodeFilter pathManager:manager];
            if (result != nil) {
              if ([ATGJSONPathParser getKindOfClass:result] == ARRAY) {
                [retVal addObjectsFromArray:result];
              } else {
                [retVal addObject:result];
              }
            }
          } else {
            if ([ATGJSONPathParser getKindOfClass:currNode] == ARRAY) {
              [retVal addObjectsFromArray:currNode];
            } else {
              [retVal addObject:currNode];
            }
          }
        }
        [retVal addObjectsFromArray:[self getDescendantsRecursively:currNode withNodename:nodename forNodeFilter:nodeFilter pathManager:manager]];
      }
      break;
    }
    case ARRAY:
    {
      NSArray *a = (NSArray *) contentJSON;
      for (NSUInteger index = 0; index < a.count; index++) {
        [retVal addObjectsFromArray:
         [self getDescendantsRecursively:[a objectAtIndex:index] withNodename:nodename forNodeFilter:nodeFilter pathManager:manager]];
      }
      break;
    }
    case OTHER:
    {
      contentJSON = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:contentJSON]];
      return [self getDescendantsRecursively:contentJSON withNodename:nodename forNodeFilter:nodeFilter pathManager:manager];
    }
    case STRING:
    case NUMBER:
    default:
      break;
  }
  return retVal;
}

- (id)getChild:(id)contentJSON withNodename:(NSString *)nodename {
  if (contentJSON == nil) {
    return nil;
  }
  
  JSONObjectClassType type = [ATGJSONPathParser getKindOfClass:contentJSON];
  BOOL getAll = [nodename isEqualToString:@"*"];
  NSMutableArray *retVal = [[NSMutableArray alloc] init];
  
  switch (type) {
    case DICTIONARY:
    {
      NSDictionary *d = (NSDictionary *) contentJSON;
      NSArray *keys = [d allKeys];
      
      id children = 0;
      id currNode = 0;
      NSInteger index = 0;
      
      for (index = 0; index < keys.count; index++) {
        currNode = [keys objectAtIndex:index];
        children = [d objectForKey:currNode];
        
        if (children != nil && (getAll == YES || [nodename isEqualToString:(NSString *)currNode])) {
          if ([ATGJSONPathParser getKindOfClass:children] == ARRAY) {
            [retVal addObjectsFromArray:children];
          } else {
            [retVal addObject:children];
          }
        }
      }
      break;
    }
    case ARRAY:
    {
      NSArray *a = (NSArray *) contentJSON;
      
      for (NSUInteger index = 0; index < a.count; index++) {
        id obj = [a objectAtIndex:index];
        JSONObjectClassType typeObj = [ATGJSONPathParser getKindOfClass:obj];
        if (typeObj == OTHER) {
          obj = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:(obj)]];
        }
        typeObj = [ATGJSONPathParser getKindOfClass:obj];
        if (typeObj == DICTIONARY || typeObj == ARRAY) {
          [retVal addObjectsFromArray:(NSArray *)[self getChild:obj withNodename:nodename]];
        }
      }
      break;
    }
    case OTHER:
    {
      contentJSON = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:contentJSON]];
      return [self getChild:contentJSON withNodename:nodename];
    }
    default:
      break;
  }
  return retVal;
}

- (id)getContentFromCurrent:(id)contentJSON atIndex:(NSInteger)index {
  
  if (contentJSON == nil) {
    return nil;
  }
  
  JSONObjectClassType typecj = [ATGJSONPathParser getKindOfClass:contentJSON];
  
  switch (typecj) {
    case DICTIONARY:
    {
      NSDictionary *d = (NSDictionary *)contentJSON;
      NSArray *keys = [d allKeys];
      if (index >= 0 && index < keys.count) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:[d objectForKey:[keys objectAtIndex:index]] forKey:[keys objectAtIndex:index]];
        return dictionary;
      }
      break;
    }
    case ARRAY:
    {
      NSArray *obj = (NSArray *)contentJSON;
      if (index >= 0 && index < obj.count) {
        return [obj objectAtIndex:index];
      }
      break;
    }
    case OTHER:
    {
      contentJSON = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:contentJSON]];
      return [self getContentFromCurrent:contentJSON atIndex:index];
    }
    default:
      break;
  }
  return 0;
}

- (id)getContentFromCurrent:(id)contentJSON forNodeFilter:(NSString *)nodeFilter pathManager:(ATGJSONPathManager *)manager {
  
  if (contentJSON == nil) {
    return nil;
  }
  
  if([ATGJSONPathParser getKindOfClass:contentJSON] == OTHER) {
    contentJSON = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:contentJSON]];
  }
  
  id retVal = 0;
  
  NSPredicate *regexNumber = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForNumber]];
  NSPredicate *regexScript = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForScript]];
  NSPredicate *regexFilterExpr = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForFilterExpression]];
  NSPredicate *regexUnion = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForUnion]];
  NSPredicate *regexSlice = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForSlice]];
  
  if ([regexNumber evaluateWithObject:nodeFilter] == YES) {
    retVal = [self getContentFromCurrent:contentJSON atIndex:[nodeFilter integerValue]];
    
  } else if ([regexScript evaluateWithObject:nodeFilter] == YES) {
    retVal = [self getContentFromCurrent:contentJSON forScriptFilter:nodeFilter];
    
  } else if ([regexUnion evaluateWithObject:nodeFilter] == YES) {
    retVal = [self getContentFromCurrent:contentJSON withUnionOf:nodeFilter pathManager:manager];
    
  } else if ([regexFilterExpr evaluateWithObject:nodeFilter] == YES) {
    retVal = [self getContentFromCurrent:contentJSON forExpressionFilter:nodeFilter pathManager:manager];
    
  } else if ([regexSlice evaluateWithObject:nodeFilter] == YES) {
    retVal = [self getContentFromCurrent:contentJSON forSliceFilter:nodeFilter pathManager:manager];
    
  } else if ([@"*" isEqualToString:nodeFilter]) {
    retVal = contentJSON;
    
  } else {
    retVal = [manager getContentForPath:nodeFilter fromContent:contentJSON];
  }
  
  return retVal;
}

- (id)getContentFromCurrent:(id)contentJSON forScriptFilter:(NSString *)script {
  if (contentJSON == nil) {
    return nil;
  }
  
  NSMutableArray *retVal = [[NSMutableArray alloc] init];
  NSInteger atDot = [script rangeOfString:@"@."].location;
  
  if (atDot != NSNotFound && atDot < script.length - 1) {
    script = [script substringWithRange:NSMakeRange(atDot + 2, script.length - atDot - 3)];
    NSInteger count = [script rangeOfString:@"count"].location;
    NSInteger lastObject = [script rangeOfString:@"lastObject"].location;
    JSONObjectClassType type = [ATGJSONPathParser getKindOfClass:contentJSON];
    
    NSInteger offset = NSNotFound;
    if (count != NSNotFound) {
      offset = [[script substringWithRange:NSMakeRange(count + 5, script.length - count - 5)] integerValue];
    } else if (lastObject != NSNotFound) {
      offset = -1;
    }
    if (offset != NSNotFound) {
      if (type == ARRAY) {
        retVal = [self getContentFromCurrent:contentJSON atIndex:[(NSArray *) contentJSON count] + offset];
      } else if (type == DICTIONARY) {
        retVal = [self getContentFromCurrent:contentJSON atIndex:[(NSDictionary *) contentJSON count] + offset];
      }
    }
  }
  return retVal;
}

- (id)getContentFromCurrent:(id)contentJSON forExpressionFilter:(NSString *)expression pathManager:(ATGJSONPathManager *)manager {
  if (contentJSON == nil) {
    return nil;
  }
  
  NSMutableArray *retVal = [[NSMutableArray alloc] init];
  NSInteger atdot = [expression rangeOfString:@"@."].location;
  
  if (atdot != NSNotFound && atdot < expression.length - 1) {
    JSONObjectClassType type = [ATGJSONPathParser getKindOfClass:contentJSON];
    
    expression = [expression substringWithRange:NSMakeRange(atdot + 2, expression.length - atdot - 3)];
    NSArray *tokens = [[manager getTokenizer] tokenizeJSONPath:expression];
    
    switch (type) {
      case DICTIONARY:
      {
        NSDictionary *d = (NSDictionary *) contentJSON;
        NSArray *keys = [contentJSON allKeys];
        for (NSString *str in keys) {
          id vals = [d objectForKey:str];
          if(vals != nil && [self pathExists:tokens inContent:vals]) {
            [retVal addObject:vals];
          }
        }
        break;
      }
      case ARRAY:
      {
        NSArray *a = (NSArray *)contentJSON;
        for (NSInteger index = 0; index < a.count; index++) {
          id obj = [a objectAtIndex:index];
          if (obj != nil && [self pathExists:tokens inContent:obj]) {
            [retVal addObject:obj];
          }
        }
        break;
      }
      default:
        break;
    }
  }
  return retVal;
}

- (id)getContentFromCurrent:(id)contentJSON withUnionOf:(NSString *)unionExpression pathManager:(ATGJSONPathManager *)manager {
  if (contentJSON == nil) {
    return nil;
  }
  
  NSMutableArray *retVal = [[NSMutableArray alloc] init];
  NSArray *tokens = [[manager getTokenizer] splitExpression:unionExpression usingDelimiter:@","];
  
  for (NSInteger index = 0; index < tokens.count; index++) {
    NSString *token = [tokens objectAtIndex:index];
    id result = [self getContentFromCurrent:contentJSON forNodeFilter:token pathManager:manager];
    JSONObjectClassType resType = [ATGJSONPathParser getKindOfClass:result];
    
    if (result != nil) {
      if (resType == ARRAY) {
        [retVal addObjectsFromArray:(NSArray *)result];
      } else {
        [retVal addObject:result];
      }
    }
  }
  return retVal;
}

- (id)getContentFromCurrent:(id)contentJSON forSliceFilter:(NSString *)sliceExpr pathManager:(ATGJSONPathManager *)manager {
  if (contentJSON == nil) {
    return nil;
  }
  
  NSMutableArray *retVal = [[NSMutableArray alloc] init];
  
  if ([ATGJSONPathParser getKindOfClass:contentJSON] == ARRAY) {
    NSArray *a = (NSArray *) contentJSON;
    NSArray *tokens = [[manager getTokenizer] splitExpression:sliceExpr usingDelimiter:@":"];
    
    // default slicing
    NSInteger start = 0;
    NSInteger end = a.count;
    NSInteger step = 1;
    
    // change default values, where necessary, to match sliceExpr
    if (tokens.count == 3) {
      start = [[tokens objectAtIndex:0] integerValue];
      end = [[tokens objectAtIndex:1] integerValue];
      step = [[tokens objectAtIndex:2] integerValue];
    } else if (tokens.count == 2 && [[tokens objectAtIndex:0] isEqualToString:@""]) {
      end = [[tokens objectAtIndex:1] integerValue];
      if (end < 0) {
        end = a.count + end;
      }
    } else if (tokens.count == 1) {
      start = [[tokens objectAtIndex:0] integerValue];
      if (start < 0) {
        start = a.count + start;
      }
    }
    
    id result = 0;
    for (NSInteger index = start; index < end; index += step) {
      if (index > a.count - 1) {
        break;
      }
      result = [a objectAtIndex:index];
      if (result != nil) {
        [retVal addObject:result];
      }
    }
  }
  return retVal;
}

- (BOOL)pathExists:(NSArray *)pathTokens inContent:(id)contentJSON {
  if (contentJSON == nil) {
    return NO;
  }
  
  NSPredicate *predicateTest = [NSPredicate predicateWithFormat:@"self matches %@", [ATGDefaultJSONPathRegex getRegexForBooleanExpression]];
  
  if ([ATGJSONPathParser getKindOfClass:contentJSON] == OTHER) {
    contentJSON = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:contentJSON]];
  }
  
  for (NSInteger index = 0; index < pathTokens.count; index++) {
    NSString *token = [pathTokens objectAtIndex:index];
    
    if ([predicateTest evaluateWithObject:token] == YES) {
      NSRange predicateStartIndex = [token rangeOfString:[ATGDefaultJSONPathRegex getRegexForComparisonOperators] options:NSRegularExpressionSearch];
      
      NSString *key = [token substringToIndex:predicateStartIndex.location];
      NSString *booleanOp = [token substringWithRange:NSMakeRange(predicateStartIndex.location, predicateStartIndex.length)];
      NSString *val = [token substringWithRange:NSMakeRange(predicateStartIndex.location + predicateStartIndex.length, token.length - predicateStartIndex.location - predicateStartIndex.length)];
      
      NSString *openQuotation = [val substringToIndex:1]; // first character
      NSString *closeQuotation = [val substringFromIndex:val.length - 1]; // last character
      
      if ([openQuotation isEqualToString:@"'"] && [closeQuotation isEqualToString:@"'"]) {
        val = [val substringWithRange:NSMakeRange(1, val.length - 2)];
      }
      
      NSArray *stmtTokens = [[NSArray alloc]initWithObjects:key, booleanOp, val, nil];
      contentJSON = [self getContentFromCurrent:contentJSON satisfyingBooleanStatement:stmtTokens];
    } else {
      contentJSON = [self getChild:contentJSON withNodename:token];
    }
    
    if (contentJSON == nil) {
      return NO;
    } else if ([ATGJSONPathParser getKindOfClass:contentJSON] == ARRAY && [(NSArray *)contentJSON count] < 1) {
      return NO;
    }
  }
  return YES;
}

- (id)getContentFromCurrent:(id)contentJSON satisfyingBooleanStatement:(NSArray *)statementTokens {
  if (contentJSON == nil) {
    return nil;
  }
  
  NSString *key = [statementTokens objectAtIndex:0];
  NSString *booleanOp = [statementTokens objectAtIndex:1];
  NSString *val = [statementTokens objectAtIndex:2];
  
  NSMutableArray *retVal = [[NSMutableArray alloc]init];
  JSONObjectClassType type = [ATGJSONPathParser getKindOfClass:contentJSON];
  
  if (type == DICTIONARY) {
    NSDictionary *d = (NSDictionary *) contentJSON;
    NSArray *keys = [d allKeys];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    
    for (NSString *str in keys) {
      
      if ([key isEqualToString:str]) {
        id valOfStr = [d objectForKey:str];
        type = [ATGJSONPathParser getKindOfClass:valOfStr];
        
        if ([booleanOp isEqualToString:@"="]) {
          if ((type == STRING && [(NSString *) valOfStr isEqualToString:val])
              || (type == NUMBER  && [(NSNumber *) valOfStr doubleValue]  == [[formatter numberFromString:val] doubleValue])) {
            [retVal addObject:d];
          }
        } else if ([booleanOp isEqualToString:@"!="]) {
          if ((type == STRING && [(NSString *) valOfStr isEqualToString:val] == NO)
              || (type == NUMBER && [(NSNumber *) valOfStr doubleValue] != [[formatter numberFromString:val] doubleValue])) {
            
            [retVal addObject:d];
          }
        } else if ([booleanOp isEqualToString:@"<"]
                   && type == NUMBER && [(NSNumber *) valOfStr doubleValue] < [[formatter numberFromString:val] doubleValue]) {
          [retVal addObject:d];
          
        } else if ([booleanOp isEqualToString:@"<="]
                   && type == NUMBER && [(NSNumber *)valOfStr doubleValue] <= [[formatter numberFromString:val] doubleValue]) {
          [retVal addObject:d];
          
        } else if ([booleanOp isEqualToString:@">"]
                   && type == NUMBER && [(NSNumber *) valOfStr doubleValue] > [[formatter numberFromString:val] doubleValue]) {
          [retVal addObject:d];
          
        } else if ([booleanOp isEqualToString:@">="]
                   && type == NUMBER && [(NSNumber *) valOfStr doubleValue] >= [[formatter numberFromString:val]doubleValue]) {
          [retVal addObject:d];
        }
      }
    }
    formatter = nil;
  } else if (type == ARRAY) {
    NSArray *a = (NSArray *)contentJSON;
    for (NSInteger index = 0; index < a.count; index++) {
      id obj = [a objectAtIndex:index];
      if ([ATGJSONPathParser getKindOfClass:obj] == OTHER) {
        obj = [ATGJSONPathParser checkObjectTypeAndThrowError:[self.delegate getPrimitiveObjectFromUnknown:obj]];
      }
      if ([ATGJSONPathParser getKindOfClass:obj] == DICTIONARY) {
        id nextLevel = [self getContentFromCurrent:obj satisfyingBooleanStatement:statementTokens];
        if ([ATGJSONPathParser getKindOfClass:nextLevel] == ARRAY) {
          [retVal addObjectsFromArray:nextLevel];
        } else {
          [retVal addObject:nextLevel];
        }
      }
    }
  }
  return retVal;
}

+ (JSONObjectClassType)getKindOfClass:(id)object {
  JSONObjectClassType ct;
  
  if ([object isKindOfClass:[NSDictionary class]]) {
    ct = DICTIONARY;
  } else if ([object isKindOfClass:[NSArray class]]) {
    ct = ARRAY;
  } else if ([object isKindOfClass:[NSString class]]) {
    ct = STRING;
  } else if ([object isKindOfClass:[NSNumber class]]) {
    ct = NUMBER;
  } else {
    ct = OTHER;
  }
  return ct;
};

+ (id)checkObjectTypeAndThrowError:(id)unknownObject {
  if (unknownObject != nil && [ATGJSONPathParser getKindOfClass:unknownObject] == OTHER) {
    [NSException raise:@"ATGJSONPathParser: Error parsing given JSON object. " format:@"JSON object %@ is of uknown type", unknownObject];
  }
  return unknownObject;
};

@end
