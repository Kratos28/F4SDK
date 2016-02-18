//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import "SDK_ComponentEngine.h"


@implementation SDK_ComponentEngine
{
    __strong NSMutableDictionary *_components;
}

static SDK_ComponentEngine *sharedInstance;


+ (instancetype)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[SDK_ComponentEngine alloc] init];
    }
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _components = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (id <SDK_ComponentProtocol>)componentWithClass:(Class)componentClass
{
    NSString *className = NSStringFromClass(componentClass);
    id <SDK_ComponentProtocol> result = _components[className];
    if (result == nil)
    {
        result = [[componentClass alloc] init];
        _components[className] = result;
    }
    return result;
}


- (void)clean
{
    NSArray *keys = [_components allKeys];
    for (NSString *key in keys)
    {
        id <SDK_ComponentProtocol> component = _components[key];
        if ([component cleanable])
        {
            [_components removeObjectForKey:key];
        }
    }
}

@end