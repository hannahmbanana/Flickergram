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


#define CELL_HEADER_HEIGHT 50
#define CELL_HEADER_HORIZONTAL_INSET 10
#define USER_IMAGE_HEIGHT 30

@implementation PhotoTableViewCell
{
  UIImageView  *_userProfileImageView;
  UILabel      *_userNameLabel;
  UILabel      *_photoLocationLabel;
  UILabel      *_photoTimeIntervalSincePostLabel;
  
  UIImageView  *_photoImageView;
  
  UILabel      *_photoLikesLabel;
  UILabel      *_photoDescriptionLabel;
  UILabel      *_photoCommentsLabel;
  
  NSDictionary              *_photoDictionaryRepresentation;
  
  NSURLSessionTask          *_photoDownloadSessionTask;
  NSURLSessionTask          *_buddyIconDownloadSessionTask;
  FKFlickrNetworkOperation  *_networkOp;

}

#pragma mark - Class methods

//- (CGFloat)heightForCellWithPhotoObject:


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
      
    _userProfileImageView                      = [[UIImageView alloc] init];
    
    _userNameLabel                             = [[UILabel alloc] init];
    _userNameLabel.font                        = [_userNameLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    
    _photoLocationLabel                        = [[UILabel alloc] init];
    _photoLocationLabel.font                   = [_photoLocationLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    
    _photoTimeIntervalSincePostLabel           = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel.font      = [_photoTimeIntervalSincePostLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
    _photoTimeIntervalSincePostLabel.textColor = [UIColor lightGrayColor];

    _photoImageView                            = [[UIImageView alloc] init];
    
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
  _photoDictionaryRepresentation        = nil;
  _userProfileImageView.image           = nil;
  _photoImageView.image                 = nil;
  
  // remove label text
  _userNameLabel.text                   = nil;
  _photoLocationLabel.text              = nil;
  _photoTimeIntervalSincePostLabel.text = nil;
  
  // cancel network operations
  [_photoDownloadSessionTask cancel];
  [_buddyIconDownloadSessionTask cancel];
  [_networkOp cancel];
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoDictionary:(NSDictionary *)photoDictionary
{
  _photoDictionaryRepresentation    = photoDictionary;
  
  // async download of photo
  FlickrKit *fk                     = [FlickrKit sharedFlickrKit];
  NSURL *photoURL                   = [fk photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoDictionary];
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  NSURLSession *session             = [NSURLSession sessionWithConfiguration:config];
  _photoDownloadSessionTask         = [session dataTaskWithURL:photoURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (response) {
      if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          _photoImageView.image = [[UIImage alloc] initWithData:data];
        });
      }
    }
  }];
  [_photoDownloadSessionTask resume];

  // async download of photo info
  FKFlickrPhotosGetInfo *photoInfo = [[FKFlickrPhotosGetInfo alloc] init];
  photoInfo.photo_id               = [photoDictionary valueForKeyPath:@"id"];
  photoInfo.secret                 = [photoDictionary valueForKeyPath:@"secret"];
  _networkOp                       = [fk call:photoInfo completion:^(NSDictionary *response, NSError *error) {
    if (response) {
      if (!error) {
        
        // photo location
        NSDictionary *photoLocationDictionary = [response valueForKeyPath:@"photo.location"];
        NSString *photoLocationString         = [self locationStringFromPhotoLocationDictionary:photoLocationDictionary];
        
        // photo post age
        NSString *elapsedTimeString = [response valueForKeyPath:@"photo.dateuploaded"];
        NSString *photoPostTimeString = [self elapsedTimeStringSinceDate:elapsedTimeString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          // author name
          _userNameLabel.text = [response valueForKeyPath:@"photo.owner.username"];

          // photo info
          _photoDescriptionLabel.text = [response valueForKeyPath:@"photo.description._content"];
          
          // photo location
          _photoLocationLabel.text = photoLocationString;
          
          // photo post age
          if (!elapsedTimeString) {
            NSLog(@"ERROR: %@", [response valueForKeyPath:@"photo"]);
          }
          _photoTimeIntervalSincePostLabel.text = photoPostTimeString;
          
          [self setNeedsLayout];
        });
      }
    }
  }];

  // async download of buddy icon
  NSURL *buddyUrl                   = [fk buddyIconURLForUser:[photoDictionary valueForKeyPath:@"owner"]];
  config                            = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  session                           = [NSURLSession sessionWithConfiguration:config];
  _buddyIconDownloadSessionTask     = [session dataTaskWithURL:buddyUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (response) {
      if (!error) {
        UIImage *roundedBuddyIcon = [[[UIImage alloc] initWithData:data] makeRoundImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          _userProfileImageView.image = roundedBuddyIcon;
        });
      }
    }
  }];
  [_buddyIconDownloadSessionTask resume];
  
  
}


