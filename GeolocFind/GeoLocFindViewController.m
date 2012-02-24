//
//  ForwardGeocodeResultsList.m
//  LaFourchetteV2
//
//  Created by Christophe on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GeoLocFindViewController.h"
#import "CustomPlacemark.h"
#import "CustomTitleView.h"
#import "LocationManager.h"

@implementation GeoLocFindViewController
@synthesize searchBar = mSearchBar;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return  [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<GeoLocFindViewDelegate>)dg
{
	self = [super initWithNibName:nil bundle:nil];
	if (self)
	{
		mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
        delegate = dg;
	}
	
	return self;
}

- (id) initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) 
    {
		mForwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
		delegate = [query objectForKey:kURLQueryDelegate];
        
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.navigationItem.titleView = [[[CustomTitleView alloc] initWithTitle:NSLocalizedString(@"Find an address",@"title for GeolocFindViewController")] autorelease];
    
    //Create the custom back button
    TTButton *backButtonView = [TTButton buttonWithStyle:@"toolbarModalCancelButton:" title:NSLocalizedString(@" Back", @"title for back button")]; 
    backButtonView.frame = CGRectMake(0, 0, 55, 32);
    [backButtonView addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];	
    
    mSearchBar.tintColor = [UIColor blackColor];
    [mSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    mSearchBar.delegate = self;
    bSearchIsOn = NO;
    
    
    
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

- (void)cleanup {
    [mForwardGeocoder release];
    mForwardGeocoder = nil;
    [mSearchBar release];
    mSearchBar = nil;
    delegate = nil;
}

- (void)viewDidUnload {
    [self cleanup];
    [super viewDidUnload];
}


- (void)dealloc
{
    [self cleanup];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView DataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *	  cellIdentifier  = @"StandardCell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] init] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	cell.textLabel.text = [((CustomPlacemark*)[mTableData objectAtIndex:indexPath.row]) title];
	
	return cell;
}

//- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return [mArrayPlacemarks count];
//}

#pragma mark -
#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
	CustomPlacemark* place =  (CustomPlacemark*)[mTableData objectAtIndex:indexPath.row];
	
//	CLLocation* location = [[[CLLocation alloc] initWithLatitude:place.mCoordinateRegion.center.latitude longitude:place.mCoordinateRegion.center.longitude] autorelease];
	
	[delegate newLocation:place];
    
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SearchBar Delegate Methods
- (void)enableCancelButton:(UISearchBar *)aSearchBar
{
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

-(void) refreshWithBSKmlResults:(NSArray*)results
{
    [mTableData release];
    mTableData = [[NSMutableArray alloc] init];
    for(BSKmlResult* place in [mForwardGeocoder results])
    {
        //createPlacemark
        CustomPlacemark* placemark = [[[CustomPlacemark alloc] initWithBSKmlResult:place] autorelease];
        
        if (placemark.title)
            [mTableData addObject:placemark];
        
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
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"alert_generic_error_title") message:NSLocalizedString(@"No result found, try precising your search", @"request_response__error_no_result_found") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
        [self refreshWithBSKmlResults:[mForwardGeocoder results]];
	}
	[self refreshAfterData];
}

#pragma mark -
#pragma mark ForwardGeocodeResults Delegate Method
- (void)resultsDidChange:(NSMutableArray*)_results forSearchString:(NSString*)_string
{
	mSearchBar.text = _string;
	
    [self refreshWithBSKmlResults:_results];
    [self refreshAfterData];
	//[self changeMapAnnotations];
}

- (void)pushResultsView:(CustomPlacemark*)placemark
{
	/*SearchResultsViewController* controller = [[SearchResultsViewController alloc] initWithResearch:mResearch];
	 [self.navigationController pushViewController:controller animated:YES];
	 [controller release];*/
	[delegate newLocation:placemark];
	
	[self goBack:nil];
}

@end
