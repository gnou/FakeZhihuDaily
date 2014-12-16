//
//  Theme.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ThemeStory;

@interface Theme : NSManagedObject

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *stories;
@end

@interface Theme (CoreDataGeneratedAccessors)

- (void)addStoriesObject:(ThemeStory *)value;
- (void)removeStoriesObject:(ThemeStory *)value;
- (void)addStories:(NSSet *)values;
- (void)removeStories:(NSSet *)values;

@end
