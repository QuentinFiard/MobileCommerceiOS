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

#import <objc/runtime.h>
#import <objc/message.h>
#import "ATGExpandableTableView.h"
#import "ATGExpandableTableViewCell.h"

/*
 ******************* NOTE ********************
   This class does not use Automatic Reference Counting. To enable ARC, remove the
   "-fno-objc-arc" compiler flag from the Compile Sources Build Phase for the
   project.
 */

// This collection will contain all instrumented classes.
static NSMutableArray *ATGInstrumentedClasses = nil;

#pragma mark - ATGExpandableTableView Custom IMP Functions

// Use this function as method implementation, if you want to send exactly the same
// message to the instance's superclass.
// I.e. add this function as method implementation for the tableView:heightForRowAtIndexPath:
// method, and class updated will have an implementation as follows
// return [super tableView:heightForRowAtIndexPath:];
id call_parent_height(id pInstance, SEL pSelector, ...) {
  // Definition of instance's superclass.
  struct objc_super super_definition = {
    pInstance, class_getSuperclass([pInstance class])
  };
  // Get all parameters passed into the current method.
  va_list arguments;
  va_start(arguments, pSelector);
  id tableView = va_arg(arguments, id);
  id indexPath = va_arg(arguments, id);
  // Free the variable arguments list.
  va_end(arguments);
  // Make a call to instance's superclass. Pass all the same input parameters.
  SEL selector = @selector(tableView:heightForRowAtIndexPath:);
  return objc_msgSendSuper(&super_definition, selector, tableView, indexPath);
}

// Similar implementation for the tableView:didSelectRowAtIndexPath: selector.
id call_parent_select(id pInstance, SEL pSelector, ...) {
  // Definition of instance's superclass.
  struct objc_super super_definition = {
    pInstance, class_getSuperclass([pInstance class])
  };
  // Get all parameters passed into the current method.
  va_list arguments;
  va_start(arguments, pSelector);
  id tableView = va_arg(arguments, id);
  id indexPath = va_arg(arguments, id);
  // Free the variable arguments list.
  va_end(arguments);
  // Make a call to instance's superclass. Pass all the same input parameters.
  SEL selector = @selector(tableView:didSelectRowAtIndexPath:);
  return objc_msgSendSuper(&super_definition, selector, tableView, indexPath);
}

// Implementation fo the tableView:willSelectRowAtIndexPath: selector.
id call_parent_will_select(id pInstance, SEL pSelector, ...) {
  // Define instance's superclass.
  struct objc_super super_definition = {
    pInstance, class_getSuperclass([pInstance class])
  };
  // Get parameters from the method to pass them. We know exact number and types of parameters.
  va_list arguments;
  va_start(arguments, pSelector);
  id tableView = va_arg(arguments, id);
  id indexPath = va_arg(arguments, id);
  va_end(arguments);
  // Now call the super-implementation.
  SEL selector = @selector(tableView:willSelectRowAtIndexPath:);
  return objc_msgSendSuper(&super_definition, selector, tableView, indexPath);
}

// This implementation will propagate method calling to a superclass without changing selector.
id call_parent_anything(id pInstance, SEL pSelector, ...) {
  // Definition of instance's superclass.
  struct objc_super super_definition = {
    pInstance, class_getSuperclass([pInstance class])
  };
  // Get all parameters passed into the current method.
  va_list arguments;
  va_start(arguments, pSelector);
  id tableView = va_arg(arguments, id);
  id indexPath = va_arg(arguments, id);
  // Free the variable arguments list.
  va_end(arguments);
  return objc_msgSendSuper(&super_definition, pSelector, tableView, indexPath);
}

#pragma mark - ATGExpandableTableView Private Protocol Definition
#pragma mark -

@interface ATGExpandableTableView ()

- (void) deinstrumentSubclassesOfClass:(Class)class;

@end

#pragma mark - ATGExpandableTableView Implementation
#pragma mark -

