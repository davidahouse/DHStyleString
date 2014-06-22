//
//  ExamplesTableViewController.m
//  StyleStringExample
//
//  Created by David House on 5/29/14.
//  Copyright (c) 2014 Random Accident. All rights reserved.
//

#import "ExamplesTableViewController.h"
#import "DHStyleSpec.h"
#import "DHStyleString.h"

@interface ExamplesTableViewController ()

@property (nonatomic,strong) UITableViewCell *sizingCell;
@property (nonatomic,strong) DHStyleSpec *styleSpec;

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
    
    self.styleSpec = [[DHStyleSpec alloc] initWithName:@"test"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dynamicTextChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
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
    return 4;
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
    else if ( section == 2 ) {
        return 1;
    }
    else {
        return 6;
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
    else if ( indexPath.section == 2 ) {
        NSAttributedString *cellText = [self attributedTextForMultiLineRow:indexPath.row];
        cell.textLabel.attributedText = cellText;
    }
    else {
        NSAttributedString *cellText = [self attributedTextForDynamicRow:indexPath.row];
        cell.textLabel.attributedText = cellText;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [@[@"Basic Styles",@"Inherited Styles",@"Multiline Styles",@"Dynamic Styles"] objectAtIndex:section];
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
    else if ( indexPath.section == 2 ) {
        cellText = [self attributedTextForMultiLineRow:indexPath.row];
    }
    else {
        cellText = [self attributedTextForDynamicRow:indexPath.row];
    }

    if ( !self.sizingCell ) {
        self.sizingCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }

    CGSize maxSize = CGSizeMake(self.sizingCell.textLabel.frame.size.width, CGFLOAT_MAX);
    CGRect formattedSize = [cellText boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    return (int)formattedSize.size.height + 17.0;
}

#pragma mark - Observer selectors
- (void)dynamicTextChanged:(NSNotification *)notification
{
    NSLog(@"VC got dynamic text message");
    self.styleSpec = [[DHStyleSpec alloc] initWithName:@"test"];
    [self.tableView reloadData];
}


#pragma mark - Private Methods

- (NSAttributedString *)attributedTextForRow:(int)row
{
    return [self.styleSpec attributedString:@"Your dog has fleas" style:[NSString stringWithFormat:@"row%d",row]];
}

- (NSAttributedString *)attributedTextForInheritedRow:(int)row
{
    return [self.styleSpec attributedString:@"Your dog has fleas" style:[NSString stringWithFormat:@"inherited_row%d",row]];
}

- (NSAttributedString *)attributedTextForMultiLineRow:(int)row
{
    DHStyleString *styleString = [[DHStyleString alloc] initWithName:@"mcbeth"];
    return [self.styleSpec attributedStringFromStyleString:styleString variables:@{@"speaker":@"MACBETH",@"source":@"source: http://shakespeare.mit.edu/macbeth"}];
}

- (NSAttributedString *)attributedTextForDynamicRow:(int)row
{
    return [self.styleSpec attributedString:@"Your dog has fleas" style:[NSString stringWithFormat:@"dynamic_row%d",row]];
}

@end
