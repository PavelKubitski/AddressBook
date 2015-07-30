//
//  ViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 15.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "EditInfoViewController.h"
#import "Section.h"
#import "ContactsTableView.h"
#import "CDWriter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchBar.delegate = self;
    
    self.abManager = [[ABManager alloc] init];


    self.cdWriter = [CDWriter sharedManager];


    self.tableView.navigationController = self.navigationController;
    self.tableView.storyboard = self.storyboard;
    self.tableView.abManager = self.abManager;
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editButtonAction:)];
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addButtonAction:)];
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refreshButtonAction:)];
    

    [self.navigationItem setLeftBarButtonItem:addButton];
    [self.navigationItem setRightBarButtonItems:@[editButton, refreshButton] animated:YES];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setValidSizesOfControllers];
    self.tableView.personsFetchedResultsController = nil;
    [self.tableView reloadData];

}

- (void) setValidSizesOfControllers {

    CGRect frameTable = self.tableView.frame;
    frameTable.size.width = self.view.frame.size.width;
    self.tableView.frame = frameTable;
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height;
    frame.size.width = self.view.frame.size.width;
    self.tableView.frame = frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
    [self removeObservers];
}

- (void) addPersonsToDataBase:(NSArray*) persons {
    [self.cdWriter addPersonsToCDBase:persons];
}

#pragma mark - actions

- (void) editButtonAction:(UIBarButtonItem*) sender {
    bool isEditing = self.tableView.editing;

    [self.tableView setEditing:!isEditing animated:YES];
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:@selector(editButtonAction:)];
    [self.navigationItem setRightBarButtonItem:editButton];
}


- (void) refreshButtonAction:(UIBarButtonItem*) sender {
    
    self.abManager = [[ABManager alloc] init];
    [self.cdWriter deleteAllObjects];
    self.personsArray = [NSMutableArray arrayWithArray:[self.abManager allPersonsAddPerson:NO]];
    [self.cdWriter addPersonsToCDBase:self.personsArray];
}




- (void) addButtonAction:(UIBarButtonItem*) sender {

    
    CDPerson* person = [NSEntityDescription insertNewObjectForEntityForName:@"CDPerson"
                                                            inManagedObjectContext:[[CDManager sharedManager] managedObjectContext]];
    UIImage *image = [UIImage imageNamed:@"noname.png"];
    person.avatarImage = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    EditInfoViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditInfoViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
    [self.abManager allPersonsAddPerson:YES];
    [vc initWithPerson:person fromVC:VIEWCONTROLLER];
}








#pragma mark - Notifications




- (void) addressBookDidChanged:(NSNotification*) notification  {

    NSArray* persons;

    NSString* status = [notification.userInfo objectForKey:ABManagerKindOfChangeInfoKey];
    if ([status isEqualToString:@"Append"]) {
        
        persons = [notification.userInfo objectForKey:ABManagerDidChangeAddressBookInfoKey];
        [self addPersonsToDataBase:persons];
    }
}





#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"textDidChange %@", searchText);
    
//    self.sectionsArray = [self generateSectionsFromArray:self.personsArray withFilter:searchText];
//    [self.tableView reloadData];
    
//    [self generateSectionsInBackgroundFromArray:self.namesArray withFilter:self.searchBar.text];
    
}

#pragma mark - generator

- (NSMutableArray*) generateSectionsFromArray:(NSArray*) array withFilter:(NSString*) filterString {

    NSMutableArray* sectionsArray = [NSMutableArray array];

    NSString* currentLetter = nil;

    for (Person* person in array) {
        NSString* fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        
        if ([filterString length] > 0 && [fullName rangeOfString:filterString].location == NSNotFound) {
            continue;
        }
        
        NSString* firstLetter = [person.firstName substringToIndex:1];
        
        Section* section = nil;
        
        if (![currentLetter isEqualToString:firstLetter]) {
            section = [[Section alloc] init];
            section.sectionName = firstLetter;
            section.itemsArray = [NSMutableArray array];
            currentLetter = firstLetter;
            [sectionsArray addObject:section];
        } else {
            section = [sectionsArray lastObject];
        }

        [section.itemsArray addObject:fullName];

    }

    return sectionsArray;
}




#pragma mark - manage notifications

- (void) addObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(addressBookDidChanged:)
               name:ABManagerDidChangeAddressBookNotification
             object:nil];

}

- (void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:ABManagerDidChangeAddressBookNotification
                object:self];
}







@end
