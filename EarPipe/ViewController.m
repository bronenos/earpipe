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
@property(nonatomic, strong) IBOutlet UISegmentedControl *pipeModeSwitcher;
- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol;
@end


@implementation ViewController
#pragma mark - View
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self onPipeModeChanged:nil];
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
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}


#pragma mark - User Actions
- (IBAction)onPipeModeChanged:(UISegmentedControl *)segcontrol
{
	EPMode mode = (EPMode) self.pipeModeSwitcher.selectedSegmentIndex;
	[EPRouteController sharedInstance].mode = mode;
}
@end
