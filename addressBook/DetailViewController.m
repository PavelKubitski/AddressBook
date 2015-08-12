//
//  DetailTableViewController.m
//  addressBook
//
//  Created by Pavel Kubitski on 18.06.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import "DetailViewController.h"
#import "InfoCell.h"
#import "EditInfoViewController.h"
#import "LabelAndInfo.h"
#import "CustomAnnotation.h"
#import "UIViewController+LastViewController.h"
#import "NSArray+Converter.h"
#import "CDCoordinate.h"



NSInteger offset = 10;

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Person";

    self.infoTableView.scrollEnabled = NO;
    
    self.homeMapView.person = self.cdPerson;
    
    [self.scroller setScrollEnabled:YES];
    self.scroller.delaysContentTouches = NO;

    self.fotoImageView.layer.cornerRadius = 5;
    self.fotoImageView.layer.masksToBounds = YES;
    self.fotoImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.fotoImageView.layer.borderWidth = 0.2f;
    
    [self setValidSizesOfControllers];

    self.homeMapView.scrollEnabled = NO;
    self.homeMapView.zoomEnabled = NO;
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
}


- (void) setValidSizesOfControllers {
    CGRect frameMap = self.homeMapView.frame;
    CGRect frameTable = self.infoTableView.frame;
    CGRect frameScroller = self.scroller.frame;
    
    frameMap.size.width = self.view.frame.size.width;
    frameTable.size.width = self.view.frame.size.width;
    frameScroller.size.width = self.view.frame.size.width + 100;    //потому что на 5s узким был scroller
    
    self.homeMapView.frame = frameMap;
    self.infoTableView.frame = frameTable;
    self.scroller.frame = frameScroller;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.cdPerson.firstName, self.cdPerson.lastName];
    self.companyNameLabel.text = self.cdPerson.companyName;
    
    self.infoTableView.cdPerson = self.cdPerson;
    
    self.fotoImageView.image = [UIImage imageWithData:self.cdPerson.avatarImage];
    
    
    CGRect frame = self.homeMapView.frame;
    frame.origin.y = self.view.frame.size.height;
    self.homeMapView.frame = frame;

    [self.infoTableView reloadDataOfCustomTable];

    CustomAnnotation* annotation = [[CustomAnnotation alloc] initWithCDCoordinate:self.cdPerson.coordinate];
    if (annotation.coordinate.latitude != -1 &&
        annotation.coordinate.longitude != -1) {
        [self.homeMapView removeAnnotations:[self.homeMapView annotations]];
        [self.homeMapView addAnnotation:annotation];
        [self.homeMapView showHomeOnMap];
    } else {
        NSString* fullAddress = self.cdPerson.coordinate.fullAddress;
        if (fullAddress) {
            [self.homeMapView geoCodeUsingAddress:fullAddress];
        }
    }
    
    [self addObservers];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjastHieghtOfTableView];

}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObservers];
}



- (void) adjastHieghtOfTableView {
    CGRect frameTable = self.infoTableView.frame;
    
    frameTable.size.height = self.infoTableView.contentSize.height;
    self.infoTableView.frame = frameTable;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frameMap = self.homeMapView.frame ;
        frameMap.origin.y = frameTable.origin.y + frameTable.size.height;
        self.homeMapView.frame = frameMap;
    }];
    
    NSInteger mapHeight = self.homeMapView.frame.size.height;
    NSInteger hieght = self.infoTableView.frame.origin.y + self.infoTableView.contentSize.height + mapHeight + offset;
    [self.scroller setContentSize:CGSizeMake(320, hieght)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}






#pragma mark - actions

- (void) editButtonAction:(UIBarButtonItem*) sender {
    EditInfoViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditInfoViewController"];
    [vc initWithPerson:self.cdPerson fromVC:DETAILVIEWCONTROLLER];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - notifications

- (void) mapViewTouched:(NSNotification*) notification {

    MapViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    [vc initWithPerson:self.cdPerson fromVC:DETAILVIEWCONTROLLER];

    [self.navigationController pushViewController:vc animated:YES];

}


#pragma mark - manage notifications

- (void) addObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(mapViewTouched:)
               name:MapViewTouchedNotification
             object:nil];
}

- (void) removeObservers {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:MapViewTouchedNotification
                object:nil];
}



@end
