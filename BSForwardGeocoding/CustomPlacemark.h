//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BSKmlResult.h"

@interface CustomPlacemark : NSObject
	<MKAnnotation>
{
//	CLLocationCoordinate2D	coordinate;
//	MKCoordinateRegion		mCoordinateRegion;
    NSString *mTitle;
    NSString *mSubtitle;
    NSString* mLocality;
    NSString* mThoroughfare;
    NSString* mSubThoroughfare;
    NSString* mSubLocality;
    NSString* mAdministrativeArea;
    NSString* mSubAdministrativeArea;
    NSString* mPostalCode;
    NSString* mCountry;

}

//@property (nonatomic, readonly) MKCoordinateRegion mCoordinateRegion;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
//@property (nonatomic, retain) NSString *mMessage;
// address dictionary properties
@property (nonatomic, retain) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
@property (nonatomic, retain) NSString *subThoroughfare; // eg. 1
@property (nonatomic, retain) NSString *locality; // city, eg. Cupertino
@property (nonatomic, retain) NSString *subLocality; // neighborhood, common name, eg. Mission District
@property (nonatomic, retain) NSString *administrativeArea; // state, eg. CA
@property (nonatomic, retain) NSString *subAdministrativeArea; // county, eg. Santa Clara
@property (nonatomic, retain) NSString *postalCode; // zip code, eg. 95014
@property (nonatomic, retain) NSString *country; // eg. United States

- (id)initWithBSKmlResult:(BSKmlResult*)_place;
- (id)initWithMKPlacemark:(MKPlacemark*)placemark;

@end
