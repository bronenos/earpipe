//
//  EPRouteController.h
//  EarPipe
//
//  Created by Stan Potemkin on 8/18/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface EPRouteController : NSObject <CBCentralManagerDelegate>
- (void)startScanning;
- (void)stopScanning;
@end
