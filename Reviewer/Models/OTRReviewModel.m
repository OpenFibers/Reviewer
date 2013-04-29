//
//  ReviewModel.m
//  Reviewer
//
//  Created by openthread on 4/16/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTRReviewModel.h"

@implementation OTRReviewModel

- (NSString *)commitString
{
    NSMutableString *commitString = [NSMutableString stringWithFormat:@"//@review %@", self.reviewNotes];
    if (self.author)
    {
        [commitString appendFormat:@" @author %@", self.author];
    }
    if (self.reviewDate)
    {
        [commitString appendFormat:@" @date %@", self.reviewDate];
    }
    
    if (self.isClosed)
    {
        [commitString appendString:@" @closed"];
    }
    [commitString appendString:@"\n"];
    
    NSString *resultString = [NSString stringWithString:commitString];
    
    return resultString;
}

- (void)fillWithCommitString:(NSString *)commitString
{
    NSArray *subStrings = [commitString componentsSeparatedByString:@"@"];
    NSString *notes = nil;
    NSString *author = nil;
    NSString *date = nil;
    BOOL isClosed = NO;
    
    for (NSString *eachSubString in subStrings)
    {
        NSString *reviewContent = [OTRReviewModel trimmedContentStringFromString:eachSubString tag:@"review"];
        if (reviewContent)
        {
            notes = reviewContent;
        }
        
        NSString *authorContent = [OTRReviewModel trimmedContentStringFromString:eachSubString tag:@"author"];
        if (authorContent)
        {
            author = authorContent;
        }
        
        NSString *dateContent = [OTRReviewModel trimmedContentStringFromString:eachSubString tag:@"date"];
        if (dateContent)
        {
            date = dateContent;
        }
        
        NSString *closedContent = [OTRReviewModel trimmedContentStringFromString:eachSubString tag:@"closed"];
        isClosed = (closedContent != nil);
    }
    
    self.reviewNotes = (notes ? notes : @"");
    self.author = (author ? author : @"");
    self.reviewDate = (date ? date : @"");
    self.isClosed = isClosed;
}

+ (NSString *)trimmedContentStringFromString:(NSString *)string tag:(NSString *)tag
{
    NSString *resultString = nil;
    if (string.length >= tag.length && [string hasPrefix:tag])
    {
        resultString = [string substringFromIndex:tag.length];
        resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return resultString;
}

+ (NSRegularExpression *)reviewModelRegex
{
    static NSRegularExpression *reviewModelRegex = nil;
    if (!reviewModelRegex)
    {
        NSString *patternString = @"^\\s*//@review";
        reviewModelRegex = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:NULL];

    }
    return reviewModelRegex;
}

+ (OTRReviewModel *)reviewModelInLine:(NSString *)line
               selectedRangeInLine:(NSRange)selectedRangeInLine
                      matchedRange:(NSRangePointer)matchedRange
{
	__block NSRange foundResultRange = NSMakeRange(NSNotFound, 0);
	__block OTRReviewModel *foundReviewModel = nil;
	
    NSRegularExpression *modelRegex = [OTRReviewModel reviewModelRegex];
	[modelRegex enumerateMatchesInString:line
                                 options:0
                                   range:NSMakeRange(0, line.length)
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange resultRange = [result range];
         if (selectedRangeInLine.location >= resultRange.location && NSMaxRange(selectedRangeInLine) <= NSMaxRange(resultRange))
         {
             
             foundReviewModel = [[OTRReviewModel alloc] init];
             [foundReviewModel fillWithCommitString:line];
             foundResultRange = resultRange;
             *stop = YES;
         }
     }];
    
    if (foundReviewModel)
    {
		if (matchedRange != NULL)
        {
			*matchedRange = foundResultRange;
		}
    }
    
    return foundReviewModel;
}

+ (NSString *)currentDateString
{
    static NSDateFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM/dd/yyyy HH:mm:ss";
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:locale];
        [locale release];
    }
    NSDate *date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