#pragma mark - Helper Methods

- (nullable NSString *)locationStringFromPhotoLocationDictionary:(NSDictionary *)photoLocationDictionary
{
  // early return if no location info
  if (!photoLocationDictionary)
  {
    return nil;
  }
  
  NSString *country       = [photoLocationDictionary valueForKeyPath:@"country._content"];
  NSString *county        = [photoLocationDictionary valueForKeyPath:@"county._content"];
  NSString *locality      = [photoLocationDictionary valueForKeyPath:@"locality._content"];
  NSString *neighbourhood = [photoLocationDictionary valueForKeyPath:@"neighbourhood._content"];
  NSString *region        = [photoLocationDictionary valueForKeyPath:@"region._content"];

  NSString *locationString;

  if (neighbourhood) {
    locationString = [NSString stringWithFormat:@"%@", neighbourhood];
  } else if (locality && county) {
    locationString = [NSString stringWithFormat:@"%@, %@", locality, county];
  } else if (region) {
    locationString = [NSString stringWithFormat:@"%@, %@", region, country];
  } else if (country) {
    locationString = [NSString stringWithFormat:@"%@", country];
  } else {
    locationString = @"ERROR";
  }
  
//  NSLog(@"%@", photoLocationDictionary);
//  NSLog(@"%@, %@, %@, %@, %@", neighbourhood, locality, county, region, country);
//  NSLog(@"%@", locationString);

  return locationString;
}

- (NSString *)elapsedTimeStringSinceDate:(NSString *)stringWithTimeIntervalSince1970
{
  // early return if no post date string
  if (!stringWithTimeIntervalSince1970)
  {
    return @"NO POST DATE";
  }
  
  NSTimeInterval postInterval = [stringWithTimeIntervalSince1970 floatValue];
  NSDate *postDate            = [NSDate dateWithTimeIntervalSince1970:postInterval];
  NSDate *currentDate         = [NSDate date];
  
  NSCalendar *calendar        = [NSCalendar currentCalendar];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&postDate    interval:NULL forDate:postDate];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&currentDate interval:NULL forDate:currentDate];
  
  NSUInteger seconds = [[calendar components:NSCalendarUnitSecond fromDate:postDate toDate:currentDate options:0] second];
  NSUInteger minutes = [[calendar components:NSCalendarUnitMinute fromDate:postDate toDate:currentDate options:0] minute];
  NSUInteger hours   = [[calendar components:NSCalendarUnitHour   fromDate:postDate toDate:currentDate options:0] hour];
  NSUInteger days    = [[calendar components:NSCalendarUnitDay    fromDate:postDate toDate:currentDate options:0] day];

  NSString *elapsedTime;
  
  if (days > 7) {
    elapsedTime = [NSString stringWithFormat:@"%luw", (long)ceil(days/7.0)];
  } else if (days > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lud", (long)days];
  } else if (hours > 0) {
    elapsedTime = [NSString stringWithFormat:@"%luh", (long)hours];
  } else if (minutes > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lum", (long)minutes];
  } else if (seconds > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lus", (long)seconds];
  } else {
    elapsedTime = @"ERROR";
  }

  return elapsedTime;
}

@end
