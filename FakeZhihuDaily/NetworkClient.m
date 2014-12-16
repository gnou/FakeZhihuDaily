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

- (void)fetchLatestStoriesIntoMangedObejctContext:(NSManagedObjectContext *)context {
    [[self fetchLatestStories] subscribeNext:^(NSDictionary *jsonDictionary) {
        NSString *dateString = jsonDictionary[@"date"];
        NSArray *storiesArray = jsonDictionary[@"stories"];
        [context performBlock:^{
            [Story loadStorysFromArray:storiesArray withDateString:dateString intoManagedObjectContext:context];
            [context save:NULL];
        }];
    } error:^(NSError *error) {
#warning Handle error
        // Handle error
    }];
}

- (void)fetchStoriesBeforCertainDate:(NSString *)dateString intoManagedObjectContext:(NSManagedObjectContext *)context {
    [[self fetchStoriesBeforCertainDate:dateString] subscribeNext:^(NSDictionary *jsonDictionary) {
        NSString *dateString = jsonDictionary[@"date"];
        NSArray *storiesArray = jsonDictionary[@"stories"];
        [context performBlock:^{
            [Story loadStorysFromArray:storiesArray withDateString:dateString intoManagedObjectContext:context];
            [context save:NULL];
        }];
    } error:^(NSError *error) {
#warning Handle error
        // Handle error
    }];
}

- (void)fetchThemesIntoManagedObjectContext:(NSManagedObjectContext *)context {
    [[self fetchThemes] subscribeNext:^(NSDictionary *jsonDictionary) {
        [context performBlock:^{
            [Theme loadThemesWithThemesArray:jsonDictionary[@"others"] intoManagedObjectContext:context];
            [context save:NULL];
        }];
    } error:^(NSError *error) {
#warning Handle error
        // Handle error
    }];
}

- (void)fetchThemeStoriesWithThemeID:(NSUInteger)id intoManagedObjectContext:(NSManagedObjectContext *)context {
    [[self fetchStoriesOfCertainTheme:id] subscribeNext:^(NSDictionary *jsonDictionary) {
        [context performBlock:^{
            [ThemeStory loadThemeStoriesFromArray:jsonDictionary[@"stories"] withThemeID:id intoManagedObjectContext:context];
            [context save:NULL];
        }];
    } error:^(NSError *error) {
#warning Handle error
        // Handle error
    }];
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    
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

- (RACSignal *)fetchLatestStories {
    NSString *urlString = @"http://news-at.zhihu.com/api/3/news/latest";
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

- (RACSignal *)fetchStoriesBeforCertainDate:(NSString *)dateString {
    if (![self.appDelegate isValidDateString:dateString]) {
        [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
#warning Create a NSError, then send it to subscriber
            NSError *notValidDateStringError = nil;
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

- (RACSignal *)fetchThemes {
    NSString *urlString = @"http://news-at.zhihu.com/api/3/themes";
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

- (RACSignal *)fetchStoriesOfCertainTheme:(NSUInteger)themeID {
    NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/3/theme/%lu", themeID];
    NSURL *url = [NSURL URLWithString:urlString];
    return [self fetchJSONFromURL:url];
}

@end
