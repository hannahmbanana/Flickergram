//
//  PhotoTableViewCell.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "Utilities.h"
#import "PINImageView+PINRemoteImage.h"
#import "PINButton+PINRemoteImage.h"
#import "CommentView.h"

#define FONT_SIZE 14
#define DEBUG_PHOTOCELL_LAYOUT 0
#define HEADER_HEIGHT 50
#define HORIZONTAL_BUFFER 10
#define VERTICAL_BUFFER 5
#define USER_IMAGE_HEIGHT 30

@interface PhotoTableViewCell () <UIActionSheetDelegate>
@end

@implementation PhotoTableViewCell
{
  PhotoModel   *_photoModel;
  
  UIImageView  *_userProfileImageView;
  UILabel      *_userNameLabel;
  UILabel      *_photoLocationLabel;
  UILabel      *_photoTimeIntervalSincePostLabel;
  
  UIImageView  *_photoImageView;
  
  UILabel      *_photoLikesLabel;
  UILabel      *_photoDescriptionLabel;
  CommentView  *_photoCommentsView;
}


#pragma mark - Class methods

+ (CGFloat)heightForPhotoModel:(PhotoModel *)photo withWidth:(CGFloat)width;
{
  // count number of comments, lines of description
  CGFloat photoHeight = width;
  
  UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
  CGFloat likesHeight = roundf([font lineHeight]);
  NSString *descriptionString = [NSString stringWithFormat:@"%@ %@", photo.ownerUserProfile.username, photo.descriptionText]; // FIXME: move to model
  NSAttributedString *descriptionAttrString = [NSAttributedString attributedStringWithString:descriptionString fontSize:FONT_SIZE
                                                                                   color:nil firstWordColor:nil];

  CGFloat availableWidth = (width - HORIZONTAL_BUFFER * 2);
  CGSize descriptionSize = [descriptionAttrString boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                               context:nil].size;
  
  CGFloat commentViewHeight = [CommentView heightForCommentFeedModel:photo.commentFeed withWidth:availableWidth];

  NSLog(@"1 %f 2 %f 3 %f", likesHeight, descriptionSize.height, commentViewHeight);
  
  return HEADER_HEIGHT + photoHeight + likesHeight + descriptionSize.height + commentViewHeight + (4 * VERTICAL_BUFFER);
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    _userNameLabel                             = [[UILabel alloc] init];
    _photoLocationLabel                        = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel           = [[UILabel alloc] init];
    _photoLikesLabel                           = [[UILabel alloc] init];
    _photoDescriptionLabel               = [[UILabel alloc] init];
    _photoDescriptionLabel.numberOfLines = 3;

    _userProfileImageView                      = [[UIImageView alloc] init];
    _photoImageView                            = [[UIImageView alloc] init];
    _photoImageView.clipsToBounds              = YES; // FIXME: do I need these 2 lines?
    _photoImageView.contentMode                = UIViewContentModeScaleAspectFill;
    [_photoImageView setPin_updateWithProgress:YES];
    
    _photoCommentsView                         = [[CommentView alloc] init];
    
    [self addSubview:_userProfileImageView];  // FIXME: order
    [self addSubview:_userNameLabel];
    [self addSubview:_photoLocationLabel];
    [self addSubview:_photoImageView];
    [self addSubview:_photoLikesLabel];
    [self addSubview:_photoDescriptionLabel];
    [self addSubview:_photoTimeIntervalSincePostLabel];
    [self addSubview:_photoCommentsView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasLongPressed:)];
    [self addGestureRecognizer:lpgr];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasTapped:)];
    [self addGestureRecognizer:tgr];

#if DEBUG_PHOTOCELL_LAYOUT
    _userProfileImageView.backgroundColor             = [UIColor redColor];
    _userNameLabel.backgroundColor                    = [UIColor purpleColor];
    _photoLocationLabel.backgroundColor               = [UIColor greenColor];
    _photoTimeIntervalSincePostLabel.backgroundColor  = [UIColor greenColor];
    _photoCommentsView.backgroundColor                = [UIColor purpleColor];
