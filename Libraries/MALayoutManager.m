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




/** Layout Manager
 *
 *  @author Mario Adrian
 *  @date 27.8.2012
 *
 *  @version 0.3
 *  
 *
 *  @todo add view property hidden
 *
 *
 */
@implementation MALayoutManager

- (id)init {
    if((self = [super init])) { 
        [self initProperty];
    }
    return self;
}

- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view withBaseView:(BOOL)baseView {
    assert(view != nil && layoutName != nil);
    if((self = [super init])) {   
        [self initProperty];
        self.layoutView = view;
        
        if(view != nil) {            
            _withBaseView = baseView;
            
            [self addLayoutWithName:layoutName fromView:view];
        }
    }
    return self;
}

- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view withBaseView:(BOOL)baseView dontAddSubviewsFromThisClasses:(NSArray *)classes {    
    assert(view != nil && layoutName != nil);
    if((self = [super init])) {
        [self initProperty];
        self.layoutView = view;
        _dontAddSubviewsFromThisClasses = classes;
        
        if(view != nil) {
            _withBaseView = baseView;
            
            [self addLayoutWithName:layoutName fromView:view];
        }
    }
    return self;
}

- (void)initProperty {
    self.layoutView = nil;
    _layouts = [[NSMutableDictionary alloc] initWithCapacity:2];
    _currentLayout = @"";
    _cachedNibName = @"";
    _nibCaching = NO;
    _withBaseView = NO;
    _dontAddSubviewsFromThisClasses = nil;
}

//### public methods

- (void)clear {
    self.layoutView = nil;
    [_layouts removeAllObjects];
}

- (void)clearCache {
    _cachedNibName = @"";
    _cacheAlternativeViewArray = nil;
}

- (void)addLayoutWithName:(NSString *)layoutName fromView:(UIView *)view {
    assert(view != nil && layoutName != nil); 

#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutWithName:fromView:| name: %@; withBaseView:%@", layoutName, (withBaseView ? @"YES" : @"NO"));
#endif
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [_layouts setObject:layoutDictionary forKey:layoutName];

    if (_withBaseView == YES) {
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
    NSLog(@"addLayoutWithName:fromNib:withIndex:| nib: %@; name: %@; index: %d; withBaseView:%@", nib, layoutName, index, (withBaseView ? @"YES" : @"NO"));
#endif
    
    UIView *alternativeView = nil;
    
    if ([_cachedNibName isEqualToString:nib] == NO) {
        UIViewController *controller = [[UIViewController alloc] init];
        NSArray *alternativeViewArray = [[NSBundle mainBundle] loadNibNamed:nib owner:controller options:nil];
        alternativeView = [alternativeViewArray objectAtIndex:index];
        
        if (_nibCaching == YES) {
            _cachedNibName = nib;
            _cacheAlternativeViewArray = alternativeViewArray;
        }
        
    } else {
        alternativeView = [_cacheAlternativeViewArray objectAtIndex:index];
    }
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [_layouts setObject:layoutDictionary forKey:layoutName];  
    
    if (_withBaseView == YES) {
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
/// @todo to test
- (void)copyLayoutWithName:(NSString *)layoutName toLayoutWithName:(NSString *)newLayoutName {
    assert(newLayoutName != nil && layoutName != nil); 
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    NSMutableDictionary *newlayoutDictionary = [NSMutableDictionary dictionaryWithCapacity:layoutDictionary.count];
           
    [layoutDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CGRect frame = [(NSValue *)[obj objectForKey:@"frame"] CGRectValue];
        
        NSNumber *tagObject = [obj objectForKey:@"tag"];
        NSInteger tag = 0;
        if (tagObject) {
            tag = [tagObject integerValue];
        }
        //float alpha = [(NSNumber *)[obj objectForKey:@"alpha"] floatValue];
        //unsigned int autoresizingMask = [(NSNumber *)[obj objectForKey:@"autoresizingMask"] unsignedIntValue];
                
        NSMutableDictionary *config = [NSMutableDictionary dictionary];
        [config setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
        if (tag != 0) {
            [config setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
        }
        //[config setObject:[NSNumber numberWithFloat:alpha] forKey:@"alpha"];
        //[config setObject:[NSNumber numberWithUnsignedInt:autoresizingMask] forKey:@"autoresizingMask"];  
        
        [newlayoutDictionary setObject:config forKey:key];        
    }];
     
    [_layouts setObject:newlayoutDictionary forKey:newLayoutName];
}

- (void)removeLayoutWithName:(NSString *)layoutName { 
    [_layouts removeObjectForKey:layoutName];
}
/// @todo to test
/// @return success YES or NO
- (bool)addView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews { 
    assert(view != nil && layoutName != nil);
      
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    if (subviews == YES) {
        [self addLayoutFromView:view toDictionary:layoutDictionary]; 
    } else {        
        NSMutableDictionary *config = [NSMutableDictionary dictionary];
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
        if (view.tag != 0) {
            [config setObject:[NSNumber numberWithInteger:view.tag] forKey:@"tag"];
        }
        //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
        //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];  
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
    }        
    return YES;
}
/// @todo to test
/// @return success YES or NO
- (bool)removeView:(UIView *)view fromLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews { 
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
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
/// @todo to test
- (void)removeViewFromLayoutManager:(UIView *)view withSubviews:(bool)subviews { 
    assert(view != nil);
    
    //View und subviews müssen aus viewarray entfernt werden
    if (subviews == YES) {
        for (NSMutableDictionary *layoutDictionary in _layouts.allValues) {
            [self removeLayoutFromView:view fromDictionary:layoutDictionary]; 
        }
    }else {
        for (NSMutableDictionary *layoutDictionary in _layouts.allValues) {
            [layoutDictionary removeObjectForKey:[NSNumber numberWithInt:(int)view]]; 
        }
    }
}

/// @return success YES or NO
- (bool)setFrame:(CGRect)frame forView:(UIView *)view inLayoutWithName:(NSString *)layoutName { 
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config == nil) {    //gibt es noch nicht in dictionary       
        config = [NSMutableDictionary dictionary];
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
        
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];           
    } else {
        [config removeObjectForKey:@"frame"];
        [config setObject:[NSValue valueWithCGRect:frame] forKey:@"frame"];
    }
    return YES; 
}

/// @return return the frame of the view from the layout
- (CGRect)getFramefromView:(UIView *)view inLayoutWithName:(NSString *)layoutName {
    assert(view != nil && layoutName != nil);
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return frame;
    }
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config != nil) {
        frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue]; 
    }
    return frame;
}

