//
//  ImageModel.h
//  TabProject
//
//  Created by gaoyan on 3/31/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageModel : NSObject

@property (nonatomic,copy)NSString *src;
@property (nonatomic,copy)NSString *author;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,copy)NSString *_id;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,assign)NSInteger width;
@property (nonatomic,assign)NSInteger height;

-(instancetype)initWithDict:(NSDictionary*)dict;
+(instancetype)imageWithDict:(NSDictionary*)dict;

@end
