#import "Word.h"
#import "Texter.h"
#import "Constants.h"
#import "WPediaFile.h"

@class Article, WPediaViewController, WPediaWindow;

enum
{
	ReleaseViewsNone,
	ReleaseViewsForward,
	ReleaseViewsBack
};
typedef int ReleaseViewsMode;

@interface wpedia: NSObject
{
}

+(void) init;
+(WPediaWindow *) wpediaWindow;
+(void) setWpediaWindow:(WPediaWindow *)newValue;
+(WPediaViewController *) viewController;
+(void) setViewController:(WPediaViewController *)newValue;
+(int) historyIndex;
+(void) setHistoryIndex:(int)newValue;
+(NSString *) lastArticleTitle;
+(void) setLastArticleTitle:(NSString *)newValue;
+(NSString *) documentDirectory;
+(NSMutableArray *) history;
+(void) loadData;
+(void) loadBasicFiles;
+(void) adjustHistory;
+(void) saveHistory;
+(void) releaseViews:(ReleaseViewsMode)releaseMode;
@end
