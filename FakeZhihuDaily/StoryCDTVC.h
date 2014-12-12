//
//  StoryCDTVC.h
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface StoryCDTVC : CoreDataTableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
