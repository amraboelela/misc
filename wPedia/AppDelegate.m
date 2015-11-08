#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	// low on memory: do whatever you can to reduce your memory foot print here
	NSLog(@"applicationDidReceiveMemoryWarning");
	[wpedia releaseViews:ReleaseViewsBack];
	
#ifdef DEBUG
	report_memory();
#endif
}

-(void) applicationDidFinishLaunching:(UIApplication *)application
{
	if (getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
 	[wpedia init];
	[wpedia loadData];
	WPediaViewController *vc = [[WPediaViewController alloc] initWithNibName:@"WPediaViewController" bundle:nil];
	[wpedia setWpediaWindow:window];
	[window addSubview:vc.view];
	[window makeKeyAndVisible];
}

-(void) dealloc
{
    [window release];    
    [super dealloc];
}

@end


