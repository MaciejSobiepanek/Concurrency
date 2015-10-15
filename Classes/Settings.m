//
//  Settings.m
//  Concurrency
//
//  Created by Nick Lockwood on 22/01/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//

#import "Settings.h"
#import "AppDelegate.h"

@implementation Settings

+(Settings*)currentSettings{
    NSManagedObjectContext *context = [AppDelegate instance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Settings"];
    request.fetchLimit = 1;
    NSError *fetchError = nil;
    Settings *settings = [[context executeFetchRequest:request error:&fetchError] firstObject];
    if (fetchError){
        return nil;
    }
    else if (!settings){
        //default values configured in momd
        settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
    }
    return settings;
}

@end
