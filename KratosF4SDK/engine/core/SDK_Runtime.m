//
// Created by K on 11/20/14.
// Copyright (c) 2014 iOS Team. All rights reserved.
//

#import "SDK_Runtime.h"
#import "OpenUDID.h"
#import <UIKit/UIKit.h>

@implementation SDK_Runtime

- (id)init
{
    self = [super init];
    if (self)
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSDictionary *info = mainBundle.infoDictionary;
        _appName = info[@"CFBundleName"];
        _appVersion = info[@"CFBundleShortVersionString"];

        _os = [[UIDevice currentDevice] systemName];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _udid = [OpenUDID value];
    }
    return self;
}

- (NSString *)cacheDirPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths[0];
}

@end