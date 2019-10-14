# RequestCode302URL
iOS AFN 和NSURLSession分别 获取重定向地址code 302
工作中遇到了获取重定向URL地址的问题,网上AFN获取的文章比较少,所以打算记录一下.话不多说.直接上代码
## 1: NSURLSession 方法 
(记得设置 NSURLSessionTaskDelegate )
/// 用NSURLSession 获取重定向URL地址
重点是 willPerformHTTPRedirection 这个代理方法
```
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
```
## 2:AFN 获取重定向URL地址
重点是setTaskWillPerformHTTPRedirectionBlock 方法
```
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
```
