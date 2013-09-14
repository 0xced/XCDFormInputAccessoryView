//
//  DemoViewController.h
//  Form Accessory View Demo
//
//  Created by Cédric Luthi on 10.11.12.
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

@interface DemoViewController : UITableViewController

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *textInputs;

- (IBAction)selectNextResponder:(id)sender;

@end
