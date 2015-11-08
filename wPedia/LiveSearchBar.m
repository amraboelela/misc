#import "LiveSearchBar.h"

@implementation LiveSearchBar

@synthesize liveWebView;
@synthesize borderView, shadeView;
@synthesize htmlContent;
@synthesize searchStr;
@synthesize timer;
@synthesize isActive;

#pragma mark -
#pragma mark init methods

-(id) initWithViewController:(CGRect)frame viewController:(WPediaViewController *)aViewController
{
	self = [self initWithFrame:frame];
	self.delegate = self;
	viewController = aViewController;
	shadeView = [[UIView alloc] init];
	borderView = [[UIView alloc] init];
	liveWebView = [[UIWebView alloc] init];
	shadeView.frame = CGRectMake(40, 73, 210, 150);
	borderView.frame = CGRectMake(30, 63, 210, 150);
	liveWebView.frame = CGRectMake(31, 64, 208, 148);
	borderView.backgroundColor = [UIColor blackColor];
	shadeView.backgroundColor = [UIColor grayColor];
	shadeView.alpha = 0.5;
	liveWebView.delegate = self;
	htmlContent = [[NSMutableString alloc] init];
	timer = nil;
	listUpToDate = false;
	searchButtonClicked = false;
	isActive = false;
	return self;
}

#pragma mark -
#pragma mark UISearchBarDelegate

/*
 * called when text changes
 */
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	isActive = true;
	[viewController showBars];
	[self becomeFirstResponder];
	if (searchButtonClicked)
	{
		searchButtonClicked = false;
		return;
	}
	listUpToDate = false;
	self.searchStr = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[NSThread detachNewThreadSelector:@selector(fillHtmlContent) toTarget:self withObject:nil];
	if (!timer)
		timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(viewList) userInfo:nil repeats:true];
}

/*
 * called when keyboard search button pressed
 */
-(void) searchBarSearchButtonClicked:(UISearchBar *)clickedSearchBar
{
	Article *oldArticle, *newArticle;
	[self hideList];
	[self resignFirstResponder];
	self.text = [Texter uppercaseFirst:[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	oldArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	newArticle = [[Article alloc] initWithTitle:self.text];
	[oldArticle releaseViews];
	[[wpedia history] replaceObjectAtIndex:[wpedia historyIndex] withObject:newArticle];
	if ([wpedia historyIndex] < [[wpedia history] count] - 1)
	{
		Article *nextArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex] + 1];
		nextArticle.hasParent = false;
	}
	[newArticle release];
	[viewController showArticle:newArticle];
	[wpedia adjustHistory];
	isActive = false;
}

/*
 * called when cancel button pressed
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)clickedSearchBar
{
	[self hideList];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url, *title;
	NSScanner *scanner;
	
	if (navigationType == 0)
	{
		liveListClicked = true;
		if  ([request.URL.absoluteString rangeOfString:@"search://search?"].location == 0)
		{	// search page navigation.
			url = request.URL.absoluteString;
			scanner = [[NSScanner alloc] initWithString:url];
			[scanner scanUpToString:@"://search?" intoString:NULL];
			[scanner scanString:@"://search?" intoString:NULL];
			[scanner scanUpToString:@"\n" intoString:&title];
			title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			title = [title stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			self.text = [title retain];
			[scanner release];
			return false; 
		}
	}
	[viewController showBars];
	return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{	
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:@"webView error: %@", error.localizedDescription];
	NSLog(@"%@", errorString);
}

#pragma mark -
#pragma mark other methods

/*
 * fill htmlContent
 */
- (void) fillHtmlContent
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int i;
	NSMutableString *prefix = [[NSMutableString alloc] init];
	NSArray *liveList = [NSArray arrayWithObjects:nil];
	
	if (searchStr.length > 0)
	{
		NSArray *splitWords = [searchStr componentsSeparatedByString:@" "];
		for (i=0; i < splitWords.count - 1; i++)
			[prefix appendFormat:@"%@ ", [splitWords objectAtIndex:i]];
		NSString *lastWord = [[splitWords objectAtIndex:splitWords.count-1] lowercaseString];
		if ([lastWord isMatchedByRegex:@"[a-z]"])
			liveList = [Word findWord:lastWord resultLimit:100];
	}
	Word *word;
	NSMutableString *myContent = [[NSMutableString alloc] init];
	
	[myContent appendFormat:@"%@<body>", [LiveSearchBar getHeader]];
	if (liveList.count > 0)
	{
		word = [liveList objectAtIndex:0];
		[myContent appendFormat:@"<a href='search://search?%@%@'>%@%@</a>", prefix, word.value, prefix, word.value];
	}
	for (i=1; i < liveList.count; i++)
	{
		word = [liveList objectAtIndex:i];
		[myContent appendFormat:@"<br><a href='search://search?%@%@'>%@%@</a>", prefix, word.value, prefix, word.value];
	}
	[myContent appendString:@"</body>"];
	[htmlContent setString:myContent];
	listUpToDate = true;
	[prefix release];
	[myContent release];
	[pool drain];
}

/*
 * get the output page header
 */
+(NSString *) getHeader
{
	NSString *result = @"<head>\n"
	@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />\n"
	@"<link rel='stylesheet' href='css/searchBar.css' type='text/css' />\n"
	@"</head>\n";
	return result;
}

/*
 * view suggestion list
 */
-(void) viewList
{
	//NSLog(@"viewList");
	[viewController showBars];
	if (listUpToDate)
	{
		listUpToDate = false;
		NSURL *baseURL = [NSURL fileURLWithPath:[wpedia documentDirectory] isDirectory:true];
		[liveWebView loadHTMLString:htmlContent baseURL:baseURL];
		NSString *mySearchStr = [self.text lowercaseString];;
		if (![mySearchStr isMatchedByRegex:@"[a-z]"])
			[self hideList];
		else
		{
			if (![shadeView superview])
				[viewController.view addSubview:shadeView];
			[viewController.view bringSubviewToFront:shadeView];
			if (![borderView superview])
				[viewController.view addSubview:borderView];
			[viewController.view bringSubviewToFront:borderView];
			if (![liveWebView superview])
				[viewController.view addSubview:liveWebView];
			[viewController.view bringSubviewToFront:liveWebView];
		}
	}
	if (liveListClicked)
	{
		liveListClicked = false;
		[self becomeFirstResponder];
	}
}

/*
 * view suggestion list
 */
- (void) hideList
{
	if ([liveWebView superview])
		[liveWebView removeFromSuperview];
	if ([borderView superview])
		[borderView removeFromSuperview];
	if ([shadeView superview])
		[shadeView removeFromSuperview];
	if (timer)
	{
		[timer invalidate];
		self.timer = nil;
	}
	[viewController showBars];
	isActive = false;
}
@end
