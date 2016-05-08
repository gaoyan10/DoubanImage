//
//  SelectImageCell.h
//  TabProject
//
//  Created by gaoyan on 5/5/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageModel;

@interface SelectImageCell : UICollectionViewCell

@property (nonatomic, strong) ImageModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

-(void)setImageData:(ImageModel *)data;

@end
