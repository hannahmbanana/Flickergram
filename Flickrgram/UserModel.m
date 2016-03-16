//
//  UserModel.m
//  Flickrgram
//
//  Created by Hannah Troisi on 2/26/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "UserModel.h"
#import <UIKit/UIKit.h>
#import "Utilities.h"

@implementation UserModel
{
  BOOL _fullUserInfoFetchRequested;
  BOOL _fullUserInfoFetchDone;
  void (^_fullUserInfoCompletionBlock)(UserModel *);
}

#pragma mark - Lifecycle

- (instancetype)initWith500pxPhoto:(NSDictionary *)dictionary
{
  self = [super init];
  
  if (self) {
    
    _fullUserInfoFetchRequested = NO;
    _fullUserInfoFetchDone = NO;
    
    // parse user dictionary
    [self loadUserDataFromDictionary:dictionary];
  }
  
  return self;
}


#pragma mark - Instance Methods

- (NSAttributedString *)usernameAttributedStringWithFontSize:(CGFloat)size
{
  return [NSAttributedString attributedStringWithString:self.username
                                               fontSize:size
                                                  color:[UIColor darkBlueColor]
                                         firstWordColor:nil];
}

- (NSAttributedString *)fullNameAttributedStringWithFontSize:(CGFloat)size
{
  return [NSAttributedString attributedStringWithString:self.fullName
                                               fontSize:size
                                                  color:[UIColor lightGrayColor]
                                         firstWordColor:nil];
}

- (void)fetchAvatarImageWithCompletionBlock:(void(^)(UserModel *, UIImage *))block
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    NSData *data   = [NSData dataWithContentsOfURL:_userPicURL];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if (block) {
        block(self, image);
      }
    });
    
  });
}

- (void)downloadCompleteUserDataWithCompletionBlock:(void(^)(UserModel *))block;
{
  if (_fullUserInfoFetchDone) {
    NSAssert(!_fullUserInfoCompletionBlock, @"Should not have a waiting block at this point");
    
    // complete user info fetch complete - excute completion block
    if (block) {
      block(self);
    }
  
  } else {
    NSAssert(!_fullUserInfoCompletionBlock, @"Should not have a waiting block at this point");

    // set completion block
    _fullUserInfoCompletionBlock = block;
    
    if (!_fullUserInfoFetchRequested) {
      
      // if fetch not in progress, beging
      [self fetchCompleteUserData];
    }
  }
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@", self.dictionaryRepresentation];
}

#pragma mark - Helper Methods

- (void)fetchCompleteUserData
{
  _fullUserInfoFetchRequested = YES;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  
    // fetch JSON data from server
    NSString *urlString     = [NSString stringWithFormat:@"https://api.500px.com/v1/users/show?id=%lu&consumer_key=Fi13GVb8g53sGvHICzlram7QkKOlSDmAmp9s9aqC", (unsigned long)_userID];
    
    NSURL *url              = [NSURL URLWithString:urlString];
    
    NSAssert(![NSThread isMainThread], @"Absolutely never call NSData URL loader on main thread");   //FIXME:
    NSData *data            = [NSData dataWithContentsOfURL:url];
    
    NSDictionary *response  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // parse JSON data
    if ([response isKindOfClass:[NSDictionary class]]) {
      [self loadUserDataFromDictionary:response];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      // execute completion block
    
      _fullUserInfoFetchDone = YES;

      if (_fullUserInfoCompletionBlock) {
        _fullUserInfoCompletionBlock(self);
        
        // IT IS ESSENTIAL to nil the block, as it retains a view controller BECAUSE it uses an instance variable which
        // means that self is retained. It could continue to live on forever
        // If we don't release this.
        _fullUserInfoCompletionBlock = nil;
      }
    });
  });
}

- (void)loadUserDataFromDictionary:(NSDictionary *)dictionary
{
  NSDictionary *userDictionary = [dictionary objectForKey:@"user"];
  if (![userDictionary isKindOfClass:[NSDictionary class]]) {
    return;
  }

  _userID                   = [[self guardJSONElement:[userDictionary objectForKey:@"id"]] integerValue];
  _username                 = [[self guardJSONElement:[userDictionary objectForKey:@"username"]] lowercaseString];
  
  if ([_username isKindOfClass:[NSNumber class]]) {
    _username               = @"Anonymous";
  }
  
  _firstName                = [self guardJSONElement:[userDictionary objectForKey:@"firstname"]];
  _lastName                 = [self guardJSONElement:[userDictionary objectForKey:@"lastname"]];
  _fullName                 = [self guardJSONElement:[userDictionary objectForKey:@"fullname"]];
  _city                     = [self guardJSONElement:[userDictionary objectForKey:@"city"]];
  _state                    = [self guardJSONElement:[userDictionary objectForKey:@"state"]];
  _country                  = [self guardJSONElement:[userDictionary objectForKey:@"country"]];
  _about                    = [self guardJSONElement:[userDictionary objectForKey:@"about"]];
  _domain                   = [self guardJSONElement:[userDictionary objectForKey:@"domain"]];
  _photoCount               = [[self guardJSONElement:[userDictionary objectForKey:@"photos_count"]] integerValue];
  _galleriesCount           = [[self guardJSONElement:[userDictionary objectForKey:@"galleries_count"]] integerValue];
  _affection                = [[self guardJSONElement:[userDictionary objectForKey:@"affection"]] integerValue];
  _friendsCount             = [[self guardJSONElement:[userDictionary objectForKey:@"friends_count"]] integerValue];
  _followersCount           = [[self guardJSONElement:[userDictionary objectForKey:@"followers_count"]] integerValue];
  _following                = [[self guardJSONElement:[userDictionary objectForKey:@"following"]] boolValue];
  _dictionaryRepresentation = userDictionary;
  
  NSString *urlString       = [self guardJSONElement:[userDictionary objectForKey:@"userpic_url"]];
  _userPicURL               = urlString ? [NSURL URLWithString:urlString] : nil;

}

- (id)guardJSONElement:(id)element
{
  return (element == [NSNull null]) ? nil : element;
}

@end
