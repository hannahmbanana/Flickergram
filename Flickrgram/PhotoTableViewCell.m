//
//  PhotoTableViewCell.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "UIImage+UIImage_Additions.h"
#import "PINImageView+PINRemoteImage.h"
#import "PINButton+PINRemoteImage.h"

#define DEBUG_PHOTO_CELL                0
#define CELL_HEADER_HEIGHT              50
#define CELL_HEADER_HORIZONTAL_INSET    10
#define CELL_HEADER_VERTICAL_INSET      ((CELL_HEADER_HEIGHT - USER_IMAGE_HEIGHT) / 2)
#define USER_IMAGE_HEIGHT               30

@interface PhotoTableViewCell () <UIActionSheetDelegate>
@end

@implementation PhotoTableViewCell
{
  PhotoModel          *_photoModel;
  
  ASNetworkImageNode  *_userProfileImageView;
  
  ASTextNode          *_userNameLabel;
  
  ASTextNode          *_photoLocationLabel;

  ASTextNode          *_photoTimeIntervalSincePostLabel;
  
  ASNetworkImageNode  *_photoImageView;
  
  ASTextNode          *_photoLikesLabel;
  ASTextNode          *_photoDescriptionLabel;
  ASTextNode          *_photoCommentsLabel;
}


#pragma mark - Class methods

+ (CGFloat)cellHeaderFooterHeightForDataModel:(PhotoModel *)photo
{
  CGFloat height = CELL_HEADER_HEIGHT;
  return height;
}


#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    
    _userProfileImageView                      = [[ASNetworkImageNode alloc] init];
    
    _userNameLabel                             = [[ASTextNode alloc] init];
    _userNameLabel.hitTestSlop                 = UIEdgeInsetsMake(-5, -10, -5, -10);  // negative becasue we want outset not inset :)
    
    // allows me to get rid of gesture recovnizer
    [_userNameLabel addTarget:self action:@selector(userNameTapped) forControlEvents:ASControlNodeEventTouchUpInside];
    
//    _userNameLabel.font                        = [_userNameLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
//    _userNameLabel.textColor                   = [UIColor colorWithRed:18.0/255.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];

    _photoLocationLabel                        = [[ASTextNode alloc] init];
//    _photoLocationLabel.font                   = [_photoLocationLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
//    _photoLocationLabel.textColor              = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

    _photoTimeIntervalSincePostLabel           = [[ASTextNode alloc] init];
//    _photoTimeIntervalSincePostLabel.font      = [_photoTimeIntervalSincePostLabel.font fontWithSize:floorf(USER_IMAGE_HEIGHT/2)-1];
//    _photoTimeIntervalSincePostLabel.textColor = [UIColor lightGrayColor];

    _photoImageView                            = [[ASNetworkImageNode alloc] init];
