//
//  XCDFormInputAccessoryView.m
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//
#import "XCDResponderChain.h"
#import "XCDFormInputAccessoryView.h"

static NSString * UIKitLocalizedString(NSString *string)
{
	NSBundle *UIKitBundle = [NSBundle bundleForClass:[UIApplication class]];
	return UIKitBundle ? [UIKitBundle localizedStringForKey:string value:string table:nil] : string;
}

@implementation XCDFormInputAccessoryView
{
	UIToolbar *_toolbar;
}

- (id) initWithFrame:(CGRect)frame
{
	return [self initWithResponders:nil];
}

- (id) initWithResponders:(NSArray *)responders
{
    return [self initWithResponderChain:responders ? [[XCDResponderChain alloc] initWithResponders:responders] : nil];
}

- (id) initWithResponderChain:(XCDResponderChain *)responderChain
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
	_responderChain = responderChain;
	
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
	_toolbar.items = @[ segmentedControlBarButtonItem, flexibleSpace ];
	self.hasDoneButton = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
	
	[self addSubview:_toolbar];
	
	self.frame = _toolbar.frame = (CGRect){CGPointZero, [_toolbar sizeThatFits:CGSizeZero]};
	
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
	if (!window)
		return;
	
	[self updateSegmentedControl];
}

- (void) textInputDidBeginEditing:(NSNotification *)notification
{
	[self updateSegmentedControl];
}

- (NSArray *) responders
{
    return self.responderChain.responders;
}

- (void) setResponders:(NSArray *)responders
{
    self.responderChain.responders = responders;
}

- (XCDResponderChain*) responderChain
{
    if (_responderChain == nil)
    {
        _responderChain = [XCDResponderChain
                           responderChainWithTextFieldsInView:[[UIApplication sharedApplication] keyWindow]];
        [_responderChain sortRespondersByPosition];
    }
    return _responderChain;
}

- (void) setHasDoneButton:(BOOL)hasDoneButton
{
	[self setHasDoneButton:hasDoneButton animated:NO];
}

- (void) setHasDoneButton:(BOOL)hasDoneButton animated:(BOOL)animated
{
	if (_hasDoneButton == hasDoneButton)
		return;
	
	[self willChangeValueForKey:@"hasDoneButton"];
	_hasDoneButton = hasDoneButton;
	[self didChangeValueForKey:@"hasDoneButton"];
	
	NSArray *items;
	if (hasDoneButton)
		items = [_toolbar.items arrayByAddingObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)]];
	else
		items = [_toolbar.items subarrayWithRange:NSMakeRange(0, 2)];
	
	[_toolbar setItems:items animated:animated];
}

#pragma mark - Actions

- (void) selectAdjacentResponder:(UISegmentedControl *)sender
{
	if (sender.selectedSegmentIndex == 0)
    {
        [self.responderChain  selectPreviousResponder];
    }
    else
    {
        [self.responderChain  selectNextResponder];
    }
}

- (void) done
{
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end
