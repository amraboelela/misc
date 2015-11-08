#import "wpedia.h"
#import "WPediaViewController.h"

@class WPediaViewController;

@interface LiveSearchBar : UISearchBar <UISearchBarDelegate, UIWebViewDelegate>
{
	WPediaViewController *viewController;
	UIWebView *liveWebView;
	UIView *borderView, *shadeView;
	NSMutableString *htmlContent;
	NSString *searchStr;
	NSTimer *timer;
	BOOL listUpToDate, searchButtonClicked, isActive, liveListClicked;
}

@property (nonatomic, retain) UIWebView *liveWebView;
@property (nonatomic, retain) UIView *borderView, *shadeView;
@property (nonatomic, retain) NSMutableString *htmlContent;
@property (nonatomic, retain) NSString *searchStr;
@property (nonatomic, assign) NSTimer *timer;
@property BOOL isActive;

-(id) initWithViewController:(CGRect)frame viewController:(WPediaViewController *)aViewController;
-(void) fillHtmlContent;
-(void) viewList;
-(void) hideList;
+(NSString *) getHeader;
@end
