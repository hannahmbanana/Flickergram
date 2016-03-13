//
//  CommentView.m
//  Flickrgram
//
//  Created by Hannah Troisi on 3/9/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "CommentView.h"
#import "PhotoFeedModel.h"
#import "Utilities.h"

#define INTER_COMMENT_SPACING 5
#define NUM_COMMENTS_TO_SHOW_UNEXPANDED 3

@implementation CommentView
{
  CommentFeedModel *_commentFeed;
  UILabel          *_commentCountLabel;
  UILabel          *_commentLabel1;
  UILabel          *_commentLabel2;
  UILabel          *_commentLabel3;
}

#pragma mark - Class Methods

+ (CGFloat)heightForCommentFeedModel:(CommentFeedModel *)commentFeed withWidth:(CGFloat)width
{
  CGFloat height = 0;
  NSAttributedString *string;
  
  NSUInteger numComments       = [commentFeed totalNumberOfCommentsForPhoto];
  if (numComments > 3) {
    NSString *countString      = [NSString stringWithFormat:@"View all %@ comments", [NSNumber numberWithUnsignedInteger:numComments]];
    NSAttributedString *string = [NSAttributedString attributedStringWithString:countString fontSize:14 color:nil firstWordColor:nil];
    CGRect countStringRect     = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil];
    height                    += countStringRect.size.height;
  }
  
  NSUInteger numCommentsInFeed = [commentFeed numberOfItemsInFeed];

  for (int i = 0; i < numCommentsInFeed; i++) {
    
    CommentModel *comment      = [commentFeed objectAtIndex:i];
    string                     = [NSAttributedString attributedStringWithString:comment.body fontSize:14 color:nil firstWordColor:nil];
    CGRect stringRect          = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil];
    height                    += stringRect.size.height + INTER_COMMENT_SPACING;
  }

  return roundf(height);
}

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];        // FIXME: create array of UILabels, have helper method to do below 3 lines, call helper method in update:, not init (consider reuse - destroy array)
  
  if (self) {
    _commentCountLabel           = [[UILabel alloc] init];
    [self addSubview:_commentCountLabel];
    
    _commentLabel1               = [[UILabel alloc] init];
    _commentLabel1.numberOfLines = 3;
    [self addSubview:_commentLabel1];
    
    _commentLabel2               = [[UILabel alloc] init];
    _commentLabel2.numberOfLines = 3;
    [self addSubview:_commentLabel2];
    
    _commentLabel3               = [[UILabel alloc] init];
    _commentLabel3.numberOfLines = 3;
    [self addSubview:_commentLabel3];
  }
  
  return self;
}


- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize boundsSize = self.bounds.size;
  CGRect rect       = CGRectMake(0, 0, boundsSize.width, 0);
  
  if (_commentCountLabel.attributedText) {
    rect.size = [_commentCountLabel sizeThatFits:CGSizeMake(boundsSize.width, CGFLOAT_MAX)];
    _commentCountLabel.frame = rect;
  }
  
  if (_commentLabel1.attributedText) {
    rect.origin.y += rect.size.height + INTER_COMMENT_SPACING;
    rect.size = [_commentLabel1 sizeThatFits:CGSizeMake(boundsSize.width, CGFLOAT_MAX)];
    _commentLabel1.frame = rect;
  }
  
  if (_commentLabel2.attributedText) {
    rect.origin.y += rect.size.height + INTER_COMMENT_SPACING;
    rect.size = [_commentLabel2 sizeThatFits:CGSizeMake(boundsSize.width, CGFLOAT_MAX)];
    _commentLabel2.frame = rect;
  }
  
  if (_commentLabel3.attributedText) {
    rect.origin.y += rect.size.height + INTER_COMMENT_SPACING;
    rect.size = [_commentLabel3 sizeThatFits:CGSizeMake(boundsSize.width, CGFLOAT_MAX)];
    _commentLabel3.frame = rect;
  }
}

#pragma mark - Instance Methods

- (void)prepareForReuse
{
  _commentCountLabel.attributedText       = nil;
  _commentLabel1.attributedText = nil;
  _commentLabel2.attributedText = nil;
  _commentLabel3.attributedText = nil;
  
  [self setNeedsLayout];
}

- (void)updateWithCommentFeedModel:(CommentFeedModel *)feed
{
  _commentFeed = feed;
  
  NSUInteger numComments          = [_commentFeed totalNumberOfCommentsForPhoto];
  if (numComments > 3) {
    NSString *string                  = [NSString stringWithFormat:@"View all %@ comments", [NSNumber numberWithUnsignedInteger:numComments]]; // FIXME: move to model
    _commentCountLabel.attributedText = [NSAttributedString attributedStringWithString:string fontSize:14 color:[UIColor lightGrayColor] firstWordColor:nil];
  }
  
  NSUInteger numLoadedComments    = [_commentFeed numberOfItemsInFeed];
  if (numLoadedComments >= 3) {
    _commentLabel3.attributedText = [[_commentFeed objectAtIndex:2] commentAttributedString];
  }
  if (numLoadedComments >= 2){
    _commentLabel2.attributedText = [[_commentFeed objectAtIndex:1] commentAttributedString];
  }
  if (numLoadedComments >= 1) {
    _commentLabel1.attributedText = [[_commentFeed objectAtIndex:0] commentAttributedString];
  }

  [self setNeedsLayout];
}

@end
