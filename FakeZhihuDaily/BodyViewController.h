//
//  BodyViewController.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BodyViewController : UIViewController
@property (nonatomic, strong) NSNumber *id;
- (NSString *)generateWebPageFromDictionary:(NSDictionary *)dictionary;
@end
