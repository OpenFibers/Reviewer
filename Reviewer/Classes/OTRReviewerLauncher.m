//
//  Reviewer.m
//  Reviewer
//
//  Created by openthread on 4/16/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTRReviewerLauncher.h"
#import "OTRReviewView.h"
#import "OTRReviewModel.h"
#import "NSTextView+OTRReviewerMethods.h"

#define kReviewViewWidth    400.0f
#define kReviewViewHeight   160.0f


@implementation OTRReviewerLauncher
{
    OTRReviewView *_reviewView;
}

- (OTRReviewView *)reviewView
{
    if (!_reviewView)
    {
        _reviewView = [[OTRReviewView alloc] initWithFrame:CGRectMake(100, 100, kReviewViewWidth, kReviewViewHeight)];
    }
    return _reviewView;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    [OTRReviewerLauncher sharedPlugin];
}

+ (OTRReviewerLauncher *)sharedPlugin
{
    static OTRReviewerLauncher *mySharedPlugin = nil;

    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mySharedPlugin = [[self alloc] init];
	});
	return mySharedPlugin;
}

- (id)init
{
	if (self = [super init])
    {
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];        
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reviewView release], _reviewView = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //Set up menu items
    [self addMenuItems];
    
    [self activeHighlighting];
}

- (void)activeHighlighting
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
    
    NSTextView *textView = [NSTextView firstResponderSourceTextView];
    if (textView)
    {
        NSNotification *notification = [NSNotification notificationWithName:NSTextViewDidChangeSelectionNotification
                                                                     object:textView];
        [self selectionDidChange:notification];
    }
}

- (void)selectionDidChange:(NSNotification *)notification
{
    NSTextView *textView = [notification object];
    if ([NSTextView isObjectSourceTextView:textView])
    {		
		NSArray *selectedRanges = [textView selectedRanges];
		if (selectedRanges.count >= 1)
        {
			NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
			NSString *text = textView.textStorage.string;
			NSRange lineRange = [text lineRangeForRange:selectedRange];
			NSRange selectedRangeInLine = NSMakeRange(selectedRange.location - lineRange.location, selectedRange.length);
			NSString *line = [text substringWithRange:lineRange];
			NSRange resultRange = NSMakeRange(NSNotFound, 0);
            
			OTRReviewModel *matchedModel = [OTRReviewModel reviewModelInLine:line
                                                   selectedRangeInLine:selectedRangeInLine
                                                          matchedRange:&resultRange];
            if (matchedModel)
            {
				NSRect selectionRectOnScreen = [textView firstRectForCharacterRange:selectedRange];
				NSRect selectionRectInWindow = [textView.window convertRectFromScreen:selectionRectOnScreen];
				NSRect selectionRectInView = [textView convertRect:selectionRectInWindow fromView:nil];
                
                OTRReviewView *reviewView = [self reviewView];
                [reviewView setReviewModel:matchedModel];
                reviewView.frame = CGRectMake(50, CGRectGetMaxY(selectionRectInView) + 5, kReviewViewWidth, kReviewViewHeight);
                [textView addSubview:reviewView];
            }
            else
            {
                OTRReviewView *reviewView = [self reviewView];
                [reviewView removeFromSuperview];
            }
		}
        else
        {
            OTRReviewView *reviewView = [self reviewView];
            [reviewView removeFromSuperview];
        }
        
        [textView invokeRefreshReviewMark];
    }
}

#pragma mark - Menu

- (void)addMenuItems
{
	NSMenu *mainMenu = [NSApp mainMenu];
    
	// find the Edit menu and add a new item
	NSMenuItem *editMenu = [mainMenu itemWithTitle:@"Edit"];
	NSMenuItem *item1 = [[NSMenuItem alloc] initWithTitle:@"Insert a Code Review"
                                                   action:@selector(addReviewMenuClicked:)
                                            keyEquivalent:@""];
    [item1 setKeyEquivalent:@"/"];
    [item1 setKeyEquivalentModifierMask:NSControlKeyMask|NSCommandKeyMask];
	[item1 setTarget:self];
	[[editMenu submenu] addItem:item1];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSTextView *textView = [NSTextView firstResponderSourceTextView];
    return textView != nil;
}

- (void)addReviewMenuClicked:(id)sender
{
    NSTextView *textView = [NSTextView firstResponderSourceTextView];
    if (textView)
    {
		NSArray *selectedRanges = [textView selectedRanges];
		if (selectedRanges.count >= 1)
        {
			NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
			NSString *text = textView.textStorage.string;
			NSRange lineRange = [text lineRangeForRange:selectedRange];
            NSRange insertRange = NSMakeRange(lineRange.location, 0);
            
            OTRReviewModel *model = [[OTRReviewModel alloc] init];
            model.reviewNotes = @"";
            model.reviewDate = [OTRReviewModel currentDateString];
            model.author = NSUserName();
            [textView.textStorage replaceCharactersInRange:insertRange withString:model.commitString];
            textView.selectedRange = insertRange;
            [model release];
            
            [textView performSelector:@selector(makeReviewViewBecomeFirstResponder) withObject:nil afterDelay:0];
        }
    }
}

@end
