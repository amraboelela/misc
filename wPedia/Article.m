#import "Article.h"

@implementation Article

static BOOL offline;

@synthesize ID;
@synthesize rawHtml, wholePage;
@synthesize viewMode;
@synthesize title, previousArticle, nextArticle;
@synthesize sections;
@synthesize hasParent, searchPage, specialPage;
@synthesize pageNumber;
@synthesize webView, descriptionWebView, textWebView, textWebViewExternal, htmlWebView, htmlWebViewExternal;
@synthesize textExternal, htmlExternal;

@synthesize score;
@synthesize completeRawHtml, completeDescription;
@synthesize completeSections, completeText, completeHtml, completeDownloadImages, imagesViewed;
@synthesize foundResultInWikipedia, connecting, loading, wasConnecting;
@synthesize didYouMean, linePart;
@synthesize inBody, inJumpTo, inFooter, inTOC, inMetaData, inExternalLinks;
@synthesize inSisterProject, inDev;

#pragma mark -
#pragma mark init methods

-(id) init
{
	self = [super init];
	ID = -1;
	score = 0;
	title = [[NSString alloc] init];
	self.didYouMean = @"";
	previousArticle = nil;
	nextArticle = nil;
	sections = nil;
	rawHtml = nil;
	wholePage = nil;
	foundResultInWikipedia = true;
	descriptionWebView = nil;
	textWebView = nil;
	textWebViewExternal = nil;
	htmlWebView = nil;
	htmlWebViewExternal = nil;
	self.viewMode = ViewModeHtml;
	completeDownloadImages = true;
	imagesViewed = true;
	return self;
}

-(id) initWithID:(int)newID
{
	self = [self init];
	ID = newID;
	return self;
}

-(id) initWithTitle:(NSString *)aTitle
{
	self = [self init];
	title = [aTitle retain];
	return self;
}

-(id) initWithPageNumber:(NSString *)aTitle pageNumber:(int)aPageNumber
{
	self = [self initWithTitle:aTitle];
	pageNumber = aPageNumber;
	return self;
}

/*
 * reinit for refreshing
 */
-(void) reinit
{
	self.didYouMean = @"";
	score = 0;
	foundResultInWikipedia = true;
	connecting = false;
	loading = false;
	wasConnecting = false;
	searchPage = false;
	specialPage = false;
	completeRawHtml = false;
	completeSections = false;
	completeDescription = false;
	completeText = false;
	completeHtml = false;
	completeDownloadImages = true;
	imagesViewed = true;
	inBody = false;
	inJumpTo = false;
	inFooter = false;
	inTOC = false;
	inMetaData = false;
	//foundNewLine = false;
	inSisterProject = false;
	textExternal = false;
	htmlExternal = false;
	inDev = 0;
	offline = false;
	self.external = false;
	[self releaseRawData];
	[self releaseViews];
}

#pragma mark -
#pragma mark property methods

+(BOOL) offline
{
	return offline;
}

+(void) setOffline:(BOOL)newValue
{
	offline = newValue;
}

-(void) setViewMode:(int)newValue
{
	viewMode = newValue;
	switch (newValue) 
	{
		case ViewModeDescription:
			webView = &descriptionWebView;
			break;
		case ViewModeText:
			if (textExternal)
				webView = &textWebViewExternal;
			else
				webView = &textWebView;
			[self releaseDescriptionWebView];
			break;
		case ViewModeHtml:
			if (htmlExternal)
				webView = &htmlWebViewExternal;
			else
				webView = &htmlWebView;
			[self releaseDescriptionWebView];
			break;
	}
}

/*
 * check if description or text or html is complete according to current viewMode
 */
-(BOOL) completeView
{
	switch (viewMode)
	{
		case ViewModeDescription:
			return (completeDescription && descriptionWebView);
		case ViewModeText:
			return (completeText && textWebView);
		case ViewModeHtml:
			if (completeHtml && htmlWebView && completeDownloadImages)
			{
				if (imagesViewed)
					return true;
				else
				{
					imagesViewed = true;
					return false;
				}
			}
			return false;
	}
	return false;
}

