//
//  LMDistanceCalculator.m
//  LMDistanceCalculator
//
//  Created by LMinh on 6/7/16.
//  Copyright © 2016 LMinh. All rights reserved.
//

#import "LMDistanceCalculator.h"

static NSString * const kLMDistanceCalculatorErrorDomain = @"LMDistanceCalculatorError";

@interface LMDistanceCalculator ()

@property (nonatomic, strong) NSURLSessionDataTask *googleDistanceTask;

@end

@implementation LMDistanceCalculator

#pragma mark - INIT

+ (instancetype)sharedInstance
{
    static LMDistanceCalculator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.travelMode = @"walking";
    }
    return self;
}


#pragma mark - GEOMETRY DISTANCE

+ (CGFloat)geometryDistanceFromOrigin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)destination
{
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:origin.latitude longitude:origin.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    
    CLLocationDistance geometryDistance = [originLocation distanceFromLocation:destinationLocation];
    return geometryDistance;
}


#pragma mark - REAL DISTANCE SYNCHRONOUS

- (nullable NSNumber *)realDistanceFromOrigin:(CLLocationCoordinate2D)origin
                                  destination:(CLLocationCoordinate2D)destination
                                        error:(NSError **)error
{
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:origin.latitude longitude:origin.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    
    NSArray *results = [self realDistancesFromOrigins:@[originLocation]
                                         destinations:@[destinationLocation]
                                                error:error];
    return [results firstObject];
}

- (nullable NSArray *)realDistancesFromOrigins:(NSArray *)origins
                                  destinations:(NSArray *)destinations
                                         error:(NSError **)error
{
    // Check valid input
    if (origins.count == 0 || destinations.count == 0 || (origins.count * destinations.count > 100))
    {
        // Invalid input --> Return
        *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                     code:kLMDistanceCalculatorErrorInvalidInput
                                 userInfo:nil];
        return nil;
    }
    else
    {
        // Valid input --> Call Google Distance Matrix API
        NSString *urlString = [self requestURLStringFromOrigins:origins destinations:destinations];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
        
        if (!error && data)
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:error];
            if (!error && result)
            {
                NSString *status = [result objectForKey:@"status"];
                if ([status isEqualToString:@"OK"])
                {
                    // Status OK --> Parse response results
                    NSDictionary *firstRow = [[result objectForKey:@"rows"] firstObject];
                    
                    // Get distance
                    NSMutableArray *distances = [NSMutableArray new];
                    NSArray *elements = [firstRow objectForKey:@"elements"];
                    for (NSDictionary *element in elements) {
                        NSNumber *distance = element[@"distance"][@"value"];
                        if (distance) {
                            [distances addObject:distance];
                        }
                    }
                    
                    // Return
                    return distances;
                }
                else if ([status isEqualToString:@"OVER_QUERY_LIMIT"])
                {
                    // Status Over query limit --> Return error
                    *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                                 code:kLMDistanceCalculatorErrorOverLimit
                                             userInfo:nil];
                }
                else
                {
                    // Other Status --> Return error
                    *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                                 code:kLMDistanceCalculatorErrorInternal
                                             userInfo:nil];
                }
            }
        }
        
        return nil;
    }
}


#pragma mark - REAL DISTANCE ASYNCHRONOUS

- (void)realDistanceFromOrigin:(CLLocationCoordinate2D)origin
                   destination:(CLLocationCoordinate2D)destination
             completionHandler:(nullable LMDistanceCallback)handler
{
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:origin.latitude longitude:origin.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    
    [self realDistancesFromOrigins:@[originLocation]
                      destinations:@[destinationLocation]
                 completionHandler:^(NSArray * _Nullable results, NSError * _Nullable error) {
                     
                     if (handler) {
                         handler([results firstObject], error);
                     }
                 }];
}

