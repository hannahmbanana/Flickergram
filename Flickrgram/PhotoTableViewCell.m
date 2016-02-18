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


#define CELL_HEADER_HEIGHT 30

@implementation PhotoTableViewCell
{
  UIImageView *_userProfileImageView;
  UILabel     *_userNameLabel;
  UILabel     *_photoLocationLabel;
  UILabel     *_photoTimeIntervalSincePostLabel;
  UIImageView *_photoImageView;
  UILabel     *_photoLikesLabel;
  UILabel     *_photoDescriptionLabel;
  UILabel     *_photoCommentsLabel;
}

#pragma mark - Class methods

//- (CGFloat)heightForCellWithPhotoObject:


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    _photoImageView = [[UIImageView alloc] init];
    _userProfileImageView = [[UIImageView alloc] init];
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textColor = [UIColor whiteColor];
    _photoLocationLabel = [[UILabel alloc] init];
    _photoLocationLabel.textColor = [UIColor whiteColor];
    _photoTimeIntervalSincePostLabel = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel.textColor = [UIColor whiteColor];

  }
  
  return self;
}

- (void)layoutSubviews
{
  _photoImageView.frame = self.bounds;
  _userProfileImageView.frame = CGRectMake(0, 0, 30, 30);
  [_userNameLabel sizeToFit];
  _userNameLabel.frame = CGRectMake(30, 0, 200, 40);
  
  _photoLocationLabel.frame = CGRectMake(30, 50, 200, 40);
  _photoTimeIntervalSincePostLabel.frame = CGRectMake(30, 50, 200, 40);


  [self addSubview:_photoImageView];
  [self addSubview:_userProfileImageView];
  [self addSubview:_userNameLabel];
  [self addSubview:_photoLocationLabel];
  [self addSubview:_photoTimeIntervalSincePostLabel];
}

- (void)prepareForReuse
{
  _userProfileImageView.image = nil;
  
  // put grey placeholders in imageView spots
}

#pragma mark - Instance Methods

- (void)updateCellWithPhotoURL:(NSURL *)photoURL
{
  // download the image
  NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLargeSquare150 fromPhotoDictionary:photoURL];

  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
    _photoImageView.image = [[UIImage alloc] initWithData:data];
  }];
  
  // download the buddy icon
  NSURL *buddyUrl = [[FlickrKit sharedFlickrKit] buddyIconURLForUser:[photoURL valueForKeyPath:@"owner"]];
  request = [NSURLRequest requestWithURL:buddyUrl];
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
    UIImage *roundedBuddyIcon = [[[UIImage alloc] initWithData:data] makeRoundImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      _userProfileImageView.image = roundedBuddyIcon;
    });
    
  }];
  
  
  // get user name
  FKFlickrPeopleGetInfo *peopleInfo = [[FKFlickrPeopleGetInfo alloc] init];
  peopleInfo.user_id = [photoURL valueForKeyPath:@"owner"];
  
  [[FlickrKit sharedFlickrKit] call:peopleInfo completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          _userNameLabel.text = [response valueForKeyPath:@"person.username._content"];
        });
      }
    });
  }];

  
  // get photo info
  FKFlickrPhotosGetInfo *photoInfo = [[FKFlickrPhotosGetInfo alloc] init];
  photoInfo.photo_id = [photoURL valueForKeyPath:@"id"];
  photoInfo.secret = [photoURL valueForKeyPath:@"secret"];
  
  [[FlickrKit sharedFlickrKit] call:photoInfo completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          CFTimeInterval time = [[response valueForKeyPath:@"photo.dateuploaded"] integerValue];
          CFTimeInterval now = CFAbsoluteTimeGetCurrent();
          CFGregorianUnits units = CFAbsoluteTimeGetDifferenceAsGregorianUnits(now, time, nil, nil);
          _photoTimeIntervalSincePostLabel.text = [NSString stringWithFormat:@"%d",units.days];

        });
      }
    });
  }];
  
  // redo the layout
  [self setNeedsLayout];
}


#pragma mark - Helper Methods




@end
