#import "wpedia.h"

//#define DEBUG

#ifdef DEBUG
#import <mach/mach.h>

/*
 * report the current memroy usage of the device
 */
void report_memory(void) 
{
	struct task_basic_info info;
	mach_msg_type_number_t size = sizeof(info);
	kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);

	if( kerr == KERN_SUCCESS ) 
		NSLog(@"Memory in use (in bytes): %u", info.resident_size);
	else 
		NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
}
#endif

@implementation wpedia

static int historyIndex = -1;
static NSMutableArray *history;
static NSString *documentDirectory = @"";
static NSString *lastArticleTitle = @"";
static WPediaWindow *wpediaWindow;
static WPediaViewController *viewController;

+(void) init
{
	history = [[NSMutableArray alloc] init];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentDirectory = [[paths objectAtIndex:0] retain];
}

+(WPediaWindow *) wpediaWindow
{
	return wpediaWindow;
}

+(void) setWpediaWindow:(WPediaWindow *)newValue
{
	wpediaWindow = newValue;
}

+(WPediaViewController *) viewController
{
	return viewController;
}

+(void) setViewController:(WPediaViewController *)newValue
{
	viewController = newValue;
}

+(int) historyIndex
{
	return historyIndex;
}

+(void) setHistoryIndex:(int)newValue
{
	historyIndex = newValue;
}

+(NSString *) lastArticleTitle
{
	return lastArticleTitle;
}

+(void) setLastArticleTitle:(NSString *)newValue
{
	if (lastArticleTitle)
		[lastArticleTitle release];
	lastArticleTitle = [newValue retain];
}

+(NSString *) documentDirectory
{
	return documentDirectory;
}

+(NSMutableArray *) history
{
	return history;
}

+(void) setHistory: (NSMutableArray *) newValue
{
	history = newValue;
}

/*
 * load data
 */
+(void) loadData
{
	NSString *line;
	Article *article;

	[wpedia loadBasicFiles];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/history.txt", [wpedia documentDirectory]];
	NSData *contents = [[NSData alloc] initWithContentsOfFile:fileName];
	const char *firstPosition = [contents bytes];
	const char *chars = firstPosition;
	int length = [contents length];

	lastArticleTitle = [[NSString alloc] initWithCString:chars encoding:NSUTF8StringEncoding];
	chars += [lastArticleTitle length] + 1;
	line = [[NSString alloc] initWithCString:chars encoding:NSUTF8StringEncoding];
	historyIndex = [line intValue];
	chars += [line length] + 1;
	while (chars - firstPosition < length)
	{
		[line release];
		line = [[NSString alloc] initWithCString:chars encoding:NSUTF8StringEncoding];
		if ([Texter isInteger:line])
			article = [[Article alloc] initWithID:[line intValue]];
		else
			article = [[Article alloc] initWithTitle:line];
		chars += [line length] + 1;
		[line release];
		line = [[NSString alloc] initWithCString:chars encoding:NSUTF8StringEncoding];
		article.viewMode = [line intValue];
		[history addObject:article];
		[article release];
		chars += [line length] + 1;
		[line release];
		line = [[NSString alloc] initWithCString:chars encoding:NSUTF8StringEncoding];
		article.hasParent = [line intValue];
		chars += [line length] + 1;
	}
	if (historyIndex > history.count-1)
		historyIndex = history.count-1;
	[fileName release];
	[contents release];
	[line release];
	[NSThread detachNewThreadSelector:@selector(trimCache) toTarget:[WPediaFile class] withObject:nil];
}

/*
 * load css files and basic images into the Documents directory, if they are not already there.
 */
