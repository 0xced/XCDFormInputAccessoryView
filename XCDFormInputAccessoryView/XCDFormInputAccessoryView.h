//
//  XCDFormInputAccessoryView.h
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XCDFormInputAccessoryViewChangeBlock)(UIResponder *newFirstResponder);

@interface XCDFormInputAccessoryView : UIView

- (id) initWithResponders:(NSArray *)responders; // Objects must be UIResponder instances

@property (nonatomic, strong) NSArray *responders;

@property (nonatomic, assign) BOOL hasDoneButton; // Defaults to YES on iPhone, NO on iPad

@property (nonatomic, copy) XCDFormInputAccessoryViewChangeBlock changeBlock;

- (void) setHasDoneButton:(BOOL)hasDoneButton animated:(BOOL)animated;

@end
