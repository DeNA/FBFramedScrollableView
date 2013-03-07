//
//  FBFramedScrollableView.h
//
//  Created by Frederic Barthelemy on 2012-11-09.
//

#import <UIKit/UIKit.h>
#import "FBViewFrameComponent.h"

/**
 * Features:
 *	- Manages a view which behaves specially if it is scrollable. (UIWebView, UIScrollView)
 *	- Permits you to have a background view behind each scrollable area.
 *	- Automatically moves a header and footer bar around according to a variety of rules. (See FBViewFrameComponent protocol)
 *	- Redelegates the UIScrollViewDelegate protocol for the scrollable area (that it relies on to function)
 */
@interface FBFramedScrollableView : UIView <UIScrollViewDelegate>

// Contains *either* a Webview or a ScrollView, you decide which!
@property (nonatomic, readwrite, strong) UIView * contentView; // Arbitrary accessor

// Helper Methods to access 2 known scrollers
@property (nonatomic, readonly, strong)  UIScrollView * scrollView;
@property (nonatomic, readonly, strong)  UIWebView * webview;


@property (nonatomic, readwrite, strong) UIView * background; // Will set webview as non-opaque & transparent, save the color yourself if you want to restore it.

@property (nonatomic, readwrite, strong) UIView /*<FBViewFrameComponent>*/* headerView;
@property (nonatomic, readwrite, strong) UIView /*<FBViewFrameComponent>*/* footerView;

@property (nonatomic, readwrite, weak) id<UIScrollViewDelegate> scrollViewDelegate;

@end
