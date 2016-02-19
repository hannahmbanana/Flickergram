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


#define CELL_HEADER_HEIGHT 40
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
    
    self.backgroundColor                       = [UIColor lightGrayColor];
    
    _userProfileImageView                      = [[UIImageView alloc] init];
    _userNameLabel                             = [[UILabel alloc] init];
    _photoLocationLabel                        = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel           = [[UILabel alloc] init];
    _photoTimeIntervalSincePostLabel.textColor = [UIColor darkGrayColor];

    _photoImageView                            = [[UIImageView alloc] init];
    
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
  _userNameLabel.frame = CGRectMake(CGRectGetMaxX(_userProfileImageView.frame) + CELL_HEADER_HORIZONTAL_INSET,
                                    (CELL_HEADER_HEIGHT - _userNameLabel.frame.size.height) / 2,
                                    _userNameLabel.frame.size.width,
                                    _userNameLabel.frame.size.height);
  [self addSubview:_userNameLabel];

  
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
                                     self.bounds.size.width - 3 * CELL_HEADER_HEIGHT);
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
  
  // cancel network operations
  [_photoDownloadSessionTask cancel];
  [_buddyIconDownloadSessionTask cancel];
  [_networkOp cancel];
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoDictionary:(NSDictionary *)photoDictionary
{
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
        dispatch_async(dispatch_get_main_queue(), ^{
          
          // author name
          _userNameLabel.text = [response valueForKeyPath:@"photo.owner.username"];

          // photo info
          _photoDescriptionLabel.text = [response valueForKeyPath:@"photo.description._content"];
          
          // photo post age
          NSTimeInterval postTime = [[response valueForKeyPath:@"photo.dateuploaded"] floatValue];
          NSDate *postDate        = [NSDate dateWithTimeIntervalSince1970:postTime];
          NSDate *nowDate         = [NSDate date];
          
          NSCalendar *calendar    = [NSCalendar currentCalendar];
          [calendar rangeOfUnit:NSCalendarUnitDay startDate:&postDate interval:NULL forDate:postDate];
          [calendar rangeOfUnit:NSCalendarUnitDay startDate:&nowDate interval:NULL forDate:nowDate];
          
          NSDateComponents *diffS = [calendar components:NSCalendarUnitSecond fromDate:postDate toDate:nowDate options:0];
          NSDateComponents *diffM = [calendar components:NSCalendarUnitMinute fromDate:postDate toDate:nowDate options:0];
          NSDateComponents *diffH = [calendar components:NSCalendarUnitHour fromDate:postDate toDate:nowDate options:0];
          NSDateComponents *diffD = [calendar components:NSCalendarUnitDay fromDate:postDate toDate:nowDate options:0];
          
//          NSLog(@"%lu %lu %lu %lu", [diffS second], [diffM minute], [diffH hour], [diffD day]);
          
          NSString *elapsedTime;
          
          if ([diffD day] > 0) {
            elapsedTime = [NSString stringWithFormat:@"%lud", (long)[diffD day]];
          } else if ([diffH hour] > 0) {
            elapsedTime = [NSString stringWithFormat:@"%luh", (long)[diffH hour]];
          } else if ([diffM minute] > 0) {
            elapsedTime = [NSString stringWithFormat:@"%lum", (long)[diffM minute]];
          } else if ([diffS second] > 0) {
            elapsedTime = [NSString stringWithFormat:@"%lus", (long)[diffS second]];
          }
          
//          // remove the "s" if "1 days", etc
//          if (elapsedTime && [[elapsedTime substringToIndex:1] isEqualToString:@"1"] ) {
//            elapsedTime = [elapsedTime substringToIndex:[elapsedTime length]-1];
//          }
          
          _photoTimeIntervalSincePostLabel.text = elapsedTime;
          
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

@end
