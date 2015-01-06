//
//  ContentViewController.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 15/1/6.
//  Copyright (c) 2015年 gnou. All rights reserved.
//

#import "ContentViewController.h"
#import <ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <UIImageView+WebCache.h>
#import "ContentHeaderView.h"

@interface ContentViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLSession *session;
//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) UIImage *headerImage;
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *imageSourceString;
@end

@implementation ContentViewController

- (void)setId:(NSNumber *)id {
    _id = id;
    
    NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/3/news/%@", id.stringValue];
    self.url = [NSURL URLWithString:urlString];
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    self.webView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    @weakify(self)
    [[[[[RACObserve(self, url) ignore:nil] flattenMap:^RACStream *(NSURL *url) {
        @strongify(self);
        return [self fetchBodyForURL:url];
    }] flattenMap:^RACStream *(NSDictionary *dict) {
        self.htmlString = [self generateWebPageFromDictionary:dict];
        self.titleString = dict[@"title"];
        self.imageSourceString = dict[@"image_source"];
        // Assume image exist
        NSString *imageURLString = dict[@"image"];
        if (imageURLString) {
            return [self fetchImageForURLString:imageURLString];
        } else {
            return nil;
        }
    }] deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(UIImage *image) {
        @strongify(self)
        // Load html string
        [self.webView loadHTMLString:self.htmlString baseURL:nil];
        
        if (image) {
            // init header view from nib
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ContentHeaderView" owner:self options:nil];
            ContentHeaderView *headerView = [nibArray firstObject];
            
            // Setup header view
            CGRect headerFrame = CGRectMake(0, 0, self.webView.frame.size.width, 220);
            headerView.frame = headerFrame;
            headerView.imageView.image = image;
            headerView.titleLabel.text = self.titleString;
            headerView.imageSourceLabel.text = self.imageSourceString;
            [self.webView.scrollView addSubview:headerView];
        }
    } error:^(NSError *error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (RACSignal *)fetchBodyForURL:(NSURL *)url {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                NSError *jsonError;
                NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if (jsonError) {
                    [subscriber sendError:jsonError];
                } else {
                    [subscriber sendNext:bodyDictionary];
                }
            }
        }];
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (RACSignal *)fetchImageForURLString:(NSString *)imageURLString {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:imageURLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                UIImage *newImage = [UIImage imageWithData:data];
                [subscriber sendNext:newImage];
            }
        }];
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (NSString *)generateWebPageFromDictionary:(NSDictionary *)dictionary {
    NSString *htmlBodyString = dictionary[@"body"];
    NSString *cssURLString = dictionary[@"css"][0];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", cssURLString, htmlBodyString];
    return htmlString;
}

@end
