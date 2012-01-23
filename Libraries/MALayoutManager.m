//
//  MALayoutManager.m
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MALayoutManager.h"



@interface MALayoutManager (privat)

- (bool)addLayoutFromView:(UIView *)view inDictionary:(NSMutableDictionary *)dictionary;

@end



@implementation MALayoutManager

    NSMutableArray *layoutsArray = nil;

- (id)init {
    if((self = [super init])) {    
        layoutsArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    if((self = [super init])) {        
        layoutsArray = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];
        [layoutsArray addObject:layoutDictionary];
        
        [self addLayoutFromView:view inDictionary:layoutDictionary];
        
    }
    return self;
}

- (bool)addLayoutFromView:(UIView *)view inDictionary:(NSMutableDictionary *)dictionary {    
    if (view == nil) { 
        return NO; 
    } 
    
    
    [dictionary removeAllObjects];

    //TODO

    
    return NO;
}

- (bool)addLayoutFromView:(UIView *)view inLayout:(int)number {
    if (layoutsArray.count >= number) { 
        return NO; 
    }   
    
    return [self addLayoutFromView:view inDictionary:[layoutsArray objectAtIndex:number]]; 
}

- (bool)addLayoutFromNib:(NSString *)nib inLayout:(int)number { 
    if (layoutsArray.count >= number) { 
        return NO; 
    }
    
    UIView *view; 
    
    
    return [self addLayoutFromView:view inDictionary:[layoutsArray objectAtIndex:number]];
}

- (bool)removeLayout:(int)number { 
    if (layoutsArray.count >= number) { 
        return NO; 
    }
    
    [layoutsArray removeObjectAtIndex:number];
    
    return YES;
}

- (bool)addFrame:(CGRect *)frame forNewView:(UIView *)view inLayout:(int)number { 
    if (layoutsArray.count >= number || view == nil) { 
        return NO; 
    }
    
    NSMutableDictionary *layoutDictionary = [layoutsArray objectAtIndex:number];
    
    
    return NO;
}

- (bool)setFrame:(CGRect *)frame forView:(UIView *)view inLayout:(int)number { 
    if (layoutsArray.count >= number || view == nil) { 
        return NO; 
    }
    
    NSMutableDictionary *layoutDictionary = [layoutsArray objectAtIndex:number];
    
    
    return NO;
}

- (bool)removeFrame:(CGRect *)frame forView:(UIView *)view inLayout:(int)number { 
    if (layoutsArray.count >= number || view == nil) { 
        return NO; 
    }
    
    NSMutableDictionary *layoutDictionary = [layoutsArray objectAtIndex:number];
    
    
    return NO;
}

- (bool)isValid {
    //min two layouts
    if (layoutsArray.count <= 1) {
        return NO;
    }
    
    NSMutableDictionary *layoutDictionary1 = [layoutsArray objectAtIndex:0];
    NSMutableDictionary *layoutDictionary2 = nil;
    
    for (int i=1; i<layoutsArray.count; i++) {
        layoutDictionary2 = [layoutsArray objectAtIndex:i];
        
        if (layoutDictionary1.count != layoutDictionary2.count) {
            return NO;
        }
        layoutDictionary1 = layoutDictionary2;
    }
    
    return YES;
}

- (bool)changeLayoutToNumber:(int)number {
    if (layoutsArray.count >= number || [self isValid] == NO) { 
        return NO; 
    }
    
    NSMutableDictionary *layoutDictionary = [layoutsArray objectAtIndex:number];
    
    
    return NO;
}


@end
