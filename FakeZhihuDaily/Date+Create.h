//
//  Date+Create.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/10.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Date.h"

@interface Date (Create)
+ (Date *)dateWithDateString:(NSString *)dateString inManagedObjectContext:(NSManagedObjectContext *)context;
@end
