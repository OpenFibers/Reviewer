//
//  ReviewView.m
//  Reviewer
//
//  Created by openthread on 4/16/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTRReviewView.h"
#import "NSTextView+OTRReviewerMethods.h"

#define kReviewerUnknownAuthorString    @"By Unknown Commiter"
#define kReviewerUnknownDateString      @"By Unknown Date"

@interface OTRReviewView()<NSTextFieldDelegate>
@end

@implementation OTRReviewView
{
    NSTextField *_notesLabel;
    NSTextField *_notesTextField;
    NSTextField *_reviewerLabel;
    NSTextField *_reviewDateLabel;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _notesLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
        _notesLabel.font = [NSFont systemFontOfSize:13.0f];
        _notesLabel.textColor = [NSColor blackColor];
        _notesLabel.frame = CGRectMake(10, 10, 0, 0);
        [_notesLabel setStringValue:@"Review Notes:"];
        [_notesLabel setEditable:NO];
        _notesLabel.bezeled = NO;
        _notesLabel.drawsBackground = YES;
        _notesLabel.backgroundColor = [NSColor clearColor];
        [self addSubview:_notesLabel];
        
        _notesTextField = [[NSTextField alloc] initWithFrame:CGRectZero];
        _notesTextField.font = [NSFont systemFontOfSize:13.0f];
        _notesTextField.textColor = [NSColor blackColor];
        [_notesTextField setEditable:YES];
        _notesTextField.delegate = self;
        [self addSubview:_notesTextField];
        
        _reviewerLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
        _reviewerLabel.font = [NSFont systemFontOfSize:13.0f];
        _reviewerLabel.textColor = [NSColor blackColor];
        _reviewerLabel.frame = CGRectMake(10, 10, 0, 0);
        [_reviewerLabel setStringValue:kReviewerUnknownAuthorString];
        [_reviewerLabel setEditable:NO];
        _reviewerLabel.bezeled = NO;
        _reviewerLabel.drawsBackground = YES;
        _reviewerLabel.backgroundColor = [NSColor clearColor];
        [self addSubview:_reviewerLabel];
        
        _reviewDateLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
        _reviewDateLabel.font = [NSFont systemFontOfSize:13.0f];
        _reviewDateLabel.textColor = [NSColor blackColor];
        _reviewDateLabel.frame = CGRectMake(10, 10, 0, 0);
        [_reviewDateLabel setStringValue:kReviewerUnknownDateString];
        [_reviewDateLabel setEditable:NO];
        _reviewDateLabel.bezeled = NO;
        _reviewDateLabel.drawsBackground = YES;
        _reviewDateLabel.backgroundColor = [NSColor clearColor];
        [_reviewDateLabel setAlignment:NSRightTextAlignment];
        [self addSubview:_reviewDateLabel];
        
        [self setFrame:frameRect];
    }
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    CGFloat reviewerAndDateWidth = (int)((CGRectGetWidth(frameRect) - 30) / 2);
    _reviewerLabel.frame = CGRectMake(10, 10, reviewerAndDateWidth, 25);
    _reviewDateLabel.frame = CGRectMake(CGRectGetWidth(frameRect) - reviewerAndDateWidth - 10, 10, reviewerAndDateWidth, 25);
    _notesTextField.frame = CGRectMake(10, 45, CGRectGetWidth(frameRect) - 20, CGRectGetHeight(frameRect) - 80);
    _notesLabel.frame = CGRectMake(10, CGRectGetHeight(frameRect) - 35, 150, 25);
}

- (void)setReviewModel:(OTRReviewModel *)reviewModel
{
    if (_reviewModel)
    {
        [_reviewModel release], _reviewModel = nil;
    }
    _reviewModel = [reviewModel retain];
    
    if (reviewModel.author.length)
    {
        [_reviewerLabel setStringValue:[NSString stringWithFormat:@"By %@", reviewModel.author]];
    }
    else
    {
        [_reviewerLabel setStringValue:kReviewerUnknownAuthorString];
    }
    
    if (reviewModel.reviewDate.length)
    {
        [_reviewDateLabel setStringValue:reviewModel.reviewDate];
    }
    else
    {
        [_reviewDateLabel setStringValue:kReviewerUnknownDateString];
    }
    
    if (reviewModel.reviewNotes)
    {
        [_notesTextField setStringValue:reviewModel.reviewNotes];
    }
    else
    {
        [_notesTextField setStringValue:@""];
    }
}

- (BOOL)becomeFirstResponder
{
    return [_notesTextField becomeFirstResponder];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    BOOL result = NO;
    
    if (command == @selector(insertNewline:))
    {
        [self finishInput];
        result = YES;
    }
    else if (command == @selector(cancelOperation:))
    {
        [self removeFromSuperview];
    }
    
    return result;
}

- (void)finishInput
{
    NSTextView *textView = (NSTextView *)self.superview;
    [self removeFromSuperview];
    
    if (![NSTextView isObjectSourceTextView:textView])
    {
        return;
    }
    
    NSArray *selectedRanges = [textView selectedRanges];
    if (selectedRanges.count >= 1)
    {
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString *text = textView.textStorage.string;
        NSRange lineRange = [text lineRangeForRange:selectedRange];
        NSRange selectedRangeInLine = NSMakeRange(selectedRange.location - lineRange.location, selectedRange.length);
        NSString *line = [text substringWithRange:lineRange];
        NSRange resultRange = NSMakeRange(NSNotFound, 0);

        OTRReviewModel *newModel = [[OTRReviewModel alloc] init];
        newModel.reviewNotes = _notesTextField.stringValue;
        newModel.author = NSUserName();
        newModel.reviewDate = [OTRReviewModel currentDateString];
        OTRReviewModel *oldModel = [OTRReviewModel reviewModelInLine:line selectedRangeInLine:selectedRangeInLine matchedRange:&resultRange];
        if (oldModel)
        {
            NSString *newReviewString = [newModel commitString];
            [textView.textStorage replaceCharactersInRange:lineRange withString:newReviewString];
        }
        
        [newModel release];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor gridColor] set];
    NSRectFill(dirtyRect);
}

- (void)dealloc
{
    [_notesTextField release];
    [super dealloc];
}

@end
