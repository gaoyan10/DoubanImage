//
//  DocumentManager.m
//  TabProject
//
//  Created by gaoyan on 5/2/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager

- (void) createEditableCopyOfDatabaseIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    
    BOOL dbexists = [fileManager fileExistsAtPath:writableDBPath];
    if (!dbexists) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Setting.plist"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"错误写入文件: '%@'", [error localizedDescription]);
        }
    }
}

- (NSString *)applicationDocumentsDirectoryFile
{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"Setting.plist"];
    return path;
}

- (void)writeDocument:(NSString *)value withKey:(NSString *)key
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [dict setObject:value forKey:key];
    [dict writeToFile:path atomically:YES];
}

- (NSString *)readDocument:(NSString *)key
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *value = [dict objectForKey:key];
    return value;
}
@end


