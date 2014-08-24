//
//  TableViewController.h
//  Lesson 37 - 38 home
//
//  Created by Андрей on 04.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

@property (strong, nonatomic) UIViewController *vc;

// Поповер инфо о студенте
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

// Поповер количество студентов
@property (weak, nonatomic) IBOutlet UIImageView *meetingImageView;
@property (weak, nonatomic) IBOutlet UILabel *count500metersLabel;
@property (weak, nonatomic) IBOutlet UILabel *count1kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *count2kmLabel;

@end