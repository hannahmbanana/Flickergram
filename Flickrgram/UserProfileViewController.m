//
//  UserProfileViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/24/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImage+UIImage_Additions.h"

#define HEADER_HEIGHT           300
#define USER_AVATAR_HEIGHT      70
#define HEADER_HORIZONTAL_INSET 15

@implementation UserProfileViewController
{
  UserModel    *_user;
  
  UIImageView  *_avatarImageView;
  UIImage      *_followingStatusImage;
  UILabel      *_fullNameLabel;
  UILabel      *_aboutLabel;
  UILabel      *_domainLabel;
  UILabel      *_followersCountLabel;
  UILabel      *_followingCountLabel;
  UILabel      *_viewsCountLabel;
}

- (instancetype)initWithUser:(UserModel *)user
{
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {
    
    self.navigationItem.title = user.username;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _user = user;
    
    _avatarImageView = [[UIImageView alloc] init]; // FIXME: return image
    _avatarImageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_avatarImageView];
    
    _fullNameLabel                        = [[UILabel alloc] init];
//    _fullNameLabel.font                   = [_fullNameLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _fullNameLabel.textColor              = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _fullNameLabel.backgroundColor        = [UIColor greenColor];
    [self.view addSubview:_fullNameLabel];

    _aboutLabel                        = [[UILabel alloc] init];
    _aboutLabel.numberOfLines         = 3;
//    _aboutLabel.font                   = [_fullNameLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _aboutLabel.backgroundColor        = [UIColor greenColor];
    [self.view addSubview:_aboutLabel];
    
    _domainLabel                        = [[UILabel alloc] init];
    _domainLabel.textColor = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
    //    _aboutLabel.font                   = [_fullNameLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _domainLabel.backgroundColor        = [UIColor greenColor];
    [self.view addSubview:_domainLabel];

    _followersCountLabel           = [[UILabel alloc] init];
//    _followersCountLabel.font      = [_followersCountLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _followersCountLabel.textColor = [UIColor lightGrayColor];
    _followersCountLabel.backgroundColor             = [UIColor greenColor];
    [self.view addSubview:_followersCountLabel];

    _followingCountLabel           = [[UILabel alloc] init];
//    _followingCountLabel.font      = [_followingCountLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _followingCountLabel.textColor = [UIColor lightGrayColor];
    _followingCountLabel.backgroundColor             = [UIColor greenColor];
    [self.view addSubview:_followingCountLabel];
    
    _followingCountLabel           = [[UILabel alloc] init];
//    _followingCountLabel.font      = [_followingCountLabel.font fontWithSize:floorf(USER_AVATAR_HEIGHT/2)-1];
    _followingCountLabel.textColor = [UIColor lightGrayColor];
    _followingCountLabel.backgroundColor             = [UIColor greenColor];
    [self.view addSubview:_followingCountLabel];
    
    // tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileWasTapped:)];
    [self.view addGestureRecognizer:tgr];
    
    // This is what we have available as soon as we're created, without fetching new metadata from the network.
    _fullNameLabel.text = _user.username;
    [self.view setNeedsLayout];
    
    [self loadAdditionalProfileFields];
  }
  return self;
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  
  CGSize boundsSize = self.view.bounds.size;
  
  // user avatar
  CGFloat x = HEADER_HORIZONTAL_INSET;
  CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame) + HEADER_HORIZONTAL_INSET;
  _avatarImageView.frame = CGRectMake(x,
                                      y,
                                      USER_AVATAR_HEIGHT,
                                      USER_AVATAR_HEIGHT);
  
  if (_fullNameLabel.text) {
    [_fullNameLabel sizeToFit];
    y += HEADER_HORIZONTAL_INSET + _avatarImageView.frame.size.height;
    _fullNameLabel.frame = CGRectMake(x,
                                      y,
                                      boundsSize.width - 2 * HEADER_HORIZONTAL_INSET,
                                      _fullNameLabel.frame.size.height);
  }
  
  if (_aboutLabel.text) {
    [_aboutLabel sizeToFit];
    y += HEADER_HORIZONTAL_INSET + _fullNameLabel.frame.size.height;
    _aboutLabel.frame = CGRectMake(x,
                                   y,
                                   boundsSize.width - 2 * HEADER_HORIZONTAL_INSET,
                                   _aboutLabel.frame.size.height);
  }
  
  if (_domainLabel.text) {
    [_domainLabel sizeToFit];
    y += HEADER_HORIZONTAL_INSET + _aboutLabel.frame.size.height;
    _domainLabel.frame = CGRectMake(x,
                                    y,
                                    boundsSize.width - 2 * HEADER_HORIZONTAL_INSET,
                                    _domainLabel.frame.size.height);
  }
}


#pragma mark - Helper Methods

- (void)loadAdditionalProfileFields
{
  // fetch full user profile info
  [_user downloadCompleteUserDataWithCompletionBlock:^(UserModel *userModel) {

    // check that info returning from async download is still applicable to this view
    if (userModel == _user) {
      
      _followersCountLabel.text = [[NSNumber numberWithUnsignedInteger:userModel.followersCount] description];
      _followingCountLabel.text = [[NSNumber numberWithUnsignedInteger:userModel.friendsCount] description];
      _aboutLabel.text = userModel.about;
      _domainLabel.text = userModel.domain;
      
      [self.view setNeedsLayout];
    }
  }];
}

- (void)profileWasTapped:(UITapGestureRecognizer *)sender
{
  NSLog(@"tap");
}

@end
