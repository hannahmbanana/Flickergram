//
//  PhotoModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PhotoModel.h"
#import <UIKit/UIKit.h>

@implementation PhotoModel
{
  NSDictionary *_dictionaryRepresentation;
  NSString     *_uploadDateRaw;
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
    
    _uploadDateRaw              = [photoDictionary objectForKey:@"created_at"];
    
    _photoID                    = [[photoDictionary objectForKey:@"id"] description];
    
//    _title                      = [photoDictionary objectForKey:@"title"];
//    _descriptionText            = [photoDictionary valueForKeyPath:@"description._content"];
    
    // photo location
    _location                   = [[LocationModel alloc] initWith500pxPhoto:photoDictionary];

    // calculate dateString off the main thread
    _uploadDateString = [self elapsedTimeStringSinceDate:_uploadDateRaw];
  }
  
  return self;

}

  
#pragma mark - Helper Methods

// Returns a user-visible date time string that corresponds to the
// specified RFC 3339 date time string. Note that this does not handle
// all possible RFC 3339 date time strings, just one of the most common
// styles.
- (NSDate *)userVisibleDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString
{
  NSDateFormatter *   rfc3339DateFormatter;
  NSLocale *          enUSPOSIXLocale;
  
  // Convert the RFC 3339 date time string to an NSDate.
  
  rfc3339DateFormatter = [[NSDateFormatter alloc] init];
  
  enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  
  [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
  [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ'"];
  [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  
  return [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
}

- (NSString *)elapsedTimeStringSinceDate:(NSString *)uploadDateString
{
  // early return if no post date string
  if (!uploadDateString)
  {
    return @"NO POST DATE";
  }
  
  NSDate *postDate = [self userVisibleDateTimeStringForRFC3339DateTimeString:uploadDateString];

  if (!postDate) {
    return @"DATE CONVERSION ERROR";
  }
  
  NSDate *currentDate         = [NSDate date];
  
  NSCalendar *calendar        = [NSCalendar currentCalendar];
  
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
  } else if (seconds == 0) {
    elapsedTime = @"1s";
  } else {
    elapsedTime = @"ERROR";
  }
  
  return elapsedTime;
}

@end