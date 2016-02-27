//
//  LocationModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "LocationModel.h"
#import <UIKit/UIKit.h>
#import "FlickrKit.h"

@implementation LocationModel


#pragma mark - Lifecycle

- (instancetype)initWithFlickPhoto:(NSDictionary *)flickrPhotoDictionary
{
  self = [super init];
  
  if (self) {
    
    CLLocationDegrees latitude  = [[flickrPhotoDictionary objectForKey:@"latitude"] floatValue];
    CLLocationDegrees longitude = [[flickrPhotoDictionary objectForKey:@"longitude"] floatValue];
    _coordinates                = CLLocationCoordinate2DMake(latitude, longitude);
    
    // calculate user friendly location string off the main thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self downloadPhotoLocationWithFlickrPhotoDictionary:flickrPhotoDictionary];
    });
  }
  
  return self;
}


#pragma mark - Helper Methods

- (nullable NSString *)locationStringFromPhotoLocationDictionary:(NSDictionary *)photoLocationDictionary
{
  // early return if no location info
  if (!photoLocationDictionary)
  {
    return nil;
  }
  
  NSString *country       = [photoLocationDictionary valueForKeyPath:@"country._content"];
  NSString *county        = [photoLocationDictionary valueForKeyPath:@"county._content"];
  NSString *locality      = [photoLocationDictionary valueForKeyPath:@"locality._content"];
  NSString *neighbourhood = [photoLocationDictionary valueForKeyPath:@"neighbourhood._content"];
  NSString *region        = [photoLocationDictionary valueForKeyPath:@"region._content"];
  
  NSString *locationString;
  
  if (neighbourhood) {
    locationString = [NSString stringWithFormat:@"%@", neighbourhood];
  } else if (locality && county) {
    locationString = [NSString stringWithFormat:@"%@, %@", locality, county];
  } else if (region) {
    locationString = [NSString stringWithFormat:@"%@, %@", region, country];
  } else if (country) {
    locationString = [NSString stringWithFormat:@"%@", country];
  } else {
    locationString = @"ERROR";
  }
  
  //  NSLog(@"%@", photoLocationDictionary);
  //  NSLog(@"%@, %@, %@, %@, %@", neighbourhood, locality, county, region, country);
  //  NSLog(@"%@", locationString);
  
  return locationString;
}

- (void)downloadPhotoLocationWithFlickrPhotoDictionary:(NSDictionary *)flickrPhotoDictionary
{
  // async download of photo info
  FlickrKit *fk                    = [FlickrKit sharedFlickrKit];
  FKFlickrPhotosGetInfo *photoInfo = [[FKFlickrPhotosGetInfo alloc] init];
  photoInfo.photo_id               = [flickrPhotoDictionary valueForKeyPath:@"id"];
  photoInfo.secret                 = [flickrPhotoDictionary valueForKeyPath:@"secret"];
    
  FKFlickrNetworkOperation *networkOp = [fk call:photoInfo completion:^(NSDictionary *response, NSError *error) {
    
    if (response) {
      if (!error) {
        
        // photo location
        NSDictionary *photoLocationDictionary = [response valueForKeyPath:@"photo.location"];
        _userFriendlyLocationString = [self locationStringFromPhotoLocationDictionary:photoLocationDictionary];
      }
    }
  }];
}

@end
