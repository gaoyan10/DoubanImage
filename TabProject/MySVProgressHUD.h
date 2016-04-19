//
//  MySVProgressHUD.h
//  TabProject
//
//  Created by gaoyan on 4/1/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "SVProgressHUD.h"

@interface SVProgressHUD(CYM)
+ (void)reveal;
+ (void)revealSuccessWithStatus:(NSString *)status;
+ (void)revealErrorWithStatus:(NSString *)status;
+ (void)revealInfoWithStatus:(NSString *)status;

@end
