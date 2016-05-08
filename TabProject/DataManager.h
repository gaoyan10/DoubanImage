//
//  DataManager.h
//  TabProject
//
//  Created by gaoyan on 5/6/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ImageDBObject.h"
#import "ImageModel.h"
#define TableName @"Collection"

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistantStoreCoordinator;

- (void) saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (int) insertSingleCoreData:(ImageModel *)model;
//插入数据
- (int)insertCoreData:(NSMutableArray *)dataArray;
//查询数据
- (NSMutableArray *)selectData:(int)limit andOffset:(int)offset;
//删除
- (int) deleteData;
//删除一条
- (int) deleteData:(ImageModel *)model;
//更新
- (int) updateData:(NSString *)newId withSrc:(NSString *)src;

- (NSInteger) getDataCount;
@end
