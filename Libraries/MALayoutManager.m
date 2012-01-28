//
//  MALayoutManager.m
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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

    NSMutableDictionary *layouts = nil;

- (id)init {
    if((self = [super init])) { 
        layouts = [[NSMutableDictionary alloc] initWithCapacity:2];
        currentLayout = nil;
    }
    return self;
}

- (id)initLayoutWithName:(NSString *)layoutName fromView:(UIView *)view {
    if((self = [super init])) {   
        self.layoutView = view;
        layouts = [[NSMutableDictionary alloc] initWithCapacity:2];
         
        if(view != nil) {
            [self addNewLayoutWithName:layoutName fromView:view];
            currentLayout = layoutName;
        }
    }
    return self;
}

//### public methods

- (void)clear {
    self.layoutView = nil;
    [layouts removeAllObjects];
}

- (void)addNewLayoutWithName:(NSString *)layoutName fromView:(UIView *)view {
    assert(view != nil && layoutName != nil); 
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [layouts setObject:layoutDictionary forKey:layoutName];
    
    for (UIView *subview in view.subviews) {
        [self addLayoutFromView:subview toDictionary:layoutDictionary]; 
    }
}

- (void)addNewLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib {     
    [self addNewLayoutWithName:layoutName fromNib:nib withIndex:0];
}

- (void)addNewLayoutWithName:(NSString *)layoutName fromNib:(NSString *)nib withIndex:(int)index { 
    assert(nib != nil && layoutName != nil);
        
    UIViewController *controller = [[UIViewController alloc] init];           
    UIView *alternativeView = [[[NSBundle mainBundle] loadNibNamed:nib owner:controller options:nil] objectAtIndex:index];
    
    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
    [layouts setObject:layoutDictionary forKey:layoutName];  
    
    UIView *alternativeViewSubview = nil;
    UIView *layoutViewSubview = nil;    
    for (int i=0; i<self.layoutView.subviews.count; i++) {
        layoutViewSubview = [self.layoutView.subviews objectAtIndex:i];
        alternativeViewSubview = [alternativeView.subviews objectAtIndex:i];
        
        [self addLayoutFromAlternativeView:alternativeViewSubview forView:layoutViewSubview toDictionary:layoutDictionary];
    }
}
//Test
- (void)removeLayoutWithName:(NSString *)layoutName { 
    [layouts removeObjectForKey:layoutName];
}
//Test
- (bool)addView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)subviews { 
    assert(view != nil && layoutName != nil);
      
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    
    if ([layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]] != nil) {  //gibt es schon
        return NO;
    }
    
    if (subviews == YES) {
        [self addLayoutFromView:view toDictionary:layoutDictionary]; 
    } else {
        NSMutableDictionary *config = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"frame",
                                       [NSValue valueWithCGRect:view.frame],
                                       //@"alpha",
                                       //[NSNumber numberWithFloat:view.alpha],
                                       //@"autoresizingMask",
                                       //[NSNumber numberWithUnsignedInt:view.autoresizingMask],
                                       nil];
        [layoutDictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
    }
        
    return YES;
}
//Test
- (void)removeView:(UIView *)view fromLayoutWithName:(NSString *)layoutName { 
    assert(view != nil && layoutName != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    [self removeLayoutFromView:view fromDictionary:layoutDictionary]; 
}
//TODO
- (void)removeViewFromLayoutManager:(UIView *)view { 
    assert(view != nil);
    
    //View und subviews müssen aus viewarray entfernt werden
  
    for (NSMutableDictionary *layoutDictionary in layouts.allValues) {
        [self removeLayoutFromView:view fromDictionary:layoutDictionary]; 
    }
}
//TODO:
- (bool)setFrame:(CGRect)frame forView:(UIView *)view inLayoutWithName:(NSString *)layoutName { 
    assert([layouts objectForKey:layoutName] != nil && view != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    NSMutableDictionary *config = [layoutDictionary objectForKey:view];
    if (config == nil) {    //den view gibt es noch nicht in dictionary       
        config = [NSMutableDictionary dictionaryWithCapacity:3];
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
        //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
        //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];
        
        [layoutDictionary setObject:config forKey:view];   
    } else {
        [config removeObjectForKey:@"frame"]; 
        [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];    
    }
    return YES; 
}

- (bool)isValid {    
    
    return YES;
}

- (bool)changeToLayoutWithName:(NSString *)layoutName {
    assert([self isValid] == YES);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil || self.layoutView == nil) {
        return NO;
    }
       
    //NSLog(@" %@ - %@", layoutName, layoutDictionary);
    
    [self changeLayoutOfView:self.layoutView fromDictionary:layoutDictionary];
    currentLayout = layoutName;
    
    return YES;
}
//Test
- (bool)changeFrameFromView:(UIView *)view toLayoutWithName:(NSString *)layoutName withSubviews:(bool)withsubviews {
    assert([self isValid] == YES && view != nil);
    
    NSMutableDictionary *layoutDictionary = [layouts objectForKey:layoutName];
    if (layoutDictionary == nil) {
        return NO;
    }
    
    if (withsubviews == YES) {
        [self changeLayoutOfView:self.layoutView fromDictionary:layoutDictionary];
    } else {
        NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
        view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue]; 
        //view.alpha = [(NSNumber *)[config objectForKey:@"alpha"] floatValue];
        //view.autoresizingMask = [(NSNumber *)[config objectForKey:@"autoresizingMask"] unsignedIntValue];
    }
    
    return YES;
}

//### private methods

- (void)changeLayoutOfView:(UIView *)view fromDictionary:(NSMutableDictionary *)layoutDictionary {
    assert(view != nil && layoutDictionary != nil);
    
    //CGRect rect = view.frame;
    
    NSMutableDictionary *config = [layoutDictionary objectForKey:[NSNumber numberWithInt:(int)view]];
    if (config != nil) {
        view.frame = [(NSValue *)[config objectForKey:@"frame"] CGRectValue]; 
        //view.alpha = [(NSNumber *)[config objectForKey:@"alpha"] floatValue];
        //view.autoresizingMask = [(NSNumber *)[config objectForKey:@"autoresizingMask"] unsignedIntValue];
        
        //NSLog(@"from %@ to %@", NSStringFromCGRect(rect), NSStringFromCGRect(view.frame));
    }

    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self changeLayoutOfView:subview fromDictionary:layoutDictionary];
    }
}

- (void)addLayoutFromView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
	assert(view != nil && dictionary != nil);

    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithCapacity:3];
    [config setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
    //[config setObject:[NSNumber numberWithFloat:view.alpha] forKey:@"alpha"];
    //[config setObject:[NSNumber numberWithUnsignedInt:view.autoresizingMask] forKey:@"autoresizingMask"];
    
    //NSLog(@"%@", NSStringFromCGRect([(NSValue *)[config objectForKey:@"frame"] CGRectValue]));
    
	[dictionary setObject:config forKey:[NSNumber numberWithInt:(int)view]];
	
    for (int i = 0; i < [view.subviews count]; i++) {
        UIView *subview = [view.subviews objectAtIndex:i];
        
        [self addLayoutFromView:subview toDictionary:dictionary];
    }
}

- (void)addLayoutFromAlternativeView:(UIView *)alternativeView forView:(UIView *)view toDictionary:(NSMutableDictionary *)dictionary {
	assert(alternativeView != nil && view != nil && dictionary != nil);
    assert(view.subviews.count == alternativeView.subviews.count);
    
    //NSLog(@"%@ - %@", NSStringFromCGRect(alternativeView.frame), NSStringFromCGRect(view.frame));
    
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithCapacity:3];
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
