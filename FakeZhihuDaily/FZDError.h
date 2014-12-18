//
//  FZDError.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/18.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#ifndef FakeZhihuDaily_FZDError_h
#define FakeZhihuDaily_FZDError_h

#define FZDErrorDomain @"FakeZhihuDailyDomain"

typedef enum : NSUInteger {
    FZDInvalidDateString,
    FZDNoMangedObjectContext,
} FZDError;

#endif