@implementation ATGExpandableTableView

// Default implementation, if no willSelectRow method defined by delegate.
- (NSIndexPath *) tableView:(UITableView *)pTableView defaultWillSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  // Do nothing, just return input parameter to allos cell selection by default.
  return pIndexPath;
}

// Implementation to be triggered when sending the willSelectRow message.
- (NSIndexPath *) tableView:(UITableView *)pTableView extendedWillSelectRowAtIndexPath:(NSIndexPath *)pIndexPath {
  BOOL restrictSelection = [pIndexPath isEqual:[pTableView indexPathForSelectedRow]];
  if ([pTableView indexPathForSelectedRow] &&
      [pIndexPath section] == [[pTableView indexPathForSelectedRow] section]) {
    [pTableView beginUpdates];
    [pTableView deselectRowAtIndexPath:[pTableView indexPathForSelectedRow] animated:YES];
    [pTableView endUpdates];
  }
  // Ok, no recursion will occur, as we will swap implementations of extendedWillSelectRowAtIndexPath: and
  // willSelectRowAtIndexPath: methods.
  NSIndexPath *result = [self tableView:pTableView extendedWillSelectRowAtIndexPath:pIndexPath];
  return restrictSelection ? nil : result;
}

// Default implementation, if no heightForRow method defined by delegate.
- (CGFloat) tableView:(UITableView *)pTableView defaultHeightForRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  return [pTableView rowHeight];
}

// Implementation to be triggered when sending the heightForRow
- (CGFloat) tableView:(UITableView *)pTableView extendedHeightForRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  if ([pIndexPath isEqual:[pTableView indexPathForSelectedRow]]) {
    // We're getting height of a selected row.
    // This height should be saved by the tableView:didSelectRow: method.
    // The theigh is saved on the table view, and we're inside of a delegate's method.
    // So we have to get the height from table view.
    // For some reason object_getInstanceVariable takes a void* parameter, not void**.
    CGFloat savedHeight;
    object_getInstanceVariable(pTableView, "mSelectedExpandedHeigh",
                               (void *)&savedHeight);
    return savedHeight;
  }
  // This will not cause an infinite recursion, because we will exchange method
  // implementations while instrumenting the delegate. Default
  // tableView:heightForRowAtIndexPath: method implementation will be triggered
  // when the tableView:extendedHeightForRowAtIndexPath: message is sent.
  return [self tableView:pTableView extendedHeightForRowAtIndexPath:pIndexPath];
}

// Add this method, if no didSelectRow method defined by delegate.
- (void) tableView:(UITableView *)pTableView defaultDidSelectRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  // Do nothing, this method implementation will be added to generify method
  // instrumentation process.
}

// Implementation to be triggered when sending the didSelectRow message.
- (void) tableView:(UITableView *)pTableView extendedDidSelectRowAtIndexPath:
 (NSIndexPath *)pIndexPath {
  // Save the selected cell height for future use.
  // It will be used when calculating cells heigh in the
  // tableView:heighForRowAtIndexPath: method.
  UITableViewCell *selected = [pTableView cellForRowAtIndexPath:pIndexPath];
  CGFloat expandedHeight;
  if ([selected conformsToProtocol:@protocol(ATGExpandableTableViewCell)]) {
    // Selected cell is an ATGExpandableTableViewCell, it can calculate its heigth.
    expandedHeight = [(id < ATGExpandableTableViewCell >) selected expandedHeight];
  } else {
    // Selected cell can't calculate its height, just use default value.
    // When this message is sent, the delegate object will possess the
    // tableView:extendedHeighForRowAtIndexPath: method. It would be added
    // dynamically while instrumenting the delegate.
    // This message will trigger default delegate's tableView:heightForRowAtIndexPath:
    // implementation.
    expandedHeight = [(id)[pTableView delegate] tableView:pTableView
                          extendedHeightForRowAtIndexPath:pIndexPath];
  }
  // Save the heigh on the table view instance.
  Ivar var = class_getInstanceVariable([pTableView class], "mSelectedExpandedHeigh");
  // You can't use an object_setInstanceVariable function on float variables, so
  // perform some voodo on table view instance.
  CGFloat *selectedHeightPtr = (CGFloat *)( (void *)pTableView + ivar_getOffset(var) );
  *selectedHeightPtr = expandedHeight;
  // And tell the table view to recalculate all heights.
  [pTableView beginUpdates];
  [pTableView endUpdates];
  // This will not cause an infinite recursion, because we will exchange method
  // implementations while instrumenting the delegate. Default
  // tableView:didSelectRowAtIndexPath: method implementation will be triggered
  // when the tableView:extendedDidSelectRowAtIndexPath: message is sent.
  [self tableView:pTableView extendedDidSelectRowAtIndexPath:pIndexPath];
}

