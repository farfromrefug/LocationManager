//
//  ForwardGeocodeResultsMap.h
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSForwardGeocoder.h"
#import "ForwardGeocodeResultsDelegate.h"
//#import "ForwardGeocodeResultsList.h"

#define kMapDefaultSpanDelta		0.005

@interface ForwardGeocodeResultsMap : UIViewController
	<MKMapViewDelegate>
{
	//IBOutlet UIButton*		mButtonList;
	//IBOutlet UISearchBar*	mSearchBar;
	IBOutlet MKMapView*		mMapView;
	
	NSArray*				mArrayResults;
	
	NSObject<ForwardGeocodeResultsDelegate>* mDelegate;
}

//- (id)initWithDelegate:(NSObject<ForwardGeocodeDelegate>*)_delegate;

- (id)initWithDelegate:(NSObject<ForwardGeocodeResultsDelegate>*)_delegate results:(NSArray*)_results;

- (void)refreshResults;

@end
