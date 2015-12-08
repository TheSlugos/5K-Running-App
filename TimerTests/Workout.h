//
//  Workout.h
//  TimerTests
//
//  Created by Janet Mason on 23/11/2015.
//  Copyright © 2015 Stephen Powell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Phase.h"

@interface Workout : NSObject

@property (strong,nonatomic) NSMutableArray* phases;
@property (nonatomic) int currentPhase;

- (void)addWorkout: (NSString*)title withTime: (int)time;
- (NSString*) currentTitle;
- (int) currentDuration;
- (int) totalPhases;
- (bool) hasEnded;
@end
