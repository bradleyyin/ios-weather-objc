//
//  IIIForecastController.m
//  WeatherObjC
//
//  Created by Bradley Yin on 10/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

#import "IIIForecastController.h"
#import "IIIDailyForecast.h"

@implementation IIIForecastController

static NSString *apiKey = @"bedd2db7595a82b10b2420f192697d45";
static NSString *baseURLString = @"https://api.openweathermap.org/data/2.5/forecast?";

//http://api.openweathermap.org/data/2.5/forecast?id=524901&APPID={APIKEY}
//api.openweathermap.org/data/2.5/weather?zip={zip code},{country code}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _forecasts = [[NSArray alloc] init];
    }
    return self;
}

- (void)fetchForecastsForZip:(int)zipCode
           completitionBlock:(IIIForecastFetcherCompletionBlock)completionBlock {
    
    // Create API request
    
    // Setup the URL
    
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:baseURLString];
    
    // Query Parameters
    NSArray *queryItems = @[
                            [NSURLQueryItem queryItemWithName:@"zip" value:[NSString stringWithFormat:@"%d",zipCode]],
                            [NSURLQueryItem queryItemWithName:@"id" value:@"524901"],
                            [NSURLQueryItem queryItemWithName:@"APPID" value:apiKey],
                            ];
    
    urlComponents.queryItems = queryItems;
    
    NSURL *url = urlComponents.URL;
    NSLog(@"URL: %@", url);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Handle the responses (error vs. data)

        // Call the completion block as needed
        // check the errors
        
        if (error) {
            NSLog(@"Error fetching quakes: %@", error);
            completionBlock(nil, error);
            return;
        }
        
        // parse the data
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON Error: %@", jsonError);
            completionBlock(nil, jsonError);
            return;
        }
        
        // TODO: Parse the data
        NSLog(@"JSON: %@", json);
        //Convert from dictionary to a [Quake] using NSArray
        NSDictionary *city = json[@"city"];
        NSString *cityName = city[@"name"];
        NSArray *forecastsList = json[@"list"];
        NSMutableArray *forecasts = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in forecastsList) {
            IIIDailyForecast *forecast = [[IIIDailyForecast alloc] initWithDictionary:dictionary :cityName];
            if (forecast) {
                [forecasts addObject:forecast];
            }
        }
        NSMutableArray *forecastsDivideByFive = [[NSMutableArray alloc] init];
        for (int i = 0; i < 40; i += 8) {
            [forecastsDivideByFive addObject:forecasts[i]];
        }
        self->_forecasts = forecastsDivideByFive;
       completionBlock(forecasts, nil);




        
    }];
    [task resume];
    
    
    
}
@end
