//
//  Currency+CoreDataProperties.h
//  Concurrency
//
//  Created by Maciej on 15.10.2015.
//  Copyright © 2015 Charcoal Design. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Currency.h"

NS_ASSUME_NONNULL_BEGIN

@interface Currency (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *symbol;
@property (nullable, nonatomic, retain) NSNumber *rate;
@property (nullable, nonatomic, retain) NSNumber *enabled;

@end

NS_ASSUME_NONNULL_END
