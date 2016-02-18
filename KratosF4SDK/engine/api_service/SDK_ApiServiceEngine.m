//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import "SDK_ApiServiceEngine.h"
#import "AFHTTPRequestOperationManager.h"
#import "SDK_ApiServiceRequest.h"
#import "SDK_ApiServiceResponse.h"
#import "SDK_Runtime.h"
#import "NSData+SDK_Encrypt.h"

// api error domain
NSString *const SDK_ApiServiceErrorDomain = @"Api.Service.ErrorDomain";

// api error message key
NSString *const SDK_ApiServiceErrorMessage = @"Api.Service.ErrorMessage";


@implementation SDK_ApiServiceEngine
{
    __strong AFHTTPRequestOperationManager *_operationManager;
    __strong NSString *_baseUrl;
    __strong NSString *_secretKey;
    __strong NSOperationQueue *_operationQueue;
    __strong NSString *_sessionId;
}

- (instancetype)initWithBaseUrl:(NSString *)baseUrl secretKey:(NSString *)secretKey
{
    self = [super init];
    if (self)
    {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _baseUrl = baseUrl;
        _secretKey = secretKey;
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}



// 请求 WebService
- (NSOperation *)requestService:(NSString *)serviceName
                     parameters:(NSDictionary *)parameters
                      onSuccess:(void (^)(NSDictionary *))successHandler
                      onFailure:(void (^)(NSError *))failureHandler
{
    __block NSData *httpBody = nil;

    NSOperation *generateHttpBodyOperation = [NSBlockOperation blockOperationWithBlock:^(void)
    {
        SDK_ApiServiceRequest *request = [self generateServiceRequestWithServiceName:serviceName
                                                                          parameters:parameters];
        httpBody = [self encodeRequest:request];
    }];

    NSOperation *apiOperation;
    apiOperation = [NSBlockOperation blockOperationWithBlock:^(void)
    {
        void (^onSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *opt, id data)
        {
            SDK_ApiServiceResponse *response = [self decodeResponse:data];

            if (!opt.isCancelled)
            {
                if (response.status == SDK_ApiServiceResponseStatusSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                    {
                        successHandler(response.content);
                    });
                }
                else
                {
                    NSDictionary *userInfo = @{SDK_ApiServiceErrorMessage : response.errorMessage};
                    NSError *err = [NSError errorWithDomain:SDK_ApiServiceErrorDomain
                                                       code:response.status
                                                   userInfo:userInfo];

                    dispatch_async(dispatch_get_main_queue(), ^(void)
                    {
                        failureHandler(err);
                    });
                }
            }
        };

        void (^onFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *opt, NSError *err)
        {
            failureHandler(err);
        };

        if (!apiOperation.isCancelled)
        {
            NSError *error;
            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                         URLString:_baseUrl
                                                                                        parameters:nil
                                                                                             error:&error];

            if (error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    failureHandler(error);
                });
                return;
            }
            [request setHTTPBody:httpBody];

            NSOperation *requestOperation = [_operationManager HTTPRequestOperationWithRequest:request
                                                                                       success:onSuccess
                                                                                       failure:onFailure];
            [_operationManager.operationQueue addOperation:requestOperation];
        }
    }];

    [apiOperation addDependency:generateHttpBodyOperation];
    [_operationQueue addOperation:generateHttpBodyOperation];
    [_operationQueue addOperation:apiOperation];

    return apiOperation;
}


- (SDK_ApiServiceRequest *)generateServiceRequestWithServiceName:(NSString *)serviceName
                                                      parameters:(NSDictionary *)parameters
{
    SDK_ApiServiceRequest *request = [[SDK_ApiServiceRequest alloc] init];
    SDK_Runtime *runtime = [SDK_Runtime sharedInstance];
    request.serviceName = serviceName;
    request.os = runtime.os;
    request.osVersion = runtime.osVersion;
    request.appName = runtime.appName;
    request.appVersion = runtime.appVersion;
    request.udid = runtime.udid;
    request.params = parameters;
    request.sessionId = _sessionId;

    return request;
}


// 编码请求
- (NSData *)encodeRequest:(SDK_ApiServiceRequest *)request
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in request.params.allKeys)
    {
        id value = request.params[key];
        if ([value isKindOfClass:[NSData class]])
        {
            NSData *data = value;
            params[key] = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        else
        {
            params[key] = value;
        }
    }
    
    NSDictionary *jsonObject = @{
                                 @"service_name" : request.serviceName,
                                 @"os" : request.os,
                                 @"os_version" : request.osVersion,
                                 @"app_name" : request.appName,
                                 @"app_version" : request.appVersion,
                                 @"udid" : request.udid,
                                 @"params" : params
                                 };
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
    if (_secretKey != nil)
    {
        data = [data sdk_AESEncryptWithKey:_secretKey];
    }
    
    return data;
}


// 解码应答
- (SDK_ApiServiceResponse *)decodeResponse:(NSData *)responseData
{
    NSData *data = responseData;
    
    if (_secretKey != nil)
    {
        data = [responseData sdk_AESDecryptWithKey:_secretKey];
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    SDK_ApiServiceResponse *response = [[SDK_ApiServiceResponse alloc] init];
    response.status = (SDK_ApiServiceResponseStatus)[json[@"status"] intValue];
    response.errorMessage = json[@"error_message"];
    response.content = json[@"content"];
    
    return response;
}


// 预准备
- (NSOperation *)prepareOnSuccess:(void (^)(void))successHandler
                        onFailure:(void (^)(NSError *))failureHandler
{
    void (^onSuccess)(NSDictionary *) = ^(NSDictionary *json)
    {
        _sessionId = json[@"session_id"];
        successHandler();
    };
    
    return [self requestService:@"api.prepare" parameters:@{} onSuccess:onSuccess onFailure:failureHandler];
}


@end