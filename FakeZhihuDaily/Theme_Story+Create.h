//
//  Theme_Story+Create.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Theme_Story.h"

@interface Theme_Story (Create)

+ (Theme_Story *)themeStoryWithStoryInfo:(NSDictionary *)storyDictionary withThemeID:(NSUInteger)id inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadThemeStoriesFromArray:(NSArray *)array withThemeID:(NSUInteger)id intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
