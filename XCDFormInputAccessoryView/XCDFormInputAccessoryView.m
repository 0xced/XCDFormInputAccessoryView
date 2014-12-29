//
//  XCDFormInputAccessoryView.m
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import "XCDFormInputAccessoryView.h"

static NSArray * EditableTextInputsInView(UIView *view)
{
	NSMutableArray *textInputs = [NSMutableArray new];
	for (UIView *subview in view.subviews)
	{
		BOOL isTextField = [subview isKindOfClass:[UITextField class]];
		BOOL isEditableTextView = [subview isKindOfClass:[UITextView class]] && [(UITextView *)subview isEditable];
		if (isTextField || isEditableTextView)
			[textInputs addObject:subview];
		else
			[textInputs addObjectsFromArray:EditableTextInputsInView(subview)];
	}
	return textInputs;
}

@interface XCDFormInputAccessoryView ()

@property (strong, nonatomic) UIBarButtonItem *previousBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *nextBarButtonItem;
@property (strong, nonatomic) UIToolbar *toolbar;

@end

@implementation XCDFormInputAccessoryView

- (instancetype) initWithFrame:(CGRect)frame
{
	return [self initWithResponders:nil];
}

- (id)initWithResponders:(NSArray *)responders
{
    return [self initWithResponders:responders tintColor:[UIColor blackColor]];
}

- (instancetype) initWithResponders:(NSArray *)responders tintColor:(UIColor *)tintColor
{
	if (!(self = [super initWithFrame:CGRectZero]))
		return nil;
	
	_responders = responders;
	
	self.toolbar = [[UIToolbar alloc] init];
	self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.toolbar.tintColor = tintColor;
    
    UIImage *previousImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowLeft"];
    UIImage *previousLandscapeImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowLeftLandscape"];
    UIImage *nextImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowRight"];
    UIImage *nextLandscapeImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowRightLandscape"];
    
    CGFloat whiteColorValue = 0.f;
    [tintColor getWhite:&whiteColorValue alpha:NULL];
    if (whiteColorValue == 1.0) {
        previousImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowLeftWhite"];
        previousLandscapeImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowLeftLandscapeWhite"];
        nextImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowRightWhite"];
        nextLandscapeImage = [UIImage imageNamed:@"XCDButtonBarArrow.bundle/UIButtonBarArrowRightLandscapeWhite"];
    }
    
    UIBarButtonItem *previousBarButtonItem = [[UIBarButtonItem alloc] initWithImage:previousImage landscapeImagePhone:previousLandscapeImage style:UIBarButtonItemStylePlain target:self action:@selector(previous:)];
	self.previousBarButtonItem = previousBarButtonItem;
	
	UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nextImage landscapeImagePhone:nextLandscapeImage style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
	self.nextBarButtonItem = nextBarButtonItem;
    
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	[fixedSpace setWidth:32];
	
	self.toolbar.items = @[ self.previousBarButtonItem, fixedSpace, self.nextBarButtonItem, flexibleSpace ];
	[self addSubview:self.toolbar];
    
	self.hasDoneButton = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
	
	self.frame = self.toolbar.frame = CGRectMake(0, 0, 0, 44);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateBarButtonItems
{
	NSArray *responders = self.responders;
	if ([responders count] == 0)
		return;
	
	BOOL isFirst = [[responders objectAtIndex:0] isFirstResponder];
	BOOL isLast = [[responders lastObject] isFirstResponder];
	[self.previousBarButtonItem setEnabled:!isFirst];
	[self.nextBarButtonItem setEnabled:!isLast];
}

- (void) willMoveToWindow:(UIWindow *)window
{
	if (!window)
		return;
	
	[self updateBarButtonItems];
}

- (void) textInputDidBeginEditing:(NSNotification *)notification
{
	[self updateBarButtonItems];
}

- (NSArray *) responders
{
	if (_responders)
		return _responders;
	
	NSArray *textInputs = EditableTextInputsInView([[UIApplication sharedApplication] keyWindow]);
	return [textInputs sortedArrayUsingComparator:^NSComparisonResult(UIView *textInput1, UIView *textInput2) {
		UIView *commonAncestorView = textInput1.superview;
		while (commonAncestorView && ![textInput2 isDescendantOfView:commonAncestorView])
			commonAncestorView = commonAncestorView.superview;
		
		CGRect frame1 = [textInput1 convertRect:textInput1.bounds toView:commonAncestorView];
		CGRect frame2 = [textInput2 convertRect:textInput2.bounds toView:commonAncestorView];
		return [@(CGRectGetMinY(frame1)) compare:@(CGRectGetMinY(frame2))];
	}];
}

- (UIResponder *) firstResponder
{
	NSArray *firstResponders = [self.responders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIResponder *responder, NSDictionary *bindings) {
		return [responder isFirstResponder];
	}]];
	UIResponder *firstResponder = [firstResponders lastObject];
	return firstResponder;
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
		items = [self.toolbar.items arrayByAddingObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)]];
	else
		items = [self.toolbar.items subarrayWithRange:NSMakeRange(0, 2)];
	
	[self.toolbar setItems:items animated:animated];
}

#pragma mark - Actions

- (void) selectAdjacentResponderAtIndex:(NSInteger)index
{
	UIResponder *firstResponder = [self firstResponder];
	NSInteger offset = index == 0 ? -1 : +1;
	NSInteger firstResponderIndex = [self.responders indexOfObject:firstResponder];
	NSInteger adjacentResponderIndex = firstResponderIndex != NSNotFound ? firstResponderIndex + offset : NSNotFound;
	UIResponder *adjacentResponder = nil;
	if (adjacentResponderIndex >= 0 && adjacentResponderIndex < (NSInteger)[self.responders count])
		adjacentResponder = [self.responders objectAtIndex:adjacentResponderIndex];
	
	// Resign the previous responder before selecting the next one, so the UIKeyboard events could be notified properly.
	[firstResponder resignFirstResponder];
	
	[adjacentResponder becomeFirstResponder];
}

- (void) previous:(UIBarButtonItem *)sender
{
	[self selectAdjacentResponderAtIndex:0];
}

- (void) next:(UIBarButtonItem *)sender
{
	[self selectAdjacentResponderAtIndex:1];
}

- (void) done
{
	UIResponder *firstResponder = [self firstResponder];
	[firstResponder resignFirstResponder];

	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

@end
