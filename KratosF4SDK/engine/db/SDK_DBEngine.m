//
// Created by K on 10/11/14.
// Copyright (c) 2014 MobileTeam. All rights reserved.
//

#import "FMResultSet.h"
#import "SDK_DBEngine.h"
#import "FMDatabase.h"
#import "SDK_DBStatement.h"
#import "SDK_Runtime.h"

static NSString const *kPrevVersionKeyFormat = @"DB.PREV_VERSION.%@";

@interface SDK_DBEngine ()

// 当前数据库版本号
- (int)currentDbVersion;

// 同步同肯数据库版本号
- (void)syncCurrentDbVersion:(int)version;

// 创建数据库，如果需要的话
- (void)createDbIfNeed;

// 更新数据库，如果需要的话
- (void)upgradeDbIfNeed;

// 保存数据库文件的目录
- (NSString *)databaseDirPath;

@end


@implementation SDK_DBEngine
{
    // 数据库名
    NSString *_dbName;

    // 最新数据库版本
    int _newVersion;

    // 工作线程
    dispatch_queue_t _workingQueue;

    // 是否已准备完毕
    BOOL _prepared;

    // FMDB
    FMDatabase *_database;
}

- (instancetype)initWithDBName:(NSString *)dbName newVersion:(int)newVersion
{
    self = [super init];
    if (self)
    {
        _dbName = dbName;
        _newVersion = newVersion;
        _prepared = NO;
    }
    return self;
}


- (void)prepareOnComplete:(void (^)(void))completeHandler
{
    if (_prepared)
        return;

    NSString *workingQueueName = [NSString stringWithFormat:@"FMDB.%@", _dbName];
    _workingQueue = dispatch_queue_create(
            [workingQueueName cStringUsingEncoding:NSUTF8StringEncoding],
            DISPATCH_QUEUE_SERIAL
    );

    dispatch_async(_workingQueue, ^(void)
    {
        [self createDbIfNeed];
        [self upgradeDbIfNeed];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            _prepared = YES;
            completeHandler();
        });
    });
}


// 执行更新语句
- (void)executeWithStatement:(SDK_DBStatement *)statement onComplete:(void (^)(void))completeHandler
{
    dispatch_async(_workingQueue, ^(void)
    {
        [_database open];
        [_database executeQuery:statement.statement withParameterDictionary:statement.parameters];
        [_database close];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            completeHandler();
        });
    });
}


// 执行多个更新语句
- (void)executeWithStatements:(NSArray *)statements onComplete:(void (^)(void))completeHandler
{
    dispatch_async(_workingQueue, ^(void)
    {
        [_database open];

        for (SDK_DBStatement *statement in statements)
        {
            [_database executeQuery:statement.statement withParameterDictionary:statement.parameters];
        }

        [_database close];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            completeHandler();
        });
    });
}


// 查询数据
- (void)queryWithStatement:(SDK_DBStatement *)statement
        resultSetProcessor:(id (^)(FMResultSet *))resultSetProcessor
               onCompleted:(void (^)(id))completeHandler
{
    dispatch_async(_workingQueue, ^(void)
    {
        [_database open];

        FMResultSet *resultSet = [_database executeQuery:statement.statement
                                 withParameterDictionary:statement.parameters];
        id result = resultSetProcessor(resultSet);

        [_database close];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            completeHandler(result);
        });
    });
}


- (int)currentDbVersion
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:(NSString *) kPrevVersionKeyFormat, _dbName];
    NSNumber *prevVersion = [settings valueForKey:key];
    if (prevVersion == nil)
    {
        prevVersion = @0;
        [settings setValue:prevVersion forKey:key];
        [settings synchronize];
    }

    return [prevVersion intValue];
}


- (void)syncCurrentDbVersion:(int)version
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:(NSString *) kPrevVersionKeyFormat, _dbName];
    [settings setValue:@(version) forKey:key];
    [settings synchronize];
}


- (void)createDbIfNeed
{
    NSString *databaseFilePath = [NSString stringWithFormat:@"%@/%@.sqlite", [self databaseDirPath], _dbName];
    _database = [FMDatabase databaseWithPath:databaseFilePath];

    if ([self currentDbVersion] != 0)
        return;

    NSString *filename = [NSString stringWithFormat:@"FMDB.%@.1", _dbName];
    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:filename
                                                                         withExtension:@"sql"]];
    NSString *statements = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [_database open];
    NSLog(@"Create database \"%@\": \n%@", _dbName, statements);
    [_database executeStatements:statements];
    [_database close];


    // 初始数据库的version为1
    [self syncCurrentDbVersion:1];
}


- (void)upgradeDbIfNeed
{
    if ([self currentDbVersion] >= _newVersion)
        return;

    [_database open];
    for (int i = [self currentDbVersion] + 1; i <= _newVersion; i++)
    {
        NSString *filename = [NSString stringWithFormat:@"FMDB.%@.%d", _dbName, i];
        NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:filename
                                                                             withExtension:@"sql"]];
        NSString *statements = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        [_database open];
        NSLog(@"Upgrade database \"%@(%d)\": \n%@", _dbName, i, statements);
        [_database executeStatements:statements];
        [_database close];
    }
    [_database close];


    // upgrade database
    [self syncCurrentDbVersion:_newVersion];
}


- (NSString *)databaseDirPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *result = [NSString stringWithFormat:@"%@/db", [[SDK_Runtime sharedInstance] cacheDirPath]];
    if (![fileManager fileExistsAtPath:result])
    {
        [fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return result;
}


@end