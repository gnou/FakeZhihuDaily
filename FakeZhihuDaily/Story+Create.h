//
//  Story+Create.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Story.h"

@interface Story (Create)
+ (Story *)storyWithStoryInfo:(NSDictionary *)storyDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadStorysFromArray:(NSArray *)storyArray intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
