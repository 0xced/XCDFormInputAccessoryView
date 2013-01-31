About
=====
`XCDFormInputAccessoryView` is a view to be used above the keyboard with *previous*, *next* and *done* buttons for navigating text fields.

![screenshot](Screenshots/XCDFormInputAccessoryView.png)

`XCDFormInputAccessoryView` uses ARC (Automatic Reference Counting) and must be built with Xcode 4.5 or greater. It has been tested on iOS 4, 5 and 6.

Usage
=====
In your `UIViewController` subclass, redeclare the `inputAccessoryView` property and create a new instance of `XCDFormInputAccessoryView`, for example in your `viewDidLoad` method:

	#import "XCDFormInputAccessoryView.h"
	
	@interface MyViewController ()
	@property (nonatomic, strong) XCDFormInputAccessoryView *inputAccessoryView;
	@end
	
	@implementation MyViewController
	- (void) viewDidLoad
	{
		[super viewDidLoad];
		self.inputAccessoryView = [XCDFormInputAccessoryView new];
	}
	@end

If you want to have total control over what the **Previous** and **Next** buttons do, you should initialize `XCDFormInputAccessoryView` with the `initWithResponders:` method instead and pass an array of `UIResponder` instances. If you do not supply an array of responders, then `XCDFormInputAccessoryView` uses the following heuristic to find which text input views will be used:

1. Find all text fields and editable text views in the key window
2. Sort them using their frame origin vertical position

License
=======
The MIT License (MIT)
Copyright (c) 2012 Cédric Luthi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.