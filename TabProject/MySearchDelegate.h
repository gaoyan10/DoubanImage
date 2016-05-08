//
//  MySearchDelegate.h
//  TabProject
//
//  Created by gaoyan on 5/2/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MySearchDelegate <NSObject>
@required
- (void)onSearchItemSelect:(id)content;
@end
