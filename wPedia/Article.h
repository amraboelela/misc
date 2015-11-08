#import "RegexKitLite.h"
#import "Texter.h"
#import "Section.h"
#import "wpedia.h"

@class Section, wpedia;

enum
{
	ViewModeDescription,
	ViewModeText,
	ViewModeHtml
};
typedef int ArticleViewMode;

@interface Article: NSObject
{
	int ID; // this is the article location in the article.txt file
	NSMutableString *rawHtml, *wholePage;
	ArticleViewMode viewMode;
	NSString *title;
	NSMutableArray *sections;
	BOOL hasParent, searchPage, specialPage;
	int pageNumber;

@public
	UIWebView **webView, *descriptionWebView, *textWebView, *textWebViewExternal, *htmlWebView, *htmlWebViewExternal;
	NSString *previousArticle, *nextArticle;
	BOOL textExternal, htmlExternal;
	
@private
	int score; // used for searching
	BOOL completeRawHtml, completeDescription;
	BOOL completeSections, completeText, completeHtml, completeDownloadImages, imagesViewed;
	BOOL foundResultInWikipedia, connecting, loading, wasConnecting;
	NSString *didYouMean, *linePart;
	BOOL inBody, inJumpTo, inFooter, inTOC, inMetaData, inExternalLinks;
	BOOL inSisterProject;
	int inDev;
}

// properties
@property int ID;
@property (nonatomic, retain) NSMutableString *rawHtml;
@property (nonatomic, retain) NSMutableString *wholePage;
@property ArticleViewMode viewMode;
@property (nonatomic, retain) NSString *title, *previousArticle, *nextArticle;
@property (nonatomic, retain) NSMutableArray *sections;
@property BOOL hasParent, searchPage, specialPage;
@property int pageNumber;
@property (nonatomic, retain) UIWebView *descriptionWebView, *textWebView, *textWebViewExternal, *htmlWebView, *htmlWebViewExternal;
@property UIWebView **webView;
@property BOOL textExternal, htmlExternal;
@property int score;
@property BOOL completeRawHtml, completeDescription;
@property BOOL completeSections, completeText, completeHtml, completeDownloadImages, imagesViewed;
@property BOOL foundResultInWikipedia, connecting, loading, wasConnecting;
@property (nonatomic, retain) NSString *didYouMean, *linePart;
@property BOOL inBody, inJumpTo, inFooter, inTOC, inMetaData, inExternalLinks;
@property BOOL inSisterProject;
@property int inDev;

// init methods
-(id) initWithID:(int)ID;
-(id) initWithTitle:(NSString *)title;
-(id) initWithPageNumber:(NSString *)title pageNumber:(int)pageNumber;
-(void) reinit;

// property methods
+(BOOL) offline;
+(void) setOffline:(BOOL)newValue;
-(BOOL) completeView;
-(void) setCompleteView:(BOOL)newValue;
-(BOOL) external;
-(void) setExternal:(BOOL)newValue;
-(NSComparisonResult) compareScore:(Article *)article;
-(NSComparisonResult) compareTitle:(Article *)article;

// release methods
-(void) releaseViews;
-(void) releaseDescriptionWebView;
-(void) releaseExternalWebView;
-(void) releaseRawData;

// loading article
-(BOOL) showView;
-(NSString *) getViewFile;
-(void) produceViewFiles;
-(NSString *) fillArticle;
-(void) reloadViews;
-(void) loadSections;
+(void) produceRandomArticles;

// online methods
-(void) fillRawHtmlOnline;
-(void) readWebPage;

@end

@interface Article (Texter)
-(void) refineRawHtml;
-(void) writeNavigation;
+(void) downloadImages:(NSMutableArray *)urls imageNames:(NSMutableArray *)imageNames;
-(void) fillTitleFromFile;
-(void) fillDescriptionFromFile;
-(void) fillDescriptionFromRawHtml;
-(void) fillText;
-(void) fillHtml;
-(void) fillSearchResultsPage;
-(void) fillSpecialPage;
-(NSString *) getHeader;
-(NSString *) getFooter;
@end
