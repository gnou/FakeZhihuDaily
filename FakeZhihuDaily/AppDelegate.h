//
//  AppDelegate.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (UIColor *)tintColor;
- (void)startFetch;
- (NSString *)dateStringOfToday;
- (BOOL)isValidDateString:(NSString *)dateString;
- (void)fetchStoriesOfDate:(NSString *)dateString;
@end