/*
 * check if description or text or html is complete according to current viewMode
 */
-(void) setCompleteView:(BOOL)theValue
{
	switch (viewMode)
	{
		case ViewModeDescription:
			completeDescription = theValue;
			return;
		case ViewModeText:
			completeText = theValue;
			return;
		case ViewModeHtml:
			completeHtml = theValue;
			//completeDownloadImages = theValue;
			//imagesViewed = theValue;
			return;
	}
}

/* 
 * check if current view is external
 */
-(BOOL) external
{
	switch (viewMode)
	{
		case ViewModeDescription:
			return false;
		case ViewModeText:
			return textExternal;
		case ViewModeHtml:
			return htmlExternal;
	}
	return false;
}

/*
 * set external to be true or false
 */
-(void) setExternal:(BOOL)newValue
{
	switch (viewMode)
	{
		case ViewModeDescription:
			return;
		case ViewModeText:
			textExternal = newValue;
			return;
		case ViewModeHtml:
			htmlExternal = newValue;
			return;
	}
}

/*
 * compare two articles descending according to their score
 */
-(NSComparisonResult) compareScore:(Article *)article
{
	if (self.score < article.score)
		return NSOrderedDescending;
	else if (self.score > article.score)
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

/*
 * compare two articles ascending according to their title
 */
-(NSComparisonResult) compareTitle:(Article *)article
{
	return [self.title compare:article.title];
			/*
		return NSOrderedDescending;
	else if (self.score > article.score)
		return NSOrderedAscending;
	else
		return NSOrderedSame;*/
}

#pragma mark -
#pragma mark release methods

-(void) dealloc
{
	//NSLog(@"dealloc article: %@", title);
	[self releaseViews];
	[self releaseRawData];
	[title release];
	[super dealloc];
}

/*
 * release views
 */
-(void) releaseViews
{
	//NSLog(@"releaseViews for article: %@", title);
	if (descriptionWebView)
	{
		if (descriptionWebView.superview)
			[descriptionWebView removeFromSuperview];
		descriptionWebView.delegate = nil;
		self.descriptionWebView = nil;
	}
	if (textWebView)
	{
		if (textWebView.superview)
			[textWebView removeFromSuperview];
		textWebView.delegate = nil;
		self.textWebView = nil;
	}
	if (textWebViewExternal)
	{
		self.external = false;
		if (textWebViewExternal.superview)
			[textWebViewExternal removeFromSuperview];
		textWebViewExternal.delegate = nil;
		self.textWebViewExternal = nil;
	}
	if (htmlWebView)
	{
		if (htmlWebView.superview)
			[htmlWebView removeFromSuperview];
		htmlWebView.delegate = nil;
		self.htmlWebView = nil;
	}
	if (htmlWebViewExternal)
	{
		self.external = false;
		if (htmlWebViewExternal.superview)
			[htmlWebViewExternal removeFromSuperview];
		htmlWebViewExternal.delegate = nil;
		self.htmlWebViewExternal = nil;
	}
}

/*
 * releaseDescription webView
 */
-(void) releaseDescriptionWebView
{
	//NSLog(@"releaseDescriptionWebView");
	if (descriptionWebView)
	{
		if (descriptionWebView.superview)
			[descriptionWebView removeFromSuperview];
		descriptionWebView.delegate = nil;
		self.descriptionWebView = nil;
	}
}

/*
 * release external webView
 */
-(void) releaseExternalWebView
{
	//NSLog(@"releaseExternalWebView");
	if (viewMode == ViewModeText)
	{
		if (textWebViewExternal)
		{
			if (textWebViewExternal.superview)
				[textWebViewExternal removeFromSuperview];
			textWebViewExternal.delegate = nil;
			self.textWebViewExternal = nil;
		}
	}
	else
	{
		if (htmlWebViewExternal)
		{
			if (htmlWebViewExternal.superview)
				[htmlWebViewExternal removeFromSuperview];
			htmlWebViewExternal.delegate = nil;
			self.htmlWebViewExternal = nil;
		}
	}
}

/*
 * release raw data like rawHtml, wholePage, and sections
 */
-(void) releaseRawData
{
#ifdef DEBUG
	report_memory();
#endif
	//NSLog(@"releaseRawData");
	
	self.didYouMean = @"";
	self.linePart = nil;	
	self.wholePage = nil;
	self.rawHtml = nil;
	self.sections = nil;
	
#ifdef DEBUG
	report_memory();
#endif
}

#pragma mark -
#pragma mark loading methods

/*
 * show current view and return true if successfull
 */
-(BOOL) showView
{
	NSString *fileName;
	NSURL *url;
	
	NSLog(@"showView title: %@", title);
	if (!*webView)
	{
		*webView = [[UIWebView alloc] init];
	}
	if (title.length == 0 && ID > -1) 
		[self fillTitleFromFile];
	if (title.length == 0 || [[title lowercaseString] isEqualToString:@"random articles"])
	{
		self.title = @"random articles";
		[Article produceRandomArticles];		
		fileName = [self getViewFile];
	}
	else
	{
		fileName = [self fillArticle];
		if (fileName.length == 0)
		{
			[self produceViewFiles];
			fileName = [self getViewFile];
		}
		if (fileName.length == 0)
		{
			self.title = @"random articles";
			[Article produceRandomArticles];		
			fileName = [self getViewFile];
		}
	}
	url = [[NSURL alloc] initFileURLWithPath:fileName isDirectory:false];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[*webView loadRequest:request];
	[url release];
	[request release];
	return true;
}

/*
 * fill this article from offline DB or online.
 */
-(NSString *) fillArticle
{
	Article *resultArticle = nil;
	NSString *viewFile = [self getViewFile];
	
	if (viewFile.length > 0)
		return viewFile;
	if (!searchPage)
	{
		if (ID > -1)
			return @"";
		NSLog(@"searching internal DB...");
		resultArticle = [Word search:title];
	}
	if (!resultArticle)
	{
		NSLog(@"found no results internally, or it is a search page");
		if (!connecting)
			[self fillRawHtmlOnline];
	}
	else
	{
		NSLog(@"found a result");
		if ([[[resultArticle title] lowercaseString] isEqualToString:@"random articles"])
		{
			self.title = @"random articles";
			[Article produceRandomArticles];		
			return [self getViewFile];
		}
		NSLog(@"resultArticle.title.lowercaseString: %@", resultArticle.title.lowercaseString);
		if ([[[resultArticle title] lowercaseString] isEqualToString:[title lowercaseString]])
		{
			ID = resultArticle.ID;
			return @"";
		}
		else
		{
			NSLog(@"Not exact match though");
			if (!connecting)
				[self fillRawHtmlOnline];
		}
	}
	if (offline || !foundResultInWikipedia)
	{
		NSLog(@"offline or !foundResultInWikipedia");
		resultArticle = [Word searchAny:title];
		if (resultArticle)
		{
			self.title = resultArticle.title;
			self.completeView = true;
		}
		return [self getViewFile];
	}
	return @"";
}

/*
 * returns the right view file
 */
-(NSString *) getViewFile
{
	NSString *fileName;
	
	NSLog(@"getViewFile title: %@", title);
	
	// check if it is random articles
	if ([[title lowercaseString] isEqualToString:@"random articles"])
	{
		fileName = [[NSString alloc] initWithFormat:@"%@/random_articles.view-0-o.htm", [wpedia documentDirectory]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			//self.viewMode = ViewModeDescription;
			self.completeView = true;
			return [fileName autorelease];
		}
		else
			[fileName release];
	}
	// check if it is search page
	fileName = [[NSString alloc] initWithFormat:@"%@/%@&%d.htm", 
				[wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString], 
				pageNumber];
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
	{
		if (!connecting && !loading)
			self.completeView = true;
		searchPage = true;
		return [fileName autorelease];
	}
	[fileName release];
	fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-%d.htm", 
				[wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString], 
				viewMode];
	if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
	{
		if (!connecting && !loading)
			self.completeView = true;
		return [fileName autorelease];
	}
	if (offline)
	{
		[fileName release];
		fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-0.htm", 
					[wpedia documentDirectory],
					[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			//self.viewMode = ViewModeDescription;
			return [fileName autorelease];
		}
	}
	if (viewMode == ViewModeDescription || offline)
	{
		[fileName release];		
		fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-0-o.htm", 
					[wpedia documentDirectory],
					[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			//self.viewMode = ViewModeDescription;			
			return [fileName autorelease];
		}
	}
	[fileName release];
	return @"";
}

