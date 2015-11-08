#import "RegexKitLite.h"
#import "Article.h"
#import "Constants.h"

@class Article;

@interface Word: NSObject
{
	int ID, score;
	NSString *value;
	NSMutableArray *articles;
}

@property int ID, score;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSMutableArray *articles;

-(id) init:(NSString *)wordValue;
-(id) init:(int)wordID value:(NSString *)wordValue;

+(Word *) withID:(int)wordID;
+(Word *) withValue:(NSString *)wordStr;

// loading methods
+(NSMutableArray *) loadWords:(int)startID numberOfWords:(int)numberOfWords;

// search methods
+(Article *) search:(NSString *)str;
+(Article *) searchAny:(NSString *)str;
+(NSArray *) findWord:(NSString *)wordStr resultLimit:(int)resultLimit;
+(Word *) binarySearch:(NSString *) searchStr;

// article methods
+(NSMutableArray *) getSearchResult:(NSArray *)wordArticles words:(NSArray *)words;
+(void) sortResult:(NSMutableArray *)result words:(NSArray *)words;
//+(Article *) getRandomArticle;
-(void) loadArticles;
-(void) addArticle:(int)articleID;
+(void) consolidateResult:(NSString *)title results:(NSMutableArray *)results;
@end
