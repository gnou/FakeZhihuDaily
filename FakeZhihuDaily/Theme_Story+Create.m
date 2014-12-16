//
//  Theme_Story+Create.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Theme_Story+Create.h"
#import "Theme+Create.h"

@implementation Theme_Story (Create)

+ (Theme_Story *)themeStoryWithStoryInfo:(NSDictionary *)storyDictionary withThemeID:(NSUInteger)id inManagedObjectContext:(NSManagedObjectContext *)context {
    Theme_Story *story =  nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Theme_Story"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", storyDictionary[@"id"]];
    
    NSError *error;
    NSArray *matchedResult = [context executeFetchRequest:fetchRequest error:&error];
    
    if (matchedResult == nil || error || [matchedResult count] > 1) {
#warning Handle error
        //Handle error
    } else if ([matchedResult count]) {
        story = matchedResult.firstObject;
    } else {
        story = [NSEntityDescription insertNewObjectForEntityForName:@"Theme_Story" inManagedObjectContext:context];
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
