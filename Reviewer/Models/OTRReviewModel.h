//
//  ReviewModel.h
//  Reviewer
//
//  Created by openthread on 4/16/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OTRReviewModel ComOpenthreadReviewerOTRReviewModel

@interface OTRReviewModel : NSObject

@property (nonatomic, retain) NSString *reviewNotes;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *reviewDate;
@property (nonatomic, assign) BOOL isClosed;

@property (nonatomic, readonly) NSString *commitString;

+ (OTRReviewModel *)reviewModelInLine:(NSString *)line
               selectedRangeInLine:(NSRange)selectedRangeInLine
                      matchedRange:(NSRangePointer)matchedRange;

+ (NSString *)currentDateString;

+ (NSRegularExpression *)reviewModelRegex;
@end
