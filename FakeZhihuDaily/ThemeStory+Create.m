//
//  ThemeStory+Create.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "ThemeStory+Create.h"
#import "Theme+Create.m"

@implementation ThemeStory (Create)

+ (ThemeStory *)themeStoryWithStoryInfo:(NSDictionary *)storyDictionary withThemeID:(NSUInteger)id inManagedObjectContext:(NSManagedObjectContext *)context {
    ThemeStory *story =  nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ThemeStory"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", storyDictionary[@"id"]];
    
    NSError *error;
    NSArray *matchedResult = [context executeFetchRequest:fetchRequest error:&error];
    
    if (matchedResult == nil || error || [matchedResult count] > 1) {
        NSLog(@"Error in %s", __FUNCTION__);
    } else if ([matchedResult count]) {
        story = matchedResult.firstObject;
    } else {
        story = [NSEntityDescription insertNewObjectForEntityForName:@"ThemeStory" inManagedObjectContext:context];
        story.id = storyDictionary[@"id"];
        story.shareURL = storyDictionary[@"share_url"];
        story.title = storyDictionary[@"title"];
        story.imageURL = storyDictionary[@"images"][0];
        NSDictionary *themeDictionary = @{@"id":[NSNumber numberWithUnsignedLong:id]};
        story.blongsTo = [Theme themeWithThemeInfo:themeDictionary inManagedObjectContext:context];
    }
    
    return story;
}

+ (void)loadThemeStoriesFromArray:(NSArray *)array withThemeID:(NSUInteger)id intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *dict in array) {
        [self themeStoryWithStoryInfo:dict withThemeID:id inManagedObjectContext:context];
    }
}
@end
