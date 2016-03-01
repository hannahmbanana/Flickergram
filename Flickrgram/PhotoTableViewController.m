//
//  PhotoTableViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoModel.h"
#import "PhotoTableViewCell.h"
#import "UserProfileViewController.h"
#import "LocationCollectionViewController.h"
#import "PhotoFeedModel.h"

@interface PhotoTableViewController () <PhotoTableViewCellProtocol>
@end

@implementation PhotoTableViewController
{
//  NSMutableArray            *_photos;                 // of PhotoModel Objects
  PhotoFeedModel *_photoFeed;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
//    _photos = [NSMutableArray array];
    _photoFeed = [[PhotoFeedModel alloc] init];
    [_photoFeed fetchPageWithCompletionBlock:^{
      [self.tableView reloadData];
    }];
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearPhotos)];
    self.navigationItem.rightBarButtonItem = clearItem;
    
    // disable tableView cell selection
    self.tableView.allowsSelection = NO;
    
    // enable tableView pull-to-refresh & add target-action pair
    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(downloadInterestingImages) forControlEvents:UIControlEventValueChanged];
    
    // register custom UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // start downloading interesting images for feed
//    [self downloadInterestingImages];
    
    // navBar title
    self.navigationItem.title = @"500pixergram";
      }
  
  return self;
}




#pragma mark - Helper Methods

- (void)clearPhotos
{
//  _photos = [NSMutableArray array];
//  [self.tableView reloadData];
}


//- (void)downloadInterestingImages
//{
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    
//    NSURL *url = [NSURL URLWithString:@"https://api.500px.com/v1/photos?feature=popular&sort=created_at&image_size=3&include_store=store_download&include_states=voted&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC"];
//    
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    
//    NSMutableArray *newPhotos = [NSMutableArray array];
//    
//    if (data) {
//      
//      NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//      
//      if ([response isKindOfClass:[NSDictionary class]]) {
//        
//        NSArray *photos = [response valueForKeyPath:@"photos"];
//        
//        if ([photos isKindOfClass:[NSArray class]]) {
//          
//          for (NSDictionary *photoDictionary in photos) {
//            
//            if ([response isKindOfClass:[NSDictionary class]]) {
//
//              PhotoModel *photo = [[PhotoModel alloc] initWith500pxPhoto:photoDictionary];
//              
//              // addObject: will crash with nil (NSArray, NSSet, NSDictionary, URLWithString - most foundation things)
//              if (photo) {
//                
//                [newPhotos addObject:photo];
//              }
//            }
//          }
//        }
//      }
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      
//      [_photoFeed.photos addObjectsFromArray:newPhotos];
//      
//      // reload table data once _photos data model is populated
//      [self.tableView reloadData];
//      
//      // end spinner
//      [self.refreshControl endRefreshing];
//    });
//  });
//}


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
  PhotoModel *photoModel = [_photoFeed objectAtIndex:indexPath.row];
  CGFloat headerFooterCombinedHeight = [PhotoTableViewCell cellHeaderFooterHeightForDataModel:photoModel];
  return headerFooterCombinedHeight + self.view.bounds.size.width; // + square photo height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photoFeed numberOfItemsInFeed];
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
  [cell updateCellWithPhotoObject:[_photoFeed objectAtIndex:indexPath.row]];
  
  return cell;
}


#pragma mark - PhotoTableViewCellProtocol

- (void)userProfileWasTouchedWithUser:(UserModel *)user;
{
  UserProfileViewController *userProfileView = [[UserProfileViewController alloc] initWithUser:user];
  
  [self.navigationController pushViewController:userProfileView animated:YES];
}

- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes name:(NSString *)name
{
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumInteritemSpacing = 1;
  layout.minimumLineSpacing = 1;
  layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 200);
  
  CGFloat numItemsLine = 5;
  layout.itemSize = CGSizeMake((self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine,
                               (self.view.bounds.size.width - (numItemsLine - 1)) / numItemsLine);
  
  LocationCollectionViewController *locationCVC = [[LocationCollectionViewController alloc] initWithCollectionViewLayout:layout coordinates:coordiantes];
  locationCVC.navigationItem.title = name;
  
  [self.navigationController pushViewController:locationCVC animated:YES];
}

@end
