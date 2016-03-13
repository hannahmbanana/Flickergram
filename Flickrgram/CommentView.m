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

+ (NSAttributedString *)attributedStringWithString:(NSString *)string   //FIXME:
{
  NSDictionary *attributes                    = @{NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                                  NSFontAttributeName: [UIFont systemFontOfSize:14]};
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
  [attributedString addAttributes:attributes range:NSMakeRange(0, string.length)];
  
  return attributedString;
}

+ (CGFloat)heightForCommentFeedModel:(CommentFeedModel *)commentFeed withWidth:(CGFloat)width
{
  CGFloat height = 0;
  NSAttributedString *string;
  
  NSUInteger numComments       = [commentFeed totalNumberOfCommentsForPhoto];
  if (numComments > 3) {
    NSString *countString      = [NSString stringWithFormat:@"View all %@ comments", [NSNumber numberWithUnsignedInteger:numComments]];
    NSAttributedString *string = [CommentView attributedStringWithString:countString];
    CGRect countStringRect     = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    height                    += countStringRect.size.height + INTER_COMMENT_SPACING;
  }
  
  NSUInteger numCommentsInFeed = [commentFeed numberOfItemsInFeed];

  for (int i = 0; i < numCommentsInFeed; i++) {
    
    CommentModel *comment      = [commentFeed objectAtIndex:i];
    string                     = [CommentView attributedStringWithString:comment.body];
    CGRect stringRect          = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    height                    += stringRect.size.height + INTER_COMMENT_SPACING;
  }

  return height;
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

- (void)updateWithCommentFeedModel:(CommentFeedModel *)feed withFontSize:(CGFloat)size
{
  _commentCountLabel.font = [_commentCountLabel.font fontWithSize:size];
  _commentLabel1.font = [_commentLabel1.font fontWithSize:size];
  _commentLabel2.font = [_commentLabel2.font fontWithSize:size];
  _commentLabel3.font = [_commentLabel3.font fontWithSize:size];
  
  _commentFeed = feed;
  
  NSUInteger numComments          = [_commentFeed totalNumberOfCommentsForPhoto];
  if (numComments > 3) {
    _commentCountLabel.text       = [NSString stringWithFormat:@"View all %@ comments", [NSNumber numberWithUnsignedInteger:numComments]];
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
