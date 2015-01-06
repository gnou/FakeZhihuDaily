//
//  ThemeBodyViewController.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/18.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "ThemeBodyViewController.h"
#import "NetworkClient.h"
#import "ContentViewController.h"
#import <TSMessage.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface ThemeBodyViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, strong) NSURL *url;
//@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NetworkClient *networkClient;
@end

@implementation ThemeBodyViewController

- (void)setUp {
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

- (void)setId:(NSNumber *)id {
    _id = id;
    
    NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/3/news/%@", id.stringValue];
    self.url = [NSURL URLWithString:urlString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.indicator startAnimating];
    
    self.webView.delegate = self;
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    @weakify(self)
    [[[[[RACObserve(self, url) ignore:nil] flattenMap:^RACStream *(NSURL *url) {
        return [self.networkClient fetchJSONFromURL:url];
    }] deliverOn:[RACScheduler mainThreadScheduler] ]
       map:^id(NSDictionary *jsonDictionary) {
        ContentViewController *bodyVC = [[ContentViewController alloc] init];
        return [bodyVC generateWebPageFromDictionary:jsonDictionary];
    }]
    subscribeNext:^(NSString *htmlString) {
        @strongify(self)
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    } error:^(NSError *error) {
        [TSMessage showNotificationInViewController:self title:@"ERROR" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIWebViewDelegate
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
