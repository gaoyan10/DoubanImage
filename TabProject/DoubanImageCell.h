//
//  DoubanImageCell.h
//  TabProject
//
//  Created by gaoyan on 4/19/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageModel;
@interface DoubanImageCell : UICollectionViewCell
@property (nonatomic, strong)ImageModel *model;

-(void)setImageData:(ImageModel *)image;
@end
