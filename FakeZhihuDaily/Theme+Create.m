//
//  Theme+Create.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/14.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Theme+Create.h"

@implementation Theme (Create)

+ (Theme *)themeWithThemeInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context {
    Theme *theme = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Theme"];
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id = %@", info[@"id"]]];
    
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    if (!resultArray || error || [resultArray count] > 1) {
        NSLog(@"ERROR in %s", __FUNCTION__);
    } else if ([resultArray count]) {
        theme = resultArray.firstObject;
    } else if (![resultArray count]) {
        theme = [NSEntityDescription insertNewObjectForEntityForName:@"Theme" inManagedObjectContext:context];
        
        theme.id = info[@"id"];
        theme.name = info[@"name"];
        theme.descrip = info[@"description"];
        theme.imageURL = info[@"image"];
        theme.color = info[@"color"];
    }
    
    return theme;
}

+ (void)loadThemesWithThemesArray:(NSArray *)array intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *dict in array) {
        [self themeWithThemeInfo:dict inManagedObjectContext:context];
    }
}
@end
