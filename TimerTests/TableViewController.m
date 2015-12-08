//
//  TableViewController.m
//  TimerTests
//
//  Created by Janet Mason on 8/12/2015.
//  Copyright © 2015 Stephen Powell. All rights reserved.
//

#import "TableViewController.h"
#import "Workout.h"
#import "ViewController.h"

#define kSections 1

@interface TableViewController ()
// Workouts
@property (strong, nonatomic) NSMutableArray<Workout*>* workouts;

-(void)readExerciseData;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // create workouts array
    // Create workouts
    _workouts = [[NSMutableArray alloc] initWithCapacity:1];
    
    // read in workout data from file
    [self readExerciseData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_workouts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"daily_cell" forIndexPath:indexPath];
    
    // Configure the cell...
    int week = (int)indexPath.row / 3 + 1;
    int day = (int)indexPath.row % 3 + 1;
    
    cell.textLabel.text = [NSString stringWithFormat:@"Week %d, Day %d", week, day];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showExerciseDetail"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        NSLog(@"Sending cell is %ld",indexPath.row);
        
        // get the receiving view controller
        ViewController* exerciseView = (ViewController*)[segue destinationViewController];
        
        // Set the current workout to the one selected
        exerciseView.thisWorkout = [_workouts objectAtIndex:indexPath.row];
    }
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
