//
//  MineViewController.m
//  TabProject
//
//  Created by gaoyan on 3/22/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "MineViewController.h"
#import "AFNetworking.h"
#import "DMHttpTool.h"

@interface MineViewController()
@property (weak, nonatomic) IBOutlet UILabel *content;

@end

@implementation MineViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    NSDictionary *parameter = @{@"q":@"美女", @"offset": @10 };
    [DMHttpTool GET:IMAGE_URL parameters:parameter success:^(id responseObject) {
        self.content.text = @"成功";
    } failure:^(NSError *error) {
        self.content.text = @"失败";
    }];
    
    
    
}

-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
