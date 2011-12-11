//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "CustomPlacemark.h"
#import "BSKmlResult.h"


@implementation CustomPlacemark
@synthesize title = mTitle;
@synthesize subtitle = mSubtitle;
@synthesize locality = mLocality;
@synthesize thoroughfare = mThoroughfare;
@synthesize subThoroughfare = mSubThoroughfare;
@synthesize subLocality = mSubLocality;
@synthesize administrativeArea = mAdministrativeArea;
@synthesize subAdministrativeArea = mSubAdministrativeArea;
@synthesize postalCode = mPostalCode;
@synthesize country = mCountry;
@synthesize coordinate;

- (id)initWithBSKmlResult:(BSKmlResult*)_place
{
	self = [super init];
	if (self)
	{
		coordinate = _place.coordinate;
		
		NSArray* arrayAddressComp;
        
		arrayAddressComp = [_place findAddressComponent:@"locality"];
		if ([arrayAddressComp count] > 0)
		{
			self.locality = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
		}
        
        arrayAddressComp = [_place findAddressComponent:@"sublocality"];
		if ([arrayAddressComp count] > 0)
		{
			self.subLocality = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
		}
        
        arrayAddressComp = [_place findAddressComponent:@"administrative_area_level_1"];
		if ([arrayAddressComp count] > 0)
		{
			self.administrativeArea = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
		}
        
        arrayAddressComp = [_place findAddressComponent:@"administrative_area_level_2"];
		if ([arrayAddressComp count] > 0)
		{
            self.subAdministrativeArea = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
			self.postalCode = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) shortName];
		}
        
		arrayAddressComp = [_place findAddressComponent:@"country"];
		if ([arrayAddressComp count] > 0)
		{
			self.country = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
		}
        
        arrayAddressComp = [_place findAddressComponent:@"postal_code"];
		if ([arrayAddressComp count] > 0)
		{
			self.postalCode = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
		}
        
        arrayAddressComp = [_place findAddressComponent:@"street_address"];
		if ([arrayAddressComp count] > 0)
		{
			self.thoroughfare = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
            
		}
        arrayAddressComp = [_place findAddressComponent:@"street_number"];
		if ([arrayAddressComp count] > 0)
		{
			self.subThoroughfare = [((BSAddressComponent*)[arrayAddressComp objectAtIndex:0]) longName];
            
		}
		if (mLocality && mSubAdministrativeArea)
        {
            mTitle = [[NSString stringWithFormat:@"%@, %@",
                  mLocality, mSubAdministrativeArea] retain];
        }
        if (mLocality && mPostalCode)
        {
            mSubtitle = [[NSString stringWithFormat:@"%@ %@",
                      mLocality, mPostalCode] retain];
        }
        if (mThoroughfare)
        {
            mSubtitle = [[NSString stringWithFormat:@"%@ ,%@",
                          mThoroughfare, mSubtitle] retain];
        }
        
		
		DLog(@"initialized");
	}
	
	return self;
}

- (id)initWithMKPlacemark:(MKPlacemark*)placemark
{
	self = [super init];
    if (self)
	{
		coordinate = placemark.coordinate;
		self.locality = placemark.locality;
		self.subLocality = placemark.subLocality;
		self.administrativeArea = placemark.administrativeArea;
		self.subAdministrativeArea = placemark.subAdministrativeArea;
		self.country = placemark.country;
		self.postalCode = placemark.postalCode;
		self.thoroughfare = placemark.thoroughfare;
		self.subThoroughfare = placemark.subThoroughfare;
            
		
		mTitle = [[NSString stringWithFormat:@"%@, %@",
                  mLocality, mSubAdministrativeArea] retain];
        mSubtitle = [[NSString stringWithFormat:@"%@, %@ %@",
                     mThoroughfare, mPostalCode, mLocality] retain];
    }
	
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"coordinate:(%f %f) title:%@ message:%@", coordinate.latitude, coordinate.longitude, mTitle, mSubtitle];
}

- (void)dealloc {
	[mTitle release];
	[mLocality release];
	[mSubLocality release];
	[mSubtitle release];
	[mSubThoroughfare release];
	[mSubLocality release];
	[mAdministrativeArea release];
	[mSubAdministrativeArea release];
	[mPostalCode release];
	[mCountry release];
	[super dealloc];
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.subAdministrativeArea forKey:@"subAdministrativeArea"];
    [encoder encodeObject:self.subThoroughfare forKey:@"subThoroughfare"];
    [encoder encodeObject:self.subtitle forKey:@"subtitle"];
    [encoder encodeObject:self.locality forKey:@"locality"];
    [encoder encodeObject:self.postalCode forKey:@"postalCode"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.subLocality forKey:@"subLocality"];
    [encoder encodeObject:self.thoroughfare forKey:@"thoroughfare"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        coordinate.latitude = [[decoder decodeObjectForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[decoder decodeObjectForKey:@"longitude"] doubleValue];
		self.locality = [decoder decodeObjectForKey:@"locality"];
		self.subLocality = [decoder decodeObjectForKey:@"subLocality"];
		self.administrativeArea = [decoder decodeObjectForKey:@"administrativeArea"];
		self.subAdministrativeArea = [decoder decodeObjectForKey:@"subAdministrativeArea"];
		self.country = [decoder decodeObjectForKey:@"country"];
		self.postalCode = [decoder decodeObjectForKey:@"postalCode"];
		self.thoroughfare = [decoder decodeObjectForKey:@"thoroughfare"];
		self.subThoroughfare = [decoder decodeObjectForKey:@"subThoroughfare"];
		
		mTitle = [[decoder decodeObjectForKey:@"title"] retain];
        mSubtitle = [[decoder decodeObjectForKey:@"subtitle"] retain];
    }
    return self;
}
@end
