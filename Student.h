//
//  Student.h
//  Lesson 37 - 38 home
//
//  Created by Андрей on 04.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Student : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) BOOL isMale;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end