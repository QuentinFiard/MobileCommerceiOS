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



#import "ATGThemeManager.h"
#import "ATGThemeReader.h"
#import "UIImage+ATGAdditions.h"

NSString *COLOR_KEY = @"@color:";
NSString *COLOR_REF_KEY = @"@colorref:";
NSString *FLOAT_KEY = @"@float:";
NSString *FONT_KEY = @"@font:";
NSString *IMAGE_KEY = @"@image:";
NSString *UNSIGNED_INT_KEY = @"@uint:";
NSString *RESOURCE_KEY = @"@resource:";
NSString *NIL_KEY = @"@nil";
NSString *BOOL_KEY = @"@bool:";
NSString *EDGE_INSETS = @"@edge_insets:";

NSString *VALUE_PREFIX = @"@";
NSString *IN_VIEW_SEPARATOR = @">";
NSString *NAMED_STYLE_PREFIX = @"~";
NSString *UNIQUE_ID_SUFFIX = @"~";

static ATGThemeManager *sThemeManager = nil;

@implementation ATGThemeManager {
  NSMutableDictionary *mColorDictionary;
  ATGThemeReader *mThemeReader;
}

@synthesize lastThemeUpdate;

-(id) init {
  if (self=[super init]) {
    mThemeReader = [[ATGThemeReader alloc] initForReadingJSONFile:[self themeFile]];
    mColorDictionary = [[NSMutableDictionary alloc] init];
  }
  return self;
}

+ (ATGThemeManager *) themeManager {
  static dispatch_once_t pred_theme_manager;
  dispatch_once(&pred_theme_manager,
                ^{
                  if (!sThemeManager)
                    sThemeManager = [[ATGThemeManager alloc] init];
                }
                );
  return sThemeManager;
}

-(void) loadThemeFromURL:(NSString *) pURL {
  mThemeReader = [[ATGThemeReader alloc] initForReadingJSONFile:pURL];
  self.lastThemeUpdate = pURL;
}

-(void) applyStyle:(NSString *) pStyleName toObject:(NSObject *) pView {
  // style names are defined in the JSON with a prefixed tilda character.  Here we accept the name
  // with or without the tilda, but if it's missing, add it now.
  if (![pStyleName hasPrefix:@"~"])
    pStyleName = [@"~" stringByAppendingString:pStyleName];
  
  [self applyStyleProperties:[[mThemeReader getStyles] objectForKey:pStyleName] toInstance:pView withValidation:YES];
}

-(id) findResourceById:(NSString *) pResourceId {
  if (![pResourceId hasPrefix:RESOURCE_KEY])
    pResourceId = [RESOURCE_KEY stringByAppendingString:pResourceId];
  id result = [self parseJSONObject:pResourceId];
  return result;
}

-(void)saveJSON:(NSData *)pJson {
  [pJson writeToFile:[self themeFile] atomically:YES];
}

-(NSString *) themeFile {
  // return the bundled Theme.json file.
  return [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"json"];
}

-(void)applyAllStyles {
  NSArray *allStyles = [[mThemeReader getStyles] allKeys];
  
  for (NSString *style in allStyles) {
    
    if ([style hasPrefix:NAMED_STYLE_PREFIX]) {
      // this is a named style, not an apperance proxy compatible style.
      continue;
    }
    NSString *whenInViews;
    NSRange colonLocation = [style rangeOfString:IN_VIEW_SEPARATOR];
    NSString *targetClassName = style;
    if (colonLocation.location != NSNotFound) {
      targetClassName = [style substringToIndex:colonLocation.location];
      whenInViews = [style substringFromIndex:colonLocation.location + 1];
    }
    
    // apply the styles to the target class
    Class clazz = NSClassFromString(targetClassName);
    id instance;
    
    if (whenInViews){
      instance = [clazz appearanceWhenContainedIn:NSClassFromString(whenInViews), nil];
    }
    else {
      instance = [clazz appearance];
    }
    
    NSDictionary *styleProperties =  [[mThemeReader getStyles] objectForKey:style];
    [self applyStyleProperties:styleProperties toInstance:instance withValidation:NO];
  }
}

