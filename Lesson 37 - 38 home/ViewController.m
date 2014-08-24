//
//  ViewController.m
//  Lesson 37 - 38 home
//
//  Created by Андрей on 04.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "TableViewController.h"
#import "UIView+MKAnnotationView.h"
#import "Student.h"
#import "Event.h"

@interface ViewController () <MKMapViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSMutableArray *studentsArray;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MKCircle *fullCircle;
@property (strong, nonatomic) MKCircle *midCircle;
@property (strong, nonatomic) MKCircle *minCircle;
@property (assign, nonatomic) MKMapRect zoomRect;
@property (assign, nonatomic) MKMapRect zoomRectMeeting;
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) MKDirections *directions;
@property (strong, nonatomic) NSMutableArray *students1km;
@property (strong, nonatomic) NSMutableArray *students2km;
@property (strong, nonatomic) NSMutableArray *students3km;
@property (strong, nonatomic) NSMutableArray *circlesOverlays;
@property (assign, nonatomic) NSInteger firtsTime;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.studentsArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        
        Student *student = [[Student alloc] init];
        [self.studentsArray addObject:student];
    }
    
    self.zoomRect = MKMapRectNull;
    self.zoomRectMeeting = MKMapRectNull;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionSearchStudent:)];
    
    UIBarButtonItem *addMeeting = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddMeeting:)];
    
    UIBarButtonItem *addRoute = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(actionAddRoute:)];
    
    NSArray *items = @[searchButton, addMeeting, addRoute];
    self.navigationItem.rightBarButtonItems = items;
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    self.circlesOverlays = [[NSMutableArray alloc] init];
    
    self.firtsTime = YES;
}

- (void)dealloc
{
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
}

// показать всех студентов на карте
- (void) showAllstudentsOnMap {
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static int delta = 4000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        self.zoomRect = MKMapRectUnion(self.zoomRect, rect);
    }
    
    self.zoomRect = [self.mapView mapRectThatFits:self.zoomRect];
    
    [self.mapView setVisibleMapRect:self.zoomRect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
}

#pragma mark - Actions

// кнопка Search - показать всех студентов
- (void) actionSearchStudent:(UIBarButtonItem *) sender {
    [self showAllstudentsOnMap];
}

// кнопка Info - подробнее о студенте
- (void) buttonInfoAction:(UIButton *) sender {
    
    // возвращает нужного студента
    MKAnnotationView *annotationView = [sender superAnnotationView];
    
    Student *student = annotationView.annotation;
    
    UIView *callout = sender.superview;
    
    TableViewController *tabController = [self.storyboard instantiateViewControllerWithIdentifier:@"TablePopover"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:tabController];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:callout.frame
                                      inView:callout.superview
                    permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                    animated:YES];
    } else {
        [self presentViewController:tabController animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
    
    // заполняем таблицу данными о студенте
    tabController.firstNameLabel.text = student.firstName;
    tabController.lastNameLabel.text = student.lastName;
    tabController.yearLabel.text = [NSString stringWithFormat:@"%d", student.year];
    if (student.isMale) {
        tabController.mainImageView.image = [UIImage imageNamed:@"male"];
    } else {
        tabController.mainImageView.image = [UIImage imageNamed:@"female"];
    }
    
    // создаем адрес
    CLLocationCoordinate2D coordinate = student.coordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Ок"
                              otherButtonTitles:nil] show];
        } else {
            
            // если placemark не получен
            if ([placemarks count] == 0) {
                [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                            message:@"Placemarks Not Found"
                                           delegate:nil
                                  cancelButtonTitle:@"Ок"
                                  otherButtonTitles:nil] show];
            // если placemark получен
            } else {
                MKPlacemark *placemark = [placemarks firstObject];
                tabController.countryLabel.text = placemark.country;
                tabController.cityLabel.text = placemark.locality;
                tabController.streetLabel.text = placemark.thoroughfare;
            }
        }
    }];
}