//    [_photoImageView setPin_updateWithProgress:YES];
    
    // make the UIImage fill the UIImageView correctly
    _photoImageView.clipsToBounds              = YES;
    _photoImageView.contentMode                = UIViewContentModeScaleAspectFill;
    
    _photoLikesLabel                           = [[ASTextNode alloc] init];
    _photoDescriptionLabel                     = [[ASTextNode alloc] init];
    _photoCommentsLabel                        = [[ASTextNode alloc] init];
    
    [self addSubnode:_userProfileImageView];
    [self addSubnode:_photoTimeIntervalSincePostLabel];
    [self addSubnode:_userNameLabel];
    [self addSubnode:_photoLocationLabel];
    [self addSubnode:_photoImageView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasLongPressed:)];
    [self.view addGestureRecognizer:lpgr];
    
    // tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasTapped:)];
    [self.view addGestureRecognizer:tgr];
    
    if (DEBUG) {
      _userProfileImageView.backgroundColor    = [UIColor redColor];
      _userNameLabel.backgroundColor           = [UIColor purpleColor];
      _photoLocationLabel.backgroundColor      = [UIColor greenColor];
      _photoTimeIntervalSincePostLabel.backgroundColor = [UIColor greenColor];
    }
  }
  
  return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
  CGFloat cellWidth = constrainedSize.max.width;
  _photoImageView.preferredFrameSize = CGSizeMake(cellWidth, cellWidth);
  _userProfileImageView.preferredFrameSize = CGSizeMake(USER_IMAGE_HEIGHT, USER_IMAGE_HEIGHT);
  
  ASStackLayoutSpec *headerStack = [ASStackLayoutSpec horizontalStackLayoutSpec];
  
  [headerStack setChildren:@[_userProfileImageView, _userNameLabel, _photoTimeIntervalSincePostLabel]];
  
  UIEdgeInsets insets = UIEdgeInsetsMake(CELL_HEADER_VERTICAL_INSET, CELL_HEADER_HORIZONTAL_INSET,
                                         CELL_HEADER_VERTICAL_INSET, CELL_HEADER_HORIZONTAL_INSET);
  
  ASInsetLayoutSpec *headerWithInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:headerStack];
  
  ASStackLayoutSpec *verticalStack = [ASStackLayoutSpec verticalStackLayoutSpec];
  [verticalStack setChildren:@[headerWithInset, _photoImageView]];
  return verticalStack;
}

// OR
//- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize;
// and
//- (void)layout
//{
//  [super layout];
//  
//  // user avatar
//  _userProfileImageView.frame = CGRectMake(CELL_HEADER_HORIZONTAL_INSET,
//                                           (CELL_HEADER_HEIGHT - USER_IMAGE_HEIGHT) / 2,
//                                           USER_IMAGE_HEIGHT,
//                                           USER_IMAGE_HEIGHT);
//  
//  // post time elapsed
//  [_photoTimeIntervalSincePostLabel measure:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
//  
//  CGFloat x = self.bounds.size.width - _photoTimeIntervalSincePostLabel.calculatedSize.width - CELL_HEADER_HORIZONTAL_INSET;
//  CGFloat y = (CELL_HEADER_HEIGHT - _photoTimeIntervalSincePostLabel.calculatedSize.height) / 2;
//  
//  _photoTimeIntervalSincePostLabel.frame = (CGRect) { CGPointMake(x,y), _photoTimeIntervalSincePostLabel.calculatedSize };
//  
//  
//  // username & photo location
//  [_userNameLabel measure:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
//  [_photoLocationLabel measure:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
//
//  x = CGRectGetMaxX(_userProfileImageView.frame) + CELL_HEADER_HORIZONTAL_INSET;
//  CGFloat maxX = CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame) - CELL_HEADER_HORIZONTAL_INSET;
//  
//  if (_photoLocationLabel.attributedString) {
//    
//    y = CELL_HEADER_HEIGHT / 2 - _userNameLabel.frame.size.height;
//    
//    _userNameLabel.frame = CGRectMake(x,
//                                      y,
//                                      maxX - x,
//                                      _userNameLabel.frame.size.height);
//    
//    _photoLocationLabel.frame = CGRectMake(x,
//                                           CELL_HEADER_HEIGHT / 2,
//                                           maxX - x,
//                                           _photoLocationLabel.calculatedSize.height);
//  } else {
//    _userNameLabel.frame = CGRectMake(x,
//                                      (CELL_HEADER_HEIGHT - _userNameLabel.calculatedSize.height) / 2,
//                                      maxX - x,
//                                      _userNameLabel.calculatedSize.height);
//  }
//
//  // middle of cell
//  _photoImageView.frame = CGRectMake(0,
//                                     CELL_HEADER_HEIGHT,
//                                     self.bounds.size.width,
//                                     self.bounds.size.width);
  
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
//}

- (void)prepareForReuse
{
//  [super prepareForReuse];
  
  // remove images so that the old content doesn't appear before the new content is loaded
  _userProfileImageView.image           = nil;
  _photoImageView.image                 = nil;
  
  // remove label text
  _userNameLabel.attributedString                   = nil;
  _photoLocationLabel.attributedString              = nil;
  _photoTimeIntervalSincePostLabel.attributedString = nil;
}


