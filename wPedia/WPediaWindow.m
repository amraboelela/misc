#import "WPediaWindow.h"

@implementation WPediaWindow

-(void) sendEvent:(UIEvent *)event
{
	float difX, difY;
	
	[super sendEvent:event];
	WPediaViewController *viewController = [wpedia viewController];
	NSSet *touches = [event allTouches];
    UITouch *touch = touches.anyObject;
	CGPoint tapPoint = [touch locationInView:viewController.view];
	CGPoint previousPoint = [touch previousLocationInView:viewController.view];
	
	if (touch.phase == UITouchPhaseBegan)
	{
		fingerMoved = false;
		moveX = 0;
		moveY = 0;
	}
	if (touch.phase == UITouchPhaseMoved)
	{
		fingerMoved = true;
		difX = tapPoint.x - previousPoint.x;
		difY = tapPoint.y - previousPoint.y;
		moveX += difX;
		moveY += difY;
	}
	if (touch.phase == UITouchPhaseEnded)
	{
		if (tapPoint.y > 215 || (tapPoint.x > 251 && tapPoint.y > 66) || (tapPoint.x < 28 && tapPoint.y > 66))
		{
			LiveSearchBar *liveSearchBar = viewController.liveSearchBar;
			if (liveSearchBar.liveWebView.superview)
			{
				[liveSearchBar hideList];
				return;
			}
		}
		if (fingerMoved)
			[viewController hideBars];
		else // if clicking
		{
			[viewController showBars];
		}
	}
}

@end
