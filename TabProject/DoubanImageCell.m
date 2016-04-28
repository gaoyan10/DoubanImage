//
//  DoubanImageCell.m
//  TabProject
//
//  Created by gaoyan on 4/19/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "DoubanImageCell.h"
#import "UIImageView+WebCache.h"
#import "ImageModel.h"

@interface DoubanImageCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@end
@implementation DoubanImageCell

-(void)setImageData:(ImageModel *)image
{
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:image.src]placeholderImage:[UIImage imageNamed:@"Image_column_default"]];
}

@end