-(void) applyStyleProperties: (NSDictionary *) pProperties toInstance: (id) pInstance withValidation: (BOOL) pValidation {
  NSArray *selectorNames = [pProperties allKeys];
  
  for (NSString *selectorName in selectorNames) {
    id instance = pInstance;

    // if the selector has a trailing "~[number]" remove it and throw it away.  Its
    // purpose is simply to keep each JSON key unique.
    NSString *cleanedSelectorName = selectorName;
    NSRange uniqueIdRange = [cleanedSelectorName rangeOfString:UNIQUE_ID_SUFFIX];
    
    if (uniqueIdRange.location != NSNotFound) {
      cleanedSelectorName = [cleanedSelectorName substringToIndex:uniqueIdRange.location];
    }
    
    // Next, see if the selector contains a '.' character.  If it does, the property is attempting
    // to set a property of a property, so we need to get the object before the '.', and then call
    // the setter after the '.'.
    
    NSRange dotRange = [cleanedSelectorName rangeOfString:@"."];
    while (dotRange.location != NSNotFound) {
      NSString *getterName = [cleanedSelectorName substringToIndex:dotRange.location];
      cleanedSelectorName = [cleanedSelectorName substringFromIndex:dotRange.location + 1];
      
      SEL getter = NSSelectorFromString(getterName);
      if ([instance respondsToSelector:getter])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        instance = [instance performSelector:getter];
#pragma clang diagnostic pop
      
      // check if the string still has a '.' character.
      dotRange = [cleanedSelectorName rangeOfString:@"."];
    }
    
    // try the name as-is.  If it's not a valid selector, try prefixing it with 'set'.
    SEL selector = NSSelectorFromString([cleanedSelectorName stringByAppendingString:@":"]);
    
    if (![instance respondsToSelector:selector]) {
      NSString *setSelector = [@"set" stringByAppendingString:[[cleanedSelectorName substringToIndex:1] capitalizedString]];
      setSelector = [setSelector stringByAppendingString:[cleanedSelectorName substringFromIndex:1]];
      
      selector = NSSelectorFromString([setSelector stringByAppendingString:@":"]);
    }
    
    // if the instance doesn't respond to the selector, an error has been made in the style definition
    // so log a debug message and continue.
    if (pValidation && ![instance respondsToSelector:selector]) {
      DebugLog(@"The following is not a valid style property: %@", cleanedSelectorName);
      continue;
    }
    
    id argument = [self parseJSONObject: [pProperties objectForKey:selectorName]];
    
    NSInvocation *invocation = [NSInvocation
                                invocationWithMethodSignature:[instance methodSignatureForSelector:selector]];
    
    if ([argument isKindOfClass:[NSValue class]]) {
      NSValue *value = (NSValue *)argument;
      void* buffer = [self unwrapValue:value];
      [invocation setArgument:buffer atIndex:2];
      // the above setArgument call copies the contents of the argument, so it's safe to
      // release it now.
      free(buffer);
    } else if ([argument isKindOfClass:[NSArray class]]) {
      NSInteger count = 2;
      NSArray *argArray = ((NSArray *) argument);
      
      for (NSInteger i = 0; i < argArray.count; i++) {
        id parsedObj = [argArray objectAtIndex:i];
        parsedObj = [self parseJSONObject:parsedObj];
        
        if ([parsedObj isKindOfClass:[NSValue class]]) {
          NSValue *value = (NSValue *)parsedObj;
          void* buffer = [self unwrapValue:value];
          [invocation setArgument:buffer atIndex:count];
          free(buffer);
        } else {
          [invocation setArgument:&parsedObj atIndex:count];
        }
        count++;
      }
      
    } else {
      [invocation setArgument:&argument atIndex:2];
    }
    
    [invocation setTarget:instance];
    [invocation setSelector:selector];
    [invocation invoke];
  }
}

-(void*) unwrapValue:(NSValue*) pValue {
  NSUInteger bufferSize = 0;
  NSGetSizeAndAlignment([pValue objCType], &bufferSize, nil);
  void* buffer = malloc(bufferSize);
  [pValue getValue:buffer];
  return buffer;
}

