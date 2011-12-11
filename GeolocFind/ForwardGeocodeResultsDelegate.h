//
//  ForwardGeocodeResultsDelegate.h
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPlacemark.h"

@class CLLocation;
@protocol ForwardGeocodeResultsDelegate

- (void)resultsDidChange:(NSMutableArray*)_results forSearchString:(NSString*)_string;
- (void)pushResultsView:(CustomPlacemark*)placemark;

@end


@protocol ForwardGeocodeDelegate

- (void)newLocation:(CustomPlacemark*)placemark;

@end