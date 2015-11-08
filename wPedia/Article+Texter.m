#import "Article.h"

@implementation Article (Texter)

#pragma mark -
#pragma mark refining methods

/*
 * refine rawHtml
 */
-(void) refineRawHtml
{
	NSString *url;
	NSString *imageName = @"";
	NSString *searchStr, *token;
	NSScanner *scanner;
	NSMutableArray *urls = [[NSMutableArray alloc] init];
	NSMutableArray *imageNames = [[NSMutableArray alloc] init];
	
	NSLog(@"refineRawHtml");
	while (loading)
	{
		NSLog(@"refineRawHtml wating for loading");
		[NSThread sleepForTimeInterval:1];
	}
	loading = true;
	self.didYouMean = @"";
	//[didYouMean release];
	//NSLog(@"didYouMean.length: %d", didYouMean.length);
	if (searchPage)
	{
		NSLog(@"refineRawHtml it is a searchPage.");
		if ([wholePage rangeOfString:@"Did you mean:"].length > 0)
		{
			NSLog(@"did you mean!");
			scanner = [[NSScanner alloc] initWithString:wholePage];
			searchStr = @"title=\"Special:Search\">";
			[scanner scanUpToString:searchStr intoString:NULL];
			[scanner scanString:searchStr intoString:NULL];
			if ([scanner scanUpToString:@"</a>" intoString:&token])
				self.didYouMean = [token stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@""];
			NSLog(@"didYouMean: %@", didYouMean);
			[scanner release];
			if ([wholePage rangeOfString:@"previous 20"].length == 0)
			{
				viewMode = ViewModeDescription;
				//searchPage = false;
				[rawHtml setString:@""];
				loading = false;
				[urls release];
				[imageNames release];
				[self readWebPage];
				return;
			}
		}
		else if ([wholePage rangeOfString:@"<p>There were no results matching the query."].length > 0)
		{
			NSLog(@"There were no results matching the query.");
			[rawHtml setString:@""];
			foundResultInWikipedia = false;
			[urls release];
			[imageNames release];
			loading = false;
			return;
		}
	}
	else
	{
		[Texter cleanHtml:rawHtml];
		scanner = [[NSScanner alloc] initWithString:rawHtml];
		searchStr = @"src=\"http:";
		while (![scanner isAtEnd])
		{
			[scanner scanUpToString:searchStr intoString:NULL];
			[scanner scanString:@"src=\"" intoString:NULL];
			if (![scanner scanUpToString:@"\"" intoString:&url])
				break;
			NSScanner *urlScan = [[NSScanner alloc] initWithString:url];
			while (![urlScan isAtEnd])
			{
				imageName = @"";
				[urlScan scanUpToString:@"/" intoString:&imageName];
				[urlScan scanString:@"/" intoString:NULL];
			}
			NSMutableString *mImageName = [[NSMutableString alloc] initWithString:imageName];
			[mImageName replaceOccurrencesOfString:@"%" withString:@"" options:0 range:NSMakeRange(0, imageName.length)];
			[rawHtml replaceOccurrencesOfString:url withString:[NSString stringWithFormat:@"images/%@", mImageName] options:0 range:NSMakeRange(0,rawHtml.length)];
			[urls addObject:url];
			[imageNames addObject:mImageName];
			[mImageName release];
			[urlScan release];
		}
		[scanner release];
	}
	if (searchPage)
	{
		[self fillDescriptionFromRawHtml];
		if (!searchPage)
		{
			[rawHtml setString:@""];
			loading = false;
			[self readWebPage];
			return;
		}
		completeRawHtml = true;
		loading = false;
		[self releaseRawData];
	}
	else
	{
		completeRawHtml = true;
		[self fillDescriptionFromRawHtml];
		[self loadSections];
		[self fillText];
		[self fillHtml];
		[self writeNavigation];
		[self releaseRawData];
		loading = false;
		[Article downloadImages:urls imageNames:imageNames];
		completeDownloadImages = true;
		//[self reloadViews];
	}
	//[self reloadViews];
	//NSLog(@"url retainCount: %d", [url retainCount]);
	[urls release];
	//NSLog(@"url retainCount: %d", [url retainCount]);
	[imageNames release];
}

