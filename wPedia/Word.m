#import "Word.h"

@implementation Word

@synthesize ID;
@synthesize score;
@synthesize value;
@synthesize articles;

#pragma mark -
#pragma mark init methods

-(id) init
{
	self = [super init];
	ID = -1;
	score = 0;
	articles = [[NSMutableArray alloc] init];
	return self;
}

-(id) init:(NSString *)newValue
{
	self = [self init];
	value = [newValue retain];
	return self;
}

-(id) init:(int)newID value:(NSString *)newValue
{
	self = [self init:newValue];
	ID = newID;
	return self;
}

#pragma mark -
#pragma mark release methods

-(void) dealloc
{
	[value release];
	[articles release];
	[super dealloc];
}

#pragma mark -
#pragma mark loading methods

/*
 * get the word with wordID ID from word.txt file
 */
+(Word *) withID:(int)wordID
{
	NSString *bufferStr = @"               ";
	const char *wordChar = [bufferStr cStringUsingEncoding:NSUTF8StringEncoding];
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"word" ofType:@"txt"];
	FILE *file = fopen([fileName UTF8String], "r");
	int offset = wordID * 15;
	fseeko(file, offset, SEEK_SET);
	fread((Ptr)wordChar, 1, 15, file);
	fclose(file);
	bufferStr = [NSString stringWithCString:wordChar encoding:NSUTF8StringEncoding];
	NSString *strWord = [[NSString alloc] initWithString:
						  [bufferStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	Word *word = [[Word alloc] init:wordID value:strWord];
	[strWord release];
	return [word autorelease];
}

/*
 * get the word with wordStr value from word.txt file
 */
+(Word *) withValue:(NSString *)wordStr
{
	Word *result = [Word binarySearch:wordStr];
	if ([result.value isEqualToString:wordStr])
		return result;
	else
		return nil;
}

/*
 * load words starting by startID and with numberOfWords count
 */
+(NSMutableArray *) loadWords:(int)startID numberOfWords:(int)numberOfWords
{
	FILE *file = nil;
	int currentID = startID;
	const char *wordChar;
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:numberOfWords];
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"word" ofType:@"txt"];
	
	file = fopen([fileName UTF8String], "r");
	int offset = currentID * 15;
	fseeko(file, offset, SEEK_SET);
	while ((currentID - startID) < numberOfWords)
	{
		NSString *bufferStr = @"               ";
		wordChar = [bufferStr cStringUsingEncoding:NSUTF8StringEncoding];
		fread((Ptr)wordChar, 1, 15, file);
		bufferStr = [NSString stringWithCString:wordChar encoding:NSUTF8StringEncoding];
		NSString *strWord = [[NSString alloc] initWithString:
							 [bufferStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		Word *word = [[Word alloc] init:currentID value:strWord];
		[strWord release];
		[result addObject:word];
		[word release];
		currentID++;
	}
	fclose(file);
	return result;
}

#pragma mark -
#pragma mark search methods

/*
 * search for string str with exact match and AND condition
 */
+(Article *) search:(NSString *)str
{
	int i;
	NSMutableArray *wordArticles = [[NSMutableArray alloc] initWithCapacity:10];
	NSMutableArray *firstResult, *currentWordArticles;
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
	Article *resultArticle = nil;
	Article *article;
	NSString *IDStr;
	Word *word;

	str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
	NSLog(@"Word search str: %@", str);
	if (![str isMatchedByRegex:@"[a-z]"])
	{
		[wordArticles release];
		[result release];
		return [[[Article alloc] initWithTitle:@"random articles"] autorelease];
	}
	NSArray *words = [str componentsSeparatedByRegex:@"[^a-z]"];
	for (NSString *strWord in words)
	{
		word = [Word withValue:strWord];
		if (!word)//(strWord.length <= 2)
		{
			[wordArticles release];
			[result release];
			return nil;
		}
		/*
		else if (![[word value] isEqualToString:strWord])
		{
			[wordArticles release];
			[result release];
			return nil;
		}*/
		else
		{
			if (word.articles.count == 0)
				[word loadArticles];
			[wordArticles addObject:word.articles];
		}
	}
	if (wordArticles.count > 0)
	{
		firstResult = [wordArticles objectAtIndex:0];
		NSMutableDictionary *articlesDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
		for (article in firstResult)
		{
			IDStr = [NSString stringWithFormat:@"%d", article.ID];
			[articlesDictionary setObject:article forKey:IDStr];
		}
		for (i = 1; i < wordArticles.count; i++)
		{
			currentWordArticles = [wordArticles objectAtIndex:i];
			for (article in currentWordArticles)
			{
				IDStr = [NSString stringWithFormat:@"%d", article.ID];
				Article *foundArticle = [articlesDictionary objectForKey:IDStr];
				if (foundArticle)
					foundArticle.score++;
			}
		}
		for (IDStr in articlesDictionary)
		{
			article = [articlesDictionary objectForKey:IDStr];
			if (article.score == wordArticles.count-1)
				[result addObject:article];
		}
		[Word sortResult:result words:words];
		[articlesDictionary release];
	}
	NSLog(@"result.count: %d", result.count);
	if (result && result.count > 0)
		resultArticle = [result objectAtIndex:0];
	[wordArticles release];
	[result release];
	return resultArticle;
}

/*
 * search for string str and return the result
 */
+(Article *) searchAny:(NSString *)str
{
	NSString *searchStr = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
	NSMutableString *cleanWord = [[NSMutableString alloc] init];
	NSMutableString *cleanSearchStr = [[NSMutableString alloc] init];
	NSMutableArray *wordArticles = [[NSMutableArray alloc] initWithCapacity:10];
	NSMutableArray *result;
	NSMutableArray *words = [[NSMutableArray alloc] initWithCapacity:10];
	NSArray *findWords;
	int i;
	NSString *chr;
	
	NSLog(@"searchAny: %@", searchStr);
	if (![searchStr isMatchedByRegex:@"[a-z]"])
	{
		[cleanWord release];
		[cleanSearchStr release];
		[wordArticles release];
		[words release];
		return [[[Article alloc] initWithTitle:@"random articles"] autorelease]; // we will still return something :)
	}
	NSArray *splitWords = [searchStr componentsSeparatedByString:@" "];
	@try
	{
		// consider only words which has at least one [a-z] letter.
		for (NSString *strWord in splitWords)
			if ([strWord isMatchedByRegex:@"[a-z]"])
			{
				NSLog(@"strWord: %@", strWord);
				[cleanWord setString:@""];
				for (i = 0; i < strWord.length; i++)
				{
					chr = [strWord substringWithRange:NSMakeRange(i, 1)];
					if ([chr isMatchedByRegex:@"[a-z]"])
					{
						[cleanWord appendString:chr];
						[cleanSearchStr appendString:chr];
					}
				}
				[cleanSearchStr appendString:@" "];
				[words addObject:[NSString stringWithString:cleanWord]];
			}
		[cleanSearchStr deleteCharactersInRange:NSMakeRange(cleanSearchStr.length-1, 1)]; // remove last space
		int count=0;
		for (NSString *strWord in words)
		{
			//if (++count > 2)
			//	break;
			findWords = [Word findWord:strWord resultLimit:(100/words.count)];
			NSLog(@"findWords.count: ", findWords.count);
			for (Word *foundWord in findWords)
			{
				if (foundWord.articles.count == 0)
					[foundWord loadArticles];
				[wordArticles addObject:foundWord.articles];
			}
		}
		NSLog(@"wordArticles.count: %d", wordArticles.count);
		if (wordArticles.count > 0)
			result = [Word getSearchResult:wordArticles words:words];
		if (result.count == 0)
		{
			[cleanWord release];
			[cleanSearchStr release];
			[wordArticles release];
			[words release];
			return [[[Article alloc] initWithTitle:@"random articles"] autorelease];
		}
		if (result.count > 100)
		{
			count = result.count;
			for (i=100; i < count; i++)
				[result removeObjectAtIndex:100];
		}
		NSLog(@"searchAny result[0].ID: %d", [[result objectAtIndex:0] ID]);
		NSLog(@"searchAny result.count: %d", result.count);
	}
	@catch (NSException *ex)
	{
		NSLog(@"Exception: %@", ex);
	}
	[Word consolidateResult:searchStr results:result];
	[cleanWord release];
	[cleanSearchStr release];
	[wordArticles release];
	[words release];
	return nil;
}

/*
 * find similar words to wordStr with a limit of resultLimit words
 */
+(NSArray *) findWord:(NSString *)wordStr resultLimit:(int)resultLimit
{
	int i;
	NSString *chr;
	NSRange oldMatchIndex = NSMakeRange(0, 0), matchIndex;
	NSMutableArray *resultWords;
	Word *bsWord = [Word binarySearch:wordStr];
	if ([bsWord.value isEqualToString:wordStr])
	{
		resultWords = [NSMutableArray arrayWithCapacity:1];
		[resultWords addObject:bsWord];
		return [NSArray arrayWithArray:resultWords];
	}
	int wordID = bsWord.ID;
	
	if (wordID > 100)
		wordID -= 100;
	else
		wordID = 0;
	if (wordID > TotalNumberOfWords - 100)
		wordID = TotalNumberOfWords - 100;
	resultWords = [Word loadWords:wordID numberOfWords:200];
	for (Word *word in resultWords)
	{
		word.score = 0;
		if ([word.value rangeOfString:wordStr].length > 0 || [wordStr rangeOfString:word.value].length > 0)
			word.score += wordStr.length;
		oldMatchIndex = NSMakeRange(0,0);
		matchIndex = NSMakeRange(1000, 0);
		for (i=0; i < wordStr.length; i++)
		{
			chr = [wordStr substringWithRange:NSMakeRange(i, 1)];
			if ([word.value rangeOfString:chr].length > 0)
			{
				@try
				{
					word.score += 2;
					matchIndex = [word.value rangeOfString:chr options:0 range:NSMakeRange(oldMatchIndex.location, word.value.length - oldMatchIndex.location)];
					if (matchIndex.location != NSNotFound)
						word.score++;
					else
						matchIndex = [word.value rangeOfString:chr];
				}
				@catch (NSException *ex)
				{
					NSLog(@"findWord Exception: %@", ex);
					NSLog(@"findWord %@ %@", wordStr, word.value);
				}
			}
			word.score -= abs(matchIndex.location - i);
			if (matchIndex.location != NSNotFound)
				oldMatchIndex = matchIndex;
		}
	}
	[resultWords sortUsingSelector:@selector(compare:)];
	if (resultWords.count > resultLimit)
	{
		int count = resultWords.count;
		for (i=resultLimit; i<count; i++)
			[resultWords removeObjectAtIndex:resultLimit];
	}
	return [NSArray arrayWithArray:resultWords];
}

/*
 * compare two words descending using their score
 */
-(NSComparisonResult) compare:(Word *)word
{
        if (self.score < word.score)
                return NSOrderedDescending;
        else if (self.score > word.score)
                return NSOrderedAscending;
        else
                return NSOrderedSame;
}

/*
 * binary search for full word wordStr
 */
+(Word *) binarySearch:(NSString *)wordStr
{
	int min = 0, max = TotalNumberOfWords, mid;
	Word *midWord;
	
	while (min <= max) 
	{
		mid = (min + max) / 2;
		midWord = [Word withID:mid];
		NSString *midValue = midWord.value;
		NSComparisonResult comparisonResult = [wordStr compare:midValue];
		if (comparisonResult == NSOrderedSame)
			return midWord;
		else if (comparisonResult == NSOrderedDescending)
			min = mid + 1;
		else
			max = mid - 1;
		if (max < min)
			return midWord;
	}
	return nil;
}

#pragma mark -
#pragma mark article methods

/*
 * get search result of articles knowing each match word articles (in wordArticles)
 */
+(NSMutableArray *) getSearchResult:(NSArray *)wordArticles words:(NSArray *)words
{
	int i;
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:200];
	
	NSLog(@"getSearchResult wordArticles.count: %d", wordArticles.count);
	for (i=0; i<wordArticles.count; i++)
		for (Article *article in [wordArticles objectAtIndex:i])
			if (![result containsObject:article])
				[result addObject:article];
	[Word sortResult:result words:words];
	NSLog(@"result[0].ID: %d", [[result objectAtIndex:0] ID]);
	NSLog(@"result.count: %d", result.count);
	return result;
}

