//
// API 服务应答
//
// Created by K on 11/20/14.
// Copyright (c) 2014 iOS Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , SDK_ApiServiceResponseStatus)
{
    // 请求成功
    SDK_ApiServiceResponseStatusSuccess = 0,
    // 请求失败或有误
    SDK_ApiServiceResponseStatusFailure = 1
};

@interface SDK_ApiServiceResponse : NSObject

// 应答状态
@property (nonatomic, assign) SDK_ApiServiceResponseStatus status;
// 错误消息，如无错，则为nil
@property (nonatomic, strong) NSString *errorMessage;
// 应答内容
@property (nonatomic, strong) NSDictionary * content;

@end