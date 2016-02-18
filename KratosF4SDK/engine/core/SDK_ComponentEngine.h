//
// 组件引擎
//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDK_ComponentProtocol <NSObject>

// 单例
+ (id)sharedInstance;

// 是否可以在内存告紧时可以清除
- (BOOL)cleanable;

@end

@interface SDK_ComponentEngine : NSObject

// 单例
+ (instancetype)sharedInstance;

// 获取组件
- (id <SDK_ComponentProtocol>)componentWithClass:(Class)componentClass;

// 清理
- (void)clean;

@end