#pragma mark - Instance Methods

- (void)updateCellWithPhotoObject:(PhotoModel *)photo
{
  _photoModel                                       = photo;
  _photoTimeIntervalSincePostLabel.attributedString = [[NSAttributedString alloc] initWithString:photo.uploadDateString ? : @""];
  _photoDescriptionLabel.attributedString           = [[NSAttributedString alloc] initWithString:photo.title ? : @""];
  _userNameLabel.attributedString                   = [[NSAttributedString alloc] initWithString:photo.ownerUserProfile.username ? : @""];
  
  [photo.location reverseGeocodedLocationWithCompletionBlock:^(LocationModel *locationModel) {
    
    // check and make sure this is still relevant for this cell (and not an old cell)
    // make sure to use _photoModel instance variable as photo may change when cell is reused,
    // where as local variable will never change
    if (locationModel == _photoModel.location) {
      _photoLocationLabel.attributedString = [[NSAttributedString alloc] initWithString:photo.location.locationString ? : @""];
      
      [self setNeedsLayout];
    }
  }];


  // async download of photo using PINRemoteImage
  _photoImageView.URL = photo.URL;
  
  // async download of buddy icon using PINRemoteImage
  _userProfileImageView.URL = photo.ownerUserProfile.userPicURL;
//  [_userProfileImageView pin_setImageFromURL:photo.ownerUserProfile.userPicURL processorKey:@"rounded" processor:^UIImage * _Nullable(PINRemoteImageManagerResult * _Nonnull result, NSUInteger * _Nonnull cost) {
//    
//    // make user profile image round
//    return [result.image makeRoundImage];
//  }];
}


#pragma mark - Helper Methods


#pragma mark - Gesture Handling

- (void)cellWasLongPressed:(UIGestureRecognizer *)sender
{
//  if (sender.state == UIGestureRecognizerStateBegan) {
//    
//    // determine which area of cell was tapped
//    CGPoint tapPoint = [sender locationInView:_photoImageView];
//    
//    if (tapPoint.y > 0) {
//    
//      // photo long pressed
//      NSLog(@"LONG PRESS");
//      
//      // need a 2nd method to be able to pass photo model
//      [self longPressRecognized];
//    }
//  }
}

- (void)userNameTapped
{
  
}

- (void)longPressRecognized
{
//  [self.delegate cellWasLongPressedWithPhoto:_photoModel];
}

- (void)cellWasTapped:(UIGestureRecognizer *)sender
{
//  // determine which area of cell was tapped
//  CGPoint tapPoint = [sender locationInView:self.view];
//  
//  if (tapPoint.y > CELL_HEADER_HEIGHT) {
//    
//    // photo tapped
//    NSLog(@"TAP: photo");
//    
//  } else if (tapPoint.x <= CGRectGetMaxX(_userProfileImageView.frame)) {
//    
//    // user avatar tapped
//    NSLog(@"TAP: Buddy Icon");
//    
//    [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
//    
//  } else if (tapPoint.x < CGRectGetMinX(_photoTimeIntervalSincePostLabel.frame)) {
//    
//    // check if location exists
//    if (_photoLocationLabel.attributedString) {
//      
//      if (tapPoint.y > CGRectGetMinY(_photoLocationLabel.frame)) {
//        NSLog(@"TAP: Location Label");
////        [self.delegate photoLocationWasTouchedWithCoordinate:_photoModel.location.coordinates name:_photoLocationLabel.text];
//        
//      } else {
//        
//        NSLog(@"Tap: Username Label");
//        
//        [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
//      }
//      
//    } else {
//      
//      // username tapped
//      NSLog(@"Tap: Username Label");
//      
//      [self.delegate userProfileWasTouchedWithUser:_photoModel.ownerUserProfile];
//    }
//  }
}


#pragma mark - UIActionSheetDelegate 


@end
