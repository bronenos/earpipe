//
//  EPRouteController.h
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#define USE_PUBLIC_API 0

#import <Foundation/Foundation.h>
#if USE_PUBLIC_API
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <BluetoothManager/BluetoothDevice.h>
#endif


extern NSString * const EPRouteControllerDeviceDiscovered;

typedef enum {
	EPModeHeadsetToDevice,
	EPModeDeviceToHeadset,
	EPModeDeviceToDevice,
} EPMode;


@interface EPRouteController : NSObject <NSObject
#if USE_PUBLIC_API
, CBPeripheralManagerDelegate, CBPeripheralDelegate
#endif
>
@property(nonatomic, assign) EPMode mode;
@property(nonatomic, readonly) NSArray *foundDeviceList;

+ (EPRouteController *)sharedInstance;

- (void)startScanning;
- (void)stopScanning;
@end
