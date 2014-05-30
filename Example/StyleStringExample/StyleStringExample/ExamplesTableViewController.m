//
//  ExamplesTableViewController.m
//  StyleStringExample
//
//  Created by David House on 5/29/14.
//  Copyright (c) 2014 Random Accident. All rights reserved.
//

#import "ExamplesTableViewController.h"
#import <NSAttributedString+DHStyleString.h>

@interface ExamplesTableViewController ()

@property (nonatomic,strong) UITableViewCell *sizingCell;

@end

@implementation ExamplesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( section == 0 ) {
        return 17;
    }
    else if ( section == 1 ) {
        return 1;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if ( indexPath.section == 0 ) {
        NSAttributedString *cellText = [self attributedTextForRow:indexPath.row];
        cell.textLabel.attributedText = cellText;
    }
    else if ( indexPath.section == 1 ) {
        NSAttributedString *cellText = [self attributedTextForInheritedRow:indexPath.row];
        cell.textLabel.attributedText = cellText;
    }
    else {
        NSAttributedString *cellText = [self attributedTextForMultiLineRow:indexPath.row];
        cell.textLabel.attributedText = cellText;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [@[@"Basic Styles",@"Inherited Styles",@"Multiline Styles"] objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *cellText = nil;
    if ( indexPath.section == 0 ) {
        cellText = [self attributedTextForRow:indexPath.row];
    }
    else if ( indexPath.section == 1 ) {
        cellText = [self attributedTextForInheritedRow:indexPath.row];
    }
    else {
        cellText = [self attributedTextForMultiLineRow:indexPath.row];
    }

    if ( !self.sizingCell ) {
        self.sizingCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }

    CGSize maxSize = CGSizeMake(self.sizingCell.textLabel.frame.size.width, CGFLOAT_MAX);
    CGRect formattedSize = [cellText boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    return (int)formattedSize.size.height + 17.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSAttributedString *)attributedTextForRow:(int)row
{
    return [NSAttributedString SS_attributedString:@"Your dog has fleas" style:[NSString stringWithFormat:@"row%d",row] stylespec:@"test"];
}

- (NSAttributedString *)attributedTextForInheritedRow:(int)row
{
    return [NSAttributedString SS_attributedString:@"Your dog has fleas" style:[NSString stringWithFormat:@"inherited_row%d",row] stylespec:@"test"];
}

- (NSAttributedString *)attributedTextForMultiLineRow:(int)row
{
    return [NSAttributedString SS_attributedStrings:@[@"your dog",@"\nhas fleas"]
                      styles:@[@"header1",@"body1"] stylespec:@"test"];
}

@end
