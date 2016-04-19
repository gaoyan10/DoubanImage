//
//  ImageModel.m
//  TabProject
//
//  Created by gaoyan on 3/31/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel

-(instancetype) initWithDict:(NSDictionary *)dict
{
    ImageModel *image = [[ImageModel alloc] init];
    image.src = dict[@"src"];
    image.author = dict[@"author"];
    image.url = dict[@"url"];
    image._id = dict[@"id"];
    image.title = dict[@"title"];
    image.width =[dict[@"width"] integerValue];
    image.height = [dict[@"height"] integerValue];
    return image;
}

+ (instancetype) imageWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
