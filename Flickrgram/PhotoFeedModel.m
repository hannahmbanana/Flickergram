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
  NSMutableArray *_ids;
  NSString       *_urlString;
  NSUInteger     _currentPage;
  NSUInteger     _totalPages;
  NSUInteger     _totalItems;
  
  BOOL           _fetchPageInProgress;
  BOOL           _refreshFeedInProgress;

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
    _ids         = [[NSMutableArray alloc] init];
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

- (void)clearFeed
{
  _photos = [[NSMutableArray alloc] init];
}

- (void)requestPageWithCompletionBlock:(void (^)(NSArray *))block
{
  // only one fetch at a time
  if (_fetchPageInProgress) {
    
    NSLog(@"Request: FAIL - fetch page already in progress");
    return;
    
  } else {
    
    _fetchPageInProgress = YES;
    
    NSLog(@"Request: SUCCESS");
    [self fetchPageWithCompletionBlock:block];
  }
}

- (void)refreshFeedWithCompletionBlock:(void (^)(NSArray *))block
{
  // only one fetch at a time
  if (_refreshFeedInProgress) {
    
    NSLog(@"Request Refresh: FAIL - refresh feed already in progress");
    return;
    
  } else {
    
    _refreshFeedInProgress = YES;
    _currentPage = 0;
    
    // FIXME: blow away any other requests in progress
    
    NSLog(@"Request Refresh: SUCCESS");
    
    
    [self fetchPageWithCompletionBlock:^(NSArray *newPhotos) {
      if (block) {
        block(newPhotos);
      }
      
      _refreshFeedInProgress = NO;
    } replaceData:YES];
  }
}

#pragma mark - Helper Methods
- (void)fetchPageWithCompletionBlock:(void (^)(NSArray *))block
{
  [self fetchPageWithCompletionBlock:block replaceData:NO];
}

- (void)fetchPageWithCompletionBlock:(void (^)(NSArray *))block replaceData:(BOOL)replaceData
{
  // early return if reached end of pages
  if (_totalPages) {
    if (_currentPage == _totalPages) {
      return;
    }
  }
    
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSMutableArray *newPhotos = [NSMutableArray array];
    NSMutableArray *newIDs = [NSMutableArray array];
    
    @synchronized(self) {
    
      NSUInteger nextPage = _currentPage + 1;
      
      NSString *urlAdditions = [NSString stringWithFormat:@"&page=%lu&rpp=4", (unsigned long)nextPage];
      
      NSURL *url = [NSURL URLWithString:[_urlString stringByAppendingString:urlAdditions]];
      
      NSData *data = [NSData dataWithContentsOfURL:url];
      
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
                  
                  if (replaceData || ![_ids containsObject:photo.photoID]) {
                    [newPhotos addObject:photo];
                    [newIDs addObject:photo.photoID];
                  }
                }
              }
            }
          }
        }
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if (replaceData) {
        _photos = [newPhotos mutableCopy];
        _ids = [newIDs mutableCopy];
      } else {
        [_photos addObjectsFromArray:newPhotos];
        [_ids addObjectsFromArray:newIDs];
      }
      
      if (block) {
        block(newPhotos);
      }
    });
    
    _fetchPageInProgress = NO;

  });
}

@end
