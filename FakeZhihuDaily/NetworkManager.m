//
//  Manager.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "NetworkManager.h"
#import "Title.h"
@import CoreData;
#import "AppDelegate.h"
#import "Story.h"

@interface NetworkManager ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Do some init work here
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        self.context = appDelegate.managedObjectContext;
    }
    return self;
}

- (RACSignal *)syncTitles {
   NSURL *url = [NSURL URLWithString:@"http://news-at.zhihu.com/api/3/news/latest"];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            NSLog(@"response's statusCode: %ld", (long)resp.statusCode);
            if (!error) {
                NSError *jsonError;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (!jsonError) {
                    //NSError *mtlError;
                    NSArray *jsonArray = dict[@"stories"];
                    [self saveTitlesArray:jsonArray];
                    [subscriber sendCompleted];
//                    NSArray * titlesArray = [MTLJSONAdapter modelsOfClass:[Title class] fromJSONArray:jsonArray error:&mtlError];
//                    if (!mtlError) {
//                        //[subscriber sendNext:titlesArray];
//                        [self saveTitlesArray:titlesArray];
//                        [subscriber sendCompleted];
//                    } else {
//                        [subscriber sendError:mtlError];
//                    }
                } else {
                    NSLog(@"%@", jsonError.userInfo);
                    [subscriber sendError:jsonError];
                }
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];

        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (void)saveTitlesArray:(NSArray *)titlesArray {
    for (NSDictionary *title in titlesArray) {
        Story *story = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:self.context];
        story.id = title[@"id"];
        story.title = title[@"title"];
        story.imageURL = title[@"images"][0];
        story.shareURL = title[@"share_url"];
        story.isRead = @(NO);
        NSError *saveError;
        [self.context save:&saveError];
    }
}

- (void)trigger {
    [[self syncTitles]
    subscribeError:^(NSError *error) {
        NSLog(@"Error : %@", error);
    } completed:^{
        NSLog(@"Completion");
    }];
}
@end
