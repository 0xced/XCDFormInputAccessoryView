//
//  DemoViewController.m
//  Form Accessory View Demo
//
//  Created by Cédric Luthi on 10.11.12.
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import "DemoViewController.h"

#import "XCDFormAccessoryView.h"

@implementation DemoViewController
{
	UIView *_inputAccessoryView;
}

- (void) setTextInputs:(NSArray *)textInputs
{
	// Some day, IBOutletCollection will be properly sorted, in the meantime, sort it!
	_textInputs = [textInputs sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
		return [@(view1.tag) compare:@(view2.tag)];
	}];
}

- (void) viewDidLoad
{
	for (UIView *textInput in self.textInputs)
	{
		UIView *view = [textInput isKindOfClass:[UITextField class]] ? textInput.superview : textInput;
		view.layer.borderColor = [UIColor grayColor].CGColor;
		view.layer.borderWidth = 1;
		view.layer.cornerRadius = 8;
	}
}

- (UIView *) inputAccessoryView
{
	if (!_inputAccessoryView)
	{
		_inputAccessoryView = [[XCDFormAccessoryView alloc] initWithResponders:self.textInputs];
		//_inputAccessoryView = [[XCDFormAccessoryView alloc] init];
		//_inputAccessoryView = [[NSClassFromString(@"UIWebFormAccessory") alloc] init];
	}
	return _inputAccessoryView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.row == 2 ? 200 : tableView.rowHeight;
}

@end
