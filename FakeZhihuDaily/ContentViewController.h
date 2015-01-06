//
//  ContentViewController.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 15/1/6.
//  Copyright (c) 2015年 gnou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController
@property (nonatomic, strong) NSNumber *id;
- (NSString *)generateWebPageFromDictionary:(NSDictionary *)dictionary;
@end
