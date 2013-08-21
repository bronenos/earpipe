//
//  EPRouteController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>
#import "EPRouteController.h"


NSString * const EPRouteControllerDeviceDiscovered = @"EPRouteControllerDeviceDiscovered";


@interface EPRouteController()
@property(nonatomic, strong) GKSession *gamekitSession;
@property(nonatomic, strong) CBPeripheralManager *bluetoothManager;

- (void)GK_startScanning;
- (void)BT_startScanning;
@end


@implementation EPRouteController
{
	dispatch_queue_t _bluetoothQueue;
	NSMutableArray *_foundDeviceList;
}

#pragma mark - Memory
- (id)init
{
	if ((self = [super init])) {
		_bluetoothQueue = dispatch_queue_create("bluetooth-manager", 0);
		self.bluetoothManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_bluetoothQueue];
		
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


#pragma mark - Public
- (NSArray *)foundDeviceList
{
	NSArray *ret = [NSArray arrayWithArray:_foundDeviceList];
	return ret;
}

- (void)startScanning
{
	switch (self.mode) {
		case EPRouteModeDeviceToDevice:
			[self GK_startScanning];
			break;
			
		case EPRouteModeHeadsetToDevice:
		case EPRouteModeDeviceToHeadset:
			[self BT_startScanning];
			break;
	}
}

- (void)stopScanning
{
}


#pragma mark - Internal
- (void)GK_startScanning
{
	GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
	picker.delegate = self;
	picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	[picker show];
}

- (void)BT_startScanning
{
	// ...
}


#pragma mark - GameKit delegate
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
	GKSession *session = [[GKSession alloc] initWithSessionID:@"BTSessionID"
												  displayName:nil
												  sessionMode:GKSessionModePeer];
	return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
	session.delegate = self;
	self.gamekitSession = session;
	
	picker.delegate = nil;
	[picker dismiss];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	if (state == GKPeerStateConnected) {
		[session setDataReceiveHandler:self withContext:NULL];
	}
	else {
		session.delegate = nil;
		self.gamekitSession = nil;
	}
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
	// ...
}


#pragma mark - Bluetooth Delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	const BOOL isPowered = (peripheral.state == CBPeripheralManagerStatePoweredOn);
	NSLog(@"%s -> is %@ powered with state %d", __FUNCTION__, (isPowered ? @"" : @"not"), peripheral.state);
	
	if (isPowered) {
//		NSArray *services = nil; // @[ [CBUUID UUIDWithString:@"180A"] ];
//		NSDictionary *options = nil; // @{ CBCentralManagerScanOptionAllowDuplicatesKey:@(NO) };
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

@end
