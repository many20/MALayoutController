//
//  MALayoutManager.m
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
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


#import "MALayoutManager.h"



@interface MALayoutManager (private)

- (void)changeLayoutOfView:(UIView *)view fromDictionary:(NSMutableDictionary *)layoutDictionary;
- (void)addLayoutFromView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary;
- (void)addLayoutFromAlternativeView:(UIView *)alternativeView forView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary;
- (void)removeLayoutFromView:(UIView *)view fromDictionary:(NSMutableDictionary *)dictionary;

@end



@implementation MALayoutManager

@synthesize layoutView = _layoutView;
@synthesize currentLayout;

@synthesize nibCaching;
@synthesize baseView;

- (id)init {
    if((self = [super init])) { 
        self.layoutView = nil;
        layouts = [[NSMutableDictionary alloc] initWithCapacity:2];
        currentLayout = @"";
        cachedNibName = @"";
        nibCaching = NO;
        baseView = NO;
    }
    return self;
}

- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view withBaseView:(BOOL)_baseView {
    assert(view != nil && layoutName != nil);
    if((self = [super init])) {   
        self.layoutView = view;
        layouts = [[NSMutableDictionary alloc] initWithCapacity:2];
        currentLayout = @"";
        cachedNibName = @"";
        nibCaching = NO;
        baseView = NO;
        
        if(view != nil) {            
            baseView = _baseView;
            
            [self addLayoutWithName:layoutName fromView:view];
        }
    }
    return self;
}

//### public methods

- (void)clear {
    self.layoutView = nil;
    [layouts removeAllObjects];
}

- (void)clearCache {
    cachedNibName = @"";
    cacheAlternativeViewArray = nil;
}

- (void)addLayoutWithName:(NSString *)layoutName fromView:(UIView *)view {
    assert(view != nil && layoutName != nil); 

#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutWithName:fromView:| name: %@; withBaseView:%@", layoutName, (baseView ? @"YES" : @"NO"));
#endif
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [layouts setObject:layoutDictionary forKey:layoutName];

    if (baseView == YES) {
        [self addLayoutFromView:view toDictionary:layoutDictionary]; 
    } else {
        for (UIView *subview in view.subviews) {
            [self addLayoutFromView:subview toDictionary:layoutDictionary]; 
        }        
    }    
}

- (void)addLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib {     
    [self addLayoutWithName:layoutName fromNib:nib withIndex:0];
}

- (void)addLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib withIndex:(int)index { 
    assert(nib != nil && layoutName != nil);
    
#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutWithName:fromNib:withIndex:| nib: %@; name: %@; index: %d; withBaseView:%@", nib, layoutName, index, (baseView ? @"YES" : @"NO"));
#endif
    
    UIView *alternativeView = nil;
    
    if ([cachedNibName isEqualToString:nib] == NO) {
        UIViewController *controller = [[UIViewController alloc] init];
        NSArray *alternativeViewArray = [[NSBundle mainBundle] loadNibNamed:nib owner:controller options:nil];
        alternativeView = [alternativeViewArray objectAtIndex:index];
        
        if (nibCaching == YES) {
            cachedNibName = nib;
            cacheAlternativeViewArray = alternativeViewArray;
        }
        
    } else {
        alternativeView = [cacheAlternativeViewArray objectAtIndex:index];
    }
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [layouts setObject:layoutDictionary forKey:layoutName];  
    
    if (baseView == YES) {
        [self addLayoutFromAlternativeView:alternativeView forView:self.layoutView toDictionary:layoutDictionary];
    } else {
        UIView *alternativeViewSubview = nil;
        UIView *layoutViewSubview = nil;    
        for (int i=0; i<self.layoutView.subviews.count; i++) {
            layoutViewSubview = [self.layoutView.subviews objectAtIndex:i];
            alternativeViewSubview = [alternativeView.subviews objectAtIndex:i];
            
            [self addLayoutFromAlternativeView:alternativeViewSubview forView:layoutViewSubview toDictionary:layoutDictionary];
        }
    }
}

- (void)removeLayoutWithName:(NSString *)layoutName { 
    [layouts removeObjectForKey:layoutName];
}
//Test
- (bool)addView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews { 
    assert(view != nil && layoutName != nil);
      
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    if (subviews == YES) {
        [self addLayoutFromView:view toDictionary:layoutDictionary]; 
    } else {        
        NSMutableDictionary *config = [NSMutableDictionary dictionary];
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
        //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
        //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];  
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
    }        
    return YES;
}
//test
- (bool)removeView:(UIView *)view fromLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews { 
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    if (subviews == YES) {
        [self removeLayoutFromView:view fromDictionary:layoutDictionary];
    }else {
        [layoutDictionary removeObjectForKey:[NSNumber numberWithInt:(int)view]];
    }
    return YES;
}
//test
- (void)removeViewFromLayoutManager:(UIView *)view withSubviews:(bool)subviews { 
    assert(view != nil);
    
    //View und subviews müssen aus viewarray entfernt werden
    if (subviews == YES) {
        for (NSMutableDictionary *layoutDictionary in layouts.allValues) {
            [self removeLayoutFromView:view fromDictionary:layoutDictionary]; 
        }
    }else {
        for (NSMutableDictionary *layoutDictionary in layouts.allValues) {
            [layoutDictionary removeObjectForKey:[NSNumber numberWithInt:(int)view]]; 
        }
    }
}

