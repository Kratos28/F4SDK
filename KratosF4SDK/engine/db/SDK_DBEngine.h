//
// 数据库引擎 (该类不允许被直接使用)
//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDK_BaseComponent.h"

@class SDK_DBStatement;
@class FMResultSet;


@interface SDK_DBEngine : SDK_BaseComponent

// 初始化数据库名称及当前最新版本
- (instancetype)initWithDBName:(NSString *)dbName newVersion:(int)newVersion;

// 初始准备，在进行所有操作前，需调该方法
- (void)prepareOnComplete:(void (^)(void))completeHandler;

// 执行更新语句
- (void)executeWithStatement:(SDK_DBStatement *)statement onComplete:(void (^)(void))completeHandler;

// 执行多个更新语句
- (void)executeWithStatements:(NSArray *)statements onComplete:(void (^)(void))completeHandler;

// 查询数据
- (void)queryWithStatement:(SDK_DBStatement *)statement
        resultSetProcessor:(id (^)(FMResultSet *))resultSetProcessor
               onCompleted:(void (^)(id))completeHandler;


@end