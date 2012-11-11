//
//  XCDFormAccessoryView.h
//
//  Created by Cédric Luthi on 2012-11-10
//  Copyright (c) 2012 Cédric Luthi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCDFormAccessoryView : UIView

- (id) initWithResponders:(NSArray *)responders;

@property (nonatomic, readonly) NSArray *responders;

@end
