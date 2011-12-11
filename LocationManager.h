//
//  LocationManager.h
//  IziPass
//
//  Created by Olivier Bonal on 19/01/11.
//  Copyright 2011 C4M Prod. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomPlacemark.h"
#import "BSForwardGeocoder.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate, BSForwardGeocoderDelegate, ForwardGeocodeDelegate> {
    CLLocationManager*                  mLocationManager;
    CLLocation*                         mCurrentLocation;
    CustomPlacemark*                    mCurrentPlacemark;
//    MKReverseGeocoder*                reverseGeocoder;
    
    CLLocation*                         mCustomLocation;
    CustomPlacemark*                    mCustomPlacemark;
	BSForwardGeocoder*                  mForwardGeocoder;
    
    NSString*                           mViewControllerURL;
}

@property (nonatomic, retain) NSString* viewControllerURL;
@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) CLLocation* customLocation;
@property (nonatomic, retain) CustomPlacemark* currentPlacemark;
@property (nonatomic, retain) CustomPlacemark* customPlacemark;

+ (LocationManager *)sharedInstance;

- (void) goToCurrentLocation;
- (void) reverseGeocodeCurrentLocation;

- (void)startSignificantChangeUpdates;
- (void)stopSignificantChangeUpdates;

-(void) chooseCustomLocation;

@end
