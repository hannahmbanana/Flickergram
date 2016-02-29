//
//  LocationCollectionViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/24/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "LocationCollectionViewController.h"
#import <MapKit/MKMapView.h>
#import <MapKit/MKPointAnnotation.h>


#define MAP_HEIGHT_VERTICAL_SCREEN_RATIO 0.3

@implementation LocationCollectionViewController
{
  CLLocationCoordinate2D  _coordinates;
  MKMapView              *_mapView;
}


#pragma mark - Lifecycle

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
                                 coordinates:(CLLocationCoordinate2D)coordiantes

{
  self = [super initWithCollectionViewLayout:layout];

  if (self) {
    
    // set collection view dataSource and delegate
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // register cell class
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"photoCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    
    // configure MKMapView & add as subview
    _mapView = [[MKMapView alloc] init];
    _mapView.showsUserLocation = YES;
  

    // set coordinates
    _coordinates = coordiantes;
  
  }

  return self;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  // add annotation for coordinates
  MKPointAnnotation *photoLocationAnnotation = [[MKPointAnnotation alloc] init];
  photoLocationAnnotation.coordinate = _coordinates;
  [_mapView addAnnotation:photoLocationAnnotation];
  
  // center map on photo pin
  [_mapView setCenterCoordinate:_coordinates];
  
  // set map span and region
  MKCoordinateSpan span = MKCoordinateSpanMake(5, 5);
  MKCoordinateRegion region = MKCoordinateRegionMake(_coordinates, span);
  [_mapView setRegion:region animated:YES];
  
//  // layout MKMapView
//  _mapView.frame = CGRectMake(0,
//                              0,
//                              self.view.bounds.size.width,
//                              self.view.bounds.size.height * MAP_HEIGHT_VERTICAL_SCREEN_RATIO);
//  

  
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 40;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  // check for cell in reuse queue
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
  
  // if no reusable cell, create a new one
  if (!cell) {
    cell = [[UICollectionViewCell alloc] init];
  }
  
  // configure celld
  cell.backgroundColor = [UIColor purpleColor];
  
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionReusableView *reusableview = nil;
  
  if (kind == UICollectionElementKindSectionHeader) {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
    
    if (!headerView) {
      headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
    }
    
    _mapView.frame = headerView.frame;
    [headerView addSubview:_mapView];

    reusableview = headerView;
  }
  
  return reusableview;
}


@end
