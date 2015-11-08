#import "RegexKitLite.h"
#import "wpedia.h"

#define ReadLineSize 200

@interface Texter: NSObject

+(NSString *) readline;
+(NSString *) readLineFromFile:(FILE *)file;
+(BOOL) isInteger:(NSString *)str;
+(BOOL) isNumeric:(NSString *)str;
+(NSString *) extractText:(NSString *)source start:(NSString *)start end:(NSString *)end;
+(void) cleanHtml:(NSMutableString *)html;
+(void) removeParenthesis:(NSMutableString *)str;
+(void) removeSquareBrackets:(NSMutableString *)str;
+(NSString *) shortenText:(NSString *)text maxLength:(int)maxLength;
+(NSString *) uppercaseFirst:(NSString *)text;
+(void) log:(NSString *)text;
@end
