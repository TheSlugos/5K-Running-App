//
//  DataController.h
//  TimerTests
//
//  Created by Janet Mason on 9/12/2015.
//  Copyright © 2015 Stephen Powell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workout.h"

@interface DataController : NSObject

-(NSArray<Workout*>*)getWorkoutData;
@end
