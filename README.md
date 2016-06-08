LMDistanceCalculator
==============
LMDistanceCalculator is a simple wrapper for calculating geometry and real distance between any locations on Earth.

![](https://raw.github.com/lminhtm/LMDistanceCalculator/master/Screenshots/screenshot.png)

## Features
* Wrapper for calculating geometry and real distance with blocked-based coding.
* Using Google Distance Matrix API.

## Requirements
* iOS 7.0 or higher 
* ARC

## Installation
#### From CocoaPods
```ruby
pod 'LMDistanceCalculator'
```
#### Manually
* Drag the `LMDistanceCalculator` folder into your project.
* Add the `CoreLocation.framework` to your project.
* Add `#import "LMDistanceCalculator.h"` to the top of classes that will use it.

## Usage
#### Geometry Distance
```ObjC
CGFloat geometryDistance = [LMDistanceCalculator geometryDistanceFromOrigin:origin destination:destination];
NSLog(@"Geometry Distance: %f", geometryDistance);
```

#### Real Distance
```ObjC
[[LMDistanceCalculator sharedInstance] realDistanceFromOrigin:origin
                                                  destination:destination
                                            completionHandler:^(NSNumber * _Nullable result, NSError * _Nullable error) {
                                                if (result && !error) {
                                                    NSLog(@"Real Distance: %f", [result doubleValue]);
                                                }
                                            }];
```

See sample Xcode project in `/LMDistanceCalculatorDemo`

## License
LMDistanceCalculator is licensed under the terms of the MIT License.

## Contact
Minh Luong Nguyen
* https://github.com/lminhtm
* lminhtm@gmail.com
