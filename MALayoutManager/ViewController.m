//
//  ViewController.m
//  MALayoutManager
//
//  Created by Mario Adrian on 23.01.12.
//  
//

#import "ViewController.h"
#import "MALayoutManager.h"


@implementation ViewController

MALayoutManager *layoutManager;
int value;
UIView *newView1;
UIView *newView2;
UIView *newSubview1;
UIView *newSubview2;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    layoutManager = [[MALayoutManager alloc] initLayoutWithName:@"portraiLayout1" fromView:self.view withBaseView:NO dontAddSubviewsFromThisClasses:[NSArray arrayWithObjects:UIButton.class, nil]];
    [layoutManager addLayoutWithName:@"landscapeLayout1" fromNib:@"ViewController_iPhone_layout2"];
    [layoutManager addLayoutWithName:@"portraiLayout2" fromView:self.view];
    
    //[layoutManager addLayoutsFromNibWithCaching:YES];
    
    [layoutManager addLayoutWithName:@"landscapeLayout2" fromNib:@"ViewController_iPhone_layout3"];
    [layoutManager addLayoutWithName:@"landscapeLayout3" fromNib:@"ViewController_iPhone_layout3" withIndex:1];
    
    //[layoutManager clearCache];
    
    [layoutManager setFrame:(CGRect){outletView1.frame.origin, {50, 100}} forView:outletView1 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:(CGRect){outletView2.frame.origin, {100, 50}} forView:outletView2 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:CGRectOffset(outletView3.frame, 40, 40) forView:outletView3 inLayoutWithName:@"portraiLayout2"];
    [layoutManager setFrame:CGRectMake(0, 20, 60, 70) forView:outletView4 inLayoutWithName:@"portraiLayout2"];
    
    newView1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 100, 100)];
    [layoutManager setFrame:CGRectMake(0, 0, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 300, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 0, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    
    value = 0;
    
    
    
    //### Tests
    
    /*
    newView1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 100, 100)];
    newView1.backgroundColor = [UIColor blackColor];
    newView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 100, 100)];
    newView2.backgroundColor = [UIColor brownColor];
    newSubview1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 60, 60)];
    newSubview1.backgroundColor = [UIColor yellowColor];
    newSubview2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX([[UIScreen mainScreen] applicationFrame]), CGRectGetMidY([[UIScreen mainScreen] applicationFrame]), 20, 20)];
    newSubview2.backgroundColor = [UIColor redColor];
    
    [newView1 addSubview:newSubview1];
    [newView2 addSubview:newSubview2];
    [self.view addSubview:newView1];
    [self.view addSubview:newView2];
    
    if ([layoutManager addView:newView1 toLayoutWithName:@"portraiLayout1" withSubviews:NO]) {
        NSLog(@"add one");
    }
    if ([layoutManager addView:newView1 toLayoutWithName:@"portraiLayout1" withSubviews:NO]) {
        NSLog(@"add the some");
    }
    
    if ([layoutManager addView:newView2 toLayoutWithName:@"portraiLayout1" withSubviews:YES]) {
        NSLog(@"add one");
    }
    if ([layoutManager addView:newView2 toLayoutWithName:@"portraiLayout1" withSubviews:YES]) {
        NSLog(@"add the some");
    }
     
    [layoutManager setFrame:CGRectMake(0, 0, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 300, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    [layoutManager setFrame:CGRectMake(300, 0, 100, 100) forView:newView1 inLayoutWithName:@"portraiLayout1"];
    
    newSubview1.frame = CGRectMake(0, 0, 30, 70);
    newSubview2.frame = CGRectMake(0, 0, 30, 70);
    
    if ([layoutManager addView:newSubview1 toLayoutWithName:@"portraiLayout1" withSubviews:NO]) {
        NSLog(@"add modivied subview1 for portraiLayout1");
    }
    if ([layoutManager addView:newSubview2 toLayoutWithName:@"portraiLayout1" withSubviews:NO]) {
        NSLog(@"add modivied subview2 for portraiLayout1");
    }
    if ([layoutManager addView:newSubview1 toLayoutWithName:@"portraiLayout2" withSubviews:NO]) {
        NSLog(@"add modivied subview1 for portraiLayout2");
    }
    if ([layoutManager addView:newSubview2 toLayoutWithName:@"portraiLayout2" withSubviews:NO]) {
        NSLog(@"add modivied subview2 for portraiLayout2");
    }
    */
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [layoutManager clear];
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
                    [layoutManager removeView:newView1 fromLayoutWithName:@"portraiLayout1" withSubviews:NO];
                    break;
                case 3:
                    //reverse action
                    [layoutManager removeView:newView1 fromLayoutWithName:@"portraiLayout1" withSubviews:YES];
                    break;  
                case 4:
                    [layoutManager removeViewFromLayoutManager:newView1 withSubviews:NO];
                    break;
                case 5:
                    //reverse action
                    [layoutManager removeViewFromLayoutManager:newView1 withSubviews:YES];
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
            if ([layoutManager.currentLayout isEqualToString:@"landscapeLayout2"]) {
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