/*
 * sort search resulted articles according to best match to words.
 */
+(void) sortResult:(NSMutableArray *)array words:(NSArray *)words
{
	int oldMatchIndex = 0;
	NSString *articleTitle;
	NSMutableString *wordsTitle = [[NSMutableString alloc] init];
	NSRange range, resultRange;
	const char *chr;
	NSString *strChr;
	int count = 0;
	
	for (NSString *word in words)
		[wordsTitle appendFormat:@"%@ ", word];
	[wordsTitle deleteCharactersInRange:NSMakeRange(wordsTitle.length - 1, 1)];
	for (Article *article in array)
		article.score = 0;
	for (Article *article in array)
	{
		if (article.title.length == 0)
			[article fillTitleFromFile];
		articleTitle = [[article title] lowercaseString];
		if ([articleTitle isEqualToString:wordsTitle])
		{
			NSLog(@"articleTitle isEqualToString:wordsTitle: %@", wordsTitle);
			article.score = 1000000; // infinity!
			break;
		}
		article.score -= abs(wordsTitle.length - articleTitle.length);
		oldMatchIndex = 0;
		count = 0;
		chr = [articleTitle cStringUsingEncoding:NSUTF8StringEncoding];
		while (*chr != 0)
		{
			strChr = [NSString stringWithFormat:@"%c", *chr];
			if ([wordsTitle rangeOfString:strChr].length > 0)
			{
				article.score++;
				// give credit for the right order match
				range = NSMakeRange(oldMatchIndex, wordsTitle.length - oldMatchIndex);
				resultRange = [wordsTitle rangeOfString:strChr options:0 range:range];
				if (resultRange.length > 0)
					article.score ++;
				else
					resultRange = [wordsTitle rangeOfString:strChr];
				article.score -= abs(resultRange.location - count++);
				oldMatchIndex = resultRange.location;
			}
			chr++;
		}
		for (NSString *word in words)
		{
			if ([articleTitle rangeOfString:word].length > 0)
				article.score += word.length;
			oldMatchIndex = 0;
			chr = [word cStringUsingEncoding:NSUTF8StringEncoding];
			while (*chr != 0)
			{ 
				strChr = [NSString stringWithFormat:@"%c",*chr];
				if ([articleTitle rangeOfString:strChr].length > 0)
				{
					article.score++;
					// give credit for the right order match
					range = NSMakeRange(oldMatchIndex, articleTitle.length - oldMatchIndex);
					resultRange = [articleTitle rangeOfString:strChr options:0 range:range];
					if (resultRange.length > 0)
						article.score ++;
					else
						resultRange = [wordsTitle rangeOfString:strChr];
					oldMatchIndex = resultRange.location;
				}
				chr++;
			}
		}
	}
	[array sortUsingSelector:@selector(compareScore:)];
	[wordsTitle release];
}

