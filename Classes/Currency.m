//
//  Currency.m
//  CurrencyConverter
//
//  Created by Nick Lockwood on 30/06/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import "Currency+CoreDataProperties.h"
#import "Currencies.h"
#import "AppDelegate.h"

@implementation Currency
{
    //not a property, because we don't want to save it
    NSNumberFormatter *_numberFormatter;
}

+ (instancetype)nullCurrency
{
    static Currency *currency = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currency = [[Currency alloc] init];
    });
    
    return currency;
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter)
    {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_numberFormatter setCurrencySymbol:@""]; //currency symbol is displayed separately
    }
    return _numberFormatter;
}

- (void)setCode:(NSString *)code
{
    [self willChangeValueForKey:@"code"];
    [self setPrimitiveValue:code forKey:@"code"];
    [self didChangeValueForKey:@"code"];
    
    NSString *localeIdentifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCurrencyCode: code}];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    [[self numberFormatter] setLocale:locale];
}


- (double)valueInEuros:(double)value
{
    return self.rate.doubleValue ? (value / self.rate.doubleValue): 0.0;
}

- (double)valueFromEuros:(double)euroValue
{
    return euroValue * self.rate.doubleValue;
}

- (double)value:(double)value convertedToCurrency:(Currency *)currency
{
    return [currency valueFromEuros:[self valueInEuros:value]];
}

- (NSString *)localisedStringFromValue:(double)value
{
    return [[self numberFormatter] stringFromNumber:@(value)];
}


+(Currency*)createFromDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context{
    Currency *currency = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:context];
    currency.name = dictionary[@"name"];
    currency.code = dictionary[@"code"];
    currency.rate = dictionary[@"rate"];
    NSString *symbol = dictionary[@"symbol"];
    if (symbol)
        currency.symbol = symbol;
    currency.enabled = dictionary[@"enabled"];    
    return currency;
}

@end
