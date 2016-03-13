//
//  Utilities.m
//  Flickrgram
//
//  Created by Hannah Troisi on 3/9/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "Utilities.h"
#import <UIKit/UIKit.h>

#define DARK_BLUE [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

@implementation UIImage (Additions)

- (UIImage *)makeRoundImage
{
  // make a CGRect with the image's size
  CGRect circleRect = (CGRect) {CGPointZero, self.size};
  
  // begin the image context since we're not in a drawRect:
  UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);
  
  // create a UIBezierPath circle
  UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
  
  // clip to the circle
  [circle addClip];
  
  // draw the image in the circleRect *AFTER* the context is clipped
  [self drawInRect:circleRect];
  
  // create a border (for white background pictures)
  circle.lineWidth = 1;
  [[UIColor darkGrayColor] set];
  [circle stroke];
  
  // get an image from the image context
  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
  
  // end the image context since we're not in a drawRect:
  UIGraphicsEndImageContext();
  
  return roundedImage;
}

@end

@implementation NSString (Additions)

// Returns a user-visible date time string that corresponds to the
// specified RFC 3339 date time string. Note that this does not handle
// all possible RFC 3339 date time strings, just one of the most common
// styles.
+ (NSDate *)userVisibleDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString
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

+ (NSString *)elapsedTimeStringSinceDate:(NSString *)uploadDateString
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

@implementation NSAttributedString (Additions)

+ (NSAttributedString *)colorizeFirstWordInString:(NSString *)string
{
  NSDictionary *attributes                    = @{NSForegroundColorAttributeName: DARK_BLUE};
  NSRange firstWordRange                      = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
  [attributedString addAttributes:attributes range:firstWordRange];
  
  return attributedString;
}

@end