#import "WPediaViewController.h"
#import "WPediaWindow.h"
#import "wpedia.h"
#import "Article.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    WPediaWindow *window;
}

@property (nonatomic, retain) IBOutlet WPediaWindow *window;

@end

