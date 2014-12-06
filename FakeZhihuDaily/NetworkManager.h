//
//  Manager.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface NetworkManager : NSObject
+ (instancetype)sharedManager;
//- (RACSignal *)syncTitles;
- (void)trigger;
@end
