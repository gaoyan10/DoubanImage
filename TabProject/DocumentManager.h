//
//  DocumentManager.h
//  TabProject
//
//  Created by gaoyan on 5/2/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DocumentManager : NSObject
- (void) createEditableCopyOfDatabaseIfNeeded;
- (NSString *)applicationDocumentsDirectoryFile;
- (void)writeDocument:(NSString *)value withKey:(NSString *)key;
- (NSString *)readDocument:(NSString *)key;
@end
