//
//  Student.m
//  Lesson 37 - 38 home
//
//  Created by Андрей on 04.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "Student.h"

@implementation Student

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *firstNames = @[@"Андрей", @"Татьяна", @"Алексей", @"Игорь", @"Анна", @"Елена", @"Максим", @"Евгения", @"Олег",             @"Мария", @"Николай", @"Софья"];
        NSArray *lastNames = @[@"Короленко", @"Коломиченко", @"Гопцарь", @"Петренко", @"Петренко", @"Василенко", @"Капраленко", @"Мащенко", @"Андреенко", @"Джонсон", @"Питерсон", @"Томсон"];
        
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(47.211019, 39.673683);
        CGFloat randomLatitude = (float)(arc4random() % (50000 - 10000) + 10000) / 1000000;
        CGFloat randomLongitude = (float)(arc4random() % (50000 - 10000) + 10000) / 1000000;
        NSInteger randomName = arc4random() % 12;
        
        self.firstName = [firstNames objectAtIndex:randomName];
        self.lastName = [lastNames objectAtIndex:arc4random() % 12];
        self.year = arc4random() % (1995 - 1989) + 1989;
        
        if (randomName == 0 || randomName == 2 || randomName == 3 || randomName == 6 || randomName == 8 || randomName == 10) {
            self.isMale = YES;
        } else {
            self.isMale = NO;
        }
        
        self.coordinate = CLLocationCoordinate2DMake(startCoordinate.latitude + randomLatitude,
                                                     startCoordinate.longitude + randomLongitude);
        
        self.title = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        self.subtitle = [NSString stringWithFormat:@"%d", self.year];
    }
    return self;
}

@end
