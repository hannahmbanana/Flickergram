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
  PhotoFeedModel *_photoFeed;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
    // PHOTO FEED OBJECT
    CGRect screenRect   = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize imageSize    = CGSizeMake(screenRect.size.width * screenScale, screenRect.size.width * screenScale);
    
    _photoFeed = [[PhotoFeedModel alloc] initWithPhotoFeedModelType:PhotoFeedModelTypePopular imageSize:imageSize];
    
    // start first small fetch
    [_photoFeed refreshFeedWithCompletionBlock:^(NSArray *newPhotos){
      
      // update the tableView
      [self.tableView reloadData];
      
      [self requestCommentsForPhotos:newPhotos];
      
      // immediately start second larger fetch
//      [self loadPage];
    }];
    
    
    // TABLEVIEW CONFIG
    // disable tableView cell selection
    self.tableView.allowsSelection = NO;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // register custom UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // enable tableView pull-to-refresh & add target-action pair
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *loadData = [[UIBarButtonItem alloc] initWithTitle:@"load data" style:UIBarButtonItemStylePlain target:self action:@selector(loadPage)];
    self.navigationItem.rightBarButtonItem = loadData;
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearFeed)];
    self.navigationItem.leftBarButtonItem = clear;
    
    // navBar title
    self.navigationItem.title = @"500pixgram";
  }
  
  return self;
}


#pragma mark - Gesture Handling

- (void)clearFeed
{
  [_photoFeed clearFeed];
  [self.tableView reloadData];
}

- (void)refreshFeed
{
  [_photoFeed refreshFeedWithCompletionBlock:^(NSArray *newPhotos){
    
    [self.tableView reloadData];
    
    NSLog(@"_photoFeed number of items = %lu", (unsigned long)[_photoFeed numberOfItemsInFeed]);
    
    [self.refreshControl endRefreshing];
    
    [self requestCommentsForPhotos:newPhotos];

  }];
}

- (void)loadPage
{
  NSLog(@"_photoFeed number of items = %lu", (unsigned long)[_photoFeed numberOfItemsInFeed]);
  
  [self logPhotoIDsInPhotoFeed];

  [_photoFeed requestPageWithCompletionBlock:^(NSArray *newPhotos){
    
    [self insertNewRowsInTableView:newPhotos];
    
    [self logPhotoIDsInPhotoFeed];
    
    [self requestCommentsForPhotos:newPhotos];
  }];
}

- (void)requestCommentsForPhotos:(NSArray *)newPhotos
{
  // comment feed
  for (PhotoModel *photo in newPhotos) {
    
    [photo.commentFeed refreshFeedWithCompletionBlock:^(NSArray *newComments) {
      
      // update PhotoModel with commentFeed
      NSInteger rowNum = [_photoFeed indexOfPhotoModel:photo];
      
      [self.tableView reloadData];
      
      PhotoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowNum inSection:0]];
      if (cell) {
        [cell loadCommentsForPhoto:photo];
      }
      
      // force heightForCellAtIndexPath...
      [self.tableView beginUpdates];
      [self.tableView endUpdates];
      
      // FIXME: adjust content offset - iterate over cells above to get heights...
    }];
  }
}

- (void)logPhotoIDsInPhotoFeed
{
  NSLog(@"_photoFeed number of items = %lu", (unsigned long)[_photoFeed numberOfItemsInFeed]);
  
  for (int i = 0; i < [_photoFeed numberOfItemsInFeed]; i++) {
    if (i % 4 == 0 && i > 0) {
      NSLog(@"\t-----");
    }
    
//    [_photoFeed return]
//    NSString *duplicate =  ? @"(DUPLICATE)" : @"";
    NSLog(@"\t%@  %@", [[_photoFeed objectAtIndex:i] photoID], @"");
  }
}

- (void)insertNewRowsInTableView:(NSArray *)newPhotos
{
 // instead of doing tableView reloadData, use table editing commands
  NSMutableArray *indexPaths = [NSMutableArray array];
  
  NSInteger section = 0;
  NSUInteger newTotalNumberOfPhotos = [_photoFeed numberOfItemsInFeed];
  for (NSUInteger row = newTotalNumberOfPhotos - newPhotos.count; row < newTotalNumberOfPhotos; row++) {
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    [indexPaths addObject:path];
  }
  
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//  if (scrollView == self.tableView) {
//    CGFloat currentOffSetY = scrollView.contentOffset.y;
//    CGFloat contentHeight = scrollView.contentSize.height;
//    
//    if (currentOffSetY > (contentHeight * 3.0 / 4.0)) {
//      [self loadPage];
//    }
//  }
//}


#pragma mark - UITableViewDataSource

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  PhotoModel *photoModel = [_photoFeed objectAtIndex:indexPath.row];
  return [PhotoTableViewCell heightForPhotoModel:photoModel withWidth:self.view.bounds.size.width];
}


#pragma mark - PhotoTableViewCellProtocol

- (void)userProfileWasTouchedWithUser:(UserModel *)user;
{
  UserProfileViewController *userProfileView = [[UserProfileViewController alloc] initWithUser:user];
  
  [self.navigationController pushViewController:userProfileView animated:YES];
}

- (void)photoLocationWasTouchedWithCoordinate:(CLLocationCoordinate2D)coordiantes name:(NSAttributedString *)name
{
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumInteritemSpacing = 1;
  layout.minimumLineSpacing = 1;
  
  CGFloat boundsWidth = self.view.bounds.size.width;
  layout.headerReferenceSize = CGSizeMake(boundsWidth, 200);
  
  CGFloat photoColumnCount = 3;
  CGFloat photoSize = (boundsWidth - (photoColumnCount - 1)) / photoColumnCount;
  layout.itemSize = CGSizeMake(photoSize, photoSize);
  
  LocationCollectionViewController *locationCVC = [[LocationCollectionViewController alloc] initWithCollectionViewLayout:layout coordinates:coordiantes];
  locationCVC.navigationItem.title = name.string;
  
  [self.navigationController pushViewController:locationCVC animated:YES];
}

- (void)cellWasLongPressedWithPhoto:(PhotoModel *)photo
{
  UIAlertAction *savePhotoAction = [UIAlertAction actionWithTitle:@"Save Photo"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                            NSLog(@"hi");
                                                          }];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                       }];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
  
  [alert addAction:savePhotoAction];
  [alert addAction:cancelAction];
  
  [self presentViewController:alert animated:YES completion:^{}];
}


@end
