//
//  MALayoutManager.h
//  MALayoutManager
//
// Created by Mario Adrian on 23.01.12.
//
// Copyright (c) 2011 Mario Adrian (http://ma-source.de/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MALayoutManager : NSObject

@property (nonatomic, weak) UIView *layoutView;
@property (nonatomic, strong, readonly) NSString* currentLayout;

- (id)init;
- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view;

- (void)clear;

- (void)addLayoutsFromNibWithCaching:(BOOL)caching;
- (void)clearCache;

- (void)addLayoutWithName:(NSString *)layoutName fromView:(UIView *)view;
- (void)addLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib;
- (void)addLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib withIndex:(int)index;
- (void)removeLayoutWithName:(NSString *)layoutName;

- (bool)addView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews;
- (bool)removeView:(UIView *)view fromLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews ;
- (void)removeViewFromLayoutManager:(UIView *)view withSubviews:(bool)subviews;

- (bool)setFrame:(CGRect)frame forView:(UIView *)view inLayoutWithName:(NSString *)layoutName;

- (bool)isValid;

- (bool)changeToLayoutWithName:(NSString *)layoutName;
- (bool)changeFrameFromView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)withsubviews;

@end
