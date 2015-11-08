#import "WPediaViewController.h"
#import "Constants.h"

#pragma mark -
@implementation WPediaViewController

static float webTop, webWidth, webHeight;

@synthesize liveSearchBar, toolbar, rButton, borderView;
@synthesize webFrame;

#pragma mark -
#pragma mark init methods

-(void) dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController delegate methods

/*
 * called when the view did load
 */
-(void) viewDidLoad
{
	[super viewDidLoad];
	NSLog(@"viewDidLoad");
	
	webTop = kTopPlacement;
	webWidth = 320;
	webHeight = kWebHeight;
	webFrame = CGRectMake(0, webTop, webWidth, webHeight);
	
	liveSearchBar = [[LiveSearchBar alloc] initWithViewController:CGRectMake(0.0, 20.0, self.view.bounds.size.width-44, 44.0) viewController:self];
	[self.view addSubview:liveSearchBar];
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	
	Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	[self showArticle:currentArticle];
	liveSearchBar.text = [Texter uppercaseFirst:currentArticle.title];
	
	borderView = [[UIView alloc] init];
	borderView.frame = CGRectMake(320-44, 20+43, 44, 1);
	borderView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:borderView];
	[wpedia setViewController:self];
	[self showBars];
	//activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	//activityIndicator.frame = CGRectMake(320-44-55, 20+13, 20, 20);
	//[self.view addSubview:activityIndicator];
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeHandler) userInfo:nil repeats:true];
	//wasInForwardAction = false;
	//animate = false;
	//[self.view bringSubviewToFront:activityIndicator];
	//[activityIndicator startAnimating];
}

/*
 * called after this controller's view was dismissed, covered or otherwise hidden
 */
-(void) viewWillDisappear:(BOOL)animated
{
	// restore the nav bar and status bar color to default
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

/*
 * called after this controller's view will appear
 */
-(void) viewWillAppear:(BOOL)animated
{	
	// match the status bar with the nav bar
}

#pragma mark -
#pragma mark rotation delegate methods

/*
 * called after rotation
 */
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return true;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait 
		|| toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[UIApplication sharedApplication].statusBarHidden = false;
		webTop = 0;
		webWidth = 320;
		webHeight = kWebHeight;
	}
	else
	{
		[UIApplication sharedApplication].statusBarHidden = true;
		webTop = 0;
		webWidth = 480;
		webHeight = 320;
	}
	Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	UIWebView *articleWebView = *currentArticle.webView;
	webFrame = CGRectMake(0, webTop, webWidth, webHeight);
	articleWebView.frame = webFrame;
	[self.view bringSubviewToFront:articleWebView];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		liveSearchBar.shadeView.frame = CGRectMake(40, 73-20, 210, 150);
		liveSearchBar.borderView.frame = CGRectMake(30, 63-20, 210, 150);
		liveSearchBar.liveWebView.frame = CGRectMake(31, 64-20, 208, 148);
		
		liveSearchBar.frame = CGRectMake(0.0, 0, 320-44, 44.0);
		rButton.frame = CGRectMake(320-44, -1, 44, 44.0);
		borderView.frame = CGRectMake(320-44, 0+43, 44, 1);
		toolbar.frame = CGRectMake(0, 480-44-20, self.view.bounds.size.width, 44.0);
		//activityIndicator.frame = CGRectMake(320/2-15, 480/2-15, 30, 30);
	}
	else
	{
		liveSearchBar.shadeView.frame = CGRectMake(40, 73-20, 480-150, 150-45);
		liveSearchBar.borderView.frame = CGRectMake(30, 63-20, 480-150, 150-45);
		liveSearchBar.liveWebView.frame = CGRectMake(31, 64-20, 480-150-2, 150-45-2);
		
		liveSearchBar.frame = CGRectMake(0, 0, 480-44, 44.0);
		rButton.frame = CGRectMake(480-44, -1, 44, 44);
		borderView.frame = CGRectMake(480-44, 43, 44, 1);
		toolbar.frame = CGRectMake(0, 320-44, self.view.bounds.size.width, 44.0);
		//activityIndicator.frame = CGRectMake(480/2-15, 320/2-15, 30, 30);
	}
	[self showBars];
}

#pragma mark -
#pragma mark UIToolbar delegate methods

