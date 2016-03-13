//
//  CommentModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 3/9/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "CommentModel.h"
#import "Utilities.h"

@implementation CommentModel
{
  NSDictionary *_dictionaryRepresentation;
}

#pragma mark - Lifecycle

- (instancetype)initWithDictionary:(NSDictionary *)photoDictionary
{
  self = [super init];
  
  if (self) {
    
    _dictionaryRepresentation   = photoDictionary;
    
    _ID              = [[photoDictionary objectForKey:@"id"] integerValue];
    _commenterID     = [[photoDictionary objectForKey:@"user_id"] integerValue];
    _commenterUsername = [photoDictionary valueForKeyPath:@"user.username"];
    _body            = [photoDictionary objectForKey:@"body"];
    _dateString      = [NSString elapsedTimeStringSinceDate:[photoDictionary valueForKeyPath:@"created_at"]];
  }
  
  return self;
}

- (NSAttributedString *)commentAttributedString
{
  return [NSAttributedString colorizeFirstWordInString:[NSString stringWithFormat:@"%@ %@",[_commenterUsername lowercaseString], _body]];
}

@end