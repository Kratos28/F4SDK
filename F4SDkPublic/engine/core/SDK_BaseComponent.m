//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import "SDK_BaseComponent.h"


@implementation SDK_BaseComponent

+ (id)sharedInstance
{
    return [[SDK_ComponentEngine sharedInstance] componentWithClass:self];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        NSLog(@"Component \"%@\" created.", NSStringFromClass([self class]));
    }

    return self;
}


- (BOOL)cleanable
{
    return YES;
}


- (void)dealloc
{
    NSLog(@"Component \"%@\" cleaned.", NSStringFromClass([self class]));
}


@end