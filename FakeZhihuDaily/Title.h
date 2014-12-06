//
//  Title.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/11/28.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle/Mantle.h>

@interface Title : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *imagesURL;
@property (nonatomic, strong) NSString *shareURL;
@end