/*
 * fill article content according to the viewMode
 */
-(void) produceViewFiles
{
	NSLog(@"produceViewFiles title: %@", title);
	
	if (title.length == 0 && ID == -1)
		return;
	while (loading)
		[NSThread sleepForTimeInterval:1];
	loading = true;
	if (viewMode == ViewModeDescription)
	{
		if (!completeDescription && rawHtml && rawHtml.length > 0)
			[self fillDescriptionFromRawHtml];
		if (ID > -1)
			[self fillDescriptionFromFile];
		else if (!offline && !connecting && !completeRawHtml)
		{
			[self fillRawHtmlOnline];
			[self fillDescriptionFromRawHtml];
		}
		if (!connecting && !offline && foundResultInWikipedia && !completeRawHtml)
			[NSThread detachNewThreadSelector:@selector(readWebPage) toTarget:self withObject:nil];
		if (completeRawHtml && !searchPage)
		{
			if (!completeSections)
				[self loadSections];
			if (!completeText)
				[self fillText];
			if (!completeHtml)
				[self fillHtml];
		}
	}
	else
	{
		if (!connecting && !offline && foundResultInWikipedia && !completeRawHtml)
			[self fillRawHtmlOnline];
		if (rawHtml && rawHtml.length > 0)
		{
			if (!completeSections)
				[self loadSections];
			if (!completeText)
				[self fillText];
			if (!completeHtml)
				[self fillHtml];
		}
		else if (ID > -1)
			[self fillDescriptionFromFile];
	}
	if (completeHtml)
		[self releaseRawData];
	/*
	if (!searchPage)
	{
		NSString *nextString = [NSString stringWithFormat:@" | <a href='cache://cache/%@'>Next</a><br><br>\n", 
								  [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
		fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-1.htm", 
					[wpedia documentDirectory],
					[[wpedia lastArticleTitle] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
			[fileHandle seekToEndOfFile];
			[fileHandle writeData:[nextString dataUsingEncoding:NSUTF8StringEncoding]];
			[fileHandle closeFile];
		}
		[fileName release];
		fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-2.htm", 
					[wpedia documentDirectory],
					[[wpedia lastArticleTitle] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
			[fileHandle seekToEndOfFile];
			[fileHandle writeData:[nextString dataUsingEncoding:NSUTF8StringEncoding]];
			[fileHandle closeFile];
		}
		wpedia.lastArticleTitle = [[title lowercaseString] retain];
	}*/
	loading = false;
}

