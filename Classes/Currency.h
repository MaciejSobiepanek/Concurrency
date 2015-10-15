//
//  Currency.h
//  CurrencyConverter
//
//  Created by Nick Lockwood on 30/06/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Currency : NSManagedObject

+(instancetype)nullCurrency;

- (double)exchangeRateToCurrency:(Currency*)otherCurrency;
- (double)valueInEuros:(double)value;
- (double)valueFromEuros:(double)euroValue;
- (double)value:(double)value convertedToCurrency:(Currency *)currency;
- (NSString *)localisedStringFromValue:(double)value;
+(Currency*)createFromDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context;
@end
