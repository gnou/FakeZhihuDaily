//
//  AppDelegate+MOC.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MOC)
- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)createMainQueueManagedObjectContext;
@end
