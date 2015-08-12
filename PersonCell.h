//
//  PersonCell.h
//  addressBook
//
//  Created by Pavel Kubitski on 09.08.15.
//  Copyright (c) 2015 Pavel Kubitski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
