//
//  Theme_Story.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/16.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Theme;

@interface ThemeStory : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * shareURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Theme *blongsTo;

@end
