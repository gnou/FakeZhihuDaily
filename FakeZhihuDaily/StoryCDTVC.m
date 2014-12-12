//
//  StoryCDTVC.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "StoryCDTVC.h"
#import "StorysDatabaseAvailability.h"
#import "TitleCell.h"
#import "Story.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "BodyViewController.h"
#import "Date.h"
#import <ReactiveCocoa.h>
#import <SWRevealViewController.h>

#define HEIGHT_OF_SECTION_HEADER 37.5f

@interface StoryCDTVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) CGFloat screenHeight;
@end

@implementation StoryCDTVC

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:StorysDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo[StorysDatabaseAvailabilityContext];
        //[self.navigationController setNavigationBarHidden:YES];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.appDelegate = [UIApplication sharedApplication].delegate;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        self.dateFormatter.dateStyle = NSDateFormatterFullStyle;
        self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    }];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.sideBarButton.target = self.revealViewController;
//    self.sideBarButton.action = @selector(revealToggle:);
//    
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gaPrefix"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"date.dateString" cacheName:nil];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = (TitleCell *)[tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0f;
    } else {
        return HEIGHT_OF_SECTION_HEADER;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, HEIGHT_OF_SECTION_HEADER);
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    sectionHeaderView.backgroundColor = [self.appDelegate tintColor];
    NSString *headerString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    UILabel *headerLabel = [[UILabel alloc] init];
    
    NSString *displayText = [self displaySectionHeaderString:headerString];
    headerLabel.text = displayText;
    [headerLabel sizeToFit];
    [sectionHeaderView addSubview:headerLabel];
    
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerX];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerY];

//    [[[[[[RACObserve(sectionHeaderView, frame) ignore:nil]
//       map:^id(NSNumber *rect) {
//        return [NSNumber numberWithDouble:rect.CGRectValue.origin.y];
//    }]
//     filter:^BOOL(NSNumber *sectionOriginalY) {
//         return sectionOriginalY.floatValue > 0.0;
//    }] filter:^BOOL(NSNumber *sectionOriginalY) {
//        //return self.tableView.contentOffset.y > 1500.0;
//        return (sectionOriginalY.floatValue <= (self.tableView.contentOffset.y + 64.0 - HEIGHT_OF_SECTION_HEADER));
//    }] deliverOn:[RACScheduler mainThreadScheduler]]
//     subscribeNext:^(NSNumber *sectionOriginalY) {
//         self.title = displayText;
//    }];
    
    return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Total sections number
    NSInteger sectionsNum = [[self.fetchedResultsController sections] count];
    
    // Total rows number in current section
    NSInteger rowsNum = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
        rowsNum = [sectionInfo numberOfObjects];
    }
    
    // check if this is the end of tableView
    if ((indexPath.section == (sectionsNum - 1)) && (indexPath.row == (rowsNum - 1))) {
        Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
        Date *currentDate = story.date;
        NSString *currentDateString = currentDate.dateString;
        
        [self.appDelegate fetchStoriesOfDate:currentDateString];
    }
}

#pragma mark- Useful Functions

- (void)configureCell:(TitleCell *)cell atIndexPath:(NSIndexPath *)indexPath  {
    Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = story.title;
    NSString *imageURL = story.imageURL;
    if (!imageURL) {
        NSLog(@"No image");
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:cell.titleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.0f];
        [cell addConstraint:constraint];
    } else {
        [cell.titleImageView sd_setImageWithURL:[NSURL URLWithString:story.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
}

- (NSString *)displaySectionHeaderString:(NSString *)dateString {
    if ([self.appDelegate isValidDateString:dateString]) {
        if ([dateString isEqualToString:[self.appDelegate dateStringOfToday]]) {
            return @"今日热门";
        }
        self.dateFormatter.dateFormat = @"yyyyMMdd";
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        
        NSString *dateFormat;
        NSString *dateComponent = @"MMMd EEEE";
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        
        dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponent options:0 locale:locale];
        [self.dateFormatter setDateFormat:dateFormat];
        
        return [self.dateFormatter stringFromDate:date];
    }
    return nil;
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Goto News Body"]) {
        BodyViewController *bodyVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
        bodyVC.id = story.id;
        
    }
}

// 把contentView向上移动一个HEIGHT_OF_SECTION_HEADER的高度，
// 以防止sectionHeaderView卡在navigationBar下面
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = HEIGHT_OF_SECTION_HEADER;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
@end