/*
 * goto the previous webView tab.
 */
-(IBAction) backAction:(id)sender
{
	Article *currentArticle, *backArticle;
	CGRect frame;
	NSLog(@"backAction");
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
	currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	UIWebView *currentWebView = *currentArticle.webView;
	if (currentWebView.canGoBack)
	{
		[currentWebView goBack];
		return;
	}
	else if (currentArticle.external)
	{
		[currentArticle releaseExternalWebView]; 
		currentArticle.external = false;
		if (currentArticle.viewMode == ViewModeText)
			currentArticle.webView = &currentArticle->textWebView;
		else
			currentArticle.webView = &currentArticle->htmlWebView;
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
			|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
			frame = CGRectMake(0, webTop, webWidth, webHeight);
		else
			frame = CGRectMake(0, webTop, webWidth, webHeight);	
		(*currentArticle.webView).frame = frame;
		[self.view addSubview:*currentArticle.webView];
		return;
	}
	if ([wpedia historyIndex] == 0)
		backArticle = [[wpedia history] objectAtIndex:[[wpedia history] count] - 1];
	else
		backArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex] - 1];
	UIWebView *backWebView = *backArticle.webView;
	if (!backWebView || backWebView.delegate != self || !backWebView.superview)
	{
		[backArticle showView];
		backWebView = *backArticle.webView;
		backWebView.delegate = self;
	}
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		frame = CGRectMake(-320, webTop, webWidth, webHeight);
	else
		frame = CGRectMake(-480, webTop, webWidth, webHeight);	
	backWebView.frame = frame;
	if (!backWebView.superview)
	{
		[self.view addSubview:backWebView];
	}
	[self showBars];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		backWebView.center = CGPointMake(backWebView.center.x + 320, backWebView.center.y);
		currentWebView.center = CGPointMake(currentWebView.center.x + 320, currentWebView.center.y);
	}
	else 
	{
		backWebView.center = CGPointMake(backWebView.center.x + 480, backWebView.center.y);
		currentWebView.center = CGPointMake(currentWebView.center.x + 480, currentWebView.center.y);
	}
	liveSearchBar.text = [Texter uppercaseFirst:backArticle.title];
	[UIView commitAnimations];
	if ([wpedia historyIndex] == 0)
		[wpedia setHistoryIndex:[[wpedia history] count] - 1];
	else
		[wpedia setHistoryIndex:[wpedia historyIndex]-1];
	[wpedia saveHistory];
//	[self completeViewArticle:backArticle];
}

/*
 * goto the next webView tab.
 */
-(IBAction) forwardAction:(id)sender
{
	Article *currentArticle, *forwardArticle;
	CGRect frame;
	NSLog(@"forwardAction");
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
	currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	UIWebView *currentWebView = *currentArticle.webView;
	if ([wpedia historyIndex] == [[wpedia history] count] - 1)
		forwardArticle = [[wpedia history] objectAtIndex:0];
	else
		forwardArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex] + 1];
	UIWebView *forwardWebView = *forwardArticle.webView;
	if (!forwardWebView || forwardWebView.delegate != self || !forwardWebView.superview)
	{
		[forwardArticle showView];
		forwardWebView = *forwardArticle.webView;
		forwardWebView.delegate = self;
	}
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		frame = CGRectMake(320, webTop, webWidth, webHeight);
	else
		frame = CGRectMake(480, webTop, webWidth, webHeight);
	forwardWebView.frame = frame;
	if (!forwardWebView.superview)
	{
		[self.view addSubview:forwardWebView];
	}
	[self showBars];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		forwardWebView.center = CGPointMake(forwardWebView.center.x - 320, forwardWebView.center.y);
		currentWebView.center = CGPointMake(currentWebView.center.x - 320, currentWebView.center.y);
	}
	else 
	{
		forwardWebView.center = CGPointMake(forwardWebView.center.x - 480, forwardWebView.center.y);
		currentWebView.center = CGPointMake(currentWebView.center.x - 480, currentWebView.center.y);
	}
	liveSearchBar.text = [Texter uppercaseFirst:forwardArticle.title];
	[UIView commitAnimations];
	if ([wpedia historyIndex] == [[wpedia history] count] - 1)
		[wpedia setHistoryIndex:0];
	else
		[wpedia setHistoryIndex:[wpedia historyIndex] + 1];
	[wpedia adjustHistory];
	//wasInForwardAction = true;
}

