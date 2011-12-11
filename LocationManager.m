//
//  LocationManager.m
//  IziPass
//
//  Created by Olivier Bonal on 19/01/11.
//  Copyright 2011 C4M Prod. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize currentLocation = mCurrentLocation;
@synthesize currentPlacemark = mCurrentPlacemark;
@synthesize customLocation = mCustomLocation;
@synthesize customPlacemark = mCustomPlacemark;
@synthesize reverseGeocoder;
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Geolocalisation Necessaire", nil) message:@"IZI-Pass a besoin de votre localisation pour vous offrir les meilleurs offres!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

#pragma mark -
#pragma mark Custom Methods

- (void) goToCurrentLocation
{
    if (self.customLocation)
    {
        self.customLocation = nil;
        self.customPlacemark = nil;
    }
}

- (void)reverseGeocodeCurrentLocation
{
//    DLog(@"we need reverse geoloc for %f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
//    [self.reverseGeocoder cancel];
//    self.reverseGeocoder =
//    [[[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate] autorelease];
//    self.reverseGeocoder.delegate = s
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

//#pragma mark -
//#pragma mark MKReverseGeocoder Delegate
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
//{
//    NSString *errorMessage = [error localizedDescription];
//    DLog(@"reverseGeocoder ERROR: %@", errorMessage);
//    
////    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot obtain address."
////                                                        message:errorMessage
////                                                       delegate:nil
////                                              cancelButtonTitle:@"OK"
////                                              otherButtonTitles:nil];
////    [alertView show];
////    [alertView release];
//    
//    self.reverseGeocoder.delegate = nil;
////    [self.reverseGeocoder autorelease];
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
//{
//    CustomPlacemark* newplacemark = [[[CustomPlacemark alloc] initWithMKPlacemark:placemark] autorelease];
//    self.currentPlacemark = newplacemark;
//    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject: self.currentPlacemark];
//    [prefs setObject:myEncodedObject forKey:kUserLocationStoreKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

#pragma mark - Custom Location

-(void) chooseCustomLocation
{
    //around adress
    if (mViewControllerURL == nil)
    {
        DLog(@"viewControllerURL has not been set!");
    }
    else
    {
        NSMutableDictionary* query = [NSMutableDictionary dictionary];
        [query setValue:(id)self forKey:kURLQueryDelegate];
        IPOpenURLWithQuery(mViewControllerURL, query);
    }
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
	DLog(@"");
	if ([[mForwardGeocoder results] count] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erreur", @"alert_generic_error_title") message:NSLocalizedString(@"Aucun résultat n'a été trouvé. Essayez de préciser votre recherche.", @"request_response__error_no_result_found") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"alert_button_ok") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
        if ([[mForwardGeocoder results] count] > 0)
        {
            CustomPlacemark* newplacemark = [[[CustomPlacemark alloc] initWithBSKmlResult:[[mForwardGeocoder results] objectAtIndex:0]] autorelease];
            self.currentPlacemark = newplacemark;
        }

	}
	
}

@end