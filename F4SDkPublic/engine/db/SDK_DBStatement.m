//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import "SDK_DBStatement.h"


@implementation SDK_DBStatement

- (instancetype)initWithStatement:(NSString *)statement parameters:(NSDictionary *)parameters
{
    self = [super init];
    if (self)
    {
        _statement = statement;
        _parameters = parameters;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"SQL: %@ -> %@", _statement, _parameters];
}


- (NSString *)debugDescription
{
    return [self description];
}

@end