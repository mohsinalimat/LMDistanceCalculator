//
//  ViewController.m
//  LMDistanceCalculatorDemo
//
//  Created by LMinh on 6/7/16.
//  Copyright © 2016 LMinh. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "LMDistanceCalculator.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D origin;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *originView;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UIView *geometryDistanceView;
@property (weak, nonatomic) IBOutlet UILabel *geometryDistanceLabel;
@property (weak, nonatomic) IBOutlet UIView *realDistanceView;
@property (weak, nonatomic) IBOutlet UILabel *realDistanceLabel;

@end

@implementation ViewController

#pragma mark - VIEW LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Apple
    self.origin = CLLocationCoordinate2DMake(37.332064, -122.028570);
    self.originLabel.text = @"Apple, Infinite Loop";
    
    // Start getting current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 100;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Customize UI
    [self customizeUI];
}

- (void)customizeUI
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Black background
    self.originView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.destinationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.geometryDistanceView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.realDistanceView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    
    // Show camera on real device for nice effect
    BOOL hasCamera = ([[AVCaptureDevice devices] count] > 0);
    if (hasCamera)
    {
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetHigh;
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [captureVideoPreviewLayer setFrame:self.backgroundImageView.bounds];
        [self.backgroundImageView.layer addSublayer:captureVideoPreviewLayer];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        [session startRunning];
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"background"];
    }
}


#pragma mark - LOCATION MANAGER

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CGFloat geometryDistance = [LMDistanceCalculator geometryDistanceFromOrigin:self.origin destination:location.coordinate];
    
    // Update UI
    self.destinationLabel.text = [NSString stringWithFormat:@"%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude];
    self.geometryDistanceLabel.text = [NSString stringWithFormat:@"%dm", (int)geometryDistance];
     
    // Start to reverse
    [[LMDistanceCalculator sharedInstance] cancelCalculator];
    [[LMDistanceCalculator sharedInstance] realDistanceFromOrigin:self.origin
                                                      destination:location.coordinate
                                                completionHandler:^(NSNumber * _Nullable result, NSError * _Nullable error) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (result && !error) {
                                                    self.realDistanceLabel.text = [NSString stringWithFormat:@"%dm", [result intValue]];
                                                }
                                                else {
                                                    self.realDistanceLabel.text = @"-";
                                                }
                                            });
                                        }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Updating location failed");
}

@end
