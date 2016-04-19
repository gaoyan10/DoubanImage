//
//  DMHttpTool.h
//  TabProject
//
//  Created by gaoyan on 4/1/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMHttpTool : NSObject

#define IMAGE_URL @"http://www.douban.com/j/search_photo?limit=20"

/**
 *  网络请求的GET方法.
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param sucess     成功的回调
 *  @param failure    失败的回调
 */
+ (void)GET:(NSString *)URLString parameters:(id)parameters
    success:(void (^)(id responseObject))sucess failure:(void (^)(NSError *error))failure;
/**
 *  网络请求的Post方法
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */
+ (void)POST:(NSString *)URLString parameters:(id)parameters
     success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

/**
 *  网络检查.
 */
+ (void)checkNetWork;
/**
 *  网络是否可达
 *
 *  @return true 网络可用.
 */
+ (BOOL)reachability;


@end
