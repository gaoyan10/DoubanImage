//
//  SelectImageCell.m
//  TabProject
//
//  Created by gaoyan on 5/5/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "SelectImageCell.h"
#import "UIImageView+WebCache.h"
#import "ImageModel.h"

@implementation SelectImageCell


- (void)setImageData:(ImageModel *)data
{
    [self.image sd_setImageWithURL:[NSURL URLWithString:data.src] placeholderImage:[UIImage imageNamed:@"Image_column_default"]];
}

@end
