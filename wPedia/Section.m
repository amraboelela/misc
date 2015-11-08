#import "Section.h"
#import "Article.h"

@implementation Section

@synthesize level, ID;
@synthesize title, rawHtml;
@synthesize parent;
@synthesize article;
@synthesize sections;

-(id) init
{
	self = [super init];
	level = 1;
	ID = 0;
	title = [[NSString alloc] init];
	rawHtml = [[NSMutableString alloc] init];
	sections = [[NSMutableArray alloc] init];
	return self;
}

#pragma mark -
#pragma mark release methods

-(void) dealloc
{
	[title release];
	[rawHtml release];
	[sections release];
	[super dealloc];
}

#pragma mark -
#pragma mark loading methods

/*
 * load sections from rawHtml
 */
-(void) loadSections
{
	if (level == 3) // maximum 3 level processing
		return;
	Section *section;
	NSString *line = @"", *line2;
	NSString *hNumber = @"";
	NSScanner *scanner = [[NSScanner alloc] initWithString:rawHtml];
	int count = 1;
	
	//if (parent == nil || ![parent.title isEqualToString: @"Introduction"])
	//{
		section = [[Section alloc] init];
		[sections addObject:section];
		[section release];
		section.title = @"Introduction";
		section.level = level + 1;
		section.parent = self;
		section.article = article;
		section.ID = count++;
	//}
	while (![scanner isAtEnd])
	{
		[scanner scanUpToString:@"\n" intoString:&line];
		[scanner scanString:@"\n" intoString:NULL];
		if ([line rangeOfString:[NSString stringWithFormat:@"<h%@", hNumber]].length > 0)	
		{
			if ([line rangeOfString:[NSString stringWithFormat:@"</h%@", hNumber]].length == 0)
			{
				if ([scanner scanUpToString:@"\n" intoString:&line2])
					line = [NSString stringWithFormat:@"%@%@", line, line2];
				[scanner scanString:@"\n" intoString:NULL];
			}
			hNumber = [Texter extractText:line start:@"<h" end:@">"];
			if (![Texter isNumeric:hNumber])
				continue;
			section = [[Section alloc] init];
			[sections addObject:section];
			[section release];
			line = [line stringByReplacingOccurrencesOfString:@"<i>" withString:@""];
			line = [line stringByReplacingOccurrencesOfString:@"</i>" withString:@""];
			section.title = [Texter extractText:line start:@"\">" end:@"<"];
			section.level = level + 1;
			section.parent = self;
			section.article = article;
			section.ID = count++;
		}
		else
			[[section rawHtml] appendFormat:@"%@\n", line];
	}
	if (sections.count > 0)
	{
		Section *firstSection = [sections objectAtIndex:0];
		if (sections.count == 1 && [firstSection.title isEqualToString:@"Introduction"])
			[sections removeObjectAtIndex:0];
	}
	for (Section *sec in sections)
		[sec loadSections];
	[scanner release];
}

/*
 * get text output (no tables nor divs) from this section description and subsections
 */
-(NSString *) fillText
{
	int tableCount = 0, divCount = 0;
	BOOL empty = true;
	BOOL infoBox = false, inDiv = false;
	NSString *line = @"";
	NSString *subsectionText;
	NSScanner *scanner = [[NSScanner alloc] initWithString:rawHtml];
	NSMutableString *result = [[NSMutableString alloc] init];

	if (level > 1 || article.sections.count > 1)
		[result appendString:[self fillHeader]];
	if (sections.count == 0)
	{
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=2><tr><td>\n"];
		while (![scanner isAtEnd] && ![line isMatchedByRegex:@"<h[3-5]>"])
		{
			[scanner scanUpToString:@"\n" intoString:&line];
			[scanner scanString:@"\n" intoString:NULL];
			if ([line rangeOfString:@"<table class=\"infobox"].length > 0)
				infoBox = true;
			if (infoBox)
			{
				if ([line rangeOfString:@"<table"].length > 0)
					tableCount++;
				if ([line rangeOfString:@"</table>"].length > 0)
					tableCount--;
				if (tableCount == 0)
				{
					infoBox = false;
					continue;
				}
			}
			if ([line rangeOfString:@"<div"].length > 0 && ([line rangeOfString:@"class="].length > 0 || [line rangeOfString:@"id="].length > 0))
				inDiv = true;
			if (inDiv)
			{
				if ([line rangeOfString:@"<div"].length > 0)
					divCount++;
				if ([line rangeOfString:@"</div"].length > 0)
					divCount--;
				if (divCount == 0)
				{
					inDiv = false;
					continue;
				}
			}
			if (!infoBox && !inDiv && ![line isMatchedByRegex:@"<h[3-5]>"] && [line rangeOfString:@"<div"].length == 0 && [line rangeOfString:@"</div"].length == 0)
			{
				empty = false;
				[result appendFormat:@"%@\n", line];
			}
		}
		if (empty)
		{
			[scanner release];
			[result release];
			return @"";
		}
	}
	else
	{
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=0><tr><td nowrap>&nbsp;&nbsp;</td><td>\n"];
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=0>\n"];
		for (Section *sec in sections)
		{
			subsectionText = [sec fillText];
			if (subsectionText.length > 0)
			{
				[result appendString:@"<tr><td>\n"];
				[result appendString:subsectionText];
				[result appendString:@"</td></tr>\n"];
			}
		}
		[result appendString:@"</table>\n"];
	}
	[result appendString:@"</td></tr></table>\n"];
	if (level > 1 || article.sections.count > 1)
		[result appendString:@"</div>\n"];
	NSString *finalResult = [NSString stringWithString:result];
	[result release];
	[scanner release];
	return finalResult;
}

