//
//  Story.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/10.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Date;

@interface Story : NSManagedObject

@property (nonatomic, retain) NSString * gaPrefix;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * shareURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Date *date;

@end
