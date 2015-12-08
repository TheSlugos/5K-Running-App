//
//  ViewController.m
//  TimerTests
//
//  Created by Janet Mason on 19/07/2015.
//  Copyright (c) 2015 Stephen Powell. All rights reserved.
//

@import AudioToolbox;

#import "ViewController.h"
#import "Workout.h"

@interface ViewController ()
// UI Elements
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UIButton *btnTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UILabel *lblStage;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalTime;
@property (nonatomic) bool timerStarted;

// the 1 sec timer
@property (weak,nonatomic) NSTimer *myTimer;

// time
@property (nonatomic) int timerSeconds;
@property (nonatomic) int totalTimeSeconds;

// ticking sound
@property (nonatomic) SystemSoundID sndTick;
@property (nonatomic) SystemSoundID sndBuzzer;

// Workouts
@property (strong, nonatomic) NSMutableArray<Workout*>* workouts;

// Today's workout
@property (nonatomic) int thisWorkoutIndex;
@property (strong, nonatomic) Workout* thisWorkout;

// methods
- (IBAction)btnTimer_Click:(UIButton *)sender;
- (IBAction)btnStop_Click:(UIButton *)sender;
-(void)updateTimerLabel:(NSTimer*)theTimer;
//-(void)setTimerText;
-(void)resetTimer;
-(void)readExerciseData;
-(NSString*)timeAsString:(int)time;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create workouts
    _workouts = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Read exercise data from the file
    [self readExerciseData];
    
    // setup sounds
    NSString* sndPath = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
    NSURL* sndURL = [NSURL fileURLWithPath:sndPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sndURL,  &_sndTick);
    
    sndPath = [[NSBundle mainBundle] pathForResource:@"buzzer" ofType:@"wav"];
    sndURL = [NSURL fileURLWithPath:sndPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sndURL, &_sndBuzzer);
    
    // set the current workout
    // this should come from the workout selected in the list view that
    // needs to be implemented
    _thisWorkoutIndex = 0;
    _thisWorkout = [_workouts objectAtIndex:_thisWorkoutIndex];
    
    [self resetTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetTimer {
    // timer not going
    _timerStarted = NO;
    
    // set initial stage of exercise
    _thisWorkout.currentPhase = 0;
    
    // setup the timer seconds
    _timerSeconds = [_thisWorkout currentDuration];
    _totalTimeSeconds = 0;
    
    // setup the labels
    _lblTimer.text = [self timeAsString:_timerSeconds];
    _lblTotalTime.text = [self timeAsString:_totalTimeSeconds];
    
    _lblTitle.text = [_thisWorkout currentTitle];
    
    [_lblTimer setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    _lblStage.text = [NSString stringWithFormat:@"Stage %d/%lu", _thisWorkout.currentPhase + 1, (unsigned long)[_thisWorkout totalPhases]];
    
    // invalidate timer
    [_myTimer invalidate];
    
    _btnTimer.hidden = NO;
}

- (IBAction)btnTimer_Click:(UIButton *)sender {
    
    if ( [[_btnTimer titleForState:UIControlStateNormal] isEqualToString:@"Start"])
    {
        _timerStarted = YES;
        // setup repeating timer
        
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector( updateTimerLabel:) userInfo:nil repeats:YES];
        
        // save reference to timer
        _myTimer = timer;
        
        [_btnTimer setTitle:@"Pause" forState:UIControlStateNormal];
        
        // stop phone from sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    else if ([[_btnTimer titleForState:UIControlStateNormal] isEqualToString:@"Pause"])
    {
        // need to pause the timer
        
        // cancel the timer
        [_myTimer invalidate];
        _myTimer = nil;
        
        [_btnTimer setTitle:@"Resume" forState:UIControlStateNormal];
    }
    else
    {
        // Resume
        
        // Reset the timer
        // invalidate existing timers
        [_myTimer invalidate];
        
        // setup repeating timer
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector( updateTimerLabel:) userInfo:nil repeats:YES];
        
        // save reference to timer
        _myTimer = timer;
        
        [_btnTimer setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)btnStop_Click:(UIButton *)sender {
    [self resetTimer];
    [_btnTimer setTitle: @"Start" forState:UIControlStateNormal];
    // allow phone to sleep
    // allow phone to sleep
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)updateTimerLabel:(NSTimer*)theTimer{
    // take off one second
    _timerSeconds--;
    
    // add one to total
    _totalTimeSeconds++;
    
    if (_timerSeconds == 0 )
    {
        // play buzzer
        AudioServicesPlaySystemSound(_sndBuzzer);
        
        // move to next stage
        _thisWorkout.currentPhase++;
        
        if ( [_thisWorkout hasEnded] )
        {
            // end exercise
            [_lblTimer setTextColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
        
            _timerStarted = NO;
        
            [_myTimer invalidate];
            _myTimer = nil;
            
            _lblTitle.text = @"Well Done";
            
            _lblStage.text = @"Exercise Completed";
            
            _btnTimer.hidden = YES;
        }
        else
        {
            // move to next stage
            _lblTitle.text = [_thisWorkout currentTitle];
            _timerSeconds = [_thisWorkout currentDuration];
            
            // update stage title
            _lblStage.text = [NSString stringWithFormat:@"Stage %d/%lu", (_thisWorkout.currentPhase + 1), (unsigned long)[_thisWorkout totalPhases]];
        }
    }
    else if ( _timerSeconds <= 3 ) {
        // play sound
        AudioServicesPlaySystemSound(_sndTick);
    }
    
    _lblTimer.text = [self timeAsString:_timerSeconds];
    _lblTotalTime.text = [self timeAsString:_totalTimeSeconds];
    
}

// timeAsString
//
// Description: converts seconds into a displayable string as mm:ss
// Parameter: time - the current time in seconds
// Returns: the string representation of the time
-(NSString*)timeAsString:(int)time
{
    // determine the minutes and seconds in the current time
    long minutes = time / 60;
    long seconds = time % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

-(void)readExerciseData
{
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
        for (NSUInteger i = 0; i < phases; i++) {

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
        [_workouts addObject:workout];
    }
    
    NSLog(@"Data read from file");
}

@end
