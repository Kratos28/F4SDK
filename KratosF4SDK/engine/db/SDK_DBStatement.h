//
// 数据库操作语句
//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SDK_DBStatement : NSObject

// 语句
@property(nonatomic, strong) NSString *statement;

// 参数
@property(nonatomic, strong) NSDictionary *parameters;

// 初始化
- (instancetype)initWithStatement:(NSString *)statement parameters:(NSDictionary *)parameters;

@end