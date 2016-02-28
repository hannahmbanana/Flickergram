//
//  PhotoTableViewCell.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "UIImage+UIImage_Additions.h"
#import "FlickrKit.h"
#import "PINImageView+PINRemoteImage.h"
#import "PINButton+PINRemoteImage.h"


#define CELL_HEADER_HEIGHT 50
#define CELL_HEADER_HORIZONTAL_INSET 10
#define USER_IMAGE_HEIGHT 30

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
  UILabel      *_photoCommentsLabel;
}

#pragma mark - Class methods

//- (CGFloat)heightForCellWithPhotoObject:


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    // tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasTapped:)];
    [self addGestureRecognizer:tgr];
    
    _userProfileImageView                      = [[UIImageView alloc] init];
    
    _userNameLabel                             = [[UILabel alloc] init];
    _userNameLabel.font                        = [_userNameLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    
    _photoLocationLabel                        = [[UILabel alloc] init];
    _photoLocationLabel.font                   = [_photoLocationLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    
    _photoTimeIntervalSincePostLabel           = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel.font      = [_photoTimeIntervalSincePostLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoTimeIntervalSincePostLabel.textColor = [UIColor lightGrayColor];

    _photoImageView                            = [[UIImageView alloc] init];
    [_photoImageView setPin_updateWithProgress:YES];
    
    // make the UIImage fill the UIImageView correctly
    _photoImageView.clipsToBounds              = YES;
    _photoImageView.contentMode                = UIViewContentModeScaleAspectFill;
    
    _photoLikesLabel                           = [[UILabel alloc] init];
    _photoDescriptionLabel                     = [[UILabel alloc] init];
    _photoCommentsLabel                        = [[UILabel alloc] init];
  }
  
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  // top of cell
  _userProfileImageView.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
                                           (CELL_HEADER_HEIGHT - USER_IMAGE_HEIGHT) / 2,
                                           USER_IMAGE_HEIGHT,
                                           USER_IMAGE_HEIGHT);
  [self addSubview:_userProfileImageView];

  [_userNameLabel sizeToFit];
  [_photoLocationLabel sizeToFit];
  
  CGFloat x = CGRectGetMaxX(_userProfileImageView.frame) + CELL_HEADER_HORIZONTAL_INSET;

  if (_photoLocationLabel.text) {
    
    _userNameLabel.frame = CGRectMake(x,
                                      CELL_HEADER_HEIGHT / 2 - _userNameLabel.frame.size.height,
                                      _userNameLabel.frame.size.width,
                                      _userNameLabel.frame.size.height);
    
    _photoLocationLabel.frame = CGRectMake(x,
                                           CELL_HEADER_HEIGHT / 2,
                                           _photoLocationLabel.frame.size.width,
                                           _photoLocationLabel.frame.size.height);
  } else {
    _userNameLabel.frame = CGRectMake(x,
                                      (CELL_HEADER_HEIGHT - _userNameLabel.frame.size.height) / 2,
                                      _userNameLabel.frame.size.width,
                                      _userNameLabel.frame.size.height);
  }

  [self addSubview:_userNameLabel];
  [self addSubview:_photoLocationLabel];
  
  [_photoTimeIntervalSincePostLabel sizeToFit];
  _photoTimeIntervalSincePostLabel.frame = CGRectMake(self.bounds.size.width - _photoTimeIntervalSincePostLabel.frame.size.width - CELL_HEADER_HORIZONTAL_INSET,
                                                      (CELL_HEADER_HEIGHT - _photoTimeIntervalSincePostLabel.frame.size.height) / 2,
                                                      _photoTimeIntervalSincePostLabel.frame.size.width,
                                                      _photoTimeIntervalSincePostLabel.frame.size.height);
  [self addSubview:_photoTimeIntervalSincePostLabel];


  // middle of cell
  _photoImageView.frame = CGRectMake(0,
                                     CELL_HEADER_HEIGHT,
                                     self.bounds.size.width,
                                     self.bounds.size.width - 1 * CELL_HEADER_HEIGHT);
  [self addSubview:_photoImageView];
  
  // bottom of cell
//  [_photoLikesLabel sizeToFit];
//  _photoLikesLabel.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
//                                     CGRectGetMaxY(_photoImageView.frame),
//                                     _photoLikesLabel.frame.size.width,
//                                     _photoLikesLabel.frame.size.height);
//  [self addSubview:_photoLikesLabel];
//  
//  [_photoDescriptionLabel sizeToFit];
//  _photoLikesLabel.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
//                                      CGRectGetMaxY(_photoLikesLabel.frame) + 5,
//                                      _photoDescriptionLabel.frame.size.width,
//                                      _photoDescriptionLabel.frame.size.height);
////  [self addSubview:_photoDescriptionLabel];
//  
//  [_photoCommentsLabel sizeToFit];
//  [self addSubview:_photoCommentsLabel];
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
  
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoObject:(PhotoModel *)photo
{
  _photoModel                           = photo;
  _userNameLabel.text                   = photo.ownerUserProfile.username;
  _photoTimeIntervalSincePostLabel.text = photo.uploadDateString;
  _photoDescriptionLabel.text           = photo.title;
  _photoLocationLabel.text              = photo.location.userFriendlyLocationString;

  // async download of photo using PINRemoteImage
  [_photoImageView pin_setImageFromURL:photo.URL];
  
  // async download of buddy icon using PINRemoteImage
  [_userProfileImageView pin_setImageFromURL:photo.ownerUserProfile.userPicURL processorKey:@"rounded" processor:^UIImage * _Nullable(PINRemoteImageManagerResult * _Nonnull result, NSUInteger * _Nonnull cost) {
    
    // make user profile image round
    return [result.image makeRoundImage];
  }];
}


#pragma mark - Helper Methods


#pragma mark - Gesture Handling

- (void)cellWasTapped:(UIGestureRecognizer *)sender
{
  // determine which area of cell was tapped
  CGPoint tapPoint = [sender locationInView:self];
  
  if (tapPoint.y > CELL_HEADER_HEIGHT) {    // photo
    
    NSLog(@"TAP: photo");
    
  } else if (tapPoint.x <= CGRectGetMaxX(_userProfileImageView.frame)) {
    
    NSLog(@"TAP: Buddy Icon");
    [self.delegate userProfileWasTouchedWithUserID:_photoModel.ownerUserProfile.userID];
    
  } else if (tapPoint.x < CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame)) {
    
    // check if location exists
    if (_photoLocationLabel.text) {
      
      if (tapPoint.y > CGRectGetMinY(_photoLocationLabel.frame)) {
        NSLog(@"TAP: Location Label");
        [self.delegate photoLocationWasTouchedWithCoordinate:_photoModel.location.coordinates];
        
      } else {
        
        NSLog(@"Tap: Username Label");
      }
      
    } else {
      NSLog(@"Tap: Username Label");
    }
  }
}

@end
