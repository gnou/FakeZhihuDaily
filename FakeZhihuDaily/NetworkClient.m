//
//  NetworkClient.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "NetworkClient.h"
#import "Story+Create.h"
#import "ThemeStory+Create.h"
#import "AppDelegate.h"
#import "Theme+Create.h"
#import "FZDError.h"

@interface NetworkClient ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end


@implementation NetworkClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
        self.appDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
}

#pragma mark - Fetch&Save Latest Stories
- (RACSignal *)fetchAndSaveLatestStoriesIntoManagedObjectContext:(NSManagedObjectContext *)context {
    return [[self fetchLatestStories] flattenMap:^RACStream *(NSDictionary *jsonDictionary) {
        return [self saveStories:jsonDictionary intoManagedObjectContext:context];
    }];
}

- (RACSignal *)saveStories:(NSDictionary *)storiesDictionary
        intoManagedObjectContext:(NSManagedObjectContext *)context {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *dateString = storiesDictionary[@"date"];
        NSArray *storiesArray = storiesDictionary[@"stories"];
        [context performBlock:^{
            NSError *saveError = nil;
            [Story loadStorysFromArray:storiesArray withDateString:dateString intoManagedObjectContext:context];
            [context save:&saveError];
            if (saveError) {
                [subscriber sendError:saveError];
            } else {
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)fetchLatestStories {
    NSString *urlString = @"http://news-at.zhihu.com/api/3/news/latest";
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

#pragma mark - Fetch&Save Stories Before a Date

- (RACSignal *)fetchAndSaveStoriesBeforeCertainDate:(NSString *)dateString
                    intoManagedObjectContext:(NSManagedObjectContext *)context {
    return [[self fetchStoriesBeforCertainDate:dateString] flattenMap:^RACStream *(NSDictionary *jsonDictionary) {
        return [self saveStories:jsonDictionary intoManagedObjectContext:context];
    }];
}

- (RACSignal *)fetchStoriesBeforCertainDate:(NSString *)dateString {
    if (![self.appDelegate isValidDateString:dateString]) {
        [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"not a valid date string", nil)};
            NSError *notValidDateStringError = [NSError errorWithDomain:FZDErrorDomain code:FZDInvalidDateString userInfo:userInfo];
            [subscriber sendError:notValidDateStringError];
            return nil;
        }];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/3/news/before/%@", dateString];
        NSURL *url = [NSURL URLWithString:urlString];
        return [self fetchJSONFromURL:url];
    }
    return nil;
}

#pragma mark - Fetch&Save Themes List
- (RACSignal *)fetchAndSaveThemesIntoManagedObjectContext:(NSManagedObjectContext *)context {
    return [[self fetchThemes] flattenMap:^RACStream *(NSDictionary *jsonDictionary) {
        return [self saveThemesList:jsonDictionary intoManagedObjectContext:context];
    }];
}

- (RACSignal *)saveThemesList:(NSDictionary *)themesDictionary
     intoManagedObjectContext:(NSManagedObjectContext *)context {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSArray *themeArray = themesDictionary[@"others"];
        [context performBlock:^{
            [Theme loadThemesWithThemesArray:themeArray intoManagedObjectContext:context];
            NSError *saveError = nil;
            [context save:&saveError];
            if (saveError) {
                [subscriber sendError:saveError];
            } else {
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)fetchThemes {
    NSString *urlString = @"http://news-at.zhihu.com/api/3/themes";
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

#pragma mark - Fetch&Save Theme Stories
- (RACSignal *)fetchAndSaveThemeStoriesWithThemeID:(NSUInteger)themeID
                           intoMangedObjectContext:(NSManagedObjectContext *)context {
    return [[self fetchStoriesOfCertainTheme:themeID] flattenMap:^RACStream *(NSDictionary *jsonDictionary) {
        return [self saveCertainThemeStories:jsonDictionary withThemeID:themeID intoManagedObjectContext:context];
    }];
}

- (RACSignal *)saveCertainThemeStories:(NSDictionary *)themeStoriesDictionary
                           withThemeID:(NSUInteger)themeID
              intoManagedObjectContext:(NSManagedObjectContext *)context {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSArray *themeStoriesArray = themeStoriesDictionary[@"stories"];
        [context performBlock:^{
            [ThemeStory loadThemeStoriesFromArray:themeStoriesArray withThemeID:themeID intoManagedObjectContext:context];
            NSError *saveError = nil;
            [context save:&saveError];
            if (saveError) {
                [subscriber sendError:saveError];
            } else {
                [subscriber sendCompleted];
            }
            
        }];
        return nil;
    }];
}

- (RACSignal *)fetchStoriesOfCertainTheme:(NSUInteger)themeID {
    NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/3/theme/%lu", themeID];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    //NSLog(@"Fetching: %@",url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                }
            }
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

@end
