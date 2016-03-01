//
//  PhotoFeedModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/28/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoFeedModel.h"

@implementation PhotoFeedModel
{
  NSMutableArray *_photos;    // array of PhotoModel objects
}


#pragma mark - Properties

- (NSMutableArray *)photos
{
  return _photos;
}


#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  
  if (self) {
  
    _photos = [[NSMutableArray alloc] init];
  
  }
  
  return self;
}


#pragma mark - Instance Methods

- (NSUInteger)numberOfItemsInFeed
{
  return [_photos count];
}

- (PhotoModel *)objectAtIndex:(NSUInteger)index
{
  return [_photos objectAtIndex:index];
}


#pragma mark - Helper Methods

- (void)fetchPageWithCompletionBlock:(void (^)())block;
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSURL *url = [NSURL URLWithString:@"https://api.500px.com/v1/photos?feature=popular&sort=created_at&image_size=3&include_store=store_download&include_states=voted&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC"];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSMutableArray *newPhotos = [NSMutableArray array];
    
    if (data) {
      
      NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
      
      if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSArray *photos = [response valueForKeyPath:@"photos"];
        
        if ([photos isKindOfClass:[NSArray class]]) {
          
          for (NSDictionary *photoDictionary in photos) {
            
            if ([response isKindOfClass:[NSDictionary class]]) {
              
              PhotoModel *photo = [[PhotoModel alloc] initWith500pxPhoto:photoDictionary];
              
              // addObject: will crash with nil (NSArray, NSSet, NSDictionary, URLWithString - most foundation things)
              if (photo) {
                
                [newPhotos addObject:photo];
              }
            }
          }
        }
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      [_photos addObjectsFromArray:newPhotos];
      
      if (block) {
        block();
      }
    });
  });
}

@end
