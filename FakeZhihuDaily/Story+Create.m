//
//  Story+Create.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Story+Create.h"
#import "Date+Create.h"

@implementation Story (Create)

+ (Story *)storyWithStoryInfo:(NSDictionary *)storyDictionary withDateString:(NSString *)dateString inManagedObjectContext:(NSManagedObjectContext *)context {
    Story *story = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", storyDictionary[@"id"]];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gaPrefix"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || error || [fetchedObjects count] > 1) {
        NSLog(@"Error : fetch object from DB error");
    } else if ([fetchedObjects count]) {
        return [fetchedObjects firstObject];
    } else {
        story = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
        story.id = storyDictionary[@"id"];
        story.title = storyDictionary[@"title"];
        story.gaPrefix = storyDictionary[@"ga_prefix"];
        story.imageURL = storyDictionary[@"images"][0];
        story.shareURL = storyDictionary[@"share_url"];
        story.date = [Date dateWithDateString:dateString inManagedObjectContext:context];
    }
    return story;
}

+ (void)loadStorysFromArray:(NSArray *)storyArray withDateString:(NSString *)dateString intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *story in storyArray) {
        [self storyWithStoryInfo:story withDateString:(NSString *)dateString inManagedObjectContext:context];
    }
}

@end