#endif
  }
  
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGSize boundsSize = self.bounds.size;
  
  // FIXME: Make PhotoCellHeaderView
  
  CGRect rect = CGRectMake(HORIZONTAL_BUFFER, (HEADER_HEIGHT - USER_IMAGE_HEIGHT) / 2.0, USER_IMAGE_HEIGHT, USER_IMAGE_HEIGHT);
  _userProfileImageView.frame = rect;

  rect.size = _photoTimeIntervalSincePostLabel.bounds.size;
  rect.origin.x = boundsSize.width - HORIZONTAL_BUFFER - rect.size.width;
  rect.origin.y = (HEADER_HEIGHT - rect.size.height) / 2.0;
  _photoTimeIntervalSincePostLabel.frame = rect;

  CGFloat availableWidth = CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame) - HORIZONTAL_BUFFER;
  rect.size = _userNameLabel.bounds.size;
  rect.size.width = MIN(availableWidth, rect.size.width);

  rect.origin.x = HORIZONTAL_BUFFER + USER_IMAGE_HEIGHT + HORIZONTAL_BUFFER;
  
  if (_photoLocationLabel.attributedText) {
    CGSize locationSize = _photoLocationLabel.bounds.size;
    locationSize.width = MIN(availableWidth, locationSize.width);
    
    rect.origin.y = (HEADER_HEIGHT - rect.size.height - locationSize.height) / 2.0;
    _userNameLabel.frame = rect;
    
    // FIXME: Name rects at least for this sub-condition
    rect.origin.y += rect.size.height;
    rect.size = locationSize;
    _photoLocationLabel.frame = rect;
  } else {
    rect.origin.y = (HEADER_HEIGHT - rect.size.height) / 2.0;
    _userNameLabel.frame = rect;
  }

  _photoImageView.frame = CGRectMake(0, HEADER_HEIGHT, boundsSize.width, boundsSize.width);
  
  // FIXME: Make PhotoCellFooterView
  
  rect.size = _photoLikesLabel.bounds.size;
  rect.origin = CGPointMake(HORIZONTAL_BUFFER, CGRectGetMaxY(_photoImageView.frame) + VERTICAL_BUFFER);
  _photoLikesLabel.frame = rect;

  rect.size = _photoDescriptionLabel.bounds.size;
  rect.size.width = MIN(boundsSize.width - HORIZONTAL_BUFFER * 2, rect.size.width);
  rect.origin.y = CGRectGetMaxY(_photoLikesLabel.frame) + VERTICAL_BUFFER;
  _photoDescriptionLabel.frame = rect;

  rect.size = _photoCommentsView.bounds.size;
  rect.origin.y = CGRectGetMaxY(_photoDescriptionLabel.frame) + VERTICAL_BUFFER;
  _photoCommentsView.frame = rect;
  
  NSLog(@"1 %@ 2 %@ 3 %@", NSStringFromCGRect(_photoLikesLabel.frame), NSStringFromCGRect(_photoDescriptionLabel.frame), NSStringFromCGRect(_photoCommentsView.frame));
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  
  // remove images so that the old content doesn't appear before the new content is loaded
  _userProfileImageView.image           = nil;
  _photoImageView.image                 = nil;
  
  // remove label text
  _userNameLabel.attributedText                   = nil;
  _photoLocationLabel.attributedText              = nil;
  _photoTimeIntervalSincePostLabel.attributedText = nil;
  _photoLikesLabel.attributedText = nil;
  _photoDescriptionLabel.attributedText = nil;
  
  [_photoCommentsView prepareForReuse];
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoObject:(PhotoModel *)photo
{
  _photoModel                           = photo;
  _photoTimeIntervalSincePostLabel.attributedText = [NSAttributedString attributedStringWithString:photo.uploadDateString fontSize:FONT_SIZE
                                                                                             color:[UIColor lightGrayColor] firstWordColor:nil];
//  _photoDescriptionLabel.attributedText           = photo.title;
  _userNameLabel.attributedText         = [NSAttributedString attributedStringWithString:photo.ownerUserProfile.username
                                                                                fontSize:FONT_SIZE color:[UIColor darkBlueColor] firstWordColor:nil];
  
  NSNumberFormatter *formatter1 = [[NSNumberFormatter alloc] init];
  [formatter1 setNumberStyle:NSNumberFormatterDecimalStyle];
  NSString * formattedAmount2 = [formatter1 stringFromNumber: [[NSNumber alloc] initWithUnsignedInteger:photo.likesCount]];
  
  NSString *string = [NSString stringWithFormat:@"♥︎ %@ likes", formattedAmount2]; // FIXME: move to model
  _photoLikesLabel.attributedText = [NSAttributedString attributedStringWithString:string fontSize:FONT_SIZE color:[UIColor darkBlueColor] firstWordColor:nil];
  NSString *descriptionString = [NSString stringWithFormat:@"%@ %@", photo.ownerUserProfile.username, photo.descriptionText]; // FIXME: move to model
  _photoDescriptionLabel.attributedText = [NSAttributedString attributedStringWithString:descriptionString fontSize:FONT_SIZE
                                                                                   color:[UIColor darkGrayColor] firstWordColor:[UIColor darkBlueColor]];

  [_photoCommentsView updateWithCommentFeedModel:photo.commentFeed];
  
  [photo.location reverseGeocodedLocationWithCompletionBlock:^(LocationModel *locationModel) {
    
    // check and make sure this is still relevant for this cell (and not an old cell)
    // make sure to use _photoModel instance variable as photo may change when cell is reused,
    // where as local variable will never change
    if (locationModel == _photoModel.location) {
      _photoLocationLabel.attributedText = [NSAttributedString attributedStringWithString:photo.location.locationString
                                                                                 fontSize:FONT_SIZE color:[UIColor lightBlueColor] firstWordColor:nil];
      [_photoLocationLabel sizeToFit];
      [self setNeedsLayout];
    }
  }];
  
  // async download of buddy icon using PINRemoteImage
  [_userProfileImageView pin_setImageFromURL:_photoModel.ownerUserProfile.userPicURL processorKey:@"custom" processor:^UIImage * _Nullable(PINRemoteImageManagerResult * _Nonnull result, NSUInteger * _Nonnull cost) {
    CGSize profileImageSize = CGSizeMake(USER_IMAGE_HEIGHT, USER_IMAGE_HEIGHT);
    return [result.image makeCircularImageWithSize:profileImageSize];
  }];

  // async download of photo using PINRemoteImage
  [_photoImageView pin_setImageFromURL:photo.URL];
  
  [_photoLikesLabel sizeToFit];
  [_photoDescriptionLabel sizeToFit];
  [_photoTimeIntervalSincePostLabel sizeToFit];
  [_userNameLabel sizeToFit];
}

