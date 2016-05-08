//
//  SearchViewController.h
//  TabProject
//
//  Created by gaoyan on 5/2/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySearchDelegate.h"

@interface SearchViewController : UITableViewController
- (void) setTagList:(NSArray *)tags;
- (void) setOnItemSelect:(id<MySearchDelegate>)delegate;
@end
