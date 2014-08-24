//
//  UIView+MKAnnotationView.m
//  Lesson 37 - 38 home
//
//  Created by Андрей on 04.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import "UIView+MKAnnotationView.h"

@implementation UIView (MKAnnotationView)

- (MKAnnotationView *) superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
}

@end
