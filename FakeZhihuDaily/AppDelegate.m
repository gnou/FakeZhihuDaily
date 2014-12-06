//
//  AppDelegate.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+MOC.h"
#import "StorysDatabaseAvailability.h"
#import "Story+Create.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *downloadStorysSession;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.managedObjectContext = [self createMainQueueManagedObjectContext];
    
    [self initAppearence];
    
    [self startFetch];
    
    return YES;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    NSDictionary *userInfo = managedObjectContext ? @{StorysDatabaseAvailabilityContext:managedObjectContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:StorysDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

- (void)initAppearence {
    UIColor *myTintColor = [UIColor colorWithRed:76/255.0f green:211/255.0f blue:235/255.0f alpha:1.0f];
    
    [[UITabBar appearance] setTintColor:myTintColor];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:myTintColor];
    
    [[UIToolbar appearance] setBarStyle:UIBarStyleDefault];
    [[UIToolbar appearance] setBarTintColor:myTintColor];
}

- (void)startFetch {
    [self.downloadStorysSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.downloadStorysSession downloadTaskWithURL:[NSURL URLWithString:@"http://news-at.zhihu.com/api/3/news/latest"]];
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

- (NSURLSession *)downloadStorysSession {
    if (!_downloadStorysSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"Fetch Storys"];
        _downloadStorysSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _downloadStorysSession;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *storyData = [NSData dataWithContentsOfURL:location];
    NSError *jsonError;
    NSDictionary *storyDictionary = [NSJSONSerialization JSONObjectWithData:storyData options:NSJSONReadingAllowFragments error:&jsonError];
    if (!jsonError) {
        NSArray *storiesArray = storyDictionary[@"stories"];
        [self.managedObjectContext performBlock:^{
            [Story loadStorysFromArray:storiesArray intoManagedObjectContext:self.managedObjectContext];
            [self.managedObjectContext save:NULL];
        }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
