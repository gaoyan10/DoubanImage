//
//  DataManager.m
//  TabProject
//
//  Created by gaoyan on 5/6/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "DataManager.h"
#import "ImageModel.h"

@implementation DataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistantStoreCoordinator = _persistantStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"DB error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data Stack
//返回应用程序的管理对象上下文
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil){
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistantStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
// 返回应用程序的托管对象模型，如果模型不存在，则创建模型.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Collection" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//返回Coordinator.
- (NSPersistentStoreCoordinator *)persistantStoreCoordinator
{
    if (_persistantStoreCoordinator != nil) {
        return _persistantStoreCoordinator;
    }
    //NSString *storeURL = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"Collection.sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Collection.sqlite"];
    NSError *error = nil;
    _persistantStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistantStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unsolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistantStoreCoordinator;
}
#pragma mark - Allication Documents Directory。
//将URL返回给应用程序的文档目录.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}
- (int)insertSingleCoreData:(ImageModel *)model
{
    NSManagedObjectContext *context = [self managedObjectContext];
    ImageDBObject *imageDBObject = [NSEntityDescription insertNewObjectForEntityForName:TableName inManagedObjectContext:context];
    imageDBObject.url = model.url;
    imageDBObject.src = model.src;
    imageDBObject.height = [NSNumber numberWithInteger:model.height];
    imageDBObject.width = [NSNumber numberWithInteger:model.width];
    imageDBObject.title = model.title;
    imageDBObject.id = model._id;
    imageDBObject.author = model.author;
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"不能保存： %@", [error localizedDescription]);
        return -1;
    }
    return 0;

}
- (int)insertCoreData:(NSMutableArray *)dataArray
{
    NSManagedObjectContext *context = [self managedObjectContext];
    for (ImageModel *model in dataArray){
        ImageDBObject *imageDBObject = [NSEntityDescription insertNewObjectForEntityForName:TableName inManagedObjectContext:context];
        imageDBObject.url = model.url;
        imageDBObject.src = model.src;
        imageDBObject.height = [NSNumber numberWithInteger:model.height];
        imageDBObject.width = [NSNumber numberWithInteger:model.width];
        imageDBObject.title = model.title;
        imageDBObject.id = model._id;
        imageDBObject.author = model.author;
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"不能保存： %@", [error localizedDescription]);
        }
    }
    return 0;
}
//查询
- (NSMutableArray *)selectData:(int)limit andOffset:(int)offset
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setFetchOffset:offset];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (ImageDBObject* image in fetchedObjects) {
        ImageModel *model = [[ImageModel alloc] init];
        model.height = image.height.integerValue;
        model.width = image.width.integerValue;
        model.title = image.title;
        model.src = image.src;
        model.author = image.author;
        model._id = image.id;
        model.url = image.url;
        [resultArray addObject:model];
        
    }
    return resultArray;
    
}
//删除
- (int) deleteData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPendingChanges:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas &&[datas count]) {
        for (NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@", error);
            return -1;
        }
    }
    return 0;
}
- (int) updateData:(NSString *)newId withSrc:(NSString *)src
{
    return 0;
}
- (int) deleteData:(ImageModel *)model
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPendingChanges:NO];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", model._id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas &&[datas count]) {
        for (NSManagedObject *obj in datas) {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error: %@", error);
            return -1;
        }
    }
    return 0;
}
- (NSInteger)getDataCount
{
    NSManagedObjectContext *context = [self managedObjectContext];
     NSEntityDescription *entity = [NSEntityDescription entityForName:TableName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSInteger count = [context countForFetchRequest:request error:&error];
    return count;
    
}
@end
