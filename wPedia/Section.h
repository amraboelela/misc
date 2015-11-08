#import "RegexKitLite.h"

@class Article;

@interface Section: NSObject
{
	int level, ID;
	NSString *title;
	NSMutableString *rawHtml;
	Section *parent;
	Article *article;
	NSMutableArray *sections;
}
@property int level, ID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic,retain) NSMutableString *rawHtml;
@property (nonatomic, assign) Section *parent;
@property (nonatomic, assign) Article *article;
@property (nonatomic, retain) NSMutableArray *sections;

// init methods
-(id) init;

// release methods
-(void) dealloc;

// loading methods
-(void) loadSections;
-(NSString *) fillText;
-(NSString *) fillHtml;
-(NSString *) fillHeader;
-(NSString *) fillFullID;

@end
