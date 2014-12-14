//
//  Theme+Create.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/14.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Theme.h"

@interface Theme (Create)
+ (Theme *)themeWithThemeInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadThemesWithThemesArray:(NSArray *)array intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
