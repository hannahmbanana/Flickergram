//
//  PhotoFeedModel.h
//  Flickrgram
//
//  Created by Hannah Troisi on 2/28/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoModel.h"

@interface PhotoFeedModel : NSObject

- (NSUInteger)numberOfItemsInFeed;
- (PhotoModel *)objectAtIndex:(NSUInteger)index;
- (void)fetchPageWithCompletionBlock:(void (^)())block;

@end
