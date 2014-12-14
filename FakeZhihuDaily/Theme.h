//
//  Theme.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/14.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Theme : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSNumber * color;

@end
