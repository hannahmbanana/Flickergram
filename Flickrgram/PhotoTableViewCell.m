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

#define CELL_HEADER_HEIGHT 50
#define CELL_HEADER_HORIZONTAL_INSET 10
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

+ (CGFloat)cellHeaderFooterHeightForDataModel:(PhotoModel *)photo
{
  // count number of comments, lines of description
  CGFloat height = CELL_HEADER_HEIGHT * 6;
  return height;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    _userProfileImageView                      = [[UIImageView alloc] init];
//    _userProfileImageView.backgroundColor      = [UIColor redColor];
  
    
    
    _userNameLabel                             = [[UILabel alloc] init];
    _userNameLabel.font                        = [_userNameLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _userNameLabel.textColor                   = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
//    _userNameLabel.backgroundColor             = [UIColor purpleColor];

    _photoLocationLabel                        = [[UILabel alloc] init];
    _photoLocationLabel.font                   = [_photoLocationLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoLocationLabel.textColor              = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
//    _photoLocationLabel.backgroundColor             = [UIColor greenColor];

    _photoTimeIntervalSincePostLabel           = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel.font      = [_photoTimeIntervalSincePostLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoTimeIntervalSincePostLabel.textColor = [UIColor lightGrayColor];
//    _photoTimeIntervalSincePostLabel.backgroundColor             = [UIColor greenColor];


    _photoImageView                            = [[UIImageView alloc] init];
    [_photoImageView setPin_updateWithProgress:YES];
    
    // make the UIImage fill the UIImageView correctly
    _photoImageView.clipsToBounds              = YES;
    _photoImageView.contentMode                = UIViewContentModeScaleAspectFill;
    
    _photoLikesLabel                           = [[UILabel alloc] init];
    _photoLikesLabel.font                        = [_photoLikesLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoLikesLabel.textColor                   = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
    
    _photoDescriptionLabel                     = [[UILabel alloc] init];
    _photoDescriptionLabel.font                = [_photoDescriptionLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoDescriptionLabel.numberOfLines       = 3;

    _photoCommentsView                         = [[CommentView alloc] init];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasLongPressed:)];
    [self addGestureRecognizer:lpgr];
    
    // tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasTapped:)];
    [self addGestureRecognizer:tgr];
  }
  
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  // user avatar
  _userProfileImageView.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
                                           (CELL_HEADER_HEIGHT - USER_IMAGE_HEIGHT) / 2,
                                           USER_IMAGE_HEIGHT,
                                           USER_IMAGE_HEIGHT);
  [self addSubview:_userProfileImageView];

  // post time elapsed
  [_photoTimeIntervalSincePostLabel sizeToFit];
  
  CGFloat x = self.bounds.size.width - _photoTimeIntervalSincePostLabel.frame.size.width - CELL_HEADER_HORIZONTAL_INSET;
  CGFloat y = (CELL_HEADER_HEIGHT - _photoTimeIntervalSincePostLabel.frame.size.height) / 2;
  
  _photoTimeIntervalSincePostLabel.frame = (CGRect) { CGPointMake(x,y), _photoTimeIntervalSincePostLabel.frame.size };
  [self addSubview:_photoTimeIntervalSincePostLabel];
  
  // username & photo location
  [_userNameLabel sizeToFit];       
  [_photoLocationLabel sizeToFit];

  x = CGRectGetMaxX(_userProfileImageView.frame) + CELL_HEADER_HORIZONTAL_INSET;
  CGFloat maxX = CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame) - CELL_HEADER_HORIZONTAL_INSET;
  
  if (_photoLocationLabel.text) {
    
    y = CELL_HEADER_HEIGHT / 2 - _userNameLabel.frame.size.height;
    
    
    
    _userNameLabel.frame = CGRectMake(x,
                                      y,
                                      maxX - x,
                                      _userNameLabel.frame.size.height);
    
    _photoLocationLabel.frame = CGRectMake(x,
                                           CELL_HEADER_HEIGHT / 2,
                                           maxX - x,
                                           _photoLocationLabel.frame.size.height);
  } else {
    _userNameLabel.frame = CGRectMake(x,
                                      (CELL_HEADER_HEIGHT - _userNameLabel.frame.size.height) / 2,
                                      maxX - x,
                                      _userNameLabel.frame.size.height);
  }

  [self addSubview:_userNameLabel];
  [self addSubview:_photoLocationLabel];

  // middle of cell
  _photoImageView.frame = CGRectMake(0,
                                     CELL_HEADER_HEIGHT,
                                     self.bounds.size.width,
                                     self.bounds.size.width);
  [self addSubview:_photoImageView];
  
  // bottom of cell
  [_photoLikesLabel sizeToFit];
  _photoLikesLabel.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
                                     CGRectGetMaxY(_photoImageView.frame)+ 5,
                                     _photoLikesLabel.frame.size.width,
                                     _photoLikesLabel.frame.size.height);
  [self addSubview:_photoLikesLabel];

  [_photoDescriptionLabel sizeToFit];
  _photoDescriptionLabel.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
                                      CGRectGetMaxY(_photoLikesLabel.frame) + 5,
                                      self.bounds.size.width - CELL_HEADER_HORIZONTAL_INSET * 2,
                                      _photoDescriptionLabel.frame.size.height);
  [self addSubview:_photoDescriptionLabel];

  [_photoCommentsView sizeToFit];
  _photoCommentsView.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
                                            CGRectGetMaxY(_photoDescriptionLabel.frame) + 5,
                                            self.bounds.size.width - CELL_HEADER_HORIZONTAL_INSET * 2,
                                            _photoCommentsView.frame.size.height);
  
  [self addSubview:_photoCommentsView];
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  
  // remove images so that the old content doesn't appear before the new content is loaded
  _userProfileImageView.image           = nil;
  _photoImageView.image                 = nil;
  
  // remove label text
  _userNameLabel.text                   = nil;
  _photoLocationLabel.text              = nil;
  _photoTimeIntervalSincePostLabel.text = nil;
  _photoLikesLabel.text = nil;
  _photoDescriptionLabel.text = nil;
  
  [_photoCommentsView prepareForReuse];
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoObject:(PhotoModel *)photo
{
  _photoModel                           = photo;
  _photoTimeIntervalSincePostLabel.text = photo.uploadDateString;
  _photoDescriptionLabel.text           = photo.title;
  _userNameLabel.text                   = photo.ownerUserProfile.username;
  _photoLikesLabel.text                 = [NSString stringWithFormat:@"♥︎ %@ likes", [[[NSNumber alloc] initWithUnsignedInteger:photo.likesCount] description]];
  _photoDescriptionLabel.text           = [NSString stringWithFormat:@"%@ %@", photo.ownerUserProfile.username, photo.descriptionText];

  [_photoCommentsView updateWithCommentFeedModel:photo.commentFeed];
  
  [photo.location reverseGeocodedLocationWithCompletionBlock:^(LocationModel *locationModel) {
    
    // check and make sure this is still relevant for this cell (and not an old cell)
    // make sure to use _photoModel instance variable as photo may change when cell is reused,
    // where as local variable will never change
    if (locationModel == _photoModel.location) {
      _photoLocationLabel.text = photo.location.locationString;
      
      [self setNeedsLayout];
    }
  }];

  // async download of photo using PINRemoteImage
  [_photoImageView pin_setImageFromURL:photo.URL];
  
  // async download of buddy icon using PINRemoteImage
  [_userProfileImageView pin_setImageFromURL:photo.ownerUserProfile.userPicURL processorKey:@"rounded" processor:^UIImage * _Nullable(PINRemoteImageManagerResult * _Nonnull result, NSUInteger * _Nonnull cost) {
    
    // make user profile image round
    return [result.image makeRoundImage];
  }];
}

- (void)loadCommentsForPhoto:(PhotoModel *)photo
{
  [_photoCommentsView updateWithCommentFeedModel:photo.commentFeed];
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
  
  if (tapPoint.y > CELL_HEADER_HEIGHT) {
    
    // photo tapped
    NSLog(@"TAP: photo");
    
  } else if (tapPoint.x <= CGRectGetMaxX(_userProfileImageView.frame)) {
    
    // user avatar tapped
    NSLog(@"TAP: Buddy Icon");
    
    [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
    
  } else if (tapPoint.x < CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame)) {
    
    // check if location exists
    if (_photoLocationLabel.text) {
      
      if (tapPoint.y > CGRectGetMinY(_photoLocationLabel.frame)) {
        NSLog(@"TAP: Location Label");
        [self.delegate photoLocationWasTouchedWithCoordinate:_photoModel.location.coordinates name:_photoLocationLabel.text];
        
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
