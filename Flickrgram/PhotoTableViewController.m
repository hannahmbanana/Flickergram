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
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearPhotos)];
    self.navigationItem.rightBarButtonItem = clearItem;
    
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

- (void)clearPhotos
{
  _photos = [NSMutableArray array];
  [self.tableView reloadData];
}


- (void)downloadInterestingImages
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSURL *url = [NSURL URLWithString:@"https://api.500px.com/v1/photos?feature=popular&sort=created_at&image_size=3&include_store=store_download&include_states=voted&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC"];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSMutableArray *newPhotos = [NSMutableArray array];
    
    if (data) {
      
      NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
      
      if ([response isKindOfClass:[NSDictionary class]]) {
        
        NSArray *photos = [response valueForKeyPath:@"photos"];
        
        if ([photos isKindOfClass:[NSArray class]]) {
          
          for (NSDictionary *photoDictionary in photos) {
            
            if ([response isKindOfClass:[NSDictionary class]]) {

              PhotoModel *photo = [[PhotoModel alloc] initWith500pxPhoto:photoDictionary];
              
              // addObject: will crash with nil (NSArray, NSSet, NSDictionary, URLWithString - most foundation things)
              if (photo) {
                
                [newPhotos addObject:photo];
              }
            }
          }
        }
      }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      
      [_photos addObjectsFromArray:newPhotos];
      
      // reload table data once _photos data model is populated
      [self.tableView reloadData];
      
      // end spinner
      [self.refreshControl endRefreshing];
    });
  });
}


#pragma mark - UITableViewDelegate

//////***** JUST COPIED THIS FROM THE INTERNET - what to do??**** /////////
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//  if (scrollView == self.tableView) {
//    CGFloat currentOffsetX = scrollView.contentOffset.x;
//    CGFloat currentOffSetY = scrollView.contentOffset.y;
//    CGFloat contentHeight = scrollView.contentSize.height;
//    
//    if (currentOffSetY < (contentHeight / 6.0f)) {
//      scrollView.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY + (contentHeight/2)));
//    }
//    if (currentOffSetY > ((contentHeight * 4)/ 6.0f)) {
//      scrollView.contentOffset = CGPointMake(currentOffsetX,(currentOffSetY - (contentHeight/2)));
//    }
//  }
//}


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
