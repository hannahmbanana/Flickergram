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
  NSMutableArray *_photoArray;
}

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  
  if (self) {
  
    _photoArray = [[NSMutableArray alloc] init];
  
  }
  
  return self;
}


#pragma mark - Instance Methods



#pragma mark - Helper Methods


@end
