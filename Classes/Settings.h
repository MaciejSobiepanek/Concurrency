//
//  Settings.h
//  Concurrency
//
//  Created by Nick Lockwood on 22/01/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//
#import <CoreData/CoreData.h>

@interface Settings : NSManagedObject

+(Settings*)currentSettings;

@end
