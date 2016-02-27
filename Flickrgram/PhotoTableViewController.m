//
//  PhotoTableViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "FlickrKit.h"
#import "PhotoModel.h"
#import "PhotoTableViewCell.h"
#import "LocationViewController.h"

@interface PhotoTableViewController () <PhotoTableViewCellProtocol>
@end

@implementation PhotoTableViewController
{
  FKFlickrNetworkOperation  *_todaysInterestingOp;
  NSMutableArray            *_photos;                 // of PhotoModel Objects
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
    _photos = [NSMutableArray array];
    
    // disable tableView cell selection
    self.tableView.allowsSelection = NO;
    
    // enable tableView pull-to-refresh & add target-action pair
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(downloadInterestingImages) forControlEvents:UIControlEventValueChanged];
    
    // register custom UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // start downloading interesting images for feed
    [self downloadInterestingImages];
    
    // navBar title
    self.navigationItem.title = @"flickrgram";
      }
  
  return self;
}




#pragma mark - Helper Methods

- (void)downloadInterestingImages
{
  FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
  interesting.per_page = @"5";
  interesting.extras = @"description, date_upload, owner_name, geo, tags, machine_tags, url_q";
  
  _todaysInterestingOp = [[FlickrKit sharedFlickrKit] call:interesting completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if (response) {
        
        NSMutableArray *photoDictionaries = [NSMutableArray array];
        
        for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
          
          PhotoModel *photo = [[PhotoModel alloc] initWithFlickPhoto:photoDictionary];
          [photoDictionaries addObject:photo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          [_photos addObjectsFromArray:photoDictionaries];
          
          // reload table data once _photos data model is populated
          [self.tableView reloadData];
          
          // end spinner
          [self.refreshControl endRefreshing];
        });
      }
    });
  }];
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  #warning H: call class method on cell heightForRowWithDataModel
  return self.view.bounds.size.width;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // dequeue a reusable cell
  PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
  
  // create a new PhotoTableViewCell if no reusable ones are available in queue
  if (!cell) {
    cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
    cell.delegate = self;
  }
  
  // configure the cell for the appropriate photo
  cell.delegate = self;
  [cell updateCellWithPhotoObject:[_photos objectAtIndex:indexPath.row]];
  
  return cell;
}


#pragma mark - PhotoTableViewCellProtocol

- (void)userProfileWasTouchedWithUserID:(NSString *)userID;
{
//  UserProfileCollectionViewController *userProfileView = [[UserProfileCollectionViewController alloc] initWithUserID:userID];
//  userProfileView.view.backgroundColor = [UIColor redColor];
//  
//  [self.navigationController pushViewController:userProfileView animated:YES];
}

- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes
{
  LocationViewController *locationVC = [[LocationViewController alloc] init];
  locationVC.coordinate = coordiantes;
  
  [self.navigationController pushViewController:locationVC animated:YES];
}

@end