// кнопка + добавить встречу. Считаем количество студентов в кругах
- (void) actionAddMeeting:(UIBarButtonItem *) sender {
    
    static int count = 0;
    
    if (count == 0) {
        self.event = [[Event alloc] init];
        [self.mapView addAnnotation:self.event];
        count++;
        
        // считаем количество студентов в кругах
        self.students1km = [[NSMutableArray alloc] init];
        self.students2km = [[NSMutableArray alloc] init];
        self.students3km = [[NSMutableArray alloc] init];
        
        for (id <MKAnnotation> student in self.studentsArray) {
            
            // получаем CLLocation студента
            CLLocation *locationStudent = [[CLLocation alloc] initWithLatitude:student.coordinate.latitude
                                                                     longitude:student.coordinate.longitude];
            
            CLLocation *locationMeeting = [[CLLocation alloc] initWithLatitude:self.event.coordinate.latitude
                                                                     longitude:self.event.coordinate.longitude];
            
            CLLocationDistance distanceFromMeeting = [locationStudent distanceFromLocation:locationMeeting];
            
            if (distanceFromMeeting < 1000.f) {
                [self.students1km addObject:student];
            } else if (distanceFromMeeting >= 1000 && distanceFromMeeting <= 2000) {
                [self.students2km addObject:student];
            } else {
                [self.students3km addObject:student];
            }
        }
    }
}

// проложить маршруты
- (void) showDirectionsForStudent:(Student *) student {
    
    // берем координаты встречи
    CLLocationCoordinate2D coordinateMeeting = self.event.coordinate;
    MKPlacemark *placemarkMeeting = [[MKPlacemark alloc] initWithCoordinate:coordinateMeeting addressDictionary:nil];
    MKMapItem *destinationMeeting = [[MKMapItem alloc] initWithPlacemark:placemarkMeeting];
    
    // берем координаты студента
    CLLocationCoordinate2D coordinateStudent = student.coordinate;
    MKPlacemark *placemarkStudent = [[MKPlacemark alloc] initWithCoordinate:coordinateStudent addressDictionary:nil];
    MKMapItem *destinationStudent = [[MKMapItem alloc] initWithPlacemark:placemarkStudent];
    
    // создаем маршрут
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = destinationStudent;
    request.destination = destinationMeeting;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                        message:@"Нет конечной точки маршрута"
                                       delegate:nil cancelButtonTitle:@"Ок"
                              otherButtonTitles:nil] show];
        } else if ([response.routes count] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                        message:@"Не найдено маршрутов"
                                       delegate:nil cancelButtonTitle:@"Ок"
                              otherButtonTitles:nil] show];
        } else {
            
            [self.mapView removeOverlays:self.circlesOverlays];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            for (MKRoute *route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
    }];

}

// кнопка проложить маршрут
- (void) actionAddRoute:(UIBarButtonItem *) sender {
    
    if (self.event == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                    message:@"Нет конечной точки маршрута"
                                   delegate:nil cancelButtonTitle:@"Ок"
                          otherButtonTitles:nil] show];    }
    else {
        
        for (Student *student in self.students1km) {
            NSInteger randomNumberStudents1000 = arc4random() % (11 - 1) + 1;
            if (randomNumberStudents1000 >= 1 && randomNumberStudents1000 <= 9) {
                [self showDirectionsForStudent:student];
            }
        }
        
        for (Student *student in self.students2km) {
            NSInteger randomNumberStudents2000 = arc4random() % (11 - 1) + 1;
            if (randomNumberStudents2000 >= 1 && randomNumberStudents2000 <= 5) {
                [self showDirectionsForStudent:student];
            }
        }
        
        for (Student *student in self.students3km) {
            NSInteger randomNumberStudents3000 = arc4random() % (11 - 1) + 1;
            if (randomNumberStudents3000 >= 1 && randomNumberStudents3000 <= 2) {
                [self showDirectionsForStudent:student];
            }
        }
    }
}

// кнопка подробнее о встрече - поповер встречи
- (void) buttonInfoMeetingAction:(UIButton *) sender {
    
    UIView *callout = sender.superview;
    
    TableViewController *tabController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountPopover"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:tabController];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:callout.frame
                                      inView:callout.superview
                    permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight
                                    animated:YES];
    } else {
        [self presentViewController:tabController animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }
    
    // заполняем поповер данными о количестве студентов
    tabController.meetingImageView.image = [UIImage imageNamed:@"event"];
    tabController.count500metersLabel.text = [NSString stringWithFormat:@"%d студентов", [self.students1km count]];
    tabController.count1kmLabel.text = [NSString stringWithFormat:@"%d студентов", [self.students2km count]];
    tabController.count2kmLabel.text = [NSString stringWithFormat:@"%d студентов", [self.students3km count]];
}