/*
 * reload views after page and images have been downloaded
 */
-(void) reloadViews
{
}

/*
 * load sections from rawHtml
 */
-(void) loadSections
{	
	int count = 1;
	NSString *line, *line2;
	Section *section = [[Section alloc] init];
	NSMutableString *rawHtmlCopy;
	BOOL isCopy = false, foundH2 = false;
	
	NSLog(@"loadSections");
	self.sections = [[NSMutableArray alloc] init];
	[sections release];
	if (completeRawHtml)
	{
		completeSections = true;
		rawHtmlCopy = rawHtml;
	}
	else
	{
		isCopy = true;
		rawHtmlCopy = [rawHtml mutableCopy];
	}
	[sections addObject:section];
	[section release];
	section.title = @"Introduction";
	section.parent = nil;
	section.article = self;
	section.ID = count++;
	if (!completeRawHtml)
		[Texter cleanHtml:rawHtmlCopy];
	NSScanner *scanner = [[NSScanner alloc] initWithString:rawHtmlCopy];
	while (![scanner isAtEnd])
	{
		[scanner scanUpToString:@"\n" intoString:&line];
		[scanner scanString:@"\n" intoString:NULL];
		if ([line rangeOfString:@"<h2"].length > 0 || ([line rangeOfString:@"<h3"].length > 0 && !foundH2))
		{
			if ([line rangeOfString:@"<h2"].length > 0)
				foundH2 = true;
			if ([line rangeOfString:@"</h2"].length == 0)
			{
				if ([scanner scanUpToString:@"\n" intoString:&line2])
					line = [NSString stringWithFormat:@"%@%@", line, line2];
				[scanner scanString:@"\n" intoString:NULL];
			}
			section = [[Section alloc] init];
			[sections addObject:section];
			[section release];
			section.title = [Texter extractText:line start:@"\">" end:@"<"];
			section.parent = nil;
			section.article = self;
			section.ID = count++;
		}
		else if ([line rangeOfString:@"<h1"].length == 0)
			[[section rawHtml] appendFormat:@"%@\n", line];
	}
	for (Section *sec in sections)
		[sec loadSections];
	[scanner release];
	if (isCopy)
		[rawHtmlCopy release];
}

