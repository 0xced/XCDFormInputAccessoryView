//
//  XCDFormAccessoryView.m
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import "XCDFormAccessoryView.h"

static NSString * UIKitLocalizedString(NSString *string)
{
	NSBundle *UIKitBundle = [NSBundle bundleForClass:[UIApplication class]];
	return UIKitBundle ? [UIKitBundle localizedStringForKey:string value:string table:nil] : string;
}

static NSArray * TextInputsInView(UIView *view)
{
	NSMutableArray *textInputs = [NSMutableArray new];
	for (UIView *subview in view.subviews)
	{
		if ([subview isKindOfClass:[UITextField class]] || [subview isKindOfClass:[UITextView class]])
			[textInputs addObject:subview];
		else
			[textInputs addObjectsFromArray:TextInputsInView(subview)];
	}
	return textInputs;
}

@implementation XCDFormAccessoryView
{
	UIToolbar *_toolbar;
}

- (id) initWithFrame:(CGRect)frame
{
	return [self initWithResponders:nil];
}

- (id) initWithResponders:(NSArray *)responders
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
	_responders = responders;
	
	_toolbar = [[UIToolbar alloc] init];
	_toolbar.tintColor = nil;
	_toolbar.barStyle = UIBarStyleBlack;
	_toolbar.translucent = YES;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ UIKitLocalizedString(@"Previous"), UIKitLocalizedString(@"Next") ]];
	[segmentedControl addTarget:self action:@selector(selectAdjacentResponder:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	UIBarButtonItem *segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *doneBarButtonItem = nil;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	_toolbar.items = [NSArray arrayWithObjects:segmentedControlBarButtonItem, flexibleSpace, doneBarButtonItem, nil];
	
	[self addSubview:_toolbar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateSegmentedControl
{
	NSArray *responders = self.responders;
	if ([responders count] == 0)
		return;
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)[_toolbar.items[0] customView];
	BOOL isFirst = [[responders objectAtIndex:0] isFirstResponder];
	BOOL isLast = [[responders lastObject] isFirstResponder];
	[segmentedControl setEnabled:!isFirst forSegmentAtIndex:0];
	[segmentedControl setEnabled:!isLast forSegmentAtIndex:1];
}

- (void) willMoveToWindow:(UIWindow *)window
{
	self.frame = _toolbar.frame = (CGRect){CGPointZero, [_toolbar sizeThatFits:CGSizeZero]};
	[self updateSegmentedControl];
}

- (void) textInputDidBeginEditing:(NSNotification *)notification
{
	[self updateSegmentedControl];
}

- (NSArray *) responders
{
	if (_responders)
		return _responders;
	
	NSArray *textInputs = TextInputsInView([[UIApplication sharedApplication] keyWindow]);
	return [textInputs sortedArrayUsingComparator:^NSComparisonResult(UIView *textInput1, UIView *textInput2) {
		UIView *commonAncestorView = textInput1.superview;
		while (commonAncestorView && ![textInput2 isDescendantOfView:commonAncestorView])
			commonAncestorView = commonAncestorView.superview;
		
		CGRect frame1 = [textInput1 convertRect:textInput1.bounds toView:commonAncestorView];
		CGRect frame2 = [textInput2 convertRect:textInput2.bounds toView:commonAncestorView];
		return [@(CGRectGetMinY(frame1)) compare:@(CGRectGetMinY(frame2))];
	}];
}

#pragma mark - Actions

- (void) selectAdjacentResponder:(UISegmentedControl *)sender
{
	NSArray *firstResponders = [self.responders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIResponder *responder, NSDictionary *bindings) {
		return [responder isFirstResponder];
	}]];
	UIResponder *firstResponder = [firstResponders lastObject];
	NSInteger offset = sender.selectedSegmentIndex == 0 ? -1 : +1;
	NSInteger firstResponderIndex = [self.responders indexOfObject:firstResponder];
	NSInteger adjacentResponderIndex = firstResponderIndex != NSNotFound ? firstResponderIndex + offset : NSNotFound;
	UIResponder *adjacentResponder = nil;
	if (adjacentResponderIndex >= 0 && adjacentResponderIndex < (NSInteger)[self.responders count])
		adjacentResponder = [self.responders objectAtIndex:adjacentResponderIndex];
	
	[adjacentResponder becomeFirstResponder];
}

- (void) done
{
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end
