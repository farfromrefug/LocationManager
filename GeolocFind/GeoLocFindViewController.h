
#import <UIKit/UIKit.h>
#import "BSForwardGeocoder.h"
#import "GeoLocFindViewDelegate.h"
#import "GLMGeoViewController.h"

@interface GeoLocFindViewController : GLMGeoViewController
	<BSForwardGeocoderDelegate, ForwardGeocodeResultsDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar*	mSearchBar;
    BOOL            bSearchIsOn;
	
	
	BSForwardGeocoder*		mForwardGeocoder;
		
	id<GeoLocFindViewDelegate>	mDelegate;
}
@property (nonatomic, retain) UISearchBar* searchBar; 
//@property (nonatomic, assign) BOOL bSearchIsOn;


- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;
- (id)initWithDelegate:(id<GeoLocFindViewDelegate>)delegate;

//- (IBAction)exit;

//- (IBAction) displayModeChanged:(id)sender;

@end
