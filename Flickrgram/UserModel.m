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

- (instancetype)initWith500pxPhoto:(NSDictionary *)dictionary
{
  self = [super init];
  
  if (self) {
    
    NSDictionary *userDictionary = [dictionary objectForKey:@"user"];
    
    if ([userDictionary isKindOfClass:[NSDictionary class]]) {
      
      _userID         = [userDictionary objectForKey:@"id"];
      _username       = [userDictionary objectForKey:@"username"];
      _userFirstName  = [userDictionary objectForKey:@"firstname"];
      _userLastName   = [userDictionary objectForKey:@"lastname"];
      _userCity       = [userDictionary objectForKey:@"city"];
      _userCountry    = [userDictionary objectForKey:@"country"];
      
      NSString *urlString = [userDictionary objectForKey:@"userpic_url"];  //FIXME: create data model for mult sizes
      _userPicURL         = urlString ? [NSURL URLWithString:urlString] : nil;
    }
  }
  
  return self;
}

@end