/*
 * Show the wikwpedia page in text view only.
 */
-(IBAction) textViewAction:(id)sender
{
	NSLog(@"textViewAction");
	
	[Article setOffline:false];
	Article *article = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	if (article.searchPage || article.specialPage || [article.title isEqualToString:@"random articles"])
		return;
	[*article.webView removeFromSuperview];
	article.viewMode = ViewModeText;
	[self showArticle:article];
	[wpedia adjustHistory];
}

/*
 * Show the whole wikwpedia page including images.
 */
-(IBAction) imageViewAction:(id)sender
{
	NSLog(@"imageViewAction");
	
	[Article setOffline:false];
	Article *article = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	if (article.searchPage || article.specialPage || [article.title isEqualToString:@"random articles"])
		return;
	[*article.webView removeFromSuperview];
	article.viewMode = ViewModeHtml;
	[self showArticle:article];
	[wpedia adjustHistory];
}

/*
 * refresh view.
 */
-(IBAction) refreshAction:(id)sender
{	
	NSLog(@"refreshAction");
	
 	[Article setOffline:false];
	Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	if (currentArticle.connecting)
		return;
	if ([[currentArticle.title lowercaseString] isEqualToString:@"random articles"])
	{
		[self randomAction:self];
		return;
	}
	[currentArticle reinit];
	// fill previousArticle and nextArticle
	NSString *fileName = [currentArticle getViewFile];
	NSString *fileText = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];
	NSScanner *scanner = [[NSScanner alloc] initWithString:fileText];
	if ([fileText rangeOfString:@"<hr>\n<a href='cache://cache/"].length > 0)
	{
		NSString *token;
		[scanner scanUpToString:@"<hr>\n<a href='cache://cache/" intoString:NULL];
		[scanner scanString:@"<hr>\n<a href='cache://cache/" intoString:NULL];
		[scanner scanUpToString:@"'>Previous</a>" intoString:&token];
		if (![scanner isAtEnd])
			currentArticle.previousArticle = token;
		[scanner scanUpToString:@"<hr>\n<a href='cache://cache/" intoString:NULL];
		[scanner scanString:@"<hr>\n<a href='cache://cache/" intoString:NULL];
		[scanner scanUpToString:@"'>Next</a>" intoString:&token];
		if (![scanner isAtEnd])
			currentArticle.nextArticle = token;
	}
	[currentArticle releaseViews];
	[currentArticle fillRawHtmlOnline];
	[self showArticle:currentArticle];
	
#ifdef DEBUG
	report_memory();
#endif
}

/*
 * view random articles.
 */
-(IBAction) randomAction:(id)sender
{
	Article *oldArticle, *newArticle;
	
	if (liveSearchBar.timer)
	{
		[liveSearchBar.timer invalidate];
		liveSearchBar.timer = nil;
	}
	[liveSearchBar hideList];
	[liveSearchBar resignFirstResponder];
	liveSearchBar.text = @"random articles";
	oldArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	newArticle = [[Article alloc] initWithTitle:liveSearchBar.text];
	[oldArticle releaseViews];
	[[wpedia history] replaceObjectAtIndex:[wpedia historyIndex] withObject:newArticle];
	if ([wpedia historyIndex] < [[wpedia history] count] - 1)
	{
		Article *nextArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex] + 1];
		[nextArticle setHasParent:false];
	}
	[newArticle release];
	[self showArticle:newArticle];
	[wpedia adjustHistory];
	liveSearchBar.isActive = false;
}

