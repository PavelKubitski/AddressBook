//
//  DetailTableViewController.h
//  addressBook
//
//  Created by Pavel Kubitski on 18.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import <MapKit/MapKit.h>
#import "CustomMapView.h"
#import "MapViewController.h"
#import "ViewContactTableView.h"

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *fotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet ViewContactTableView *infoTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet CustomMapView *homeMapView;

@property (strong, nonatomic) CDPerson* cdPerson;







@end
