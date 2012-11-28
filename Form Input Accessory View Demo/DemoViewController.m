//
//  DemoViewController.m
//  Form Accessory View Demo
//
//  Created by Cédric Luthi on 10.11.12.
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import "DemoViewController.h"

#import "XCDFormInputAccessoryView.h"

@implementation DemoViewController
{
	XCDFormInputAccessoryView *_inputAccessoryView;
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
	
	UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeScreenshot:)];
	tapGestureRecognizer2.numberOfTapsRequired = 2;
	UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeScreenshot:)];
	tapGestureRecognizer3.numberOfTapsRequired = 3;
	[tapGestureRecognizer2 requireGestureRecognizerToFail:tapGestureRecognizer3];
	[self.view addGestureRecognizer:tapGestureRecognizer2];
	[self.view addGestureRecognizer:tapGestureRecognizer3];
}

- (void) takeScreenshot:(UITapGestureRecognizer *)gestureRecognizer
{
	CGFloat scale = gestureRecognizer.numberOfTapsRequired - 1.0f;
	UIGraphicsBeginImageContextWithOptions(self.inputAccessoryView.frame.size, NO, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.inputAccessoryView.layer renderInContext:context];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	[[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
	NSString *scaleString = scale != 1.f ? [NSString stringWithFormat:@"@%gx", scale] : @"";
	NSString *screenshotName = [NSString stringWithFormat:@"%@%@.png", [[self inputAccessoryView] class], scaleString];
	NSString *screenshotPath = [documentsDirectory stringByAppendingPathComponent:screenshotName];
	[UIImagePNGRepresentation(screenshot) writeToFile:screenshotPath atomically:YES];
	system([[NSString stringWithFormat:@"open \"%@\"", screenshotPath] fileSystemRepresentation]);
}

- (UIView *) inputAccessoryView
{
	if (!_inputAccessoryView)
	{
		_inputAccessoryView = [[XCDFormInputAccessoryView alloc] initWithResponders:self.textInputs];
		//_inputAccessoryView = [[XCDFormInputAccessoryView alloc] init];
		//_inputAccessoryView = [[NSClassFromString(@"UIWebFormAccessory") alloc] init];
	}
	return _inputAccessoryView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.row == 2 ? 200 : tableView.rowHeight;
}

@end