#pragma mark -
#pragma mark UIWebViewDelegate

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
			navigationType:(UIWebViewNavigationType)navigationType
{	
	NSString *url, *title;
	NSScanner *scanner;
	
	NSLog(@"shouldStartLoadWithRequest: %d %@", navigationType, request.URL.absoluteString);
	if (navigationType == 0)
	{		
		[self showBars];
		if  ([request.URL.absoluteString rangeOfString:@"file:///wiki/"].location == 0)
		{
			url = request.URL.absoluteString;
			scanner = [[NSScanner alloc] initWithString:url];
			[scanner scanUpToString:@"wiki/" intoString:NULL];
			[scanner scanString:@"wiki/" intoString:NULL];
			[scanner scanUpToString:@"\n" intoString:&title];
			title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			title = [title stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			NSLog(@"article extracted title: %@", title);
			Article *newArticle = [[Article alloc] initWithTitle:title];
			newArticle.hasParent = true;
			if ([wpedia historyIndex] < [[wpedia history] count] - 1)
			{
				Article *nextArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex] + 1];
				if (![nextArticle hasParent])
					[[wpedia history] insertObject:newArticle atIndex:[wpedia historyIndex] + 1];
				else
					[[wpedia history] replaceObjectAtIndex:[wpedia historyIndex]+1 withObject:newArticle];
			}
			else
				[[wpedia history] addObject:newArticle];
			[newArticle release];
			[self forwardAction:self];
			[scanner release];
			return false;
		}
		if  ([request.URL.absoluteString rangeOfString:@"wpedia://wpedia?"].location == 0)
		{	// search page navigation.
			Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
			currentArticle.searchPage = true;
			url = request.URL.absoluteString;
			scanner = [[NSScanner alloc] initWithString:url];
			[scanner scanUpToString:@"//wpedia?" intoString:NULL];
			[scanner scanString:@"//wpedia?" intoString:NULL];
			[scanner scanUpToString:@"\n" intoString:&title];
			title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			title = [title stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			NSArray *splitArray = [title componentsSeparatedByString:@"&"];
			title = [splitArray objectAtIndex:0];
			NSString *tempStr = [splitArray objectAtIndex:1];
			currentArticle.pageNumber = tempStr.intValue;
			NSLog(@"search page extracted title: %@, %d", title, currentArticle.pageNumber);
			*currentArticle.webView = nil;
			*currentArticle.webView = [[UIWebView alloc] init];
			(*currentArticle.webView).frame = webFrame;
			(*currentArticle.webView).delegate = self;
			[currentArticle showView];
			if (webView.superview)
				[webView removeFromSuperview];
			webView.delegate = nil;
			[self.view addSubview:*currentArticle.webView];
			[scanner release];
			return false;
		}
		if  ([request.URL.absoluteString rangeOfString:@"cache://cache/"].location == 0)
		{	// cache navigation.
			Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
			//currentArticle.searchPage = true;
			url = request.URL.absoluteString;
			scanner = [[NSScanner alloc] initWithString:url];
			[scanner scanUpToString:@"//cache/" intoString:NULL];
			[scanner scanString:@"//cache/" intoString:NULL];
			[scanner scanUpToString:@"\n" intoString:&title];
			title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			title = [title stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
			NSLog(@"cache navigation extracted title: %@", title);
			currentArticle.title = title;
			[currentArticle releaseViews]; 
			*currentArticle.webView = nil;
			*currentArticle.webView = [[UIWebView alloc] init];
			(*currentArticle.webView).frame = webFrame;
			(*currentArticle.webView).delegate = self;
			[currentArticle showView];
			liveSearchBar.text = [Texter uppercaseFirst:title];
			[self.view addSubview:*currentArticle.webView];
			[wpedia saveHistory];
			[scanner release];
			return false;
		}
		Article *article = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
		if (webView != article.textWebViewExternal && webView != article.htmlWebViewExternal)
		{
			article.external = true;
			[UIApplication sharedApplication].networkActivityIndicatorVisible = true;
			if (article.viewMode == ViewModeText)
			{
				if (!article.textWebViewExternal)
				{
					article.textWebViewExternal = [[UIWebView alloc] init];
					article.textWebViewExternal.frame = webFrame;
					article.textWebViewExternal.delegate = self;
					article.textWebViewExternal.scalesPageToFit = true;
				}
				[article.textWebViewExternal loadRequest:request];
			}
			else
			{
				if (!article.htmlWebViewExternal)
				{
					article.htmlWebViewExternal = [[UIWebView alloc] init];
					article.htmlWebViewExternal.frame = webFrame;
					article.htmlWebViewExternal.delegate = self;
					article.htmlWebViewExternal.scalesPageToFit = true;
				}
				[article.htmlWebViewExternal loadRequest:request];
			}
			[self showBars];
			return false;
		}
	}
	return true;
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{	
	//Article *article;
	//BOOL foundArticle = false;
	//int i;
	Article *currentArticle = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	
	if ( (webView == currentArticle.textWebViewExternal && currentArticle.viewMode == ViewModeText)
		|| (webView == currentArticle.htmlWebViewExternal && currentArticle.viewMode == ViewModeHtml) )
	{
		[*currentArticle.webView removeFromSuperview];
		if (currentArticle.viewMode == ViewModeText)
			currentArticle.webView = &currentArticle->textWebViewExternal;
		else
			currentArticle.webView = &currentArticle->htmlWebViewExternal;
		[self.view addSubview:*currentArticle.webView];
	}
	/*
	// find the webView article
	for (i=0; i < [wpedia history].count; i++)
	{
		article = [[wpedia history] objectAtIndex:i];
		
		if (webView == article.textWebView || webView == article.htmlWebView)
		{
			foundArticle = true;
			break;
		}
	}*/
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
	[self showBars];
	//animate = false;
	//[activityIndicator stopAnimating];
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
	NSString* errorString = [NSString stringWithFormat:@"webView error: %@", error.localizedDescription];
	NSLog(@"%@", errorString);
	[self showBars];
	//[activityIndicator stopAnimating];
	//animate = false;
}

#pragma mark -
#pragma mark show / hide methods

/*
 * toggle the show / hide for the bars
 */
-(void) toggleBars
{
	if (liveSearchBar.alpha < 0.1 && toolbar.alpha < 0.1)
		[self showToolbar];
	else if (liveSearchBar.alpha < 0.1 && toolbar.alpha > 0.9)
		[self showSearchbar];
	else if (liveSearchBar.alpha > 0.9 && toolbar.alpha < 0.1)
		[self showToolbar];
	else if (liveSearchBar.alpha > 0.9 && toolbar.alpha > 0.9)
		[self hideBars];
}

/*
 * Show the searchbar
 */
-(void) showBars
{
	[self showToolbar];
	[self showSearchbar];
}

/*
 * Show the searchbar
 */
-(void) showSearchbar
{
	liveSearchBar.alpha = 1;
	rButton.alpha = 1;
	borderView.alpha = 1;
	[self.view bringSubviewToFront:liveSearchBar];
	[self.view bringSubviewToFront:rButton];
	[self.view bringSubviewToFront:borderView];
}

/*
 * Show the toolbar
 */
-(void) showToolbar
{
	toolbar.alpha = 1;
	[self.view bringSubviewToFront:toolbar];
}

/*
 * Hide the searchbar
 */
-(void) hideSearchbar
{
	liveSearchBar.alpha = 0;
	rButton.alpha = 0;
	borderView.alpha = 0;
}

/*
 * Hide the searchbar and the toolbar
 */
-(void) hideBars
{
	Article *article = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	
	if (!article.connecting && !liveSearchBar.isActive)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.7];
		liveSearchBar.alpha = 0;
		rButton.alpha = 0;
		borderView.alpha = 0;
		toolbar.alpha = 0;
		[UIView commitAnimations];
	}
}

/*
 * show article.
 */
-(void) showArticle:(Article *)article
{
	UIWebView *articleWebView = *article.webView;
	
	if (!article.completeView)
	{
		[article showView];
		articleWebView = *article.webView;
		articleWebView.frame = webFrame;
		articleWebView.delegate = self;
		liveSearchBar.text = [Texter uppercaseFirst:article.title];
	}
	if (articleWebView.frame.size.width != self.view.bounds.size.width)
		articleWebView.frame = webFrame;
	if (!articleWebView.superview)
		[self.view addSubview:articleWebView];
	[self.view bringSubviewToFront:articleWebView];
	[self showBars];
}

#pragma mark -
#pragma mark timer methods

/*
 * time handler, to handle tasks while loading or hide show search and tool bars.
 */
-(void) timeHandler
{
	//int i;
	Article *article = [[wpedia history] objectAtIndex:[wpedia historyIndex]];
	
	if (article.wasConnecting && article.viewMode != ViewModeText)
	{
		if (article.completeDownloadImages)
		{
			article.wasConnecting = false;
			if (!article.imagesViewed)
				[self imageViewAction:self];
		}
	}
}
@end
