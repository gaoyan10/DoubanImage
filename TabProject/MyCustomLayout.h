//
//  MyCustomLayout.h
//  TabProject
//
//  Created by gaoyan on 4/28/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomLayout : UICollectionViewLayout

@property (nonatomic, readonly) CGFloat horizontalInset;
@property (nonatomic, readonly) CGFloat verticalInset;
@property (nonatomic, readonly) CGFloat minimumItemWidth;
@property (nonatomic, readonly) CGFloat maxmumItemWidth;
@property (nonatomic, readonly) CGFloat itemHeight;

@end
