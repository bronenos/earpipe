//
//  EPRouteController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>
#import <BluetoothManager/BluetoothManager.h>
#import "EPRouteController.h"


NSString * const EPRouteControllerDeviceDiscovered = @"EPRouteControllerDeviceDiscovered";


@interface EPRouteController()
#if USE_PUBLIC_API
@property(nonatomic, strong) CBPeripheralManager *bluetoothManager;
#else
@property(nonatomic, strong) BluetoothManager *bluetoothManager;
#endif

- (void)signForNotifications;
@end


@implementation EPRouteController
{
#	if USE_PUBLIC_API
	dispatch_queue_t _bluetoothQueue;
#	endif
	NSMutableArray *_foundDeviceList;
}

#pragma mark - Memory
- (id)init
{
	if ((self = [super init])) {
#		if USE_PUBLIC_API
		_bluetoothQueue = dispatch_queue_create("bluetooth-manager", 0);
		self.bluetoothManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_bluetoothQueue];
#		else
		self.bluetoothManager = [BluetoothManager sharedInstance];
		[self signForNotifications];
#		endif
		
		_foundDeviceList = [NSMutableArray new];
	}
	
	return self;
}

+ (EPRouteController *)sharedInstance
{
	static id __instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		__instance = [self new];
	});
	
	return __instance;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public
- (NSArray *)foundDeviceList
{
	NSArray *ret = [NSArray arrayWithArray:_foundDeviceList];
	return ret;
}

- (void)startScanning
{
#	if USE_PUBLIC_API
#	else
	if (self.bluetoothManager.powered == NO) {
		[self.bluetoothManager setPowered:YES];
	}
	
	if (self.bluetoothManager.enabled == NO) {
		[self.bluetoothManager setEnabled:YES];
	}
#	endif
}

- (void)stopScanning
{
#	if USE_PUBLIC_API
	[self.bluetoothManager stopAdvertising];
#	else
	[self.bluetoothManager setDeviceScanningEnabled:NO];
#	endif
}


#pragma mark - Internal
static void cb_anyNoteCatcher(CFNotificationCenterRef center,
						   void *observer,
						   CFStringRef name,
						   const void *object,
						   CFDictionaryRef userInfo) {
    NSLog(@"Notification Name:%@ Data:%@", name, userInfo);
}

- (void)signForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onBluetoothAvailabilityChanged:)
												 name:@"BluetoothAvailabilityChangedNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onBluetoothDeviceDiscovered:)
												 name:@"BluetoothDeviceDiscoveredNotification"
											   object:nil];
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    NULL,
                                    cb_anyNoteCatcher,
                                    NULL,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}


#pragma mark - Bluetooth Delegate
#if USE_PUBLIC_API
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	const BOOL isPowered = (peripheral.state == CBPeripheralManagerStatePoweredOn);
	NSLog(@"%s -> is %@ powered with state %d", __FUNCTION__, (isPowered ? @"" : @"not"), peripheral.state);
	
	if (isPowered) {
		NSArray *services = nil; // @[ [CBUUID UUIDWithString:@"180A"] ];
		NSDictionary *options = nil; // @{ CBCentralManagerScanOptionAllowDuplicatesKey:@(NO) };
		[self.bluetoothManager startAdvertising:nil];
	}
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
	NSLog(@"%s -> %@", __FUNCTION__, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSLog(@"%s -> %@", __FUNCTION__, error);
}
#else
- (void)onBluetoothAvailabilityChanged:(NSNotification *)note
{
	if (self.bluetoothManager.enabled) {
		[_foundDeviceList removeAllObjects];
		
		[self.bluetoothManager setDeviceScanningEnabled:YES];
		[self.bluetoothManager scanForServices:0xFFFFFFFF];
	}
}

- (void)onBluetoothDeviceDiscovered:(NSNotification *)note
{
	BluetoothDevice *device = (id) note.object;
	[_foundDeviceList addObject:device];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:EPRouteControllerDeviceDiscovered object:self];
}
#endif

@end
