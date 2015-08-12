//
//  EditInfoViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "EditInfoViewController.h"
#import "EditCell.h"
#import "DetailViewController.h"
#import "TypeViewController.h"

#import "LabelAndInfo.h"
#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "NSManagedObject+Clone.h"
#import "CDManager.h"
#import "UIViewController+LastViewController.h"
#import "NSArray+Converter.h"
#import "CDCoordinate.h"
#import "CDWriter.h"

NSInteger kOffset = 70;




NSString* const IndexOfPersonInArrayInfoKey = @"IndexOfPersonInArrayInfoKey";

@interface EditInfoViewController ()

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Edit";
    
    self.infoTableView.cdPerson = self.personWithChanges;
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.companyNameTextField.delegate = self;
    
    self.infoTableView.scrollEnabled = NO;
    
    [self.scroller setScrollEnabled:YES];
    self.scroller.delegate = self;
    
    self.fotoImageView.image = [UIImage imageWithData:self.personWithChanges.avatarImage];

    self.fotoImageView.layer.cornerRadius = 5;
    self.fotoImageView.layer.masksToBounds = YES;
    self.fotoImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.fotoImageView.layer.borderWidth = 0.2f;

    self.infoTableView.editing = YES;
    self.infoTableView.allowsSelectionDuringEditing = YES;

    self.homeMapView.zoomEnabled = NO;
    self.homeMapView.scrollEnabled = NO;
    
    self.abManager = [ABManager sharedBook];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDoneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem* cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(actionCancelButtonPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    
    [self setValidSizesOfControllers];
    [self addObservers];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewDidAppear:animated];



    CustomAnnotation* annotation = [[CustomAnnotation alloc] initWithCDCoordinate:self.personWithChanges.coordinate];
    if (annotation.coordinate.latitude != -1 &&
        annotation.coordinate.longitude != -1) {
        [self.homeMapView removeAnnotations:[self.homeMapView annotations]];
        [self.homeMapView addAnnotation:annotation];
        [self.homeMapView showHomeOnMap];
    } else {
        NSString* fullAddress = self.personWithChanges.coordinate.fullAddress;
        if (fullAddress) {
            [self.homeMapView geoCodeUsingAddress:fullAddress];
        }
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mapViewTouched:)
                                                 name:MapViewTouchedNotification
                                               object:nil];
   
    self.firstNameTextField.text = self.personWithChanges.firstName;
    self.lastNameTextField.text = self.personWithChanges.lastName;
    self.companyNameTextField.text = self.personWithChanges.companyName;

    [self.homeMapView showHomeOnMap];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MapViewTouchedNotification
                                                  object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect frameTable = self.infoTableView.frame;
    
    frameTable.size.height = self.infoTableView.contentSize.height;
    self.infoTableView.frame = frameTable;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frameMap = self.homeMapView.frame ;
        frameMap.origin.y = frameTable.origin.y + frameTable.size.height;
        self.homeMapView.frame = frameMap;
    }];

    NSInteger mapHeight = self.homeMapView.frame.size.height;
    NSInteger hieght = self.infoTableView.frame.origin.y + self.infoTableView.contentSize.height + mapHeight;
    [self.scroller setContentSize:CGSizeMake(320, hieght + kOffset)];

}

- (void) setValidSizesOfControllers {
    CGRect frameMap = self.homeMapView.frame;
    CGRect frameTable = self.infoTableView.frame;
    CGRect frameScroller = self.scroller.frame;
    
    frameMap.size.width = self.view.frame.size.width;
    frameTable.size.width = self.view.frame.size.width;
    frameScroller.size.width = self.view.frame.size.width;
    
    self.homeMapView.frame = frameMap;
    self.infoTableView.frame = frameTable;
    self.scroller.frame = frameScroller;
}

- (void) endEditingTextFields {
    NSArray *cells = [self.infoTableView visibleCells];
    
    for (EditCell* cell in cells) {
        if ([cell.infoTextField isEditing]) {
            [cell.infoTextField endEditing:YES];
        }
    }
}


#pragma mark - actions


