//
//  LMDistanceCalculator.h
//  LMDistanceCalculator
//
//  Created by LMinh on 6/7/16.
//  Copyright © 2016 LMinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  LMDistanceCalculator error codes, embedded in NSError.
 */
typedef NS_OPTIONS(NSUInteger, LMGeocoderErrorCode) {
    kLMDistanceCalculatorErrorInvalidInput,
    kLMDistanceCalculatorErrorOverLimit,
    kLMDistanceCalculatorErrorInternal,
};

/*!
 *  Handler that reports a distance response, or error.
 */
typedef void (^LMDistanceCallback) (NSNumber * _Nullable result,  NSError * _Nullable error);
typedef void (^LMDistancesCallback) (NSArray * _Nullable results,  NSError * _Nullable error);

/*!
 *  Exposes a service for calculating distance between locations.
 */
@interface LMDistanceCalculator : NSObject

/*!
 *  To set google API key.
 */
@property (nonatomic, strong, nullable) NSString *googleAPIKey;

/*!
 *  Specifies the mode of transport to use when calculating distance.
 *  The following travel modes are supported: driving, walking (defaults), bicycling, transit.
 */
@property (nonatomic, strong, nullable) NSString *travelMode;

/*!
 *  Get shared instance.
 */
+ (instancetype)sharedInstance;

/*!
 *  Get geometry distance.
 *
 *  @param origin      The origin coordinate.
 *  @param destination The destination coordinate.
 *
 *  @return The distance in meter.
 */
+ (CGFloat)geometryDistanceFromOrigin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)destination;

/*!
 *  Get distance from Google Distance API synchronously.
 *
 *  @param origin      The origin coordinate.
 *  @param destination The destination coordinate.
 *  @param error       The error.
 *
 *  @return The distance in meter.
 */
- (nullable NSNumber *)realDistanceFromOrigin:(CLLocationCoordinate2D)origin
                                  destination:(CLLocationCoordinate2D)destination
                                        error:(NSError **)error;

/*!
 *  Get distance matrix from Google Distance API synchronously.
 *  Limit: 100 elements/request. elements = origins x destinations.
 *
 *  @param origins      The array of origin objects (CLLocation).
 *  @param destinations The array of destination objects (CLLocation).
 *  @param error        The error.
 *
 *  @return The array of distance objects (NSNumber).
 */
- (nullable NSArray *)realDistancesFromOrigins:(NSArray *)origins
                                  destinations:(NSArray *)destinations
                                         error:(NSError **)error;

/*!
 *  Get distance from Google Distance API asynchronously.
 *
 *  @param origin      The origin coordinate.
 *  @param destination The destination coordinate.
 *  @param handler     The callback to invoke with the distance result.
 */
- (void)realDistanceFromOrigin:(CLLocationCoordinate2D)origin
                   destination:(CLLocationCoordinate2D)destination
             completionHandler:(nullable LMDistanceCallback)handler;

/*!
 *  Get distance matrix from Google Distance API asynchronously.
 *  Limit: 100 elements/request. elements = origins x destinations.
 *
 *  @param origins      The array of origin objects (CLLocation).
 *  @param destinations The array of destination objects (CLLocation).
 *  @param handler      The callback to invoke with the distance results.
 */
- (void)realDistancesFromOrigins:(NSArray *)origins
                    destinations:(NSArray *)destinations
               completionHandler:(nullable LMDistancesCallback)handler;

/*!
 *  Cancels a pending distance calculator request.
 */
- (void)cancelCalculator;

@end

NS_ASSUME_NONNULL_END