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
#import "DataController.h"

#define kSections 1

@interface TableViewController ()
// Workouts
@property (strong, nonatomic) NSArray<Workout*>* workouts;
@property (strong, nonatomic) DataController* dc;
@property (nonatomic) long selectedRow;

-(NSArray*)writeCompletionInfo;
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
    //_workouts = [[NSMutableArray alloc] initWithCapacity:1];
    
    if (_dc == nil) {
        _dc = [[DataController alloc] init];
    }
    
    // read in workout data from file if required
    if ( _workouts == nil)
    {
        _workouts = [_dc getWorkoutData];
    }
    
    // get workout completion info
    NSArray* completionInfo = [_dc readCompletionInfo];
    
    if ( completionInfo == nil)
    {
        NSLog(@"File does not exist writing new file");
        completionInfo = [self writeCompletionInfo];
    }
    else
    {
        NSLog(@"Reading from existing file");
        // store completion info into Workouts
        if ([completionInfo count] == [_workouts count])
        {
            // have the correct amount
            for (int i = 0; i < [completionInfo count]; i++)
            {
                [_workouts objectAtIndex:i].completed = [[completionInfo objectAtIndex:i] boolValue];
            }
        }
    }
    
    // set selected row
    _selectedRow = -1;
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
    
    if  ([_workouts objectAtIndex:indexPath.row].completed == NO)
    {
        cell.textLabel.textColor = [UIColor redColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor greenColor];
    }
    
    return cell;
}
-(IBAction)unwindToList:(UIStoryboardSegue*)sender
{
    ViewController* exerciseView = (ViewController*)sender.sourceViewController;
    
    NSLog(@"Selected row was %ld", _selectedRow);
    
    if (exerciseView.workoutFinished) {
        NSLog(@"Workout done, write to file");
        
        // set workout as done
        [_workouts objectAtIndex:_selectedRow].completed = YES;
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
        NSLog(@"Row %ld", indexPath.row);
        [[self tableView] cellForRowAtIndexPath: indexPath].textLabel.textColor = [UIColor greenColor];
        [self writeCompletionInfo];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_workouts objectAtIndex:indexPath.row].completed)
    {
        cell.textLabel.textColor = [UIColor greenColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor redColor];
    }
}

-(NSArray*)writeCompletionInfo
{
    NSMutableArray* completionInfo = [[NSMutableArray alloc] initWithCapacity:1];
    
    // get completion info from Workouts
    for (int i = 0; i < [_workouts count]; i++)
    {
        [completionInfo addObject:[NSNumber numberWithBool:[_workouts objectAtIndex:i].completed]];
    }
    
    // write this data to the file
    bool result = [_dc writeCompletionInfo:completionInfo];
    
    if (result)
    {
        NSLog(@"File write successful");
    }
    else
    {
        NSLog(@"File write failed");
    }

    return [NSArray arrayWithArray:completionInfo];
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
        _selectedRow = indexPath.row;
        exerciseView.thisWorkout = [_workouts objectAtIndex:_selectedRow];
    }
}

@end
