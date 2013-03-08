//
//  FBViewController.m
//  FramedScrollableViewTest
//
//  Created by Frederic Barthelemy on 3/8/13.
//  Copyright (c) 2013 Mobage. All rights reserved.
//

#import "FBViewController.h"
#import "FBAppDelegate.h"
#import "FBFramedScrollableView.h"

@interface FBTestBorderView : UIView<FBViewFrameComponent>
@property (nonatomic, readwrite, assign) BOOL invertHidingStyle;
@end
@implementation FBTestBorderView

- (FBViewFrameHidingStyle)hidingStyle
{
	// Snap our header/footer back into place if you scroll back up.
	return FBViewFrameHidingStyleFollowPopBack;
}
- (CGSize)minSize
{
	// Define that the minimum visible height for our header/footer will be 10 pixels
	return CGSizeMake(0,10);
}

@end

// Simple implementation of a subclass with a contained webview.
@interface FBFramedWebView : FBFramedScrollableView
@end
@implementation FBFramedWebView
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])){
		self.contentView = [[UIWebView alloc] initWithFrame:frame];
	}
	return self;
}

@end

@interface FBViewController ()

@end

@implementation FBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
	UIScrollView * tmp;
	
	UIImageView * ti = [[UIImageView alloc] initWithFrame:tmp.bounds];
	ti.image = [UIImage imageNamed:@"hellfire_shot.jpg"];
	
	// Make our base view be a plain UIView.
	self.view = [[UIView alloc] initWithFrame:((FBAppDelegate*)[UIApplication sharedApplication].delegate).window.bounds];
	ti.frame = self.view.frame;
	[self.view addSubview:ti];
	
	// Create our Test View Instance
	FBFramedWebView * tw;
	tw = [[FBFramedWebView alloc] initWithFrame:((FBAppDelegate*)[UIApplication sharedApplication].delegate).window.bounds];
	[self.view addSubview:tw];
	[tw.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
	tmp = tw.webview.scrollView;
	
	tw.opaque = NO;
	tw.backgroundColor = [UIColor clearColor];
	
	// Arbitrary header/footer frame of ScreenWidth x 50pts
	CGRect tr = CGRectMake(0,0,320,50);
	
	FBTestBorderView * tv;
	
	tw.footerView = tv = [[FBTestBorderView alloc] initWithFrame:tr];
	tw.footerView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
	tv.invertHidingStyle = YES;
	
	tw.headerView = [[FBTestBorderView alloc] initWithFrame:tr];
	tw.headerView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
	
#if 0
	// Frame Inspecting Debug code
	for (UIView * view in tmp.subviews){
		NSLog(@"View? %@",view);
		view.frame = CGRectOffset(view.frame, 0, 100);
	}
	tmp.contentSize = CGSizeMake(tmp.contentSize.width, tmp.contentSize.height + 100);
	tmp.contentOffset = CGPointMake(0, 50);
#endif
}


@end
