#import "WPediaFile.h"

@implementation WPediaFile

@synthesize path, date, size;

/*
 * trim the cache by deleting old files to the cache size would match the configured cacheLimit value.
 */
+(void) trimCache
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError* error = nil;
	NSString *documentDirectory = [wpedia documentDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	long cacheLimit = 1024 * 1024 * 1024;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    cacheLimit = lround([defaults floatForKey:@"cacheLimit"] * 1024 * 1024 * 1024); // Gigabyte
	if (cacheLimit == 0)
		cacheLimit = 1024 * 1024 * 1024;
	//cacheLimit = 0;
	NSLog(@"cacheLimit: %d", cacheLimit);
	[Texter log:[NSString stringWithFormat:@"cacheLimit: %d", cacheLimit]];
	NSArray *files = [fileManager subpathsAtPath:documentDirectory];
	unsigned long totalSize = 0;
	for (NSString *path in files) 
	{
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:[documentDirectory stringByAppendingPathComponent:path] error:NULL];
		totalSize += [attributes fileSize];
	}
	NSLog(@"trimCache, total cache size: %d", totalSize);
	if (totalSize > cacheLimit)
	{ 
		NSLog(@"trimming cache");
		NSMutableArray* wpediaFiles = [[NSMutableArray alloc] init];
		for (NSString* path in files)
		{
			WPediaFile *wpediaFile = [[WPediaFile alloc] init];
			NSDictionary* properties = [fileManager	attributesOfItemAtPath:[documentDirectory stringByAppendingPathComponent:path]
										error:&error];
			wpediaFile.path = path;
			wpediaFile.date = [properties fileModificationDate];
			wpediaFile.size = [properties fileSize];
			[wpediaFiles addObject:wpediaFile];
			[wpediaFile release];
		}
		[wpediaFiles sortUsingSelector:@selector(compare:)];
		NSArray* sortedFiles = [NSArray arrayWithArray:wpediaFiles];
		long sizeToDelete = totalSize - (cacheLimit * 0.8); // delete also 20% of the cache 
		long sizeCount = 0;
		for (WPediaFile *file in sortedFiles)
		{
			if ([file.path rangeOfString:@"css/"].location == 0
				|| [file.path isEqualToString:@"css"]
				|| [file.path isEqualToString:@"images"]
				|| [file.path isEqualToString:@"images/plus.png"]
				|| [file.path isEqualToString:@"images/minus.png"]
				|| [file.path isEqualToString:@"history.txt"]
				|| [file.path isEqualToString:@"wpediaScript.js"])
				continue;
			sizeCount += file.size;
			NSLog(@"deleting file: %d %@ %@", file.size, file.date, file.path);
			NSString *fileName = [documentDirectory stringByAppendingPathComponent:file.path];
			[fileManager removeItemAtPath:fileName error:0];
			if (sizeCount > sizeToDelete)
				break;
			//NSLog(@"%d %@ %@", file.size, file.date, file.path);
		}
		[wpediaFiles release];
	}
	[pool drain];
}

/*
 * compare two files ascending using their modificationDate
 */
-(NSComparisonResult) compare:(WPediaFile *)file
{
	return [self.date compare:file.date];
}
@end