- (void)actionDoneButtonPressed:(id)sender {
    [self endEditingTextFields];
    [self saveChangesOfProfile];


    if (self.vc == PERSONSVIEWCONTROLLER) {
        if ([self.personWithChanges.firstName isEqualToString:@""] &&
            [self.personWithChanges.lastName isEqualToString:@""]) {
            self.personWithChanges.firstName = @"No name";
        }
        [[CDWriter sharedWriter] addPhotoToUser];
        [self.abManager updateAdressBookPerson:nil withPerson:self.personWithChanges];

    } else if (self.vc == DETAILVIEWCONTROLLER) {
        
        [self.abManager updateAdressBookPerson:self.oldPerson withPerson:self.personWithChanges];
        
    }
    [[CDManager sharedManager] saveContext];
    [[[CDManager sharedManager] managedObjectContext] deleteObject:self.oldPerson];
    [[CDManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}





- (void)actionCancelButtonPressed:(id)sender {
    [[[CDManager sharedManager] managedObjectContext] deleteObject:self.personWithChanges];
    
    if (self.vc == PERSONSVIEWCONTROLLER) {

        [[[CDManager sharedManager] managedObjectContext] deleteObject:self.oldPerson];
    } else if (self.vc == DETAILVIEWCONTROLLER) {
        
        DetailViewController* detailVC = (DetailViewController*)[self backViewController];
        detailVC.cdPerson = self.oldPerson;
    }
    
    [[CDManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Notifications

- (void)touchedTypeLabel:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    self.indexpath = [info objectForKey:TypeLabelTouchedAtIndexPathInfoKey];
    if (self.indexpath.row != 0) {
        [self endEditingTextFields];
        TypeViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TypeViewController"];
        EditCell* cell = (EditCell*)[self.infoTableView cellForRowAtIndexPath:self.indexpath];
        [vc initWithTypeIndexPath:self.indexpath typeLabel:cell.typeLabel.text];
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:vc animated:YES completion:nil];
        [self hideAndDisableNavigationItems];
    }
}

- (void)typeVCDismissed:(NSNotification*)notification {
    NSString* type = [notification.userInfo objectForKey:TypeVCLabelTextInfoKey];
    
    [self.infoTableView changeTypeLabelWithLabel:type atIndexPath:self.indexpath];
    [self showAndEnableNavigationItems];
    
}

- (void) mapViewTouched:(NSNotification*) notification {

    [self saveChangesOfProfile];
    MapViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];

    [vc initWithPerson:self.personWithChanges fromVC:EDITVIEWCONTROLLER];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) sizeOfTableViewChanged:(NSNotification*) notification {
    
    [self adjustHeightOfScrollView];
}


#pragma mark - keyboard notification

- (void)keyboardWasShown:(NSNotification*)notification
{
    if (![self.firstNameTextField isEditing] &&
        ![self.lastNameTextField isEditing] &&
        ![self.companyNameTextField isEditing]) {
        NSDictionary* info = [notification userInfo];
        NSInteger offset = 65;
        CGSize kbSize = [[info objectForKey:SizeOfKeyboardWasShownInfoKey] CGSizeValue];
        CGRect cellFrame = [[info objectForKey:FrameOfEditCellKeyboardWasShownInfoKey] CGRectValue];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+offset, 0.0);
        self.scroller.contentInset = contentInsets;
        self.scroller.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height+offset;
        if (!CGRectContainsPoint(aRect, cellFrame.origin) ) {
            [self.scroller scrollRectToVisible:cellFrame animated:YES];
        }
    }

}


- (void)keyboardWillBeHidden:(NSNotification*)notification {

    UIEdgeInsets contentInset = UIEdgeInsetsMake(35.0, 0.0, 0.0, 0.0);
    self.scroller.contentInset = contentInset;
    self.scroller.scrollIndicatorInsets = contentInset;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:DragingScrollViewBeganNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - Initialization

- (void) initWithPerson:(CDPerson*) cdPerson fromVC:(enum viewControllers) vc {

    self.vc = vc;
    self.oldPerson = (CDPerson*)[cdPerson clone];
    self.personWithChanges = cdPerson;
}



#pragma mark - Adjusting

- (void)adjustHeightOfScrollView
{

    [self.infoTableView reloadData];

    CGFloat height = self.infoTableView.contentSize.height;

    CGRect frameTable = self.infoTableView.frame;
    frameTable.size.height = height;
    self.infoTableView.frame = frameTable;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frameMap = self.homeMapView.frame ;
        frameMap.origin.y = frameTable.origin.y + frameTable.size.height;
        self.homeMapView.frame = frameMap;
    }];
    
    NSInteger hieghtOfScroller = self.infoTableView.frame.origin.y + self.infoTableView.contentSize.height + self.homeMapView.frame.size.height;
    [self.scroller setContentSize:CGSizeMake(320, hieghtOfScroller + kOffset)];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (self.firstNameTextField == textField && ![self.firstNameTextField isFirstResponder]) {
        [self.firstNameTextField becomeFirstResponder];
    }
    if (self.lastNameTextField == textField && ![self.lastNameTextField isFirstResponder]) {
        [self.lastNameTextField becomeFirstResponder];
    }
    if (self.companyNameTextField == textField && ![self.companyNameTextField isFirstResponder]) {
        [self.companyNameTextField becomeFirstResponder];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.firstNameTextField == textField && [self.firstNameTextField isFirstResponder]) {
        [self.firstNameTextField resignFirstResponder];
    }
    if (self.lastNameTextField == textField && [self.lastNameTextField isFirstResponder]) {
        [self.lastNameTextField resignFirstResponder];
    }
    if (self.companyNameTextField == textField && [self.companyNameTextField isFirstResponder]) {
        [self.companyNameTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Saving

- (void) saveChangesOfProfile {
    self.personWithChanges.firstName = self.firstNameTextField.text;
    self.personWithChanges.lastName = self.lastNameTextField.text;
    self.personWithChanges.companyName = self.companyNameTextField.text;
}

#pragma mark - touches

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    return YES;
}



#pragma mark - bar buttons

- (void) hideAndDisableNavigationItems {
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
}

-(void) showAndEnableNavigationItems {
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blueColor]];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blueColor]];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
}

#pragma mark - manage notifications

- (void) addObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWasShown:)
               name:EditCellKeyboardWasShownNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillBeHidden:)
               name:EditCellKeyboardWillDisappearNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(touchedTypeLabel:)
               name:TypeLabelTouchedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(typeVCDismissed:)
               name:TypeVCDismissedNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(sizeOfTableViewChanged:)
               name:SizeOfTableViewChangedNotification
             object:nil];

}

- (void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:EditCellKeyboardWasShownNotification
                object:nil];
    [nc removeObserver:self
                  name:EditCellKeyboardWillDisappearNotification
                object:nil];
    [nc removeObserver:self
                  name:TypeLabelTouchedNotification
                object:nil];
    [nc removeObserver:self
                  name:TypeVCDismissedNotification
                object:nil];
    [nc removeObserver:self
                  name:SizeOfTableViewChangedNotification
                object:nil];
}



@end
