//
//  Settings+CoreDataProperties.h
//  Concurrency
//
//  Created by Maciej on 15.10.2015.
//  Copyright © 2015 Charcoal Design. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Settings.h"

NS_ASSUME_NONNULL_BEGIN

@interface Settings (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastUpdate;
@property (nullable, nonatomic, retain) NSNumber *topPickerIndex;
@property (nullable, nonatomic, retain) NSNumber *bottomPickerSelected;
@property (nullable, nonatomic, retain) NSNumber *bottomPickerIndex;
@property (nullable, nonatomic, retain) NSNumber *currencyValue;

@end

NS_ASSUME_NONNULL_END
