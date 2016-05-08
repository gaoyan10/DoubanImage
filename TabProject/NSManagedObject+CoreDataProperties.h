//
//  NSManagedObject+CoreDataProperties.h
//  TabProject
//
//  Created by gaoyan on 5/5/16.
//  Copyright © 2016 gaoyan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ImageDBObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *src;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSNumber *height;

@end

NS_ASSUME_NONNULL_END
