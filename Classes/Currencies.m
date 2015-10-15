//
//  Currencies.m
//  CurrencyConverter
//
//  Created by Nick Lockwood on 27/06/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import "Currencies.h"


NSString *const CurrenciesUpdatedNotification = @"CurrenciesUpdatedNotification";
static NSString *const UpdateURL = @"https://themoneyconverter.com/rss-feed/EUR/rss.xml";


@implementation Currencies
{
    NSMutableDictionary *_currenciesByCode;
}

+ (void)load
{
    //auto-initialize
    [self performSelectorOnMainThread:@selector(sharedInstance) withObject:nil waitUntilDone:NO];
}

+ (BMFileFormat)saveFormat
{
    return BMFileFormatXMLPropertyList;
}

- (void)setWithDictionary:(NSDictionary *)dict
{
    //set last updated date
    NSDate *date = dict[@"lastUpdated"];
    if (_lastUpdated && [_lastUpdated timeIntervalSinceDate:date] >= 0)
    {
        //merge enabled
        for (NSDictionary *entry in dict[@"currencies"])
        {
            Currency *currency = [self currencyForCode:entry[@"code"]];
            [currency setValue:entry[@"enabled"] forKey:@"enabled"];
        }
        return;
    }
    _lastUpdated = date;
    
    //set currencies
    _currencies = [[Currency instancesWithArray:dict[@"currencies"]] sortedArrayUsingComparator:^NSComparisonResult(Currency *a, Currency *b) {
        
        return [a.name caseInsensitiveCompare:b.name];
    }];
    
    //set currencies by code
    _currenciesByCode = [NSMutableDictionary dictionaryWithObjects:_currencies forKeys:[_currencies valueForKeyPath:@"code"]];
    
    //download update
    [self update];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (Currency *)currencyForCode:(NSString *)code
{
    Currency *currency = _currenciesByCode[code];
    if (!currency){
        currency = [Currency instance];
        [currency setValue:code forKey:@"code"];
        [currency setValue:code forKey:@"name"];
        _currenciesByCode[code] = currency;
    }
    return currency;
}

- (NSArray *)currenciesMatchingSearchString:(NSString *)searchString
{
    if ([searchString length])
    {
        searchString = [searchString lowercaseString];
        return [self.currencies filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Currency *currency, __unused id bindings) {
            return [[currency.name lowercaseString] rangeOfString:searchString].length || [[currency.code lowercaseString] hasPrefix:searchString];
        }]];
    }
    else
    {
        return self.currencies;
    }
}

- (NSArray *)enabledCurrencies
{
    return [_currencies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled=YES"]];
}


-(void)downloadDataFromYahooCompletionBLock:(nonnull void (^)(BOOL))block{
    NSString *updateURL = @"ahttps://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(";
    for (Currency *currency in _currencies) {
        updateURL = [updateURL stringByAppendingFormat:@"%%22%@EUR%%22%@", currency.code, _currencies.lastObject == currency ? @"" : @"%2C"];
    }
    updateURL = [updateURL stringByAppendingString:@")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"];
    
    NSURL *URL = [NSURL URLWithString:updateURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError){
            NSLog(@"connection to yahoo error %@", connectionError.description);
            block(false);
        }
        else if (data){
            NSError *jsonError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError || !jsonDict[@"query"] || !jsonDict[@"query"][@"results"] || !jsonDict[@"query"][@"results"][@"rate"]){
                NSLog(@"parsing json from yahoo error %@", jsonError);
                block(false);
            }
            else{
                _lastUpdated = [NSDate date];
                NSArray *rates = jsonDict[@"query"][@"results"][@"rate"];
                
                for (NSDictionary *entry in rates)  {
                    NSString *code = [[entry[@"Name"] componentsSeparatedByString:@"/"] firstObject];
                    if (!code) continue;
                    
                    NSString *rate = entry[@"Rate"];
                    if ([rate doubleValue] < 0.000001) continue;
                    
                    Currency *currency = [self currencyForCode:code];
                    [currency setValue:rate forKey:@"rate"];
                }
                block(true);
            }
        }
    }];
}

-(void)downloadDataFromGoogleCompletionBLock:(nonnull void (^)(BOOL))block{
    __block NSUInteger currenciesUpdated = 0;
    for (Currency *currency in _currencies) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://currency-api.appspot.com/api/EUR/%@.json",currency.code]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            currenciesUpdated++;

            if (!connectionError && data){
                NSError *jsonError = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (!jsonError){
                    NSString *code = jsonDict[@"target"];
                    Currency *currency = [self currencyForCode:code];
                    [currency setValue:jsonDict[@"rate"] forKey:@"rate"];
                }
            }
            
            if (currenciesUpdated == _currencies.count){
                _lastUpdated = [NSDate date];
                block(true);
            }
        }];
    }
    
}


-(void)updateFinished:(void (^)(void))block{
    _currencies = [[_currenciesByCode allValues] sortedArrayUsingComparator:^NSComparisonResult(Currency *a, Currency *b) {
        return [a.name caseInsensitiveCompare:b.name];
    }];
    [self save];
    if (block) block();
}

- (void)updateWithBlock:(void (^)(void))block
{
    //yahoo is first source, because: https, one fetch for all data
    [self downloadDataFromYahooCompletionBLock:^(BOOL result){
        if (result)
            [self updateFinished:block];
        else{
            //if yahoo is offline or some errors ex. api change, google is backup
            [self downloadDataFromGoogleCompletionBLock:^(BOOL result){
                //called also when device is offline
                [self updateFinished:block];
            }];
        }
    }];
}

- (void)update
{
    [self updateWithBlock:NULL];
}

- (BOOL)save
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrenciesUpdatedNotification object:self];
    return [super save];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