- (void) replaceOriginalSelector:(SEL)pOriginalSelector
            withExtendedSelector:(SEL)pExtendedSelector
              addDefaultSelector:(SEL)pDefaultSelector
         useParentImplementation:(IMP)pParentImplementation
                         onClass:(Class)pClass {
  // Check, if delegate or its superclasses implement the original method.
  Method originalMethod = class_getInstanceMethod(pClass, pOriginalSelector);
  if (!originalMethod) {
    // Delegate or its superclass doesn't implement the original method.
    // Add default implementation.

    // Default implementation is defined on the ATGExpandableTableView,
    // and self parameter is an ATGExpandableTableView.
    Method defaultMethod = class_getInstanceMethod([self class], pDefaultSelector);
    IMP defaultMethodImp = method_getImplementation(defaultMethod);
    // Add the method to delegate's class.
    // Important! default implementation will be called in response to the
    // original selector, not default selector!
    class_addMethod( pClass, pOriginalSelector, defaultMethodImp,
                     method_getTypeEncoding(defaultMethod) );
  } else {
    // Delegate itself or one of its superclasses implement the original method.
    // Check, if it implements the method by itself (not superclass).
    BOOL implements = NO;
    unsigned int methodsNumber = 0;
    // Get methods implemented by the class specified only.
    Method *implementedMethods = class_copyMethodList(pClass, &methodsNumber);
    // Look, if the method is implemented.
    for (int i = 0; i < methodsNumber; i++) {
      // Compare methods by their selectors.
      SEL methodSelector = method_getName(implementedMethods[i]);
      if ( sel_isEqual(methodSelector, pOriginalSelector) ) {
        // Found! Delegate implements its own logic for the original method.
        implements = YES;
        break;
      }
    }
    // Always free the memory acquired.
    free(implementedMethods);
    if (!implements) {
      // Delegate doesn't implement the method by itself. Add a method which will call
      // a superclass.
      // Actually add the method implementation to delegate's method.
      class_addMethod( pClass, pOriginalSelector, pParentImplementation,
                       method_getTypeEncoding(originalMethod) );
    }
    // Now the delegate either implements its own logic for the original method
    // or makes a call to its superclass.
  }
  // At this point delegate class reliably implements an original method.

  // Add an extended version of this method.
  // Extended version of this method is defined on the ATGExpandableTableView.
  // self parameter is always ATGExpandableTableView, so get method from it.
  Method extendedMethod = class_getInstanceMethod([self class], pExtendedSelector);
  IMP extendedMethodImp = method_getImplementation(extendedMethod);
  class_addMethod( pClass, pExtendedSelector, extendedMethodImp,
                   method_getTypeEncoding(extendedMethod) );
  // At this point delegate class reliably implements both
  // original and extended methods.

  // Extended version of the method should be triggered when accessing the
  // original method. Exchange implementations.
  method_exchangeImplementations( class_getInstanceMethod(pClass, pOriginalSelector),
                                  class_getInstanceMethod(pClass, pExtendedSelector) );
}

