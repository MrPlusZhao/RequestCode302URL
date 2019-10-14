//
//  ViewController.m
//  重定向获取URL
//
//  Created by Mr.Plus on 2019/10/14.
//  Copyright © 2019 MrPlus. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface ViewController ()<NSURLSessionTaskDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self request302]; /// 用NSURLSession 拦截重定向URL地址
//    [self request302ForAFN]; /// 用AFN 拦截重定向URL地址
}
/// 用AFN 拦截重定向URL地址
- (void)request302ForAFN
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://www.bing.com" parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
    [manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nullable(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse.statusCode == 302) {
            // do something ...
            NSLog(@"重定向地址 == %@",urlResponse.allHeaderFields[@"Location"]);
            // https://www.bing.com ---->  http://cn.bing.com
        }
        if (request) {
            return request;
        }else{
            return nil;
        }
    }];
}
/// 用NSURLSession 拦截重定向URL地址
- (void)request302
{
    NSURL *url = [NSURL URLWithString:@"https://www.bing.com"];
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:url];
    quest.HTTPMethod = @"GET";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if (urlResponse.statusCode == 302) {
            // do something ...
            NSLog(@"重定向地址 == %@",urlResponse.allHeaderFields[@"Location"]);
        }
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    NSLog(@"%ld",response.statusCode); // 302
    NSLog(@"%@",response.allHeaderFields[@"Location"]); // 重定向地址URL
//    completionHandler(nil); 打开,block会有回调,不打开就没有回调,根据业务需求决定
}

@end
