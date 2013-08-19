//
//  EPRouteController.h
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef enum {
	EPModeHeadsetToDevice,
	EPModeDeviceToHeadset,
	EPModeDeviceToDevice,
} EPMode;


@interface EPRouteController : NSObject <CBCentralManagerDelegate>
@property(nonatomic, assign) EPMode mode;

+ (EPRouteController *)sharedInstance;

- (void)startScanning;
- (void)stopScanning;
@end
