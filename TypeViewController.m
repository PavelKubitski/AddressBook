//
//  TypeViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 28.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "TypeViewController.h"


NSString* const TypeVCDismissedNotification = @"TypeVCDismissedNotification";

NSString* const TypeVCLabelTextInfoKey = @"TypeVCLabelTextInfoKey";



@interface TypeViewController ()

@end

@implementation TypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.3];
    
    

    CGRect frameDoneButton = self.doneButton.frame;
    frameDoneButton.origin.x = self.view.frame.size.width - self.doneButton.frame.size.width - 10;
    
    self.doneButton.frame = frameDoneButton;

}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableView.contentSize.height;
    frame.size.width = self.view.frame.size.width;
    
    self.tableView.frame = frame;

}

#pragma mark - initialization

- (void) initWithTypeIndexPath:(NSIndexPath*) indexpath typeLabel:(NSString *)type  {
    self.indexpath = indexpath;
    self.type = type;
}


#pragma mark - actions

- (IBAction)actionDoneButtonTouches:(id)sender {

    NSDictionary* dc = [NSDictionary dictionaryWithObjectsAndKeys:self.type, TypeVCLabelTextInfoKey,  nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeVCDismissedNotification object:nil userInfo:dc];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (self.indexpath.section == 0) {
        numberOfRows = 9;
    } else if (self.indexpath.section == 1){
        numberOfRows = 4;
    }
    return numberOfRows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [[UITableViewCell alloc] init];

    if (self.indexpath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"home";
                break;
            case 1:
                cell.textLabel.text = @"work";
                break;
            case 2:
                cell.textLabel.text = @"iPhone";
                break;
            case 3:
                cell.textLabel.text = @"mobile";
                break;
            case 4:
                cell.textLabel.text = @"main";
                break;
            case 5:
                cell.textLabel.text = @"home fax";
                break;
            case 6:
                cell.textLabel.text = @"work fax";
                break;
            case 7:
                cell.textLabel.text = @"pager";
                break;
            case 8:
                cell.textLabel.text = @"other";
                break;
                
            default:
                break;
        }
    } else if (self.indexpath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"home";
                break;
            case 1:
                cell.textLabel.text = @"work";
                break;
            case 2:
                cell.textLabel.text = @"iCloud";
                break;
            case 3:
                cell.textLabel.text = @"other";
                break;
            default:
                break;
        }

    }
    if ([cell.textLabel.text isEqualToString:self.type]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    self.type = cell.textLabel.text;
    [self disableCellAccessoryType];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


- (void) disableCellAccessoryType {
    NSArray* subviews = [self.tableView visibleCells];
    

    for (int i = 0; i < [subviews count]; i++) {
        UITableViewCell* cell = [subviews objectAtIndex:i];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}



@end
