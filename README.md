# FramedScrollableView

### Features:
- Manages a view which behaves specially if it is scrollable. (UIWebView, UIScrollView)
- Permits you to have a background view behind each scrollable area.
- Automatically moves a header and footer bar around according to a variety of rules. (See FBViewFrameComponent protocol)
- Redelegates the UIScrollViewDelegate protocol for the scrollable area (that it relies on to function), so you can have a separate delegate that watches scrolling.

The fundamental purpose of this is to make it easy to have a header and footer that animate in and out automatically as you scroll.

## Author: 
Frederic Barthelemy - github@fbartho.com
