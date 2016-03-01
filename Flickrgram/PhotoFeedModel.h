//
//  PhotoFeedModel.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/28/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoModel.h"

typedef NS_ENUM(NSInteger, PhotoFeedModelType) {
  PhotoFeedModelTypePopular,
  PhotoFeedModelTypePopular2
};

@interface PhotoFeedModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPhotoFeedModelType:(PhotoFeedModelType)type NS_DESIGNATED_INITIALIZER;

- (NSUInteger)numberOfItemsInFeed;
- (PhotoModel *)objectAtIndex:(NSUInteger)index;
- (void)fetchPageWithCompletionBlock:(void (^)())block;

@end