- (bool)setFrame:(CGRect)frame forView:(UIView *)view inLayoutWithName:(NSString *)layoutName { 
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config == nil) {    //gibt es noch nicht in dictionary       
        config = [NSMutableDictionary dictionary];
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
        //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
        //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];
        
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];           
    } else {
        [config removeObjectForKey:@"frame"];
        [config setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
    }
    return YES; 
}

- (bool)isValid {    
    
    return YES;
}

- (bool)changeToLayoutWithName:(NSString *)layoutName {
    assert([self isValid] == YES);
    
    if (currentLayout == layoutName) {
        return NO;
    }  
            
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil || self.layoutView == nil) {
        return NO;
    }
    
#ifdef DEBUG_MALAYOUTMANAGER       
    NSLog(@"changeToLayoutWithName:| %@ - %@", layoutName, layoutDictionary);
#endif
    
    [self changeLayoutOfView:self.layoutView fromDictionary:layoutDictionary];
    currentLayout = layoutName;

    return YES;
}
//Test
- (bool)changeFrameFromView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)withsubviews {
    assert([self isValid] == YES && view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue]; 
    //view.alpha = [(NSNumber *)[config objectForKey:@"alpha"] floatValue];
    //view.autoresizingMask = [(NSNumber *)[config objectForKey:@"autoresizingMask"] unsignedIntValue];
    
    [self changeLayoutOfView:self.layoutView fromDictionary:layoutDictionary];
    
    return YES;
}

//### private methods

- (void)changeLayoutOfView:(UIView *)view fromDictionary:(NSMutableDictionary *)layoutDictionary {
    assert(view != nil && layoutDictionary != nil);

#ifdef DEBUG_MALAYOUTMANAGER     
    CGRect rect = view.frame;
#endif
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config != nil) {
        view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue]; 
        //view.alpha = [(NSNumber *)[config objectForKey:@"alpha"] floatValue];
        //view.autoresizingMask = [(NSNumber *)[config objectForKey:@"autoresizingMask"] unsignedIntValue];

#ifdef DEBUG_MALAYOUTMANAGER        
        NSLog(@"changeLayoutOfView:fromDictionary:| from %@ to %@", NSStringFromCGRect(rect), NSStringFromCGRect(view.frame));
#endif
    }

    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self changeLayoutOfView:subview fromDictionary:layoutDictionary];
    }
}

- (void)addLayoutFromView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
	assert(view != nil && dictionary != nil);

    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
    //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
    //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];

#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutFromView:toDictionary:| %@", NSStringFromCGRect([(NSValue *)[config objectForKey:@"frame"] CGRectValue]));
#endif
    
	[dictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
	
    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self addLayoutFromView:subview toDictionary:dictionary];
    }
}

- (void)addLayoutFromAlternativeView:(UIView *)alternativeView forView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
	assert(alternativeView != nil && view != nil && dictionary != nil);
#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutFromAlternativeView:forView:toDictionary:| %d = %d; %@; %@",view.subviews.count, alternativeView.subviews.count, NSStringFromCGRect(view.frame), NSStringFromCGRect(alternativeView.frame));
#endif    
    assert(view.subviews.count == alternativeView.subviews.count);
        
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config setObject:[NSValue valueWithCGRect:alternativeView.frame] forKey:@"frame"];
    //[config setObject:[NSNumber numberWithFloat:alternativeView.alpha] forKey:@"alpha"];
    //[config setObject:[NSNumber numberWithUnsignedInt:alternativeView.autoresizingMask] forKey:@"autoresizingMask"];
    
	[dictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
	
    //NSMutableDictionary *tmp = [dictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    //NSLog(@"%@", NSStringFromCGRect([[tmp objectForKey:@"frame"]CGRectValue]));
    
    for (int i = 0; i < view.subviews.count; i++) {        
        UIView *subview = [view.subviews objectAtIndex:i];
        UIView *alternativeSubview = [alternativeView.subviews objectAtIndex:i];
        
        [self addLayoutFromAlternativeView:alternativeSubview forView:subview toDictionary:dictionary];
    }
}
//Test
- (void)removeLayoutFromView:(UIView *)view fromDictionary:(NSMutableDictionary *)dictionary {
	assert(view != nil && dictionary != nil);
    
	[dictionary removeObjectForKey:[NSNumber numberWithInt:(int)view]];
	
    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self removeLayoutFromView:subview fromDictionary:dictionary];
    }
}

@end
