#import "wpedia.h"

@interface WPediaFile : NSObject 
{
	NSString *path;
	NSDate* date;
	unsigned long size;
}
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSDate* date;
@property unsigned long size;

+(void) trimCache;
-(NSComparisonResult) compare:(WPediaFile *)file;
@end
