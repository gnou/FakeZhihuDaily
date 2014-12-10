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

#define HEIGHT_OF_SECTION_HEADER 37.5f

@implementation StoryCDTVC

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:StorysDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo[StorysDatabaseAvailabilityContext];
        //[self.navigationController setNavigationBarHidden:YES];
    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = (TitleCell *)[tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_OF_SECTION_HEADER;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, HEIGHT_OF_SECTION_HEADER);
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    sectionHeaderView.backgroundColor = [appDelegate tintColor];
    NSString *headerString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = headerString;
    [headerLabel sizeToFit];
    [sectionHeaderView addSubview:headerLabel];
    
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerX];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerY];
    
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
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate fetchStoriesOfDate:currentDateString];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Goto News Body"]) {
        BodyViewController *bodyVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
        bodyVC.id = story.id;
        
    }
}
@end
