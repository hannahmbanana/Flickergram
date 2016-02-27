//
//  NSUserDefaults+NSUserDefaults_CacheFeed.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/27/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "NSUserDefaults+NSUserDefaults_CacheFeed.h"

@implementation NSUserDefaults (NSUserDefaults_CacheFeed)

- (void)saveHomeFeedPhotos
{
  // get NSUserDefaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:<#(nullable id)#> forKey:@"homeFeedPhotos"];
  
}

@end
