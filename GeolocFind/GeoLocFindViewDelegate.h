
#import <UIKit/UIKit.h>
#import "CustomPlacemark.h"

@class CLLocation;
@protocol ForwardGeocodeResultsDelegate

- (void)resultsDidChange:(NSMutableArray*)_results forSearchString:(NSString*)_string;
- (void)pushResultsView:(CustomPlacemark*)placemark;

@end


@protocol GeoLocFindViewDelegate

- (void)newLocation:(CustomPlacemark*)placemark;

@end