/*
 * produce random articles
 */
+(void) produceRandomArticles
{
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:100];
	Word *word;
	int i;
	
	NSLog(@"produceRandomArticles");
	srandom(time(NULL));
	for (i=0; i<100; i++)
	{
		word = [Word withID:random() % TotalNumberOfWords];
		if (word.articles.count == 0)
			[word loadArticles];
		Article *article = [word.articles objectAtIndex:random() % word.articles.count];
		[article fillTitleFromFile];
		[result addObject:article];
	}
	[result sortUsingSelector:@selector(compareTitle:)];
	[Word consolidateResult:@"random articles" results:result];
	[result release];
}
 
#pragma mark -
#pragma mark Online methods

/*
 * fill the rawHtml from wikipedia then cache it
 */
-(void) fillRawHtmlOnline
{
	NSLog(@"fillRawHtmlOnline");
	offline = false;
	if (rawHtml != nil && rawHtml.length > 0)
		return;
	[NSThread detachNewThreadSelector:@selector(readWebPage) toTarget:self withObject:nil];
	int count = 0;
	connecting = true;
	wasConnecting = true;
	BOOL htmlCheck = true;
	while (htmlCheck && count++ < 13 && connecting)
	{
		if (!foundResultInWikipedia || offline)
		{
			NSLog(@"!foundResultInWikipedia || offline");
			return;
		}
		[NSThread sleepForTimeInterval:1];
		NSLog(@"%d", count);
		if (!completeRawHtml && wholePage.length == 0 && count > 5 && didYouMean.length == 0 && !searchPage)
		{
			NSLog(@"offline");
			offline = true;
			return;
		}
		if (completeRawHtml)
			break;
		if (wholePage)
		{
			htmlCheck = [wholePage rangeOfString:@"Wikipedia does not have an article with this exact name"].length > 0 
				|| [wholePage rangeOfString:@"<p>This page has been deleted."].length > 0 
				|| (!([wholePage rangeOfString:@"<p>"].length > 0) && !([wholePage rangeOfString:@"<li>"].length > 0))
				|| [wholePage rangeOfString:@"searchdidyoumean\">Did you mean:"].length > 0;
		}
		else
			htmlCheck = true;
	}
	NSLog(@"fillRawHtmlOnline out!");
	if (searchPage)
		while (count++ < 10 && connecting)
		{
			if (!foundResultInWikipedia)
				return;
			[NSThread sleepForTimeInterval:1];
			NSLog(@"*");
		}
	if (!completeRawHtml && !offline)
	{
		[NSThread sleepForTimeInterval:1];
		NSLog(@"%d", ++count);
	}
	while (loading)
	{
		[NSThread sleepForTimeInterval:1];
	}
}

/*
 * read the web page from wikipedia.org according to the title
 */
