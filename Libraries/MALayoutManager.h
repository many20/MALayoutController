//
//  MALayoutManager.h
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MALayoutManager : NSObject

@property (nonatomic, weak) UIView *layoutView;
@property (nonatomic, strong, readonly) NSString* currentLayout;

- (id)init;
- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view;

- (void)clear;

- (void)addNewLayoutWithName:(NSString *)layoutName fromView:(UIView *)view;
- (void)addNewLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib;
- (void)addNewLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib withIndex:(int)index;
- (void)removeLayoutWithName:(NSString *)layoutName;

- (bool)addView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews;
- (void)removeView:(UIView *)view fromLayoutWithName:(NSString *)layoutName;
- (void)removeViewFromLayoutManager:(UIView *)view;
- (bool)setFrame:(CGRect)frame forView:(UIView *)view inLayoutWithName:(NSString *)layoutName;

- (bool)isValid;

- (bool)changeToLayoutWithName:(NSString *)layoutName;
- (bool)changeFrameFromView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)withsubviews;

@end