/*
 * load the articles of this word
 */
-(void) loadArticles
{
	int offset, number;
	NSString *fileName;
	FILE *file;
	
	fileName = [[NSBundle mainBundle] pathForResource:@"wordArticleLoc" ofType:@"bin"];
	file = fopen([fileName UTF8String], "rb");
	offset = ID * 4;
	fseeko(file, offset, SEEK_SET);
	fread(&number, 1, 4, file);
	fclose(file);

	fileName = [[NSBundle mainBundle] pathForResource:@"wordArticle" ofType:@"bin"];
	file = fopen([fileName UTF8String], "rb");
	offset = number;
	fseeko(file, offset, SEEK_SET);
	fread(&number, 1, 4, file);
	while (number != -1)
	{
		[self addArticle:number];
		fread(&number, 1, 4, file);
	}
	fclose(file);
}

/*
 * add article knowing the article ID (article position in article.txt file).
 */
-(void) addArticle:(int)articleID
{
	Article *article = [[Article alloc] initWithID:articleID];
	[articles addObject:article];
	[article release];
}

/*
 * consolidate all results into one article with title "title"
 */
+(void) consolidateResult:(NSString *)title results:(NSMutableArray *)results
{
	int i;
	NSString *fileName;
	NSMutableString *description = [[NSMutableString alloc] init];
	Article *resultArticle;
	
	NSLog(@"consolidateResult");
	resultArticle = [[Article alloc] initWithTitle:[Texter uppercaseFirst:title]];
	[description appendFormat:@"%@<body>\n", [resultArticle getHeader]];
	[resultArticle release];
	[description appendFormat:@"<table>"];
	for (i=0; i<results.count; i+=2)
	{
		resultArticle = [results objectAtIndex:i];
		if (resultArticle.title.length > 0)
		{
			[description appendFormat:@"<tr><td>&nbsp;</td><td><li><a href=/wiki/%@>%@</a></td>", 
			 [resultArticle.title stringByReplacingOccurrencesOfString:@" " withString:@"_"], resultArticle.title];
			if (i+1 < results.count)
			{
				resultArticle = [results objectAtIndex:(i+1)];
				if (resultArticle.title.length > 0)
					[description appendFormat:@"<td><li><a href=/wiki/%@>%@</a></td></tr>", 
					 [resultArticle.title stringByReplacingOccurrencesOfString:@" " withString:@"_"], resultArticle.title];
				else
					[description appendString:@"<td>&nbsp;</td></tr>"];
			}
			else 
				[description appendString:@"<td>&nbsp;</td></tr>"];
		}
	}
	[description appendFormat:@"</table>"];
	[description appendString:@"</body>\n"];
	fileName = [[NSString alloc] initWithFormat:@"%@/%@.view-0-o.htm", [wpedia documentDirectory],
				[[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString]];
	[description writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	[description release];
	[fileName release];
}
@end
