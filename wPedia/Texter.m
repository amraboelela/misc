#import "Texter.h"

@implementation Texter

static char readlineLine[ReadLineSize];

/*
 * read line from std input
 */
+(NSString *) readline
{
	if (fgets(readlineLine, ReadLineSize, stdin))
	{
		char *newline = strchr(readlineLine, '\n'); /* check for trailing '\n' */
		if (newline)
			*newline = '\0'; /* overwrite the '\n' with a terminating null */
	}
	return [[NSString stringWithCString:readlineLine encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/*
 * readline from file
 */
+(NSString *) readLineFromFile:(FILE *)file
{
	char buffer[4096];

	// tune this capacity to your liking -- larger buffer sizes will be faster, but
	// use more memory
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:256];

	// Read up to 4095 non-newline characters, then read and discard the newline
	int charsRead;
	do
	{
		if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
			[result appendString:[NSString stringWithUTF8String:buffer]];// :@"%s", buffer];
		else
			break;
	} while(charsRead == 4095);
	NSString *finalResult = [NSString stringWithString:result];
	[result release];
	return finalResult;
}

/*
 * check if this str is integer
 */
+(BOOL) isInteger:(NSString *)str
{
	NSScanner *scan = [NSScanner scannerWithString: str];
	return [scan scanInteger:NULL] && [scan isAtEnd];
}

/*
 * check if this str is numeric
 */
+(BOOL) isNumeric:(NSString *)str
{
	NSScanner *scan = [NSScanner scannerWithString: str];
	return [scan scanFloat:NULL] && [scan isAtEnd];
}

/*
 * return extracted text in source between start and end. 
 */
+(NSString *) extractText:(NSString *)source start:(NSString *)start end:(NSString *)end
{
	BOOL found = false;
	NSString *result = @"";
	NSScanner *scanner = [[NSScanner alloc] initWithString:source];
	while (!found && !scanner.isAtEnd)
	{
		[scanner scanUpToString:start intoString:NULL];
		[scanner scanString:start intoString:NULL];
		found = [scanner scanUpToString:end intoString:&result];
		[scanner scanString:end intoString:NULL];
	}
	[scanner release];
	return result;
}

/*
 * clean html page
 */
+(void) cleanHtml:(NSMutableString *)html
{
	NSLog(@"cleanHtml");
	@try
	{
		[Texter removeParenthesis:html];
		[Texter removeSquareBrackets:html];
		[html replaceOccurrencesOfString:@" ," withString:@"," options:0 range:NSMakeRange(0, html.length)];
		[html replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, html.length)];
		[html replaceOccurrencesOfRegex:@"<a href=\"/wiki/File:[^>]*>(.*)</a>" withString:@"$1"];
		[html replaceOccurrencesOfRegex:@"<div class=\"magnify\">.*</div>" withString:@""];
	}
	@catch (NSException *ex)
	{
		NSLog(@"Exception: %@", ex);
	}
}

/*
 * remove parenthesis.
 */
+(void) removeParenthesis:(NSMutableString *)str
{
	int parenthCount = 0, i;
	NSRange range;
	NSScanner *scan = [[NSScanner alloc] initWithString:str];
	
	if ([str rangeOfString:@"(pronounced"].length > 0)
	{
		[scan scanUpToString:@"(pronounced" intoString:NULL];
		range.location = scan.scanLocation;
		for (i = range.location; i < str.length; i++)
		{
			if ([str characterAtIndex:i] == '(')
				parenthCount++;
			if ([str characterAtIndex:i] == ')')
			{
				parenthCount--;
				if (parenthCount == 0)
				{
					range.length = i - range.location + 1;
					break;
				}
			}
		}
		if (parenthCount == 0)
			[str deleteCharactersInRange:range];
	}
	[scan release];
}

/*
 * remove square brackets.
 */
+(void) removeSquareBrackets:(NSMutableString *)str
{
	int parenthCount = 0, i;
	NSRange range;

	range.location = -1;
	range.length = 0;
	while ([str rangeOfString:@"["].length > 0)
	{
		parenthCount = 0;
		range.location = -1;
		for (i=0; i<str.length; i++)
		{
			if ([str characterAtIndex:i] == '[')
			{
				if (parenthCount == 0)
					range.location = i;
				parenthCount++;
			}
			if ([str characterAtIndex:i] == ']')
			{
				if (range.location == -1)
				{
					range.location = i;
					range.length = 1;
					break;
				}
				parenthCount--;
				if (parenthCount == 0)
				{
					range.length = i - range.location + 1;
					break;
				}
			}
		}
		[str deleteCharactersInRange:range];
	}
}

/*
 * make sure that text length is no more than maxLength characters
 */
+(NSString *) shortenText:(NSString *)text maxLength:(int)maxLength
{
	if (!text)
		return @"";
	else if (text.length > maxLength)
		return [text substringToIndex:maxLength];
	else
		return text;
}

/*
 * return the text with first letter uppercase
 */
+(NSString *) uppercaseFirst:(NSString *)text
{
	if (!text || text.length == 0)
		return @"";
	return [NSString stringWithFormat:@"%@%@", [[text substringToIndex:1] uppercaseString], [text substringFromIndex:1]];
}

/*
 * log to file
 */
+(void) log:(NSString *)text
{
	NSString *fileName = [[NSString alloc] initWithFormat:@"%@/log.txt", [wpedia documentDirectory]];
	
	[text writeToFile:fileName atomically:true encoding:NSUTF8StringEncoding error:NULL];
	[fileName release];
}
@end
