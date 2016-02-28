//
//  UserModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "UserModel.h"
#import <UIKit/UIKit.h>
#import "FlickrKit.h"

@implementation UserModel

#pragma mark - Lifecycle

- (instancetype)initWithFlickPhoto:(NSDictionary *)flickrPhotoDictionary
{
  self = [super init];
  
  if (self) {
    
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    
    _photoURL = [fk buddyIconURLForUser:[flickrPhotoDictionary valueForKeyPath:@"owner"]];
    _userName     = [flickrPhotoDictionary objectForKey:@"ownername"];
    _user         = [flickrPhotoDictionary objectForKey:@"owner"];
  }
  
  return self;
}

@end
