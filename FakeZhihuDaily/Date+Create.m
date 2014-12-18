//
//  Date+Create.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/10.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Date+Create.h"

@implementation Date (Create)

+ (Date *)dateWithDateString:(NSString *)dateString inManagedObjectContext:(NSManagedObjectContext *)context {
    Date *date = nil;
    if ([dateString length]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Date"];
        request.predicate = [NSPredicate predicateWithFormat:@"dateString = %@", dateString];
        
        NSError *error;
        NSArray *matchArray = [context executeFetchRequest:request error:&error];
        
        if (!matchArray || error || [matchArray count] > 1) {
            // Handle Error
            NSLog(@"ERROR in %s", __FUNCTION__);
        } else if ([matchArray count]) {
            date = matchArray.firstObject;
        } else if (![matchArray count]){
            date = [NSEntityDescription insertNewObjectForEntityForName:@"Date" inManagedObjectContext:context];
            date.dateString = dateString;
        }
    }
    return date;
}
@end