/*
 * write navigation info to html files
 */
-(void) writeNavigation
{
	int i;
	
	NSLog(@"writeNavigation: %@, %@", previousArticle, title);
	
	self.previousArticle = [wpedia lastArticleTitle];
	[wpedia setLastArticleTitle:[title lowercaseString]];
	[wpedia saveHistory];
	NSString *navString = [NSString stringWithFormat:@"&nbsp;&nbsp;<a href='cache://cache/%@'>Previous</a> |", 
						   [previousArticle stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
	NSString *fileName = nil;
	for (i=1; i<=2; i++)
	{
		if (fileName)
			[fileName release];
		fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-%d.htm", 
					[wpedia documentDirectory],
					[[title lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"], i];
		if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			if (![previousArticle isEqualToString:[title lowercaseString]])
			{
				NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
				[fileHandle seekToEndOfFile];
				[fileHandle writeData:[navString dataUsingEncoding:NSUTF8StringEncoding]];
				[fileHandle closeFile];
			}
		}
		else
			return;
	}
	if (![previousArticle isEqualToString:[title lowercaseString]])
	{
		navString = [NSString stringWithFormat:@" <a href='cache://cache/%@'>Next</a><br><br><br><br>\n", 
					 [[title lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
		for (i=1; i<=2; i++)
		{
			[fileName release];
			fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-%d.htm", 
						[wpedia documentDirectory],
						[previousArticle stringByReplacingOccurrencesOfString:@" " withString:@"_"], i];
			if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
			{
				NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
				[fileHandle seekToEndOfFile];
				[fileHandle writeData:[navString dataUsingEncoding:NSUTF8StringEncoding]];
				[fileHandle closeFile];
			}
		}
	}
	self.previousArticle = nil;
}

/*
 * download images from the rawHtml file
 */
+(void) downloadImages:(NSMutableArray *)urls imageNames:(NSMutableArray *)imageNames
{
	int i;
	NSString *fileName;
	NSData *data;

	NSLog(@"downloadImages");
	for (i=0; i<urls.count; i++)
	{
		fileName = [[NSString alloc] initWithFormat:@"%@/images/%@", [wpedia documentDirectory], [imageNames objectAtIndex:i]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urls objectAtIndex:i]]];
			[data writeToFile:fileName atomically:true];
			[data release];
		}
		[fileName release];
	}
	NSLog(@"done downloadImages");
}

#pragma mark -
#pragma mark filling methods

/*
 * fill title from article.txt file
 */
-(void) fillTitleFromFile
{
	int offset;
	FILE *file;

	//NSLog(@"fillTitleFromFile for article ID:%d", ID);
	@try
	{
		NSString *fileName=[[NSBundle mainBundle] pathForResource:@"article" ofType:@"txt"];
		file = fopen([fileName UTF8String], "rt");
		offset = ID;
		fseeko(file, offset, SEEK_SET);
		self.title = [Texter readLineFromFile:file];
	}
	@catch (NSException *ex) 
	{
		NSLog(@"fillTitleFromFile Exception: %@", ex);
	}
	fclose(file);
}

/*
 * fill article description from article.txt file
 */
-(void) fillDescriptionFromFile
{
	NSMutableString *description = [[NSMutableString alloc] init];
	int offset;
	FILE *file;
	NSString *line;

	NSLog(@"fillDescriptionFromFile for article ID:%d", ID);
	NSString *articleFileName = [[NSBundle mainBundle] pathForResource:@"article" ofType:@"txt"];
	file = fopen([articleFileName UTF8String], "rt");
	offset = ID;
	fseeko(file, offset, SEEK_SET);
	line = [Texter readLineFromFile:file];
	self.title = line;
	NSLog(@"title: %@", title);
 
	[description appendFormat:@"%@\n", [self getHeader]];
	line = [Texter readLineFromFile:file];
	while (![line isEqualToString:@"."])
	{
		if ([line rangeOfString:@"*"].location == 0)
			[description appendFormat:@"%@\n",line];
		else
			[description appendFormat:@"<p>%@</p>\n",line];
		line = [Texter readLineFromFile:file];
	}
	[description replaceOccurrencesOfString:@".\n" withString:@".<br><br>\n" options:0 range:NSMakeRange(0, description.length)];
	[description replaceOccurrencesOfString:@":\n" withString:@":<br><br>\n" options:0 range:NSMakeRange(0, description.length)];
	[description replaceOccurrencesOfString:@"\n*" withString:@"\n<li>" options:0 range:NSMakeRange(0, description.length)];
	[description replaceOccurrencesOfString:@"[" withString:@"<sb>" options:0 range:NSMakeRange(0, description.length)];
	[description replaceOccurrencesOfString:@"]" withString:@"</sb>" options:0 range:NSMakeRange(0, description.length)];
	[description replaceOccurrencesOfRegex:@"<sb>([^>]*)</sb>" withString:@"<a href='/wiki/$1'>$1</a>"];
	//[description appendString:@"<br><br></body>\n"];
	[description appendString:[self getFooter]];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-0-o.htm", [wpedia documentDirectory],
						  [[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[description writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[description release];
	fclose(file);
}

/*
 * fill article.description from rawHtml
 */
-(void) fillDescriptionFromRawHtml
{
	NSString *fileName;
	NSMutableString *description = [[NSMutableString alloc] init];
	//NSLog(@"fillDescriptionFromRawHtml");

	NSString *line;
	NSMutableString *rawHtmlCopy;
	NSScanner *scanner;
	int insideTable = 0;//, insideDiv = 0;
	BOOL foundParagraph = false, descriptionEnd = false;

	if (completeRawHtml)
		completeDescription = true;
	NSLog(@"fillDescriptionFromRawHtml title: %@", title);
	//[description setString:@""];
	if (searchPage)
	{
		[description release];
		[self fillSearchResultsPage];
		return;
	}
	if ([title rangeOfString:@":"].length > 0)
	{
		[description release];
		[self fillSpecialPage];
		return;
	}
	[description appendFormat:@"%@\n", [self getHeader]];
	if (!completeRawHtml)
	{
		NSLog(@"!completeRawHtml");
		rawHtmlCopy = [rawHtml mutableCopy];
		[Texter cleanHtml:rawHtmlCopy];
		scanner = [[NSScanner alloc] initWithString:rawHtmlCopy];
		[rawHtmlCopy release];
	}
	else
		scanner = [[NSScanner alloc] initWithString:rawHtml];
	while (![scanner isAtEnd] && !descriptionEnd)
	{ 
		[scanner scanUpToString:@"\n" intoString:&line];
		[scanner scanString:@"\n" intoString:NULL];
		if ([line rangeOfString:@"<table"].length > 0)
			insideTable++;
		if ([line rangeOfString:@"</table"].length > 0)
			insideTable--;
		if (insideTable == 0 && ([line rangeOfString:@"<p>"].length > 0 || [line rangeOfString:@"</p>"].length > 0 || [line rangeOfString:@"<li>"].length > 0))
		{
			foundParagraph = true;
			[description appendString:line];
		}
		if (foundParagraph && ([line rangeOfString:@"<table"].length > 0 || [line rangeOfString:@"<h2"].length > 0) && [line rangeOfString:@"\"infobox\""].length == 0)
			descriptionEnd = true;
	}
	//[description appendString:@"<br><br></body>\n"];
	[description appendString:[self getFooter]];
	fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-0.htm",
				[wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[description writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[scanner release];
	[description release];
}

/*
 * get full text from description and sections for this article
 */
-(void) fillText
{
	NSMutableString *text = [[NSMutableString alloc] init];
	NSLog(@"fillText");
	
	if (completeSections)
		completeText = true;
	if (searchPage)
	{
		[text release];
		return;
	}
	if ([title rangeOfString:@":"].length > 0)
	{
		NSLog(@"it is a pecial page");
		specialPage = true;
		[text release];
		return;
	}
	[text appendFormat:@"%@\n", [self getHeader]];
	[text appendString:@"<table border=0 cellpadding=0 cellspacing=0>\n"];
	for (Section *sec in sections)
	{
		[text appendString:@"<tr><td>\n"];
		[text appendString:[sec fillText]];
		[text appendString:@"</td></tr>\n"];
	}
	[text appendString:@"</table>\n"];
	//[text appendString:@"<br><br></body>\n"];
	[text appendString:[self getFooter]];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-1.htm", 
						  [wpedia documentDirectory],
						  [[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[text writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[text release];
}

/*
 * fill full html from rawHtml and sections for this article
 */
-(void) fillHtml
{
	NSMutableString *html = [[NSMutableString alloc] init];	
	NSLog(@"fillHtml");

	if (completeSections)
		completeHtml = true;
	if (searchPage)
	{
		[html release];
		return;
	}
	if ([title rangeOfString:@":"].length > 0)
	{
		NSLog(@"it is a pecial page");
		specialPage = true;
		[html release];
		return;
	}
	[html appendFormat:@"%@\n", [self getHeader]];
	[html appendString:@"<table border=0 cellpadding=0 cellspacing=0>\n"];
	for (Section *sec in sections)
	{
		[html appendString:@"<tr><td>\n"];
		[html appendString:[sec fillHtml]];
		[html appendString:@"</td></tr>\n"];
	}
	[html appendString:@"</table>\n"];
	//[html appendString:@"<br><br></body>\n"];
	[html appendString:[self getFooter]];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-2.htm", 
						  [wpedia documentDirectory],
						  [[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[html writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[html release];
}

/*
 * fill search page if this article is a search results
 */
-(void) fillSearchResultsPage
{
	NSString *line = @"", *token, *lcToken;
	NSMutableString *result = [[NSMutableString alloc] init];
	NSMutableString *rawHtmlCopy;
	NSScanner *scanner;
	
	NSLog(@"fillSearchResultsPage");
	
	rawHtmlCopy = [rawHtml mutableCopy];
	[Texter cleanHtml:rawHtmlCopy];
	[result appendFormat:@"%@\n", [self getHeader]];
	if ([rawHtmlCopy rangeOfString:@">next 20</a>"].length > 0 || [rawHtmlCopy rangeOfString:@">previous 20</a>"].length > 0)
	{                
		[result appendString:@"<p class='mw-search-pager-bottom'>View ("];
		NSLog(@"pageNumber: %d", pageNumber);
		if (pageNumber > 0)
			[result appendFormat:@"<a href='wpedia://wpedia?%@&%d'>previous 20</a>", 
			 [title stringByReplacingOccurrencesOfString:@" " withString:@"_"], (pageNumber - 1)];
		else
			[result appendString:@"previous 20"];
		[result appendString:@" | "];
		if ([rawHtmlCopy rangeOfString:@">next 20</a>"].length > 0)
			[result appendFormat:@"<a href='wpedia://wpedia?%@&%d'>next 20</a>", 
			 [title stringByReplacingOccurrencesOfString:@" " withString:@"_"], (pageNumber + 1)];
		else
			[result appendString:@"next 20"];
		[result appendString:@")</p>\n"];
	}
	[result appendString:@"<div class='searchresults'><ul class='mw-search-results'>\n"];
	if (didYouMean.length > 0)
		[result appendFormat:@"<li><a href=/wiki/%@>%@</a></li>\n", 
			[didYouMean stringByReplacingOccurrencesOfString:@" " withString:@"_"], [Texter uppercaseFirst:didYouMean]];
	scanner = [[NSScanner alloc] initWithString:rawHtmlCopy];
	while (![scanner isAtEnd])
	{
		[scanner scanUpToString:@"\n" intoString:&line];
		[scanner scanString:@"\n" intoString:NULL];
		if ([line rangeOfString:@"<div class=\"mw-search-formheader\">"].length > 0)
			continue;
		if ([line rangeOfString:@"<li>"].length > 0 && [line rangeOfString:@"/wiki/"].length > 0)
		{
			NSScanner *lineScanner = [[NSScanner alloc] initWithString:line];
			[lineScanner scanUpToString:@"/wiki/" intoString:NULL];
			[lineScanner scanString:@"/wiki/" intoString:NULL];
			token = @"";
			[lineScanner scanUpToString:@"\"" intoString:&token];
			[lineScanner release];
			token = [token stringByReplacingOccurrencesOfString:@"_" withString:@" "];
			lcToken = [token lowercaseString];
			if ([[title lowercaseString] isEqualToString:lcToken])
			{
				NSLog(@"nope, it is not a searchPage, after all!");
				searchPage = false;
				self.title = token;
				[result release];
				[scanner release];
				[rawHtmlCopy release];
				return;
			}
			[result appendFormat:@"%@</li>\n", line];
		}
	}
	[result appendString:@"</ul></div>\n"];
	if ([rawHtmlCopy rangeOfString:@">next 20</a>"].length > 0 || [rawHtmlCopy rangeOfString:@">previous 20</a>"].length > 0)
	{            
		[result appendString:@"<p class='mw-search-pager-bottom'>View ("];
		NSLog(@"pageNumber: %d", pageNumber);
		if (pageNumber > 0)
			[result appendFormat:@"<a href='wpedia://wpedia?%@&%d'>previous 20</a>", 
				[title stringByReplacingOccurrencesOfString:@" " withString:@"_"], (pageNumber - 1)];
		else
			[result appendString:@"previous 20"];
		[result appendString:@" | "];
		if ([rawHtmlCopy rangeOfString:@">next 20</a>"].length > 0)
			[result appendFormat:@"<a href='wpedia://wpedia?%@&%d'>next 20</a>", 
				[title stringByReplacingOccurrencesOfString:@" " withString:@"_"], (pageNumber + 1)];
		else
			[result appendString:@"next 20"];
		[result appendString:@")</p>\n"];
	}
	[result appendString:@"<br><br></body>\n"];
	[result replaceOccurrencesOfRegex:@"class='[^']*'" withString:@""];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@&%d.htm",
				[wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString],
				pageNumber];
	[result writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[result release];
	[scanner release];
	[rawHtmlCopy release];
}

/*
 * fill special page, like Portal page.
 */
-(void) fillSpecialPage
{
	NSString *line = @"";
	NSMutableString *result = [[NSMutableString alloc] init];
	NSMutableString *rawHtmlCopy;

	NSLog(@"fillSpecialPage");
	specialPage = true;
	descriptionWebView.scalesPageToFit = true;
	rawHtmlCopy = [rawHtml mutableCopy];
	[Texter cleanHtml:rawHtmlCopy];
	[result appendFormat:@"%@\n", [self getHeader]];
	NSScanner *scanner = [[NSScanner alloc] initWithString:rawHtmlCopy];
	while (![scanner isAtEnd])
	{
		if ([scanner scanUpToString:@"\n" intoString:&line])
		{
			if ([line rangeOfString:@"<h1"].length == 0)
				[result appendFormat:@"%@</li>\n", line];
		}
		[scanner scanString:@"\n" intoString:NULL];
	}
	//[result appendString:@"<br><br></body>"];
	[result replaceOccurrencesOfRegex:@"class='[^']*'" withString:@""];
	[result appendString:[self getFooter]];
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-2.htm",
				[wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[result writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
	[rawHtmlCopy release];
	[scanner release];
	[result release];
}

/*
 * get the output page header
 */
-(NSString *) getHeader
{
	NSString *result;
	
	result = @"<head>\n"
			@"<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />\n"
			@"<link rel='stylesheet' href='css/shared.css' type='text/css' />\n"
			@"<link rel='stylesheet' href='css/main.css' type='text/css' />\n"
			@"<link rel='stylesheet' href='css/common.css' type='text/css' media='all' />\n"
			@"<script src='wpediaScript.js' type='text/javascript'></script>\n"
			@"</head>\n"
			@"<body onload='init()'>\n";
	result = [NSString stringWithFormat:@"%@<h2>%@</h2>", result, title];
	return result;
}

/*
 * get the output page footer
 */
-(NSString *) getFooter
{
	NSString *result;
	
	result = [NSString stringWithFormat:@"<hr>&nbsp;&nbsp;<font size=2>URL: <a href=http://en.wikipedia.org/wiki/%@>http://en.wikipedia.org/wiki/%@</a></font>\n", 
			  [title stringByReplacingOccurrencesOfString:@" " withString:@"_"], 
			  [title stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
	result = [NSString stringWithFormat:@"%@<hr>\n&nbsp;&nbsp;<input id=btn_search type=button value=Search onClick='searchPrompt();' />\n",
			  result];
	return result;
}
@end
