//
//  ReviewView.h
//  Reviewer
//
//  Created by openthread on 4/16/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OTRReviewModel.h"

#define OTRReviewView ComOpenthreadReviewerOTRReviewView

@interface OTRReviewView : NSView

@property (nonatomic,retain) OTRReviewModel *reviewModel;

@end
