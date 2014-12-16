//
//  NetworkClient.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <CoreData/CoreData.h>

@interface NetworkClient : NSObject
- (void)fetchLatestStoriesIntoMangedObejctContext:(NSManagedObjectContext *)context;
- (void)fetchStoriesBeforCertainDate:(NSString *)dateString intoManagedObjectContext:(NSManagedObjectContext *)context;
- (void)fetchThemesIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (void)fetchThemeStoriesWithThemeID:(NSUInteger)id intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
