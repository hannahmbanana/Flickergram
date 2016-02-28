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
#import <CoreLocation/CLGeocoder.h>

@implementation LocationModel


#pragma mark - Lifecycle

- (nullable instancetype)initWith500pxPhoto:(NSDictionary *)dictionary
{
  NSNumber *latitude  = [dictionary objectForKey:@"latitude"];
  NSNumber *longitude = [dictionary objectForKey:@"longitude"];
  
  // early return if location is "<null>"
  if (![latitude isKindOfClass:[NSNumber class]] || ![longitude isKindOfClass:[NSNumber class]]) {
    return nil;
  }
  
  self = [super init];
  
  if (self) {
    
    CLLocationDegrees latitudeDegrees = [latitude floatValue];
    CLLocationDegrees longitudeDegrees = [longitude floatValue];
    _coordinates = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
    
    // calculate user friendly location string off the main thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
//      [self downloadPhotoLocationWithFlickrPhotoDictionary:flickrPhotoDictionary];
      [self downloadPhotoLocationWithMKReverseGeocoder];
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

- (void)downloadPhotoLocationWithMKReverseGeocoder
{
  CLLocationCoordinate2D locationCoordinate = self.coordinates;
  CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude
                                                    longitude:locationCoordinate.longitude];
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
    _placemark = [placemarks lastObject];
    _userFriendlyLocationString = [self locationStringFromCLLocation];
  }];
}

- (nullable NSString *)locationStringFromCLLocation
{
  // early return if no location info
  if (!_placemark)
  {
    return nil;
  }
  
//  @property (nonatomic, readonly, copy, nullable) NSString *name; // eg. Apple Inc.
//  @property (nonatomic, readonly, copy, nullable) NSString *thoroughfare; // street name, eg. Infinite Loop
//  @property (nonatomic, readonly, copy, nullable) NSString *subThoroughfare; // eg. 1
//  @property (nonatomic, readonly, copy, nullable) NSString *locality; // city, eg. Cupertino
//  @property (nonatomic, readonly, copy, nullable) NSString *subLocality; // neighborhood, common name, eg. Mission District
//  @property (nonatomic, readonly, copy, nullable) NSString *administrativeArea; // state, eg. CA
//  @property (nonatomic, readonly, copy, nullable) NSString *subAdministrativeArea; // county, eg. Santa Clara
//  @property (nonatomic, readonly, copy, nullable) NSString *postalCode; // zip code, eg. 95014
//  @property (nonatomic, readonly, copy, nullable) NSString *ISOcountryCode; // eg. US
//  @property (nonatomic, readonly, copy, nullable) NSString *country; // eg. United States
//  @property (nonatomic, readonly, copy, nullable) NSString *inlandWater; // eg. Lake Tahoe
//  @property (nonatomic, readonly, copy, nullable) NSString *ocean; // eg. Pacific Ocean
//  @property (nonatomic, readonly, copy, nullable) NSArray<NSString *> *areasOfInterest; // eg. Golden Gate Park
  
  NSString *locationString;
  
  if (_placemark.inlandWater) {
    locationString = [NSString stringWithFormat:@"%@", _placemark.inlandWater];
  } else if (_placemark.name) {
    locationString = [NSString stringWithFormat:@"%@", _placemark.name];
  } else if (_placemark.subLocality && _placemark.locality) {
    locationString = [NSString stringWithFormat:@"%@, %@", _placemark.subLocality, _placemark.locality];
  } else if (_placemark.administrativeArea && _placemark.subAdministrativeArea) {
    locationString = [NSString stringWithFormat:@"%@, %@", _placemark.subAdministrativeArea, _placemark.administrativeArea];
  } else if (_placemark.country) {
    locationString = [NSString stringWithFormat:@"%@", _placemark.country];
  } else {
    locationString = @"ERROR";
  }
  
  //  NSLog(@"%@", photoLocationDictionary);
  //  NSLog(@"%@, %@, %@, %@, %@", neighbourhood, locality, county, region, country);
  //  NSLog(@"%@", locationString);
  
  return locationString;
}

@end
