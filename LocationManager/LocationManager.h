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
#import "GeoLocFindViewDelegate.h"

#define kURLQueryDelegate               @"delegate"

#define kUserLocationTimestampStoreKey  @"User_location_timestamp"
#define kUserLocationStoreKey           @"User_location"

@class GeoLocFindViewController;
@interface LocationManager : NSObject <CLLocationManagerDelegate, BSForwardGeocoderDelegate, GeoLocFindViewDelegate> {
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

-(void) chooseCustomLocationFromController:(UIViewController*) parentController;
-(void) chooseCustomLocationFromController:(UIViewController*) parentController usingController:(GeoLocFindViewController*)controller;
@end
