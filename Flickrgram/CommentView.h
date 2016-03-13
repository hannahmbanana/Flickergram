//
//  CommentView.h
//  Flickrgram
//
//  Created by Hannah Troisi on 3/9/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentFeedModel.h"

@interface CommentView : UIView

+ (CGFloat)heightForCommentFeedModel:(CommentFeedModel *)commentFeed withWidth:(CGFloat)width;
- (void)prepareForReuse;
- (void)updateWithCommentFeedModel:(CommentFeedModel *)feed withFontSize:(CGFloat)size;

@end
