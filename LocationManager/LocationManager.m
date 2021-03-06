//
//  LocationManager.m
//  IziPass
//
//  Created by Olivier Bonal on 19/01/11.
//  Copyright 2011 C4M Prod. All rights reserved.
//

#import "LocationManager.h"
#import "GeoLocFindViewController.h"

@implementation LocationManager

@synthesize currentLocation = mCurrentLocation;
@synthesize currentPlacemark = mCurrentPlacemark;
@synthesize customLocation = mCustomLocation;
@synthesize customPlacemark = mCustomPlacemark;
//@synthesize reverseGeocoder;
@synthesize viewControllerURL = mViewControllerURL;

static LocationManager*	sharedInstance = nil;

+ (LocationManager *)sharedInstance
{
	if (sharedInstance == nil)
	{
		sharedInstance = [[LocationManager alloc] init];
	}
	
	return sharedInstance;
}



- (id) init {
    if ((self = [super init])) {
        mLocationManager = [[CLLocationManager alloc] init];
        mLocationManager.distanceFilter = 1000; // 1km
        mLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 100 m
        mLocationManager.delegate = self;
		mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
        mCurrentLocation = nil;
        mCustomLocation = nil;
        mCustomPlacemark = nil;
        mCurrentPlacemark = nil;
        mViewControllerURL = nil;
    }
    return self;
}

- (void)startSignificantChangeUpdates
{
    if (![CLLocationManager locationServicesEnabled])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Geolocalisation Necessary", @"title for alert on geoloc not possible") message:[NSString stringWithFormat:@"%@ %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"], NSLocalizedString(@"requires location service, please enable it in your settings", @"message for alert on geoloc not possible")]
                              
                              
                               delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserLocationTimestampStoreKey])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [prefs objectForKey:kUserLocationStoreKey ];
        CustomPlacemark* placemark = (CustomPlacemark *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        if (placemark)
        {
            self.currentPlacemark = placemark;
            CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude];
            self.currentLocation = newLocation;
            [newLocation release];
        }
    }
    
    [mLocationManager startUpdatingLocation];
}

- (void)stopSignificantChangeUpdates
{
    [mLocationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    bool needsReverseLocation = (self.currentPlacemark == nil);
    
    if (self.currentLocation.coordinate.latitude != newLocation.coordinate.latitude
        || self.currentLocation.coordinate.longitude != newLocation.coordinate.longitude)
    {
        needsReverseLocation = YES;
        self.currentLocation = newLocation;

        double timestamp = [self.currentLocation.timestamp timeIntervalSince1970];
    
        [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kUserLocationTimestampStoreKey];
    }
    
    if (needsReverseLocation)
        [self reverseGeocodeCurrentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"impossible to locate you! %@", [error localizedDescription]);
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Localisation impossible", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    self.currentLocation = nil;
}

#pragma mark -
#pragma mark Custom Methods

- (void) goToCurrentLocation
{
    NI_RELEASE_SAFELY(mCustomLocation);
    NI_RELEASE_SAFELY(mCustomPlacemark);
    NI_RELEASE_SAFELY(mCurrentLocation);
    NI_RELEASE_SAFELY(mCurrentPlacemark);
    [mLocationManager stopUpdatingLocation];
    [mLocationManager startUpdatingLocation];
}

- (void)reverseGeocodeCurrentLocation
{
    [mForwardGeocoder findLocationWithLat:self.currentLocation.coordinate.latitude andLong:self.currentLocation.coordinate.longitude];
}

#pragma mark -
#pragma mark LocationManager Delegate Methods

- (void)dealloc {
    [self stopSignificantChangeUpdates];
	mLocationManager.delegate = nil;
    [mLocationManager release];
    [mCurrentLocation release];
    [mCurrentPlacemark release];
    [mCustomPlacemark release];
//    [reverseGeocoder release];
    [mForwardGeocoder release];
	[super dealloc];
}

#pragma mark - Custom Location

-(void) chooseCustomLocationFromController:(UIViewController*) parentController usingController:(GeoLocFindViewController*)controller
{
    controller.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [parentController presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

-(void) chooseCustomLocationFromController:(UIViewController*) parentController
{

    GeoLocFindViewController* controller = [[GeoLocFindViewController alloc] initWithDelegate:self];

    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[parentController navigationController] presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [controller release];
}

#pragma mark - ForwardGeocodeDelegate Methods
- (void)newLocation:(CustomPlacemark*)placemark
{
    CLLocation* location = [[[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude] autorelease];
    self.customLocation = location;
    self.customPlacemark = placemark;
}  

#pragma mark -
#pragma mark BSForwardGeocoder Delegate Method
- (void)forwardGeocoderFoundLocation
{
	if ([[mForwardGeocoder results] count] == 0)
	{
        
        DLog(@"Could not get a placemark for you Lat,long current coordinates: %f, %f", mCurrentLocation.coordinate.latitude, mCurrentLocation.coordinate.longitude);
        self.currentPlacemark = nil;
	}
	else
	{
        if ([[mForwardGeocoder results] count] > 0)
        {
            BSKmlResult* result = [[mForwardGeocoder results] objectAtIndex:0];
            CustomPlacemark* newplacemark = [[CustomPlacemark alloc] initWithBSKmlResult:result];
            self.currentPlacemark = newplacemark;
            [newplacemark release];
        }

	}
	
}

@end
