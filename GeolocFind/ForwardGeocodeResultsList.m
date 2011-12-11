//
//  ForwardGeocodeResultsList.m
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ForwardGeocodeResultsList.h"
#import "CustomPlacemark.h"
#import "CustomTitleView.h"
#import "AppDelegate.h"

#define kMapMode			1
#define kListMode			0

@implementation ForwardGeocodeResultsList
/*
- (id)initWithDelegate:(NSObject<ForwardGeocodeResultsDelegate>*)_delegate results:(NSArray*)_results;
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		// Custom initialization.
		mArrayResults = [_results retain];
		mArrayPlacemarks
		
		mDelegate = [_delegate retain];
	}
	return self;
}*/

- (id)initWithDelegate:(NSObject <ForwardGeocodeDelegate>*)_delegate
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		// Custom initialization.

	}
	
	return self;
}

- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) 
    {
        mArrayResults = [[NSMutableArray array] retain];
		mArrayPlacemarks = [[NSMutableArray array] retain];
		
		mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
		
		mDelegate = [query objectForKey:kURLQueryDelegate];
        
		mMapController = [[ForwardGeocodeResultsMap alloc] initWithDelegate:self results:mArrayPlacemarks];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.navigationItem.titleView = [[[CustomTitleView alloc] initWithTitle:@"Chercher une adresse"] autorelease];
    
    //Create the custom back button
    TTButton *backButtonView = [TTButton buttonWithStyle:@"toolbarModalCancelButton:" title:@"  Retour"]; 
    backButtonView.frame = CGRectMake(0, 0, 55, 32);
    [backButtonView addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
	
	CGRect frame = mMapController.view.frame;
	frame.origin.y = 88;
	mMapController.view.frame = frame;
	
	CALayer *layer = mMapController.view.layer;
	CATransform3D transform = layer.transform;
	transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
	
	mMapController.view.layer.transform = transform;
	
	mMapController.view.layer.doubleSided = NO;
	
	[self.view addSubview:mMapController.view];
	
	mTableView.layer.doubleSided = NO;
	
	[self.view bringSubviewToFront:mTableView];
}

- (void) goBack:(id)sender
{    
    // make sure you do this!
    // pop the controller
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [mSearchBar becomeFirstResponder];
//    
//    //set navgation bar image
//    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//    appDelegate.titleBarType = kBarDefault;
//    [self.navigationController.navigationBar setNeedsDisplay];

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)refreshResults
{
	[mTableView reloadData];
}

#pragma mark -
#pragma mark Memory Management Methods
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [mListButton release];
    mListButton = nil;
    [mMapButton release];
    mMapButton = nil;
    [mForwardGeocoder release];
    mForwardGeocoder = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	mTableView = nil;
}


- (void)dealloc
{
	[mTableView release];
	
	[mArrayResults release];
	
    [mForwardGeocoder release];
	
    [mListButton release];
    [mMapButton release];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView DataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *	  cellIdentifier  = @"StandardCell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] init] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	cell.textLabel.text = [((CustomPlacemark*)[mArrayPlacemarks objectAtIndex:indexPath.row]) title];
	
	return cell;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [mArrayPlacemarks count];
}

#pragma mark -
#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
	CustomPlacemark* place =  (CustomPlacemark*)[mArrayPlacemarks objectAtIndex:indexPath.row];
	
//	CLLocation* location = [[[CLLocation alloc] initWithLatitude:place.mCoordinateRegion.center.latitude longitude:place.mCoordinateRegion.center.longitude] autorelease];
	
	[mDelegate newLocation:place];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Actions