/// @return success YES or NO
- (bool)deleteFramefromView:(UIView *)view inLayoutWithName:(NSString *)layoutName {
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config == nil) {    //gibt es noch nicht in dictionary
        return NO;
    } else {
        [config removeObjectForKey:@"frame"];
    }
    return YES;
}

/// @todo to test
/// @return success YES or NO
- (bool)setTag:(int)tag forView:(UIView *)view inLayoutWithName:(NSString *)layoutName {
    assert(view != nil && layoutName != nil);
    
    //tag NULL should not be stored 
    if (tag == 0) {
        return NO;
    }
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config == nil) {    //gibt es noch nicht in dictionary
        config = [NSMutableDictionary dictionary];
        [config setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
        
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
    } else {
        [config removeObjectForKey:@"tag"];
        [config setObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
    }
    return YES;
}

/// @todo to test
- (int)getTagfromView:(UIView *)view inLayoutWithName:(NSString *)layoutName {
    assert(view != nil && layoutName != nil);
    
    int tag = 0;
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return tag;
    }
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config != nil) {
        NSNumber *tagObject = [config objectForKey:@"tag"];
        if (tagObject) {
            tag = [tagObject integerValue];
        }
    }
    return tag;
}

/// @todo to test
/// @return success YES or NO
- (bool)deleteTagfromView:(UIView *)view inLayoutWithName:(NSString *)layoutName {
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config == nil) {    //gibt es noch nicht in dictionary
        return NO;
    } else {
        [config removeObjectForKey:@"tag"];
    }
    return YES;
}

/// @todo implement test if valid
- (bool)isValid {    
    
    return YES;
}

/// @return success YES or NO
- (bool)changeToLayoutWithName:(NSString *)layoutName {
    assert([self isValid] == YES);
    
    /*if (currentLayout == layoutName) {
        return NO;
    }*/
            
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil || self.layoutView == nil) {
        return NO;
    }
    
#ifdef DEBUG_MALAYOUTMANAGER       
    NSLog(@"changeToLayoutWithName:| %@ - %@", layoutName, layoutDictionary);
