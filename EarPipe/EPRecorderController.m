//
//  EPRecorderController.m
//  EarPipe
//
//  Created by Stan Potemkin on 8/23/13.
//  Copyright (c) 2013 Stan Potemkin. All rights reserved.
//

#import <AudioToolbox/AudioSession.h>
#import "EPRecorderController.h"

// See AudioQueueNewOutput

@implementation EPRecorderController
#pragma mark - Memory
- (id)init
{
	if ((self = [super init])) {
		// ...
	}
	
	return self;
}

+ (EPRecorderController *)sharedInstance
{
	static id __instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		__instance = [self new];
	});
	
	return __instance;
}
@end