-(void) readWebPage
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString *pageTitle = title;
	NSString *urlAddress;

	connecting = true;
	completeDownloadImages = false;
	imagesViewed = false;
	loading = false;
	wasConnecting = true;
	foundResultInWikipedia = true;
	offline = false;
	inBody = false;
	inJumpTo = false;
	inFooter = false;
	inTOC = false;
	inMetaData = false;
	//foundNewLine = false;
	inSisterProject = false;
	inExternalLinks = false;
	inDev = 0;
	self.rawHtml = [[NSMutableString alloc] init];
	[rawHtml release];
	self.linePart = @"";
	self.wholePage = [[NSMutableString alloc] init];
	[wholePage release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = true;
	if (didYouMean.length > 0)
		pageTitle = didYouMean;
	NSLog(@"readWebPage: %@", pageTitle);
	if (searchPage)
		urlAddress = [[NSString alloc] initWithFormat:
						@"http://en.wikipedia.org/w/index.php?title=Special:Search&limit=20&offset=%dns0=1&redirs=0&search=%@", 
							(pageNumber*20), 
							[pageTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	else
		urlAddress = [[NSString alloc] initWithFormat:@"http://en.wikipedia.org/wiki/%@", 
					  [pageTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
	NSLog(@"viewMode: %d", viewMode);
	NSLog(@"urlAddress: %@", urlAddress);
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlAddress] 
								cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[urlAddress release];
	[request release];
	[[NSRunLoop currentRunLoop] run];
	[urlConnection release];
	
	[pool drain];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

/*
 * this method is called when the server has determined that it
 * has enough information to create the NSURLResponse
 */
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//NSLog(@"connection response: %@", response);
}

int gcounter = 0;

/*
 * append the new data to the receivedData
 * receivedData is declared as a method instance elsewhere
 */
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	int i;
	NSString *line, *cleanLinePart;
	NSMutableString *cleanLine = [[NSMutableString alloc] init];
	NSString *stringData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

	if (!stringData || stringData.length == 0)
	{
		[cleanLine release];
		return;
	}
	[wholePage appendString:stringData];
	if ([wholePage rangeOfString:@"</title>"].length > 0 && [wholePage rangeOfString:@"Wikipedia"].length == 0)
	{
		NSLog(@"offline, not Wikipedia page!");
		offline = true;
		[rawHtml setString:@""];
		[connection cancel];
		[cleanLine release];
		return;
	}
	offline = false;
	if ([wholePage rangeOfString:@"Wikipedia does not have an article with this exact name"].length > 0)
	{
		NSLog(@"connection didReceiveData: it is a search page");
		[rawHtml setString:@""];
		searchPage = true;
		[connection cancel];
		[cleanLine release];
		[NSThread detachNewThreadSelector:@selector(readWebPage) toTarget:self withObject:nil];
		//[stringData release];
		return;
	}
	//NSScanner *scanner = [[NSScanner alloc] initWithString:stringData];
	//ine = [NSString stringWithFormat:@"%@%@", linePart, line];
	stringData = [NSString stringWithFormat:@"%@%@", linePart, stringData];
	NSArray *lines = [stringData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	//while (![scanner isAtEnd] && ([line rangeOfString:@"</html>"].length == 0))
	//for (NSString *line in lines)
	for (i=0; i<lines.count-1; i++)
	{
		line = [lines objectAtIndex:i];
		if ([line rangeOfString:@"<div"].length > 0 && inSisterProject)
			inDev++;
		if ([line rangeOfString:@"infobox sisterproject"].length > 0 && [line rangeOfString:@"<div"].length > 0)
		{
			inDev = 1; 
			inSisterProject = true;
		}
		if ([line rangeOfString:@"</div>"].length > 0 && inSisterProject)
			inDev--;
		/*
		if ([line rangeOfString:@"jump"].length > 0)
		{
			NSLog(@"line with jump: %@", line);
			//inBody = true;
			//inJumpTo = true;
		}*/
		if ([line rangeOfString:@"<div id=\"jump-to-nav\">"].length > 0)
		{
			inBody = true;
			inJumpTo = true;
		}
		if ([line rangeOfString:@"<h2>"].length > 0 || [line rangeOfString:@"<h3>"].length > 0 
			|| [line rangeOfString:@"<table class=\"infobox\""].length > 0)
			inBody = true;
		if ([line rangeOfString:@"<h2"].length > 0 && ([line rangeOfString:@"References"].length > 0 
													   || [line rangeOfString:@"Notes"].length > 0))
			inFooter = true;
		if ([line rangeOfString:@"<div class=\"printfooter\">"].length > 0)
			inFooter = true;
		if ([line rangeOfString:@"<table id=\"toc\" class=\"toc\">"].length > 0)
			inTOC = true;
		if ([line rangeOfString:@"<table class=\"metadata"].length > 0)
			inMetaData = true;
		NSScanner *lineScanner;
		[cleanLine setString:line];
		while ([cleanLine rangeOfString:@"["].length > 0 && [cleanLine rangeOfString:@"]"].length > 0)
		{
			lineScanner = [[NSScanner alloc] initWithString:[NSString stringWithString:cleanLine]];
			[cleanLine setString:@""];
			if ([lineScanner scanUpToString:@"[" intoString:&cleanLinePart])
				[cleanLine appendString:cleanLinePart];
			[lineScanner scanUpToString:@"]" intoString:NULL];		
			[lineScanner scanString:@"]" intoString:NULL];	
			if ([lineScanner scanUpToString:@"\n" intoString:&cleanLinePart])
				[cleanLine appendString:cleanLinePart];	
			[lineScanner release];
		}
		if ([cleanLine rangeOfString:@"<li"].length > 0 && [cleanLine rangeOfString:@"\"external text\""].length > 0 
			&& [cleanLine rangeOfString:@"</a>"].length > 0 && inExternalLinks && !inSisterProject && inDev == 0)
		{
			[rawHtml appendFormat:@"%@\n", cleanLine];
		}
		if ([cleanLine rangeOfString:@"<h2"].length > 0 && ([cleanLine rangeOfString:@"External links"].length > 0))
		{
			inExternalLinks = true;
			[rawHtml appendFormat:@"%@\n", cleanLine];
		}
		else if (inBody && !inJumpTo && !inFooter && !inTOC && !inMetaData && !inSisterProject)
		{
			[rawHtml appendFormat:@"%@\n", cleanLine];
		}
		else if ([cleanLine rangeOfString:@"<h1"].length > 0)
			[rawHtml appendFormat:@"%@\n", line];
		if ([cleanLine rangeOfString:@"</div>"].length > 0 && inJumpTo)
			inJumpTo = false;
		if ([cleanLine rangeOfString:@"</table>"].length > 0 && inTOC)
			inTOC = false;
		if ([cleanLine rangeOfString:@"</table>"].length > 0 && inMetaData)
			inMetaData = false;
		if (inDev == 0 && inSisterProject)
			inSisterProject = false;
	}
	unichar chr = [stringData characterAtIndex:stringData.length-1];
	//NSLog(@"chr: %d %c", chr, chr);
	self.linePart = [lines objectAtIndex:lines.count-1];
	//NSLog(@"linePart: %@", linePart);
	if (chr == 10 || chr == 13) // line not cut
	{
		self.linePart = [NSString stringWithFormat:@"%@\n", linePart];
		//NSLog(@"line not cut, linePart: %@", linePart);
	}
	[cleanLine release];
}

/*
 * connection has error
 */
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection error: %@", error);
	offline = true;
	connecting = false;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
}

/*
 * connection finished loading
 */
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connectionDidFinishLoading");
	if (rawHtml.length == 0)
	{
		self.rawHtml = [wholePage mutableCopy];
	//	NSLog(@"rawHtml retainCount: %d", [rawHtml retainCount]);
		[rawHtml release];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = false;
	connecting = false;
	[self refineRawHtml];
}

/*
 * connection got redirected
 */
-(NSURLRequest *) connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	return request;
}
@end
