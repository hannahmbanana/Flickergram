//
//  UserProfileViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/24/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImage+UIImage_Additions.h"
#import "FlickrKit.h"

@implementation UserProfileViewController
{
  UIImageView  *_userProfileImageView;
  NSString *_userID;
}

- (instancetype)initWithUserID:(NSString *)userID
{
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    
    _userProfileImageView                      = [[UIImageView alloc] init];
    _userID = userID;
    
    [self downloadBuddyImage];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // top of cell
  _userProfileImageView.frame = CGRectMake(100, 100, 60, 60);
  
  [self.view addSubview:_userProfileImageView];
}

- (void)downloadBuddyImage
{
  // async download of buddy icon
  FlickrKit *fk                     = [FlickrKit sharedFlickrKit];
  NSURL *buddyUrl                   = [fk buddyIconURLForUser:_userID];
  NSURLSessionConfiguration *config  = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  NSURLSession *session              = [NSURLSession sessionWithConfiguration:config];
  NSURLSessionDataTask *buddyIconDownloadSessionTask     = [session dataTaskWithURL:buddyUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (response) {
      if (!error) {
        UIImage *roundedBuddyIcon = [[[UIImage alloc] initWithData:data] makeRoundImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          _userProfileImageView.image = roundedBuddyIcon;
          
        });
      }
    }
  }];
  [buddyIconDownloadSessionTask resume];
  
  
}

@end
