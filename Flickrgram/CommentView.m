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


#define NUM_COMMENTS_TO_SHOW_UNEXPANDED 3

@implementation CommentView
{
  CommentFeedModel *_commentFeed;
  UILabel          *_commentCountLabel;
  UILabel          *_commentLabel1;
  UILabel          *_commentLabel2;
  UILabel          *_commentLabel3;
}

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    _commentCountLabel           = [[UILabel alloc] init];
    _commentCountLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_commentCountLabel];
    
    _commentLabel1               = [[UILabel alloc] init];
    _commentLabel1.textColor     = [UIColor darkGrayColor];
    _commentLabel1.numberOfLines = 3;
    [self addSubview:_commentLabel1];
    
    _commentLabel2               = [[UILabel alloc] init];
    _commentLabel2.textColor     = [UIColor darkGrayColor];
    _commentLabel2.numberOfLines = 3;
    [self addSubview:_commentLabel2];
    
    _commentLabel3               = [[UILabel alloc] init];
    _commentLabel3.textColor     = [UIColor darkGrayColor];
    _commentLabel3.numberOfLines = 3;
    [self addSubview:_commentLabel3];
  }
  
  return self;
}

#define INTER_COMMENT_SPACING 5
- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize boundSize = self.bounds.size;
  CGRect rect      = CGRectMake(0, 0, boundSize.width, 0);
  
  if (_commentCountLabel.text) {
    [_commentCountLabel sizeToFit];
    rect.size.height         = _commentCountLabel.frame.size.height;
    _commentCountLabel.frame = rect;
    rect.origin.y           += _commentCountLabel.frame.size.height + INTER_COMMENT_SPACING;
  }
  
  if (_commentLabel1.attributedText) {
    [_commentLabel1 sizeToFit];
    rect.size.height     = _commentLabel1.frame.size.height;
    _commentLabel1.frame = rect;
    rect.origin.y       += _commentLabel1.frame.size.height + INTER_COMMENT_SPACING;
  }
  
  if (_commentLabel2.attributedText) {
    [_commentLabel2 sizeToFit];
    rect.size.height     = _commentLabel2.frame.size.height;
    _commentLabel2.frame = rect;
    rect.origin.y       += _commentLabel2.frame.size.height + INTER_COMMENT_SPACING;
  }
  
  if (_commentLabel3.attributedText) {
    [_commentLabel3 sizeToFit];
    rect.size.height     = _commentLabel3.frame.size.height;
    _commentLabel3.frame = rect;
  }
}

#pragma mark - Instance Methods

- (void)prepareForReuse
{
  _commentCountLabel.text       = nil;
  _commentLabel1.attributedText = nil;
  _commentLabel2.attributedText = nil;
  _commentLabel3.attributedText = nil;
  
  [self setNeedsLayout];
}

- (void)updateWithCommentFeedModel:(CommentFeedModel *)feed{
  
  _commentFeed = feed;
  
  NSUInteger numComments          = [_commentFeed totalNumberOfCommentsForPhoto];
  if (numComments > 3) {
    _commentCountLabel.text       = [NSString stringWithFormat:@"View all %@ comments", [NSNumber numberWithUnsignedInteger:numComments]];
  }
  if (numComments >= 3) {
    _commentLabel3.attributedText = [[NSAttributedString alloc] initWithString:[[_commentFeed objectAtIndex:2] body]]; //[[_commentFeed objectAtIndex:2] commentAttributedString];
  }
  if (numComments >= 2){
    _commentLabel2.attributedText = [[NSAttributedString alloc] initWithString:[[_commentFeed objectAtIndex:1] body]]; //[[_commentFeed objectAtIndex:1] commentAttributedString];
  }
  if (numComments >= 1) {
    _commentLabel1.attributedText = [[NSAttributedString alloc] initWithString:[[_commentFeed objectAtIndex:0] body]]; //[[_commentFeed objectAtIndex:0] commentAttributedString];
  }

  [self setNeedsLayout];
}

@end
