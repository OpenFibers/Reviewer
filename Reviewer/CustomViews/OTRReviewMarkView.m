//
//  ReviewMarkView.m
//  Reviewer
//
//  Created by openthread on 4/22/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTRReviewMarkView.h"

@implementation OTRReviewMarkView

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        self.alphaValue = 0.5f;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:186/255.0f green:1 blue:253/255.0f alpha:0.5f] set];
    NSRectFill(dirtyRect);
}

+ (id)markView
{
    OTRReviewMarkView *markView = [[OTRReviewMarkView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    return [markView autorelease];
}

@end