#endif
    
    [self changeLayoutOfView:self.layoutView fromDictionary:layoutDictionary];
    _currentLayout = layoutName;

    return YES;
}
/// @todo to test
/// @return success YES or NO
- (bool)changeFrameFromView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)withsubviews {
    assert([self isValid] == YES && view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [_layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue];
    
    NSNumber *tagObject = [config objectForKey:@"tag"];
    if (tagObject) {
        view.tag = [tagObject integerValue];
    }
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
    NSInteger oldTag = view.tag;
#endif
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config != nil) {
        view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue];
        NSNumber *tagObject = [config objectForKey:@"tag"];
        if (tagObject) {
            view.tag = [tagObject integerValue];
        }
        //view.alpha = [(NSNumber *)[config objectForKey:@"alpha"] floatValue];
        //view.autoresizingMask = [(NSNumber *)[config objectForKey:@"autoresizingMask"] unsignedIntValue];

#ifdef DEBUG_MALAYOUTMANAGER
        //only view info if something changed
        if ((rect.origin.x != view.frame.origin.x) || (rect.origin.y != view.frame.origin.y) || (rect.size.height != view.frame.size.height) || (rect.size.width != view.frame.size.width)) {
            NSLog(@"changeLayoutOfView:fromDictionary:| from %@ to %@", NSStringFromCGRect(rect), NSStringFromCGRect(view.frame));   
        }
        if (oldTag != view.tag) {
            NSLog(@"from tag: %d to %d", oldTag, view.tag);
        }
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
    //tag NULL should not be stored
    if (view.tag != 0) {
        [config setObject:[NSNumber numberWithInteger:view.tag] forKey:@"tag"];
    }
    //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
    //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];

#ifdef DEBUG_MALAYOUTMANAGER
    NSLog(@"addLayoutFromView:toDictionary:| %@", NSStringFromCGRect([(NSValue *)[config objectForKey:@"frame"] CGRectValue]));
#endif
    
	[dictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
	
    //UIButtons option "Shows touch on hightlight" uses a extra View, that makes problems.
    for (Class class in _dontAddSubviewsFromThisClasses) {
        if([view isMemberOfClass:class] == YES) {
            return;
        }
    }
                
    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self addLayoutFromView:subview toDictionary:dictionary];        
    }    
}

- (void)addLayoutFromAlternativeView:(UIView *)alternativeView forView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
	assert(alternativeView != nil && view != nil && dictionary != nil);   
            
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config setObject:[NSValue valueWithCGRect:alternativeView.frame] forKey:@"frame"];
    if (alternativeView.tag != 0) {
        [config setObject:[NSNumber numberWithInteger:alternativeView.tag] forKey:@"tag"];
    }
    //[config setObject:[NSNumber numberWithFloat:alternativeView.alpha] forKey:@"alpha"];
    //[config setObject:[NSNumber numberWithUnsignedInt:alternativeView.autoresizingMask] forKey:@"autoresizingMask"];
    
	[dictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
	
    //NSMutableDictionary *tmp = [dictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    //NSLog(@"%@", NSStringFromCGRect([[tmp objectForKey:@"frame"]CGRectValue]));
    
    //UIButtons option "Shows touch on hightlight" uses a extra View, that makes problems.
    for (Class class in _dontAddSubviewsFromThisClasses) {
        if([view isMemberOfClass:class] == YES) {
            return;
        }
    }
       
#ifdef DEBUG_MALAYOUTMANAGER
    //only view info if there is an error
    if (view.subviews.count != alternativeView.subviews.count) {
        NSLog(@"addLayoutFromAlternativeView:forView:toDictionary:| %d = %d; %@; %@",view.subviews.count, alternativeView.subviews.count, NSStringFromCGRect(view.frame), NSStringFromCGRect(alternativeView.frame));
        NSLog(@"viewClass1: %@ description: %@", NSStringFromClass([view class]), view.description);
        NSLog(@"viewClass2: %@ description: %@", NSStringFromClass([alternativeView class]), alternativeView.description);
    }
#endif
    assert(view.subviews.count == alternativeView.subviews.count);
    
    for (int i = 0; i < view.subviews.count; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];        
        UIView *alternativeSubview = [alternativeView.subviews objectAtIndex:i];
        
        [self addLayoutFromAlternativeView:alternativeSubview forView:subview toDictionary:dictionary];        
    }
}
/// @todo to test
- (void)removeLayoutFromView:(UIView *)view fromDictionary:(NSMutableDictionary *)dictionary {
	assert(view != nil && dictionary != nil);
    
	[dictionary removeObjectForKey:[NSNumber numberWithInt:(int)view]];
	
    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self removeLayoutFromView:subview fromDictionary:dictionary];
    }
}

@end
