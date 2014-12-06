//
//  Title.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "Title.h"

@implementation Title

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id":@"id",
             @"title":@"title",
             @"imagesURL":@"images",
             @"shareURL":@"share_url",
             };
}

@end
