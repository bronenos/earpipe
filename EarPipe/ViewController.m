//
//  ViewController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import "ViewController.h"
#import "EPRouteController.h"


@interface ViewController ()
@property(nonatomic, strong) IBOutlet UITableView *deviceListTable;
@property(nonatomic, strong) IBOutlet UISegmentedControl *pipeModeSwitcher;

- (EPRouteMode)routeModeFromSwitcherIndex:(NSInteger)index;

- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol;
- (IBAction)doStartScan;
- (IBAction)doStopScan;
@end


@implementation ViewController
#pragma mark - View
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self onPipeModeChanged:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onDeviceDiscovered:)
												 name:EPRouteControllerDeviceDiscovered
											   object:nil];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//	[super viewDidAppear:animated];
//	[[EPRouteController sharedInstance] startScanning];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//	[[EPRouteController sharedInstance] stopScanning];
//}


#pragma mark - Internal
- (EPRouteMode)routeModeFromSwitcherIndex:(NSInteger)index
{
	EPRouteMode modes[] = {
		EPRouteModeDeviceToDevice,
		EPRouteModeHeadsetToDevice,
		EPRouteModeDeviceToHeadset
	};
	
	return modes[index];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger ret = [EPRouteController sharedInstance].foundDeviceList.count;
	return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	return cell;
}


#pragma mark - User Actions
- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol
{
	[[EPRouteController sharedInstance] stopScanning];
	[EPRouteController sharedInstance].mode = [self routeModeFromSwitcherIndex:segcontrol.selectedSegmentIndex];
}

- (IBAction)doStartScan
{
	[[EPRouteController sharedInstance] startScanning];
}

- (IBAction)doStopScan
{
	[[EPRouteController sharedInstance] stopScanning];
}


#pragma mark - Events
- (void)onDeviceDiscovered:(NSNotification *)note
{
	[self.deviceListTable reloadData];
}
@end
