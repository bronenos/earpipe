//
//  EPRouteController.h
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#define USE_PUBLIC_API 0

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <GameKit/GameKit.h>


extern NSString * const EPRouteControllerDeviceDiscovered;

typedef enum {
	EPRouteModeDeviceToDevice,
	EPRouteModeHeadsetToDevice,
	EPRouteModeDeviceToHeadset,
} EPRouteMode;


@interface EPRouteController : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>
@property(nonatomic, assign) EPRouteMode mode;
@property(nonatomic, readonly) NSArray *foundDeviceList;

+ (EPRouteController *)sharedInstance;

- (void)startScanning;
- (void)stopScanning;
@end
