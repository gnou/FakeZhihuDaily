//
//  StoryCDTVC.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "MainStoriesViewController.h"
#import "TitleCell.h"
#import "Story.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
//#import "BodyViewController.h"
#import "Date.h"
#import <ReactiveCocoa.h>
#import <SWRevealViewController.h>
#import "NetworkClient.h"
#import <TSMessage.h>
#import "ContentViewController.h"

#define HEIGHT_OF_SECTION_HEADER 37.5f

@interface MainStoriesViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic) CGFloat screenHeight;

@property (nonatomic, strong) NetworkClient *networkClient;
@end

@implementation MainStoriesViewController

- (void)setUp {
//    [[NSNotificationCenter defaultCenter] addObserverForName:StorysDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        self.managedObjectContext = note.userInfo[StorysDatabaseAvailabilityContext];
//    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
    if (self.appDelegate.managedObjectContext) {
        self.managedObjectContext = self.appDelegate.managedObjectContext;
    } else {
        NSLog(@"not managedObjectContext in appDelegate");
    }
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    self.dateFormatter.dateStyle = NSDateFormatterFullStyle;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.networkClient = [[NetworkClient alloc] init];
    
}

- (void)awakeFromNib {
    [self setUp];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setUp];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sideBarButton.target = self.revealViewController;
    self.sideBarButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

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

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    _fetchedResultsController = newfrc;
    _fetchedResultsController.delegate = self;
    
    [self performFetch];
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        if (error) {
            NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = [[self.fetchedResultsController sections] count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        rows = [sectionInfo numberOfObjects];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *titleString = story.title;
    NSString *imageURL = story.imageURL;
    
    TitleCell *cell;
    if (imageURL) {
        cell = (TitleCell *)[tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];
        [cell.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    } else {
        cell = (TitleCell *)[tableView dequeueReusableCellWithIdentifier:@"TitleCellWithoutImage" forIndexPath:indexPath];
    }
    cell.titleLabel.text = titleString;
    //[self configureCell:cell atIndexPath:indexPath];
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
    
    return sectionHeaderView;
}

#pragma mark - UITableViewDelegate

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
        
        [[self.networkClient fetchAndSaveStoriesBeforeCertainDate:currentDateString intoManagedObjectContext:self.managedObjectContext] subscribeError:^(NSError *error) {
            [TSMessage showNotificationInViewController:self.navigationController title:@"ERROR" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark- Useful Functions
//
//- (void)configureCell:(TitleCell *)cell atIndexPath:(NSIndexPath *)indexPath  {
//    Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.titleLabel.text = story.title;
//    NSString *imageURL = story.imageURL;
//    if (!imageURL) {
//        NSLog(@"No image");
//        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:cell.titleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.0f];
//        [cell addConstraint:constraint];
//    } else {
//        [cell.titleImageView sd_setImageWithURL:[NSURL URLWithString:story.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    }
//}

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
    //    if ([segue.identifier isEqualToString:@"Goto News Body"]) {
    //BodyViewController *bodyVC = segue.destinationViewController;
    ContentViewController *contentVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //bodyVC.id = story.id;
    contentVC.id = story.id;
    //    }
}

#pragma mark - UIScrollViewDelegate

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

- (IBAction)getLatestStories:(id)sender {
    [[self.networkClient fetchAndSaveLatestStoriesIntoManagedObjectContext:self.managedObjectContext] subscribeError:^(NSError *error) {
        NSLog(@"error : %@", error.localizedDescription);
    }];
}
@end
