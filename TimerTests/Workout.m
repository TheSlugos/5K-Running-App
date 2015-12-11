//
//  Workout.m
//  TimerTests
//
//  Created by Janet Mason on 23/11/2015.
//  Copyright © 2015 Stephen Powell. All rights reserved.
//

#import "Workout.h"

@implementation Workout

-(id)init {
    if (self = [super init])
    {
        _currentPhase = 0;
        _phases = [[NSMutableArray alloc] initWithCapacity:1];
        _completed = NO;
    }
    
    return self;
}

-(void) addWorkout:(NSString *)title withTime:(int)time
{
    Phase* newPhase = [[Phase alloc] init];
    
    newPhase.title = [NSString stringWithString:title];
    [newPhase setTime: time];
    
    [_phases addObject:newPhase];
}

- (NSString*) currentTitle
{
    return ((Phase*)[_phases objectAtIndex:_currentPhase]).title;
}

- (int) currentDuration
{
    return ((Phase*)[_phases objectAtIndex:_currentPhase]).time;
}

- (int) totalPhases
{
    return (int)[_phases count];
}

-(bool) hasEnded
{
    return _currentPhase == [_phases count];
}

@end
