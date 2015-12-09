//
//  DataController.m
//  TimerTests
//
//  Created by Janet Mason on 9/12/2015.
//  Copyright © 2015 Stephen Powell. All rights reserved.
//

#import "DataController.h"

@implementation DataController

-(NSArray<Workout*>*)getWorkoutData
{
    NSMutableArray<Workout*>* workouts = [[NSMutableArray alloc] initWithCapacity:1];
    
    // get url of file
    NSURL* fileLocation = [[NSBundle mainBundle] URLForResource: @"stage_durations" withExtension:@"txt"];
    
    // get data from the file
    NSString *fileContent = [NSString stringWithContentsOfURL: fileLocation encoding: NSUTF8StringEncoding error: nil];
    
    // Split data read from file
    NSArray* fileLines = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // Separate phase titles
    NSArray* titles = [[fileLines objectAtIndex:0] componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@","]];
    
    // Get phase time data for each workout session
    NSUInteger lineCount = [fileLines count];
    for (NSUInteger index = 1; index < lineCount; index++)
    {
        // extract the individual times for this workout session
        NSArray* times = [[fileLines objectAtIndex:index] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        // workout object to store current workout
        Workout* workout = [[Workout alloc] init];
        
        // get the title for this phase
        NSUInteger phases = [times count];
        for (NSUInteger i = 0; i < phases; i++)
        {
            NSString* phaseTitle;
            
            if ( i == 0 )
            {
                // Warm up
                phaseTitle = [NSString stringWithString:[titles objectAtIndex:0]];
            }
            else if ( i == phases - 1 )
            {
                // Cool Down
                phaseTitle = [NSString stringWithString:[titles objectAtIndex:([titles count] - 1)]];
            }
            else
            {
                // i % 2 = 0 == Run, i % 2 = 1 == Walk
                phaseTitle = [NSString stringWithString:[titles objectAtIndex: (i % 2) + 1]];
            }
            
            int phaseDuration = [[times objectAtIndex:i] intValue];
            [workout addWorkout:phaseTitle withTime:phaseDuration];
        }
        
        // Workout should have all phases added, store this workout
        [workouts addObject:workout];
    }
    
    NSLog(@"Data read from file");
    
    return [workouts copy];

}
@end