- (IBAction) displayModeChanged:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
	{
		NSInteger index = ((UIButton *)sender).tag;
		switch (index)
		{
			case kMapMode:
			{
                mListButton.enabled = YES;
                mMapButton.enabled = NO;
                
				CATransform3D transform;
				
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.5];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				
				transform = mMapController.view.layer.transform;
				transform = CATransform3DRotate(transform, M_PI, 0, -1, 0);
				mMapController.view.layer.transform = transform;
				
				transform = mTableView.layer.transform;
				transform = CATransform3DRotate(transform, M_PI, 0, -1, 0);
				mTableView.layer.transform = transform;
				
				//[mListController.view setHidden:YES];
				//[mListController.view.layer setHidden:YES];
				[self.view bringSubviewToFront:mMapController.view];
				
				[UIView commitAnimations];
				break;
			}
			case kListMode:
			{
                mListButton.enabled = NO;
                mMapButton.enabled = YES;
                
				CATransform3D transform;
				
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.5];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				
				transform = mMapController.view.layer.transform;
				transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
				mMapController.view.layer.transform = transform;
				
				transform = mTableView.layer.transform;
				transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
				mTableView.layer.transform = transform;
				
				//[mListController.view setHidden:NO];
				//[mListController.view.layer setHidden:NO];
				
				[self.view bringSubviewToFront:mTableView];
				
				[UIView commitAnimations];
				break;
			}
			default:
				break;
		}
	}
}

- (IBAction)exit
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SearchBar Delegate Methods
- (void)enableCancelButton:(UISearchBar *)aSearchBar
{
	DLog(@"");
	for (id subview in [aSearchBar subviews])
	{
		if ([subview isKindOfClass:[UIButton class]])
		{
			UIButton *cancelButton = subview;
			[cancelButton setEnabled:TRUE];
		}
	}  
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	[mSearchBar setShowsCancelButton:YES animated:YES];
	[self enableCancelButton:searchBar];
	
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	[mSearchBar setShowsCancelButton:NO animated:YES];
	
	return YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
//	DLog(@"");
	if ([mSearchBar.text length] > 0)
	{
		// Forward geocode!
		NSString* search = mSearchBar.text;
		
		if([search rangeOfString:@"France"].location == NSNotFound)
		{
			search = [NSString stringWithFormat:@"%@, %@", mSearchBar.text, @"France"];
		}
		
//		DLog(@" here");
		[mForwardGeocoder findLocation:search];
	}
	
	[searchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar 
{ 
	searchBar.text = @"";
	[searchBar resignFirstResponder];
}


#pragma mark -
#pragma mark Map Custom Methods
- (void)createPlacemarks
{
	for(BSKmlResult* place in mArrayResults)
	{
//		NSLog(@"%@", [place description]);
		// Add a placemark on the map
		CustomPlacemark* placemark = [[[CustomPlacemark alloc] initWithBSKmlResult:place] autorelease];
        
        if (placemark.title)
            [mArrayPlacemarks addObject:placemark];
		
		NSArray *countryName = [place findAddressComponent:@"country"];
		if([countryName count] > 0)
		{
//			NSLog(@"Country: %@", ((BSAddressComponent*)[countryName objectAtIndex:0]).longName );
		}
	}
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
		if (mArrayResults != nil)
		{
			[mArrayResults release];
			mArrayResults = nil;
		}
		
		[mArrayPlacemarks removeAllObjects];
		
		mArrayResults = [[[NSMutableArray alloc] initWithArray:[mForwardGeocoder results]] retain];
		
		[self createPlacemarks];
		[mTableView reloadData];
		//[self changeMapAnnotations];
	}
	
	[mMapController refreshResults];
}

#pragma mark -
#pragma mark ForwardGeocodeResults Delegate Method
- (void)resultsDidChange:(NSMutableArray*)_results forSearchString:(NSString*)_string
{
	mSearchBar.text = _string;
	
	if(mArrayResults != nil)
	{
		[mArrayResults release];
		mArrayResults = nil;
	}
	[mArrayPlacemarks removeAllObjects];
	
	mArrayResults = [_results retain];
	
	[self createPlacemarks];
	[mTableView reloadData];
	//[self changeMapAnnotations];
}

- (void)pushResultsView:(CustomPlacemark*)placemark
{
	/*SearchResultsViewController* controller = [[SearchResultsViewController alloc] initWithResearch:mResearch];
	 [self.navigationController pushViewController:controller animated:YES];
	 [controller release];*/
	[mDelegate newLocation:placemark];
	
	[self dismissModalViewControllerAnimated:YES];
}

@end