/*
 * get html output from this section rawHtml and subsections
 */
-(NSString *) fillHtml
{
	BOOL empty = true;
	int pixels = 0;
	NSString *line = @"";
	NSString *subLine;
	NSString *subsectionHtml;
	NSScanner *scanner = [[NSScanner alloc] initWithString:rawHtml];
	NSMutableString *result = [[NSMutableString alloc] init];
	
	if (level > 1 || article.sections.count > 1)
		[result appendString:[self fillHeader]];
	if (sections.count == 0)
	{
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=2><tr><td>\n"];
		while (![scanner isAtEnd] && ![line isMatchedByRegex:@"<h[3-5]>"])
		{
			[scanner scanUpToString:@"\n" intoString:&line];
			[scanner scanString:@"\n" intoString:NULL];
			if (![line isMatchedByRegex:@"<h[3-5]>"])
			{
				if ([line rangeOfRegex:@"width:[2-9][0-9][0-9]*px;"].length > 0)
				{
					NSScanner *lineScanner = [[NSScanner alloc] initWithString:line];
					if ([lineScanner scanUpToString:@"width:" intoString:&subLine])
						[result appendFormat:@"%@width:", subLine];
					[lineScanner scanString:@"width:" intoString:NULL];
					if ([lineScanner scanUpToString:@"px" intoString:&subLine])
					{
						pixels = subLine.intValue;
						if (pixels > 290)
							pixels = 290;
						[result appendFormat:@"%d", pixels];
					}
					else
						[result appendFormat:@"%d", 50];
					if ([lineScanner scanUpToString:@"width=\"" intoString:&subLine])
						[result appendFormat:@"%@width=\"", subLine];
					[lineScanner scanString:@"width=\"" intoString:NULL];
					if ([lineScanner scanUpToString:@"\"" intoString:&subLine])
					{
						pixels = subLine.intValue;
						if (pixels > 290)
							pixels = 290;
						[result appendFormat:@"%d", pixels];
					}
					else
						[result appendFormat:@"%d", 50];
					if ([lineScanner scanUpToString:@"\n" intoString:&subLine])
						[result appendFormat:@"%@\n", subLine];
					[lineScanner release];
				}
				else
					[result appendFormat:@"%@\n", line];
				empty = false;
			}
		}
		if (empty)
		{
			[scanner release];
			[result release];
			return @"";
		}
	}
	else
	{
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=0><tr><td nowrap>&nbsp;&nbsp;</td><td>\n"];
		[result appendString:@"<table border=0 cellpadding=0 cellspacing=0>\n"];
		for (Section *sec in sections)
		{
			subsectionHtml = [sec fillHtml];
			if (![subsectionHtml isEqualToString:@""])
			{
				[result appendString:@"<tr><td>\n"];
				[result appendString:subsectionHtml];
				[result appendString:@"</td></tr>\n"];
			}
		}
		[result appendString:@"</table>\n"];
	}
	[result appendString:@"</td></tr></table>\n"];
	if (level > 1 || article.sections.count > 1)
		[result appendString:@"</div>\n"];
	[scanner release];
	NSString *finalResult = [NSString stringWithString:result];
	[result release];
	return finalResult;
}

/*
 * get the output section header
 */
-(NSString *) fillHeader
{
	NSMutableString *result = [[NSMutableString alloc] init];
	int count = 0;
	NSString *prefix = [[NSString alloc] init];
	NSString *fullID = [self fillFullID];
	if (parent)
	{
		[prefix release];
		prefix = [[NSString alloc] initWithFormat:@"%@-", [parent fillFullID]];
		count = parent.sections.count;
	}
	else
		count = article.sections.count;
	NSString *toggle = [[NSString alloc] initWithFormat:@"<a href=\"javascript:toggle('%@','%d','%d');\">", prefix, ID, count];
	[result appendFormat:@"<table cellpadding=0 cellspacing=0><tr><td nowrap>%@<img border=0 align=middle id='b%@' src='images/plus.png'/></a>\n", toggle, fullID];
	[result appendFormat:@"<font size=4>%@%@</a></font></td></tr></table>\n", toggle, title];
	[result appendFormat:@"<div id='d%@' style='display:none;'>\n", fullID];
	[toggle release];
	[prefix release];
	NSString *finalResult = [NSString stringWithString:result];
	[result release];
	return finalResult;
}

/*
 * get the section full hierarchical ID
 */
-(NSString *) fillFullID
{
	if (parent == nil)
		return [NSString stringWithFormat:@"%d", ID];
	return [NSString stringWithFormat:@"%@-%d", [parent fillFullID], ID];
}
@end
