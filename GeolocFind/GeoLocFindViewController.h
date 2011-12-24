
#import <UIKit/UIKit.h>
#import "BSForwardGeocoder.h"
#import "GeoLocFindViewDelegate.h"
#import "GLMViewController.h"

@interface GeoLocFindViewController : GLMViewController
	<BSForwardGeocoderDelegate, ForwardGeocodeResultsDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar*	mSearchBar;
    BOOL            bSearchIsOn;
	
	
	BSForwardGeocoder*		mForwardGeocoder;
		
	id<GeoLocFindViewDelegate>	delegate;
}
@property (nonatomic, retain) UISearchBar* searchBar; 
@property (nonatomic, assign) id<GeoLocFindViewDelegate>	delegate;


- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;
- (id)initWithDelegate:(id<GeoLocFindViewDelegate>)delegate;

//- (IBAction)exit;

//- (IBAction) displayModeChanged:(id)sender;

@end