- (BOOL) isDelegateInstrumented:(id)pDelegate {
  return [pDelegate respondsToSelector:@selector(tableView:extendedDidSelectRowAtIndexPath:)]
         && [pDelegate respondsToSelector:@selector(tableView:extendedHeightForRowAtIndexPath:)]
         && [pDelegate respondsToSelector:@selector(tableView:extendedWillSelectRowAtIndexPath:)];
}

- (void) instrumentDelegate:(id <UITableViewDelegate>)pDelegate {
  if ([self isDelegateInstrumented:pDelegate]) {
    return;
  } else {
    [self deinstrumentSubclassesOfClass:[pDelegate class]];
  }
  // Touch the row height method.
  [self replaceOriginalSelector:@selector(tableView:heightForRowAtIndexPath:)
           withExtendedSelector:@selector(tableView:extendedHeightForRowAtIndexPath:)
             addDefaultSelector:@selector(tableView:defaultHeightForRowAtIndexPath:)
        useParentImplementation:&call_parent_height
                        onClass:[pDelegate class]];
  // Touch the row selected method.
  [self replaceOriginalSelector:@selector(tableView:didSelectRowAtIndexPath:)
           withExtendedSelector:@selector(tableView:extendedDidSelectRowAtIndexPath:)
             addDefaultSelector:@selector(tableView:defaultDidSelectRowAtIndexPath:)
        useParentImplementation:&call_parent_select
                        onClass:[pDelegate class]];
  // Touch the will select row method.
  [self replaceOriginalSelector:@selector(tableView:willSelectRowAtIndexPath:)
           withExtendedSelector:@selector(tableView:extendedWillSelectRowAtIndexPath:)
             addDefaultSelector:@selector(tableView:defaultWillSelectRowAtIndexPath:)
        useParentImplementation:&call_parent_will_select
                        onClass:[pDelegate class]];
  [ATGInstrumentedClasses addObject:[pDelegate class]];
}

- (void) setDelegate:(id <UITableViewDelegate>)pDelegate {
  if (pDelegate) {
    // Instrument the delegate before setting it into table view.
    // UITableView looks up for a tableView:heightForRowAtIndexPath: method only once,
    // during the setDelegate: method invokation. So the method should already be there
    // when setting the delegate.
    [self instrumentDelegate:pDelegate];
  }
  [super setDelegate:pDelegate];
}

#pragma mark - ATGExpandableTableView Private Protocol Implementation

- (void) deinstrumentSubclassesOfClass:(Class)pClass {
  if (ATGInstrumentedClasses == nil) {
    ATGInstrumentedClasses = [[NSMutableArray alloc] init];
  }

  for (Class class in ATGInstrumentedClasses) {
    if ([class isSubclassOfClass:pClass]) {
      method_exchangeImplementations
        ( class_getInstanceMethod( class, @selector(tableView:extendedHeightForRowAtIndexPath:) ),
        class_getInstanceMethod( class, @selector(tableView:heightForRowAtIndexPath:) ) );
      class_replaceMethod(class, @selector(tableView:extendedHeightForRowAtIndexPath:),
                          &call_parent_anything, "@@::");
      method_exchangeImplementations
        ( class_getInstanceMethod( class, @selector(tableView:extendedDidSelectRowAtIndexPath:) ),
        class_getInstanceMethod( class, @selector(tableView:didSelectRowAtIndexPath:) ) );
      class_replaceMethod(class, @selector(tableView:extendedDidSelectRowAtIndexPath:),
                          &call_parent_anything, "@@::");
      method_exchangeImplementations
        ( class_getInstanceMethod( class, @selector(tableView:extendedWillSelectRowAtIndexPath:) ),
        class_getInstanceMethod( class, @selector(tableView:willSelectRowAtIndexPath:) ) );
      class_replaceMethod(class, @selector(tableView:extendedWillSelectRowAtIndexPath:),
                          &call_parent_anything, "@@::");
      [ATGInstrumentedClasses removeObject:class];
    }
  }
}

@end