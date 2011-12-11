//
//  ForwardGeocodeResultsMap.m
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ForwardGeocodeResultsMap.h"
#import "ForwardGeocodeResultsList.h"
#import "BSKmlResult.h"
#import "CustomPlacemark.h"
#import "AppDelegate.h"


@interface ForwardGeocodeResultsMap (Private)

- (void)createPlacemarks;
- (void)changeMapAnnotations;

@end

@implementation ForwardGeocodeResultsMap
/*
- (id)initWithDelegate:(NSObject<ForwardGeocodeDelegate>*)_delegate
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		// Custom initialization.
		mArrayResults = [[NSMutableArray array] retain];
		mArrayPlacemarks = [[NSMutableArray array] retain];
		
		mForwardGeocoder = [BSForwardGeocoder alloc];
		[mForwardGeocoder initWithDelegate:self];
		
		mDelegate = [_delegate retain];
		
		//mListController = [[ForwardGeocodeResultsList alloc] initWithDelegate:self results:mArrayPlacemarks];
	}
	return self;
}
*/
- (id)initWithDelegate:(NSObject<ForwardGeocodeResultsDelegate>*)_delegate results:(NSArray*)_results
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		// Custom initialization.
		//mArrayResults = [_results retain];
		mArrayResults = [_results retain];
		
		mDelegate = [_delegate retain];
	}
	return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CLLocationCoordinate2D franceCenterCoordinate;
	franceCenterCoordinate.latitude = kFranceCenterLatitude;
	franceCenterCoordinate.longitude = kFranceCenterLongitude;
	
	MKCoordinateRegion region = MKCoordinateRegionMake(franceCenterCoordinate, MKCoordinateSpanMake(kFranceCenterSpan, kFranceCenterSpan));
	
	[mMapView setRegion:region];
	
	//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:mButtonList] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    
//	//set navgation bar image
//    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//    appDelegate.titleBarType = kBarDefault;
//    [self.navigationController.navigationBar setNeedsDisplay];

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Memory Management Methods
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	//mButtonList = nil;
	//mSearchBar = nil;
	mMapView = nil;
}


- (void)dealloc
{
	//[mButtonList release];
	//[mSearchBar release];
	[mMapView release];
	
	[mArrayResults release];
	//[mArrayPlacemarks release];
	//[mPopToViewController release];
	//[mForwardGeocoder release];
	
	//[mListController release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Custom Map Method
- (void)changeMapAnnotations
{
	MKCoordinateRegion region;
	CLLocationCoordinate2D maxCoordinate;
	CLLocationCoordinate2D minCoordinate;
	CLLocationCoordinate2D newCoordinate;
	
	maxCoordinate.latitude = -1000; maxCoordinate.longitude = -1000;
	minCoordinate.latitude = 1000; minCoordinate.longitude = 1000;
	
	// remove all current annotations
	NSMutableArray* annotationToRemove = [NSMutableArray arrayWithCapacity:0];
	for (NSObject<MKAnnotation>* annotation in [mMapView annotations])
	{
		if ([annotation isKindOfClass:[CustomPlacemark class]])
		{
			[annotationToRemove addObject:annotation];
		}
	}
	[mMapView removeAnnotations:annotationToRemove];
	
	if ([mArrayResults count] == 0)
	{
		return;
	}
	
	// Center/zoom the map on results
	NSInteger i = 0;
	
	for	(CustomPlacemark *placemark in mArrayResults)
	{
		if (![[mMapView annotations] containsObject:placemark])
		{
			[mMapView addAnnotation:placemark];
			i++;
			
			if ([placemark coordinate].latitude > maxCoordinate.latitude)
			{
				maxCoordinate.latitude = [placemark coordinate].latitude;
			}
			if ([placemark coordinate].longitude > maxCoordinate.longitude)
			{
				maxCoordinate.longitude = [placemark coordinate].longitude;
			}
			if ([placemark coordinate].latitude < minCoordinate.latitude)
			{
				minCoordinate.latitude = [placemark coordinate].latitude;
			}
			if ([placemark coordinate].longitude < minCoordinate.longitude)
			{
				minCoordinate.longitude = [placemark coordinate].longitude;
			}
		}
	}
	
	// If function has been called when updating from map, do not re-center
	if ([[mMapView annotations] count] == 0)
	{
		return;
	}
	
	newCoordinate.latitude = minCoordinate.latitude + (maxCoordinate.latitude - minCoordinate.latitude)/2.;
	newCoordinate.longitude = minCoordinate.longitude + (maxCoordinate.longitude - minCoordinate.longitude)/2.;
	region.center = newCoordinate;
	
	if (i == 1)
	{
		region.span = MKCoordinateSpanMake(kMapDefaultSpanDelta, kMapDefaultSpanDelta);
	}
	else
	{
		region.span = MKCoordinateSpanMake((maxCoordinate.latitude - minCoordinate.latitude)*1.3, (maxCoordinate.longitude - minCoordinate.longitude)*1.3);
	}
	[mMapView setRegion:region animated:NO];
}

- (void)refreshResults
{
	[self changeMapAnnotations];
}

#pragma mark -
#pragma mark Map View Delegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString  * annotationViewId = @"AnnotationView";
	MKPinAnnotationView * annotationView = nil;
	
	annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewId];
	
	if( [annotation isKindOfClass:[CustomPlacemark class]])
	{
		if (annotationView == nil) 
		{
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewId] autorelease];
		}
		
		annotationView.canShowCallout = YES;
		
		UIButton* pickUpButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[pickUpButton setFrame:CGRectMake(0, 0, 30, 30) ];
		annotationView.rightCalloutAccessoryView = pickUpButton;
		
		annotationView.pinColor = MKPinAnnotationColorGreen;
		
		[annotationView setCenterOffset:CGPointMake(0, -([annotationView frame].size.height)/2.0)];
	}
	else
	{
		annotationView.pinColor = MKPinAnnotationColorPurple;
	}
	
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	//mResearch.mGPSLocalization = [((CustomPlacemark*)view.annotation) coordinate];
	
	/*SearchResultsViewController* controller = [[SearchResultsViewController alloc] initWithResearch:mResearch];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];*/
//	CustomPlacemark* place = ((CustomPlacemark*)[view annotation]);
	
//	CLLocation* location = [[[CLLocation alloc] initWithLatitude:place.mCoordinateRegion.center.latitude longitude:place.mCoordinateRegion.center.longitude] autorelease];
	
	[mDelegate pushResultsView:((CustomPlacemark*)[view annotation])];
	
	[self dismissModalViewControllerAnimated:YES];
}



@end
