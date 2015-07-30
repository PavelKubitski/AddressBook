//
//  EditInfoViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 22.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "ABManager.h"
#import <MapKit/MapKit.h>
#import "CustomMapView.h"
#import "EditContactTableView.h"
#import "CDPerson.h"




extern NSString* const IndexOfPersonInArrayInfoKey;

//enum viewControllers {VIEWCONTROLLER, DETAILVIEWCONTROLLER};

@interface EditInfoViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *fotoImageView;
@property (weak, nonatomic) IBOutlet EditContactTableView *infoTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet CustomMapView *homeMapView;


@property (strong, nonatomic) NSIndexPath* indexpath;
@property (strong, nonatomic) CDPerson* oldPerson;
@property (strong, nonatomic) CDPerson* personWithChanges;
@property (strong, nonatomic) ABManager* abManager;


@property (assign, nonatomic) enum viewControllers vc;



- (void) initWithPerson:(CDPerson*) cdPerson fromVC:(enum viewControllers) vc;

@end
