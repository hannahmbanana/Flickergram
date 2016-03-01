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
  NSString       *_urlString;
  NSUInteger     _currentPage;
  NSUInteger     _totalPages;
  NSUInteger     _totalItems;
}


#pragma mark - Properties

- (NSMutableArray *)photos
{
  return _photos;
}


#pragma mark - Lifecycle

- (instancetype)initWithPhotoFeedModelType:(PhotoFeedModelType)type
{
  self = [super init];
  
  if (self) {
  
    _photos      = [[NSMutableArray alloc] init];
    _currentPage = 0;
    
    switch (type) {
      case (PhotoFeedModelTypePopular):
        _urlString = @"https://api.500px.com/v1/photos?feature=popular&sort=created_at&image_size=3&include_store=store_download&include_states=voted&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC";
        break;
        
//      case (PhotoFeedModelTypePopular2):
//        urlString =
//        break;
        
      default:
        _urlString = @"https://api.500px.com/v1/photos?feature=popular&sort=created_at&image_size=3&include_store=store_download&include_states=voted&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC";
        break;
    }
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
  // early return if reached end of pages
  if (_totalPages) {
    if (_currentPage == _totalPages) {
      return;
    }
  }
  
  NSLog(@"Total Pages = %lu", _totalPages);
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSUInteger nextPage = _currentPage + 1;
    
    NSString *urlAdditions = [NSString stringWithFormat:@"&page=%lu", nextPage];
    
    NSURL *url = [NSURL URLWithString:[_urlString stringByAppendingString:urlAdditions]];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSMutableArray *newPhotos = [NSMutableArray array];
    
    if (data) {
      
      NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
      
      if ([response isKindOfClass:[NSDictionary class]]) {
        
        _currentPage = [[response valueForKeyPath:@"current_page"] integerValue];
        _totalPages  = [[response valueForKeyPath:@"total_pages"] integerValue];
        _totalItems  = [[response valueForKeyPath:@"total_items"] integerValue];
        
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