- (void)realDistancesFromOrigins:(NSArray *)origins
                    destinations:(NSArray *)destinations
               completionHandler:(nullable LMDistancesCallback)handler
{
    // Check valid input
    if (origins.count == 0 || destinations.count == 0 || (origins.count * destinations.count > 100))
    {
        // Invalid input --> Return
        NSError *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                             code:kLMDistanceCalculatorErrorInvalidInput
                                         userInfo:nil];
        if (handler) {
            handler(nil, error);
        }
    }
    else
    {
        // Valid input --> Call Google Distance Matrix API
        NSString *urlString = [self requestURLStringFromOrigins:origins destinations:destinations];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        self.googleDistanceTask = [session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 
                                                 if (!error && data)
                                                 {
                                                     // Request successful --> Parse response to JSON
                                                     NSError *parsingError = nil;
                                                     NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:NSJSONReadingAllowFragments
                                                                                                              error:&parsingError];
                                                     if (!parsingError && result)
                                                     {
                                                         // Parse successful --> Check status value
                                                         NSString *status = [result valueForKey:@"status"];
                                                         if ([status isEqualToString:@"OK"])
                                                         {
                                                             // Status OK --> Parse response results
                                                             NSDictionary *firstRow = [[result objectForKey:@"rows"] firstObject];
                                                             
                                                             // Get distance
                                                             NSMutableArray *distances = [NSMutableArray new];
                                                             NSArray *elements = [firstRow objectForKey:@"elements"];
                                                             for (NSDictionary *element in elements) {
                                                                 NSNumber *distance = element[@"distance"][@"value"];
                                                                 if (distance) {
                                                                     [distances addObject:distance];
                                                                 }
                                                             }
                                                             
                                                             if (handler) {
                                                                 handler(distances, nil);
                                                             }
                                                         }
                                                         else if ([status isEqualToString:@"OVER_QUERY_LIMIT"])
                                                         {
                                                             // Status Over query limit --> Return error
                                                             NSError *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                                                                                  code:kLMDistanceCalculatorErrorOverLimit
                                                                                              userInfo:nil];
                                                             if (handler) {
                                                                 handler(nil, error);
                                                             }
                                                         }
                                                         else
                                                         {
                                                             // Other statuses --> Return error
                                                             NSError *error = [NSError errorWithDomain:kLMDistanceCalculatorErrorDomain
                                                                                                  code:kLMDistanceCalculatorErrorInternal
                                                                                              userInfo:nil];
                                                             if (handler) {
                                                                 handler(nil, error);
                                                             }
                                                         }
                                                     }
                                                     else
                                                     {
                                                         // Parse failed --> Return error
                                                         if (handler) {
                                                             handler(nil, parsingError);
                                                         }
                                                     }
                                                 }
                                                 else
                                                 {
                                                     // Request failed --> Return error
                                                     if (handler) {
                                                         handler(nil, error);
                                                     }
                                                 }
                                             }];
        [self.googleDistanceTask resume];
    }
}

- (void)cancelCalculator
{
    if (self.googleDistanceTask) {
        [self.googleDistanceTask cancel];
    }
}


#pragma mark - SUPPORT

- (void)setTravelMode:(NSString *)travelMode
{
    NSArray *availableTravelModes = @[@"driving", @"walking", @"bicycling", @"transit"];
    if ([availableTravelModes containsObject:travelMode]) {
        _travelMode = travelMode;
    }
}

- (NSString *)requestURLStringFromOrigins:(NSArray *)origins
                             destinations:(NSArray *)destinations
{
    NSString *urlString = @"https://maps.googleapis.com/maps/api/distancematrix/json?units=metric";
    if (self.travelMode && self.travelMode.length != 0) {
        urlString = [urlString stringByAppendingFormat:@"&mode=%@", self.travelMode];
    }
    if (self.googleAPIKey && self.googleAPIKey.length) {
        urlString = [urlString stringByAppendingFormat:@"&key=%@", self.googleAPIKey];
    }
    
    for (CLLocation *origin in origins) {
        urlString = [urlString stringByAppendingFormat:@"&origins=%f,%f|", origin.coordinate.latitude, origin.coordinate.longitude];
    }
    urlString = [urlString substringToIndex:urlString.length - 1];
    
    for (CLLocation *destination in destinations) {
        urlString = [urlString stringByAppendingFormat:@"&destinations=%f,%f|", destination.coordinate.latitude, destination.coordinate.longitude];
    }
    urlString = [urlString substringToIndex:urlString.length - 1];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlString;
}

@end
