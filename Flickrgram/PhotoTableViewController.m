//
//  PhotoTableViewController.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/17/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "FlickrKit.h"
#import "PhotoTableViewCell.h"

@implementation PhotoTableViewController
{
  FKFlickrNetworkOperation  *_todaysInterestingOp;
  NSArray                   *_photoArray;
}


#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  
  if (self) {
    
    // register UITableViewCell subclass
    [self.tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoCell"];
    
    // start downloading images for feed
    [self downloadInterestingImages];
  }
  
  return self;
}


#pragma mark - Helper Methods

- (void)downloadInterestingImages
{
  FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
  interesting.per_page = @"100";
  interesting.extras = @"<code>description</code>, <code>date_upload</code>, <code>owner_name</code>, <code>geo</code>, <code>tags</code>, <code>machine_tags</code>, <code>url_q</code>";
  
  _todaysInterestingOp = [[FlickrKit sharedFlickrKit] call:interesting completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (response) {
        
        NSMutableArray *photoURLs = [NSMutableArray array];
        
        for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
          [photoURLs addObject:photoDictionary];
        }
        _photoArray = photoURLs;
        
        [self.tableView reloadData];
      }
    });				
  }];
}


#pragma mark - TableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  // call class method on cell heightForRowWithDataModel
  return self.view.bounds.size.width;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_photoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
  
  if (!cell) {
    cell = [[PhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
  }
  
  NSString *photoURL = [_photoArray objectAtIndex:indexPath.row];
  cell.backgroundColor = [UIColor purpleColor];
  [cell updateCellWithPhotoURL:photoURL];
  
  return cell;
}

@end
