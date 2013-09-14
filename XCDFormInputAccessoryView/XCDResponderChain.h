//
//  XCDResponderChain.h
//
//  Created by Jude Venn on 14/09/2013.
//  Copyright (c) 2013 Cuttlefish Multimedia Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^XCDResponderTestCallback)(id obj, BOOL *stop);

@interface XCDResponderChain : NSObject

+ (XCDResponderChain*)responderChainWithTextFieldsInView:(UIView *)view;
+ (XCDResponderChain*)responderChainInView:(UIView*)view passingTest:(XCDResponderTestCallback)predicate;

// Responders must be an array of UIResponders
- (id) initWithResponders:(NSArray *)responders;

@property (nonatomic, strong) NSArray *responders;

// Move the input focus to the adjacent responder
- (void)selectNextResponder;
- (void)selectPreviousResponder;

// By default +responderChainInView will return views order by z-order, which allows
// the developer to order views in the xib. Sometimes it's preferable to have the views
// sorted by vertical position like XCDFormInputAccessoryView, so this method does that.
- (void)sortRespondersByPosition;

@end
