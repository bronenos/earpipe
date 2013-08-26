//
//  ViewController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import "ViewController.h"
#import "EPRouteController.h"


@interface ViewController()
@property(nonatomic, strong) IBOutlet UIView *modeContainer;
@property(nonatomic, strong) IBOutlet UIButton *deviceModeButton;
@property(nonatomic, strong) IBOutlet UIButton *headsetModeButton;
@property(nonatomic, strong) IBOutletCollection(UIButton) NSArray *modeButtons;

@property(nonatomic, strong) IBOutlet UIView *deviceModeContainer;
@property(nonatomic, strong) IBOutlet UILabel *deviceName;
@property(nonatomic, strong) IBOutlet UITableView *deviceListTable;

- (IBAction)doSwitchToDeviceMode:(UIButton *)button;
- (IBAction)doSwitchToHeadsetMode:(UIButton *)button;
- (void)switchToMode:(EPRouteMode)mode andSelectButton:(UIButton *)button;

- (IBAction)doStartScan;
- (IBAction)doStopScan;
- (IBAction)doSendData;
@end


@implementation ViewController
#pragma mark - Memory
- (id)init
{
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(onDeviceDiscovered:)
													 name:EPRouteControllerDeviceDiscovered
												   object:nil];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.modeContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	UIImage *normalImage = [UIImage imageNamed:@"button_normal_80.png"];
	[self.deviceModeButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	[self.headsetModeButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	
	UIImage *pressedImage = [UIImage imageNamed:@"button_pressed_80.png"];
	[self.deviceModeButton setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	[self.headsetModeButton setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	
	UIImage *selectedImage = [UIImage imageNamed:@"button_pressed_80.png"];
	[self.deviceModeButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
	[self.headsetModeButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
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



#pragma mark  - Internal
- (void)switchToMode:(EPRouteMode)mode andSelectButton:(UIButton *)button
{
	[EPRouteController sharedInstance].mode = mode;
	
	[self.modeButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
		btn.selected = (btn == button);
	}];
}


#pragma mark - User Actions
- (IBAction)doSwitchToDeviceMode:(UIButton *)button
{
	[self switchToMode:EPRouteModeDeviceToDevice andSelectButton:button];
	[[EPRouteController sharedInstance] startScanning];
}

- (IBAction)doSwitchToHeadsetMode:(UIButton *)button
{
	[self switchToMode:EPRouteModeDeviceToHeadset andSelectButton:button];
}

- (IBAction)doStartScan
{
	[[EPRouteController sharedInstance] startScanning];
}

- (IBAction)doStopScan
{
	[[EPRouteController sharedInstance] stopScanning];
}

- (IBAction)doSendData
{
	[[EPRouteController sharedInstance] sendData];
}


#pragma mark - Events
- (void)onDeviceDiscovered:(NSNotification *)note
{
	[self.deviceListTable reloadData];
}
@end
