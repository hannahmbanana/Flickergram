//
//  PhotoModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoModel.h"
#import <UIKit/UIKit.h>
#import "FlickrKit.h"

@implementation PhotoModel
{
  NSDictionary *_dictionaryRepresentation;
  CGFloat      _uploadDate;
}


#pragma mark - Lifecycle

- (instancetype)initWith500pxPhoto:(NSDictionary *)photoDictionary
{
  self = [super init];
  
  if (self) {
    
    _dictionaryRepresentation   = photoDictionary;
    
    NSString *urlString         = [photoDictionary objectForKey:@"image_url"];
    _URL                        = urlString ? [NSURL URLWithString:urlString] : nil;
    
    _ownerUserProfile           = [[UserModel alloc] initWith500pxPhoto:photoDictionary];
    
//    _uploadDate                 = [photoDictionary objectForKey:@"created_at"];
    
//    _title                      = [photoDictionary objectForKey:@"title"];
//    _descriptionText            = [photoDictionary valueForKeyPath:@"description._content"];
    
    // photo location
    _location                   = [[LocationModel alloc] initWith500pxPhoto:photoDictionary];
    
    // calculate dateString off the main thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      _uploadDateString = [self elapsedTimeStringSinceDate:_uploadDate];
    });
  }
  
  return self;

}

  
#pragma mark - Helper Methods

- (NSString *)elapsedTimeStringSinceDate:(CGFloat)timeIntervalSince1970
{
  // early return if no post date string
  if (!timeIntervalSince1970)
  {
    return @"NO POST DATE";
  }
  
  NSDate *postDate            = [NSDate dateWithTimeIntervalSince1970:timeIntervalSince1970];
  NSDate *currentDate         = [NSDate date];
  
  NSCalendar *calendar        = [NSCalendar currentCalendar];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&postDate    interval:NULL forDate:postDate];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&currentDate interval:NULL forDate:currentDate];
  
  NSUInteger seconds = [[calendar components:NSCalendarUnitSecond fromDate:postDate toDate:currentDate options:0] second];
  NSUInteger minutes = [[calendar components:NSCalendarUnitMinute fromDate:postDate toDate:currentDate options:0] minute];
  NSUInteger hours   = [[calendar components:NSCalendarUnitHour   fromDate:postDate toDate:currentDate options:0] hour];
  NSUInteger days    = [[calendar components:NSCalendarUnitDay    fromDate:postDate toDate:currentDate options:0] day];
  
  NSString *elapsedTime;
  
  if (days > 7) {
    elapsedTime = [NSString stringWithFormat:@"%luw", (long)ceil(days/7.0)];
  } else if (days > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lud", (long)days];
  } else if (hours > 0) {
    elapsedTime = [NSString stringWithFormat:@"%luh", (long)hours];
  } else if (minutes > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lum", (long)minutes];
  } else if (seconds > 0) {
    elapsedTime = [NSString stringWithFormat:@"%lus", (long)seconds];
  } else {
    elapsedTime = @"ERROR";
  }
  
  return elapsedTime;
}

@end