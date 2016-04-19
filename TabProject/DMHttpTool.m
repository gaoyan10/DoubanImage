//
//  DMHttpTool.m
//  TabProject
//
//  Created by gaoyan on 4/1/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "DMHttpTool.h"
#import "AFNetworking.h"
#import "MySVProgressHUD.h"
static bool checkNetWork;

@implementation DMHttpTool

+ (void)GET:(NSString *)URLString parameters:(id)parameters

    success:(void (^)(id))success failure:(void (^)(NSError *))failure

{
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.requestSerializer.timeoutInterval = 30;
    
    [SVProgressHUD reveal];
    
    [session.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",
                                                           
                                                           @"text/json", @"text/javascript",nil]];
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    [session GET:url.absoluteString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        if (success) {
            
            [SVProgressHUD dismiss];
            
            success(responseObject);
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
        
        if (failure) {
            
            [SVProgressHUD revealErrorWithStatus:@"获取数据失败"];
            
            failure(error);
            
        }
        
    }];
    
}



+ (void) POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer.timeoutInterval = 30;
    [SVProgressHUD reveal];
    [session.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",
                                                           @"text/json", @"text/javascript",
                                                           @"text/html", @"text/css", nil]];
    [SVProgressHUD reveal];
    NSURL *url = [NSURL URLWithString:URLString];
    [session POST:url.absoluteString parameters:parameters constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            [SVProgressHUD dismiss];
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            [SVProgressHUD revealErrorWithStatus:@"请求失败"];
            failure(error);
        }
    }];
    
    

}
#pragma mark- 网络检测
+(void) checkNetWork
{
    AFNetworkReachabilityManager * mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //当网络状态改变的时候调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                checkNetWork = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                checkNetWork = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                checkNetWork = NO;
                break;
            case AFNetworkReachabilityStatusUnknown:
                checkNetWork = NO;
                break;
        }
    }];
    //开始监控.
    [mgr startMonitoring];
}
+(BOOL)reachability
{
    return checkNetWork;
}
-(void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

@end

