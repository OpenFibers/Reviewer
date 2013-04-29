//
//  NSTextView+MakeReviewViewBecomeFirstResponder.m
//  Reviewer
//
//  Created by openthread on 4/19/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "NSTextView+OTRReviewerMethods.h"
#import "OTRReviewView.h"
#import "OTRReviewMarkView.h"

@implementation NSTextView (OTRReviewerMethods)

- (void)makeReviewViewBecomeFirstResponder
{
    if ([NSTextView isObjectSourceTextView:self])
    {
        for (NSView *view in self.subviews)
        {
            if ([view isKindOfClass:[OTRReviewView class]])
            {
                [view becomeFirstResponder];
            }
        }
    }
}

+ (NSTextView *)firstResponderSourceTextView
{
    NSTextView *textView = nil;
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if ([NSTextView isObjectSourceTextView:firstResponder])
    {
        textView = (NSTextView *)firstResponder;
    }
    return textView;
}

+ (BOOL)isObjectSourceTextView:(id)object
{
    if ([object isKindOfClass:NSClassFromString(@"DVTSourceTextView")] &&
        [object isKindOfClass:[NSTextView class]])
    {
        return YES;
    }
    return NO;
}

- (void)refreshReviewMark
{
    if ([NSTextView isObjectSourceTextView:self])
    {
        //Remove old review marks first
        NSArray *subViews = [NSArray arrayWithArray:self.subviews];
        for (NSView *view in subViews)
        {
            if ([view isKindOfClass:[OTRReviewMarkView class]])
            {
                [view removeFromSuperview];
            }
        }
        
        //Get each line of text view
        NSString *text = self.textStorage.string;
        NSArray *array = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        
        NSRange currentLineRange = NSMakeRange(0, 0);
        for (int i = 0; i < array.count; i++)
        {
            NSString *line = array[i];
            currentLineRange.length = line.length;
            
            //Find review tag
            //NSRange reviewTagRange = [line rangeOfString:@"//@review"];

            NSRegularExpression *regex = [OTRReviewModel reviewModelRegex];
            NSRange reviewTagRange = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, [line length])];
            
            if (reviewTagRange.location != NSNotFound)//If review tag found
            {
                //Highlight review tag line
                NSLayoutManager *layoutManager = [self layoutManager];
                NSRect paragraphRect = [layoutManager boundingRectForGlyphRange:currentLineRange inTextContainer:[self textContainer]];
                
                OTRReviewMarkView *markView = [OTRReviewMarkView markView];
                markView.frame = paragraphRect;
                [self addSubview:markView];
            }
            
            currentLineRange.location += line.length + 1;
            currentLineRange.length = 0;
        }
    }
    [self release];
}

- (void)invokeRefreshReviewMark
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshReviewMark) object:nil];
    [self retain];
    [self performSelector:@selector(refreshReviewMark) withObject:nil afterDelay:0.0f];
}

@end
