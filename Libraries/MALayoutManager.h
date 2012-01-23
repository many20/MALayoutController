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

- (id)init;
- (id)initWithView:(UIView *)view;

- (bool)addLayoutFromView:(UIView *)view inLayout:(int)number;
- (bool)addLayoutFromNib:(NSString *)nib inLayout:(int)number;
- (bool)removeLayout:(int)number;

- (bool)addFrame:(CGRect *)frame forNewView:(UIView *)view inLayout:(int)number;
- (bool)setFrame:(CGRect *)frame forView:(UIView *)view inLayout:(int)number;
- (bool)removeFrame:(CGRect *)frame forView:(UIView *)view inLayout:(int)number;
- (bool)isValid;

- (bool)changeLayoutToNumber:(int)number;

@end
