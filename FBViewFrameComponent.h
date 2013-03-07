//
//  FBViewFrameComponent.h
//
//  Created by Frederic Barthelemy on 2012-11-09.
//

#import <Foundation/Foundation.h>

typedef enum {
	FBViewFrameHidingStyleNone = 0,			// Always Persistent On Screen
	FBViewFrameHidingStyleFollow = 1,		// Scrolls off with content (up to min size)
	FBViewFrameHidingStyleFollowPopBack = 2	// Scrolls off with content, but pops back in
} FBViewFrameHidingStyle;

@protocol FBViewFrameComponent <NSObject>

@optional
@property (nonatomic, readonly, assign) FBViewFrameHidingStyle hidingStyle;
@property (nonatomic, readonly, assign) BOOL invertHidingStyle;	// Use this if you want to invert logic, so footer hides with header
@property (nonatomic, readonly, assign) CGSize minSize;			// Use this to lock a minimum always visible.
@end