- (void)loadCommentsForPhoto:(PhotoModel *)photo
{
  [_photoCommentsView updateWithCommentFeedModel:photo.commentFeed];
  CGRect frame = _photoCommentsView.frame;
  CGFloat availableWidth = (self.bounds.size.width - HORIZONTAL_BUFFER * 2);
  frame.size.width = availableWidth;
  frame.size.height = [CommentView heightForCommentFeedModel:photo.commentFeed withWidth:availableWidth];
  _photoCommentsView.frame = frame;
  [self setNeedsLayout];
}
  
#pragma mark - Helper Methods


#pragma mark - Gesture Handling

- (void)cellWasLongPressed:(UIGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateBegan) {
    
    // determine which area of cell was tapped
    CGPoint tapPoint = [sender locationInView:_photoImageView];
    
    if (tapPoint.y > 0) {
    
      // photo long pressed
      NSLog(@"LONG PRESS");
      
      // need a 2nd method to be able to pass photo model
      [self longPressRecognized];
    }
  }
}

- (void)longPressRecognized
{
  [self.delegate cellWasLongPressedWithPhoto:_photoModel];
}

- (void)cellWasTapped:(UIGestureRecognizer *)sender
{
  // determine which area of cell was tapped
  CGPoint tapPoint = [sender locationInView:self];
  
  if (tapPoint.y > HEADER_HEIGHT) {
    
    // photo tapped
    NSLog(@"TAP: photo");
    
  } else if (tapPoint.x <= CGRectGetMaxX(_userProfileImageView.frame)) {
    
    // user avatar tapped
    NSLog(@"TAP: Buddy Icon");
    
    [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
    
  } else if (tapPoint.x < CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame)) {
    
    // check if location exists
    if (_photoLocationLabel.attributedText) {
      
      if (tapPoint.y > CGRectGetMinY(_photoLocationLabel.frame)) {
        NSLog(@"TAP: Location Label");
        [self.delegate photoLocationWasTouchedWithCoordinate:_photoModel.location.coordinates name:_photoLocationLabel.attributedText];
        
      } else {
        
        NSLog(@"Tap: Username Label");
        
        [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
      }
      
    } else {
      
      // username tapped
      NSLog(@"Tap: Username Label");
      
      [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
    }
  }
}


#pragma mark - UIActionSheetDelegate 


@end
