#import "wpedia.h"
#import "LiveSearchBar.h"
#import "WPediaWindow.h"

@class LiveSearchBar;

@interface WPediaViewController : UIViewController <UISearchBarDelegate, UIWebViewDelegate>
{
	UIToolbar *toolbar;
	UIToolbar *rButton;
	//UIActivityIndicatorView *activityIndicator;
	UIView *borderView;
	//BOOL wasInForwardAction;
	LiveSearchBar *liveSearchBar;
	CGRect webFrame;
	int idleCount;
	//BOOL animate;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar, *rButton;
@property (nonatomic, retain) UIView *borderView;
//@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) LiveSearchBar *liveSearchBar;
@property CGRect webFrame;

// actions
-(IBAction) backAction:(id)sender;
-(IBAction) forwardAction:(id)sender;
-(IBAction) textViewAction:(id)sender;
-(IBAction) imageViewAction:(id)sender;
-(IBAction) refreshAction:(id)sender;
-(IBAction) randomAction:(id)sender;

// timer methods
-(void) timeHandler;

// show / hide methods
-(void) toggleBars;
-(void) showBars;
-(void) showSearchbar;
-(void) showToolbar;
-(void) hideSearchbar;
-(void) hideBars;
-(void) showArticle:(Article *)article;
//-(void) completeViewArticle:(Article *)article;

//-(void) showToolbar;
@end
