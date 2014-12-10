//
//  Date.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/10.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Story;

@interface Date : NSManagedObject

@property (nonatomic, retain) NSString * dateString;
@property (nonatomic, retain) NSSet *stories;
@end

@interface Date (CoreDataGeneratedAccessors)

- (void)addStoriesObject:(Story *)value;
- (void)removeStoriesObject:(Story *)value;
- (void)addStories:(NSSet *)values;
- (void)removeStories:(NSSet *)values;

@end
