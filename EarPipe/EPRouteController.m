//
//  EPRouteController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>
#import "EPRouteController.h"


@interface EPRouteController()
@property(nonatomic, strong) CBCentralManager *bluetoothManager;
@end


@implementation EPRouteController
{
	dispatch_queue_t _bluetoothQueue;
}

#pragma mark - Memory
- (id)init
{
	if ((self = [super init])) {
		_bluetoothQueue = dispatch_queue_create("bluetooth-manager", 0);
		self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:_bluetoothQueue];
	}
	
	return self;
}


#pragma mark - Public
- (void)startScanning
{
	[self.bluetoothManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanning
{
	[self.bluetoothManager stopScan];
}


#pragma mark - Bluetooth Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	const BOOL isPowered = (central.state == CBCentralManagerStatePoweredOn);
	NSLog(@"%s -> is powered on %d", __FUNCTION__, isPowered);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"%s -> discovered %@", __FUNCTION__, peripheral.name);
}


@end