+(void) loadBasicFiles
{
	NSString *fileName, *distFile;
	NSString *path = [[NSString alloc] initWithFormat:@"%@/css", [wpedia documentDirectory]];
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// check and load css files
	if (![fileManager fileExistsAtPath:path])
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:false attributes:nil error:NULL];
	distFile = [path stringByAppendingPathComponent:@"common.css"];
	if (![fileManager fileExistsAtPath:distFile])
	{
		fileName = [[NSBundle mainBundle] pathForResource:@"common" ofType:@"css"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	distFile = [path stringByAppendingPathComponent:@"main.css"];
	if (![fileManager fileExistsAtPath:distFile])
	{
		fileName = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"css"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	distFile = [path stringByAppendingPathComponent:@"shared.css"];
	if (![fileManager fileExistsAtPath:distFile])
	{
		fileName = [[NSBundle mainBundle] pathForResource:@"shared" ofType:@"css"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	distFile = [path stringByAppendingPathComponent:@"searchBar.css"];
	if (![fileManager fileExistsAtPath:distFile])
	{	
		fileName = [[NSBundle mainBundle] pathForResource:@"searchBar" ofType:@"css"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}

	// check and load wpediaScript.js
	distFile = [[wpedia documentDirectory] stringByAppendingPathComponent:@"wpediaScript.js"];
	if (![fileManager fileExistsAtPath:distFile])
	{	
		fileName = [[NSBundle mainBundle] pathForResource:@"wpediaScript" ofType:@"js"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	
	// check and load history.txt
	distFile = [[wpedia documentDirectory] stringByAppendingPathComponent:@"history.txt"];
	if (![fileManager fileExistsAtPath:distFile])
	{	
		fileName = [[NSBundle mainBundle] pathForResource:@"history" ofType:@"txt"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	
	// check and load images
	[path release];
	path = [[NSString alloc] initWithFormat:@"%@/images", [wpedia documentDirectory]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:false attributes:nil error:NULL];
	distFile = [path stringByAppendingPathComponent:@"minus.png"];	
	if (![fileManager fileExistsAtPath:distFile])
	{
		fileName = [[NSBundle mainBundle] pathForResource:@"minus" ofType:@"png"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	distFile = [path stringByAppendingPathComponent:@"plus.png"];
	if (![fileManager fileExistsAtPath:distFile])
	{
		fileName = [[NSBundle mainBundle] pathForResource:@"plus" ofType:@"png"];
		[fileManager copyItemAtPath:fileName toPath:distFile error:&error];
	}
	[path release];
}

/*
 * clean history then call saveHistory
 */
+(void) adjustHistory
{
	int i;
	Article *article;
	
	NSLog(@"adjustHistory");
	if (history.count > MaxNumberOfTabs)
	{
		if (historyIndex > history.count / 2)
		{
			for (i = 0; i < MaxNumberOfTabs - history.count; i++)
			{
				article = [history objectAtIndex:0];
				NSLog(@"removing from history: %d-%@", 0, article.title);
				[history removeObjectAtIndex:0];
				historyIndex--;
			}		
		}
		else
		{
			for (i = 0; i < MaxNumberOfTabs - history.count; i++)
			{
				article = [history objectAtIndex:history.count - 1];
				NSLog(@"removing from history: %d-%@", history.count - 1, article.title);
				[history removeObjectAtIndex:history.count - 1];
			}
		}
	}
	[wpedia saveHistory];
}

/*
 * save history
 */
+(void) saveHistory
{
	int i;
	Article *article;
	NSLog(@"saveHistory");
	
	NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"%@\0%d\0", lastArticleTitle, historyIndex];
	for (i=0; i < history.count; i++)
	{
		article = [history objectAtIndex:i];
		if (article.ID > -1)
			[result appendFormat:@"%d\0", article.ID];
		else
			[result appendFormat:@"%@\0", article.title];
		[result appendFormat:@"%d\0", article.viewMode];
		[result appendFormat:@"%d\0", article.hasParent];
	}
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/history.txt", [wpedia documentDirectory]];
	[result writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[result release];
	[fileName release];
	
#ifdef DEBUG
	report_memory();
#endif
}

/*
 * release views if memory is full
 */
+(void) releaseViews:(ReleaseViewsMode)releaseMode
{
	int i;
	Article *article;
	
	for (i=0; i < history.count-1; i++)
		if (!(i==historyIndex
			  || (i==historyIndex+1 && releaseMode==ReleaseViewsForward) 
			  || (i==historyIndex-1 && releaseMode==ReleaseViewsBack)))
		{
			article = [history objectAtIndex:i];
			[article releaseViews];
		}
}
@end
