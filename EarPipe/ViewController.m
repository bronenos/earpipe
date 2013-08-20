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
- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol;
@end


@implementation ViewController
#pragma mark - Memory
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[EPRouteController sharedInstance] startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[EPRouteController sharedInstance] stopScanning];
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
	NSArray *deviceList = [EPRouteController sharedInstance].foundDeviceList;
	BluetoothDevice *device = deviceList[indexPath.row];
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	cell.textLabel.text = device.name;
	cell.detailTextLabel.text = device.address;
	return cell;
}


#pragma mark - User Actions
- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol
{
	EPMode mode = (EPMode) self.pipeModeSwitcher.selectedSegmentIndex;
	[EPRouteController sharedInstance].mode = mode;
}


#pragma mark - Events
- (void)onDeviceDiscovered:(NSNotification *)note
{
	[self.deviceListTable reloadData];
}
@end
