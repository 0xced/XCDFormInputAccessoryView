//
//  XCDResponderChain.m
//
//  Created by Jude Venn on 14/09/2013.
//  Copyright (c) 2013 Cuttlefish Multimedia Ltd. All rights reserved.
//

#import "XCDResponderChain.h"

@interface XCDResponderChain ()

+ (NSArray*)descendantsOfView:(UIView*)view passingTest:(XCDResponderTestCallback)predicate;

- (void)selectAdjacentResponder:(NSInteger)direction;

@end


@implementation XCDResponderChain

- (id)initWithResponders:(NSArray *)responders {
    self = [super init];
    if (self) {
        self.responders = responders;
    }
    return self;
}

- (void)sortRespondersByPosition {
	self.responders = [self.responders sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (![view1 isKindOfClass:[UIView class]] || ![view2 isKindOfClass:[UIView class]]) {
            return NSOrderedSame;
        }
        
		UIView *commonAncestorView = view1.superview;
		while (commonAncestorView && ![view2 isDescendantOfView:commonAncestorView]) {
			commonAncestorView = commonAncestorView.superview;
        }
		
		CGRect frame1 = [view1 convertRect:view1.bounds toView:commonAncestorView];
		CGRect frame2 = [view2 convertRect:view2.bounds toView:commonAncestorView];
		return [@(CGRectGetMinY(frame1)) compare:@(CGRectGetMinY(frame2))];
	}];
}

+ (NSArray*)descendantsOfView:(UIView*)view passingTest:(XCDResponderTestCallback)predicate {
    NSMutableArray *descendants = [NSMutableArray array];
    BOOL stop = NO;
    for (UIView *subview in view.subviews) {
        if (predicate(subview, &stop)) {
            [descendants addObject:subview];
            if (stop) break;
        }
        if ([subview.subviews count]) {
            [descendants addObjectsFromArray:[self descendantsOfView:subview
                                                         passingTest:predicate]];
        }
    }
    return descendants;
}

+ (XCDResponderChain*)responderChainInView:(UIView*)view passingTest:(XCDResponderTestCallback)predicate {
    return [[self alloc] initWithResponders:[self descendantsOfView:view passingTest:predicate]];
}

+ (XCDResponderChain*)responderChainWithTextFieldsInView:(UIView *)view {
    XCDResponderTestCallback isEditableTextField = ^BOOL(id obj, BOOL *stop) {
        BOOL isTextField = [obj isKindOfClass:[UITextField class]];
        BOOL isEditableTextView = [obj isKindOfClass:[UITextView class]] && [(UITextView *)obj isEditable];
        return (isTextField || isEditableTextView);
    };
    return [XCDResponderChain
            responderChainInView:view
            passingTest:isEditableTextField];
}

- (void)selectNextResponder {
    [self selectAdjacentResponder:1];
}

- (void)selectPreviousResponder {
    [self selectAdjacentResponder:-1];
}

- (void)selectAdjacentResponder:(NSInteger)direction {
    if (direction == 0) return;
	NSInteger offset = direction < 0 ? -1 : +1;
    
	NSArray *firstResponders = [self.responders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIResponder *responder, NSDictionary *bindings) {
		return [responder isFirstResponder];
	}]];
	UIResponder *firstResponder = [firstResponders lastObject];
	NSInteger firstResponderIndex = [self.responders indexOfObject:firstResponder];
	NSInteger adjacentResponderIndex = firstResponderIndex != NSNotFound ? firstResponderIndex + offset : NSNotFound;
	UIResponder *adjacentResponder = nil;
	if (adjacentResponderIndex >= 0 && adjacentResponderIndex < (NSInteger)[self.responders count])
		adjacentResponder = [self.responders objectAtIndex:adjacentResponderIndex];
	
	[adjacentResponder becomeFirstResponder];
}

@end
