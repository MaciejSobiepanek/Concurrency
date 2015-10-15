//
//  Currencies.h
//  CurrencyConverter
//
//  Created by Nick Lockwood on 27/06/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "Currency+CoreDataProperties.h"
#import "Settings+CoreDataProperties.h"

extern NSString *const CurrenciesUpdatedNotification;


@interface Currencies : NSObject
@property (nonatomic, retain) Settings *settings;
@property (nonatomic, retain) NSArray *currencies;

- (Currency *)currencyForCode:(NSString *)code;
- (NSArray *)currenciesMatchingSearchString:(NSString *)searchString;
- (void)updateWithBlock:(void (^)(void))block;
- (void)update;
- (NSArray*)enabledCurrencies;

+ (id)sharedInstance;

@end