#pragma mark - MKMapViewDelegate

// создается аннотация
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    Student *student = nil;
    Event *event = nil;
    
    if ([annotation isKindOfClass:[Student class]]) {
        student = (id <MKAnnotation>)annotation;
        
    } else if ([annotation isKindOfClass:[Event class]]) {
        event = (id <MKAnnotation>)annotation;
        
    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    if (!annotationView) {
        
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        // если аннотация студент
        if ([annotation isKindOfClass:[Student class]]) {
            
            if (student.isMale) {
                annotationView.image = [UIImage imageNamed:@"male"];
            } else {
                annotationView.image = [UIImage imageNamed:@"female"];
            }
            
            annotationView.canShowCallout = YES;
            
            // создаем кнопку справа на Callout
            UIButton *buttonInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [buttonInfo addTarget:self action:@selector(buttonInfoAction:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = buttonInfo;
        }
        
        // если аннотация встреча
        else if ([annotation isKindOfClass:[Event class]]) {
            annotationView.image = [UIImage imageNamed:@"event"];
            annotationView.canShowCallout = YES;
            annotationView.draggable = YES;
            
            UIButton *buttonInfoMeeting = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [buttonInfoMeeting addTarget:self
                                  action:@selector(buttonInfoMeetingAction:)
                        forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = buttonInfoMeeting;

            
            // создаем круги вокруг встречи
            MKCircle *circle1 = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:1000];
            MKCircle *circle2 = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:2000];
            MKCircle *circle3 = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:3000];
            
            self.fullCircle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:3000];
            self.midCircle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:2000];
            self.minCircle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:1000];
            
            [self.mapView addOverlay:circle1];
            [self.mapView addOverlay:circle2];
            [self.mapView addOverlay:circle3];
            
            [self.mapView addOverlay:self.fullCircle];
            [self.mapView addOverlay:self.midCircle];
            [self.mapView addOverlay:self.minCircle];
            
            // для последующего удаления кругов с экрана
            [self.circlesOverlays addObject:circle1];
            [self.circlesOverlays addObject:circle2];
            [self.circlesOverlays addObject:circle3];
            [self.circlesOverlays addObject:self.fullCircle];
            [self.circlesOverlays addObject:self.midCircle];
            [self.circlesOverlays addObject:self.minCircle];
            
            // делаем область видимости вместе с кругами
            self.zoomRectMeeting = [self.mapView mapRectThatFits:self.zoomRectMeeting];
            [self.mapView setVisibleMapRect:self.zoomRectMeeting edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:YES];
        }
    }
    return annotationView;
}

// когда рендерится что-то на карте
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        
        // если заполненный круг большой
        if ([overlay isEqual:self.fullCircle]) {
            renderer.fillColor = [UIColor colorWithRed:0 green:128 blue:255 alpha:0.1f];
        
        } else if ([overlay isEqual:self.midCircle]) {
            renderer.fillColor = [UIColor colorWithRed:0 green:128 blue:255 alpha:0.15f];
            
        } else if ([overlay isEqual:self.minCircle]) {
            renderer.fillColor = [UIColor colorWithRed:0 green:128 blue:255 alpha:0.2f];
        }
        // если пустой
        else {
            renderer.strokeColor = [UIColor colorWithRed:0 green:128 blue:255 alpha:1];
            renderer.lineWidth = 3.f;
        }
        
        // добавляем к общему rect circle rect для показа области видимости вместе с кругами
        self.zoomRect = MKMapRectUnion(self.zoomRect, overlay.boundingMapRect);
        self.zoomRectMeeting = MKMapRectUnion(self.zoomRectMeeting, overlay.boundingMapRect);
        
        return renderer;
        
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 3.f;
        renderer.strokeColor = [UIColor greenColor];
        return  renderer;
    }
    
    return nil;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    
    if (self.firtsTime) {
        self.firtsTime = NO;
        [self.mapView addAnnotations:self.studentsArray];
        [self showAllstudentsOnMap];
    }
}

#pragma mark - UIPopoverControllerDelegate

// удаляем поповер, после того как он исчез
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popover = nil;
}

@end
