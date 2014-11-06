//
//  EPRouteController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EPRouteController.h"


NSString * const EPRouteControllerDeviceDiscovered = @"EPRouteControllerDeviceDiscovered";


@interface EPRouteController() <GKVoiceChatClient>
@property(nonatomic, strong) GKSession *gamekitSession;
@property(nonatomic, strong) CBPeripheralManager *bluetoothManager;

- (void)GK_startScanning;
- (void)GK_stopScanning;

- (void)BT_startScanning;
- (void)BT_stopScanning;
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
	switch (self.mode) {
		case EPRouteModeDeviceToDevice:
			[self GK_stopScanning];
			break;
			
		case EPRouteModeHeadsetToDevice:
		case EPRouteModeDeviceToHeadset:
			[self BT_stopScanning];
			break;
	}
}

- (void)sendData
{
	if (self.mode != EPRouteModeDeviceToDevice) {
		return;
	}
	
	if (self.gamekitSession == nil) {
		return;
	}
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *error;
	
	if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error setting the AV play/record category: %@", [error localizedDescription]);
//		showAlert(@"Could not establish an Audio Connection. Sorry!");
		return;
	}
	
	if (![audioSession setActive: YES error: &error])
	{
		NSLog(@"Error activating the audio session: %@", [error localizedDescription]);
//		showAlert(@"Could not establish an Audio Connection. Sorry!");
		return;
	
	
	}
	
	GKVoiceChatService *chatService = [GKVoiceChatService defaultVoiceChatService];
	if (chatService) {
		NSArray *peers = [self.gamekitSession peersWithConnectionState:GKPeerStateConnected];
		
		chatService.client = self;
		[chatService startVoiceChatWithParticipantID:[peers firstObject] error:nil];
		[GKVoiceChatService defaultVoiceChatService].remoteParticipantVolume = 0;
	}
}


#pragma mark - Internal
- (void)GK_startScanning
{
	[GKVoiceChatService defaultVoiceChatService].client = self;
	
	
	GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
	picker.delegate = self;
	picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	[picker show];
}

- (void)GK_stopScanning
{
	[self.gamekitSession disconnectFromAllPeers];
	self.gamekitSession.delegate = nil;
	self.gamekitSession = nil;
}

- (void)BT_startScanning
{
	// ...
}

- (void)BT_stopScanning
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

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
	picker.delegate = nil;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
	self.gamekitSession = session;
	self.gamekitSession.delegate = self;
	[self.gamekitSession setDataReceiveHandler:self withContext:NULL];
	
	picker.delegate = nil;
	[picker dismiss];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	if (state == GKPeerStateDisconnected) {
		self.gamekitSession.delegate = nil;
		self.gamekitSession = nil;
	}
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
	char t = ((char*)data.bytes)[0];
	NSData *d = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
	
	switch (t) {
		case 0x00:
			[[GKVoiceChatService defaultVoiceChatService] receivedData:d fromParticipantID:peer];
			break;
			
		case 0x01:
			[[GKVoiceChatService defaultVoiceChatService] receivedRealTimeData:d fromParticipantID:peer];
			break;
	}
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



- (NSString *)participantID
{
	return self.gamekitSession.peerID;
}


- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didReceiveInvitationFromParticipantID:(NSString *)participantID callID:(NSInteger)callID
{
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
	
	AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideAudioRoute,
							 sizeof (audioRouteOverride),
							 &audioRouteOverride
							 )
	
	;	[[GKVoiceChatService defaultVoiceChatService] acceptCallID:callID error:nil];
	[GKVoiceChatService defaultVoiceChatService].remoteParticipantVolume = 1.0;
}


- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
	char b = 0x00;
	
	NSMutableData *d = [NSMutableData data];
	[d appendBytes:&b length:sizeof(b)];
	[d appendData:data];
	[self.gamekitSession sendData:d toPeers:@[participantID] withDataMode:GKSendDataReliable error:nil];
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendRealTimeData:(NSData *)data toParticipantID:(NSString *)participantID
{
	char b = 0x01;
	
	NSMutableData *d = [NSMutableData data];
	[d appendBytes:&b length:sizeof(b)];
	[d appendData:data];
	[self.gamekitSession sendData:d toPeers:@[participantID] withDataMode:GKSendDataUnreliable error:nil];
}

@end
