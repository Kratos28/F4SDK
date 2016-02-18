//
// Created by K on 11/20/14.
// Copyright (c) 2014 iOS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDK_BaseComponent.h"


@interface SDK_Runtime : SDK_BaseComponent

// 操作系统
@property (nonatomic, strong, readonly) NSString *os;

// 操作系统版本
@property (nonatomic, strong, readonly) NSString *osVersion;

// 应用名
@property (nonatomic, strong, readonly) NSString *appName;

// 应用版本
@property (nonatomic, strong, readonly) NSString *appVersion;

// 设备ID
@property (nonatomic, strong, readonly) NSString *udid;

// 缓存目录
@property(nonatomic, strong, readonly) NSString *cacheDirPath;

@end