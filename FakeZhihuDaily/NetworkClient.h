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
- (RACSignal *)fetchAndSaveLatestStoriesIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (RACSignal *)fetchAndSaveStoriesBeforeCertainDate:(NSString *)dateString
                    intoManagedObjectContext:(NSManagedObjectContext *)context;
- (RACSignal *)fetchAndSaveThemesIntoManagedObjectContext:(NSManagedObjectContext *)context;
- (RACSignal *)fetchAndSaveThemeStoriesWithThemeID:(NSUInteger)themeID
                           intoMangedObjectContext:(NSManagedObjectContext *)context;

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
@end
