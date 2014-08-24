//
//  Event.m
//  Lesson 37 - 38 home
//
//  Created by Андрей on 05.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "Event.h"

@implementation Event

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(47.236226, 39.712779);
        self.title = @"Встреча студентов";
    }
    return self;
}

@end
