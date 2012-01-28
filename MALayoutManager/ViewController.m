//
//  ViewController.m
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MALayoutManager.h"


@implementation ViewController

MALayoutManager *layoutManager;
int value;
UIView *newView;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    layoutManager = [[MALayoutManager alloc] initLayoutWithName:@"portraiLayout1" fromView:self.view];
    [layoutManager addNewLayoutWithName:@"landscapeLayout1" fromNib:@"ViewController_iPhone_layout2"];
    [layoutManager addNewLayoutWithName:@"portraiLayout2" fromView:self.view];
    [layoutManager addNewLayoutWithName:@"landscapeLayout2" fromNib:@"ViewController_iPhone_layout3"];
    [layoutManager addNewLayoutWithName:@"landscapeLayout3" fromNib:@"ViewController_iPhone_layout3" withIndex:1];
    
    [layoutManager setFrame:(CGRect){outletView1.frame.origin, {50, 100}} forView:outletView1 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:(CGRect){outletView2.frame.origin, {100, 50}} forView:outletView2 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:CGRectOffset(outletView3.frame, 40, 40) forView:outletView3 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:CGRectMake(0, 20, 60, 70) forView:outletView4 inLayoutWithName:@"portraiLayout2"];
    
    newView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 100, 100)];
    
    [self.view addSubview:newView];
    [layoutManager addView:newView toLayoutWithName:@"portraiLayout1" withSubviews:NO];
    [layoutManager setFrame:CGRectMake(0, 0, 100, 100) forView:newView inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 300, 100, 100) forView:newView inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 0, 100, 100) forView:newView inLayoutWithName:@"portraiLayout1"];
    
    value = 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [layoutManager changeToLayoutWithName:@"landscapeLayout1"];
    } else {
        [layoutManager changeToLayoutWithName:@"portraiLayout1"];
    }
}

- (IBAction)layoutAction1:(id)sender {
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
        [UIView animateWithDuration:1.0 animations:^{
            [layoutManager changeToLayoutWithName:@"landscapeLayout1"];
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [layoutManager changeToLayoutWithName:@"portraiLayout1"];

            value++;
            switch (value) {
                case 2:
                    [layoutManager removeView:newView fromLayoutWithName:@"portraiLayout1"];
                    break;    
                case 4:
                    [layoutManager removeViewFromLayoutManager:newView];
                    break;
                case 6:
                    [layoutManager removeLayoutWithName:@"portraiLayout1"];
                    break;
            }
        }];
    }
}

- (IBAction)layoutAction2:(id)sender {
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
        [UIView animateWithDuration:1.0 animations:^{
            if (layoutManager.currentLayout == @"landscapeLayout2") {
                [layoutManager changeToLayoutWithName:@"landscapeLayout3"];
                [layoutManager removeLayoutWithName:@"landscapeLayout3"];
            } else {
                [layoutManager changeToLayoutWithName:@"landscapeLayout2"];
            }
        }];
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            [layoutManager changeToLayoutWithName:@"portraiLayout2"];
        }];
    }
}
@end
