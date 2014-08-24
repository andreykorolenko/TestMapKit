//
//  Event.h
//  Lesson 37 - 38 home
//
//  Created by Андрей on 05.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Event : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

@end
