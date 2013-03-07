//
//  FBFramedScrollableView.m
//
//  Created by Frederic Barthelemy on 2012-11-09.
//

#import "FBFramedScrollableView.h"

@interface FBFramedScrollableView ()
@property (nonatomic, readonly, strong) UIScrollView *scroller;
@end

@implementation FBFramedScrollableView
{
	CGPoint lastOffset;
	CGPoint scrollStartOffset;
	
	CGSize minHeaderSize;
	
	UIView <FBViewFrameComponent> *headerView; // little magic so we don't get compile warnings re: optional protocol methods. Always check if respondsToSelector!
	UIView <FBViewFrameComponent> *footerView;
	
	BOOL updateInProgress; // to avoid multiple layoutSubview calls.
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

- (UIView*)headerView
{
	return headerView;
}
- (void)setHeaderView:(UIView *)_headerView
{
	[headerView removeFromSuperview];
	headerView = (UIView<FBViewFrameComponent> *)_headerView;
	if (headerView)[self addSubview: headerView];
	[self layoutSubviews];
	[self _refreshFramePositionsForOffset:self.scroller.contentOffset popBars:YES animate:NO];
}
- (UIView*)footerView
{
	return footerView;
}
- (void)setFooterView:(UIView *)_footerView
{
	[footerView removeFromSuperview];
	footerView = (UIView<FBViewFrameComponent> *)_footerView;
	if (footerView)[self addSubview:footerView];
	[self _refreshFramePositionsForOffset:self.scroller.contentOffset popBars:YES animate:NO];
}

@synthesize background;
- (void)setBackground:(UIView *)backgroundView
{
	[background removeFromSuperview];
	background = backgroundView;
	[self.contentView removeFromSuperview];
	if (backgroundView){
		[self addSubview:background];
		webview.opaque = NO;
		webview.backgroundColor = [UIColor clearColor];
	} else {
		webview.opaque = YES; // Note, we don't save the webview's original color, so we can't restore it. is necessary?
	}
	[self addSubview:self.contentView];
}
@dynamic scroller;
- (UIScrollView*)scroller
{
	return (webview ? webview.scrollView : scrollView);
}

@synthesize contentView;
- (UIView*)contentView
{
	return contentView;
}
- (void)setContentView:(UIView *)aContentView
{
	[contentView removeFromSuperview];
	contentView = aContentView;
	if (aContentView){
		updateInProgress = YES;
		self.webview = nil;
		self.scrollView = nil;
		if ([aContentView isKindOfClass:[UIScrollView class]]){
			self.scrollView = (UIScrollView*)aContentView;
		} else if ([aContentView isKindOfClass:[UIWebView class]]){
			self.webview = (UIWebView *)aContentView;
		}
		updateInProgress = NO;
	} else {
		updateInProgress = YES;
		self.webview = nil;
		self.scrollView = nil;
		updateInProgress = NO;
	}
	[self layoutSubviews];
}

@synthesize webview;
- (UIWebView*)webview
{
	if (!webview){
		self.webview = [[UIWebView alloc] initWithFrame:self.bounds];
		self.background = self.background;
	}
	return webview;
}
- (void)setWebview:(UIWebView *)aWebview
{
	[self.contentView removeFromSuperview];
	self.scroller.delegate = nil;
	webview = aWebview;
	if (webview){
		self.scrollView = nil;
		[self addSubview:webview];
		self.scroller.delegate = self;
	}
	if (!updateInProgress){
		[self layoutSubviews];
	}
}
@synthesize scrollView;
- (UIScrollView*)scrollView
{
	if (!scrollView){
		self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		self.background = self.background;
	}
	return scrollView;
}
- (void)setScrollView:(UIScrollView *)aScrollView
{
	[self.contentView removeFromSuperview];
	self.scroller.delegate = nil;
	scrollView = aScrollView;
	if (scrollView){
		self.webview = nil;
		[self addSubview:scrollView];
		self.scroller.delegate = self;
	}
	if (!updateInProgress){
		[self layoutSubviews];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat headerInset = headerView ? headerView.frame.size.height : 0;
	CGFloat footerInset = footerView ? footerView.frame.size.height : 0;
	
	self.scroller.contentInset = UIEdgeInsetsMake(0, 0, headerInset + footerInset, 0);
	
	self.contentView.frame = self.bounds;
	
	[self _refreshFramePositionsForOffset:self.scroller.contentOffset popBars:NO animate:NO];
}
- (void)_refreshFramePositionsForOffset:(CGPoint)curOffset popBars:(BOOL)popBars animate:(BOOL)animate
{
	FBViewFrameHidingStyle hidingStyle;
	CGFloat targetY, minY, maxY, hardMaxY, yDiff, delta;
	CGSize minSize;
	BOOL headerInvert, footerInvert;
	CGRect headerFrame = headerView ? headerView.frame : CGRectZero;
	CGRect footerFrame = footerView ? footerView.frame : CGRectZero;
	
	CGRect contentFrame = self.contentView.bounds;
	
	BOOL verticalStable = curOffset.y == lastOffset.y;
	BOOL down = curOffset.y >= lastOffset.y;
	yDiff = curOffset.y - lastOffset.y;
	
	
	if (!verticalStable || popBars) {
		
		//NSLog(@" %f %f Going %@!", curOffset.y, yDiff, down?@"Down":@"Up");
		if (headerView) {
			hidingStyle = FBViewFrameHidingStyleNone;
			if ([headerView respondsToSelector:@selector(hidingStyle)]){
				hidingStyle = headerView.hidingStyle;
			}
			
			minSize = CGSizeZero;
			if ([headerView respondsToSelector:@selector(minSize)]){
				minSize = [headerView minSize];
			}
			minY = minSize.height - headerView.frame.size.height;
			
			targetY = headerView.frame.origin.y - yDiff;
			if (curOffset.y + headerView.frame.size.height < 0) {
				targetY = -curOffset.y;
			}
			if (hidingStyle == FBViewFrameHidingStyleNone || targetY > 0){
				targetY = 0;
			}
			if (targetY < minY) {
				targetY = minY;
			}
			
			delta = (-targetY + minSize.height);
			
			if (hidingStyle == FBViewFrameHidingStyleFollowPopBack && popBars){
				//NSLog(@"target %f headerView %f",(-1 * targetY),((headerView.frame.size.height) / 2.0));
				if (minY < 0 && headerView.frame.origin.y < 0
					&& delta > (headerView.frame.size.height - delta)
					&& curOffset.y > headerView.frame.size.height){
					//NSLog(@"Pop-hide the header");
					targetY = minY;
				} else {
					//NSLog(@"Pop-show the header");
					targetY = 0;
				}
			}
			
			headerFrame.origin.y = targetY;
			
			contentFrame.origin.y += (headerFrame.origin.y + headerFrame.size.height);
			//NSLog(@"headerView %@",NSStringFromCGRect(headerView.frame));
		}
		
		if (footerView) {
			hidingStyle = FBViewFrameHidingStyleNone;
			if ([footerView respondsToSelector:@selector(hidingStyle)]){
				hidingStyle = footerView.hidingStyle;
			}
			if ([footerView respondsToSelector:@selector(invertHidingStyle)]){
				footerInvert = footerView.invertHidingStyle;
			}
			
			minSize = CGSizeZero;
			if ([footerView respondsToSelector:@selector(minSize)]){
				minSize = [footerView minSize];
			}
			
			CGFloat distancePastEnd = (curOffset.y + contentFrame.size.height) - self.scroller.contentSize.height;
			maxY = hardMaxY = contentFrame.size.height - minSize.height;
			minY = contentFrame.size.height - footerView.frame.size.height;
			
			if (distancePastEnd > 0
				//&& !(distancePastEnd < minSize.height)
				//&& (maxY + distancePastEnd + minSize.height) > minY
				//&& !(self.frame.size.height - footerView.frame.size.height > maxY)
				) {
				maxY -= distancePastEnd;
			}
			
			//NSLog(@"huh %f %f %f %f",distancePastEnd, maxY, hardMaxY, targetY);
			targetY = footerView.frame.origin.y - ((footerInvert) ? (-1 * yDiff) : yDiff);
			if (hidingStyle == FBViewFrameHidingStyleNone
				|| curOffset.y > (self.scroller.contentSize.height + contentFrame.size.height)
				){
				targetY = contentFrame.size.height - footerView.frame.size.height;
			}
			if (targetY < minY) {
				targetY = minY;
			} else if (targetY > maxY) {
				if (distancePastEnd > footerView.frame.size.height){
					targetY = contentFrame.size.height - footerView.frame.size.height;
				} else if (distancePastEnd > minSize.height) {
					targetY = contentFrame.size.height - distancePastEnd;
				} else {
					targetY = contentFrame.size.height - minSize.height;
				}
			}
			
			footerFrame.origin.y = targetY;
			
			//NSLog(@"footerView %@",NSStringFromCGRect(footerFrame));
		}
	}
	
	lastOffset = curOffset;
	
	if (animate) {
		[UIView animateWithDuration:0.25
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
			headerView.frame = headerFrame;
			footerView.frame = footerFrame;
			self.background.frame = self.contentView.frame = contentFrame;
		} completion:^(BOOL finished) {
			//NSLog(@"HeaderViewFrame %@",NSStringFromCGRect(headerView.frame));
		}];
	} else {
		headerView.frame = headerFrame;
		footerView.frame = footerFrame;
		self.background.frame = self.contentView.frame = contentFrame;
	}
}


#pragma mark - UIScrollViewDelegate redelegation
#define Redelegate_1(a) id<UIScrollViewDelegate> tmpDel; if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){[tmpDel performSelector:_cmd withObject:a];}
#define Redelegate_2(a, b) id<UIScrollViewDelegate> tmpDel; if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){[tmpDel performSelector:_cmd withObject:a withObject:b];}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
	
	[self _refreshFramePositionsForOffset: theScrollView.contentOffset popBars:NO animate:NO];
}
- (void)scrollViewDidZoom:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)theScrollView
{
	scrollStartOffset = theScrollView.contentOffset;
	
	Redelegate_1(theScrollView);
}
- (void)scrollViewWillEndDragging:(UIScrollView *)theScrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	id<UIScrollViewDelegate> tmpDel; // ARC weak property safety.
	if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){
		[tmpDel scrollViewWillEndDragging:theScrollView withVelocity:velocity targetContentOffset:targetContentOffset];
	}
	//[self _refreshFramePositionsForOffset:(*targetContentOffset) popBars:YES animate:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)theScrollView willDecelerate:(BOOL)decelerate
{
	id<UIScrollViewDelegate> tmpDel; // ARC weak property safety.
	if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){
		[tmpDel scrollViewDidEndDragging:theScrollView willDecelerate:decelerate];
	}
	
	if (!decelerate){
		[self _refreshFramePositionsForOffset:theScrollView.contentOffset popBars:YES animate:YES];
	}
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)theScrollView
{
	id<UIScrollViewDelegate> tmpDel; // ARC weak property safety.
	if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){
		return [tmpDel viewForZoomingInScrollView:theScrollView];
	}
	return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)theScrollView withView:(UIView *)view
{
	Redelegate_2(theScrollView,view);
}
- (void)scrollViewDidEndZooming:(UIScrollView *)theScrollView withView:(UIView *)view atScale:(float)scale
{
	id<UIScrollViewDelegate> tmpDel; // ARC weak property safety.
	if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){
		[tmpDel scrollViewDidEndZooming:theScrollView withView:view atScale:scale];
	}
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)theScrollView
{
	id<UIScrollViewDelegate> tmpDel; // ARC weak property safety.
	if ([(tmpDel = self.scrollViewDelegate) respondsToSelector:_cmd]){
		return [tmpDel scrollViewShouldScrollToTop:theScrollView];
	}
	return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)theScrollView
{
	Redelegate_1(theScrollView);
}
#undef Redelegate_1
#undef Redelegate_2
#pragma clang diagnostic pop
@end
