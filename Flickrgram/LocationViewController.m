//
//  LocationViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "LocationViewController.h"
#import <MapKit/MKMapView.h>
#import <MapKit/MKPointAnnotation.h>
#import <CoreLocation/CLLocation.h>

@implementation LocationViewController
{
  MKMapView *_mapView;
}

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    
    // configure MKMapView
    _mapView = [[MKMapView alloc] init];
    _mapView.showsUserLocation = YES;
    
    [self.view addSubview:_mapView];
    
  }
  
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  _mapView.frame = CGRectMake(0,0,self.view.bounds.size.width, 300);

  // add photo pin
  MKPointAnnotation *photoLocationAnnotation = [[MKPointAnnotation alloc] init];
  photoLocationAnnotation.coordinate = self.coordinate;
  [_mapView addAnnotation:photoLocationAnnotation];
  
  // center map on photo pin
  [_mapView setCenterCoordinate:self.coordinate];
  
  MKCoordinateSpan span = MKCoordinateSpanMake(5, 5);
  MKCoordinateRegion region = MKCoordinateRegionMake(self.coordinate, span);
  [_mapView setRegion:region animated:YES];
}

@end
