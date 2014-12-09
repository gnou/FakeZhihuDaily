//
//  BodyViewController.m
//  FakeZhihuDaily
//
//  Created by CuiMingyu on 14/12/6.
//  Copyright (c) 2014年 gnou. All rights reserved.
//

#import "BodyViewController.h"
#import <ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BodyViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *alphaLayer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageSourceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation BodyViewController

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
    
    [self.indicatorView startAnimating];
    
    self.webView.delegate = self;
    
    //self.navigationController.navigationBarHidden = YES;
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.alphaLayer.backgroundColor = [UIColor whiteColor];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstrain = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
    [self.view addConstraint:rightConstrain];
    
    NSLayoutConstraint *topConstrain = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [self.view addConstraint:topConstrain];
    
    NSLayoutConstraint *bottomConstrain = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:220.0f];
    [self.view addConstraint:bottomConstrain];
    //[self.view addConstraints:@[leftConstraint, rightConstrain, topConstrain]];

    [[[[[RACObserve(self, url) ignore:nil] flattenMap:^RACStream *(NSURL *url) {
        return [self fetchBodyForURL:url];
    }] deliverOn:[RACScheduler mainThreadScheduler]]
       map:^id(NSDictionary *dict) {
        [self.indicatorView stopAnimating];
        NSString *imageURLString = dict[@"image"];
           if (imageURLString) {
               [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURLString]];
               self.alphaLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
               NSString *title = dict[@"title"];
               self.titleLabel.text = title;
               NSString *imageSource = dict[@"image_source"];
               self.imageSourceLabel.text = imageSource;
           } else {
               [self.imageView removeFromSuperview];
               [self.alphaLayer removeFromSuperview];
               [self.titleLabel removeFromSuperview];
               [self.imageSourceLabel removeFromSuperview];
           }
        
        return [self generateWebPageFromDictionary:dict];
    }] subscribeNext:^(NSString *htmlString) {
        [self.webView loadHTMLString:htmlString baseURL:nil];
        self.scrollView.contentSize = self.contentView.frame.size;
    } error:^(NSError *error) {
        //Handle Error
    }];
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

//- (RACSignal *)fetchCSSFromURL:(NSURL *)url {
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            if (error) {
//                [subscriber sendError:error];
//            } else {
//                NSString *css = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                [subscriber sendNext:css];
//            }
//        }];
//        [dataTask resume];
//        
//        return [RACDisposable disposableWithBlock:^{
//            [dataTask cancel];
//        }];
//    }];
//}

- (NSString *)generateWebPageFromDictionary:(NSDictionary *)dictionary {
    NSString *htmlBodyString = dictionary[@"body"];
    NSString *cssURLString = dictionary[@"css"][0];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", cssURLString, htmlBodyString];
    //NSLog(@"%@", htmlString);
    //NSString *htmlString = [NSString stringWithFormat:@"<html><head></head><body>%@</body></html>",dictionary[@"body"]];
    return htmlString;
}

@end
