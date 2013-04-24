//
//  NSTextView+MakeReviewViewBecomeFirstResponder.h
//  Reviewer
//
//  Created by openthread on 4/19/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define OTRReviewerMethods ComOpenthreadReviewerOTRReviewerMethods

@interface NSTextView (OTRReviewerMethods)

- (void)makeReviewViewBecomeFirstResponder;

+ (NSTextView *)firstResponderSourceTextView;

+ (BOOL)isObjectSourceTextView:(id)object;

- (void)invokeRefreshReviewMark;

@end
