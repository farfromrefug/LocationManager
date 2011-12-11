//
//  ForwardGeocodeResultsList.h
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSForwardGeocoder.h"
#import "ForwardGeocodeResultsDelegate.h"
#import "ForwardGeocodeResultsMap.h"

@interface ForwardGeocodeResultsList : UIViewController
	<BSForwardGeocoderDelegate, ForwardGeocodeResultsDelegate>
{
	IBOutlet UIButton*		mBackButton;
	IBOutlet UITableView*	mTableView;
	IBOutlet UISearchBar*	mSearchBar;
	
	NSMutableArray*			mArrayResults;
	NSMutableArray*			mArrayPlacemarks;
	
	BSForwardGeocoder*		mForwardGeocoder;
	
	ForwardGeocodeResultsMap* mMapController;
	
	id<ForwardGeocodeDelegate>	mDelegate;
    IBOutlet UIButton *mListButton;
    IBOutlet UIButton *mMapButton;
}

- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;

- (IBAction)exit;

- (IBAction) displayModeChanged:(id)sender;

@end
