//
//  PhotoModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoModel.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"


@implementation PhotoModel
{
  NSDictionary *_dictionaryRepresentation;
  NSString     *_uploadDateRaw;
  CommentFeedModel *_commentFeed;
}

#pragma mark - Properties

- (CommentFeedModel *)commentFeed
{
  if (!_commentFeed) {
    _commentFeed = [[CommentFeedModel alloc] initWithPhotoID:_photoID];
  }
  
  return _commentFeed;
}


#pragma mark - Lifecycle

- (instancetype)initWith500pxPhoto:(NSDictionary *)photoDictionary
{
  self = [super init];
  
  if (self) {
    
    _dictionaryRepresentation   = photoDictionary;
    
    NSString *urlString         = [photoDictionary objectForKey:@"image_url"];
    _URL                        = urlString ? [NSURL URLWithString:urlString] : nil;
    
    _ownerUserProfile           = [[UserModel alloc] initWith500pxPhoto:photoDictionary];
    
    _uploadDateRaw              = [photoDictionary objectForKey:@"created_at"];
    
    _photoID                    = [[photoDictionary objectForKey:@"id"] description];
    
    _title                      = [photoDictionary objectForKey:@"title"];
    _descriptionText            = [photoDictionary valueForKeyPath:@"name"];
    
    _commentsCount              = [[photoDictionary objectForKey:@"comments_count"] integerValue];
    _likesCount                 = [[photoDictionary objectForKey:@"positive_votes_count"] integerValue];
    
    // photo location
    _location                   = [[LocationModel alloc] initWith500pxPhoto:photoDictionary];

    // calculate dateString off the main thread
    _uploadDateString = [NSString elapsedTimeStringSinceDate:_uploadDateRaw];
  }
  
  return self;

}

  
#pragma mark - Helper Methods

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - %@", _photoID, _descriptionText];
}

@end