-(id) parseJSONObject:(id) pObject {
  if ([pObject isKindOfClass: [NSString class]]) {
    // is a resource
    if ([pObject hasPrefix:RESOURCE_KEY]) {
      NSString *ref = [pObject substringFromIndex:[RESOURCE_KEY length]];
      NSString *valueString = [[mThemeReader getResources] valueForKey:ref];
      return [self parseJSONObject:valueString];
    }
    // is a color
    else if ([pObject hasPrefix:COLOR_KEY]) {
      NSString *rgba = [pObject substringFromIndex:[COLOR_KEY length]];
      
      // if this color has already been created, re-use it.
      if ([mColorDictionary objectForKey:rgba]) {
        return [mColorDictionary objectForKey:rgba];
      }

      NSArray *components = [rgba componentsSeparatedByString:@" "];
      
      UIColor *color = [UIColor colorWithRed:[[components objectAtIndex:0] floatValue] green:[[components objectAtIndex:1] floatValue] blue:[[components objectAtIndex:2] floatValue] alpha:[[components objectAtIndex:3] floatValue]];
      
      // put it in the dictionary for re-use.  This has the added benefit of ensuring the color doesn't get
      // prematurely freed, which can other happen in certain cases.
      [mColorDictionary setObject:color forKey:rgba];
      return color;
    }
    // is a float
    else if ([pObject hasPrefix:FLOAT_KEY]) {
      NSString *floatAsString = [pObject substringFromIndex: [FLOAT_KEY length]];
      CGFloat val = [floatAsString floatValue];
      return [NSValue valueWithBytes:&val objCType:@encode(CGFloat)];
    }
    // is an unsigned int or enum value
    else if ([pObject hasPrefix:UNSIGNED_INT_KEY]) {
      NSString *intAsString = [pObject substringFromIndex: [UNSIGNED_INT_KEY length]];
      NSUInteger val = (NSUInteger) [intAsString integerValue];
      return [NSValue valueWithBytes:&val objCType:@encode(NSUInteger)];
    }
    // is an image
    else if ([pObject hasPrefix:IMAGE_KEY]) {
      NSString *imageName = [pObject substringFromIndex: [IMAGE_KEY length]];
      UIImage *image = [UIImage locateImageNamed:imageName];
      return image;
    }
    // is a CG color reference
    else if ([pObject hasPrefix:COLOR_REF_KEY]) {
      NSString *colorString = [pObject substringFromIndex: [COLOR_REF_KEY length]];
      UIColor *color = [self parseJSONObject:colorString];
      CGColorRef ref = color.CGColor;
      return [NSValue valueWithBytes:&ref objCType:@encode(CGColorRef)];
    }
    // is a bool
    else if ([pObject hasPrefix:BOOL_KEY]) {
      NSString *boolAsString = [pObject substringFromIndex: [BOOL_KEY length]];
      BOOL val = [boolAsString boolValue];
      return [NSValue valueWithBytes:&val objCType:@encode(BOOL)];
    }
    // is a font
    else if ([pObject hasPrefix:FONT_KEY]) {
      NSString *fontAsString = [pObject substringFromIndex: [FONT_KEY length]];
      NSArray *fontSettings = [fontAsString componentsSeparatedByString:@":"];
      return [UIFont fontWithName:[fontSettings objectAtIndex:0] size:[[fontSettings objectAtIndex:1] floatValue]];
    }
    // is edge insets
    else if ([pObject hasPrefix:EDGE_INSETS]) {
      NSString *insets = [pObject substringFromIndex:[EDGE_INSETS length]];
      NSArray *components = [insets componentsSeparatedByString:@" "];
      UIEdgeInsets insetsStruct = UIEdgeInsetsMake([[components objectAtIndex:0] floatValue], [[components objectAtIndex:1] floatValue],[[components objectAtIndex:2] floatValue], [[components objectAtIndex:3] floatValue]);
      return [NSValue valueWithBytes:&insetsStruct objCType:@encode(UIEdgeInsets)];
    }
    // is nil
    else if ([pObject hasPrefix:NIL_KEY])
      return nil;
    else
      return pObject;
  } else {
    return pObject;
  }
}

@end
